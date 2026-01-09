---
name: storage-services
description: Cloudflare ストレージサービスの完全ガイド。KV、R2、D1、Durable Objects、
Queues、Hyperdrive の使い方、設定、ベストプラクティスを提供。
Use when user asks about KV, R2, D1, Durable Objects, Queues, Hyperdrive,
storage, database, or data persistence on Cloudflare.
Also use when user says KV ストア, R2 バケット, D1 データベース, Durable Objects,
キュー, ストレージ.
---

# Cloudflare Storage Services

## サービス概要

| サービス | 種類 | 特徴 | 用途 |
|---------|------|------|------|
| **KV** | Key-Value | 高速読み取り、結果整合性 | キャッシュ、設定 |
| **R2** | オブジェクト | S3互換、エグレス無料 | ファイル保存 |
| **D1** | SQL | SQLite、エッジネイティブ | アプリデータ |
| **Durable Objects** | ステートフル | 単一インスタンス保証 | リアルタイム |
| **Queues** | メッセージ | 非同期処理 | バッチ、ETL |
| **Hyperdrive** | 接続プール | 既存DB高速化 | レガシーDB |

---

## KV（Workers KV）

### 概要

グローバルに分散された Key-Value ストア。読み取り最適化、結果整合性。

### 特徴

- **読み取りレイテンシ**: 5ms未満（p99）
- **書き込み伝播**: 最大60秒
- **値サイズ**: 最大25MB
- **キー数**: 1,000万/Namespace

### 設定

```toml
# wrangler.toml
[[kv_namespaces]]
binding = "MY_KV"
id = "xxx"
preview_id = "yyy"
```

### 基本操作

```typescript
// 取得
const value = await env.MY_KV.get("key");
const json = await env.MY_KV.get("key", "json");
const stream = await env.MY_KV.get("key", "stream");

// メタデータ付き取得
const { value, metadata } = await env.MY_KV.getWithMetadata("key");

// 保存
await env.MY_KV.put("key", "value");
await env.MY_KV.put("key", JSON.stringify(data));

// TTL付き
await env.MY_KV.put("key", "value", {
  expirationTtl: 3600,  // 1時間
});

// メタデータ付き
await env.MY_KV.put("key", "value", {
  metadata: { createdAt: Date.now() },
});

// 削除
await env.MY_KV.delete("key");

// リスト
const { keys, cursor } = await env.MY_KV.list({ prefix: "user:" });
```

### ベストプラクティス

```typescript
// キャッシュパターン
async function getCached(key: string, fetcher: () => Promise<string>) {
  let value = await env.MY_KV.get(key);
  if (!value) {
    value = await fetcher();
    await env.MY_KV.put(key, value, { expirationTtl: 3600 });
  }
  return value;
}
```

---

## R2（オブジェクトストレージ）

### 概要

S3 互換のオブジェクトストレージ。**エグレス料金無料**が最大の特徴。

### 特徴

- **S3 互換 API**
- **エグレス料金**: 無料
- **オブジェクトサイズ**: 最大5GB（マルチパート対応）
- **ストレージ**: 無制限

### 設定

```toml
# wrangler.toml
[[r2_buckets]]
binding = "MY_BUCKET"
bucket_name = "my-bucket"
```

### 基本操作

```typescript
// アップロード
await env.MY_BUCKET.put("path/to/file.txt", "content");
await env.MY_BUCKET.put("image.png", imageBuffer, {
  httpMetadata: { contentType: "image/png" },
});

// ダウンロード
const object = await env.MY_BUCKET.get("path/to/file.txt");
if (object) {
  const text = await object.text();
  const headers = new Headers();
  object.writeHttpMetadata(headers);
}

// 削除
await env.MY_BUCKET.delete("path/to/file.txt");

// リスト
const { objects, truncated, cursor } = await env.MY_BUCKET.list({
  prefix: "images/",
  limit: 100,
});

// HEAD
const head = await env.MY_BUCKET.head("path/to/file.txt");
```

### 署名付きURL

```typescript
// R2 の署名付きURLは現在ベータ
// 代替: Workers で認証してストリーミング

export default {
  async fetch(request: Request, env: Env) {
    const url = new URL(request.url);
    const key = url.pathname.slice(1);

    // 認証チェック
    if (!isAuthenticated(request)) {
      return new Response("Unauthorized", { status: 401 });
    }

    const object = await env.MY_BUCKET.get(key);
    if (!object) {
      return new Response("Not Found", { status: 404 });
    }

    const headers = new Headers();
    object.writeHttpMetadata(headers);
    return new Response(object.body, { headers });
  },
};
```

---

## D1（SQLite データベース）

### 概要

サーバーレス SQLite データベース。エッジネイティブでグローバル読み取りレプリケーション対応。

### 特徴

- **SQLite 互換**
- **Time Travel**: 30日間の任意時点復元
- **グローバル読み取り**: ベータ機能
- **サイズ**: 10GB/DB（Paid）

### 設定

```toml
# wrangler.toml
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxx"
```

### 基本操作

```typescript
// クエリ実行
const { results } = await env.DB.prepare(
  "SELECT * FROM users WHERE id = ?"
).bind(userId).all();

// 単一行取得
const user = await env.DB.prepare(
  "SELECT * FROM users WHERE id = ?"
).bind(userId).first();

// 挿入
const { meta } = await env.DB.prepare(
  "INSERT INTO users (name, email) VALUES (?, ?)"
).bind(name, email).run();

const lastRowId = meta.last_row_id;
const changes = meta.changes;

// バッチ実行
const results = await env.DB.batch([
  env.DB.prepare("INSERT INTO users (name) VALUES (?)").bind("Alice"),
  env.DB.prepare("INSERT INTO users (name) VALUES (?)").bind("Bob"),
]);

// 生SQL
const { results } = await env.DB.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE
  )
`);
```

### マイグレーション

```bash
# マイグレーション作成
wrangler d1 migrations create my-database "add_users_table"

