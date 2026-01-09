---
name: best-practices
description: Cloudflare 開発・運用のベストプラクティス集。プロジェクト構成、CI/CD、
セキュリティ、パフォーマンス最適化、コスト管理、トラブルシューティングを提供。
Use when user asks about project structure, CI/CD, GitHub Actions,
performance optimization, cost management, troubleshooting, or debugging.
Also use when user says ベストプラクティス, 最適化, トラブルシューティング, CI/CD, デバッグ.
---

# Cloudflare ベストプラクティス

## 概要

Cloudflare での開発・運用における推奨パターンとトラブルシューティング手法。
プロジェクト構成、CI/CD、セキュリティ、パフォーマンス、コスト最適化をカバー。

---

## プロジェクト構成

### 推奨ディレクトリ構造

```
my-project/
├── src/
│   ├── index.ts              # エントリーポイント
│   ├── handlers/             # リクエストハンドラー
│   ├── services/             # ビジネスロジック
│   ├── utils/                # ユーティリティ
│   └── types/                # 型定義
├── test/
│   ├── unit/                 # ユニットテスト
│   └── integration/          # 統合テスト
├── migrations/               # D1 マイグレーション
├── public/                   # 静的アセット（Pages）
├── wrangler.toml             # Wrangler 設定
├── vitest.config.ts          # テスト設定
├── tsconfig.json
└── package.json
```

### wrangler.toml テンプレート

```toml
#:schema node_modules/wrangler/config-schema.json
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

# 観測可能性
observability = { enabled = true }

# 開発環境変数
[vars]
ENVIRONMENT = "development"

# 本番環境
[env.production]
vars = { ENVIRONMENT = "production" }

# D1
[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxx"

# KV
[[kv_namespaces]]
binding = "KV"
id = "xxx"
preview_id = "yyy"

# R2
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"
```

### 環境管理

| 用途 | ファイル | Git 管理 |
|------|---------|----------|
| 共通設定 | `wrangler.toml` | ○ |
| ローカルシークレット | `.dev.vars` | × |
| 本番シークレット | ダッシュボード or CLI | - |

```bash
# シークレット設定（本番）
wrangler secret put API_KEY

# 環境別シークレット
wrangler secret put API_KEY --env production

# シークレット一覧
wrangler secret list
```

---

## CI/CD

### GitHub Actions（推奨）

#### Workers デプロイ

```yaml
# .github/workflows/deploy.yml
name: Deploy Workers

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - run: npm ci
      - run: npm run test
      - run: npm run typecheck

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - run: npm ci
      - run: npx wrangler deploy
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

#### Pages デプロイ

```yaml
name: Deploy Pages

on:
  push:
    branches: [main]
  pull_request:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - run: npm ci
      - run: npm run build

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          command: pages deploy dist --project-name=my-site
```

#### D1 マイグレーション

```yaml
name: D1 Migrations

on:
  push:
    branches: [main]
    paths: ["migrations/**"]

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"

      - run: npm ci

      - name: Run Migrations
        run: npx wrangler d1 migrations apply my-database --remote
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### API Token 作成

1. Cloudflare ダッシュボード → My Profile → API Tokens
2. 「Create Token」→ 「Custom token」
3. 必要な権限のみ付与（最小権限の原則）

**Workers 用**:
- Account: Workers Scripts (Edit)
- Account: Workers KV Storage (Edit)
- Account: Workers R2 Storage (Edit)
- Account: D1 (Edit)

**Pages 用**:
- Account: Cloudflare Pages (Edit)

---

## セキュリティベストプラクティス

### 入力検証

```typescript
import { z } from "zod";

const UserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150).optional(),
});

export default {
  async fetch(request: Request): Promise<Response> {
    if (request.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    try {
      const body = await request.json();
      const user = UserSchema.parse(body);
      // 検証済みデータを使用
      return Response.json({ success: true, user });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return Response.json({ error: error.errors }, { status: 400 });
      }
      return Response.json({ error: "Invalid request" }, { status: 400 });
    }
  },
};
```

### 認証パターン

```typescript
// JWT 検証
import { jwtVerify } from "jose";

async function verifyAuth(request: Request, env: Env): Promise<boolean> {
  const auth = request.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) {
    return false;
  }

  const token = auth.slice(7);
  try {
    const secret = new TextEncoder().encode(env.JWT_SECRET);
    await jwtVerify(token, secret);
    return true;
  } catch {
    return false;
  }
}
```

