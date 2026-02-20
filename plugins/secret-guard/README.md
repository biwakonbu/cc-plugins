# secret-guard

AI によるシークレットファイルへのアクセスをブロックし、機密情報の漏洩を防止するセキュリティプラグイン。

## インストール

```bash
claude plugin install secret-guard@cc-plugins
```

## 機能

### 自動ブロック（PreToolUse フック）

インストールするだけで、AI によるシークレットファイルへのアクセスを自動的にブロック。LLM に依存せず、シェルスクリプトで確定的にブロックする。

| フック | 対象 | 説明 |
|--------|------|------|
| guard-file-access.sh | Read, Write, Edit, Glob, Grep | ファイル操作ツールのシークレットアクセスをブロック |
| guard-bash-command.sh | Bash | cat, git add/commit/push 等のシークレット操作をブロック |

### ブロック対象

**ファイル名**: `.env`, `.env.*`, `credentials.*`, `secrets.*`, `service-account*.json`, `.netrc`, `.npmrc`, `token.json`, `auth.json`, `oauth*.json`, `.htpasswd`, `wp-config.php`, `database.yml` 等

**拡張子**: `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`, `*.keystore`, `*.p8`, `*.gpg`, `*.asc`

**ディレクトリ**: `.ssh/`, `.gnupg/`, `.aws/`, `.gcloud/`

**Bash コマンド**: `cat`, `head`, `tail`, `source`, `cp`, `mv`, `base64`, `xxd` + シークレットファイル、`git add/commit/push` + シークレットファイル

## コマンド

| コマンド | 説明 |
|---------|------|
| `/secret-guard:scan [--fix]` | プロジェクトのシークレット保護状況をスキャン |
| `/secret-guard:setup [script-type]` | テンプレートスクリプトを生成 |

## スキル

| スキル | 説明 |
|--------|------|
| `secret-scan` | プロジェクトスキャン・.gitignore 管理 |
| `secret-operations` | シークレット操作のベストプラクティス |

## 設定ファイル: `.secret-guard.json`

プロジェクトルートに `.secret-guard.json` を配置することで、allowlist（許可）と blocklist（追加ブロック）を設定できる。

```json
{
  "allowlist": [
    "database.yml",
    "config/master.key"
  ],
  "blocklist": [
    "*.secret",
    "config/production.ini",
    ".vault/"
  ]
}
```

- `allowlist`: デフォルトパターンにマッチしても**許可**するパターン（プロジェクト固有の例外）
- `blocklist`: デフォルトパターンに含まれていなくても**ブロック**するパターン（プロジェクト固有の追加保護）
- glob パターン対応（`*`, `?` 等、bash の `case` 文準拠）
- 末尾 `/` のパターンはディレクトリとして判定

### 判定フロー

```
1. allowlist にマッチ → 許可
2. blocklist にマッチ → ブロック
3. デフォルトパターンにマッチ → ブロック
4. いずれにもマッチしない → 許可
```

## 使用例

```bash
# シークレット保護状況をスキャン
/secret-guard:scan

# 問題を自動修正（.gitignore への追加等）
/secret-guard:scan --fix

# テンプレートスクリプトを生成
/secret-guard:setup env-loader
```

## ライセンス

MIT
