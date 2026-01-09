---
name: terraform-management
description: Terraform/Pulumi を使用した Cloudflare インフラ管理ガイド。
Provider 設定、リソース定義、cf-terraforming、Wrangler との使い分けを提供。
Use when user asks about Terraform, Pulumi, infrastructure as code,
cloudflare provider, cf-terraforming, or IaC management.
Also use when user says Terraform, テラフォーム, インフラ管理, IaC, Pulumi.
---

# Terraform / Pulumi による Cloudflare 管理

## 概要

Terraform および Pulumi を使用して Cloudflare リソースをコードとして管理。
DNS、WAF、Zero Trust、Workers など、ほぼ全てのリソースに対応。

---

## Terraform Provider 設定

### インストール

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

### 認証方法

| 方法 | 推奨度 | 説明 |
|------|--------|------|
| **API Token** | 推奨 | 最小権限、リソース限定可能 |
| Global API Key | 非推奨 | 全権限、セキュリティリスク |

### 環境変数

```bash
# API Token（推奨）
export CLOUDFLARE_API_TOKEN="xxx"

# Global API Key（非推奨）
export CLOUDFLARE_API_KEY="xxx"
export CLOUDFLARE_EMAIL="xxx@example.com"
```

### 変数定義

```hcl
# variables.tf
variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}
```

---

## 主要リソース

### Zone（ドメイン管理）

```hcl
# 既存ゾーン参照
data "cloudflare_zone" "example" {
  name = "example.com"
}

# 新規ゾーン作成
resource "cloudflare_zone" "new" {
  account_id = var.cloudflare_account_id
  zone       = "newdomain.com"
  plan       = "free"
}
```

### DNS レコード

```hcl
# A レコード
resource "cloudflare_dns_record" "www" {
  zone_id = data.cloudflare_zone.example.id
  name    = "www"
  content = "192.0.2.1"
  type    = "A"
  ttl     = 3600
  proxied = true
}

# CNAME レコード
resource "cloudflare_dns_record" "blog" {
  zone_id = data.cloudflare_zone.example.id
  name    = "blog"
  content = "example.netlify.app"
  type    = "CNAME"
  proxied = true
}

# MX レコード
resource "cloudflare_dns_record" "mx" {
  zone_id  = data.cloudflare_zone.example.id
  name     = "@"
  content  = "mail.example.com"
  type     = "MX"
  priority = 10
}
```

### Workers

```hcl
# Worker スクリプト
resource "cloudflare_worker_script" "api" {
  account_id = var.cloudflare_account_id
  name       = "api-worker"
  content    = file("${path.module}/workers/api.js")

  # KV バインディング
  kv_namespace_binding {
    name         = "MY_KV"
    namespace_id = cloudflare_workers_kv_namespace.cache.id
  }

  # R2 バインディング
  r2_bucket_binding {
    name        = "MY_BUCKET"
    bucket_name = cloudflare_r2_bucket.assets.name
  }

  # D1 バインディング
  d1_database_binding {
    name        = "DB"
    database_id = cloudflare_d1_database.main.id
  }

  # 環境変数
  plain_text_binding {
    name = "ENV"
    text = "production"
  }

  # シークレット
  secret_text_binding {
    name = "API_KEY"
    text = var.api_key
  }
}

# Worker ルート
resource "cloudflare_worker_route" "api" {
  zone_id     = data.cloudflare_zone.example.id
  pattern     = "api.example.com/*"
  script_name = cloudflare_worker_script.api.name
}

# カスタムドメイン
resource "cloudflare_worker_domain" "api" {
  account_id = var.cloudflare_account_id
  hostname   = "api.example.com"
  service    = cloudflare_worker_script.api.name
  zone_id    = data.cloudflare_zone.example.id
}
```

### KV Namespace

```hcl
resource "cloudflare_workers_kv_namespace" "cache" {
  account_id = var.cloudflare_account_id
  title      = "cache-namespace"
}
```

### R2 Bucket

```hcl
resource "cloudflare_r2_bucket" "assets" {
  account_id = var.cloudflare_account_id
  name       = "assets-bucket"
  location   = "wnam"
}
```

### D1 Database

```hcl
resource "cloudflare_d1_database" "main" {
  account_id = var.cloudflare_account_id
  name       = "main-database"
}
```

### WAF（Ruleset）

```hcl
# カスタム WAF ルール
resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = data.cloudflare_zone.example.id
  name        = "Custom WAF Rules"
  description = "Custom security rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules {
    action      = "block"
    expression  = "(ip.src in {192.0.2.0/24})"
    description = "Block specific IP range"
    enabled     = true
  }

  rules {
    action      = "challenge"
    expression  = "(http.request.uri.path contains \"/admin\")"
    description = "Challenge admin access"
    enabled     = true
  }
}

# レート制限
resource "cloudflare_ruleset" "rate_limit" {
  zone_id = data.cloudflare_zone.example.id
  name    = "Rate Limiting"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules {
    action = "block"
    ratelimit {
      characteristics     = ["ip.src"]
      period              = 60
      requests_per_period = 100
      mitigation_timeout  = 600
    }
    expression  = "(http.request.uri.path contains \"/api\")"
    description = "API rate limit"
    enabled     = true
  }
}
```

### Zero Trust Access

```hcl
# Access アプリケーション
resource "cloudflare_zero_trust_access_application" "internal" {
  account_id                = var.cloudflare_account_id
  name                      = "Internal Dashboard"
  domain                    = "dashboard.example.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

# Access ポリシー
resource "cloudflare_zero_trust_access_policy" "allow_employees" {
  account_id     = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.internal.id
  name           = "Allow Employees"
  decision       = "allow"
  precedence     = 1

  include {
    email_domain = ["example.com"]
  }
}
```

