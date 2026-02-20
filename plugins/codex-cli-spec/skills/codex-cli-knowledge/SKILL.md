---
name: codex-cli-knowledge
description: OpenAI Codex CLI の仕様と使い方に関する知識を提供。モデル選択、推論レベル、承認モード、サンドボックス、組み込みツール、スラッシュコマンド、Plan モード、マルチエージェント協調、メモリ管理、Steer モード、パーソナリティ設定について回答。Use when user asks about Codex CLI, codex command, approval mode, sandbox, AGENTS.md, codex configuration, /model, /review, /compact, /plan, /personality, apply_patch, reasoning level, multi-agent, or memory management. Also use when user says Codex CLI について, codex の使い方, 承認モード, 推論レベル.
context: fork
---

# Codex CLI Knowledge

OpenAI Codex CLI の仕様と使い方に関する包括的な知識を提供するスキル。

**最新バージョン**: v0.104.0（2026-02-18）

## 概要

OpenAI Codex CLI は、ターミナル上で動作する軽量なコーディングエージェント。ChatGPT レベルの推論能力に加え、コードの実行、ファイル操作、依存関係のインストールなどを自動で行う機能を備える。

| 項目 | 内容 |
|------|------|
| 正式名称 | OpenAI Codex CLI |
| npm パッケージ名 | `@openai/codex` |
| GitHub リポジトリ | https://github.com/openai/codex |
| ライセンス | Apache-2.0 |
| 開発言語 | Rust |

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

### その他のパッケージマネージャー

```bash
# yarn
yarn global add @openai/codex

# pnpm
pnpm add -g @openai/codex

# bun
bun install -g @openai/codex
```

### システム要件

| 要件 | 詳細 |
|------|------|
| OS | macOS 12+、Ubuntu 20.04+/Debian 10+、Windows 11（WSL2 経由） |
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

### codex app コマンド（macOS Desktop）

```bash
codex app
```

macOS デスクトップアプリを起動。

---

## 利用可能なモデル

**注意**: `gpt-5.3-codex` のみを使用すること。他のモデルは利用価値なし。

| モデル | 用途 | 推論レベル |
|--------|------|------------|
| `gpt-5.3-codex` | コーディング専用（デフォルト・唯一推奨） | low, medium, high, xhigh |

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
| 通常のコーディング | `gpt-5.3-codex` | medium |
| 設計・方針検討・評価 | `gpt-5.3-codex` | high |
| 最高の思考が必要な場合 | `gpt-5.3-codex` | xhigh |
| 簡単な修正・フォーマット | `gpt-5.3-codex` | low |

### モデル変更方法

```bash
# コマンドラインで指定
codex --model gpt-5.3-codex "タスクを実行"

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

### 動作

1. Plan モードで計画を策定
2. ユーザーが承認
3. Act モードで実行

---

## マルチエージェント協調（v0.90.0+）

### 概要

複数のサブエージェントを並列で起動し、複雑なタスクを分割処理する機能。

### 設定

| パラメータ | デフォルト | 説明 |
|-----------|-----------|------|
| Sub-agent 最大数 | 6 | 同時に実行可能なサブエージェントの数 |
| Max-depth | 3 | サブエージェントのネスト深度制限 |

### Explorer ロール

- 読み取り専用のサブエージェント
- コードベースの探索・調査に特化
- ファイルの変更権限なし

### カスタマイズ可能なロール設定（v0.102.0）

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

**注意**: 旧 `get_memory` ツールは削除済み。スラッシュコマンドに移行。

---

## パーソナリティ設定（v0.94.0 Stable）

### 概要

Codex CLI の応答スタイルをカスタマイズ。

### デフォルト: Pragmatic（v0.98.0）

v0.98.0 以降、デフォルトパーソナリティが `Pragmatic` に変更。

### 設定方法

```
/personality
```

利用可能なパーソナリティを選択。

---

## Steer モード（v0.98.0 Stable）

### 概要

タスク実行中の入力方法を変更するモード。

### 動作

- **Enter**: 即送信（従来の Tab+Enter から変更）
- **Tab**: フォローアップキューに追加（複数の指示を蓄積）

### 破壊的変更

v0.98.0 以前は Enter でフォローアップキュー、Tab+Enter で送信だったが、動作が逆転。

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
| `view_image` | 画像表示 | 画像ファイルを表示 |

### シェル・実行ツール

| ツール | 機能 | 説明 |
|--------|------|------|
| `shell` | シェル実行 | 任意のシェルコマンドを実行 |
| `unified_exec` | 統合実行 | 統合実行環境 |

### JavaScript REPL（v0.100.0、実験的）

| ツール | 機能 | 説明 |
|--------|------|------|
| `js_repl` | JavaScript 実行 | ツールコール間で状態を保持する REPL |

- `js_repl` はツールコール間で状態（変数、関数定義等）を保持
- 計算、データ変換、プロトタイピングに有用

### 計画・連携ツール

| ツール | 機能 | 説明 |
|--------|------|------|
| `plan` | 計画立案 | タスクの計画を作成 |
| `mcp` | MCP 連携 | Model Context Protocol サーバーと連携 |
| `mcp_resource` | MCP リソース | MCP リソースにアクセス |

### ツール使用のベストプラクティス

- **単一ファイル編集**: `apply_patch` を使用（差分形式で安全）
- **ファイル検索**: `grep_files` + `rg`（ripgrep）を優先
- **複数ファイル変更**: シェルスクリプトを活用

---

## スラッシュコマンド

インタラクティブモードで使用可能なコマンド:

### モデル・設定

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/model` | モデルと推論レベルを選択 | 不可 |
| `/approvals` | 承認なしで実行可能な操作を設定 | 不可 |
| `/permissions` | 権限設定を管理 | 不可 |
| `/setup-elevated-sandbox` | 昇格サンドボックスをセットアップ | 不可 |
| `/experimental` | ベータ機能のトグル | 不可 |
| `/debug-config` | デバッグ設定を表示 | 不可 |
| `/statusline` | ステータスラインの表示設定 | 不可 |

