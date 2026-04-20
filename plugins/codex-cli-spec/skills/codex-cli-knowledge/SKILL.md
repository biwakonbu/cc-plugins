---
name: codex-cli-knowledge
description: Use when user asks about Codex CLI, codex command, approval mode, sandbox, AGENTS.md, codex configuration, /model, /review, /compact, /plan, /personality, /collab, /agent, apply_patch, reasoning level, multi-agent, plugin system, MCP server, hook engine, or memory management. Also use when user says Codex CLI について, codex の使い方, 承認モード, 推論レベル. OpenAI Codex CLI の仕様と使い方に関する知識を提供し、モデル選択、推論レベル、承認モード、サンドボックス、組み込みツール、スラッシュコマンド、Plan モード、マルチエージェント協調、メモリ管理、Steer モード、パーソナリティ設定、プラグインシステム、MCP 連携、フックエンジン、カスタムエージェントについて回答する。
context: fork
---

# Codex CLI Knowledge

OpenAI Codex CLI の仕様と使い方に関する包括的な知識を提供するスキル。

**最新バージョン**: v0.116.0（2026-03-19）

## 概要

OpenAI Codex CLI は、ターミナル上で動作する軽量なコーディングエージェント。ChatGPT レベルの推論能力に加え、コードの実行、ファイル操作、依存関係のインストールなどを自動で行う機能を備える。

| 項目 | 内容 |
|------|------|
| 正式名称 | OpenAI Codex CLI |
| npm パッケージ名 | `@openai/codex` |
| SDK パッケージ名 | `@openai/codex-sdk` |
| GitHub リポジトリ | https://github.com/openai/codex |
| ライセンス | Apache-2.0 |
| 開発言語 | Rust |
| 推奨 Node.js | 18+ |

---

## インストール方法

### npm（推奨）

```bash
npm install -g @openai/codex
```

### Homebrew（macOS）

```bash
brew install --cask codex
```

### 直接インストールスクリプト（v0.106.0+、macOS/Linux）

```bash
# npm なしでインストール可能
curl -fsSL https://codex.openai.com/install.sh | sh
```

### その他のパッケージマネージャー

```bash
# yarn
yarn global add @openai/codex

# pnpm
pnpm add -g @openai/codex

# bun
bun install -g @openai/codex
```

### Windows インストーラー（v0.110.0+）

Windows ネイティブインストーラーが利用可能。PowerShell 環境で直接動作。

### システム要件

| 要件 | 詳細 |
|------|------|
| OS | macOS 12+、Ubuntu 20.04+/Debian 10+、Windows 11（ネイティブ / WSL2） |
| Git（推奨） | 2.23+ |
| RAM | 4GB 以上（8GB 推奨） |

---

## 認証

### ChatGPT プラン（メイン）

ChatGPT のサブスクリプション（Plus/Pro/Team/Edu/Enterprise）で利用可能。

```bash
codex login
```

ブラウザで OAuth 認証を完了。

### Device-code auth（ヘッドレス環境）

SSH やコンテナなどブラウザが利用できない環境:

```bash
codex login --device-code
```

表示されるコードを別のデバイスで入力して認証。

v0.116.0 で App-server TUI がデバイスコードによるサインインとトークン更新に完全対応。

### codex app コマンド（デスクトップアプリ）

```bash
codex app
```

macOS / Windows デスクトップアプリを起動。CLI と同期する GUI 環境を提供。

### 認証情報の保存

- `~/.codex/auth.json` またはシステムキーチェーンに分離保存

---

## 利用可能なモデル

**注意**: `gpt-5.4` を標準使用すること。サブエージェント用途には `gpt-5.4-mini` も有効。

| モデル | 用途 | 推論レベル | 特徴 |
|--------|------|------------|------|
| `gpt-5.4` | 標準フラッグシップ（デフォルト・推奨） | low, medium, high, xhigh | 100万トークンコンテキスト（試験的） |
| `gpt-5.4-mini` | サブエージェント・軽量タスク | low, medium, high | 2倍以上高速、コスト30%（GPT-5.4比） |

### 推論レベル（Reasoning Effort）

各モデルは複数の推論レベルをサポート:

