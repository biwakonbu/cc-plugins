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
| [git-actions](./plugins/git-actions/) | 1.2.5 | Git commit and push workflow management for Claude Code |
| [plugin-generator](./plugins/plugin-generator/) | 1.2.0 | Claude Code プラグインのスキャフォールディングとバリデーション |
| [web-search-gemini](./plugins/web-search-gemini/) | 1.0.2 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |

## ライセンス

MIT
