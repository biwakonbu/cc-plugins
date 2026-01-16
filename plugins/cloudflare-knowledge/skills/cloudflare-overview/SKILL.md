---
name: cloudflare-overview
description: Cloudflare サービス全体の概要と各機能へのナビゲーションを提供。サービス一覧、料金プラン、用語集、アーキテクチャ概要について回答。Use when user asks about Cloudflare overview, service list, pricing, what is Cloudflare, or general Cloudflare questions. Also use when user says Cloudflare とは, サービス一覧, 料金, 概要.
context: fork
---

# Cloudflare Overview

## Cloudflare とは

Cloudflare は、CDN、セキュリティ、エッジコンピューティングを提供するグローバルプラットフォーム。
世界330以上のデータセンターでエッジネットワークを展開し、高速・安全なインターネット体験を提供する。

## サービス一覧

### コンピューティング

| サービス | 説明 | 用途 |
|---------|------|------|
| **Workers** | サーバーレスエッジ関数 | API、ミドルウェア、SSR |
| **Pages** | 静的サイト/フルスタックホスティング | Webサイト、Webアプリ |
| **Durable Objects** | ステートフルエッジコンピューティング | リアルタイム協調、ゲーム |
| **Queues** | メッセージキュー | 非同期処理、ETL |

### ストレージ

| サービス | 説明 | 用途 |
|---------|------|------|
| **KV** | Key-Value ストア | キャッシュ、設定、セッション |
| **R2** | オブジェクトストレージ（S3互換） | ファイル保存、CDNオリジン |
| **D1** | サーバーレス SQLite DB | アプリケーションデータ |
| **Hyperdrive** | 既存DB接続高速化 | PostgreSQL/MySQL プール |

### AI/ML

| サービス | 説明 | 用途 |
|---------|------|------|
| **Workers AI** | エッジ AI 推論 | LLM、画像生成、音声認識 |
| **Vectorize** | ベクトルデータベース | RAG、セマンティック検索 |
| **AI Gateway** | AI API 統合管理 | ログ、キャッシュ、レート制限 |

### セキュリティ

| サービス | 説明 | 用途 |
|---------|------|------|
| **Zero Trust** | ZTNA プラットフォーム | 企業アクセス制御 |
| **WAF** | Web アプリファイアウォール | 攻撃防御 |
| **DDoS Protection** | DDoS 攻撃軽減 | 可用性確保 |
| **Bot Management** | ボット対策 | スクレイピング防止 |
| **Turnstile** | CAPTCHA 代替 | 人間検証 |

### ネットワーク

| サービス | 説明 | 用途 |
|---------|------|------|
| **CDN** | コンテンツ配信 | 高速化、キャッシュ |
| **DNS** | マネージド DNS | ドメイン管理 |
| **Tunnel** | セキュアトンネル | オンプレミス接続 |
| **Spectrum** | TCP/UDP プロキシ | ゲーム、カスタムプロトコル |

## 料金プラン

### Workers / Pages

| プラン | 料金 | リクエスト数 | CPU時間 |
|--------|------|------------|---------|
| Free | 無料 | 10万/日 | 10ms |
| Paid | $5/月〜 | 1000万/月含む | 50ms |
| Enterprise | カスタム | 無制限 | カスタム |

### ストレージ

| サービス | 無料枠 | 有料（超過分） |
|---------|--------|--------------|
| KV | 1GB ストレージ | $0.50/GB/月 |
| R2 | 10GB ストレージ | $0.015/GB/月 |
| D1 | 5GB/DB | $0.75/GB/月 |

### Workers AI

| 項目 | 無料枠 | 有料 |
|------|--------|------|
| ニューロン | 10,000/日 | $0.011/1000ニューロン |

## 開発ツール

### Wrangler CLI

Cloudflare の公式 CLI ツール。Workers、Pages、KV、R2、D1 などの操作を行う。

```bash
# インストール
npm install -g wrangler

# ログイン
wrangler login

# プロジェクト作成
npm create cloudflare@latest
```

詳細は `wrangler-cli` スキルを参照。

### Terraform / Pulumi

Infrastructure as Code でのリソース管理。DNS、WAF、Access など。

詳細は `terraform-management` スキルを参照。

## アーキテクチャパターン

### フルスタック Web アプリ

```
[ユーザー] → [Cloudflare CDN/WAF] → [Pages/Workers]
                                          ↓
                            [D1] [KV] [R2] [Durable Objects]
```

### API ゲートウェイ

```
[クライアント] → [Workers] → [オリジンAPI]
                    ↓
            [KV キャッシュ]
```

### エッジ AI アプリ

```
[ユーザー入力] → [Workers] → [Workers AI / AI Gateway]
                    ↓                  ↓
               [Vectorize]      [外部LLMプロバイダー]
```

## 関連スキル

| スキル | 説明 |
|--------|------|
| `wrangler-cli` | Wrangler CLI の使い方 |
| `workers-development` | Workers 開発ガイド |
| `pages-deployment` | Pages デプロイメント |
| `storage-services` | ストレージサービス詳細 |
| `workers-ai` | AI/ML 機能 |
| `terraform-management` | Terraform 管理 |
| `security-features` | セキュリティ機能 |
| `best-practices` | ベストプラクティス |

## 用語集

| 用語 | 説明 |
|------|------|
| **エッジ** | ユーザーに近いデータセンターでの処理 |
| **V8 Isolates** | Workers のランタイム環境（Chrome V8 ベース） |
| **バインディング** | Workers から他サービスへの接続設定 |
| **互換性日付** | Workers ランタイムの動作バージョン指定 |
| **ニューロン** | Workers AI の課金単位 |

## 公式リソース

- [Cloudflare Developers](https://developers.cloudflare.com/)
- [Cloudflare Blog](https://blog.cloudflare.com/)
- [Cloudflare Status](https://www.cloudflarestatus.com/)
- [Cloudflare Community](https://community.cloudflare.com/)
