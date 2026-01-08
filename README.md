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
| [git-actions](./plugins/git-actions/) | 1.1.4 | Git ワークフロー管理。commit と push を Claude Code 規則に準拠して実行。 |
| [plugin-generator](./plugins/plugin-generator/) | 1.0.3 | プラグイン生成・検証。新規プラグインのスキャフォールディングと構造バリデーション。 |

## ライセンス

MIT
