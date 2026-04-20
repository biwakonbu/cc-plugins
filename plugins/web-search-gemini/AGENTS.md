# web-search-gemini

Gemini CLI を活用した Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **web-search** — Use when user asks to search the web, look up information, find recent news, or research a topic. 詳細: `skills/web-search/SKILL.md`

## Agents

- **gemini-researcher** — Use when user needs comprehensive research, comparison analysis, or multi-step investigation. 詳細: `agents/gemini-researcher.md`

## Commands

- **/web-search-gemini:search** — Gemini CLI を使用して Web 検索を実行する. 詳細: `commands/search.md`

## Hooks

- **PreToolUse (WebSearch)**: WebSearch ツール呼び出しを Gemini CLI にリダイレクト (`hooks/hooks.json`)

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
