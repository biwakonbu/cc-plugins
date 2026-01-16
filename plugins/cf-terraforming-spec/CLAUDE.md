# cf-terraforming-spec 開発ガイドライン

## プラグイン概要
Cloudflare `cf-terraforming` CLI の知識ベース。

## 命名規則
- スキル名: `cf-terraforming-knowledge`
- ディレクトリ: `skills/cf-terraforming-knowledge/`

## スキル設定（v0.2.0 以降）

### context: fork の追加
`cf-terraforming-knowledge` スキルに `context: fork` を設定し、サブエージェント化。
大量の知識コンテンツがメインコンテキストを汚染しないようになった。

## ドキュメントの更新
`SKILL.md` の内容は、Cloudflare の公式ドキュメントや `cf-terraforming` の GitHub リポジトリの最新リリースに基づいて更新してください。

## テスト
現在、このプラグインには実行可能なコードは含まれておらず、知識の提供を主目的としています。
ドキュメントの正確性を重視してください。
