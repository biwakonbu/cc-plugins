---
name: workers-development
description: Cloudflare Workers の開発ガイド。アーキテクチャ、TypeScript/JavaScript 開発、
バインディング、Service Bindings、Cron Triggers、Workers Assets について提供。
Use when user asks about Workers development, edge functions, bindings,
service bindings, cron triggers, or Workers runtime.
Also use when user says Workers 開発, エッジ関数, バインディング, サービス連携.
---

# Cloudflare Workers Development

## 概要

Cloudflare Workers は、世界330以上のデータセンターで動作するサーバーレスエッジコンピューティングプラットフォーム。
V8 Isolates ベースでコールドスタートがほぼゼロ、低レイテンシを実現。

## アーキテクチャ

### V8 Isolates

- Chrome の V8 エンジンをベースにした軽量な実行環境
- 各リクエストが独立した Isolate で実行
- コンテナや VM より高速な起動

### 制限事項

| 項目 | Free プラン | Paid プラン |
|------|------------|------------|
| CPU 時間 | 10ms | 50ms（バースト可） |
| メモリ | 128MB | 128MB |
| サブリクエスト | 50/リクエスト | 1000/リクエスト |
| スクリプトサイズ | 1MB | 10MB |

## 基本構造

### ES Modules 形式（推奨）

```typescript
export interface Env {
  MY_KV: KVNamespace;
  DB: D1Database;
  MY_BUCKET: R2Bucket;
  AI: Ai;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/api/data") {
      const data = await env.MY_KV.get("key");
      return Response.json({ data });
    }

    return new Response("Hello Workers!");
  },

  async scheduled(event: ScheduledEvent, env: Env, ctx: ExecutionContext): Promise<void> {
    // Cron ジョブ
    ctx.waitUntil(doBackgroundWork(env));
  },

  async queue(batch: MessageBatch, env: Env, ctx: ExecutionContext): Promise<void> {
    // Queue consumer
    for (const message of batch.messages) {
      console.log(message.body);
      message.ack();
    }
  },
};
```

### Service Worker 形式（レガシー）

```javascript
addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  return new Response("Hello!");
}
```

## バインディング

Workers から他の Cloudflare サービスに接続するための設定。

### wrangler.toml での設定

```toml
# KV
[[kv_namespaces]]
binding = "MY_KV"
id = "xxx"

# R2
[[r2_buckets]]
binding = "MY_BUCKET"
bucket_name = "my-bucket"

# D1
[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxx"

# Durable Objects
[durable_objects]
bindings = [
  { name = "COUNTER", class_name = "Counter" }
]

# AI
[ai]
binding = "AI"

# Vectorize
[[vectorize]]
binding = "VECTORIZE"
index_name = "my-index"

# Service Bindings
[[services]]
binding = "AUTH"
service = "auth-worker"

# Queues
[[queues.producers]]
binding = "MY_QUEUE"
queue = "my-queue"

# Analytics Engine
[[analytics_engine_datasets]]
binding = "ANALYTICS"
dataset = "my-dataset"
```

### TypeScript 型定義

```typescript
export interface Env {
  // KV
  MY_KV: KVNamespace;

  // R2
  MY_BUCKET: R2Bucket;

  // D1
  DB: D1Database;

  // Durable Objects
  COUNTER: DurableObjectNamespace;

  // AI
  AI: Ai;

  // Vectorize
  VECTORIZE: VectorizeIndex;

  // Service Bindings
  AUTH: Fetcher;

  // Queues
  MY_QUEUE: Queue;

  // 環境変数
  API_URL: string;

  // シークレット
  API_KEY: string;
}
```

## Service Bindings

Workers 間の直接通信。HTTP オーバーヘッドなし。

### 設定

```toml
[[services]]
binding = "AUTH_SERVICE"
service = "auth-worker"
environment = "production"
```

