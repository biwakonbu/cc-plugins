---
name: security-features
description: Cloudflare セキュリティ機能の完全ガイド。Zero Trust、WAF、DDoS Protection、
Bot Management、SSL/TLS、Turnstile の設定と使い方を提供。
Use when user asks about Zero Trust, WAF, DDoS, Bot Management,
SSL, TLS, Turnstile, Access, Gateway, or security configuration.
Also use when user says セキュリティ, ゼロトラスト, WAF, DDoS, ボット対策, SSL, Turnstile.
---

# Cloudflare Security Features

## 概要

Cloudflare は包括的なセキュリティプラットフォームを提供。
Zero Trust、WAF、DDoS Protection、SSL/TLS、Turnstile などで多層防御を実現。

---

## Zero Trust

### Cloudflare Access

VPN を使用せずに内部リソースへの安全なアクセスを提供する ZTNA ソリューション。

#### 主な機能

- **IdP 統合**: Azure AD、Okta、Google Workspace、GitHub など
- **認証プロトコル**: SAML 2.0、OIDC
- **アクセス制御**: ID、グループ、デバイス状態で判断
- **SSO**: 一度のログインで複数アプリにアクセス

#### 設定例（Terraform）

```hcl
resource "cloudflare_zero_trust_access_application" "dashboard" {
  account_id                = var.account_id
  name                      = "Internal Dashboard"
  domain                    = "dashboard.example.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_zero_trust_access_policy" "employees" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.dashboard.id
  name           = "Allow Employees"
  decision       = "allow"
  precedence     = 1

  include {
    email_domain = ["example.com"]
  }

  require {
    geo = ["JP", "US"]
  }
}
```

### Cloudflare Gateway

DNS/HTTP フィルタリングによるセキュア Web ゲートウェイ。

#### 機能

- DNS フィルタリング
- HTTP/HTTPS インスペクション
- データ損失防止（DLP）
- マルウェアスキャン

### WARP Client

デバイスのトラフィックを Cloudflare Gateway に安全にルーティング。

#### 主な特徴

- 場所を問わないポリシー適用
- MFA の強制
- デバイス姿勢チェック（Posture Check）
- ネットワーク監視（DEX）

### Browser Isolation

Web ブラウジングを隔離環境で実行し、マルウェアから保護。

#### 用途

- 危険なリンクの隔離
- 機密データの保護
- BYOD 環境のセキュリティ

---

## WAF（Web Application Firewall）

### 概要

OWASP Top 10 の脅威（SQLi、XSS など）から Web アプリを保護。

### Managed Rules

Cloudflare が管理する事前定義ルール。ゼロデイ脆弱性にも迅速対応。

```hcl
resource "cloudflare_ruleset" "managed_waf" {
  zone_id = var.zone_id
  name    = "Managed WAF"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules {
    action = "execute"
    action_parameters {
      id = "efb7b8c949ac4650a09736fc376e9aee"  # Cloudflare Managed Ruleset
    }
    expression  = "true"
    description = "Execute Cloudflare Managed Ruleset"
    enabled     = true
  }
}
```

### Custom Rules

独自のセキュリティルールを定義。

```hcl
resource "cloudflare_ruleset" "custom_waf" {
  zone_id = var.zone_id
  name    = "Custom WAF Rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  # IP ブロック
  rules {
    action      = "block"
    expression  = "(ip.src in {192.0.2.0/24 198.51.100.0/24})"
    description = "Block malicious IPs"
    enabled     = true
  }

  # 管理画面保護
  rules {
    action      = "challenge"
    expression  = "(http.request.uri.path contains \"/admin\")"
    description = "Challenge admin access"
    enabled     = true
  }

  # 国別ブロック
  rules {
    action      = "block"
    expression  = "(ip.geoip.country in {\"XX\" \"YY\"})"
    description = "Block specific countries"
    enabled     = true
  }

  # SQLi 検知
  rules {
    action      = "block"
    expression  = "(http.request.uri.query contains \"UNION SELECT\")"
    description = "Block SQL injection"
    enabled     = true
  }
}
```

### Rate Limiting

リクエスト頻度に基づくアクセス制御。

```hcl
resource "cloudflare_ruleset" "rate_limit" {
  zone_id = var.zone_id
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
    description = "API rate limit: 100 req/min per IP"
    enabled     = true
  }

  rules {
    action = "challenge"
    ratelimit {
      characteristics     = ["ip.src"]
      period              = 10
      requests_per_period = 50
      mitigation_timeout  = 60
    }
    expression  = "(http.request.uri.path contains \"/login\")"
    description = "Login rate limit"
    enabled     = true
  }
}
```

---

## DDoS Protection

### 概要

分散型サービス拒否攻撃をエッジで吸収・軽減。自動検知、無制限キャパシティ。

### 特徴

- **自動検知**: 数秒以内に攻撃を検知
- **L3/L4 保護**: ネットワーク層・トランスポート層
- **L7 保護**: アプリケーション層
- **無制限**: 追加料金なし

### 設定

デフォルトで有効。追加設定はダッシュボードまたは API で。

---

## Bot Management

### 概要

悪意のあるボットをブロックし、有用なボット（検索エンジン等）を許可。

### 機能

- 行動分析
- 機械学習フィンガープリント
- ボットスコア
- JavaScript チャレンジ

### ルール例

