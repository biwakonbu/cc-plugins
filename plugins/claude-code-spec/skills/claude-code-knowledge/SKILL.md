---
name: claude-code-knowledge
description: Claude Code CLI の仕様と使い方に関する知識を提供。プラグイン開発、スキル、スラッシュコマンド、サブエージェント、フック、LSP、MCP、権限設定、セッション管理、エージェントチーム、バックグラウンドエージェント、Git Worktree、セッションテレポートについて回答。Use when user asks about Claude Code, plugins, skills, slash commands, subagents, hooks, LSP, MCP, permissions, sessions, plan mode, agent teams, background agents, worktree, or teleport. Also use when user says Claude Code について, プラグイン開発, スキル定義, フック設定, 権限設定.
context: fork
---

# Claude Code Knowledge

Claude Code CLI（v2.1.49 対応）の仕様と使い方に関する知識を提供します。

公式ドキュメント: https://code.claude.com/docs/en/

---

## 概要

- **正式名称**: Claude Code
- **開発元**: Anthropic
- **インストール**: `npm install -g @anthropic/claude-code`（非推奨化予定、後述）
- **起動**: `claude`
- **ライセンス**: 有料プラン必須

### モデル

| モデル | モデル ID | 説明 |
|--------|----------|------|
| **Opus 4.6**（デフォルト） | `claude-opus-4-6` | 最高性能。複雑なタスク、深い推論に最適 |
| **Sonnet 4.6** | `claude-sonnet-4-6` | 高速・コスト効率。定型タスク、大量処理向け |

**重要**: 上記以外のモデル（Opus 4/4.1 含む）は利用価値なし。Opus 4/4.1 は非推奨化済み。

サブエージェントの model フィールド:
- `opus`: Opus 4.6 を使用（デフォルト）
- `sonnet`: Sonnet 4.6 を使用（高速・コスト効率推奨）
- `haiku`: Haiku 4.5 を使用（軽量タスク向け）

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
├── settings.json             # プラグイン同梱設定（v2.1.49+）
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

### プラグインシステム更新

| 機能 | バージョン | 説明 |
|------|-----------|------|
| `settings.json` 同梱 | v2.1.49 | プラグインに設定ファイルをバンドル可能 |
| git SHA ピン留め | v2.1.14 | 特定コミットでプラグインバージョンを固定 |
| `--add-dir` 読み込み | v2.1.45 | 追加ディレクトリからプラグインを読み込み |
| スキル説明にプラグイン名表示 | v2.1.33 | どのプラグインのスキルか識別可能 |

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

### 引数の取得

```markdown
# 全引数
$ARGUMENTS

# 位置引数
PR #$1 をレビュー（優先度: $2、担当: $3）
```

### 動的コンテキスト埋め込み

**構文**:
- Bash コマンド実行: `!` + バッククォートで囲んだコマンド（例: `!` + `` `git status` ``）
- ファイル参照: `@/path/to/file.ts`

