# codex-cli-spec

OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## インストール

```bash
/plugin install codex-cli-spec@cc-plugins
```

## 概要

Codex CLI に関する質問に自動的に回答する知識プラグイン。モデル選択、承認モード、サンドボックス、設定方法、Plan モード、マルチエージェント協調、プラグインシステム、MCP 連携など、Codex CLI の全機能について詳しい情報を提供。

対応バージョン: Codex CLI v0.116.0

## 使い方

プラグインをインストールすると、Codex CLI に関する質問で自動的に知識が適用される。

### 発動例

- 「Codex CLI のインストール方法を教えて」
- 「codex の承認モードについて説明して」
- 「AGENTS.md の使い方を教えて」
- 「Plan モードの使い方は？」
- 「マルチエージェントの設定方法」
- 「メモリ管理について」
- 「MCP サーバーの設定方法」
- 「カスタムエージェントの定義方法」

## 提供される知識

### モデル

- 標準推奨モデル: `gpt-5.4`
- サブエージェント用: `gpt-5.4-mini`
- 推論レベル: low / medium / high / xhigh

### 承認モード

- **Suggest**（デフォルト） - 全ての書き込みとコマンド実行に承認が必要
- **Auto Edit** - ファイル書き込みは自動、コマンド実行に承認が必要
- **Full Auto** - `--full-auto` ショートカットでサンドボックス内で高速実行
- Smart Approvals デフォルト有効化（v0.93.0）
- 動的権限要求 `request_permissions`（v0.113.0+）

### マルチエージェント（v0.115.0 一般公開）

- プリセットエージェント（explorer, worker）
- カスタムエージェント（`~/.codex/agents/*.toml`）
- CSV ファンアウト、スレッドフォーク、Git Worktree 隔離
- TUI 個別承認

### プラグインシステム（v0.110.0+）

- スキル、MCP エントリ、アプリコネクタのロード
- `@plugin` メンションでチャット内参照

### MCP 連携

- config.toml での MCP サーバー定義
- `codex mcp-server` で Codex を MCP サーバー化
- 動的接続（v0.115.0+）

### フックエンジン（v0.114.0+）

- SessionStart, Stop, userpromptsubmit イベント
- プロンプト送信前のブロック/拡張

### Plan モード・コラボレーション

- **Plan モード**: 実装前に計画策定。`/plan` で切り替え
- **`/collab`**: Plan / Pair Programming / Execute の3モード選択

### 設定

- **config.toml**（推奨）: TOML 形式への移行
- **マルチプロファイル**: `--profile` でプロファイル切り替え
- 認証情報の分離保存（auth.json）

### サンドボックス

- macOS Seatbelt
- Linux Bubblewrap / Docker（v0.107.0+）/ AppArmor（v0.116.0+）
- Windows ネイティブサンドボックス（v0.115.0+）
- SOCKS5 プロキシ

### 音声機能

- 音声ディクテーション（スペースキー長押し、v0.105.0+）
- オーディオ制御（マイク/スピーカー選択、v0.107.0+）

### その他

- メモリ管理（差分ベース忘却、ワークスペーススコープ）
- Steer モード（Enter 即送信、Tab フォローアップキュー）
- パーソナリティ設定（Pragmatic / Friendly）
- 実験的コードモード（v0.114.0+）
- TUI テーマピッカー、App-Server アーキテクチャ
- デスクトップアプリ（macOS / Windows）

## 前提条件

このプラグインは知識提供のみ。Codex CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @openai/codex
```

## ライセンス

MIT
