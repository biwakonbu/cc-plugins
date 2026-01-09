# cf-terraforming-spec

Cloudflare `cf-terraforming` CLI の仕様と使い方に関する知識を提供する Claude プラグイン。

## 概要

このプラグインは、既存の Cloudflare インフラストラクチャを Terraform (IaC) へ移行しようとしているユーザーをサポートします。`cf-terraforming` ツールを使用した HCL 設定の生成、リソースのインポート、およびベストプラクティスに関する情報を提供します。

## 提供されるスキル

### cf-terraforming-knowledge
- `cf-terraforming` のインストールとセットアップ方法。
- `generate` コマンドによる HCL 設定の抽出。
- `import` コマンド（および Terraform 1.5+ の `import` ブロック）を使用したステートの同期。
- サポートされているリソースタイプと既知の制限事項。

## 使い方

Cloudflare リソースの Terraform 移行について質問すると、このプラグインが適切な手順やコマンド例を提示します。

例:
- 「既存の Cloudflare DNS レコードを Terraform に取り込む方法は？」
- 「cf-terraforming で Workers をインポートするコマンドを教えて」
- 「Terraform 1.5 の import ブロックを cf-terraforming で生成したい」
