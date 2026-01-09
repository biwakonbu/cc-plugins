# git-actions

Claude Code 用の Git ワークフロー管理プラグイン。commit と push 操作を Claude Code の規則に準拠した形で実行。

## インストール

```bash
claude plugin install git-actions@cc-plugins
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `/git-actions:commit-push` | コミット & プッシュを一括実行 |
| `/git-actions:merge-to-main` | カレントブランチを main にマージしてプッシュ |

## スキル

| スキル | 説明 |
|--------|------|
| `git-commit` | コミットワークフロー（状態確認、変更分析、メッセージ生成、実行） |
| `git-push` | プッシュワークフロー（安全性チェック、プッシュ実行） |
| `git-merge` | マージワークフロー（feature ブランチを main にマージ） |
| `git-conventions` | 共通規則（安全規則、機密ファイル、禁止事項） |

## 使用例

```bash
# コミット & プッシュ
/git-actions:commit-push

# main へマージ
/git-actions:merge-to-main
```

## 機能

### コミットメッセージ生成

変更内容を分析し、詳細なコミットメッセージを自動生成:

- タイトル行
- 背景・動機
- 実装内容
- 設計判断の理由
- 参照情報

### 安全機能

- **機密ファイルの自動検出**: `.env`, `credentials.json` などをコミットから除外
- **保護ブランチ確認**: main/develop でのコミット/プッシュ時に AskUserQuestion で確認を取得し、承認後に実行
- **Force push 保護**: main/master/develop への force push を防止
- **--amend 制限**: 厳格な使用条件でのみ許可

### 保護ブランチの動作

main/develop ブランチで commit/push を実行する場合:

1. AskUserQuestion でユーザー確認を取得
2. 「はい、続行する」選択時 → 環境変数を設定して実行を許可
3. 「いいえ、中止する」選択時 → feature ブランチの作成を提案

### フック

| フック | 動作 |
|--------|------|
| `check-protected-branch.sh` | main/develop での git 操作を検出し、AskUserQuestion での確認を誘導 |

## アーキテクチャ

```
/git-actions:commit-push
    │
    ├─→ git-commit スキル
    │     ├─→ 状態確認、変更分析
    │     ├─→ コミットメッセージ生成
    │     └─→ git-conventions (共通規則)
    │
    └─→ git-push スキル
          ├─→ 安全性チェック、プッシュ実行
          └─→ git-conventions (共通規則)
```

## ライセンス

MIT
