# claude-code-spec

Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## インストール

```bash
/plugin install claude-code-spec@cc-plugins
```

## 概要

Claude Code の公式機能について質問すると、自動的にこのプラグインが発動し、正確な仕様情報を提供します。

対応バージョン: Claude Code v2.1.49

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

# 新機能
エージェントチームの使い方は?
Git Worktree の設定方法は?
セッションテレポートとは?
```

## 提供される知識

### モデル

- **Opus 4.6**（デフォルト）: 最高性能。`claude-opus-4-6`
- **Sonnet 4.6**: 高速・コスト効率。`claude-sonnet-4-6`

### プラグイン・開発

- **プラグイン構造**: plugin.json、ディレクトリ構成、settings.json 同梱（v2.1.49+）
- **スラッシュコマンド**: フロントマター、動的コンテキスト、スキル統合（v2.1.3+）
- **サブエージェント**: tools、model（sonnet 推奨）、background、memory
- **スキル**: フォークコンテキスト、ホットリロード、user-invocable

### 新機能（v2.0.0 で追加）

- **エージェントチーム**（実験的）: チームリーダー、共有タスクリスト、tmux バックエンド
- **バックグラウンドエージェント強化**: `background: true`、Ctrl+F 終了
- **Git Worktree サポート**: `--worktree` フラグ、サブエージェント分離
- **セッションテレポート**: `/desktop`、claude.ai/code 継続、iOS 委任
- **自動メモリ**: エージェント `memory` フィールド
- **タスク管理システム**: 依存関係追跡
- **PR レビュー状況**: `--from-pr` フラグ

### インフラ

- **フック**: イベント、マッチャー、環境変数、JSON出力、once、新イベント追加
- **LSPサーバー**: 設定、言語サーバー
- **権限設定**: ワイルドカード、MCP、エージェント無効化、Permission Hook
- **MCP**: 管理コマンド、Tool Search Auto、claude.ai コネクタ、OAuth
- **Plan モード**: ファイル保存、コンテキストリセット

### その他

- **Vim モーション**: キーバインド
- **名前付きセッション**: /rename（自動生成対応）、/resume
- **Claude in Chrome**: ブラウザ統合
- **環境変数**: 設定オプション
- **マーケットプレイス**: プラグイン配布

## 前提条件

Claude Code がインストールされていること:

```bash
npm install -g @anthropic/claude-code
```

## ライセンス

MIT
