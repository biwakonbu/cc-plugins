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
| agent-browser-spec | 1.0.0 | agent-browser CLI の仕様と使い方に関する知識を提供。ヘッドレスブラウザ自動化、スナップショット、セレクター、セッション管理、ネットワーク制御について回答。 |
| cf-terraforming-spec | 0.2.0 | Cloudflare cf-terraforming CLI の仕様と使い方に関する知識を提供。既存の Cloudflare リソースを Terraform にインポートする方法、HCL 設定の生成、インポートブロックの使用などについて回答。 |
| claude-code-spec | 1.2.0 | Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| cloudflare-knowledge | 1.1.0 | Cloudflare のサービス、Wrangler CLI、Workers/Pages 開発、Terraform 管理、セキュリティ機能に関する包括的な知識プラグイン |
| codex-cli-spec | 1.4.0 | OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| cursor-cli-spec | 1.2.0 | Cursor IDE および cursor-agent CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| gemini-cli-spec | 1.1.0 | Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| git-actions | 1.3.1 | Git commit and push workflow management for Claude Code |
| gogcli-spec | 2.0.0 | Google Suite CLI (gogcli/gog) の仕様と使い方を完璧に理解するための知識プラグイン。Gmail、Calendar、Drive、Contacts、Tasks、Sheets、Docs、Chat、Classroom 等の操作について回答。 |
| memory-optimizer | 1.2.1 | Claude Code のメモリ管理（CLAUDE.md、rules、imports）を最適化するための知識とワークフローを提供するプラグイン |
| nano-banana-image | 1.0.0 | Gemini Nano Banana Pro (gemini-3-pro-image-preview) を活用した画像生成プラグイン。テキストから画像生成、解像度・アスペクト比指定、参照画像を使った編集に対応。 |
| plugin-generator | 1.4.0 | Claude Code プラグインのスキャフォールディングとバリデーション |
| plugin-updater | 1.0.3 | マーケットプレイスとインストール済みプラグインを一括更新 |
| web-search-codex | 1.1.0 | Codex CLI 内で Gemini CLI を活用した Web 検索を実行。--full-auto モードで自動検索対応。 |
| web-search-gemini | 1.3.0 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |
| web-search-unified | 1.1.0 | Gemini、Codex、WebSearch を並列実行し結果を統合する高精度 Web 検索 |
| wrangler-cli-spec | 0.2.0 | Cloudflare Wrangler CLI の仕様と使い方に関する知識を提供。Durable Objects, Queues, Hyperdrive, Service Bindings, カスタムビルド設定 (Webpack/esbuild) などについて回答。 |

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

## context フィールド最適化（v2.1.0+ 対応完了）

Claude Code v2.1.0+ で導入された `context: fork` フィールドを全プラグインのスキルに適用し、トークン消費最適化とメインコンテキスト保護を完了。

### 適用内容

**知識提供スキル 19 個**: `context: fork` で独立サブエージェント化
- メインコンテキスト汚染防止（特に claude-code-knowledge 1049 行対応）
- トークン消費最適化
- 複雑なスキル干渉防止

**参照スキル 6 個**: `context: fork` + `user-invocable: false` で非表示参照スキル化
- スラッシュメニューから非表示（UI 簡潔化）
- 他スキルから自動参照可能（機能損失なし）
- git-conventions, migration-guide, plugin-spec, command-spec, skill-spec, agent-spec

### バージョン更新内容

10 プラグインのバージョンを semantic versioning で更新（コミット: c3d8a55）:
- cf-terraforming-spec: 0.1.0 → 0.2.0
- claude-code-spec: 1.0.0 → 1.1.0
- cloudflare-knowledge: 1.0.1 → 1.1.0
- codex-cli-spec: 1.2.0 → 1.3.0
- cursor-cli-spec: 1.1.1 → 1.2.0
- gemini-cli-spec: 1.0.0 → 1.1.0
- git-actions: 1.2.8 → 1.3.0
- memory-optimizer: 1.1.2 → 1.2.0
- plugin-generator: 1.2.4 → 1.3.0
- wrangler-cli-spec: 0.1.0 → 0.2.0

各プラグインの CLAUDE.md には v**.*.* セクションで context フィールド対応を記載。
