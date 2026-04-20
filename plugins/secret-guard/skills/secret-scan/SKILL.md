---
name: secret-scan
description: Use when user wants to check secret protection, audit gitignore, scan for exposed secrets, or check security status. プロジェクトのシークレット保護状況をスキャン・監査し、.gitignore の漏れを検出し保護が必要なファイルを特定してレポートする。
allowed-tools: Bash, Read, Glob, Grep, Write, Edit, AskUserQuestion
---

# secret-scan

プロジェクト内のシークレットファイルをスキャンし、.gitignore の保護状況を監査する。

## Instructions

### Step 1: シークレットファイル候補の検出

以下のパターンに該当するファイルをプロジェクト内から検索する。

**ファイル名パターン:**
- `.env`, `.env.*`, `.env.local`, `.env.production`, `.env.staging`
- `credentials.json`, `credentials.yml`, `credentials.yaml`
- `secrets.json`, `secrets.yml`, `secrets.yaml`, `secrets.toml`
- `service-account*.json`, `serviceAccountKey*.json`
- `.netrc`, `.npmrc`
- `.docker/config.json`
- `token.json`, `tokens.json`, `auth.json`, `oauth*.json`
- `.htpasswd`, `.htaccess`, `wp-config.php`, `database.yml`

**拡張子パターン:**
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`, `*.keystore`
- `*.p8`, `*.gpg`, `*.asc`

**ディレクトリパターン:**
- `.ssh/`, `.gnupg/`, `.aws/`, `.gcloud/` 配下

検索には Glob と Bash (`find` 相当) を使用する。
`node_modules`, `.git`, `vendor`, `dist`, `build` は除外する。

### Step 2: .gitignore との突合せ

検出した各ファイルについて:

1. `.gitignore` を読み取る（存在しない場合は警告）
2. 各シークレットファイルが .gitignore でカバーされているか判定
3. 結果を以下のカテゴリに分類:
   - **保護済み**: .gitignore に登録されている
   - **未保護**: .gitignore に登録されていない（要対応）
   - **git追跡済み**: 既に git tracking されている（危険）

git tracking 状態の確認:
```bash
git ls-files --error-unmatch <filepath> 2>/dev/null
```

### Step 3: レポート出力

スキャン結果をユーザーに提示する。

フォーマット:
```
## secret-guard スキャン結果

### 検出されたシークレットファイル: N 件

#### 保護済み (gitignore 登録済み)
- .env (パターン: .env)
- credentials.json (パターン: credentials.json)

#### 未保護 (要対応)
- .env.local (gitignore に未登録)
- secrets.yaml (gitignore に未登録)

#### 警告: git 追跡済み (危険)
- config/database.yml (既にコミット済み)

### 推奨アクション
1. 未保護ファイルを .gitignore に追加
2. git 追跡済みファイルを git rm --cached で除外
```

### Step 4: .gitignore の修正提案

未保護のファイルが見つかった場合:

1. AskUserQuestion で .gitignore への追加をユーザーに確認
2. 承認された場合、.gitignore にパターンを追加
3. 追加時はコメント付きで、secret-guard セクションとしてまとめる:

```gitignore
# === secret-guard: シークレットファイル保護 ===
.env
.env.*
credentials.json
*.pem
*.key
# === /secret-guard ===
```

### Step 5: git 追跡済みファイルへの対処

git で既に追跡されているシークレットファイルが見つかった場合:

1. ユーザーに警告と対処法を提示
2. `git rm --cached <file>` の実行をユーザーに提案（AI は直接実行しない）
3. コミット履歴からの削除が必要な場合は `git filter-branch` や `BFG Repo-Cleaner` を案内

## --fix モード

引数に `--fix` が含まれる場合:
- Step 4 のユーザー確認をスキップし、自動的に .gitignore を更新
- ただし git 追跡済みファイルの操作は常にユーザー確認必須

## Examples

### 標準スキャン（対話モード）

ユーザー: 「このリポジトリのシークレット保護状態をチェックして」

1. Step 1 で `.env*`, `*.pem`, `credentials.*` 等を検出
2. Step 2 で `.gitignore` と突合し 保護済み / 未保護 / git 追跡済み に分類
3. Step 3 のレポートを提示
4. 未保護があれば Step 4 の AskUserQuestion で追加可否を確認
5. git 追跡済みが見つかれば `git rm --cached` の手順を警告付きで案内

### --fix モードで自動修正

ユーザー: `/secret-guard:scan --fix`

1. Step 1〜3 を通常通り実行
2. Step 4 の確認をスキップし、未保護ファイルのパターンを `.gitignore` の
   `# === secret-guard ===` セクションへ追記
3. git 追跡済みファイルは自動処理せず、ユーザーへ `git rm --cached` を提示
4. 完了後に変更件数と残課題をレポート

### 既に漏洩しているファイルの検出

ユーザー: 「誤って commit してしまったかも」

1. Step 1 で候補ファイルを列挙
2. `git ls-files --error-unmatch` で追跡済みを識別
3. Step 5 に従い警告と履歴削除の選択肢（`git filter-branch` / BFG）を提示
4. キーのローテーション必要性をユーザーに念押し
