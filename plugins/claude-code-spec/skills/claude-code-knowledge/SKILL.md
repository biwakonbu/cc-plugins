---
name: claude-code-knowledge
description: Claude Code CLI の仕様と使い方に関する知識を提供。プラグイン開発、スキル、スラッシュコマンド、サブエージェント、フック、LSP、MCP、権限設定、セッション管理について回答。Use when user asks about Claude Code, plugins, skills, slash commands, subagents, hooks, LSP, MCP, permissions, sessions, or plan mode. Also use when user says Claude Code について, プラグイン開発, スキル定義, フック設定, 権限設定.
---

# Claude Code Knowledge

Claude Code CLI（v2.1.3 対応）の仕様と使い方に関する知識を提供します。

公式ドキュメント: https://code.claude.com/docs/en/

---

## 概要

- **正式名称**: Claude Code
- **開発元**: Anthropic
- **インストール**: `npm install -g @anthropic/claude-code`
- **起動**: `claude`
- **ライセンス**: 有料プラン必須

---

## プラグイン構造

公式ドキュメント: https://code.claude.com/docs/en/plugins

```
{plugin-name}/
├── .claude-plugin/           # メタデータ（必須）
│   └── plugin.json          # マニフェスト（必須）
├── commands/                 # スラッシュコマンド
│   └── {command}.md
├── agents/                   # サブエージェント
│   └── {agent}.md
├── skills/                   # スキル
│   └── {skill-name}/
│       └── SKILL.md
├── hooks/                    # イベントフック
│   └── hooks.json
├── .mcp.json                 # MCP サーバー設定
└── .lsp.json                 # LSP サーバー設定
```

**重要**: `.claude-plugin/` には `plugin.json` のみ配置。他コンポーネントはルートレベル。

### plugin.json スキーマ

```json
{
  "name": "plugin-name",           // 必須: 識別子（kebab-case）
  "version": "1.0.0",              // セマンティックバージョン
  "description": "説明",
  "author": {
    "name": "Author Name",         // author 指定時は name 必須
    "email": "email@example.com",
    "url": "https://..."
  },
  "homepage": "https://...",
  "repository": "https://...",
  "license": "MIT",
  "keywords": ["tag1", "tag2"],
  "commands": "./commands/",       // カスタムパス指定可
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json",
  "lspServers": "./.lsp.json"
}
```

---

## スラッシュコマンド定義

公式ドキュメント: https://code.claude.com/docs/en/slash-commands

### スキルとの統合（v2.1.3+）

v2.1.3 以降、スラッシュコマンドとスキルが統合:

- `SlashCommand` ツールは `Skill` ツールに統合
- `/skills/` ディレクトリ内のスキルがスラッシュコマンドメニューに自動表示
- `user-invocable: false` でメニューから非表示に設定可能
- スキルは自動トリガーと明示的呼び出しの両方に対応

### 保存場所

| 場所 | パス | スコープ |
|------|------|----------|
| プロジェクト | `.claude/commands/` | 現在のプロジェクトのみ |
| ユーザー | `~/.claude/commands/` | 全プロジェクト共通 |
| プラグイン | `plugins/{name}/commands/` | プラグインインストール時 |

### ファイル形式

ファイル名がコマンド名になる（例: `commit.md` → `/commit`）

```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
argument-hint: [message]
description: Git コミットを作成する
model: claude-haiku-4-5-20251001
disable-model-invocation: false
context: fork
---

# コマンド本体

$ARGUMENTS
```

### フロントマターオプション

| フィールド | 型 | 説明 | 例 |
|-----------|-----|------|-----|
| `allowed-tools` | String/List | 使用可能ツールを制限 | `Bash(git add:*), Read, Write` |
| `argument-hint` | String | 引数のヒント | `[message]` or `[pr-number] [priority]` |
| `description` | String | コマンドの説明 | `Git コミットを作成` |
| `model` | String | 使用モデル指定 | `claude-haiku-4-5-20251001` |
| `disable-model-invocation` | Boolean | `true` で無効化 | `true` / `false` |
| `context` | String | 実行コンテキスト（v2.1.0+） | `fork`（サブエージェントで実行） |
| `agent` | String | 実行エージェント指定（v2.1.0+） | `custom-agent` |
| `hooks` | Object | コマンド固有フック（v2.1.0+） | 下記参照 |

