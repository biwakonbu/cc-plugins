---
name: plugin-validation
description: Claude Code プラグインの構造とメタデータを検証する。plugin.json の必須フィールド、各コンポーネントのフロントマター、パス整合性、JSON 構文をチェック。Use when validating plugin structure, checking plugin correctness, linting plugin files, or verifying plugin format.
allowed-tools: Bash, Read, Glob, Grep
---

# Plugin Validation スキル

プラグインの構造検証を提供する。

## Instructions

### 概要

このスキルは Claude Code プラグインの構造を検証し、エラーと警告を報告します。
`validate-plugin.sh` スクリプトを使用するか、手動で検証を実行できます。

### 検証スクリプト実行

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/validate-plugin.sh" [path]
```

パスを省略するとカレントディレクトリを検証します。

### 検証項目

#### エラー（必須）

| 対象 | ルール |
|------|--------|
| `.claude-plugin/plugin.json` | 存在必須 |
| plugin.json `name` | フィールド必須 |
| 参照パス | commands, skills, agents, hooks の参照先が存在 |
| hooks 重複 | `hooks: "./hooks/hooks.json"` は自動ロードされるため指定不可 |
| `commands/*.md` | フロントマターに `description` 必須 |
| `skills/*/SKILL.md` | フロントマターに `name`, `description` 必須 |
| `agents/*.md` | フロントマターに `name`, `description` 必須 |
| `hooks/hooks.json` | 有効な JSON 構文 |

#### 警告（推奨）

| 対象 | ルール |
|------|--------|
| plugin.json `version` | セマンティックバージョン推奨 |
| plugin.json `description` | 説明推奨 |
| `CLAUDE.md` | プラグインルートに存在推奨 |

### 手動検証フロー

1. **plugin.json 確認**
   ```bash
   # 存在確認
   ls .claude-plugin/plugin.json

   # JSON 構文と必須フィールド確認
   jq '.name' .claude-plugin/plugin.json
   ```

2. **コマンド検証**
   ```bash
   # フロントマター確認
   head -5 commands/*.md
   ```

3. **スキル検証**
   ```bash
   # フロントマター確認
   head -10 skills/*/SKILL.md
   ```

4. **エージェント検証**
   ```bash
   # フロントマター確認
   head -10 agents/*.md
   ```

5. **フック検証**
   ```bash
   # JSON 構文確認
   jq empty hooks/hooks.json
   ```

### 出力形式

```
═══════════════════════════════════════════════════════════
Plugin Validator
═══════════════════════════════════════════════════════════

Target: ./plugins/my-plugin

--- plugin.json ---
✅ .claude-plugin/plugin.json exists
✅ name: my-plugin
⚠️  WARNING: 'version' フィールドを推奨します

--- commands ---
✅ commands/hello.md: frontmatter OK

═══════════════════════════════════════════════════════════
Validation Result
═══════════════════════════════════════════════════════════

  Errors:   0
  Warnings: 1

⚠️  PASSED with warnings
```

## Examples

### プラグイン検証

```
Q: このプラグインが正しいか確認して
A: validate-plugin.sh を実行して検証結果を報告します。
```

### 特定コンポーネント検証

```
Q: commands のフォーマットが正しいか見て
A: commands/*.md のフロントマターを確認し、description フィールドの有無をチェックします。
```
