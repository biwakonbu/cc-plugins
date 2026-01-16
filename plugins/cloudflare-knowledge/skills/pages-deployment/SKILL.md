---
name: pages-deployment
description: Cloudflare Pages のデプロイメントガイド。Pages Functions、フレームワーク対応（Next.js, Nuxt, Astro, SvelteKit, Remix, Hono）、ビルド設定、プレビュー環境について提供。Use when user asks about Pages deployment, Pages Functions, framework support, Next.js, Nuxt, Astro, SvelteKit, Remix, or Hono on Cloudflare. Also use when user says Pages デプロイ, フレームワーク, SSR, 静的サイト.
context: fork
---

# Cloudflare Pages Deployment

## 概要

Cloudflare Pages は静的サイトとフルスタックアプリケーションのホスティングプラットフォーム。
Git 連携による自動デプロイ、Pages Functions（Workers 統合）、プレビュー環境を提供。

2025年現在、Pages と Workers の境界は事実上消滅し、フルスタックエッジアプリとして統合。

## デプロイ方法

### Wrangler CLI

```bash
# 静的サイトをデプロイ
npx wrangler pages deploy ./dist

# プロジェクト名指定
npx wrangler pages deploy ./dist --project-name my-site

# ブランチ指定（プレビュー）
npx wrangler pages deploy ./dist --branch preview
```

### Git 連携

Cloudflare ダッシュボードで GitHub/GitLab を接続:
1. リポジトリ選択
2. ビルドコマンド・出力ディレクトリ設定
3. 自動デプロイ有効化

## Pages Functions

### ディレクトリ構造

```
project/
├── functions/              # Functions ディレクトリ（必須）
│   ├── index.ts           # → /
│   ├── hello.ts           # → /hello
│   ├── api/
│   │   ├── data.ts        # → /api/data
│   │   └── users/
│   │       └── [id].ts    # → /api/users/:id
│   ├── _middleware.ts     # ミドルウェア
│   └── [[path]].ts        # キャッチオール
└── public/                 # 静的アセット
```

### ルーティング

| パターン | ファイル | マッチ |
|---------|---------|--------|
| 静的 | `functions/hello.ts` | `/hello` |
| 動的 | `functions/posts/[id].ts` | `/posts/123` |
| キャッチオール | `functions/api/[[path]].ts` | `/api/a/b/c` |

### ハンドラー

```typescript
// functions/api/users/[id].ts
export const onRequestGet: PagesFunction<Env> = async (context) => {
  const userId = context.params.id;
  const user = await context.env.DB.prepare(
    "SELECT * FROM users WHERE id = ?"
  ).bind(userId).first();

  if (!user) {
    return new Response("Not found", { status: 404 });
  }

  return Response.json(user);
};

export const onRequestPost: PagesFunction<Env> = async (context) => {
  const body = await context.request.json();
  // ...
  return Response.json({ success: true });
};

// 全メソッド対応
export const onRequest: PagesFunction<Env> = async (context) => {
  return new Response(`Method: ${context.request.method}`);
};
```

### ミドルウェア

```typescript
// functions/_middleware.ts
export const onRequest: PagesFunction<Env> = async (context) => {
  // 認証チェック
  const auth = context.request.headers.get("Authorization");
  if (!auth && context.request.url.includes("/api/")) {
    return new Response("Unauthorized", { status: 401 });
  }

  // 次のハンドラーへ
  const response = await context.next();

  // レスポンス加工
  response.headers.set("X-Custom-Header", "value");
  return response;
};
```

### context オブジェクト

```typescript
interface EventContext<Env> {
  request: Request;
  env: Env;
  params: Record<string, string>;
  waitUntil(promise: Promise<unknown>): void;
  passThroughOnException(): void;
  next(): Promise<Response>;
  data: Record<string, unknown>;  // ミドルウェア間でデータ共有
}
```

## フレームワーク対応

### 対応状況

| フレームワーク | 方式 | SSR | ISR | 備考 |
|--------------|------|-----|-----|------|
| **Next.js** | OpenNext + Workers | ○ | ○ | App Router 完全対応 |
| **Nuxt 3** | Pages 直接 | ○ | ○ | Nitro プリセット |
| **Astro** | `@astrojs/cloudflare` | ○ | - | アダプター必須 |
| **SvelteKit** | `@sveltejs/adapter-cloudflare` | ○ | - | |
| **Remix** | Pages 直接 | ○ | - | エッジネイティブ |
| **Hono** | Workers/Pages | ○ | - | 最も親和性高 |

### Next.js（OpenNext）

**2025年推奨**: OpenNext + Cloudflare Workers

```bash
# プロジェクト作成
npm create cloudflare@latest my-next-app -- --framework=next

# ビルド
npx open-next@cloudflare build

# デプロイ
npx wrangler deploy
```

