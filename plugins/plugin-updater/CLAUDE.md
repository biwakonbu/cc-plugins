# plugin-updater プラグイン

マーケットプレイスとインストール済みプラグインを一括更新するユーティリティプラグイン。

## 概要

Claude Code のプラグインエコシステムを最新状態に保つためのメンテナンスプラグイン。
単一コマンドで全てのマーケットプレイスとプラグインを更新。

## ディレクトリ構造

```
plugin-updater/
├── .claude-plugin/
│   └── plugin.json           # プラグインメタデータ
├── commands/
│   └── update-all.md         # 全更新コマンド
├── CLAUDE.md                 # このファイル
└── README.md                 # ユーザー向けドキュメント
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `/plugin-updater:update-all` | 全マーケットプレイス + 全プラグイン更新 |

## アーキテクチャ

```
/plugin-updater:update-all
    │
    ├─→ マーケットプレイス更新
    │     └─→ claude plugin marketplace update
    │
    └─→ プラグイン更新（スコープ別）
          ├─→ User: ~/.claude/settings.json
          ├─→ Project: .claude/settings.json
          └─→ Local: .claude/settings.local.json
```

## 設計方針

### シンプル設計

- command のみで完結（skill/agent 不要）
- 外部スクリプト不要（コマンド内で完結）
- haiku モデルを使用（定型的なコマンド実行と結果報告に最適）

### 堅牢性

- 各更新は独立して実行（1つの失敗が全体に影響しない）
- 存在しないファイルはスキップ
- エラーは記録して続行

### 情報表示

- 処理前に対象を表示
- 処理中に進捗を表示
- 処理後にサマリーを表示

## 依存コマンド

- `claude plugin marketplace update`
- `claude plugin update`
- `jq` (オプション、なければ grep で代替)

## ドキュメント維持規則

README.md と CLAUDE.md は常に最新状態を維持すること。

### 更新タイミング

- コマンドの追加・変更・削除
- plugin.json の変更（バージョン含む）
- 動作仕様の変更

## コマンド実装ガイドライン

### ユーザー確認（AskUserQuestion ツール使用）

**update-all コマンド:**
- 更新実行前に更新対象一覧を表示し、続行確認
- 更新に失敗したプラグインがある場合の対応選択（リトライ/スキップ）