| レベル | 説明 | 用途 |
|--------|------|------|
| `low` | 高速応答、軽い推論 | 簡単な質問、フォーマット |
| `medium` | 速度と推論深度のバランス（デフォルト） | 通常のコーディングタスク |
| `high` | 複雑な問題に対する深い推論 | 設計、方針検討、評価、デバッグ |
| `xhigh` | 最も深い推論 | 最高の思考が必要な場合 |

### モデル選択のベストプラクティス

| ユースケース | 推奨モデル | 推論レベル |
|-------------|-----------|------------|
| 通常のコーディング | `gpt-5.4` | medium |
| 設計・方針検討・評価 | `gpt-5.4` | high |
| 最高の思考が必要な場合 | `gpt-5.4` | xhigh |
| 簡単な修正・フォーマット | `gpt-5.4` | low |
| サブエージェント並列タスク | `gpt-5.4-mini` | medium |

### モデル変更方法

```bash
# コマンドラインで指定
codex --model gpt-5.4 "タスクを実行"

# インタラクティブモードで変更
/model
```

---

## Plan モード（v0.94.0 デフォルト有効化）

### 概要

実装前に計画を策定するモード。v0.94.0 以降デフォルトで有効。

### 使い方

```
/plan
```

- Plan モードの推論 effort: `medium`（通常実行時より軽量）
- `Shift+Tab` でモード切り替え: Plan → Act → Auto（サイクル）

### `/collab` コマンド（v0.114.0+）

3つのコラボレーションモードを選択可能:

| モード | 説明 |
|--------|------|
| Plan | 計画策定のみ（実行しない） |
| Pair Programming | 対話的に共同作業 |
| Execute | 計画なしで即実行 |

### 動作

1. Plan モードで計画を策定
2. ユーザーが承認
3. Act モードで実行

---

## マルチエージェント協調（v0.90.0+、v0.115.0 一般公開）

### 概要

複数のサブエージェントを並列で起動し、複雑なタスクを分割処理する機能。v0.115.0 でサブエージェント機能が一般公開。

### 設定

| パラメータ | デフォルト | 説明 |
|-----------|-----------|------|
| Sub-agent 最大数 | 6 | 同時に実行可能なサブエージェントの数 |
| Max-depth | 3 | サブエージェントのネスト深度制限 |

### プリセットエージェント（v0.115.0+）

| ロール | 説明 |
|--------|------|
| `explorer` | 読み取り専用、コードベース探索・調査特化 |
| `worker` | 汎用実行エージェント |

### カスタムエージェント定義（v0.115.0+）

`~/.codex/agents/` に TOML ファイルで独自エージェントを定義可能:

```toml
# ~/.codex/agents/reviewer.toml
[agent]
name = "reviewer"
role = "code reviewer"
tools = ["read_file", "grep_files", "list_dir"]
model = "gpt-5.4"
```

### AGENTS.md でのロール定義（v0.102.0+）

```yaml
# AGENTS.md で定義
agents:
  explorer:
    role: "read-only explorer"
    tools: [read_file, grep_files, list_dir]
  implementer:
    role: "code writer"
    tools: [apply_patch, shell, read_file]
```

### CSV マルチエージェントファンアウト（v0.105.0+）

`spawn_agents_on_csv` による並列タスク実行。進捗/ETA 表示付き。

### スレッドフォーク（v0.107.0+）

現在のスレッドをサブエージェントにフォーク可能。コンテキストを引き継いで並列作業。

### TUI 個別承認（v0.110.0+）

サブエージェントの動作を TUI 上で個別に承認/拒否。

### サブエージェント高速化（v0.110.0+）

シェル状態の再利用で起動を大幅高速化。

### Git Worktree 隔離

各エージェントが独立 Git Worktree で作業し、コード競合を防止。

### 有効化方法

```toml
# ~/.codex/config.toml
[experimental]
multi_agent = true
```

または `/experimental` コマンドでトグル。

---

## メモリ管理システム（v0.97.0+）

### スラッシュコマンド

| コマンド | 説明 |
|----------|------|
| `/m_update` | メモリに新しい情報を追加・更新 |
| `/m_drop` | メモリから情報を削除 |

### 特徴

- ローカル永続化（`~/.codex/memory/`）
- セッション間で情報を保持
- シークレットサニタイザー: 機密情報（API キー等）を自動的にフィルタリング
- 差分ベース忘却アルゴリズム（v0.106.0+）: メモリ管理の精度向上
- ワークスペーススコープのメモリ書き込み対応（v0.110.0+）

