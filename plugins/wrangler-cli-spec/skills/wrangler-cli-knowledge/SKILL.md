---
name: wrangler-cli-knowledge
description: Cloudflare Wrangler CLI の仕様と使い方に関する knowledge。Durable Objects, Queues, Hyperdrive, Service Bindings について回答。Use when user asks about Wrangler, Cloudflare Workers, Durable Objects, Queues, Hyperdrive, or Service Bindings.
allowed-tools: []
---

# Wrangler CLI Knowledge

Cloudflare Wrangler CLI の仕様と使い方に関する包括的な知識を提供するスキル。

## 概要

Wrangler は Cloudflare Developer Platform のコマンドラインインターフェース（CLI）ツールです。Cloudflare Workers やその他の Developer Platform 製品の作成、開発、テスト、デプロイに使用されます。

---

## 主要なコンポーネント

### Durable Objects

コンピューティングとストレージを組み合わせた Cloudflare Workers の特殊なタイプです。

*   **特徴**:
    *   グローバルに一意の ID を持つインスタンス。
    *   シングルスレッドで動作し、複数のクライアント間で調整が可能。
    *   トランザクション的で強力な一貫性のあるストレージ。
    *   WebSocket をサポートし、低遅延なリアルタイム通信が可能。
*   **用途**:
    *   リアルタイム共同編集ツール、チャットアプリケーション、ゲームサーバー。

### Queues

メッセージを確実に送受信できるようにするグローバルメッセージキューイングサービスです。

*   **特徴**:
    *   操作のバッファリングまたはバッチ処理。
    *   リクエストからの重い処理のオフロード。
    *   Workers 間のデータ送信。
    *   少なくとも1回のメッセージ配信を保証。
*   **用途**:
    *   非同期タスク処理、イベント駆動型アプリケーション。

### Hyperdrive

既存の地域データベース（PostgreSQL, MySQL 等）へのクエリを高速化し、グローバル分散型データベースのように扱えるサービスです。

*   **特徴**:
    *   接続プーリング。
    *   インテリジェントなクエリキャッシュ。
    *   リクエストを最も近い接続プールにルーティングして遅延を削減。
*   **用途**:
    *   既存データベースのグローバルパフォーマンス向上。

### Service Bindings

Workers が他の Workers や Cloudflare リソースと内部的に通信するためのメカニズムです。

*   **特徴**:
    *   Cloudflare ネットワーク内での高速な内部接続。
    *   追加の遅延やオーバーヘッドがない。
    *   マイクロサービスアーキテクチャにおける関心の分離を可能にする。
*   **用途**:
    *   内部 API 呼び出し、共通コンポーネントの共有。

---

## Wrangler の基本操作

### インストール

```bash
npm install -g wrangler
```

### 認証

```bash
wrangler login
```

### プロジェクトの初期化

```bash
wrangler init my-worker
```

### デプロイ

```bash
wrangler deploy
```

### ローカル開発

```bash
wrangler dev
```

---

## 設定 (wrangler.toml)

### Durable Objects の設定

```toml
[[durable_objects.bindings]]
name = "MY_DURABLE_OBJECT"
class_name = "MyDurableObject"
```

### Queues の設定

```toml
[[queues.producers]]
queue = "my-queue"
binding = "MY_QUEUE"

[[queues.consumers]]
queue = "my-queue"
```

### Hyperdrive の設定

```toml
[[hyperdrive]]
binding = "MY_HYPERDRIVE"
id = "hyperdrive-id"
```

### Service Bindings の設定

```toml
[[services]]
binding = "AUTH_SERVICE"
service = "auth-worker"
```