# codex-cli-spec

OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## インストール

```bash
/plugin install codex-cli-spec@cc-plugins
```

## 概要

Codex CLI に関する質問に自動的に回答する知識プラグイン。モデル選択、承認モード、サンドボックス、設定方法など、Codex CLI の全機能について詳しい情報を提供。

## 使い方

プラグインをインストールすると、Codex CLI に関する質問で自動的に知識が適用される。

### 発動例

- 「Codex CLI のインストール方法を教えて」
- 「codex の承認モードについて説明して」
- 「AGENTS.md の使い方を教えて」
- 「Codex で Ollama を使う方法は？」

## 提供される知識

### モデル

- デフォルトモデル（o4-mini）
- サポートされるプロバイダー（OpenAI、Ollama、Azure など）
- モデル選択とプロバイダー設定

### 承認モード

- **Suggest**（デフォルト、`--ask-for-approval untrusted`） - 全ての書き込みとコマンド実行に承認が必要
- **Auto Edit** - ファイル書き込みは自動、コマンド実行に承認が必要
- **Full Auto** - `--full-auto` ショートカットでサンドボックス内で高速実行

詳細は SKILL.md の「承認ポリシー」セクションを参照。

### サンドボックス

- macOS のサンドボックス機能（Seatbelt）
- Linux のサンドボックス推奨設定

### プロジェクトドキュメント

- AGENTS.md の役割と配置場所
- Claude Code の CLAUDE.md との比較

### 設定

- 設定ファイル（config.yaml / config.json）
- 環境変数
- カスタムプロバイダー設定

### 主要フラグ

- `--model` - モデル指定
- `--approval-mode` - 承認モード指定
- `--provider` - プロバイダー指定
- `--quiet` - 静粛モード

## 前提条件

このプラグインは知識提供のみ。Codex CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @openai/codex
```

## ライセンス

MIT
