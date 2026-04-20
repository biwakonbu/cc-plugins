# cursor-cli-spec

Cursor IDE および cursor-agent CLI の仕様知識を提供するプラグイン。

## ディレクトリ構造

```
cursor-cli-spec/
├── .claude-plugin/
│   └── plugin.json           # プラグインメタデータ
├── CLAUDE.md                 # このファイル
├── README.md                 # ユーザー向けドキュメント
└── skills/
    └── cursor-cli-knowledge/
        └── SKILL.md          # 知識スキル
```

## コンポーネント

| コンポーネント | パス | 説明 |
|--------------|------|------|
| cursor-cli-knowledge | skills/cursor-cli-knowledge/SKILL.md | Cursor の仕様知識 |

## 設計方針

- **シンプルさ優先**: 知識スキルのみで構成
- **自動発動**: description のキーワードで発動
- **公式準拠**: docs.cursor.com の情報をベース

## スキル設定（v1.2.0 以降）

### context: fork の追加
`cursor-cli-knowledge` スキルに `context: fork` を設定し、サブエージェント化。
メインコンテキスト保護とトークン消費最適化を実現。

## 自動発動トリガー

以下のキーワードでスキルが発動:

- Cursor, cursor, cursor-agent
- ターミナルエージェント, terminal agent
- @ シンボル, @ symbols
- MCP サーバー
- Composer
- Cursor 設定

## 前提条件

このプラグインは知識のみを提供。実際に Cursor を使用するには:

1. Cursor エディタのインストール: https://cursor.com/
2. cursor-agent CLI のインストール:
   ```bash
   curl https://cursor.com/install -fsS | bash
   ```

## ドキュメント維持規則

- SKILL.md の更新時は plugin.json の version を更新
- 公式ドキュメントの変更に追従して内容を更新
- 参考 URL を常に最新に保つ

## v1.2.2 の変更

**5 ツール共通認識の標準化対応:**
- `AGENTS.md` を新規追加（Claude Code / Codex CLI / Cursor / Copilot CLI / OpenCode の入口ドキュメント）
- skills / agents / commands の `description` 1 行目を `Use when ...` で始まる形式に統一
  - Cursor / Codex / Copilot / OpenCode での発動判定精度を向上
- 既存の説明文は語順入れ替えにより先頭に移動。日本語説明は末尾に再配置し情報量は保持

**関連:**
- 仕様: `.claude/rules/plugin-development.md`
- リンター: `.claude/scripts/lint-multi-tool-compat.sh`