```hcl
resource "cloudflare_ruleset" "bot_management" {
  zone_id = var.zone_id
  name    = "Bot Management"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action      = "block"
    expression  = "(cf.bot_management.score lt 30)"
    description = "Block likely bots"
    enabled     = true
  }

  rules {
    action      = "challenge"
    expression  = "(cf.bot_management.score lt 50 and not cf.bot_management.verified_bot)"
    description = "Challenge suspicious traffic"
    enabled     = true
  }
}
```

---

## API Shield

### 概要

API エンドポイントの保護。mTLS、Schema Validation、レート制限。

### mTLS（相互 TLS）

```hcl
resource "cloudflare_mtls_certificate" "client_cert" {
  account_id  = var.account_id
  certificates = file("client-ca.pem")
  name        = "Client CA"
}

resource "cloudflare_access_mutual_tls_certificate" "api" {
  account_id              = var.account_id
  associated_hostnames    = ["api.example.com"]
  certificate             = cloudflare_mtls_certificate.client_cert.certificates
  name                    = "API mTLS"
}
```

---

## SSL/TLS

### Universal SSL

全ユーザーに無料提供。自動発行・更新。

### 設定オプション

| 設定 | 説明 |
|------|------|
| Off | SSL なし |
| Flexible | クライアント↔CF のみ暗号化 |
| Full | CF↔オリジンも暗号化（自己署名可） |
| Full (Strict) | CF↔オリジンも暗号化（有効証明書必須） |

### Advanced Certificate Manager

- 複数ワイルドカード
- 証明書有効期間カスタマイズ
- CA の選択

### mTLS

クライアント証明書による認証。

### 最小 TLS バージョン

```hcl
resource "cloudflare_zone_settings_override" "tls" {
  zone_id = var.zone_id

  settings {
    min_tls_version          = "1.2"
    automatic_https_rewrites = "on"
    always_use_https         = "on"
  }
}
```

---

## Turnstile（CAPTCHA 代替）

### 概要

プライバシー重視の人間検証。パズルなしでボットを検出。

### 実装方法

#### HTML

```html
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>

<div class="cf-turnstile" data-sitekey="YOUR_SITE_KEY"></div>
```

#### JavaScript API

```html
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit" defer></script>

<div id="turnstile-container"></div>

<script>
  window.onload = function() {
    turnstile.render('#turnstile-container', {
      sitekey: 'YOUR_SITE_KEY',
      callback: function(token) {
        console.log('Token:', token);
        // フォーム送信時にトークンを含める
      },
      'error-callback': function() {
        console.error('Turnstile error');
      },
      theme: 'light',  // 'light', 'dark', 'auto'
      size: 'normal',  // 'normal', 'compact'
    });
  };
</script>
```

### サーバーサイド検証

```typescript
// Workers での検証
export default {
  async fetch(request: Request, env: Env) {
    const formData = await request.formData();
    const token = formData.get("cf-turnstile-response");

    const result = await fetch(
      "https://challenges.cloudflare.com/turnstile/v0/siteverify",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          secret: env.TURNSTILE_SECRET,
          response: token,
          remoteip: request.headers.get("CF-Connecting-IP"),
        }),
      }
    );

    const outcome = await result.json();

    if (!outcome.success) {
      return new Response("Verification failed", { status: 403 });
    }

    // 検証成功
    return new Response("OK");
  },
};
```

### API レスポンス

```json
{
  "success": true,
  "challenge_ts": "2024-01-01T00:00:00Z",
  "hostname": "example.com",
  "error-codes": [],
  "action": "login",
  "cdata": "customer-data"
}
```

---

## Magic Transit / Magic Firewall

### Magic Transit

オンプレミス/クラウドインフラの DDoS 保護とトラフィック最適化。

- BGP でトラフィックを Cloudflare へ誘導
- 攻撃をエッジで遮断
- クリーントラフィックを GRE トンネルで転送

### Magic Firewall

クラウドベースのネットワークファイアウォール（FWaaS）。

- L3/L4 フィルタリング
- 物理アプライアンス不要
- 数秒でグローバル反映

---

## Spectrum

TCP/UDP ベースのアプリケーション向け DDoS 保護。

### 対応プロトコル

- ゲーム（Minecraft、Steam）
- SSH/RDP
- 金融サービス
- カスタムプロトコル

---

## セキュリティ機能比較

| 機能 | 主な用途 | プラン |
|------|----------|--------|
| **WAF** | Web アプリ保護 | Pro+ |
| **DDoS Protection** | 攻撃軽減 | 全プラン |
| **Bot Management** | ボット対策 | Enterprise |
| **Access** | ZTNA | 有料 |
| **Gateway** | SWG | 有料 |
| **Turnstile** | 人間検証 | 無料+ |
| **API Shield** | API 保護 | Enterprise |

---

## ベストプラクティス

### 推奨設定

1. **TLS 1.2 以上を強制**
2. **Always Use HTTPS を有効化**
3. **WAF Managed Rules を有効化**
4. **Rate Limiting を設定**
5. **Bot Score でフィルタリング**
6. **管理画面に Access を適用**

### 段階的導入

1. ログモードで WAF ルールをテスト
2. 誤検知を確認・除外設定
3. ブロックモードに切り替え
4. Rate Limiting を追加

---

## 公式リソース

- [Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [WAF Documentation](https://developers.cloudflare.com/waf/)
- [DDoS Protection](https://developers.cloudflare.com/ddos-protection/)
- [SSL/TLS](https://developers.cloudflare.com/ssl/)
- [Turnstile](https://developers.cloudflare.com/turnstile/)
- [API Shield](https://developers.cloudflare.com/api-shield/)