### CORS 設定

```typescript
const corsHeaders = {
  "Access-Control-Allow-Origin": "https://example.com",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Max-Age": "86400",
};

export default {
  async fetch(request: Request): Promise<Response> {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    const response = await handleRequest(request);

    // CORS ヘッダー追加
    Object.entries(corsHeaders).forEach(([key, value]) => {
      response.headers.set(key, value);
    });

    return response;
  },
};
```

### セキュリティヘッダー

```typescript
const securityHeaders = {
  "Content-Security-Policy": "default-src 'self'",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
  "Referrer-Policy": "strict-origin-when-cross-origin",
};
```

---

## パフォーマンス最適化

### キャッシュ戦略

```typescript
// Cache API を使用したカスタムキャッシュ
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    const cacheKey = new Request(request.url, request);
    const cache = caches.default;

    // キャッシュチェック
    let response = await cache.match(cacheKey);
    if (response) {
      return response;
    }

    // オリジンから取得
    response = await fetch(request);
    response = new Response(response.body, response);

    // キャッシュ制御ヘッダー設定
    response.headers.set("Cache-Control", "s-maxage=3600");

    // バックグラウンドでキャッシュ保存
    ctx.waitUntil(cache.put(cacheKey, response.clone()));

    return response;
  },
};
```

### KV キャッシュパターン

```typescript
async function getCachedData(
  key: string,
  fetcher: () => Promise<unknown>,
  ttl: number = 3600
): Promise<unknown> {
  // KV から取得
  const cached = await env.KV.get(key, "json");
  if (cached) {
    return cached;
  }

  // 新規取得
  const data = await fetcher();

  // バックグラウンドでキャッシュ
  ctx.waitUntil(
    env.KV.put(key, JSON.stringify(data), { expirationTtl: ttl })
  );

  return data;
}
```

### ストリーミング

```typescript
// 大きなレスポンスはストリーミング
export default {
  async fetch(request: Request, env: Env) {
    const object = await env.BUCKET.get("large-file.json");
    if (!object) {
      return new Response("Not found", { status: 404 });
    }

    // body を直接返す（ストリーミング）
    return new Response(object.body, {
      headers: {
        "Content-Type": "application/json",
      },
    });
  },
};
```

### バッチ処理

```typescript
// D1 バッチ挿入
async function batchInsert(users: User[]) {
  const BATCH_SIZE = 100;

  for (let i = 0; i < users.length; i += BATCH_SIZE) {
    const batch = users.slice(i, i + BATCH_SIZE);
    const statements = batch.map((user) =>
      env.DB.prepare(
        "INSERT INTO users (name, email) VALUES (?, ?)"
      ).bind(user.name, user.email)
    );

    await env.DB.batch(statements);
  }
}
```

---

## コスト最適化

### Workers

| 最適化 | 効果 |
|--------|------|
| キャッシュ活用 | リクエスト数削減 |
| 早期リターン | CPU 時間削減 |
| ストリーミング | メモリ使用量削減 |
| 軽量モデル使用 | haiku でサブエージェント |

### KV

- 結果整合性を理解して設計
- TTL を適切に設定
- 大きな値は R2 に移動

### R2

- エグレス無料を活用
- 不要オブジェクトを定期削除
- ライフサイクルルール設定

### D1

- インデックスを適切に設定
- N+1 クエリを避ける
- バッチ処理を活用

### Workers AI

```typescript
// ニューロン消費を最小化

// 1. 適切なモデル選択
const model = isSimpleTask
  ? "@cf/meta/llama-3.2-3b-instruct"  // 軽量
  : "@cf/meta/llama-3.1-8b-instruct"; // バランス

// 2. max_tokens を適切に設定
const response = await env.AI.run(model, {
  messages: [...],
  max_tokens: 256,  // 必要最小限
});

// 3. キャッシュ活用
const cacheKey = `ai:${hash(prompt)}`;
```

---

## トラブルシューティング

### デバッグコマンド

```bash
# ログ確認（リアルタイム）
wrangler tail

# フィルタリング
wrangler tail --status error
wrangler tail --method POST
wrangler tail --search "keyword"
wrangler tail --ip 192.168.1.1

# ログをJSON形式で出力
wrangler tail --format json

# ローカル開発
wrangler dev --local

# リモート開発（本番バインディング使用）
wrangler dev --remote
```

