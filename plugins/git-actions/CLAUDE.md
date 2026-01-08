# git-actions プラグイン

Claude Code 用の Git ワークフロー管理プラグイン。

## 概要

commit、push、merge 操作を Claude Code の規則に準拠した形で実行するためのプラグイン。
**スキルに全ての知識を集約**し、コマンドはスキルを参照する設計。

## ディレクトリ構造

```
git-actions/
├── .claude-plugin/
│   └── plugin.json           # プラグインメタデータ
├── commands/
│   ├── commit-push.md        # コミット & プッシュコマンド
│   └── merge-to-main.md      # main へマージ & プッシュコマンド
├── hooks/
│   ├── hooks.json            # フック定義
│   ├── check-protected-branch.sh  # 保護ブランチチェック
│   └── confirm-protected-branch.md  # 確認プロンプト
├── skills/
│   ├── commit/SKILL.md       # git-commit スキル
│   ├── push/SKILL.md         # git-push スキル
│   ├── merge/SKILL.md        # git-merge スキル
│   └── git-conventions/SKILL.md  # 共通規則スキル
└── CLAUDE.md
```

## コマンド

| コマンド | 説明 | 参照スキル |
|---------|------|-----------|
| `/git-actions:commit-push` | コミット & プッシュ実行 | `git-commit`, `git-push` |
| `/git-actions:merge-to-main` | main へマージ & プッシュ実行 | `git-merge` |

## スキル

| スキル名 | ディレクトリ | 役割 |
|----------|-------------|------|
| `git-commit` | skills/commit/ | 状態確認、変更分析、メッセージ生成、実行 |
| `git-push` | skills/push/ | 安全性チェック、プッシュ実行 |
| `git-merge` | skills/merge/ | feature ブランチを main にマージ & プッシュ |
| `git-conventions` | skills/git-conventions/ | 安全規則、機密ファイル、禁止事項 |

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

/git-actions:merge-to-main
    │
    └─→ git-merge スキル
          ├─→ 事前確認（状態チェック、コンフリクト検出）
          ├─→ main へチェックアウト、pull、マージ、プッシュ
          └─→ git-conventions (共通規則)
```

## 設計方針

### スキル中心設計

- **知識の集約**: 全ての知識はスキルに集約
- **コマンドは薄い**: コマンドはスキルを参照するだけ
- **再利用性**: スキルは他のプラグインやエージェントからも利用可能

### コミットメッセージ原則

**コミットメッセージは書けば書くほど良い。**

必須セクション:
1. タイトル行
2. 背景・動機
3. 実装内容
4. 設計判断の理由
5. 参照情報

### 正しい git の使い方

**すべての git コマンドは作業ディレクトリで直接実行する。**

```bash
# ✅ 正しい
git status
git commit -m "message"

# ❌ 禁止
git -C /path/to/repo status
```

### 安全性

- **`git -C` オプション使用禁止**（作業ディレクトリで直接実行）
- 機密ファイルの自動検出と警告
- **main/develop ブランチでの commit/push はフックでブロック**
- main/master/develop への force push は絶対禁止
- force push の明示的確認
- --amend の厳格な使用条件

### フック

| フック | トリガー | 動作 |
|--------|---------|------|
| `check-protected-branch.sh` | PreToolUse (Bash) | main/develop での git commit/push を検出しブロック |
| prompt フック | PreToolUse (Bash) | CONFIRM_REQUIRED 検出時にユーザーに確認を求める |

### 環境変数

| 変数 | 説明 |
|------|------|
| `GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1` | main/develop ブランチへの直コミット・プッシュブロックを回避 |

使用例:
```bash
# 一時的に回避
GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1 claude

# シェル設定に追加（永続）
export GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1
```

### 効率性

- 読み取り系コマンドの並列実行
- HEREDOC 形式による複数行コミットメッセージ