**YAML形式のallowed-tools（v2.1.0+）**:
```yaml
allowed-tools:
  - Bash(git add:*)
  - Bash(git commit:*)
  - Read
```

### 引数の取得

```markdown
# 全引数
$ARGUMENTS

# 位置引数
PR #$1 をレビュー（優先度: $2、担当: $3）
```

使用例: `/review 123 high alice` → `PR #123 をレビュー（優先度: high、担当: alice）`

### 動的コンテキスト埋め込み

```markdown
## コンテキスト
- 現在の git status: !`git status`
- 現在の diff: !`git diff HEAD`

## ファイル参照
@/path/to/file.ts
```

---

## サブエージェント定義

公式ドキュメント: https://code.claude.com/docs/en/sub-agents

```markdown
---
name: agent-name
description: いつ呼ばれるかの説明
tools: Read, Glob, Grep, Bash     # 省略時は全ツール継承
model: haiku                       # haiku | opus | inherit
permissionMode: default            # default | permissive | strict（v2.0.43+）
skills: skill1, skill2
disallowedTools:                   # 禁止ツールリスト（v2.0.30+）
  - write_file
  - dangerous_command
hooks:                             # エージェント固有フック（v2.1.0+）
  PreToolUse:
    - command: "validate.sh"
  Stop:
    - type: prompt
      prompt: "レビューを実行"
---

# システムプロンプト

エージェントへの指示をここに記述。
```

### tools フィールド

- 省略: 親の全ツール + MCP ツールを継承
- 指定: 制限（例: `Read, Glob, Grep`）

### model フィールド

| モデル | 説明 |
|--------|------|
| `haiku` | 高速・定型タスク向け（推奨） |
| `opus` | 最高性能・複雑なタスク向け |
| `inherit` | 親から継承 |

**注意**: `sonnet` は現在の Claude Code では推奨されません。

### permissionMode フィールド（v2.0.43+）

| モード | 説明 |
|--------|------|
| `default` | 親の権限設定を継承 |
| `permissive` | より緩やかな権限 |
| `strict` | より厳格な権限 |

### disallowedTools フィールド（v2.0.30+）

```yaml
disallowedTools:
  - write_file
  - run_shell_command
  - Task(DangerousAgent)
```

### hooks フィールド（v2.1.0+）

```yaml
hooks:
  PreToolUse:
    - command: "echo $CLAUDE_HOOK_TOOL_NAME"
  PostToolUse:
    - command: "validate-output.sh"
  Stop:
    - type: prompt
      prompt: "タスク完了レビュー"
```

### エージェントの無効化（v2.1.0+）

```json
{
  "permissions": {
    "deny": ["Task(DangerousAgent)"]
  }
}
```

---

## スキル定義

公式ドキュメント: https://code.claude.com/docs/en/skills

### スキルとは

- Claude が特定タスクを実行する方法を教える Markdown ファイル
- ユーザーの要求が description に一致すると Claude が**自動的に**適用
- PR レビュー、コミット生成、データベースクエリなどの標準化に最適

### ホットリロード（v2.1.0+）

`~/.claude/skills/` または `.claude/skills/` 内のスキルファイルは、変更時に自動的にリロード。セッション再起動は不要。

### スキル vs 他機能

| 機能 | 発動 | 用途 |
|------|------|------|
| Skills | Claude が自動判断 + `/skill-name` | 専門知識提供、標準化 |
| Slash commands | `/command` 明示呼び出し | 再利用可能なプロンプト |
| CLAUDE.md | 全会話でロード | プロジェクト全体指示 |
| Subagents | 自動委譲または明示呼び出し | 独立コンテキストでのタスク |

### 保存場所と優先度

| 場所 | パス | 優先度 |
|------|------|--------|
| Enterprise | 管理者設定 | 最高 |
| Personal | `~/.claude/skills/` | 高 |
| Project | `.claude/skills/` | 中 |
| Plugin | プラグイン内 `skills/` | 最低 |

### SKILL.md フォーマット

```yaml
---
name: skill-name                    # 必須: 小文字、数字、ハイフンのみ（最大64文字）
description: スキルの説明            # 必須: いつ使うか明記（最大1024文字）
allowed-tools: Read, Grep, Glob     # オプション: 使用可能ツール制限
context: fork                       # オプション: サブエージェントとして実行（v2.1.0+）
agent: custom-agent                 # オプション: 実行エージェント指定（v2.1.0+）
user-invocable: true                # オプション: スラッシュメニュー表示制御（v2.1.3+）
hooks:                              # オプション: スキル固有フック（v2.1.0+）
  PreToolUse:
    - command: "validate.sh"
---

# スキル名

## Instructions
明確なステップバイステップの指示

## Examples
具体的な使用例
```

