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

## v0.2.1 の変更

**5 ツール共通認識の標準化対応:**
- `AGENTS.md` を新規追加（Claude Code / Codex CLI / Cursor / Copilot CLI / OpenCode の入口ドキュメント）
- skills / agents / commands の `description` 1 行目を `Use when ...` で始まる形式に統一
  - Cursor / Codex / Copilot / OpenCode での発動判定精度を向上
- 既存の説明文は語順入れ替えにより先頭に移動。日本語説明は末尾に再配置し情報量は保持

**関連:**
- 仕様: `.claude/rules/plugin-development.md`
- リンター: `.claude/scripts/lint-multi-tool-compat.sh`
