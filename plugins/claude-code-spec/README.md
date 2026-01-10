# claude-code-spec

Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## インストール

```bash
/plugin install claude-code-spec@cc-plugins
```

## 概要

Claude Code の公式機能について質問すると、自動的にこのプラグインが発動し、正確な仕様情報を提供します。

対応バージョン: Claude Code v2.1.3（2026年1月時点）

## 使い方

以下のような質問をすると自動的に発動します:

```
# プラグイン開発
Claude Code のプラグイン構造について教えて
plugin.json の書き方は?

# スキル定義
スキルの作り方を教えて
user-invocable オプションとは?

# フック設定
フックの設定方法は?
once オプションの使い方は?

# 権限設定
ワイルドカード権限の設定方法は?
MCP ツールを一括許可するには?

# その他
LSP の有効化方法は?
Vim モーションの使い方は?
Plan モードとは?
```

## 提供される知識

- **プラグイン構造**: plugin.json、ディレクトリ構成
- **スラッシュコマンド**: フロントマター、動的コンテキスト、スキル統合（v2.1.3+）
- **サブエージェント**: tools、model、permissionMode、hooks
- **スキル**: フォークコンテキスト、ホットリロード、user-invocable
- **フック**: イベント、マッチャー、環境変数、JSON出力、once オプション
- **LSPサーバー**: 設定、言語サーバー
- **言語設定**: /config、リリースチャンネル
- **Rules フォルダ**: パスベースルール
- **権限設定**: ワイルドカード、MCP、エージェント無効化
- **MCP**: 管理コマンド、list_changed
- **Vim モーション**: キーバインド
- **名前付きセッション**: /rename、/resume
- **Claude in Chrome**: ブラウザ統合
- **Plan モード**: 計画策定
- **バックグラウンドエージェント**: 並列処理
- **環境変数**: 設定オプション
- **マーケットプレイス**: プラグイン配布

## 前提条件

Claude Code がインストールされていること:

```bash
npm install -g @anthropic/claude-code
```

## ライセンス

MIT