**重要**: フロントマターは必ず1行目から `---` で開始（空行不可）

### フォークコンテキスト（v2.1.0+）

`context: fork` を指定すると、スキルが独立したサブエージェントとして実行:

- メインの会話コンテキストを汚染しない
- トークン消費を抑制
- 複雑なスキルの干渉を防止

```yaml
---
name: web-research
description: Web検索を実行
context: fork
agent: researcher
---
```

### user-invocable オプション（v2.1.3+）

- `user-invocable: true`（デフォルト）: スラッシュコマンドメニューに表示
- `user-invocable: false`: メニューから非表示（自動トリガーのみ）

### description のベストプラクティス

**良い例**:
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents.
Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**悪い例**:
```yaml
description: Helps with documents
```

- 具体的なアクション名を含める（extract, fill, merge）
- ユーザーが使う用語を含める
- いつ使うかを明記

### スキルの呼び出しフロー

1. **Discovery**: 起動時に name と description のみロード
2. **Activation**: ユーザー要求が description にマッチ → 確認プロンプト
3. **Execution**: 承認後、完全な SKILL.md をロードして実行

### サブエージェントでのスキル使用

サブエージェントはスキルを**自動継承しない**。明示的に指定が必要:

```yaml
# agents/code-reviewer.md
---
name: code-reviewer
description: コードレビュー専門
skills: pr-review, security-check   # 明示的に指定
---
```

**注意**: ビルトインエージェント（Explore, Plan, Verify）と Task ツールはスキルにアクセス不可

---

## フック定義

公式ドキュメント: https://code.claude.com/docs/en/hooks

### フックとは

Claude Code のライフサイクル全体で自動実行されるユーザー定義シェルコマンド。LLM に依存せず確定的な制御を提供。

### 設定ファイル

```
~/.claude/settings.json          # ユーザー全体（優先度：低）
.claude/settings.json            # プロジェクト（優先度：中）
.claude/settings.local.json      # ローカル専用（優先度：高、.gitignore対象）
```

**重要**: 設定変更は新しいセッションで反映される（セキュリティ保護のため）

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
            "command": "your-command-here",
            "timeout": 600,
            "once": true
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
| PreToolUse | ツール実行前 | ○ |
| PostToolUse | ツール実行成功後 | ○ |
| PostToolUseFailure | ツール実行失敗後 | ○ |
| PermissionRequest | ツール許可リクエスト時（v2.0.45+） | ○ |
| UserPromptSubmit | プロンプト送信時 | × |
| SessionStart | セッション開始時 | × |
| SessionEnd | セッション終了時 | × |
| Stop | Claude 停止時 | × |
| SubagentStart | サブエージェント開始時（v2.0.43+） | × |
| SubagentStop | サブエージェント完了時（v1.0.41+） | × |
| Notification | 通知送信時 | × |

### フックタイプ

```json
// Command: シェルコマンド実行
{ "type": "command", "command": "bash-command" }

// Prompt: LLM 評価
{ "type": "prompt", "prompt": "LLM に送信するプロンプト" }

// Agent: サブエージェント実行
{ "type": "agent", ... }
```

### フロントマターでのフック定義（v2.1.0+）

エージェントやスキルのフロントマターでフックを定義可能:

```yaml
---
name: my-agent
hooks:
  PreToolUse:
    - command: "echo $CLAUDE_HOOK_TOOL_NAME"
  PostToolUse:
    - command: "validate-output.sh"
  Stop:
    - type: prompt
      prompt: "タスク完了レビュー"
---
```

### once オプション（v2.1.0+）

`once: true` を指定すると、セッション中に1回のみ実行:

```json
{
  "type": "command",
  "command": "setup.sh",
  "once": true
}
```

### マッチャーパターン

| パターン | 説明 | 例 |
|---------|------|-----|
| 完全一致 | 単一ツール | `"Write"` |
| パイプ（OR） | 複数ツール | `"Edit\|MultiEdit\|Write"` |
| ワイルドカード | 全ツール | `"*"` |
| 空文字列 | 全ツール | `""` |

