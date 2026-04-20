---
name: secret-operations
description: Use when user needs to work with secrets, manage environment variables, create secret loading scripts, or asks about secure credential management. シークレットファイルの安全な操作方法とベストプラクティスを提供し、テンプレートスクリプト生成や環境変数の安全な設定方法を案内する。
allowed-tools: Bash, Read, Write, Glob, AskUserQuestion
context: fork
---

# secret-operations

シークレットファイルの安全な操作方法とベストプラクティスを提供する。

## Instructions

### 重要な前提

AI はシークレットファイルを直接読み取れない（secret-guard フックによりブロックされる）。
そのため、以下の方法でユーザーのシークレット管理を支援する:

1. テンプレートスクリプトの生成
2. 安全な操作手順のガイダンス
3. 環境変数ベースの設計支援

### テンプレートスクリプト生成

ユーザーの要求に応じて以下のテンプレートを生成する。

#### env-loader (環境変数読み込み)

`.env` ファイルから環境変数を安全に読み込むスクリプト。
テンプレート: `scripts/templates/env-loader.sh.tmpl` を参考に、
プロジェクトに合わせてカスタマイズする。

カスタマイズポイント:
- 必須変数リスト（`REQUIRED_VARS`）
- .env ファイルのパス
- バリデーションルール

#### env-example (テンプレート .env)

`.env.example` ファイルを生成する。
- 実際の値は含めない
- 変数名とコメントのみ
- 型のヒントや制約を記述

```bash
# データベース接続
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# API キー
API_KEY=your-api-key-here

# JWT シークレット (最低32文字)
JWT_SECRET=your-jwt-secret-minimum-32-characters
```

#### docker-secrets (Docker Secrets 設定)

Docker Compose で secrets を使う設定テンプレートを生成。

#### vault-config (HashiCorp Vault 設定)

Vault からシークレットを取得するスクリプトテンプレートを生成。

### ベストプラクティスガイダンス

ユーザーの質問に応じて以下のガイダンスを提供:

1. **環境変数ベースの設計**
   - 12-Factor App に準拠
   - `.env` ファイルは開発環境のみ
   - 本番は環境変数やシークレットマネージャーを使用

2. **シークレットローテーション**
   - 定期的なキーローテーション
   - 失効したキーの安全な破棄

3. **チーム開発でのシークレット共有**
   - `.env.example` の維持
   - シークレットマネージャーの使用
   - 1Password CLI、AWS Secrets Manager、GCP Secret Manager 等

4. **CI/CD でのシークレット管理**
   - GitHub Actions Secrets
   - GitLab CI/CD Variables
   - 環境変数の暗号化

### 対話フロー

1. ユーザーの要求を確認（何を生成/設定したいか）
2. プロジェクトの技術スタック確認（AskUserQuestion）
3. 適切なテンプレート/ガイダンスを提供
4. 生成後のセットアップ手順を案内

## Examples

### .env ローダースクリプトを生成する

ユーザー: 「Node.js プロジェクトで .env を安全に読み込むスクリプトを作って」

1. 技術スタックを確認（Node.js, Bash ラッパー / dotenv 利用可否）
2. `scripts/templates/env-loader.sh.tmpl` をベースに必須変数リストを埋めてテンプレート生成
3. `.env.example` を併せて生成し、実値を含めない運用を案内
4. `.gitignore` に `.env` が登録済みかをユーザーに確認依頼

### CI/CD でのシークレット共有を相談する

ユーザー: 「GitHub Actions でこの API キーをどう渡せばいい？」

1. GitHub Actions Secrets への登録手順を提示
2. workflow 側で `${{ secrets.API_KEY }}` を `env:` へ受け渡す例を提示
3. 本番と開発で別シークレットを使う分離戦略を案内
4. ローテーション時の手順（旧キー失効 → 新キー登録 → workflow 再実行）を添える

### チーム向けに .env.example を整備する

ユーザー: 「.env.example を最新化したい」

1. 既存 `.env` のキーを Read で列挙（値は扱わない）
2. 各キーに型ヒント・制約コメントを付けたテンプレートを生成
3. AskUserQuestion でコメント内容をユーザーと確認
4. `.env.example` として書き出し、README の「セットアップ」節に反映を提案