### デバッグ

```bash
# メモリのデバッグクリア（v0.107.0+）
codex debug clear-memories
```

**注意**: 旧 `get_memory` ツールは削除済み。スラッシュコマンドに移行。

---

## パーソナリティ設定（v0.94.0 Stable）

### 概要

Codex CLI の応答スタイルをカスタマイズ。

### プリセット

| パーソナリティ | 説明 |
|---------------|------|
| **Pragmatic**（デフォルト） | 簡潔で実用重視 |
| Friendly | 親しみやすいスタイル |

### 設定方法

```
/personality
```

利用可能なパーソナリティを選択。`AGENTS.md` にプロジェクト専用の性格・規約を記述可能。

---

## Steer モード（v0.98.0 Stable）

### 概要

タスク実行中の入力方法を変更するモード。デフォルトで安定版として統合。

### 動作

- **Enter**: 即送信（リアルタイム介入）
- **Tab**: フォローアップキューに追加（次ステップへの指示を予約）

### 破壊的変更

v0.98.0 以前は Enter でフォローアップキュー、Tab+Enter で送信だったが、動作が逆転。

---

## プラグインシステム（v0.110.0+）

### 概要

スキル、MCP エントリ、アプリコネクタをロードするプラグイン機構。

### 機能

- スキル、MCP サーバー、アプリコネクタのインストール
- `@plugin` メンション（v0.112.0+）: チャット内でプラグインを直接参照
- 不足プラグインのインストール補助プロンプト（v0.116.0+）
- マーケットプレイスからの MCP スキル直接インストール

---

## フックエンジン（v0.114.0+）

### 概要

Codex CLI のライフサイクルイベントに対してユーザー定義のアクションを実行する機能。

### 対応イベント

| イベント | 説明 | バージョン |
|---------|------|-----------|
| `SessionStart` | セッション開始時 | v0.114.0 |
| `Stop` | セッション終了時 | v0.114.0 |
| `userpromptsubmit` | プロンプト送信前 | v0.116.0 |

### `userpromptsubmit` フック

プロンプト実行前にブロック/拡張が可能。既存ワークフローへの介入ポイントを提供。

---

## 組み込みツール

Codex CLI が内部で使用するツール一覧:

### ファイル操作ツール

| ツール | 機能 | 説明 |
|--------|------|------|
| `read_file` | ファイル読み取り | 指定ファイルの内容を取得 |
| `apply_patch` | パッチ適用 | 差分形式でファイルを編集（推奨） |
| `list_dir` | ディレクトリ一覧 | フォルダ構造を確認 |
| `grep_files` | ファイル検索 | 正規表現でファイル内検索（`rg` 推奨） |
| `view_image` | 画像表示 | 高解像度画像解析の公式サポート（v0.115.0+） |

### シェル・実行ツール

| ツール | 機能 | 説明 |
|--------|------|------|
| `shell` | シェル実行 | 任意のシェルコマンドを実行 |
| `unified_exec` | 統合実行 | 統合実行環境（Windows IPC 基盤含む） |

### JavaScript REPL（v0.100.0+）

| ツール | 機能 | 説明 |
|--------|------|------|
| `js_repl` | JavaScript 実行 | ツールコール間で状態を保持する REPL |

- `js_repl` はツールコール間で状態（変数、関数定義等）を保持
- 計算、データ変換、プロトタイピングに有用
- `/experimental` コマンドからも利用可能（v0.106.0+）

### 計画・連携ツール

| ツール | 機能 | 説明 |
|--------|------|------|
| `plan` | 計画立案 | タスクの計画を作成 |
| `mcp` | MCP 連携 | Model Context Protocol サーバーと連携 |
| `mcp_resource` | MCP リソース | MCP リソースにアクセス |
| `request_permissions` | 動的権限要求 | 実行中に追加権限を要求（v0.113.0+） |

### マルチモーダルカスタムツール（v0.107.0+）

画像等の構造化出力を返却可能なカスタムツール。

### 統合ターミナル読み取り（v0.114.0+）

実行中サーバーの状態やビルドエラーを直接確認可能。

### ツール使用のベストプラクティス

- **単一ファイル編集**: `apply_patch` を使用（差分形式で安全）
- **ファイル検索**: `grep_files` + `rg`（ripgrep）を優先
- **複数ファイル変更**: シェルスクリプトを活用