**注意**: 大文字小文字を区別する

**ツール名**: Write, Edit, MultiEdit, Read, Bash, Grep, Glob, WebFetch, WebSearch, Task

### 環境変数

| 変数 | 説明 | 利用可能フック |
|------|------|---------------|
| `$CLAUDE_PROJECT_DIR` | プロジェクトルート | すべて |
| `$CLAUDE_WORKING_DIR` | 作業ディレクトリ | すべて |
| `$CLAUDE_FILE_PATHS` | 操作対象ファイル（スペース区切り） | ツール関連 |
| `$CLAUDE_TOOL_NAME` | 実行ツール名 | ツール関連 |
| `$CLAUDE_COMMAND` | 実行コマンド | PreToolUse（Bash） |
| `$CLAUDE_SESSION_ID` | セッション ID | すべて |
| `$CLAUDE_ENV_FILE` | 環境変数永続化ファイル | SessionStart |
| `${CLAUDE_PLUGIN_ROOT}` | プラグインディレクトリ | プラグインフック |
| `$CLAUDE_HOOK_EVENT` | イベント名 | すべて |
| `$CLAUDE_HOOK_TOOL_NAME` | ツール名 | ツール関連 |
| `$CLAUDE_HOOK_TOOL_ARGS` | ツール引数（JSON） | ツール関連 |
| `$CLAUDE_HOOK_PERMISSION_TYPE` | 権限タイプ | PermissionRequest |

### stdin JSON データ

```json
{
  "session_id": "string",
  "transcript_path": "path/to/transcript.json",
  "cwd": "current/working/directory",
  "hook_event_name": "PreToolUse|PostToolUse|...",
  "tool_name": "Write",
  "tool_input": {...},
  "tool_response": {...},
  "tool_use_id": "string"
}
```

### 終了コード

| コード | 意味 | 動作 |
|--------|------|------|
| 0 | 成功 | stdout を JSON 解析 or コンテキスト追加 |
| 2 | ブロッキングエラー | アクション防止、stderr をエラー表示 |
| その他 | 非ブロッキング | 処理継続、stderr をログ表示 |

### JSON 出力制御

```json
{
  "continue": true,
  "stopReason": "停止理由",
  "suppressOutput": false,
  "systemMessage": "ユーザーへの警告",
  "permissionDecision": "allow|deny|ask",
  "permissionDecisionReason": "理由",
  "updatedInput": { "field": "modified_value" },
  "decision": "block"
}
```

### 実装例

#### 危険なコマンドをブロック

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_COMMAND\" == *\"rm -rf\"* ]]; then echo 'Blocked' && exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

#### 自動フォーマット

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$CLAUDE_FILE_PATHS\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

### ベストプラクティス

- PostToolUse フォーマッターから開始（フィードバックが可視化しやすい）
- 不要な実行は早期終了（`exit 0`）
- タイムアウトを適切に設定（**デフォルト10分、v2.1.2+**）
- 機密設定は `.local.json` に分離
- 入力をサニタイズしてセキュリティ確保
- `once: true` を活用して初回のみ実行

---

## LSPサーバー定義

公式ドキュメント: https://code.claude.com/docs/en/lsp

### LSPとは

Language Server Protocol によるコード解析機能（v2.0.74+）。定義へのジャンプ、参照検索、ホバードキュメント、診断機能を提供。

### 有効化

```bash
export ENABLE_LSP_TOOL=1
```

永続化: `~/.zshrc` または `~/.bashrc` に追加。

### 設定ファイル

`.lsp.json`:
```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "file_extensions": ["ts", "tsx", "js", "jsx"]
  },
  "python": {
    "command": "pyright-langserver",
    "args": ["--stdio"],
    "file_extensions": ["py"]
  },
  "rust": {
    "command": "rust-analyzer",
    "args": [],
    "file_extensions": ["rs"]
  }
}
```

### 主な機能

| 機能 | 説明 |
|------|------|
| Go-to-definition | 定義へのジャンプ |
| Find references | 参照検索 |
| Hover | 型情報・ドキュメント表示 |
| Diagnostics | 構文エラー・警告の検出 |

### 言語サーバーのインストール

```bash
# TypeScript
npm install -g typescript-language-server

# Python
pip install pyright

# Rust
rustup component add rust-analyzer
```

---

## 言語設定（v2.1.0+）

