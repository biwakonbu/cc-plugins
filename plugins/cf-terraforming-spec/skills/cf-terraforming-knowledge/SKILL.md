---
name: cf-terraforming-knowledge
description: Cloudflare cf-terraforming CLI の仕様と使い方に関する knowledge。既存リソースのインポート、HCL 生成、Terraform 連携について回答。Use when user asks about cf-terraforming, importing Cloudflare resources to Terraform, or generating HCL from existing Cloudflare setup.
context: fork
allowed-tools: []
---

# cf-terraforming Knowledge

`cf-terraforming` は、既存の Cloudflare リソースを Terraform の設定（HCL）およびステートに変換するためのコマンドラインツールです。

## 概要

このツールを使用することで、手動で作成した Cloudflare の設定を Infrastructure as Code (IaC) 管理下にスムーズに移行できます。

---

## セットアップ

### インストール

- **Homebrew (macOS)**:
  ```bash
  brew tap cloudflare/cloudflare
  brew install cloudflare/cloudflare/cf-terraforming
  ```
- **その他**: GitHub の [releases](https://github.com/cloudflare/cf-terraforming/releases) からバイナリをダウンロード。

### 認証設定

環境変数を使用して API 認証情報を設定します。

- **API トークンを使用する場合 (推奨)**:
  ```bash
  export CLOUDFLARE_API_TOKEN="YOUR_API_TOKEN"
  ```
- **API キーを使用する場合**:
  ```bash
  export CLOUDFLARE_API_KEY="YOUR_API_KEY"
  export CLOUDFLARE_EMAIL="YOUR_EMAIL"
  ```

---

## 基本的なワークフロー

既存のリソースを Terraform に取り込む手順は大きく分けて「設定の生成」と「ステートのインポート」の2段階です。

### 1. Terraform プロバイダの準備

まず、Terraform プロジェクトで Cloudflare プロバイダを初期化しておく必要があります。

```terraform
# providers.tf
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {}
```

```bash
terraform init
```

### 2. HCL 設定の生成 (`generate`)

`cf-terraforming generate` コマンドを使用して、既存のリソースから Terraform 設定ファイルを生成します。

```bash
cf-terraforming generate --resource-type "cloudflare_record" --zone <ZONE_ID> > cloudflare_dns_records.tf
```

- `--resource-type`: インポートするリソースの種類（例: `cloudflare_record`, `cloudflare_worker_script` など）。
- `--zone` / `--account`: 範囲を特定するための ID。

### 3. リソースのインポート (`import`)

生成した設定に対応する実際のデータを Terraform のステートファイルに読み込みます。

#### Terraform 1.5 以降 (モダンインポートブロック)

`--modern-import-block` フラグを使用して、`import` ブロックを生成するのが現在の推奨される方法です。

```bash
cf-terraforming import --resource-type "cloudflare_record" --zone <ZONE_ID> --modern-import-block > imports.tf
```

生成された `import` ブロックを含むファイルを作成した後、以下のコマンドでインポートを完了させます。

```bash
terraform plan
terraform apply
```

#### 以前の Terraform バージョン

フラグなしで実行すると、個別の `terraform import` コマンドがリストアップされます。

```bash
cf-terraforming import --resource-type "cloudflare_record" --zone <ZONE_ID>
# 出力されたコマンドをコピーして実行:
# terraform import cloudflare_record.example <ZONE_ID>/<RECORD_ID>
```

---

## 注意事項

- **リソース名**: 生成されるリソース名は `terraform_managed_resource_<ID>` のようになります。必要に応じてインポート前に分かりやすい名前に変更してください。
- **カバレッジ**: すべての Cloudflare リソースが `cf-terraforming` に対応しているわけではありません。未対応のものは手動で設定を作成する必要があります。
- **CI/CD**: このツールは対話的な移行を目的としており、CI/CD パイプライン内での使用は推奨されていません。

---

## よく使われるリソースタイプ

- `cloudflare_record` (DNS)
- `cloudflare_worker_script` (Workers)
- `cloudflare_worker_route` (Workers Routes)
- `cloudflare_zone` (Zones)
- `cloudflare_pages_project` (Pages)