### Tunnel

```hcl
# Tunnel 作成
resource "cloudflare_zero_trust_tunnel_cloudflared" "main" {
  account_id = var.cloudflare_account_id
  name       = "main-tunnel"
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "random_password" "tunnel_secret" {
  length = 64
}

# Tunnel 設定
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "main" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.main.id

  config {
    ingress_rule {
      hostname = "app.example.com"
      service  = "http://localhost:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

# DNS レコード
resource "cloudflare_dns_record" "tunnel" {
  zone_id = data.cloudflare_zone.example.id
  name    = "app"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
```

---

## cf-terraforming

### 概要

既存の Cloudflare リソースを Terraform コードとしてエクスポートする公式ツール。

### インストール

```bash
# macOS
brew install cloudflare/cloudflare/cf-terraforming

# Go
go install github.com/cloudflare/cf-terraforming/cmd/cf-terraforming@latest
```

### 使用方法

```bash
# 環境変数設定
export CLOUDFLARE_API_TOKEN="xxx"
export CLOUDFLARE_ZONE_ID="xxx"

# HCL コード生成
cf-terraforming generate \
  --resource-type cloudflare_dns_record \
  --zone $CLOUDFLARE_ZONE_ID > dns_records.tf

# import ブロック生成（Terraform 1.5+）
cf-terraforming import \
  --resource-type cloudflare_dns_record \
  --zone $CLOUDFLARE_ZONE_ID > imports.tf
```

### 対応リソースタイプ

| リソースタイプ | 説明 |
|---------------|------|
| `cloudflare_dns_record` | DNS レコード |
| `cloudflare_zone_settings_override` | ゾーン設定 |
| `cloudflare_page_rule` | ページルール |
| `cloudflare_ruleset` | WAF/ルールセット |
| `cloudflare_access_application` | Access アプリ |
| `cloudflare_worker_script` | Workers スクリプト |

### 推奨ワークフロー

```bash
# 1. import ブロック生成
cf-terraforming import --resource-type cloudflare_dns_record --zone $ZONE_ID > imports.tf

# 2. HCL コード生成
cf-terraforming generate --resource-type cloudflare_dns_record --zone $ZONE_ID > dns.tf

# 3. plan 確認
terraform plan

# 4. apply（インポート実行）
terraform apply

# 5. import ブロック削除
rm imports.tf
```

---

## Wrangler vs Terraform 使い分け

| 管理対象 | 推奨ツール | 理由 |
|---------|-----------|------|
| **Workers コード** | Wrangler | 開発サイクルが高速 |
| **Workers 設定** | Wrangler | wrangler.toml で一元管理 |
| **KV/R2/D1 作成** | Terraform | 他リソースと統合管理 |
| **DNS レコード** | Terraform | 宣言的管理、履歴追跡 |
| **WAF/セキュリティ** | Terraform | 環境間の一貫性 |
| **Access/Zero Trust** | Terraform | 複雑な設定の可視化 |
| **Tunnel** | Terraform | インフラ全体との統合 |

### ハイブリッド構成例

```
[Terraform]
├── DNS レコード
├── Worker Route
├── KV Namespace / R2 Bucket / D1 Database
├── WAF Ruleset
├── Access Application / Policy
└── Tunnel

[Wrangler]
├── Worker コード (*.ts)
├── wrangler.toml
├── 環境変数 / シークレット
└── ローカル開発 / デプロイ
```

---

## Pulumi

### 設定

```typescript
// index.ts
import * as cloudflare from "@pulumi/cloudflare";

const zone = new cloudflare.Zone("example", {
  zone: "example.com",
  accountId: config.accountId,
  plan: "free",
});

const record = new cloudflare.DnsRecord("www", {
  zoneId: zone.id,
  name: "www",
  type: "A",
  content: "192.0.2.1",
  proxied: true,
});

const worker = new cloudflare.WorkerScript("api", {
  accountId: config.accountId,
  name: "api-worker",
  content: fs.readFileSync("worker.js", "utf-8"),
});
```

---

## ベストプラクティス

### ディレクトリ構造

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── dns.tf
├── workers.tf
├── waf.tf
├── access.tf
└── environments/
    ├── staging/
    │   └── terraform.tfvars
    └── production/
        └── terraform.tfvars
```

### セキュリティ

- API Token を使用（最小権限）
- 機密情報は環境変数または Secrets Manager
- `.terraform.lock.hcl` をバージョン管理に含める
- 本番変更は PR レビュー必須

### CI/CD（GitHub Actions）

```yaml
name: Terraform

on:
  pull_request:
    paths: ["terraform/**"]
  push:
    branches: [main]
    paths: ["terraform/**"]

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init
        working-directory: terraform

      - name: Terraform Plan
        run: terraform plan -out=plan.tfplan
        working-directory: terraform
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}

  apply:
    if: github.ref == 'refs/heads/main'
    needs: plan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: terraform
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

---

## Provider v5 への移行

### 主な変更点

| 項目 | v4 | v5 |
|------|-----|-----|
| リソース名 | `cloudflare_record` | `cloudflare_dns_record` |
| 生成方式 | 手動実装 | OpenAPI 自動生成 |

### 移行ツール

```bash
# tf-migrate インストール
go install github.com/cloudflare/terraform-provider-cloudflare/tools/tf-migrate@latest

# HCL 変換
tf-migrate --dir ./terraform

# State 変換
tf-migrate --state ./terraform.tfstate
```

---

## 公式リソース

- [Terraform Registry - Cloudflare](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [Cloudflare Terraform Docs](https://developers.cloudflare.com/terraform/)
- [cf-terraforming](https://github.com/cloudflare/cf-terraforming)
- [Pulumi Cloudflare](https://www.pulumi.com/registry/packages/cloudflare/)
