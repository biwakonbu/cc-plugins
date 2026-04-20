# gemini-cli-spec

Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **gemini-cli-knowledge** — Use when user asks about Gemini CLI, gemini command, model selection, /model, /settings, /plan, /rewind, google_web_search, web_fetch, run_shell_command, sandbox, hooks, or Gemini extensions. 詳細: `skills/gemini-cli-knowledge/SKILL.md`

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
