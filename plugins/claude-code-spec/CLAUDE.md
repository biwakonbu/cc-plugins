# claude-code-spec プラグイン

Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

Claude Code の公式機能（プラグイン、スキル、フック、権限設定など）について質問されたときに、正確な仕様情報を提供する。

対応バージョン: Claude Code v2.1.3

## ディレクトリ構造

```
claude-code-spec/
├── .claude-plugin/
│   └── plugin.json           # プラグインメタデータ
├── CLAUDE.md                 # 本ファイル（設計ドキュメント）
├── README.md                 # ユーザー向けドキュメント
└── skills/
    └── claude-code-knowledge/
        └── SKILL.md          # 統合知識スキル
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `claude-code-knowledge` | Claude Code 仕様に関する質問に回答 |

## 設計方針

### シンプルさ優先

- 知識スキル1つのみで構成
- コマンドやエージェントは不要
- 軽量で高速な発動

### 自動発動トリガー

以下のキーワードで自動発動:

- `Claude Code について`
- `プラグイン開発`、`plugin.json`
- `スキル定義`、`SKILL.md`
- `スラッシュコマンド`、`commands`
- `サブエージェント`、`agents`
- `フック設定`、`hooks`
- `LSP`、`言語サーバー`
- `権限設定`、`permissions`
- `MCP`
- `Vim モーション`
- `Plan モード`
- `セッション管理`

## 前提条件

Claude Code がインストールされていること:

```bash
npm install -g @anthropic/claude-code
```

## ドキュメント維持規則

**README.md、CLAUDE.md、SKILL.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- Claude Code の新バージョンリリース時
- 公式ドキュメントの変更時
- SKILL.md の内容更新時
- plugin.json の変更時

### 各ファイルの役割

| ファイル | 対象 | 内容 |
|---------|------|------|
| README.md | ユーザー | インストール、使い方、機能一覧 |
| CLAUDE.md | AI・開発者 | 設計方針、構造、メンテナンス規則 |
| SKILL.md | Claude | 詳細な仕様知識 |

### バージョン更新

プラグイン内容を変更した場合は必ず `plugin.json` の version を更新:

- パッチ（x.x.1）: 誤字修正、説明改善
- マイナー（x.1.0）: 新機能追加、情報更新
- メジャー（1.0.0）: 大幅な構造変更
