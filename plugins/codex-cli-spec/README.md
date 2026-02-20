# codex-cli-spec

OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## インストール

```bash
/plugin install codex-cli-spec@cc-plugins
```

## 概要

Codex CLI に関する質問に自動的に回答する知識プラグイン。モデル選択、承認モード、サンドボックス、設定方法、Plan モード、マルチエージェント協調など、Codex CLI の全機能について詳しい情報を提供。

対応バージョン: Codex CLI v0.104.0

## 使い方

プラグインをインストールすると、Codex CLI に関する質問で自動的に知識が適用される。

### 発動例

- 「Codex CLI のインストール方法を教えて」
- 「codex の承認モードについて説明して」
- 「AGENTS.md の使い方を教えて」
- 「Plan モードの使い方は？」
- 「マルチエージェントの設定方法」
- 「メモリ管理について」

## 提供される知識

### モデル

- 唯一の推奨モデル: `gpt-5.3-codex`
- 推論レベル: low / medium / high / xhigh

### 承認モード

- **Suggest**（デフォルト） - 全ての書き込みとコマンド実行に承認が必要
- **Auto Edit** - ファイル書き込みは自動、コマンド実行に承認が必要
- **Full Auto** - `--full-auto` ショートカットでサンドボックス内で高速実行
- Smart Approvals デフォルト有効化（v0.93.0）

### 新機能（v2.0.0 で追加）

- **Plan モード**: 実装前に計画策定。`/plan` で切り替え
- **マルチエージェント協調**: Sub-agent 最大 6、Explorer ロール
- **メモリ管理**: `/m_update`、`/m_drop`、シークレットサニタイザー
- **JavaScript REPL**: `js_repl` ツール（実験的）
- **パーソナリティ設定**: `/personality` で応答スタイル変更
- **Steer モード**: Enter 即送信、Tab フォローアップキュー
- **認証**: ChatGPT プラン、Device-code auth、`codex app`

### サンドボックス

- macOS Seatbelt
- Linux Bubblewrap（bwrap）
- Windows サンドボックス
- SOCKS5 プロキシ

### プロジェクトドキュメント

- AGENTS.md の役割と配置場所
- Claude Code の CLAUDE.md との比較

### 設定

- 設定ファイル（config.yaml / config.json / config.toml）
- 環境変数
- プロファイル設定

### 主要フラグ

- `--model` - モデル指定
- `--ask-for-approval` - 承認モード指定
- `--sandbox` - サンドボックスモード
- `--full-auto` - Full Auto モード
- `--quiet` - 静粛モード

## 前提条件

このプラグインは知識提供のみ。Codex CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @openai/codex
```

## ライセンス

MIT