### 応答言語の設定

Claude の応答言語を設定できます。

**settings.json**:
```json
{
  "language": "japanese"
}
```

**設定可能な値**: `japanese`, `english`, `chinese`, `korean` など

### /config からの設定

インタラクティブに `/config` コマンドから言語を選択可能。

### リリースチャンネル（v2.1.3+）

`/config` から `stable` または `latest` を選択:
- `stable`: 安定版（推奨）
- `latest`: 最新機能を含む

---

## Rules フォルダ（v2.0.64+）

### パスベースのルール定義

`.claude/rules/` ディレクトリに Markdown ファイルを配置して、パス単位でルールを適用できます。

### ディレクトリ構造

```
.claude/
├── settings.json
├── CLAUDE.md
└── rules/
    ├── api-rules.md
    ├── frontend-rules.md
    └── test-rules.md
```

### スコープ設定

フロントマターでパスを指定:

```yaml
---
paths:
  - "src/api/**/*"
  - "tests/api/**/*"
---

# API 開発ルール

- REST API の命名規則に従う
- エラーハンドリングを必ず実装
- テストカバレッジ 80% 以上
```

### 設定の優先順位

1. プロジェクトローカル（`.claude/settings.local.json`）
2. プロジェクト共有（`.claude/settings.json`）
3. プロジェクトルール（`.claude/rules/*.md`）
4. CLAUDE.md
5. グローバル設定

---

## 権限設定

公式ドキュメント: https://code.claude.com/docs/en/permissions

### 基本構造

```json
{
  "permissions": {
    "allow": ["Tool1", "Tool2(pattern)"],
    "deny": ["Tool3"],
    "ask": ["Tool4"]
  }
}
```

### ワイルドカードパターン（v2.1.0+）

Bash コマンドでワイルドカードパターンを使用可能:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm *)",
      "Bash(* install)",
      "Bash(git * main)"
    ]
  }
}
```

### MCP ワイルドカード（v2.0.70+）

MCP サーバーのツールを一括許可:

```json
{
  "permissions": {
    "allow": ["mcp__server__*"]
  }
}
```

### エージェントの無効化（v2.1.0+）

Task ツールで特定エージェントの呼び出しを禁止:

```json
{
  "permissions": {
    "deny": ["Task(DangerousAgent)"]
  }
}
```

### 設定の優先順位

1. Managed settings（システム全体）
2. Global User Settings（`~/.claude/settings.json`）
3. Project Settings（`.claude/settings.json`）
4. Local Project Overrides（`.claude/settings.local.json`）

---

## MCP（Model Context Protocol）

### MCP管理コマンド

```bash
# サーバー追加
claude mcp add <name> <command>

# サーバー一覧
claude mcp list

# サーバー削除
claude mcp remove <name>