**対応機能**:
- App Router
- React Server Components
- Server Actions
- ISR（Incremental Static Regeneration）
- 画像最適化

### Nuxt 3

ゼロ設定でデプロイ可能:

```bash
# ビルド（SSR）
nuxt build

# ビルド（静的）
nuxt generate

# デプロイ
npx wrangler pages deploy .output/public
```

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  nitro: {
    preset: "cloudflare-pages",
  },
});
```

### Astro

```bash
# アダプター追加
npx astro add cloudflare
```

```javascript
// astro.config.mjs
import cloudflare from "@astrojs/cloudflare";

export default defineConfig({
  output: "server",  // または "hybrid"
  adapter: cloudflare(),
});
```

### SvelteKit

```bash
# アダプター追加
npm install -D @sveltejs/adapter-cloudflare
```

```javascript
// svelte.config.js
import adapter from "@sveltejs/adapter-cloudflare";

export default {
  kit: {
    adapter: adapter(),
  },
};
```

### Remix

```bash
# テンプレートから作成
npx create-cloudflare@latest my-remix-app -- --framework=remix
```

### Hono

最も Cloudflare に最適化されたフレームワーク:

```bash
npm create cloudflare@latest my-app -- --template hono
```

```typescript
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.text("Hello Hono!"));

app.get("/api/users/:id", async (c) => {
  const id = c.req.param("id");
  const user = await c.env.DB.prepare(
    "SELECT * FROM users WHERE id = ?"
  ).bind(id).first();
  return c.json(user);
});

export default app;
```

## wrangler.toml 設定

### Pages 用設定

```toml
#:schema node_modules/wrangler/config-schema.json
name = "my-pages-app"
compatibility_date = "2025-01-01"

# ビルド出力ディレクトリ
pages_build_output_dir = "dist"

# 環境変数
[vars]
API_URL = "https://api.example.com"

# D1
[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxx"

# KV
[[kv_namespaces]]
binding = "KV"
id = "xxx"

# R2
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"
```

### 環境別設定

```toml
[env.preview]
vars = { API_URL = "https://staging-api.example.com" }

[env.production]
vars = { API_URL = "https://api.example.com" }
```

## プレビュー環境

### 自動生成

- プルリクエストごとに自動で一意の URL が生成
- `https://<hash>.<project>.pages.dev`

### ブランチ指定

```bash
# 特定ブランチとしてデプロイ
npx wrangler pages deploy ./dist --branch feature-x
```

### プレビュー保護

Cloudflare Access でプレビュー URL を保護可能。

## ビルド設定

### ダッシュボード設定

| 設定 | 例 |
|------|-----|
| ビルドコマンド | `npm run build` |
| ビルド出力ディレクトリ | `dist` / `.next` / `.output/public` |
| ルートディレクトリ | `/` または `apps/web` |

### 環境変数

| 場所 | 用途 |
|------|------|
| ダッシュボード | 本番シークレット |
| `.dev.vars` | ローカル開発 |
| `wrangler.toml` の `[vars]` | 非機密設定 |

### ビルド環境変数（自動設定）

| 変数 | 説明 |
|------|------|
| `CF_PAGES` | Pages ビルドかどうか |
| `CF_PAGES_BRANCH` | ブランチ名 |
| `CF_PAGES_COMMIT_SHA` | コミットハッシュ |
| `CF_PAGES_URL` | デプロイ URL |

## Advanced Mode

Pages Functions のルーティングが不十分な場合、`_worker.js` を直接配置:

```javascript
// dist/_worker.js
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // 静的アセット
    if (url.pathname.startsWith("/assets/")) {
      return env.ASSETS.fetch(request);
    }

    // API
    if (url.pathname.startsWith("/api/")) {
      return handleApi(request, env);
    }

    // SPA フォールバック
    return env.ASSETS.fetch(new Request(
      new URL("/index.html", request.url),
      request
    ));
  },
};
```

## カスタムドメイン

### 設定方法

1. ダッシュボードで「カスタムドメイン」追加
2. DNS レコードが自動設定（Cloudflare DNS の場合）
3. SSL 証明書が自動発行

### 手動 DNS 設定

外部 DNS の場合:

```
CNAME  www  <project>.pages.dev
```

## 制限事項

| 項目 | 制限 |
|------|------|
| ビルド時間 | 20分（Free）/ 30分（Pro） |
| ファイルサイズ | 25MB/ファイル |
| ファイル数 | 20,000ファイル |
| Functions | Workers と同じ制限 |
| ビルド数 | 500/月（Free）/ 5000/月（Pro） |

## 公式リソース

- [Pages Documentation](https://developers.cloudflare.com/pages/)
- [Pages Functions](https://developers.cloudflare.com/pages/functions/)
- [Framework Guides](https://developers.cloudflare.com/pages/framework-guides/)
