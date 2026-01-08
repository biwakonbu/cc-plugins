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

## スキル

| スキル | 説明 |
|--------|------|
| `git-commit` | コミットワークフロー（状態確認、変更分析、メッセージ生成、実行） |
| `git-push` | プッシュワークフロー（安全性チェック、プッシュ実行） |
| `git-conventions` | 共通規則（安全規則、機密ファイル、禁止事項） |

## 使用例

```bash
# コミット & プッシュ
/git-actions:commit-push
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
- **保護ブランチ警告**: main/develop でのコミット/プッシュ時に確認
- **Force push 保護**: main/master/develop への force push を防止
- **--amend 制限**: 厳格な使用条件でのみ許可

### フック

| フック | 動作 |
|--------|------|
| `check-protected-branch.sh` | main/develop での git 操作を検出し確認要求 |

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
