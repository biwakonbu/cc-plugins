---
name: codex-cli-knowledge
description: OpenAI Codex CLI の仕様と使い方に関する知識を提供。モデル選択、推論レベル、承認モード、サンドボックス、組み込みツール、スラッシュコマンド、設定方法について回答。Use when user asks about Codex CLI, codex command, approval mode, sandbox, AGENTS.md, codex configuration, /model, /review, /compact, apply_patch, or reasoning level. Also use when user says Codex CLI について, codex の使い方, 承認モード, 推論レベル.
context: fork
---

# Codex CLI Knowledge

OpenAI Codex CLI の仕様と使い方に関する包括的な知識を提供するスキル。

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

## 利用可能なモデル

**注意**: モデル名は頻繁に更新されます。最新のモデル一覧は `/model` コマンドで確認してください。

| モデル | 用途 | 推論レベル |
|--------|------|------------|
| `gpt-5.3-codex` | コーディング専用（デフォルト） | low, medium, high, xhigh |

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

### サポートされるプロバイダー

Codex CLI は OpenAI Chat Completions API 互換の複数のプロバイダーをサポート:

| プロバイダー | 設定値 |
|-------------|--------|
| OpenAI（デフォルト） | `openai` |
| OpenRouter | `openrouter` |
| Azure | `azure` |
| Gemini | `gemini` |
| Ollama | `ollama` |
| Mistral | `mistral` |
| DeepSeek | `deepseek` |
| xAI | `xai` |
| Groq | `groq` |

### モデル変更方法

```bash
# コマンドラインで指定
codex --model gpt-5.3-codex "タスクを実行"

# インタラクティブモードで変更
/model
```

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
| `/setup-elevated-sandbox` | 昇格サンドボックスをセットアップ | 不可 |
| `/experimental` | ベータ機能のトグル | 不可 |

### セッション管理

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/new` | 新しいチャットを開始 | 不可 |
| `/resume` | 保存されたチャットを再開 | 不可 |
| `/compact` | 会話を要約（コンテキスト制限対策） | 不可 |
| `/status` | セッション設定とトークン使用量を表示 | 可 |

### 開発支援

| コマンド | 説明 | タスク中 |
|----------|------|----------|
| `/review` | 現在の変更をレビューして問題を発見 | 不可 |
| `/diff` | git diff を表示（未追跡ファイル含む） | 可 |
| `/mention` | ファイルをメンション | 可 |
| `/init` | AGENTS.md ファイルを作成 | 不可 |
| `/skills` | スキル管理（タスク実行の改善） | 可 |

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
| `on-failure` | エラー発生時のみ承認要求 | バランス型 |
| `on-request` | 不確実な場合のみ承認要求 | 自動化向け |
| `never` | 承認なしで実行 | CI/CD、スクリプト向け |

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
codex -a on-failure "タスク"

# Full Auto モード（ショートカット）
codex --full-auto "タスク"
# 上記は以下と同等:
# codex --ask-for-approval on-request --sandbox workspace-write "タスク"
```

---

## サンドボックス機能

### サンドボックスモード

| モード | 説明 |
|--------|------|
| `read-only` | 読み取りのみ許可 |
| `workspace-write` | ワークスペース内の書き込み許可 |
| `danger-full-access` | 全アクセス許可（注意） |

### ネットワークアクセス

| 設定 | 説明 |
|------|------|
| `restricted` | 承認が必要 |
| `enabled` | 承認不要 |

### 承認ポリシー

| ポリシー | 説明 |
|----------|------|
| `untrusted` | ほとんどのコマンドで承認要求 |
| `on-failure` | サンドボックス失敗時のみ承認要求 |
| `on-request` | 明示的に要求時のみ承認要求 |
| `never` | 非インタラクティブモード（承認なし） |

### macOS サンドボックス

- Apple Seatbelt（`sandbox-exec`）でラップ
- 読み取り専用ジェイルで実行
- `$PWD`、`$TMPDIR`、`~/.codex` のみ書き込み可能
- ネットワークは完全ブロック

