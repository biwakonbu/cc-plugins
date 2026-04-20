# gogcli-spec

Google Suite CLI (gogcli/gog) の仕様と使い方を完璧に理解するための知識プラグイン。Gmail、Calendar、Drive、Contacts、Tasks、Sheets、Docs、Chat、Classroom 等の操作について回答。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **gogcli-knowledge** — Use when user asks about gogcli, gog CLI, Google CLI, Gmail CLI, Google Calendar CLI, Google Drive CLI, or Google Workspace CLI. 詳細: `skills/gogcli-knowledge/SKILL.md`

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
