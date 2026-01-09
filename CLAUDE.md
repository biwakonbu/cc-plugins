# cc-plugins プロジェクト

Claude Code プラグインのマーケットプレイスリポジトリ。

## プロジェクト構造

```
cc-plugins/
├── .claude-plugin/
│   └── marketplace.json  # マーケットプレイス設定
└── plugins/              # プラグイン格納ディレクトリ
    ├── codex-cli-spec/     # Codex CLI 仕様知識 (v1.1.0)
    ├── cursor-cli-spec/    # Cursor CLI 仕様知識 (v1.0.0)
    ├── gemini-cli-spec/    # Gemini CLI 仕様知識 (v1.0.0)
    ├── git-actions/        # Git ワークフロー管理 (v1.2.5)
    ├── plugin-generator/   # プラグイン生成・検証 (v1.2.0)
    └── web-search-gemini/  # Gemini Web 検索 (v1.0.5)
```

## 収録プラグイン

| プラグイン | バージョン | 説明 |
|-----------|-----------|------|
| codex-cli-spec | 1.1.0 | OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| cursor-cli-spec | 1.0.0 | Cursor IDE および cursor-agent CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| gemini-cli-spec | 1.0.0 | Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン |
| git-actions | 1.2.5 | Git commit and push workflow management for Claude Code |
| plugin-generator | 1.2.0 | Claude Code プラグインのスキャフォールディングとバリデーション |
| plugin-updater | 1.0.1 | マーケットプレイスとインストール済みプラグインを一括更新 |
| web-search-gemini | 1.0.5 | Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。 |

## 開発言語

- ドキュメント・コメント: 日本語
- コード・変数名: 英語

---

# Claude Code プラグイン仕様

公式ドキュメント: https://code.claude.com/docs/en/plugins

## プラグイン構造

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

## plugin.json スキーマ

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

## スラッシュコマンド定義

公式ドキュメント: https://code.claude.com/docs/en/slash-commands

### スラッシュコマンドとは

- 頻繁に使用するプロンプトを Markdown ファイルとして定義し、`/command-name` で実行できる機能
- ワークフローの標準化と再利用可能なプロンプト作成に最適

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
---

# コマンド本体

以下のメッセージでコミットを作成:

$ARGUMENTS

必ず以下を実行:
- 変更をステージング
- 明確なコミットメッセージを記述
```

### フロントマターオプション

| フィールド | 型 | 説明 | 例 |
|-----------|-----|------|-----|
| `allowed-tools` | String | 使用可能ツールを制限 | `Bash(git add:*), Read, Write` |
| `argument-hint` | String | 引数のヒント | `[message]` or `[pr-number] [priority]` |
| `description` | String | コマンドの説明 | `Git コミットを作成` |
| `model` | String | 使用モデル指定 | `claude-haiku-4-5-20251001` |
| `disable-model-invocation` | Boolean | `true` で無効化 | `true` / `false` |

### 引数の取得

**全引数を取得:**
```markdown
$ARGUMENTS
```

**位置引数を取得:**
```markdown
PR #$1 をレビュー（優先度: $2、担当: $3）
```

使用例: `/review 123 high alice` → `PR #123 をレビュー（優先度: high、担当: alice）`

### 動的コンテキスト埋め込み

**Bash コマンド実行（`!` プレフィックス）:**
```markdown
## コンテキスト
- 現在の git status: !`git status`
- 現在の diff: !`git diff HEAD`

上記の変更に基づいてコミットメッセージを作成。
```

**ファイル内容参照（`@` プレフィックス）:**
```markdown
このファイルをレビュー:
@/path/to/file.ts

構造と改善点についてフィードバック。
```

### プラグインコマンド

プラグインのコマンドはネームスペース付きで呼び出し:

- ファイル: `plugins/my-plugin/commands/hello.md`
- コマンド名: `/my-plugin:hello`
- 形式: `/plugin-name:command-name`

### MCP サーバーコマンド

MCP サーバーはプロンプトをスラッシュコマンドとして公開可能。接続された MCP サーバーから自動的に検出される。

### SlashCommand ツール

Claude がプログラム的にスラッシュコマンドを実行できるツール。

**制限事項:**
- ユーザー定義のカスタムコマンドのみ対応
- ビルトインコマンド（`/compact`, `/init` など）は非対応
- `description` フロントマターが必須

### 実装例

`.claude/commands/commit.md`:
```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Read
argument-hint: [commit message]
description: 変更をステージングしてコミット
model: claude-haiku-4-5-20251001
---

# Git Commit

現在の状態を確認:

Status: !`git status`
Diff: !`git diff HEAD`

Conventional Commits 形式でコミット:
- type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore

コミットメッセージ:
$ARGUMENTS

変更をステージングしてコミット。
```

使用: `/commit "fix(auth): トークン有効期限の問題を修正"`

## サブエージェント定義（agents/*.md）

```markdown
---
name: agent-name
description: いつ呼ばれるかの説明
tools: Read, Glob, Grep, Bash     # 省略時は全ツール継承
model: haiku                       # haiku | opus | inherit
permissionMode: default
skills: skill1, skill2
---

# システムプロンプト

エージェントへの指示をここに記述。
```

### tools フィールド