---

## MCP（Model Context Protocol）連携

### 概要

MCP サーバーとの双方向連携。GitHub、Figma、Sentry 等と直接接続。

### 設定（config.toml）

```toml
# ~/.codex/config.toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "./src"]

[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "your_token_here" }
```

### Codex を MCP サーバー化

```bash
# 他の AI エージェントから Codex を利用可能に
codex mcp-server
```

### MCP サーバー一覧

```bash
# 有効な MCP サーバーの確認（v0.109.0+）
codex mcp list
```

### 動的接続（v0.115.0+）

設定リロードなしで実行中セッションが新 MCP サーバーを認識。

---

## スラッシュコマンド

インタラクティブモードで使用可能なコマンド:

### モデル・設定

| コマンド | 説明 | タスク中 | バージョン |
|----------|------|----------|-----------|
| `/model` | モデルと推論レベルを選択 | 不可 | - |
| `/approvals` | 承認なしで実行可能な操作を設定 | 不可 | - |
| `/permissions` | 権限設定を管理 | 不可 | - |
| `/setup-elevated-sandbox` | 昇格サンドボックスをセットアップ | 不可 | - |
| `/experimental` | ベータ機能のトグル | 不可 | - |
| `/debug-config` | デバッグ設定を表示 | 不可 | - |
| `/statusline` | ステータスラインの表示設定 | 不可 | - |
| `/fast` | 高速/フレックスサービスティアの切り替え | 不可 | v0.110.0 |
| `/theme` | TUI テーマピッカー（ライブプレビュー付き） | 不可 | v0.105.0 |

### セッション管理

| コマンド | 説明 | タスク中 | バージョン |
|----------|------|----------|-----------|
| `/new` | 新しいチャットを開始 | 不可 | - |
| `/resume` | 保存されたチャットを再開 | 不可 | - |
| `/compact` | 会話を要約（コンテキスト制限対策） | 不可 | - |
| `/status` | セッション設定とトークン使用量を表示 | 可 | - |
| `/copy` | 回答をクリップボードにコピー | 可 | v0.105.0 |
| `/clear` | 画面クリア（Ctrl-L） | 可 | v0.105.0 |

### 計画・開発支援

| コマンド | 説明 | タスク中 | バージョン |
|----------|------|----------|-----------|
| `/plan` | Plan モードに切り替え | 不可 | - |
| `/collab` | コラボレーションモード選択（Plan/Pair/Execute） | 不可 | v0.114.0 |
| `/review` | 現在の変更をレビューして問題を発見 | 不可 | - |
| `/diff` | git diff を表示（未追跡ファイル含む） | 可 | - |
| `/mention` | ファイルをメンション | 可 | - |
| `/init` | AGENTS.md ファイルを作成 | 不可 | - |
| `/skills` | スキル管理（タスク実行の改善） | 可 | - |
| `/skill` | 個別スキルを管理 | 可 | - |
| `/apps` | Codex Apps を管理 | 不可 | - |
| `/agent` | マルチエージェント管理（ロールラベル付き） | 可 | v0.110.0 |

### メモリ・パーソナリティ

| コマンド | 説明 | タスク中 | バージョン |
|----------|------|----------|-----------|
| `/m_update` | メモリに情報を追加・更新 | 不可 | - |
| `/m_drop` | メモリから情報を削除 | 不可 | - |
| `/personality` | パーソナリティを選択 | 不可 | - |
| `/grant-read-access` | ファイル・ディレクトリの読み取り権限を付与 | 可 | - |

### ツール・その他

| コマンド | 説明 | タスク中 | バージョン |
|----------|------|----------|-----------|
| `/mcp` | 設定済み MCP ツールを一覧表示 | 可 | - |
| `/ps` | バックグラウンドターミナルを一覧表示 | 可 | - |
| `/feedback` | メンテナにログを送信 | 可 | - |
| `/logout` | Codex からログアウト | 不可 | - |
| `/quit`, `/exit` | Codex を終了 | 可 | - |

---

## 承認モード（セキュリティモデル）

Codex CLI の中核機能。操作の自動実行レベルを制御する。

### 承認ポリシー（--ask-for-approval）

