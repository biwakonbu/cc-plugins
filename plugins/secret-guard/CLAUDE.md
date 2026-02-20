# secret-guard プラグイン

AI によるシークレットファイルへのアクセスをブロックし、機密情報の漏洩を防止するセキュリティプラグイン。

## 概要

Claude Code の `PreToolUse` フック機構を活用し、シークレットファイルへの AI アクセスを確実にブロックする。

**目的:**
1. AI がシークレットファイルを読み取ることを防止
2. シークレットファイルの git commit/push をブロック
3. .gitignore からシークレット漏れを検出し、率先して登録
4. ブロック時は必ずユーザーに詳細を報告

## ディレクトリ構造

```
secret-guard/
├── .claude-plugin/
│   └── plugin.json
├── CLAUDE.md
├── hooks/
│   └── hooks.json                    # PreToolUse フック定義
├── scripts/
│   ├── guard-file-access.sh          # ファイルアクセスガード (Read/Write/Edit/Glob/Grep)
│   ├── guard-bash-command.sh         # Bash コマンドガード (cat, git add/commit 等)
│   ├── lib/
│   │   └── patterns.sh              # デフォルトシークレットパターン定義
│   └── templates/
│       └── env-loader.sh.tmpl       # シークレット読み込みテンプレートスクリプト
├── commands/
│   ├── scan.md                       # /secret-guard:scan コマンド
│   └── setup.md                      # /secret-guard:setup コマンド
└── skills/
    ├── secret-scan/
    │   └── SKILL.md                  # プロジェクトスキャン・.gitignore 管理
    └── secret-operations/
        └── SKILL.md                  # シークレット操作のベストプラクティス
```

## コンポーネント

### フック (hooks/hooks.json)

| フック | マッチャー | 説明 |
|--------|-----------|------|
| guard-file-access.sh | `Read\|Write\|Edit\|Glob\|Grep` | ファイル操作ツールのシークレットアクセスをブロック |
| guard-bash-command.sh | `Bash` | cat, git add/commit/push 等のシークレット操作をブロック |

### スクリプト

| スクリプト | 説明 |
|-----------|------|
| `scripts/lib/patterns.sh` | シークレットファイルパターン定義ライブラリ |
| `scripts/guard-file-access.sh` | ファイルアクセスガード |
| `scripts/guard-bash-command.sh` | Bash コマンドガード |
| `scripts/templates/env-loader.sh.tmpl` | env 読み込みテンプレート |

### コマンド

| コマンド | 説明 |
|---------|------|
| `/secret-guard:scan [--fix]` | プロジェクトのシークレット保護状況をスキャン |
| `/secret-guard:setup [script-type]` | テンプレートスクリプトを生成 |

### スキル

| スキル名 | context | 説明 |
|----------|---------|------|
| `secret-scan` | (メイン) | プロジェクトスキャン・.gitignore 管理 |
| `secret-operations` | `fork` | シークレット操作ベストプラクティス |

## ブロック対象パターン

### ファイル名
`.env`, `.env.*`, `credentials.*`, `secrets.*`, `service-account*.json`,
`serviceAccountKey*.json`, `.netrc`, `.npmrc`, `token.json`, `auth.json`,
`oauth*.json`, `.htpasswd`, `.htaccess`, `wp-config.php`, `database.yml`

### 拡張子
`*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`, `*.keystore`, `*.p8`, `*.gpg`, `*.asc`

### ディレクトリ
`.ssh/`, `.gnupg/`, `.aws/`, `.gcloud/`

### Bash コマンド
- ファイル読み取り: `cat`, `head`, `tail`, `less`, `more`, `bat` + シークレットファイル
- ファイル操作: `source`, `.`, `cp`, `mv`, `base64`, `xxd` + シークレットファイル
- データ送信: `curl --data @` + シークレットファイル
- git 操作: `git add`, `git commit`, `git push` + シークレットファイル

## 設定ファイル: `.secret-guard.json`

プロジェクトルートに `.secret-guard.json` を配置することで、allowlist（許可）と blocklist（追加ブロック）を設定できる。

**検索先:** `$CLAUDE_PROJECT_DIR/.secret-guard.json`

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
- allowlist に `*` 等の過度に広いパターンはセキュリティ上拒否される

### 判定フロー

```
1. allowlist にマッチ → 許可（即座に return）
2. blocklist にマッチ → ブロック
3. デフォルトパターンにマッチ → ブロック
4. いずれにもマッチしない → 許可
```

**allowlist が最優先**。デフォルトでブロックされるファイルでも allowlist で個別に許可できる。

## 設計方針

### フック中心設計

- **確定的ブロック**: LLM に依存せず、シェルスクリプトで確定的にブロック
- **パターンベース**: 拡張可能なパターン定義ライブラリ
- **低遅延**: シンプルなシェルスクリプトで高速処理

### ユーザー通知

- ブロック時は必ず理由とファイルパスを報告
- 代替手段（ターミナルでの直接操作、テンプレートスクリプト）を案内

## v1.1.0

- `.secret-guard.json` 設定ファイル対応
- allowlist: デフォルトブロック対象を個別許可
- blocklist: プロジェクト固有の追加ブロックパターン
- 判定フロー: allowlist → blocklist → デフォルトパターン
- セキュリティ強化:
  - ブロックメッセージの JSON 生成を jq ベースに変更（JSON インジェクション防止）
  - allowlist に `*` 等の過度に広いパターンを拒否するバリデーション追加
  - 不正 JSON 設定ファイルの検出と警告
  - jq 不在時の警告メッセージ出力
  - load_config 多重呼び出し時の配列初期化
  - extract_paths 空配列の set -u エラー修正

## v1.0.0

- 初期リリース
- PreToolUse フックによるファイルアクセスガード
- Bash コマンドガード（cat, git add/commit/push 等）
- secret-scan スキル（プロジェクトスキャン・.gitignore 管理）
- secret-operations スキル（テンプレート生成・ベストプラクティス）
- scan / setup コマンド
