# gemini-api-spec

Gemini API の最新モデル・機能・価格に関する包括的な知識プラグイン。テキスト生成、画像生成、音声・TTS、動画生成、価格・レート制限について回答。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **gemini-api-overview** — Use when user asks about Gemini API overview, model selection, which Gemini model to use, Gemini model comparison, or SDK setup. 詳細: `skills/gemini-api-overview/SKILL.md`
- **gemini-text-models** — Use when user asks about Gemini text models, Flash vs Pro, Flash Lite, thinking mode, reasoning, context window, or model migration. 詳細: `skills/gemini-text-models/SKILL.md`
- **gemini-image-generation** — Use when user asks about Gemini image generation, Nano Banana, image models, image resolution, aspect ratio, or image editing. 詳細: `skills/gemini-image-generation/SKILL.md`
- **gemini-audio-tts** — Use when user asks about Gemini TTS, text-to-speech, audio generation, Live API, voice synthesis, speech, or audio models. 詳細: `skills/gemini-audio-tts/SKILL.md`
- **gemini-video-generation** — Use when user asks about Gemini video generation, Veo, video model, video creation, or video editing. 詳細: `skills/gemini-video-generation/SKILL.md`
- **gemini-api-pricing** — Use when user asks about Gemini pricing, cost, rate limits, free tier, API pricing, token cost, or billing. 詳細: `skills/gemini-api-pricing/SKILL.md`

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
