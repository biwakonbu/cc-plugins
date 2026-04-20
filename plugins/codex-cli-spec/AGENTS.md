# codex-cli-spec

OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **codex-cli-knowledge** — Use when user asks about Codex CLI, codex command, approval mode, sandbox, AGENTS.md, codex configuration, /model, /review, /compact, /plan, /personality, /collab, /agent, apply_patch, reasoning level, multi-agent, plugin system, MCP server, hook engine, or memory management. 詳細: `skills/codex-cli-knowledge/SKILL.md`

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