### セッション管理

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/new` | 新しいチャットを開始 | 不可 |
| `/resume` | 保存されたチャットを再開 | 不可 |
| `/compact` | 会話を要約（コンテキスト制限対策） | 不可 |
| `/status` | セッション設定とトークン使用量を表示 | 可 |

### 計画・開発支援

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/plan` | Plan モードに切り替え | 不可 |
| `/review` | 現在の変更をレビューして問題を発見 | 不可 |
| `/diff` | git diff を表示（未追跡ファイル含む） | 可 |
| `/mention` | ファイルをメンション | 可 |
| `/init` | AGENTS.md ファイルを作成 | 不可 |
| `/skills` | スキル管理（タスク実行の改善） | 可 |
| `/skill` | 個別スキルを管理 | 可 |
| `/apps` | Codex Apps を管理 | 不可 |

### メモリ・パーソナリティ

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/m_update` | メモリに情報を追加・更新 | 不可 |
| `/m_drop` | メモリから情報を削除 | 不可 |
| `/personality` | パーソナリティを選択 | 不可 |
| `/grant-read-access` | ファイル・ディレクトリの読み取り権限を付与 | 可 |

### ツール・その他

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/mcp` | 設定済み MCP ツールを一覧表示 | 可 |
| `/ps` | バックグラウンドターミナルを一覧表示 | 可 |
| `/feedback` | メンテナにログを送信 | 可 |
| `/logout` | Codex からログアウト | 不可 |
| `/quit`, `/exit` | Codex を終了 | 可 |

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

### Linux サンドボックス（Bubblewrap）

- `bwrap`（Bubblewrap）によるサンドボックス
- コンテナレスでの軽量隔離
- ファイルシステム・ネットワークの制限

### Windows サンドボックス

- WSL2 経由での実行
- Windows Sandbox との連携

### ネットワークサンドボックス

| 設定 | 説明 |
|------|------|
| `restricted` | 承認が必要 |
| `enabled` | 承認不要 |

### SOCKS5 プロキシ

```bash
# 環境変数で設定
export WS_PROXY=socks5://localhost:1080
export WSS_PROXY=socks5://localhost:1080
```

### 構造化ネットワーク承認

- ドメイン単位でのネットワーク許可
- ポート・プロトコルの制限

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
~/.codex/config.toml  # メイン設定
~/.codex/config.yaml  # または YAML 形式
~/.codex/config.json  # または JSON 形式
```

### 基本設定パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|-----|-----------|------|
| `model` | string | `gpt-5.3-codex` | 使用するモデル |
| `approvalMode` | string | `suggest` | 承認モード |
| `fullAutoErrorMode` | string | `ask-user` | Full Auto 時のエラー処理 |
| `notify` | boolean | `true` | デスクトップ通知 |

### 設定例（YAML）

```yaml
model: gpt-5.3-codex
approvalMode: suggest
fullAutoErrorMode: ask-user
notify: true
```

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

| コマンド | 状態 | 用途 |
|---------|------|------|
| `codex` | Stable | インタラクティブターミナル UI |
| `codex exec` | Stable | 非インタラクティブなスクリプト実行 |
| `codex apply` | Stable | Codex Cloud の diff をローカルに適用 |
| `codex login` | Stable | OAuth または API キーで認証 |
| `codex app` | Stable | macOS デスクトップアプリを起動 |
| `codex mcp` | Experimental | MCP サーバーの管理 |

### 主要フラグ

| フラグ | 短縮形 | 説明 |
|--------|--------|------|
| `--model` | `-m` | 使用するモデルを指定 |
| `--ask-for-approval` | `-a` | 承認ポリシーを指定（untrusted/on-request/never） |
| `--sandbox` | `-s` | サンドボックスモード（read-only/workspace-write/danger-full-access） |
| `--full-auto` | - | Full Auto モードのショートカット |
| `--quiet` | `-q` | 静粛モード（CI 向け） |
| `--json` | - | JSON 形式で出力 |
| `--no-project-doc` | - | AGENTS.md の読み込みを無効化 |
| `--search` | - | Web 検索機能を有効化 |
| `--image` | `-i` | 画像ファイルを添付 |
| `--profile` | `-p` | 設定プロファイルを読み込み |
| `--cd` | `-C` | 作業ディレクトリを変更 |
| `--yolo` | - | 全保護を無効化（危険、非推奨） |

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

---

## よくある質問

### Q: モデルを変更するには？

```bash
codex --model gpt-5.3-codex "タスク"
```

または `/model` コマンドで選択。

### Q: 推論レベルを上げるには？

`/model` コマンドでモデルと推論レベルを選択。

### Q: Plan モードを使うには？

```
/plan
```

または `Shift+Tab` でサイクル切り替え。

### Q: メモリを管理するには？

```
/m_update   # 追加・更新
/m_drop     # 削除
```

### Q: CI/CD で使用するには？

```bash
codex -q --json "タスク"
```

### Q: コンテキストが長くなりすぎたら？

`/compact` コマンドで会話を要約。

### Q: ファイルを安全に編集するには？

`apply_patch` ツールが推奨（差分形式で編集）。
