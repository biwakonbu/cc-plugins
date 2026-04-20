# cloudflare-knowledge

Cloudflare のサービス、Wrangler CLI、Workers/Pages 開発、Terraform 管理、セキュリティ機能に関する包括的な知識プラグイン。

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **cloudflare-overview** — Use when user asks about Cloudflare overview, service list, pricing, what is Cloudflare, or general Cloudflare questions. 詳細: `skills/cloudflare-overview/SKILL.md`
- **workers-development** — Use when user asks about Workers development, edge functions, bindings, service bindings, cron triggers, or Workers runtime. 詳細: `skills/workers-development/SKILL.md`
- **storage-services** — Use when user asks about KV, R2, D1, Durable Objects, Queues, Hyperdrive, storage, database, or data persistence on Cloudflare. 詳細: `skills/storage-services/SKILL.md`
- **workers-ai** — Use when user asks about Workers AI, AI models, Vectorize, AI Gateway, LLM, image generation, speech recognition, embeddings, or RAG. 詳細: `skills/workers-ai/SKILL.md`
- **wrangler-cli** — Use when user asks about wrangler commands, wrangler.toml configuration, local development, deployment, or CLI operations. 詳細: `skills/wrangler-cli/SKILL.md`
- **security-features** — Use when user asks about Zero Trust, WAF, DDoS, Bot Management, SSL, TLS, Turnstile, Access, Gateway, or security configuration. 詳細: `skills/security-features/SKILL.md`
- **terraform-management** — Use when user asks about Terraform, Pulumi, infrastructure as code, cloudflare provider, cf-terraforming, or IaC management. 詳細: `skills/terraform-management/SKILL.md`
- **pages-deployment** — Use when user asks about Pages deployment, Pages Functions, framework support, Next.js, Nuxt, Astro, SvelteKit, Remix, or Hono on Cloudflare. 詳細: `skills/pages-deployment/SKILL.md`
- **best-practices** — Use when user asks about project structure, CI/CD, GitHub Actions, performance optimization, cost management, troubleshooting, or debugging. 詳細: `skills/best-practices/SKILL.md`

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
