# claude-code-spec プラグイン

Claude Code CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

Claude Code の公式機能（プラグイン、スキル、フック、権限設定など）について質問されたときに、正確な仕様情報を提供する。

対応バージョン: Claude Code v2.1.81

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
大規模な知識コンテンツ（960+ 行）がメインコンテキストを汚染しないようになった。
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
- `effort 制御`
- `構造化出力`
- `リモートセッション`
- `--bare`
- `--console`

## 前提条件

Claude Code がインストールされていること（公式インストーラー推奨）。

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

## v3.0.0 の変更

### SKILL.md 全面改訂

**対応バージョン更新:**
- v2.1.49 → v2.1.81 対応

**新 CLI フラグ追加:**
- `--bare`（v2.1.81）、`--console`（v2.1.79）、`--effort`、`--channels`
- `--fallback-model`、`--json-schema`、`--max-budget-usd`
- `--agent`、`--agents`、`--team`、`--teammate-mode`
- `--permission-prompt-tool`、`--remote`、`--teleport`
- `--system-prompt`、`--append-system-prompt`、`--name`

**新フックイベント追加:**
- StopFailure（v2.1.78）、PreCompact/PostCompact
- InstructionsLoaded、WorktreeCreate/WorktreeRemove
- Elicitation/ElicitationResult

**サブエージェント機能強化:**
- effort フロントマター（v2.1.80）
- isolation: worktree、memory: user|project|local
- mcpServers スコープ、maxTurns
- Task → Agent リネーム（v2.1.63）

**プラグインシステム更新:**
- プラグイン永続状態（v2.1.78）
- プラグイン設定ソース（v2.1.80）
- スキル effort フロントマター（v2.1.80）

**モデル・コンテキスト:**
- Opus 4.6 最大出力: 128k（v2.1.77）
- モデルエイリアス: opus[1m]、sonnet[1m]、opusplan
- 1M コンテキスト無効化推奨（CLAUDE_CODE_DISABLE_1M_CONTEXT=1）
- 構造化出力（--json-schema）

**新セクション追加:**
- effort 制御
- 構造化出力
- サブエージェントのスコープ（優先順位）

**環境変数追加:**
- ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL
- CLAUDE_CODE_SUBAGENT_MODEL、ANTHROPIC_CUSTOM_MODEL_OPTION
- CLAUDE_CODE_DISABLE_1M_CONTEXT=1（推奨）
- CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING/BACKGROUND_TASKS=1
- CLAUDE_AUTOCOMPACT_PCT_OVERRIDE、DISABLE_PROMPT_CACHING

**権限モード拡張:**
- plan、acceptEdits、dontAsk、bypassPermissions

**破壊的変更:**
- ANTHROPIC_SMALL_FAST_MODEL 非推奨 → ANTHROPIC_DEFAULT_HAIKU_MODEL
- Task ツール → Agent ツールリネーム（v2.1.63）
- Opus 4.6 最大出力 64k → 128k（v2.1.77）

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

## v3.0.2 の変更

**5 ツール共通認識の標準化対応:**
- `AGENTS.md` を新規追加（Claude Code / Codex CLI / Cursor / Copilot CLI / OpenCode の入口ドキュメント）
- skills / agents / commands の `description` 1 行目を `Use when ...` で始まる形式に統一
  - Cursor / Codex / Copilot / OpenCode での発動判定精度を向上
- 既存の説明文は語順入れ替えにより先頭に移動。日本語説明は末尾に再配置し情報量は保持

**関連:**
- 仕様: `.claude/rules/plugin-development.md`
- リンター: `.claude/scripts/lint-multi-tool-compat.sh`
