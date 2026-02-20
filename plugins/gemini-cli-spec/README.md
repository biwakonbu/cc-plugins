# gemini-cli-spec

Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは Gemini CLI に関する質問に対して自動的に発動し、以下の知識を提供します:

- 利用可能なモデルと選択基準
- スラッシュコマンドの一覧と使い方
- 組み込みツールの詳細
- CLI フラグとオプション
- 拡張機能システム
- フックシステム
- サンドボックス機能
- MCP 管理者制御

対応バージョン: Gemini CLI v0.29.0

## インストール

```bash
/plugin install gemini-cli-spec@cc-plugins
```

## 使い方

プラグインをインストールすると、Gemini CLI に関する質問で自動的に知識が提供されます。

### 発動例

- 「Gemini CLI のモデルについて教えて」
- 「gemini で使えるコマンドは？」
- 「google_web_search の使い方」
- 「Gemini CLI の拡張機能について」
- 「サンドボックスの設定方法は？」
- 「フックの使い方」

### 提供される知識

#### モデル情報

| モデル | 特徴 |
|--------|------|
| `gemini-3.1-pro-preview` | **唯一の推奨モデル**。最新の推論能力 |

#### 主要コマンド

| コマンド | 説明 |
|----------|------|
| `/model` | モデル選択 |
| `/plan` | プランモード（v0.29.0+） |
| `/rewind` | 会話巻き戻し（v0.26.0+） |
| `/prompt-suggest` | プロンプト提案（v0.28.0+） |
| `/chat save/resume/list` | 会話管理 |
| `/settings` | 設定エディタ |
| `/tools` | ツール一覧 |
| `/memory` | GEMINI.md 管理 |

#### 組み込みツール

- ファイルシステム: `read_file`, `write_file`, `glob`, `replace`
- シェル: `run_shell_command`
- Web: `google_web_search`, `web_fetch`
- メモリ: `save_memory`

#### CLI フラグ

| フラグ | 説明 |
|--------|------|
| `--yolo` | 許可プロンプトをスキップ |
| `--model` | 起動時にモデル指定 |
| `-s`, `--sandbox` | サンドボックスモード指定 |

#### 新機能（v2.0.0 で追加）

- **フックシステム**: PreToolUse/PostToolUse イベント
- **サンドボックス強化**: Docker/Podman/Seatbelt/ポリシーエンジン
- **MCP 管理者制御**: 許可リスト、ツールフィルタリング
- **拡張機能マーケットプレイス**: 探索 UI
- **破壊的変更**: Node.js 20 必須、非対話モード ask_user 削除

## 前提条件

このプラグインは知識提供のみです。Gemini CLI を実際に使用するには別途インストールが必要です:

```bash
npm install -g @google/gemini-cli
```

または

```bash
brew install gemini-cli
```

## ライセンス

MIT
