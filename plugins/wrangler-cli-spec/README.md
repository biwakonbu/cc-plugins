# wrangler-cli-spec

Cloudflare Wrangler CLI の仕様と使い方に関する知識プラグイン。

## 概要

Wrangler CLI の高度な機能（Durable Objects, Queues, Hyperdrive, Service Bindings）や、カスタムビルド設定（Webpack/esbuild）に関する知識を提供します。

## インストール

```bash
claude plugin install wrangler-cli-spec@cc-plugins
```

## 提供スキル

| スキル | 説明 |
|--------|------|
| `wrangler-cli-knowledge` | Wrangler CLI, Durable Objects, Queues, Hyperdrive, Service Bindings に関する知識 |

## 発動トリガー

以下のキーワードでスキルが自動発動します:

- Wrangler CLI
- Durable Objects
- Queues
- Hyperdrive
- Service Bindings
- カスタムビルド（Webpack/esbuild）

## 使用例

```
Durable Objects の設定方法を教えて
Queues の Producer と Consumer の設定は？
Hyperdrive で既存の PostgreSQL に接続するには？
Service Bindings で Workers 間通信を設定したい
```

## ライセンス

MIT
