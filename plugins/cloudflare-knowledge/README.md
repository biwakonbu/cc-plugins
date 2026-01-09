# cloudflare-knowledge

Cloudflare エコシステム全体に関する包括的な知識を提供する Claude Code プラグイン。

## 概要

このプラグインは、Cloudflare に関する質問に対して自動的に適切な知識を提供します。
Wrangler CLI、Workers/Pages 開発、ストレージサービス、AI 機能、Terraform 管理、
セキュリティ機能など、Cloudflare の全領域をカバーしています。

## 提供される知識

| カテゴリ | 内容 |
|---------|------|
| **Wrangler CLI** | コマンド、設定ファイル、v4 変更点 |
| **Workers 開発** | アーキテクチャ、バインディング、Cron Triggers |
| **Pages デプロイ** | フレームワーク対応、Pages Functions |
| **ストレージ** | KV, R2, D1, Durable Objects, Queues, Hyperdrive |
| **Workers AI** | モデル一覧、Vectorize、AI Gateway |
| **Terraform** | Provider 設定、リソース管理、cf-terraforming |
| **セキュリティ** | Zero Trust, WAF, DDoS, Turnstile, SSL/TLS |
| **ベストプラクティス** | プロジェクト構成、CI/CD、最適化 |

## インストール

```bash
/plugin install cloudflare-knowledge@cc-plugins
```

## 使用例

以下のような質問をすると、適切なスキルが自動発動します：

- 「wrangler dev の使い方を教えて」
- 「D1 データベースを作成するには？」
- 「Workers AI で LLM を使う方法」
- 「Terraform で Cloudflare の DNS を管理したい」
- 「Cloudflare Zero Trust の設定方法」
- 「Next.js を Cloudflare Pages にデプロイする方法」

## 対応バージョン

- Wrangler v4.x
- Terraform Cloudflare Provider v5.x
- 2025年1月時点の Cloudflare サービス仕様

## ライセンス

MIT
