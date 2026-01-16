# wrangler-cli-spec プラグイン

Cloudflare Wrangler CLI の仕様と使い方に関する知識を提供するプラグイン。

## スキル

| スキル | 説明 | v0.2.0 以降 |
|--------|------|-----------|
| `wrangler-cli-knowledge` | Wrangler CLI, Durable Objects, Queues, Hyperdrive, Service Bindings, カスタムビルド設定（Webpack/esbuild）に関する知識 | `context: fork` |

## 使用方法

このプラグインは主に知識ベースとして機能します。ユーザーが Cloudflare Wrangler や関連技術（Durable Objects, Queues 等）について質問した際に、`wrangler-cli-knowledge` スキルが自動的に適用されます。

## 設計方針

- Cloudflare の公式ドキュメントに基づいた正確な情報を提供。
- `wrangler.toml` の設定例を含め、実践的な知識を重視。
- 関連する概念（ステートフル性、メッセージ保証、データベース高速化、内部通信）を体系的に整理。

## v0.2.0 の変更

### context: fork の追加
`wrangler-cli-knowledge` スキルに `context: fork` を設定。
大規模な知識コンテンツがサブエージェント化され、メインコンテキストを保護。