### よくある問題

#### 1. バインディングが undefined

**症状**:
```
TypeError: Cannot read property 'get' of undefined
```

**原因**: wrangler.toml の設定ミス or 環境変数未設定

**解決**:
```bash
# 設定確認
cat wrangler.toml

# バインディング一覧
wrangler whoami

# ローカルでテスト
wrangler dev --local
```

#### 2. D1 クエリエラー

**症状**:
```
D1_ERROR: no such table: users
```

**解決**:
```bash
# マイグレーション確認
wrangler d1 migrations list my-database

# マイグレーション適用
wrangler d1 migrations apply my-database --local
wrangler d1 migrations apply my-database --remote

# テーブル確認
wrangler d1 execute my-database --command "SELECT name FROM sqlite_master WHERE type='table'"
```

#### 3. Worker サイズ超過

**症状**:
```
Error: Worker exceeded size limit
```

**解決**:
```bash
# サイズ確認
wrangler deploy --dry-run --outdir dist

# 最適化
# 1. 未使用の依存関係を削除
# 2. 動的インポートを使用
# 3. 大きなデータは KV/R2 に移動
```

#### 4. CORS エラー

**症状**:
```
Access to fetch has been blocked by CORS policy
```

**解決**:
```typescript
// OPTIONS メソッドを処理
if (request.method === "OPTIONS") {
  return new Response(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
  });
}
```

#### 5. 504 Gateway Timeout

**症状**: Worker が 30 秒でタイムアウト

**解決**:
```typescript
// 長時間処理を分割
// 1. Queues を使用して非同期処理
await env.QUEUE.send({ task: "long-running", data: {...} });

// 2. Durable Objects で状態管理
// 3. waitUntil でバックグラウンド処理
ctx.waitUntil(longRunningTask());
return new Response("Accepted", { status: 202 });
```

### ログ・モニタリング

```typescript
// 構造化ログ
console.log(JSON.stringify({
  level: "info",
  message: "Request processed",
  path: request.url,
  method: request.method,
  duration: Date.now() - startTime,
  cf: request.cf,
}));

// エラーログ
console.error(JSON.stringify({
  level: "error",
  message: error.message,
  stack: error.stack,
  context: { userId, action },
}));
```

---

## テスト

### Vitest 設定

```typescript
// vitest.config.ts
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

### ユニットテスト

```typescript
import { describe, it, expect, beforeEach } from "vitest";
import { env, SELF } from "cloudflare:test";

describe("Worker", () => {
  it("should return 200 for GET /", async () => {
    const response = await SELF.fetch("https://example.com/");
    expect(response.status).toBe(200);
  });

  it("should use KV binding", async () => {
    await env.KV.put("test-key", "test-value");
    const value = await env.KV.get("test-key");
    expect(value).toBe("test-value");
  });
});
```

### 統合テスト

```typescript
describe("API Integration", () => {
  beforeEach(async () => {
    // D1 テストデータ準備
    await env.DB.exec(`
      DELETE FROM users;
      INSERT INTO users (id, name) VALUES (1, 'Test User');
    `);
  });

  it("should return user by id", async () => {
    const response = await SELF.fetch("https://example.com/api/users/1");
    const data = await response.json();
    expect(data.name).toBe("Test User");
  });
});
```

---

## チェックリスト

### デプロイ前

- [ ] テスト全パス
- [ ] TypeScript エラーなし
- [ ] シークレットが env にハードコードされていない
- [ ] wrangler.toml の compatibility_date が最新
- [ ] 不要な console.log を削除

### 本番運用

- [ ] エラー監視設定
- [ ] ログ収集設定
- [ ] アラート設定
- [ ] バックアップ設定（D1）
- [ ] Rate Limiting 設定

### セキュリティ

- [ ] 入力検証実装
- [ ] 認証/認可実装
- [ ] CORS 設定
- [ ] セキュリティヘッダー設定
- [ ] API Token の権限最小化

---

## 公式リソース

- [Workers Documentation](https://developers.cloudflare.com/workers/)
- [Pages Documentation](https://developers.cloudflare.com/pages/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)
- [Cloudflare Blog](https://blog.cloudflare.com/)
- [Discord Community](https://discord.gg/cloudflaredev)
