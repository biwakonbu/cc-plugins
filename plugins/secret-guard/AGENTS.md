# secret-guard

AI によるシークレットファイルへのアクセスをブロックし、機密情報の漏洩を防止するセキュリティプラグイン。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **secret-scan** — Use when user wants to check secret protection, audit gitignore, scan for exposed secrets, or check security status. 詳細: `skills/secret-scan/SKILL.md`
- **secret-operations** — Use when user needs to work with secrets, manage environment variables, create secret loading scripts, or asks about secure credential management. 詳細: `skills/secret-operations/SKILL.md`

## Agents

なし。

## Commands

- **/secret-guard:scan** — プロジェクトのシークレット保護状況をスキャンしレポート. 詳細: `commands/scan.md`
- **/secret-guard:setup** — シークレット操作用のテンプレートスクリプトを生成. 詳細: `commands/setup.md`

## Hooks

- **PreToolUse (Read|Write|Edit|Glob|Grep)**: シークレットファイルへのファイルアクセスをブロック (`hooks/hooks.json`)
- **PreToolUse (Bash)**: 危険なコマンドを検知してブロック (`hooks/hooks.json`)

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