| フラグ値 | 説明 | 用途 |
|----------|------|------|
| `untrusted` | 全アクションで承認要求 | 最も安全、初心者向け |
| `on-request` | 不確実な場合のみ承認要求 | 自動化向け |
| `never` | 承認なしで実行 | CI/CD、スクリプト向け |

**注意**: `on-failure` は v0.102.0 で非推奨化。使用しないこと。

### Smart Approvals（v0.93.0 デフォルト有効化）

- 安全と判断された操作を自動承認
- デフォルトで有効
- `"Allow and remember"` でセッションスコープの承認を記憶

### 権限の永続化（v0.114.0+）

承認された権限がターンをまたいで保持される。

### `request_permissions` ツール（v0.113.0+）

実行中のターンで動的に追加権限を要求可能。

### ユーザーフレンドリーなモード名

| モード名 | 対応フラグ | 動作 |
|----------|-----------|------|
| **Suggest**（デフォルト） | `--ask-for-approval untrusted` | 全ての書き込み・コマンドで承認 |
| **Auto Edit** | 書き込み自動 + コマンド承認 | ファイル編集は自動、シェルは承認 |
| **Full Auto** | `--full-auto` ショートカット | `on-request` + `workspace-write` |

### 承認モードの選択

```bash
# デフォルト（untrusted）
codex "タスク"

# 承認ポリシーを明示的に指定
codex --ask-for-approval on-request "タスク"
codex -a on-request "タスク"

# Full Auto モード（ショートカット）
codex --full-auto "タスク"
```

---

## サンドボックス機能

### サンドボックスモード

| モード | 説明 |
|--------|------|
| `read-only` | 読み取りのみ許可 |
| `workspace-write` | ワークスペース内の書き込み許可 |
| `danger-full-access` | 全アクセス許可（注意） |

### ReadOnlyAccess ポリシー

- ファイル読み取りのみ許可
- コードレビューや調査に最適

### macOS サンドボックス

- Apple Seatbelt（`sandbox-exec`）でラップ
- 読み取り専用ジェイルで実行
- `$PWD`、`$TMPDIR`、`~/.codex` のみ書き込み可能
- ネットワークは完全ブロック

### Linux サンドボックス

- `bwrap`（Bubblewrap）によるサンドボックス
- Docker ベースのサンドボックス（v0.107.0+）
- AppArmor 環境への対応（v0.116.0+）
- コンテナレスでの軽量隔離
- ファイルシステム・ネットワークの制限

### Windows サンドボックス（v0.115.0+）

- ネイティブ Windows サンドボックス対応
- PowerShell 環境での安定動作
- `unified_exec` IPC 基盤

### ネットワークサンドボックス

| 設定 | 説明 |
|------|------|
| `restricted` | 承認が必要 |
| `enabled` | 承認不要 |
| `sandbox_workspace_write.allow_network` | ワークスペース書き込み時のネットワーク許可（v0.109.0+） |

### SOCKS5 プロキシ

```bash
# 環境変数で設定
export WS_PROXY=socks5://localhost:1080
export WSS_PROXY=socks5://localhost:1080
```

### 構造化ネットワーク承認

- ドメイン単位でのネットワーク許可
- ポート・プロトコルの制限

### サンドボックス設定（config.toml）

```toml
[sandbox]
allowed_commands = ["ls", "git diff", "npm test"]
blocked_commands = ["rm -rf", "curl", "wget"]
restrict_to_workspace = true
```

---

## 音声機能

### 音声ディクテーション（v0.105.0+）

TUI 内でスペースキー長押しにより音声入力が可能。

### オーディオ制御（v0.107.0+）

リアルタイム音声セッションでのマイク/スピーカーの選択と設定保存。

---

## プロジェクトドキュメント（AGENTS.md）

Codex は以下の場所から `AGENTS.md` を読み込み、コンテキストを取得:

| 場所 | 用途 |
|------|------|
| `~/.codex/AGENTS.md` | 個人用グローバル設定 |
| リポジトリルートの `AGENTS.md` | プロジェクト共有設定 |
| 作業ディレクトリの `AGENTS.md` | サブフォルダ固有の設定 |

### AGENTS.md の役割

- プロジェクト固有の指示をエージェントに提供
- コーディング規約、ライブラリの使い方などを記述
- Claude Code の `CLAUDE.md` に相当

### フォルダ信頼（v0.115.0+）

未信頼ディレクトリでの実行が制限される。初回アクセス時に信頼確認。

