# git-actions

Git commit and push workflow management for Claude Code.

このファイルは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI / OpenCode の
5 ツールが共通で参照する、プラグインの入口ドキュメントです。
詳細な定義は各ファイルの YAML frontmatter と Markdown 本体を参照してください。

## Skills

- **git-commit** (dir: `commit/`) — Use when user wants to commit changes, create a commit, or stage and commit files. 詳細: `skills/commit/SKILL.md`
- **git-push** (dir: `push/`) — Use when user wants to push commits, push to remote, or sync with remote repository. 詳細: `skills/push/SKILL.md`
- **git-merge** (dir: `merge/`) — Use when user wants to merge to main, integrate changes to main branch, or complete a feature branch. 詳細: `skills/merge/SKILL.md`
- **git-resolve-conflicts** (dir: `resolve-conflicts/`) — Use when merge conflicts occur, when git merge fails with conflicts, or when user needs help resolving git conflicts. 詳細: `skills/resolve-conflicts/SKILL.md`
- **git-conventions** — Use when any git operation (commit, push, merge, conflict resolution) runs in this project, or when user mentions git safety. 詳細: `skills/git-conventions/SKILL.md`

## Agents

なし。

## Commands

- **/git-actions:commit-push** — 変更をコミットし、リモートリポジトリにプッシュする. 詳細: `commands/commit-push.md`
- **/git-actions:merge-to-main** — カレントブランチを main にマージしてプッシュする. 詳細: `commands/merge-to-main.md`
- **/git-actions:resolve-conflicts** — マージコンフリクトを分析し解消を支援する. 詳細: `commands/resolve-conflicts.md`

## Hooks

なし (`hooks/hooks.json` は空定義)。

## Multi-tool Compatibility

- Claude Code: `skills/` `agents/` `commands/` `hooks/` をネイティブ発見
- Codex CLI: このファイルを AGENTS.md として自動読み込み
- Cursor: `.cursor/rules/plugin.mdc` 経由で参照 (任意)
- Copilot CLI: リポジトリルートの `.github/copilot-instructions.md` 経由で参照
- OpenCode: このファイルを AGENTS.md としてネイティブ読み込み