**重要**: `!`プレフィックス記法はスラッシュコマンド（commands/*.md）でのみ有効です。スキルファイル（SKILL.md）では使用できません。

### 新スラッシュコマンド

| コマンド | バージョン | 説明 |
|----------|-----------|------|
| `/debug` | v2.1.30 | デバッグ情報を表示 |
| `/desktop` | v2.1.30+ | セッションテレポート（ブラウザ継続） |
| `/fast` | v2.1.32+ | 高速モード切り替え |
| `/usage` | v2.1.14 | トークン使用量を表示 |
| `/rename` | v2.1.41 | セッション名変更（引数なしで自動生成） |

---

## サブエージェント定義

公式ドキュメント: https://code.claude.com/docs/en/sub-agents

```markdown
---
name: agent-name
description: いつ呼ばれるかの説明
tools: Read, Glob, Grep, Bash     # 省略時は全ツール継承
model: sonnet                      # haiku | sonnet | opus | inherit
background: true                   # バックグラウンド実行（v2.1.49+）
memory: true                       # 自動メモリ有効化（v2.1.33+）
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
| `opus` | Opus 4.6。最高性能・複雑なタスク向け（デフォルト） |
| `sonnet` | Sonnet 4.6。高速・コスト効率向け（推奨） |
| `haiku` | Haiku 4.5。軽量・定型タスク向け |
| `inherit` | 親から継承 |

### 新フィールド

| フィールド | バージョン | 説明 |
|-----------|-----------|------|
| `background: true` | v2.1.49 | バックグラウンドエージェントとして実行 |
| `memory` | v2.1.33 | 自動メモリ機能の有効化 |
| `Task(agent_type)` 制限構文 | v2.1.33 | 特定エージェントの呼び出しを制限 |

### permissionMode フィールド（v2.0.43+）

| モード | 説明 |
|--------|------|
| `default` | 親の権限設定を継承 |
| `permissive` | より緩やかな権限 |
| `strict` | より厳格な権限 |

---

## スキル定義

公式ドキュメント: https://code.claude.com/docs/en/skills

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

---

## エージェントチーム（実験的、v2.1.32+）

### 有効化

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### 概要

複数の Claude Code インスタンスが協調して作業するチーム機能。

### アーキテクチャ

- **チームリーダー**: タスクの分配と調整を担当
- **共有タスクリスト**: TaskCreate/TaskUpdate で全メンバーがタスクを共有
- **直接メッセージング**: エージェント間で情報を直接交換

### バックエンド

- tmux をバックエンドとして使用
- 各エージェントが独立した tmux セッションで実行
- リーダーが全セッションを監視・調整

---

## バックグラウンドエージェント強化

### バックグラウンド化

- `Ctrl+B`: 全フォアグラウンドタスクをバックグラウンド化
- `&` プレフィックス: バックグラウンドタスクとして開始

### `background: true` エージェントフィールド（v2.1.49）

エージェント定義に `background: true` を指定すると、常にバックグラウンドで実行:

```yaml
---
name: background-worker
description: バックグラウンドで実行するワーカー
background: true
---
```

### キャンセルとクリーンアップ

- ESC でキャンセル時もバックグラウンドエージェントは継続
- `Ctrl+F`（2回）で全バックグラウンドエージェントを終了

---

## Git Worktree サポート（v2.1.49）

### CLI フラグ

```bash
# Worktree で起動
claude --worktree
claude -w

# 名前付き Worktree
claude -w my-feature
```

### サブエージェント Worktree 分離

サブエージェントが独立した Worktree で作業可能:
- メインの作業ツリーに影響を与えない
- 並列作業の安全性を確保
- 完了時に結果をマージ

---

## セッションテレポート（v2.1.30+）

### 概要

CLI セッションをブラウザ（`claude.ai/code`）に引き継ぐ機能。

### 使い方

```
/desktop
```

または `claude.ai/code` でブラウザから継続。

### iOS からのタスク委任

iOS デバイスからタスクを開始し、CLI で実行を継続可能。

---

## 自動メモリ（v2.1.32+）

### 概要

セッション中に学習した情報を自動的に記録・呼び出す機能。

### エージェント `memory` フィールド

```yaml
---
name: my-agent
memory: true
---
```

`memory: true` を指定すると、エージェントが自動メモリ機能を利用可能。

---

## タスク管理システム（v2.1.16+）

### 依存関係追跡

- TaskCreate でタスクを作成
- TaskUpdate でステータス更新（`pending` → `in_progress` → `completed`）
- `addBlocks`/`addBlockedBy` で依存関係を設定
- TaskUpdate でタスク削除（`status: "deleted"`）

---

## PR レビュー状況（v2.1.20+）

### プロンプトフッターに PR ステータス表示

- PR の状態（open/closed/merged）を自動表示
- レビューコメント数、承認状態の確認

### `--from-pr` フラグ

```bash
claude --from-pr 123
```

PR の内容をコンテキストとして読み込んで作業開始。

---

## フック定義

公式ドキュメント: https://code.claude.com/docs/en/hooks

### イベント一覧

| イベント | トリガー | マッチャー | バージョン |
|---------|---------|-----------|-----------|
| PreToolUse | ツール実行前 | ○ | - |
| PostToolUse | ツール実行成功後 | ○ | - |
| PostToolUseFailure | ツール実行失敗後 | ○ | - |
| PermissionRequest | ツール許可リクエスト時 | ○ | v2.0.45+ |
| UserPromptSubmit | プロンプト送信時 | x | - |
| SessionStart | セッション開始時 | x | - |
| SessionEnd | セッション終了時 | x | - |
| Stop | Claude 停止時 | x | - |
| SubagentStart | サブエージェント開始時 | x | v2.0.43+ |
| SubagentStop | サブエージェント完了時 | x | v1.0.41+ |
| TeammateIdle | チームメイトがアイドル時 | x | v2.1.33+ |
| TaskCompleted | タスク完了時 | x | v2.1.33+ |
| ConfigChange | 設定変更時 | x | v2.1.47+ |
| Notification | 通知送信時 | x | - |

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

### フックタイプ

```json
// Command: シェルコマンド実行
{ "type": "command", "command": "bash-command" }

// Prompt: LLM 評価
{ "type": "prompt", "prompt": "LLM に送信するプロンプト" }

// Agent: サブエージェント実行
{ "type": "agent", ... }
```

### 環境変数

| 変数 | 説明 |
|------|------|
| `$CLAUDE_PROJECT_DIR` | プロジェクトルート |
| `$CLAUDE_WORKING_DIR` | 作業ディレクトリ |
| `$CLAUDE_FILE_PATHS` | 操作対象ファイル |
| `$CLAUDE_TOOL_NAME` | 実行ツール名 |
| `$CLAUDE_COMMAND` | 実行コマンド |
| `$CLAUDE_SESSION_ID` | セッション ID |
| `$CLAUDE_ENV_FILE` | 環境変数永続化ファイル |
| `${CLAUDE_PLUGIN_ROOT}` | プラグインディレクトリ |
| `$CLAUDE_HOOK_EVENT` | イベント名 |
| `$CLAUDE_HOOK_TOOL_NAME` | ツール名 |
| `$CLAUDE_HOOK_TOOL_ARGS` | ツール引数（JSON） |

---

## 新 CLI フラグ

| フラグ | 説明 | バージョン |
|--------|------|-----------|
| `--worktree`, `-w` | Git Worktree で起動 | v2.1.49 |
| `--from-pr` | PR コンテキストで開始 | v2.1.20+ |
| `--fork-session` | セッションをフォーク | v2.0.73+ |

## 新 CLI サブコマンド

| コマンド | 説明 | バージョン |
|----------|------|-----------|
| `claude auth login` | 認証ログイン | v2.1.41 |
| `claude auth status` | 認証状態確認 | v2.1.41 |
| `claude auth logout` | 認証ログアウト | v2.1.41 |

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

### Permission Hook で自律動作

フックで権限判定を自動化:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"permissionDecision\": \"allow\"}'"
          }
        ]
      }
    ]
  }
}
```

### コンテンツレベル要求の優先度

コンテンツレベルの権限要求は設定レベルの許可より優先される。

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
```

### Tool Search デフォルト Auto（v2.1.7）

MCP ツールの検索がデフォルトで自動モードに。

### claude.ai MCP コネクタ（v2.1.46）

`claude.ai` から MCP サーバーに接続可能。

### OAuth クライアント資格情報（v2.1.30）

MCP サーバーの認証に OAuth クライアント資格情報フローを使用可能。

---

## Plan モード改善

### 計画がファイルに保存

- Plan モードで作成した計画がファイルに保存される
- 後から参照・編集可能

### 受け入れ時にコンテキストリセット

- 計画を承認すると新しいコンテキストで実行開始
- 不要な履歴を引き継がない

---

## 設定オプション追加

| 設定 | 説明 |
|------|------|
| `spinnerTipsOverride` | スピナーヒントのカスタマイズ |
| `spinnerVerbs` | スピナー動詞のカスタマイズ |
| `showTurnDuration` | ターン所要時間の表示 |
| `fastMode` | 高速モードのデフォルト設定 |

---

## LSPサーバー定義

公式ドキュメント: https://code.claude.com/docs/en/lsp

### 有効化

```bash
export ENABLE_LSP_TOOL=1
```

### 設定ファイル

`.lsp.json`:
```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "file_extensions": ["ts", "tsx", "js", "jsx"]
  }
}
```

---

## Vim モーション（v2.1.0+）

```
/vim
```

---

## 名前付きセッション（v2.0.64+）

```
/rename my-feature-session
```

v2.1.41 以降、引数なしで自動生成:
```
/rename
```

---

## インストール

### npm（非推奨化予定、v2.1.15）

```bash
npm install -g @anthropic/claude-code
```

v2.1.15 以降、npm インストールは非推奨化。公式インストーラーの使用を推奨。

---

## 環境変数

| 変数 | 説明 |
|------|------|
| `CLAUDE_CODE_SHELL` | シェルオーバーライド |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | ファイル読み取りトークン制限 |
| `CLAUDE_CODE_EXIT_AFTER_STOP_DELAY` | 自動終了遅延 |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | エージェントチーム有効化 |
| `ENABLE_LSP_TOOL` | LSP ツール有効化 |
| `FORCE_AUTOUPDATE_PLUGINS` | プラグイン自動更新強制 |

---

## 破壊的変更

### npm インストール非推奨化（v2.1.15）

- `npm install -g @anthropic/claude-code` は非推奨
- 公式インストーラーの使用を推奨

### OAuth URL 変更（v2.1.7）

- 認証 URL が変更
- 旧 URL はリダイレクトで対応

### Opus 4.6 でプリフィル削除

- Opus 4.6 ではレスポンスのプリフィルが削除
- より自然な応答生成

### Opus 4/4.1 非推奨化

- 旧モデル（Opus 4、Opus 4.1）は非推奨
- Opus 4.6 への移行を推奨

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

---

## 開発・テスト

```bash
# ローカルプラグインをロード
claude --plugin-dir ./my-plugin

# 追加ディレクトリからプラグイン読み込み（v2.1.45+）
claude --add-dir ./additional-plugins

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
