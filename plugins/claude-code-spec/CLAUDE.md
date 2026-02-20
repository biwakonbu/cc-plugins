# claude-code-spec プラグイン

Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

Claude Code の公式機能（プラグイン、スキル、フック、権限設定など）について質問されたときに、正確な仕様情報を提供する。

対応バージョン: Claude Code v2.1.49

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

### context: fork の活用（v1.1.0）

`claude-code-knowledge` スキルに `context: fork` を設定。
大規模な知識コンテンツ（1000+ 行）がメインコンテキストを汚染しないようになった。
トークン消費も最適化され、メインの会話コンテキストを保護。

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
- `エージェントチーム`
- `バックグラウンドエージェント`
- `Git Worktree`
- `セッションテレポート`
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

### バージョン更新

プラグイン内容を変更した場合は必ず `plugin.json` の version を更新:

- パッチ（x.x.1）: 誤字修正、説明改善
- マイナー（x.1.0）: 新機能追加、情報更新
- メジャー（1.0.0）: 大幅な構造変更

## v2.0.0 の変更

### SKILL.md 全面改訂

**対応バージョン更新:**
- v2.1.3 → v2.1.49 対応

**モデル情報の更新:**
- Opus 4.6（`claude-opus-4-6`）: デフォルト
- Sonnet 4.6（`claude-sonnet-4-6`）: 高速・コスト効率
- サブエージェント model フィールドに `sonnet` を推奨として追加
- Opus 4/4.1 は非推奨化

**新セクション追加:**
- エージェントチーム（実験的、v2.1.32+）: チームリーダー、共有タスクリスト、tmux バックエンド
- バックグラウンドエージェント強化: `background: true`（v2.1.49）、Ctrl+F 終了
- Git Worktree サポート（v2.1.49）: `--worktree` フラグ、サブエージェント分離
- セッションテレポート（v2.1.30+）: `/desktop`、iOS 委任
- 自動メモリ（v2.1.32+）: エージェント `memory` フィールド
- タスク管理システム（v2.1.16+）: 依存関係追跡、TaskUpdate 削除
- PR レビュー状況（v2.1.20+）: `--from-pr` フラグ

**新スラッシュコマンド追加:**
- `/debug`（v2.1.30）、`/desktop`（v2.1.30+）、`/fast`（v2.1.32+）
- `/usage`（v2.1.14）、`/rename` 引数なし自動生成（v2.1.41）

**新 CLI サブコマンド:**
- `claude auth login/status/logout`（v2.1.41）

**プラグインシステム更新:**
- `settings.json` 同梱可能（v2.1.49）
- git SHA ピン留め（v2.1.14）
- `--add-dir` プラグイン読み込み（v2.1.45）

**エージェント定義の新フィールド:**
- `background: true`（v2.1.49）
- `memory`（v2.1.33）
- `Task(agent_type)` 制限構文（v2.1.33）

**フックイベント追加:**
- `TeammateIdle`（v2.1.33）
- `TaskCompleted`（v2.1.33）
- `ConfigChange`（v2.1.47）

**MCP 更新:**
- Tool Search デフォルト Auto（v2.1.7）
- `claude.ai` MCP コネクタ（v2.1.46）
- OAuth クライアント資格情報（v2.1.30）

**破壊的変更:**
- npm インストール非推奨化（v2.1.15）
- Opus 4/4.1 非推奨化
- Opus 4.6 でプリフィル削除
