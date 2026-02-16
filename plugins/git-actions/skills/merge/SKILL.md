---
name: git-merge
description: Git マージワークフローの実行。feature ブランチを main にマージしてプッシュする。Use when user wants to merge to main, integrate changes to main branch, or complete a feature branch.
allowed-tools: Bash, Read, Grep, Glob
---

# Git Merge スキル

## Instructions

このスキルは feature ブランチを main にマージしてプッシュする全ワークフローを提供します。

**重要**: git コマンドは作業ディレクトリで直接実行する。`git -C` は使用禁止。

### 実行フロー

#### 1. 事前確認（並列実行）

以下の git コマンドを**並列**で実行し、現在の状態を把握する:

```bash
git status                        # ワーキングツリーの状態
git branch --show-current         # カレントブランチ
git fetch origin main             # リモート main を最新化
git log main..HEAD --oneline      # マージ対象コミット一覧
```

#### 2. 安全性チェック

以下の条件を確認:

| チェック | 失敗時の動作 |
|---------|------------|
| ワーキングツリーがダーティ | エラー終了、コミット or stash を促す |
| カレントブランチが main | エラー終了、feature ブランチから実行を促す |
| マージ対象コミットがない | 警告表示、ユーザー確認を求める |
| コンフリクトの可能性 | 警告表示、ユーザー確認を求める |

##### コンフリクト可能性の事前チェック

```bash
# main との共通祖先を取得
git merge-base main HEAD

# 差分ファイル一覧
git diff --stat main...HEAD
```

#### 2.5. ユーザー確認（重要）

マージを実行する前に、必ず **AskUserQuestion ツール**を使用して以下を確認する:

- header: "マージ確認"
- question: "main ブランチへのマージとプッシュを実行してよろしいですか？"
- description: マージ対象ブランチ、マージ対象コミット数、変更ファイル数を含める
- options:
  - "はい、マージを実行": 処理を続行
  - "いいえ、中止する": 処理を中止

**確認が取れた場合のみ**、次のマージ実行フローに進む。
確認なしでの実行は禁止。

#### 3. マージ実行フロー

```bash
# 元のブランチを保存
FEATURE_BRANCH=$(git branch --show-current)

# main に切り替え（フック回避が必要）
GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1 git checkout main

# リモートから最新取得
git pull origin main

# feature ブランチをマージ（--no-ff でマージコミットを強制）
git merge $FEATURE_BRANCH --no-ff -m "$(cat <<'EOF'
Merge branch 'FEATURE_BRANCH' into main

## マージ内容
- <変更の要約をここに記述>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# main をプッシュ（フック回避が必要）
GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1 git push origin main
```

**重要**: 実際のコマンド実行時は `$FEATURE_BRANCH` を実際のブランチ名に置き換える。

#### 4. コンフリクト発生時の対応

マージ中にコンフリクトが発生した場合、`git-resolve-conflicts` スキルに従ってコンフリクト解消を実行する。

解消完了後:
1. `git status` で全てのコンフリクトが解消されたことを確認
2. マージコミットを作成し、セクション5（後処理）に進む

ユーザーが中止を選択した場合は `git merge --abort` を実行し、元の feature ブランチに戻る。

#### 5. 後処理

マージ成功後、以下を提案:

1. **元のブランチに戻る**
   ```bash
   git checkout $FEATURE_BRANCH
   ```

2. **feature ブランチの削除**（オプション）
   ```bash
   # ローカル削除
   git branch -d $FEATURE_BRANCH

   # リモート削除
   git push origin --delete $FEATURE_BRANCH
   ```

### 安全規則

#### 絶対禁止

- **main ブランチ上からこのスキルを実行すること**
- git config の更新
- `--force` オプション付きのマージ
- `--no-verify` オプション

#### 要確認

- コンフリクトが予想される場合のマージ継続
- feature ブランチの削除

### フック回避について

このスキルは main ブランチへのマージ・プッシュが目的のため、
`GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1` 環境変数を設定して
保護ブランチフックをバイパスする。

これは意図された動作であり、ユーザーが明示的にマージコマンドを
実行した場合のみ適用される。

## Examples

### 正常なマージフロー

```bash
# 1. 事前確認
$ git status
On branch feature/add-login
nothing to commit, working tree clean

$ git branch --show-current
feature/add-login

$ git fetch origin main
From github.com:user/repo
 * branch            main       -> FETCH_HEAD

$ git log main..HEAD --oneline
abc1234 feat: ログイン機能を追加
def5678 docs: READMEを更新

# 2. マージ実行
$ GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1 git checkout main
Switched to branch 'main'

$ git pull origin main
Already up to date.

$ git merge feature/add-login --no-ff -m "..."
Merge made by the 'ort' strategy.
 src/login.ts | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 README.md    |  5 +++++
 2 files changed, 55 insertions(+)
 create mode 100644 src/login.ts

$ GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1 git push origin main
To github.com:user/repo.git
   xyz9876..abc1234  main -> main

# 3. 後処理
$ git checkout feature/add-login
Switched to branch 'feature/add-login'
```

### コンフリクト発生時

```
⚠ マージ中にコンフリクトが発生しました。
git-resolve-conflicts スキルでコンフリクト解消を実行します。

[コンフリクト分析・解消案生成・ユーザー確認・適用の流れを実行]

✅ コンフリクト解消完了
マージコミットの作成に進みます。
```
