# cc-plugins

Claude Code プラグインのマーケットプレイスリポジトリ。

## インストール

```bash
# git-actions プラグインをインストール
claude plugin install git-actions@cc-plugins

# plugin-generator プラグインをインストール
claude plugin install plugin-generator@cc-plugins
```

## 収録プラグイン

| プラグイン | バージョン | 説明 |
|-----------|-----------|------|
| [cf-terraforming-spec](./plugins/cf-terraforming-spec/) | 0.1.0 | Cloudflare cf-terraforming CLI の仕様と使い方に関する知識を提供。既存の Cloudflare リソースを Terraform にインポートする方法、HCL 設定の生成、インポートブロックの使用などについて回答。 |
| [cloudflare-knowledge](./plugins/cloudflare-knowledge/) | 1.0.0 | Cloudflare のサービス、Wrangler CLI、Workers/Pages 開発、Terraform 管理、セキュリティ機能に関する包括的な知識プラグイン |
| [codex-cli-spec](./plugins/codex-cli-spec/) | 1.2.0 | OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| [cursor-cli-spec](./plugins/cursor-cli-spec/) | 1.1.0 | Cursor IDE および cursor-agent CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| [gemini-cli-spec](./plugins/gemini-cli-spec/) | 1.0.0 | Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| [git-actions](./plugins/git-actions/) | 1.2.5 | Git commit and push workflow management for Claude Code |
| [plugin-generator](./plugins/plugin-generator/) | 1.2.0 | Claude Code プラグインのスキャフォールディングとバリデーション |
| [plugin-updater](./plugins/plugin-updater/) | 1.0.1 | マーケットプレイスとインストール済みプラグインを一括更新 |
| [web-search-gemini](./plugins/web-search-gemini/) | 1.0.5 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |
| [wrangler-cli-spec](./plugins/wrangler-cli-spec/) | 0.1.0 | Cloudflare Wrangler CLI の仕様と使い方に関する知識を提供。Durable Objects, Queues, Hyperdrive, Service Bindings, カスタムビルド設定 (Webpack/esbuild) などについて回答。 |

## ライセンス

MIT
