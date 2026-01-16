# cc-plugins プロジェクト

Claude Code プラグインのマーケットプレイスリポジトリ。

## プロジェクト構造

```
cc-plugins/
├── .claude-plugin/
│   └── marketplace.json  # マーケットプレイス設定
├── .claude/
│   └── rules/
│       └── plugin-development.md  # プラグイン開発仕様（plugins/** で自動ロード）
└── plugins/              # プラグイン格納ディレクトリ
```

## 収録プラグイン

| プラグイン | バージョン | 説明 |
|-----------|-----------|------|
| cf-terraforming-spec | 0.1.0 | Cloudflare cf-terraforming CLI の仕様と使い方に関する知識を提供。既存の Cloudflare リソースを Terraform にインポートする方法、HCL 設定の生成、インポートブロックの使用などについて回答。 |
| claude-code-spec | 1.0.0 | Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| cloudflare-knowledge | 1.0.1 | Cloudflare のサービス、Wrangler CLI、Workers/Pages 開発、Terraform 管理、セキュリティ機能に関する包括的な知識プラグイン |
| codex-cli-spec | 1.2.0 | OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| cursor-cli-spec | 1.1.1 | Cursor IDE および cursor-agent CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| gemini-cli-spec | 1.0.0 | Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| git-actions | 1.2.8 | Git commit and push workflow management for Claude Code |
| memory-optimizer | 1.1.2 | Claude Code のメモリ管理（CLAUDE.md、rules、imports）を最適化するための知識とワークフローを提供するプラグイン |
| plugin-generator | 1.2.4 | Claude Code プラグインのスキャフォールディングとバリデーション |
| plugin-updater | 1.0.2 | マーケットプレイスとインストール済みプラグインを一括更新 |
| web-search-gemini | 1.0.5 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |
| wrangler-cli-spec | 0.1.0 | Cloudflare Wrangler CLI の仕様と使い方に関する知識を提供。Durable Objects, Queues, Hyperdrive, Service Bindings, カスタムビルド設定 (Webpack/esbuild) などについて回答。 |

## 開発言語

- ドキュメント・コメント: 日本語
- コード・変数名: 英語

## 開発ルール

### バージョン更新（重要）

**プラグインの内容を変更した場合は必ず `plugin.json` の version を更新すること。**

- Claude Code はプラグインをバージョン単位でキャッシュする
- バージョンを更新しないと、変更がユーザーに反映されない
- セマンティックバージョニングに従う:
  - パッチ（x.x.1）: バグ修正
  - マイナー（x.1.0）: 後方互換の機能追加
  - メジャー（1.0.0）: 破壊的変更

### プラグイン仕様

プラグイン開発の詳細仕様は `.claude/rules/plugin-development.md` を参照。
`plugins/**` パスで作業時に自動ロードされる。
