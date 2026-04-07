# cc-plugins — Copilot CLI Instructions

このリポジトリは Claude Code プラグインのマーケットプレイスで、
**各プラグインは Claude Code / Codex CLI / Cursor / GitHub Copilot CLI の
4 ツールで共通認識できる形式**で構成されている。

## 認識方法

作業対象のプラグインに `AGENTS.md` があれば、まずそれを読むこと。
`AGENTS.md` はそのプラグインが提供するスキル・サブエージェント・コマンド・
フックの一覧を Markdown で列挙しており、4 ツール共通の入口ファイルとなる。

```
plugins/<name>/
├── AGENTS.md              # ← Copilot CLI が最初に読むべきファイル
├── skills/<id>/SKILL.md   # 詳細なスキル定義 (YAML frontmatter + Markdown)
├── agents/<id>.md         # サブエージェント定義
├── commands/<id>.md       # スラッシュコマンド定義
└── hooks/hooks.json       # フック設定
```

`skills/` `agents/` `commands/` 内の各ファイルは YAML frontmatter を持つ。
未知フィールド (`context`, `user-invocable`, `allowed-tools` 等の Claude Code 固有)
は無視してよい。各ファイルの `description` フィールドの 1 行目が
`Use when <条件>` の形式になっており、発動条件の判定に使える。

## 開発ルール

- ドキュメント・コメントは日本語、コード・識別子は英語
- プラグインを変更したら必ず `plugins/<name>/.claude-plugin/plugin.json` の
  `version` を semantic versioning で更新する
- 新規プラグイン作成時は `AGENTS.md` を必ず用意する
  (plugin-generator v1.5.0+ のテンプレートが自動生成する)

## リポジトリ全体の規約

- ルートの `CLAUDE.md` にプロジェクト全体の方針
- `.claude/rules/plugin-development.md` にプラグイン開発の詳細仕様
- `.claude/scripts/lint-multi-tool-compat.sh` が 4 ツール共通形式を検証する

## 参考

- Claude Code 公式: https://code.claude.com/docs/en/plugins
- AGENTS.md 提案: https://agents.md (各ツールの共通エントリファイル規約)
