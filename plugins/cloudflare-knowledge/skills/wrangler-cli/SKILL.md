---
name: wrangler-cli
description: Wrangler CLI の完全ガイド。コマンド一覧、設定ファイル、環境管理、ローカル開発について提供。wrangler dev, deploy, kv, r2, d1, pages, secret などのコマンド使用法。Use when user asks about wrangler commands, wrangler.toml configuration, local development, deployment, or CLI operations. Also use when user says wrangler コマンド, wrangler 設定, デプロイ方法, ローカル開発.
context: fork
---

# Wrangler CLI

## 概要

Wrangler は Cloudflare Workers、Pages、およびストレージサービス（KV、R2、D1）を
開発・デプロイするための公式 CLI ツール。2025年3月に v4.0.0 がリリースされた。

## インストール

```bash
# npm
npm install -g wrangler

# プロジェクトローカル（推奨）
npm install --save-dev wrangler

# 実行
npx wrangler <command>
```

## 基本コマンド

### 認証

```bash
# ブラウザ認証
wrangler login

# 認証状態確認
wrangler whoami

# ログアウト
wrangler logout
```

### プロジェクト作成

```bash
# 推奨方法（C3 経由）
npm create cloudflare@latest my-project

# テンプレート指定
npm create cloudflare@latest my-app -- --template hono

# 既存ディレクトリで初期化
wrangler init
```

### ローカル開発

```bash
# 開発サーバー起動
npx wrangler dev

# ポート指定
npx wrangler dev --port 8787

# リモートリソース使用
npx wrangler dev --remote

# 特定環境で起動
npx wrangler dev --env staging

# ローカルストレージ永続化
npx wrangler dev --persist
```

### デプロイ

```bash
# 本番デプロイ
npx wrangler deploy

# 環境指定
npx wrangler deploy --env production

# ドライラン
npx wrangler deploy --dry-run

# 特定ファイル
npx wrangler deploy src/worker.ts
```

### ログ・デバッグ

```bash
# リアルタイムログ
npx wrangler tail [worker-name]

# JSON形式
npx wrangler tail --format json

# 環境指定
npx wrangler tail --env production
```

### シークレット管理

```bash
# シークレット追加
wrangler secret put SECRET_NAME

# 環境指定
wrangler secret put SECRET_NAME --env production

# 一覧表示
wrangler secret list

# 削除
wrangler secret delete SECRET_NAME
```

### デプロイ管理

```bash
# デプロイ一覧
wrangler deployments list

# ロールバック
wrangler rollback

# 特定バージョンにロールバック
wrangler rollback <DEPLOYMENT_ID>
```

## ストレージサービス

### KV（Key-Value Store）

```bash
# Namespace 作成
wrangler kv namespace create MY_KV

# プレビュー用
wrangler kv namespace create MY_KV --preview

# データ操作
wrangler kv key put --binding=MY_KV "key" "value"
wrangler kv key get --binding=MY_KV "key"
wrangler kv key delete --binding=MY_KV "key"
wrangler kv key list --binding=MY_KV

# バルク操作
wrangler kv bulk put --binding=MY_KV ./data.json
```

### R2（オブジェクトストレージ）

```bash
# バケット作成
wrangler r2 bucket create my-bucket

# バケット一覧
wrangler r2 bucket list

# オブジェクト操作
wrangler r2 object put my-bucket/file.txt --file ./local.txt
wrangler r2 object get my-bucket/file.txt --file ./download.txt
wrangler r2 object delete my-bucket/file.txt
wrangler r2 object list my-bucket
```

### D1（SQLite データベース）

```bash
# データベース作成
wrangler d1 create my-database

# SQL 実行
wrangler d1 execute my-database --command "SELECT * FROM users;"

# ファイルから実行
wrangler d1 execute my-database --file ./schema.sql

# ローカル実行
wrangler d1 execute my-database --local --command "SELECT 1;"

# マイグレーション作成
wrangler d1 migrations create my-database "add_users"

# マイグレーション適用
wrangler d1 migrations apply my-database
```

### Pages

```bash
# デプロイ
npx wrangler pages deploy ./dist

# プロジェクト名指定
npx wrangler pages deploy ./dist --project-name my-site

# ブランチ指定（プレビュー）
npx wrangler pages deploy ./dist --branch preview

# プロジェクト一覧
wrangler pages project list

# デプロイ一覧
wrangler pages deployment list --project-name my-site
```

