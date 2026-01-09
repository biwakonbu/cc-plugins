---
description: 全マーケットプレイスとインストール済みプラグインを更新する
allowed-tools: Bash, Read
model: claude-haiku-4-5-20251001
---

# /plugin-updater:update-all

マーケットプレイスとインストール済みプラグインを一括更新します。

## 処理フロー

以下の順序で更新を実行してください。

### Step 1: マーケットプレイス更新

まず、全マーケットプレイスを更新します:

```bash
claude plugin marketplace update
```

更新されたマーケットプレイスの一覧を報告してください。

### Step 2: インストール済みプラグイン取得

各スコープの settings.json から `enabledPlugins` を取得します。

**User スコープ** (`~/.claude/settings.json`):
```bash
cat ~/.claude/settings.json 2>/dev/null | jq -r '.enabledPlugins // {} | keys[]' 2>/dev/null || grep -oE '"[^"]+@[^"]+"' ~/.claude/settings.json 2>/dev/null | tr -d '"' | sort -u || true
```

**Project スコープ** (`.claude/settings.json`):
```bash
cat .claude/settings.json 2>/dev/null | jq -r '.enabledPlugins // {} | keys[]' 2>/dev/null || grep -oE '"[^"]+@[^"]+"' .claude/settings.json 2>/dev/null | tr -d '"' | sort -u || true
```

**Local スコープ** (`.claude/settings.local.json`):
```bash
cat .claude/settings.local.json 2>/dev/null | jq -r '.enabledPlugins // {} | keys[]' 2>/dev/null || grep -oE '"[^"]+@[^"]+"' .claude/settings.local.json 2>/dev/null | tr -d '"' | sort -u || true
```

### Step 3: プラグイン更新

各スコープのプラグインを更新します。

**重要**:
- 同じプラグインが複数スコープに存在する場合も、各スコープで個別に更新してください
- 更新エラーが発生しても続行してください

```bash
# User スコープのプラグイン更新
claude plugin update <plugin-name@marketplace> --scope user

# Project スコープのプラグイン更新
claude plugin update <plugin-name@marketplace> --scope project

# Local スコープのプラグイン更新
claude plugin update <plugin-name@marketplace> --scope local
```

### Step 4: 結果報告

以下の形式でサマリーを報告してください:

```
## マーケットプレイス更新

- <marketplace-name>: 更新完了
- ...

## プラグイン更新

### User スコープ (N件)
- <plugin-name@marketplace>: 更新完了
- ...

### Project スコープ (N件)
なし（または更新したプラグイン一覧）

### Local スコープ (N件)
なし（または更新したプラグイン一覧）

## サマリー

- マーケットプレイス: N件 更新完了
- プラグイン: N件 更新完了
- エラー: N件

再起動後に更新が適用されます。
```

## エラーハンドリング

| エラー | 対応 |
|--------|------|
| settings.json 不在 | 該当スコープをスキップして続行 |
| JSON パースエラー | エラーをログ出力して続行 |
| プラグイン更新失敗 | エラーをログ出力して続行 |
| マーケットプレイス更新失敗 | エラーをログ出力して続行 |

## 使用例

```
/plugin-updater:update-all
```
