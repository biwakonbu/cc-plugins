# plugin-updater

マーケットプレイスとインストール済みプラグインを一括更新。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

なし。

## Agents

なし。

## Commands

- **/plugin-updater:update-all** — 全マーケットプレイスとインストール済みプラグインを更新する. 詳細: `commands/update-all.md`

## Hooks

なし。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
