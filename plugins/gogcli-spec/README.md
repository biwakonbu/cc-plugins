# gogcli-spec

Google Suite CLI (gogcli/gog) の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

[gogcli](https://github.com/steipete/gogcli) は Google のサービス群をターミナルから操作するための CLI ツール。このプラグインは gogcli に関する質問に対して自動発動し、包括的な知識を提供します。

## 対応サービス

Gmail, Calendar, Chat, Classroom, Drive, Docs, Slides, Sheets, Contacts, Tasks, People, Groups, Keep, Time

## 提供する知識

- インストール方法（Homebrew / ソースビルド）
- OAuth2 認証とマルチアカウント設定
- 全 14 サービスのコマンド体系
- JSON / plain / テーブル出力形式
- 環境変数と設定ファイル
- 典型的なワークフロー

## インストール

```bash
claude plugin install gogcli-spec@cc-plugins
```

## 前提条件

このプラグインは知識提供のみ。gogcli の実際の使用には別途バイナリが必要:

```bash
brew install steipete/tap/gogcli
```

## バージョン

- 2.0.0: steipete/gogcli (Google Suite CLI) の正しい情報で全面書き換え

## ライセンス

MIT
