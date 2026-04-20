# memory-optimizer

Claude Code のメモリ管理（CLAUDE.md、rules、imports）を最適化するための知識とワークフローを提供するプラグイン。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **memory-overview** — Use when user asks about memory system, what is memory, memory overview, or how memory works. 詳細: `skills/memory-overview/SKILL.md`
- **claude-md-guide** — Use when user asks about CLAUDE.md, what to write in CLAUDE.md, memory configuration, or project instructions. 詳細: `skills/claude-md-guide/SKILL.md`
- **rules-guide** — Use when user asks about rules folder, paths condition, rule files, or modular memory. 詳細: `skills/rules-guide/SKILL.md`
- **migration-guide** — Use when user wants to migrate content from CLAUDE.md to rules, split memory, or reorganize memory structure. 詳細: `skills/migration-guide/SKILL.md`
- **memory-audit** — Use when user wants to audit memory, check memory status, analyze memory configuration, or evaluate memory efficiency. 詳細: `skills/memory-audit/SKILL.md`
- **best-practices** — Use when user asks about best practices, recommended patterns, memory tips, or how to write good memory. 詳細: `skills/best-practices/SKILL.md`
- **file-path-matcher** — Use when checking if a file is covered by rules, testing path patterns, verifying rules coverage, or when the user asks about rule applicability. 詳細: `skills/file-path-matcher/SKILL.md`

## Agents

- **memory-advisor** — Use when user needs comprehensive advice on memory optimization, wants to discuss memory structure, or needs help designing memory configuration. 詳細: `agents/memory-advisor.md`

## Commands

- **/memory-optimizer:audit** — 現在のメモリ構成を監査し、最適化ポイントをレポート. 詳細: `commands/audit.md`
- **/memory-optimizer:optimize** — メモリ構成の最適化提案を生成. 詳細: `commands/optimize.md`
- **/memory-optimizer:check-file** — 指定されたファイルパスがどの .claude/rules/ に該当するかを即座に確認. 詳細: `commands/check-file.md`

## Hooks

なし。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