### 作成・無効化

```bash
# AGENTS.md を作成
/init

# コマンドラインで無効化
codex --no-project-doc "タスク"

# 環境変数で無効化
export CODEX_DISABLE_PROJECT_DOC=1
```

---

## 設定方法

### 設定ファイルの場所

```
~/.codex/config.toml   # メイン設定（推奨、TOML 形式に移行）
.codex/config.toml     # プロジェクト設定
~/.codex/auth.json     # 認証情報（設定から分離）
```

**注意**: JSON / YAML 形式も引き続きサポートされるが、TOML への移行を推奨。

### マルチプロファイル（v0.115.0+）

```toml
# ~/.codex/config.toml

[general]
default_profile = "dev"
log_level = "info"

[profiles.dev]
model = "gpt-5.4"
temperature = 0.2
approval_policy = "on-request"
sandbox_mode = true

[profiles.creative]
model = "gpt-5.4"
temperature = 0.9
approval_policy = "never"
sandbox_mode = false
```

### 基本設定パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|-----|-----------|------|
| `model` | string | `gpt-5.4` | 使用するモデル |
| `approvalMode` | string | `suggest` | 承認モード |
| `fullAutoErrorMode` | string | `ask-user` | Full Auto 時のエラー処理 |
| `notify` | boolean | `true` | デスクトップ通知 |

### 設定例（TOML）

```toml
model = "gpt-5.4"
approvalMode = "suggest"
fullAutoErrorMode = "ask-user"
notify = true
```

### 設定の優先順位

コマンドライン引数 > プロファイル > プロジェクト設定 > ユーザー設定

### 環境変数

| 変数 | 説明 |
|------|------|
| `OPENAI_API_KEY` | OpenAI API キー |
| `DEBUG` | デバッグモード有効化 |
| `CODEX_QUIET_MODE` | 静粛モード（CI 向け） |
| `CODEX_DISABLE_PROJECT_DOC` | AGENTS.md の読み込み無効化 |
| `WS_PROXY` | WebSocket プロキシ設定 |
| `WSS_PROXY` | Secure WebSocket プロキシ設定 |

---

## 主要コマンドとオプション

### 基本コマンド

| コマンド | 用途 | 例 |
|---------|------|-----|
| `codex` | インタラクティブ REPL | `codex` |
| `codex "..."` | プロンプト付きで開始 | `codex "fix lint errors"` |
| `codex -q "..."` | 非インタラクティブモード | `codex -q --json "explain utils.ts"` |
| `codex completion <shell>` | シェル補完スクリプト出力 | `codex completion bash` |

### サブコマンド

| コマンド | エイリアス | 状態 | 用途 |
|---------|-----------|------|------|
| `codex` | - | Stable | インタラクティブターミナル UI |
| `codex exec` | `codex e` | Stable | 非インタラクティブなスクリプト実行 |
| `codex apply` | `codex a` | Stable | Codex Cloud の diff をローカルに適用 |
| `codex login` | - | Stable | OAuth または API キーで認証 |
| `codex app` | - | Stable | デスクトップアプリを起動（macOS/Windows） |
| `codex mcp` | - | Stable | MCP サーバーの管理 |
| `codex mcp list` | - | Stable | 有効な MCP サーバーを一覧表示（v0.109.0+） |
| `codex mcp-server` | - | Stable | Codex を MCP サーバーとして起動 |
| `codex cloud` | - | Stable | 重い処理をクラウドで実行 |
| `codex cloud list` | - | Stable | クラウドタスク一覧 |
| `codex debug clear-memories` | - | Stable | メモリのデバッグクリア（v0.107.0+） |

### `codex exec` の詳細

```bash
# 非対話型でファイル修正
codex exec --full-auto "Fix all TypeScript errors"

# 標準入力から指示
echo "Add error handling to main.ts" | codex exec -

# 最終出力をファイルに書き出し（v0.109.0+）
codex exec --last-message-file output.txt "タスク"
```

### 主要フラグ

