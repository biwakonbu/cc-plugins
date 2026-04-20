# nano-banana-image

Gemini Nano Banana Pro (gemini-3-pro-image-preview) を活用した画像生成プラグイン。テキストから画像生成、解像度・アスペクト比指定、参照画像を使った編集に対応。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **image-generation** — Use when user asks to generate images, create pictures, make illustrations, or edit images with AI. 詳細: `skills/image-generation/SKILL.md`

## Agents

なし。

## Commands

- **/nano-banana-image:generate** — Nano Banana Pro で画像を生成する. 詳細: `commands/generate.md`

## Hooks

なし。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
