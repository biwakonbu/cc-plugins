# cloudflare-knowledge プラグイン

## 概要

Cloudflare エコシステム全体に関する包括的な知識を提供するプラグイン。
ユーザーが Cloudflare に関する質問をすると、適切なスキルが自動発動して情報を提供する。

## ディレクトリ構造

```
cloudflare-knowledge/
├── .claude-plugin/plugin.json
├── CLAUDE.md
├── README.md
└── skills/
    ├── cloudflare-overview/SKILL.md    # 統合スキル（ナビゲーション）
    ├── wrangler-cli/SKILL.md           # Wrangler CLI
    ├── workers-development/SKILL.md    # Workers 開発
    ├── pages-deployment/SKILL.md       # Pages デプロイ
    ├── storage-services/SKILL.md       # KV, R2, D1, DO, Queues
    ├── workers-ai/SKILL.md             # Workers AI, Vectorize
    ├── terraform-management/SKILL.md   # Terraform/Pulumi
    ├── security-features/SKILL.md      # Zero Trust, WAF
    └── best-practices/SKILL.md         # ベストプラクティス
```

## 設計方針

### context: fork の活用（v1.1.0）

全9スキルに `context: fork` を設定。
各スキルがサブエージェント化され、独立したコンテキストで実行。
メインコンテキスト保護とトークン消費最適化を実現。

### スキル構成

| スキル | 役割 | 発動条件 |
|--------|------|----------|
| cloudflare-overview | 全体概要・ナビゲーション | 「Cloudflare とは」「サービス一覧」 |
| wrangler-cli | CLI 操作全般 | 「wrangler」「デプロイ」「コマンド」 |
| workers-development | Workers 開発 | 「Workers」「エッジ関数」「バインディング」 |
| pages-deployment | Pages 静的サイト/SSR | 「Pages」「フレームワーク」「Next.js」 |
| storage-services | データストア全般 | 「KV」「R2」「D1」「Durable Objects」 |
| workers-ai | AI/ML 機能 | 「Workers AI」「Vectorize」「AI Gateway」 |
| terraform-management | IaC 管理 | 「Terraform」「Pulumi」「インフラ管理」 |
| security-features | セキュリティ | 「Zero Trust」「WAF」「DDoS」「Turnstile」 |
| best-practices | ベストプラクティス | 「最適化」「CI/CD」「構成」 |

### 情報ソース

- Cloudflare 公式ドキュメント（developers.cloudflare.com）
- Cloudflare ブログ（blog.cloudflare.com）
- Terraform Registry（Cloudflare Provider）
- GitHub リポジトリ（wrangler, cf-terraforming）

### 情報の更新基準

2025年1月時点の情報を基準とする。主な変更点：
- Wrangler v4（2025年3月リリース）
- Terraform Provider v5
- Workers Assets（Workers Sites の後継）
- OpenNext による Next.js 完全サポート
- Workers AI の大幅拡充

## 自動発動トリガー

### 日本語キーワード
- Cloudflare、クラウドフレア
- Workers、ワーカー
- Pages、ページズ
- wrangler、ラングラー
- D1、KV、R2
- Durable Objects
- Terraform、テラフォーム
- Zero Trust、ゼロトラスト
- WAF、DDoS

### 英語キーワード
- Cloudflare Workers/Pages
- wrangler CLI
- D1 database / KV namespace / R2 bucket
- Durable Objects
- Workers AI / Vectorize
- Terraform Cloudflare provider
- Zero Trust / Access / Gateway

## メンテナンス指針

- Cloudflare の新機能リリース時にスキル内容を更新
- バージョン更新時は plugin.json の version も更新
- 公式ドキュメントの URL が変更された場合は参照リンクを修正
