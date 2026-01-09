# plugin-updater

マーケットプレイスとインストール済みプラグインを一括更新する Claude Code プラグイン。

## インストール

```bash
claude plugin install plugin-updater@cc-plugins
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `/plugin-updater:update-all` | 全マーケットプレイスとプラグインを更新 |

## 使用例

```bash
# 全更新を実行
/plugin-updater:update-all
```

## 機能

### マーケットプレイス更新

登録されている全マーケットプレイスの最新情報を取得。

### プラグイン更新

以下のスコープのインストール済みプラグインを更新:

- **User**: `~/.claude/settings.json` のプラグイン
- **Project**: `.claude/settings.json` のプラグイン
- **Local**: `.claude/settings.local.json` のプラグイン

### 進捗・結果表示

- 更新対象の一覧
- 各更新の成否
- 最終サマリー

## 出力例

```
## マーケットプレイス更新

- claude-plugins-official: 更新完了
- cc-plugins: 更新完了

## プラグイン更新

### User スコープ (3件)
- git-actions@cc-plugins: 更新完了
- plugin-generator@cc-plugins: 更新完了
- web-search-gemini@cc-plugins: 更新完了

### Project スコープ (0件)
なし

### Local スコープ (0件)
なし

## サマリー

- マーケットプレイス: 2件 更新完了
- プラグイン: 3件 更新完了
- エラー: 0件

再起動後に更新が適用されます。
```

## 注意事項

- 更新後は Claude Code の再起動が必要です
- 個別のプラグイン更新失敗は全体に影響しません

## ライセンス

MIT
