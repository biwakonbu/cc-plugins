---
name: plugin-spec
description: Claude Code プラグインの全仕様知識を統合。plugin.json、commands、skills、agents、hooks の概要と個別スキルへの参照を提供。Use when understanding plugin structure, creating plugins, or validating plugin components.
allowed-tools: Read, Grep, Glob
---

# Plugin Spec スキル（統合版）

Claude Code プラグインの全仕様知識を統合して提供する。
詳細な仕様は個別スキルを参照。

## Instructions

このスキルはプラグインの各コンポーネント（commands, skills, agents, hooks）の
概要を提供し、詳細は個別スキルに委譲します。

**重要**: 実装前に必ず公式ドキュメント（英語版）を確認し、最新の仕様に従ってください。

## 公式ドキュメント

- [Plugins](https://code.claude.com/docs/en/plugins)
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference)

---

## 個別仕様スキル

| スキル | 説明 | 詳細コマンド |
|--------|------|------------|
| `command-spec` | command の仕様知識 | `/plugin-generator:create-command` |
| `skill-spec` | skill の仕様知識 | `/plugin-generator:create-skill` |
| `agent-spec` | agent の仕様知識 | `/plugin-generator:create-agent` |

各コンポーネントの詳細な仕様は上記スキルを参照してください。

---

## plugin.json 仕様

プラグインのメタデータを定義するファイル。

### 必須フィールド

| フィールド | 説明 |
|-----------|------|
| `name` | プラグイン識別子（kebab-case） |

### 推奨フィールド

| フィールド | 説明 |
|-----------|------|
| `version` | セマンティックバージョン（例: "1.0.0"） |
| `description` | プラグインの説明 |
| `author` | 作者情報（`{name, email?, url?}`） |
| `license` | ライセンス（例: "MIT"） |
| `keywords` | 検索用キーワード配列 |

### パスフィールド

| フィールド | 説明 |
|-----------|------|
| `commands` | コマンドディレクトリ（例: "./commands/"） |
| `skills` | スキルディレクトリ（例: "./skills/"） |
| `agents` | エージェントディレクトリ（例: "./agents/"） |
| `hooks` | フック設定ファイル（例: "./hooks/hooks.json"） |

### 例

```json
{
  "name": "my-plugin",
  "description": "プラグインの説明",
  "version": "1.0.0",
  "author": { "name": "Author Name" },
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],
  "commands": "./commands/",
  "skills": "./skills/",
  "agents": "./agents/"
}
```

---

## コンポーネント概要

### Commands

スラッシュコマンドを定義する Markdown ファイル。

- **配置**: `commands/{command-name}.md`
- **必須**: フロントマターに `description`
- **オプション**: `model`（フルモデル ID）、`allowed-tools`
- **詳細**: `command-spec` スキルを参照

### Skills

Claude が自動適用する知識・手順を定義する Markdown ファイル。

- **配置**: `skills/{skill-name}/SKILL.md`
- **必須**: フロントマターに `name`, `description`
- **オプション**: `allowed-tools`, `context`, `agent`, `user-invocable`, `hooks`
- **注意**: `model` 指定は使用不可
- **v2.1.0+**: `context: fork` でサブエージェントとして実行可能
- **詳細**: `skill-spec` スキルを参照

### Agents

サブエージェントを定義する Markdown ファイル。

- **配置**: `agents/{agent-name}.md`
- **必須**: フロントマターに `name`, `description`
- **オプション**: `tools`, `model`（短縮名）, `skills`
- **詳細**: `agent-spec` スキルを参照

### Hooks

イベント発生時に自動実行されるシェルコマンドを定義。

- **配置**: `hooks/hooks.json`
- **イベント**: PreToolUse, PostToolUse, SessionStart, SessionEnd など
- **タイプ**: command, prompt

---

## model 指定の違い

| コンポーネント | model 指定 | 形式 |
|--------------|-----------|------|
| commands | 可能 | フルモデル ID（`claude-haiku-4-5-20251001`） |
| skills | **不可** | - |
| agents | 可能 | 短縮名（`haiku`, `opus`, `inherit`） |

**注意**: Sonnet は現在の Claude Code では推奨されません。

---

## バリデーションルール

### エラー（必須）

| 対象 | ルール |
|------|--------|
| plugin.json | 存在必須 |
| plugin.json | `name` フィールド必須 |
| パス | 参照先ディレクトリ/ファイル存在 |
| commands/*.md | フロントマターに `description` 必須 |
| skills/*/SKILL.md | フロントマターに `name`, `description` 必須 |
| agents/*.md | フロントマターに `name`, `description` 必須 |
| hooks.json | 有効な JSON 構文 |

### 警告（推奨）

| 対象 | ルール |
|------|--------|
| plugin.json | `version` 推奨 |
| plugin.json | `description` 推奨 |
| プラグインルート | `CLAUDE.md` 推奨 |

---

## Examples

### コンポーネント作成

```
Q: 新しいコマンドを作りたい
A: `/plugin-generator:create-command {name}` を実行するか、
   `command-spec` スキルを参照してください。

Q: 新しいスキルを作りたい
A: `/plugin-generator:create-skill {name}` を実行するか、
   `skill-spec` スキルを参照してください。

Q: 新しいエージェントを作りたい
A: `/plugin-generator:create-agent {name}` を実行するか、
   `agent-spec` スキルを参照してください。
```

### プラグイン構造の相談

```
Q: プラグインの構造を教えて
A: 基本構造は以下の通りです:
   - .claude-plugin/plugin.json（必須）
   - commands/（スラッシュコマンド）
   - skills/（自動適用スキル）
   - agents/（サブエージェント）
   - hooks/（イベントフック）
```
