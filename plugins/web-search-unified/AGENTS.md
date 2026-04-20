# web-search-unified

Gemini、Codex、WebSearch を並列実行し結果を統合する高精度 Web 検索。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **unified-search** — Use when user needs deep/cross-source web research, comparison analysis, or highest-accuracy search results. 詳細: `skills/unified-search/SKILL.md`

## Agents

- **unified-researcher** — Use when user needs comprehensive multi-engine research combining Gemini, Codex, and WebSearch. 詳細: `agents/unified-researcher.md`

## Commands

- **/web-search-unified:search** — 統合 Web 検索を実行（Gemini + Codex + WebSearch 並列）. 詳細: `commands/search.md`

## Hooks

なし。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
