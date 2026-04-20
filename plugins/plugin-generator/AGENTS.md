# plugin-generator

Claude Code プラグインのスキャフォールディングとバリデーション。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **plugin-spec** — Use when questions about plugin.json schema or component overview. 詳細: `skills/plugin-spec/SKILL.md`
- **command-spec** — Use when creating or validating slash command frontmatter. 詳細: `skills/command-spec/SKILL.md`
- **skill-spec** — Use when creating or validating SKILL.md frontmatter and structure. 詳細: `skills/skill-spec/SKILL.md`
- **agent-spec** — Use when creating or validating agent frontmatter (tools, model, skills). 詳細: `skills/agent-spec/SKILL.md`
- **scaffolding** — Use when generating a new plugin or component from templates. 詳細: `skills/scaffolding/SKILL.md`
- **validation** — Use when verifying plugin structure correctness. 詳細: `skills/validation/SKILL.md`

## Agents

- **command-creator** — Use when creating, updating, modifying, or maintaining slash commands in a plugin. 詳細: `agents/command-creator.md`
- **skill-creator** — Use when creating, updating, modifying, or maintaining skills in a plugin. 詳細: `agents/skill-creator.md`
- **agent-creator** — Use when creating, updating, modifying, or maintaining sub-agents in a plugin. 詳細: `agents/agent-creator.md`

## Commands

- **/plugin-generator:create** — 新規プラグイン生成. 詳細: `commands/create.md`
- **/plugin-generator:create-command** — コマンド追加. 詳細: `commands/create-command.md`
- **/plugin-generator:create-skill** — スキル追加. 詳細: `commands/create-skill.md`
- **/plugin-generator:create-agent** — エージェント追加. 詳細: `commands/create-agent.md`

## Hooks

なし。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
