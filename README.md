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
| [codex-cli-spec](./plugins/codex-cli-spec/) | 1.1.0 | OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| [cursor-cli-spec](./plugins/cursor-cli-spec/) | 1.0.0 | Cursor IDE および cursor-agent CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| [gemini-cli-spec](./plugins/gemini-cli-spec/) | 1.0.0 | Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| [git-actions](./plugins/git-actions/) | 1.2.5 | Git commit and push workflow management for Claude Code |
| [plugin-generator](./plugins/plugin-generator/) | 1.2.0 | Claude Code プラグインのスキャフォールディングとバリデーション |
| [plugin-updater](./plugins/plugin-updater/) | 1.0.0 | マーケットプレイスとインストール済みプラグインを一括更新 |
| [web-search-gemini](./plugins/web-search-gemini/) | 1.0.5 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |

## ライセンス

MIT
