# gemini-cli-spec

Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは Gemini CLI に関する質問に対して自動的に発動し、以下の知識を提供します:

- 利用可能なモデルと選択基準
- スラッシュコマンドの一覧と使い方
- 組み込みツールの詳細
- CLI フラグとオプション
- 拡張機能システム

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

### 提供される知識

#### モデル情報

| モデル | 特徴 |
|--------|------|
| Auto (Gemini 3/2.5) | 推奨。システムが最適なモデルを自動選択 |
| gemini-3-pro-preview | 高度な推論・複雑なタスク向け |
| gemini-3-flash-preview | 高速処理・シンプルなタスク向け |
| gemini-2.5-pro/flash | 安定版 |

#### 主要コマンド

| コマンド | 説明 |
|----------|------|
| `/model` | モデル選択 |
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