### Linux サンドボックス

- Docker によるサンドボックス推奨
- `iptables`/`ipset` ファイアウォールで OpenAI API 以外の通信をブロック

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

### カスタムプロバイダー設定

```yaml
model: gpt-5.3-codex
provider: openai
providers:
  openai:
    name: OpenAI
    baseURL: https://api.openai.com/v1
    envKey: OPENAI_API_KEY
  ollama:
    name: Ollama
    baseURL: http://localhost:11434/v1
    envKey: OLLAMA_API_KEY
```

### 環境変数

| 変数 | 説明 |
|------|------|
| `OPENAI_API_KEY` | OpenAI API キー |
| `DEBUG` | デバッグモード有効化 |
| `CODEX_QUIET_MODE` | 静粛モード（CI 向け） |
| `CODEX_DISABLE_PROJECT_DOC` | AGENTS.md の読み込み無効化 |

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
| `codex mcp` | Experimental | MCP サーバーの管理 |

#### exec サブコマンドのオプション

| オプション | 説明 |
|-----------|------|
| `--json` | JSON イベントを改行区切りで出力 |
| `--output-last-message, -o` | 最終レスポンスをファイルに書き込み |
| `--skip-git-repo-check` | 非 Git ディレクトリでの実行を許可 |
| `--output-schema` | JSON Schema でレスポンスを検証 |

### 主要フラグ

| フラグ | 短縮形 | 説明 |
|--------|--------|------|
| `--model` | `-m` | 使用するモデルを指定 |
| `--ask-for-approval` | `-a` | 承認ポリシーを指定（untrusted/on-failure/on-request/never） |
| `--sandbox` | `-s` | サンドボックスモード（read-only/workspace-write/danger-full-access） |
| `--full-auto` | - | Full Auto モードのショートカット |
| `--quiet` | `-q` | 静粛モード（CI 向け） |
| `--json` | - | JSON 形式で出力 |
| `--provider` | - | AI プロバイダーを指定 |
| `--no-project-doc` | - | AGENTS.md の読み込みを無効化 |

### 追加フラグ

| フラグ | 短縮形 | 説明 |
|--------|--------|------|
| `--search` | - | Web 検索機能を有効化 |
| `--oss` | - | ローカル OSS モデルを使用（Ollama 必須） |
| `--image` | `-i` | 画像ファイルを添付（カンマ区切りまたは複数指定） |
| `--profile` | `-p` | 設定プロファイルを読み込み（~/.codex/config.toml） |
| `--cd` | `-C` | 作業ディレクトリを変更 |
| `--config` | `-c` | 設定値をオーバーライド（key=value 形式） |
| `--notify` | - | デスクトップ通知を有効化 |
| `--yolo` | - | 全保護を無効化（危険、非推奨） |

---

## Git 操作の安全性

Codex CLI は Git 操作において安全性を重視:

**絶対に自動実行しない操作:**
- `git reset --hard`
- `git checkout --`（変更の破棄）
- 既存の変更の勝手なリバート

**条件付きで実行:**
- `git commit --amend` - 明示的に要求された場合のみ

---

## よくある質問

### Q: モデルを変更するには？

```bash
codex --model gpt-5.3-codex "タスク"
```

または `/model` コマンドで選択。

### Q: 推論レベルを上げるには？

`/model` コマンドでモデルと推論レベルを選択。

### Q: 承認モードを変更するには？

```bash
codex --approval-mode auto-edit "タスク"
```

### Q: 他のプロバイダー（Ollama など）を使うには？

```bash
codex --provider ollama --model llama3 "タスク"
```

### Q: CI/CD で使用するには？

```bash
codex -q --json "タスク"
```

### Q: コンテキストが長くなりすぎたら？

`/compact` コマンドで会話を要約。

### Q: ファイルを安全に編集するには？

`apply_patch` ツールが推奨（差分形式で編集）。