# ファイル編集: migrations/0001_add_users_table.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

# 適用
wrangler d1 migrations apply my-database

# ローカル適用
wrangler d1 migrations apply my-database --local
```

### ORM（Drizzle）

```typescript
import { drizzle } from "drizzle-orm/d1";
import { users } from "./schema";

export default {
  async fetch(request: Request, env: Env) {
    const db = drizzle(env.DB);
    const allUsers = await db.select().from(users).all();
    return Response.json(allUsers);
  },
};
```

---

## Durable Objects

### 概要

ステートフルなエッジコンピューティング。グローバルで単一インスタンスを保証。

### 特徴

- **単一インスタンス保証**: 同じIDは常に同じインスタンス
- **永続ストレージ**: SQLite Storage
- **リアルタイム対応**: WebSocket サポート

### 設定

```toml
# wrangler.toml
[durable_objects]
bindings = [
  { name = "COUNTER", class_name = "Counter" }
]

[[migrations]]
tag = "v1"
new_classes = ["Counter"]
```

### 実装

```typescript
export class Counter {
  private state: DurableObjectState;
  private count: number = 0;

  constructor(state: DurableObjectState, env: Env) {
    this.state = state;
    // SQLite Storage からの復元
    this.state.blockConcurrencyWhile(async () => {
      const stored = await this.state.storage.get<number>("count");
      this.count = stored ?? 0;
    });
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/increment") {
      this.count++;
      await this.state.storage.put("count", this.count);
    }

    return new Response(String(this.count));
  }
}

// Worker から呼び出し
export default {
  async fetch(request: Request, env: Env) {
    const id = env.COUNTER.idFromName("global");
    const stub = env.COUNTER.get(id);
    return stub.fetch(request);
  },
};
```

### WebSocket サポート

```typescript
export class ChatRoom {
  private sessions: Set<WebSocket> = new Set();

  async fetch(request: Request): Promise<Response> {
    if (request.headers.get("Upgrade") === "websocket") {
      const pair = new WebSocketPair();
      const [client, server] = Object.values(pair);

      server.accept();
      this.sessions.add(server);

      server.addEventListener("message", (event) => {
        for (const session of this.sessions) {
          session.send(event.data);
        }
      });

      server.addEventListener("close", () => {
        this.sessions.delete(server);
      });

      return new Response(null, { status: 101, webSocket: client });
    }

    return new Response("Expected WebSocket", { status: 400 });
  }
}
```

---

## Queues

### 概要

Workers 間の非同期メッセージング。バッチ処理、ETL パイプラインに最適。

### 設定

```toml
# wrangler.toml
# Producer
[[queues.producers]]
binding = "MY_QUEUE"
queue = "my-queue"

# Consumer
[[queues.consumers]]
queue = "my-queue"
max_batch_size = 10
max_batch_timeout = 30
```

### Producer

```typescript
export default {
  async fetch(request: Request, env: Env) {
    await env.MY_QUEUE.send({
      type: "user_created",
      userId: 123,
      timestamp: Date.now(),
    });

    // バッチ送信
    await env.MY_QUEUE.sendBatch([
      { body: { id: 1 } },
      { body: { id: 2 } },
    ]);

    return new Response("Queued");
  },
};
```

### Consumer

```typescript
export default {
  async queue(
    batch: MessageBatch,
    env: Env,
    ctx: ExecutionContext
  ): Promise<void> {
    for (const message of batch.messages) {
      try {
        console.log(message.body);
        message.ack();
      } catch (error) {
        message.retry();
      }
    }
  },
};
```

---

## Hyperdrive

### 概要

既存の PostgreSQL/MySQL への接続を高速化。接続プーリングと地域キャッシュ。

### 特徴

- **接続プーリング**: コネクション再利用
- **クエリキャッシュ**: エッジでのキャッシュ
- **レイテンシ削減**: 最大10倍高速化

### 設定

```bash
# Hyperdrive 作成
wrangler hyperdrive create my-hyperdrive \
  --connection-string="postgres://user:pass@host:5432/db"
```

```toml
# wrangler.toml
[[hyperdrive]]
binding = "HYPERDRIVE"
id = "xxx"
```

### 使用例

```typescript
import { Client } from "pg";

export default {
  async fetch(request: Request, env: Env) {
    const client = new Client(env.HYPERDRIVE.connectionString);
    await client.connect();

    const result = await client.query("SELECT * FROM users LIMIT 10");
    await client.end();

    return Response.json(result.rows);
  },
};
```

---

## 比較表

| 項目 | KV | R2 | D1 | DO |
|------|-----|-----|-----|-----|
| 整合性 | 結果整合 | 強整合 | 強整合 | 強整合 |
| 読み取り | 超高速 | 高速 | 高速 | 中速 |
| 書き込み | 遅い | 中速 | 中速 | 高速 |
| クエリ | キーのみ | プレフィックス | SQL | カスタム |
| 用途 | キャッシュ | ファイル | 構造化データ | リアルタイム |

---

## 公式リソース

- [KV Documentation](https://developers.cloudflare.com/kv/)
- [R2 Documentation](https://developers.cloudflare.com/r2/)
- [D1 Documentation](https://developers.cloudflare.com/d1/)
- [Durable Objects](https://developers.cloudflare.com/durable-objects/)
- [Queues](https://developers.cloudflare.com/queues/)
- [Hyperdrive](https://developers.cloudflare.com/hyperdrive/)