## wrangler.toml 設定

### 基本設定

```toml
#:schema node_modules/wrangler/config-schema.json
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

# workers.dev サブドメイン
workers_dev = true

# アカウントID（オプション）
account_id = "your-account-id"
```

### ルーティング

```toml
# シンプルなルート
route = "example.com/*"

# 複数ルート
routes = [
  "example.com/api/*",
  "api.example.com/*"
]

# 詳細設定
[[routes]]
pattern = "example.com/api/*"
zone_name = "example.com"

[[routes]]
pattern = "app.example.com/*"
custom_domain = true
```

### 環境変数

```toml
[vars]
API_URL = "https://api.example.com"
DEBUG = "false"
```

### バインディング

```toml
# KV
[[kv_namespaces]]
binding = "MY_KV"
id = "xxxx"
preview_id = "yyyy"

# R2
[[r2_buckets]]
binding = "MY_BUCKET"
bucket_name = "my-bucket"

# D1
[[d1_databases]]
binding = "DB"
database_name = "my-db"
database_id = "xxxx"

# Durable Objects
[durable_objects]
bindings = [
  { name = "MY_DO", class_name = "MyDurableObject" }
]

[[migrations]]
tag = "v1"
new_classes = ["MyDurableObject"]

# Service Bindings
[[services]]
binding = "AUTH_SERVICE"
service = "auth-worker"
environment = "production"

# Queues
[[queues.producers]]
binding = "MY_QUEUE"
queue = "my-queue"

[[queues.consumers]]
queue = "my-queue"
max_batch_size = 10
```

### 静的アセット（Workers Assets）

```toml
[assets]
directory = "./public"
binding = "ASSETS"
```

### Cron Triggers

```toml
[triggers]
crons = ["0 * * * *", "30 8 * * 1"]
```

### 環境別設定

```toml
# デフォルト
name = "my-worker"
[vars]
ENVIRONMENT = "development"

# Staging
[env.staging]
name = "my-worker-staging"
vars = { ENVIRONMENT = "staging" }
[[env.staging.routes]]
pattern = "staging.example.com/*"

# Production
[env.production]
name = "my-worker-production"
vars = { ENVIRONMENT = "production" }
[[env.production.routes]]
pattern = "example.com/*"
```

### カスタムビルド

```toml
[build]
command = "npm run build"
cwd = "."
watch_dir = "src"

[build.upload]
format = "modules"
main = "./dist/worker.mjs"
```

## ローカル開発

### .dev.vars

ローカル専用の環境変数ファイル（.gitignore 推奨）:

```
API_KEY=dev-secret-key
DATABASE_URL=localhost:5432
```

### Miniflare 3

`wrangler dev` は Miniflare 3.0（workerd ベース）を使用:

- 本番ランタイムと高い互換性
- KV、R2、D1 のローカルエミュレーション
- `--persist` で状態を永続化

## v4 の変更点

| 項目 | v3 | v4 |
|------|-----|-----|
| プロジェクト作成 | `wrangler generate` | `npm create cloudflare@latest` |
| デプロイ | `wrangler publish` | `wrangler deploy` |
| Node.js 要件 | v16+ | v18+ |
| 推奨設定ファイル | `wrangler.toml` | `wrangler.jsonc` |

### 削除されたコマンド

- `wrangler generate` → `npm create cloudflare@latest`
- `wrangler publish` → `wrangler deploy`
- `wrangler route` → `routes` 設定

## トラブルシューティング

### 認証エラー

```bash
# トークン再設定
wrangler logout && wrangler login

# 環境変数で設定
export CLOUDFLARE_API_TOKEN="your-token"
```

### デプロイ失敗

```bash
# 詳細ログ
wrangler deploy --verbose

# ドライラン確認
wrangler deploy --dry-run
```

### ローカル開発の問題

```bash
# キャッシュクリア
rm -rf .wrangler

# ストレージリセット
rm -rf .wrangler/state
```

## 公式リソース

- [Wrangler Commands](https://developers.cloudflare.com/workers/wrangler/commands/)
- [Wrangler Configuration](https://developers.cloudflare.com/workers/wrangler/configuration/)
- [Migration to v4](https://developers.cloudflare.com/workers/wrangler/migration/v4/)