# サーバー有効化/無効化
/mcp enable <server-name>
/mcp disable <server-name>
```

### 設定ファイル

| スコープ | ファイル |
|---------|---------|
| User | `~/.claude.json` |
| Project | `.mcp.json` |

### list_changed 通知（v2.1.0+）

MCP サーバーがツール・プロンプト・リソースの動的更新を通知可能。再接続なしでツール変更を反映。

---

## Vim モーション（v2.1.0+）

Claude Code のターミナルで利用可能な Vim キーバインド。

### 有効化

```
/vim
```

### 主なキーバインド

| カテゴリ | キー | 動作 |
|---------|------|------|
| モード | `i`, `a`, `I`, `A` | 挿入モード |
| 移動 | `h`, `j`, `k`, `l` | カーソル移動 |
| 移動 | `w`, `e`, `b` | 単語移動 |
| 移動 | `f{char}`, `F{char}` | 文字検索 |
| 繰り返し | `;`, `,` | f/F/t/T の繰り返し |
| 編集 | `x`, `dd`, `dw` | 削除 |
| ヤンク | `y`, `yy`, `Y` | コピー |
| ペースト | `p`, `P` | 貼り付け |
| インデント | `>>`, `<<` | インデント/デデント |
| 行操作 | `J` | 行結合 |
| テキストオブジェクト | `iw`, `aw`, `i"`, `a"`, `i(`, `a(` | 選択 |

---

## 名前付きセッション（v2.0.64+）

### セッション名の設定

```
/rename my-feature-session
```

### 名前でセッション再開

```bash
# REPL内
/resume my-feature-session

# CLI
claude --resume my-feature-session
```

### カスタムセッションID（v2.0.73+）

```bash
claude --session-id custom-id --resume old-session --fork-session
```

---

## Claude in Chrome（v2.0.72+）

Chrome ブラウザとの統合機能（Beta）。

### 機能

- ブラウザ直接操作（クリック、入力、スクロール）
- ライブデバッグ（コンソールエラー、DOM読み取り）
- マルチサイトワークフロー
- 操作の学習・再現

### 要件

- Chrome 拡張機能 v1.0.36+
- Claude Code CLI v2.0.73+
- Claude 有料プラン

---

## Plan モード（v2.0.60+）

### 有効化

```
/plan
```

### 機能

- 複雑な実装前に詳細な計画を策定
- Shift+Tab で「auto-accept edits」オプション
- プラン拒否時にフィードバック入力可能

---

## バックグラウンドエージェント（v2.0.60+）

### バックグラウンド化

- `Ctrl+B`: 全フォアグラウンドタスクをバックグラウンド化
- `&` プレフィックス: バックグラウンドタスクとして開始

### 特徴

- 独立したワークスペース管理
- メイン対話を妨げない並列処理
- 完了時に結果を統合

---

## 環境変数

| 変数 | 説明 |
|------|------|
| `CLAUDE_CODE_SHELL` | シェルオーバーライド |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | ファイル読み取りトークン制限 |
| `CLAUDE_CODE_EXIT_AFTER_STOP_DELAY` | 自動終了遅延 |
| `IS_DEMO` | UI からメール・組織を非表示 |
| `FORCE_AUTOUPDATE_PLUGINS` | プラグイン自動更新強制 |
| `ENABLE_LSP_TOOL` | LSP ツール有効化 |

---

## マーケットプレイス

### marketplace.json

```json
{
  "name": "marketplace-name",
  "owner": {
    "name": "Owner Name"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "説明"
    }
  ]
}
```

### ソース形式

```json
// 相対パス
"source": "./plugins/my-plugin"

// GitHub（ブランチ指定可）
"source": { "source": "github", "repo": "owner/repo#branch" }

// URL
"source": { "source": "url", "url": "https://..." }
```

---

## インストール

```bash
# インタラクティブ
/plugin install

# 直接指定
claude plugin install plugin-name@marketplace

# スコープ指定
claude plugin install plugin-name@marketplace --scope project
```

### スコープ

| スコープ | 設定ファイル | 用途 |
|---------|-------------|------|
| user | ~/.claude/settings.json | 全プロジェクト共通 |
| project | .claude/settings.json | チーム共有（git管理） |
| local | .claude/settings.local.json | ローカルのみ |

---

## 開発・テスト

```bash
# ローカルプラグインをロード
claude --plugin-dir ./my-plugin

# 検証
claude plugin validate .
/plugin validate .
```

---

## よくある質問

### Q: スキルが発動しない

```bash
# スキル確認
What Skills are available?

# デバッグモード
claude --debug

# プラグインスキルが表示されない場合
rm -rf ~/.claude/plugins/cache
/plugin install plugin-name@marketplace
```

### Q: フックが動作しない

- 設定変更後は新しいセッションを開始
- タイムアウト値を確認（デフォルト10分）
- `claude --debug` でログを確認

### Q: プラグインが更新されない

- `plugin.json` の version を更新
- Claude Code はバージョン単位でキャッシュ
- キャッシュをクリア: `rm -rf ~/.claude/plugins/cache`

---

## 参考

- [プラグイン公式ドキュメント](https://code.claude.com/docs/en/plugins)
- [プラグインリファレンス](https://code.claude.com/docs/en/plugins-reference)
- [スラッシュコマンド](https://code.claude.com/docs/en/slash-commands)
- [サブエージェント](https://code.claude.com/docs/en/sub-agents)
- [スキル](https://code.claude.com/docs/en/skills)
- [フック](https://code.claude.com/docs/en/hooks)
- [フック入門ガイド](https://code.claude.com/docs/en/hooks-guide)
- [マーケットプレイス](https://code.claude.com/docs/en/plugin-marketplaces)
- [LSP](https://code.claude.com/docs/en/lsp)
- [権限設定](https://code.claude.com/docs/en/permissions)
- [メモリ（CLAUDE.md/Rules）](https://code.claude.com/docs/en/memory)