- 省略: 親の全ツール + MCP ツールを継承
- 指定: 制限（例: `Read, Glob, Grep`）

### model フィールド

- `haiku`: 高速・定型タスク向け（推奨）
- `opus`: 最高性能・複雑なタスク向け
- `inherit`: 親から継承

**注意**: `sonnet` は現在の Claude Code では推奨されません。

## スキル定義（skills/{name}/SKILL.md）

公式ドキュメント: https://code.claude.com/docs/en/skills

### スキルとは

- Claude が特定タスクを実行する方法を教える Markdown ファイル
- ユーザーの要求が description に一致すると Claude が**自動的に**適用（モデル呼び出し型）
- PR レビュー、コミット生成、データベースクエリなどの標準化に最適

### スキル vs 他機能

| 機能 | 発動 | 用途 |
|------|------|------|
| Skills | Claude が自動判断 | 専門知識提供、標準化 |
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

### ディレクトリ構造

```
my-skill/
├── SKILL.md          # 必須: 概要とナビゲーション
├── reference.md      # オプション: 詳細ドキュメント
├── examples.md       # オプション: 使用例
└── scripts/          # オプション: ユーティリティ
    └── helper.py
```

### SKILL.md フォーマット

```yaml
---
name: skill-name                    # 必須: 小文字、数字、ハイフンのみ（最大64文字）
description: スキルの説明            # 必須: いつ使うか明記（最大1024文字）
allowed-tools: Read, Grep, Glob     # オプション: 使用可能ツール制限
---

# スキル名

## Instructions
明確なステップバイステップの指示

## Examples
具体的な使用例
```

**重要**: フロントマターは必ず1行目から `---` で開始（空行不可）

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

### トラブルシューティング

```bash
# スキル確認
What Skills are available?

# デバッグモード
claude --debug

# プラグインスキルが表示されない場合
rm -rf ~/.claude/plugins/cache
/plugin install plugin-name@marketplace
```

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
| PreToolUse | ツール実行前 | ○ |
| PostToolUse | ツール実行成功後 | ○ |
| PostToolUseFailure | ツール実行失敗後 | ○ |
| PermissionRequest | ツール許可リクエスト時（v2.0.45+） | ○ |
| UserPromptSubmit | プロンプト送信時 | × |
| SessionStart | セッション開始時 | × |
| SessionEnd | セッション終了時 | × |
| Stop | Claude 停止時 | × |
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

### stdin JSON データ

```json
{
  "session_id": "string",
  "transcript_path": "path/to/transcript.json",
  "cwd": "current/working/directory",
  "hook_event_name": "PreToolUse|PostToolUse|...",
  "tool_name": "Write",
  "tool_input": {...},
  "tool_response": {...}
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

#### 本番ファイル保護

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_FILE_PATHS\" =~ (prod|production|secrets) ]]; then echo 'Protected' && exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

#### セッションログ

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "echo \"Started: $(date)\" >> .claude/session.log"
      }
    ],
    "SessionEnd": [
      {
        "type": "command",
        "command": "echo \"Ended: $(date)\" >> .claude/session.log"
      }
    ]
  }
}
```

### プラグインでのフック定義（hooks/hooks.json）

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
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

### デバッグ

```bash
# 手動テスト
CLAUDE_TOOL_NAME="Edit" CLAUDE_FILE_PATHS="src/app.ts" bash my-hook.sh

# デバッグモード
claude --debug

# Verbose モード（Ctrl+O / Cmd+O）
```

### ベストプラクティス

- PostToolUse フォーマッターから開始（フィードバックが可視化しやすい）
- 不要な実行は早期終了（`exit 0`）
- タイムアウトを適切に設定（デフォルト60秒）
- 機密設定は `.local.json` に分離
- 入力をサニタイズしてセキュリティ確保

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

// GitHub
"source": { "source": "github", "repo": "owner/repo" }

// URL
"source": { "source": "url", "url": "https://..." }
```

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

## 開発・テスト

```bash
# ローカルプラグインをロード
claude --plugin-dir ./my-plugin

# 検証
claude plugin validate .
/plugin validate .
```

## 開発ルール

### バージョン更新（重要）

**プラグインの内容を変更した場合は必ず `plugin.json` の version を更新すること。**

- Claude Code はプラグインをバージョン単位でキャッシュする
- バージョンを更新しないと、変更がユーザーに反映されない
- セマンティックバージョニングに従う:
  - パッチ（x.x.1）: バグ修正
  - マイナー（x.1.0）: 後方互換の機能追加
  - メジャー（1.0.0）: 破壊的変更

## 参考

- [プラグイン公式ドキュメント](https://code.claude.com/docs/en/plugins)
- [プラグインリファレンス](https://code.claude.com/docs/en/plugins-reference)
- [スラッシュコマンド](https://code.claude.com/docs/en/slash-commands)
- [サブエージェント](https://code.claude.com/docs/en/sub-agents)
- [スキル](https://code.claude.com/docs/en/skills)
- [フック](https://code.claude.com/docs/en/hooks)
- [フック入門ガイド](https://code.claude.com/docs/en/hooks-guide)
- [マーケットプレイス](https://code.claude.com/docs/en/plugin-marketplaces)
