# agent-browser-spec

agent-browser CLI の仕様と使い方に関する知識を提供。ヘッドレスブラウザ自動化、スナップショット、セレクター、セッション管理、ネットワーク制御について回答。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **agent-browser-knowledge** — Use when user asks about agent-browser, browser automation, snapshots, selectors, sessions, or web scraping. 詳細: `skills/agent-browser-knowledge/SKILL.md`

## Agents

なし。

## Commands

なし。

## Hooks

なし。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