| フラグ | 短縮形 | 説明 | バージョン |
|--------|--------|------|-----------|
| `--model` | `-m` | 使用するモデルを指定 | - |
| `--ask-for-approval` | `-a` | 承認ポリシーを指定 | - |
| `--sandbox` | `-s` | サンドボックスモード | - |
| `--full-auto` | - | Full Auto モードのショートカット | - |
| `--quiet` | `-q` | 静粛モード（CI 向け） | - |
| `--json` | - | JSON 形式で出力 | - |
| `--no-project-doc` | - | AGENTS.md の読み込みを無効化 | - |
| `--search` | - | Web 検索機能を有効化 | - |
| `--image` | `-i` | 画像ファイルを添付 | - |
| `--profile` | `-p` | 設定プロファイルを読み込み | - |
| `--cd` | `-C` | 作業ディレクトリを変更 | - |
| `--yolo` | - | 全保護を無効化（危険、非推奨） | - |
| `--mode code` | - | 実験的コードモード | v0.114.0 |
| `--disable-system-skills` | - | システムスキルを無効化 | v0.114.0 |
| `--check-config` | - | 設定ファイルの構文検証 | v0.115.0 |
| `--last-message-file` | - | 最終出力をファイルに書き出し | v0.109.0 |

---

## TUI（ターミナル UI）

### テーマ（v0.105.0+）

`/theme` コマンドでライブプレビュー付きのテーマ選択。シンタックスハイライト対応。

### App-Server アーキテクチャ（v0.115.0+）

TUI が App-server 上に配置される新アーキテクチャ。

### ヘルスチェック（v0.114.0+）

`/readyz`、`/healthz` エンドポイント。CI/CD 連携用。

---

## Git 操作の安全性

Codex CLI は Git 操作において安全性を重視:

**絶対に自動実行しない操作:**
- `git reset --hard`
- `git checkout --`（変更の破棄）
- 既存の変更の勝手なリバート
- `git push --force`（v0.102.0+ で強化）

**条件付きで実行:**
- `git commit --amend` - 明示的に要求された場合のみ

**`codex apply` の改善（v0.108.0+）:**
- `git apply --3way` を利用した競合解決に対応

---

## 実験的機能

### コードモード（v0.114.0+）

隔離環境でのコーディング作業に特化したワークフロー。

```bash
codex --mode code
```

### `/fast` トグル（v0.110.0+）

高速/フレックスサービスティアの永続的な切り替え。

---

## 破壊的変更

### `approval_policy: on-failure` 非推奨（v0.102.0）

- `on-failure` ポリシーは非推奨
- `on-request` への移行を推奨

### `get_memory` ツール削除

- 旧 `get_memory` ツールは削除済み
- `/m_update`、`/m_drop` スラッシュコマンドに移行

### Steer モードで Enter の動作変更（v0.98.0）

- Enter: 即送信（旧: フォローアップキュー）
- Tab: フォローアップキュー（旧: 送信）

### Git 操作の安全性強化（v0.102.0）

- `git push --force` の自動実行をブロック
- より厳格な破壊的操作の検出

### TUI App-Server 移行（v0.115.0+）

- 古いターミナルエミュレータで表示崩れの可能性

### コンテキスト除外設定のデフォルト化（v0.116.0）

- 一部スキル/エージェントが初期コンテキストから除外
- 復元には設定変更が必要

### フォルダ信頼の導入（v0.115.0+）

- 未信頼ディレクトリでの実行が制限される

---

## よくある質問

### Q: モデルを変更するには？

```bash
codex --model gpt-5.4 "タスク"
```

または `/model` コマンドで選択。

### Q: 推論レベルを上げるには？

`/model` コマンドでモデルと推論レベルを選択。

### Q: Plan モードを使うには？

```
/plan
```

または `Shift+Tab` でサイクル切り替え。`/collab` で3モードから選択も可能。

### Q: メモリを管理するには？

```
/m_update   # 追加・更新
/m_drop     # 削除
codex debug clear-memories  # デバッグクリア
```

### Q: CI/CD で使用するには？

```bash
codex -q --json "タスク"
codex exec --full-auto "タスク"
```

### Q: コンテキストが長くなりすぎたら？

`/compact` コマンドで会話を要約。

### Q: ファイルを安全に編集するには？

`apply_patch` ツールが推奨（差分形式で編集）。

### Q: Codex を MCP サーバーとして使うには？

```bash
codex mcp-server
```

### Q: カスタムエージェントを定義するには？

`~/.codex/agents/` に TOML ファイルを作成、または `AGENTS.md` で定義。

### Q: プロファイルを切り替えるには？

```bash
codex --profile creative "タスク"
```
