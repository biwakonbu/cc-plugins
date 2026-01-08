---
name: plugin-spec
description: Claude Code プラグインの仕様知識。commands, skills, agents, hooks の正しい形式と実装パターンを提供。プラグインコンポーネントの作成・検証時に使用。Use when creating or validating plugin components, understanding plugin structure, or implementing commands/skills/agents/hooks.
allowed-tools: Read, Grep, Glob
---

# Plugin Spec スキル

Claude Code プラグインの仕様知識を提供する。

## Instructions

このスキルはプラグインの各コンポーネント（commands, skills, agents, hooks）の
正しい形式と実装パターンについての知識を提供します。

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
  "skills": "./skills/"
}
```

---

## Commands 仕様

スラッシュコマンドを定義する Markdown ファイル。

### ファイル配置

```
commands/{command-name}.md
```

### フロントマター（必須）

```yaml
---
description: コマンドの説明（必須）
---
```

### 変数

| 変数 | 説明 |
|------|------|
| `$ARGUMENTS` | 引数全体 |
| `$1`, `$2`, ... | 個別引数（位置パラメータ） |

### 例

```markdown
---
description: ファイルを検索する
---

# Search

指定されたパターンでファイルを検索します。

引数: $ARGUMENTS

1. パターンを解析
2. Glob で検索を実行
3. 結果を報告
```

### コマンド呼び出し

```
/plugin-name:command-name [arguments]
```

---

## Skills 仕様

Claude が自動的に適用する知識・手順を定義する Markdown ファイル。

### ファイル配置

```
skills/{skill-name}/SKILL.md
```

### フロントマター（必須）

```yaml
---
name: skill-name           # 必須: kebab-case（最大64文字）
description: 説明           # 必須: いつ使うか明記（最大1024文字）
allowed-tools: Read, Grep  # オプション: 使用可能ツール制限
model: claude-sonnet-4-... # オプション: 使用モデル
---
```

### description のベストプラクティス

**良い例**:
```yaml
description: Extract text from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs.
```

- 具体的なアクション名を含める
- ユーザーが使う用語を含める
- いつ使うかを明記

**悪い例**:
```yaml
description: Helps with documents
```

### 構造

```markdown
---
name: my-skill
description: 説明。Use when ...
allowed-tools: Read, Grep, Glob
---

# スキル名

## Instructions

ステップバイステップの指示

## Examples

具体的な使用例
```

### 呼び出しフロー

1. Discovery: 起動時に name と description のみロード
2. Activation: ユーザー要求が description にマッチ → 確認
3. Execution: 承認後、完全な SKILL.md をロードして実行

---

## Agents 仕様

サブエージェントを定義する Markdown ファイル。

### ファイル配置

```
agents/{agent-name}.md
agents/{category}/{agent-name}.md  # サブディレクトリ可
```

### フロントマター（必須）

```yaml
---
name: agent-name
description: いつ呼ばれるかの説明
tools: Read, Glob, Grep, Bash  # 省略時は全ツール継承
model: sonnet | opus | haiku | inherit
permissionMode: default
skills: skill1, skill2         # スキルは明示的に指定
---
```

### tools フィールド

- 省略: 親の全ツール + MCP ツールを継承
- 指定: 制限（例: `Read, Glob, Grep`）

### model フィールド

| 値 | 説明 |
|----|------|
| `sonnet` | 推論重視 |
| `haiku` | 高速（Explore 向け） |
| `opus` | 最高性能 |
| `inherit` | 親から継承 |

### 例

```markdown
---
name: code-reviewer
description: コードレビューを担当。コード品質、セキュリティ、パフォーマンスを評価。
tools: Read, Glob, Grep
model: sonnet
skills: security-check
---

# Code Reviewer エージェント

あなたはコードレビューを担当するサブエージェントです。

## 役割

1. コードを読み込む
2. 品質・セキュリティ・パフォーマンスを評価
3. 改善点を報告

## 出力フォーマット

レビュー結果を構造化して報告してください。
```

---

## Hooks 仕様

イベント発生時に自動実行されるシェルコマンドを定義。

### ファイル配置

```
hooks/hooks.json
```

### 基本構造

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-command.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### イベント一覧

| イベント | トリガー | マッチャー |
|---------|---------|-----------|
| `PreToolUse` | ツール実行前 | ○ |
| `PostToolUse` | ツール実行成功後 | ○ |
| `PostToolUseFailure` | ツール実行失敗後 | ○ |
| `UserPromptSubmit` | プロンプト送信時 | × |
| `SessionStart` | セッション開始時 | × |
| `SessionEnd` | セッション終了時 | × |
| `Stop` | Claude 停止時 | × |

### マッチャーパターン

| パターン | 説明 |
|---------|------|
| `"Write"` | 完全一致 |
| `"Edit\|Write"` | パイプ（OR） |
| `"*"` | ワイルドカード |

### フックタイプ

```json
// command: シェルコマンド実行
{ "type": "command", "command": "script.sh" }

// prompt: LLM 評価
{ "type": "prompt", "prompt": "チェック内容" }
```

### 環境変数

| 変数 | 説明 |
|------|------|
| `$CLAUDE_PROJECT_DIR` | プロジェクトルート |
| `$CLAUDE_WORKING_DIR` | 作業ディレクトリ |
| `$CLAUDE_FILE_PATHS` | 操作対象ファイル |
| `$CLAUDE_TOOL_NAME` | 実行ツール名 |
| `$CLAUDE_COMMAND` | 実行コマンド（Bash 時） |
| `${CLAUDE_PLUGIN_ROOT}` | プラグインディレクトリ |

### 終了コード

| コード | 意味 |
|--------|------|
| 0 | 成功 |
| 2 | ブロッキングエラー（アクション防止） |
| 他 | 非ブロッキング（処理継続） |

### 例

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          }
        ]
      }
    ]
  }
}
```

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

## Examples

### コマンド作成の相談

```
Q: 新しいコマンドを作りたい
A: commands/{name}.md を作成し、フロントマターに description を必ず含めてください。
   $ARGUMENTS で引数を受け取れます。
```

### スキル作成の相談

```
Q: スキルの description はどう書けばいい？
A: 具体的なアクション名と「Use when ...」でいつ使うかを明記してください。
   例: "Extract data from CSV files. Use when user mentions CSV or spreadsheet data."
```
