---
name: git-commit
description: Git コミットワークフローの実行。変更のステージング、コミットメッセージ生成、コミット実行を行う。Use when user wants to commit changes, create a commit, or stage and commit files.
allowed-tools: Bash, Read, Grep, Glob
---

# Git Commit スキル

## Instructions

このスキルは Git コミットの全ワークフローを提供します。

**重要**: git コマンドは作業ディレクトリで直接実行する。`git -C` は使用禁止。

### 実行フロー

#### 1. 状態確認（並列実行）

以下の git コマンドを**並列**で実行し、現在の状態を把握する:

```bash
git status              # 未追跡ファイルと変更状態
git branch --show-current  # カレントブランチ
git diff                # ステージされていない変更
git diff --staged       # ステージ済みの変更
git log --oneline -5    # 直近のコミットスタイル確認
```

#### 1.5. 保護ブランチ確認（最重要 - 必ず先に実行）

**git commit コマンドを実行する前に**、カレントブランチが **main** または **develop** かを確認する。

main/develop の場合、**先に AskUserQuestion ツールで確認を取得し、承認された場合のみ** git commit を実行する:

- header: "保護ブランチ"
- question: "main/develop ブランチへ直接コミットしようとしています。続行しますか？"
- options:
  - "はい、続行する": 環境変数 `GIT_ACTIONS_ALLOW_PROTECTED_BRANCH=1` を設定してコミット実行
  - "いいえ、中止する": 処理を中止し、feature ブランチの作成を提案

**確認が取れた場合のみ**、環境変数を設定してフックをバイパスする。
確認なしでの実行は禁止。

#### 2. 変更分析

ステージされた変更（または新規追加予定の変更）を分析:

- 変更の性質（new feature, enhancement, bug fix, refactoring, test, docs など）
- 変更の目的と理由
- 機密ファイルの有無を確認

**機密ファイル検出時は警告**:
- `.env`, `.env.*`
- `credentials.json`, `secrets.*`
- `*.pem`, `*.key`
- `config/local.*`

#### 3. コミットメッセージ生成

**原則: コミットメッセージは書けば書くほど良い。**

コミットメッセージは将来の開発者が「なぜこの変更が必要だったのか」を理解するための重要なドキュメント。

##### 必須セクション

1. **タイトル行**: 変更の要約（リポジトリの既存スタイルに準拠）

2. **背景・動機**: なぜこの変更が必要になったのか
   - ユーザーからの要望やフィードバック
   - バグ報告や Issue 番号
   - 技術的負債の解消理由
   - パフォーマンス問題の発見経緯

3. **実装内容**: 何を変更したか
   - 変更したファイルと役割
   - 追加・削除・修正した機能
   - 変更の性質（add = 新機能, update = 改善, fix = バグ修正, refactor = リファクタリング）

4. **設計判断の理由**: なぜこの実装方法を選んだのか
   - 検討した代替案があれば記載
   - 参照したドキュメント、仕様書、既存コード
   - 採用した設計パターンとその理由
   - トレードオフの考慮点

5. **参照情報**（該当する場合）:
   - 関連する Issue/PR 番号
   - 参照したドキュメントの URL やパス
   - 依存する他のコミットや機能
   - 参考にした既存実装のパス

##### 情報が不明な場合

実装内容から推測できる事情を記載する:
- コードの構造から読み取れる設計意図
- 命名規則やパターンから推測される方針
- 既存コードとの一貫性を保つための判断

#### 4. ステージングとコミット実行

```bash
# 関連ファイルをステージング（必要な場合）
git add <files>

# HEREDOC形式でコミット実行
git commit -m "$(cat <<'EOF'
タイトル: 変更の要約

## 背景
- なぜこの変更が必要になったか

## 実装内容
- 変更したファイルと内容

## 設計判断
- なぜこの方法を選んだか

## 参照
- 関連ドキュメントや Issue

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

#### 5. 結果確認

コミット後、`git status` で成功を確認する。

### 安全規則

- pre-commit hook でコミットが失敗した場合は、問題を修正して**新しいコミット**を作成する（--amend は使用しない）
- コミットが成功したが hook がファイルを自動修正した場合のみ、--amend を検討可能
- プッシュ済みのコミットは --amend しない
- git config の更新は禁止
- `--no-verify`, `--no-gpg-sign` などのスキップオプションは禁止

### 動詞の使い分け

- `add`: 完全に新しい機能
- `update`: 既存機能の改善
- `fix`: バグ修正
- `refactor`: 機能変更なしのコード改善
- `docs`: ドキュメントのみの変更
- `test`: テストのみの変更

## Examples

### 良いコミットメッセージ

```
ユーザー認証のセッションタイムアウトを30分から1時間に延長

## 背景
ユーザーから「作業中に頻繁にログアウトされる」というフィードバックが
複数寄せられていた（Issue #234, #256）。特にドキュメント編集中の
セッション切れが問題視されていた。

## 実装内容
- src/config/auth.ts: SESSION_TIMEOUT を 1800 から 3600 に変更
- src/middleware/session.ts: タイムアウト警告を残り5分で表示するよう追加
- tests/auth.test.ts: 新しいタイムアウト値に対応したテストケース追加

## 設計判断
- 2時間案も検討したが、セキュリティチームとの協議の結果、
  セキュリティとUXのバランスから1時間が適切と判断
- 無期限セッションは PCI DSS 準拠の観点から却下
- 参照: docs/security-policy.md のセッション管理方針

## 参照
- Issue: #234, #256
- セキュリティレビュー: SEC-2024-001
- 参考実装: src/features/admin/session.ts（管理者セッション処理）

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 悪いコミットメッセージ

```
fix bug
```

```
update files
```

```
セッションタイムアウトを変更
```
（何を、なぜ変更したか不明）