### 使用例

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // 別の Worker を呼び出し
    const authResponse = await env.AUTH_SERVICE.fetch(
      new Request("https://auth/verify", {
        method: "POST",
        body: JSON.stringify({ token: "xxx" }),
      })
    );

    if (!authResponse.ok) {
      return new Response("Unauthorized", { status: 401 });
    }

    return new Response("Authorized!");
  },
};
```

## Cron Triggers

定期実行ジョブ。

### 設定

```toml
[triggers]
crons = [
  "0 * * * *",      # 毎時
  "30 8 * * 1-5",   # 平日 8:30
  "0 0 1 * *",      # 毎月1日
]
```

### ハンドラー

```typescript
export default {
  async scheduled(
    event: ScheduledEvent,
    env: Env,
    ctx: ExecutionContext
  ): Promise<void> {
    console.log(`Cron: ${event.cron}`);
    console.log(`Scheduled: ${new Date(event.scheduledTime)}`);

    // バックグラウンド処理
    ctx.waitUntil(
      env.DB.prepare("DELETE FROM logs WHERE created_at < ?")
        .bind(Date.now() - 7 * 24 * 60 * 60 * 1000)
        .run()
    );
  },
};
```

## Workers Assets

静的ファイルの配信（Workers Sites の後継）。

### 設定

```toml
[assets]
directory = "./public"
binding = "ASSETS"  # オプション
```

### 動作

1. リクエスト URL が静的ファイルに一致 → 自動配信
2. 一致しない → Worker スクリプト実行

### プログラムからのアクセス

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // アセットを取得
    const assetResponse = await env.ASSETS.fetch(request);

    if (assetResponse.status !== 404) {
      return assetResponse;
    }

    // カスタム404
    return new Response("Not Found", { status: 404 });
  },
};
```

## ExecutionContext

### waitUntil

レスポンス後もバックグラウンドで処理を継続。

```typescript
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // レスポンスを即座に返す
    const response = new Response("OK");

    // バックグラウンドでログ記録
    ctx.waitUntil(
      env.MY_KV.put("last_access", new Date().toISOString())
    );

    return response;
  },
};
```

### passThroughOnException

エラー時にオリジンにフォールバック。

```typescript
ctx.passThroughOnException();
```

## Node.js 互換性

### 有効化

```toml
compatibility_flags = ["nodejs_compat"]
```

### 使用可能な API

```typescript
import { Buffer } from "node:buffer";
import { createHash } from "node:crypto";
import { EventEmitter } from "node:events";

const hash = createHash("sha256").update("data").digest("hex");
```

### 互換性のあるモジュール

- `node:buffer`
- `node:crypto`
- `node:events`
- `node:stream`
- `node:util`
- `node:assert`
- `node:path`

## fetch API

### 外部 API 呼び出し

```typescript
const response = await fetch("https://api.example.com/data", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${env.API_KEY}`,
  },
  body: JSON.stringify({ key: "value" }),
});

const data = await response.json();
```

### リクエスト変換

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    url.hostname = "api.example.com";

    const modifiedRequest = new Request(url, {
      method: request.method,
      headers: request.headers,
      body: request.body,
    });

    return fetch(modifiedRequest);
  },
};
```

## ミドルウェアパターン

```typescript
type Middleware = (
  request: Request,
  env: Env,
  ctx: ExecutionContext,
  next: () => Promise<Response>
) => Promise<Response>;

const withAuth: Middleware = async (request, env, ctx, next) => {
  const token = request.headers.get("Authorization");
  if (!token) {
    return new Response("Unauthorized", { status: 401 });
  }
  return next();
};

const withCors: Middleware = async (request, env, ctx, next) => {
  const response = await next();
  response.headers.set("Access-Control-Allow-Origin", "*");
  return response;
};

// 使用
const middlewares = [withCors, withAuth];

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    let handler = async () => new Response("Hello!");

    for (const mw of middlewares.reverse()) {
      const next = handler;
      handler = () => mw(request, env, ctx, next);
    }

    return handler();
  },
};
```

## テスト

### Vitest（推奨）

```typescript
import { env, createExecutionContext, waitOnExecutionContext } from "cloudflare:test";
import { describe, it, expect } from "vitest";
import worker from "./index";

describe("Worker", () => {
  it("returns hello", async () => {
    const request = new Request("https://example.com/");
    const ctx = createExecutionContext();
    const response = await worker.fetch(request, env, ctx);
    await waitOnExecutionContext(ctx);

    expect(response.status).toBe(200);
    expect(await response.text()).toBe("Hello!");
  });
});
```

### vitest.config.ts

```typescript
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

export default defineWorkersConfig({
  test: {
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.toml" },
      },
    },
  },
});
```

## デバッグ

### console.log

```typescript
console.log("Debug:", { key: value });
console.error("Error:", error);
console.time("operation");
// ...
console.timeEnd("operation");
```

### wrangler tail

```bash
npx wrangler tail --format pretty
```

## 公式リソース

- [Workers Documentation](https://developers.cloudflare.com/workers/)
- [Workers Examples](https://developers.cloudflare.com/workers/examples/)
- [Workers Runtime APIs](https://developers.cloudflare.com/workers/runtime-apis/)
