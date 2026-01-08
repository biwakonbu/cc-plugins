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
| [git-actions](./plugins/git-actions/) | 1.2.1 | Git commit and push workflow management for Claude Code |
| [image-gen-gemini](./plugins/image-gen-gemini/) | 1.0.0 | Gemini CLI (Nano Banana Pro) を使用した AI 画像生成 |
| [plugin-generator](./plugins/plugin-generator/) | 1.0.3 | Claude Code プラグインのスキャフォールディングとバリデーション |
| [web-search-gemini](./plugins/web-search-gemini/) | 1.0.1 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |

## ライセンス

MIT
