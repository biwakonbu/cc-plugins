# gogcli-spec プラグイン

Google Suite CLI (gogcli/gog) の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは gogcli に関する質問に対して自動発動し、以下の知識を提供する:

- インストール方法（Homebrew / ソースビルド）
- OAuth2 認証とマルチアカウント設定
- Gmail 操作（検索、送信、ラベル、フィルタ、委任、Watch）
- Calendar 操作（イベント CRUD、空き状況、チーム、招待）
- Drive 操作（ファイル管理、アップロード、ダウンロード、権限）
- Contacts / Tasks / Sheets / Docs / Slides 操作
- Chat / Classroom / People / Groups / Keep 操作
- JSON / plain / テーブル出力形式
- 環境変数と設定ファイル

## ディレクトリ構造

```
gogcli-spec/
├── .claude-plugin/
│   └── plugin.json           # メタデータ
├── CLAUDE.md                 # 本ファイル
└── skills/
    └── gogcli-knowledge/
        └── SKILL.md          # gogcli 仕様知識
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `gogcli-knowledge` | gogcli の仕様に関する質問で自動発動 |

## 設計方針

### シンプルさ優先

- 知識スキルのみで構成
- コマンドやエージェントは含めない
- 軽量で高速な発動

### 自動発動トリガー

以下のキーワードで発動:

- 「gogcli」「gog」「Google CLI」
- Gmail 関連（`gog gmail`, メール検索、メール送信）
- Calendar 関連（`gog calendar`, イベント作成、空き状況）
- Drive 関連（`gog drive`, ファイルアップロード、ダウンロード）
- Contacts / Tasks / Sheets / Docs 関連
- Chat / Classroom / People / Groups / Keep 関連
- 認証関連（`gog auth`, OAuth2, サービスアカウント）

## 前提条件

このプラグインは知識提供のみ。gogcli の実際の使用には別途バイナリが必要:

- Homebrew: `brew install steipete/tap/gogcli`
- GitHub リリースページ: https://github.com/steipete/gogcli/releases
- またはソースからビルド: `git clone && cd gogcli && make`

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- CLAUDE.md: 設計方針と内部構造、バージョン更新内容
- plugin.json: バージョン番号

## v2.0.0

- steipete/gogcli (Google Suite CLI) の正しい情報に全面書き換え
- 旧情報（Magnitus-/gogcli, GOG.com CLI）を完全に除去
