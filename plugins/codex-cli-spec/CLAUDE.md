# codex-cli-spec プラグイン

OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは Codex CLI に関する質問に対して自動発動し、以下の知識を提供する:

- 利用可能なモデルとプロバイダー
- 承認モード（Suggest / Auto Edit / Full Auto）
- サンドボックス機能
- 主要コマンドとフラグ
- 設定方法（config.yaml / 環境変数）
- AGENTS.md（プロジェクトドキュメント）
- Plan モード
- マルチエージェント協調
- メモリ管理システム
- Steer モード
- パーソナリティ設定

対応バージョン: Codex CLI v0.104.0

## ディレクトリ構造

```
codex-cli-spec/
├── .claude-plugin/
│   └── plugin.json           # メタデータ
├── CLAUDE.md                 # 本ファイル
├── README.md                 # ユーザー向けドキュメント
└── skills/
    └── codex-cli-knowledge/
        └── SKILL.md          # Codex CLI 仕様知識
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `codex-cli-knowledge` | Codex CLI の仕様に関する質問で自動発動 |

## 設計方針

### シンプルさ優先

- 知識スキルのみで構成
- コマンドやエージェントは含めない
- 軽量で高速な発動

### 自動発動トリガー

以下のキーワードで発動:

- 「Codex CLI」「codex」
- 「承認モード」「approval mode」
- 「AGENTS.md」
- コマンド名（`--model`、`--approval-mode` など）
- 「Plan モード」「メモリ」「パーソナリティ」
- 「マルチエージェント」「Steer モード」

## 前提条件

このプラグインは知識提供のみ。Codex CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @openai/codex
```

## v2.0.0 の変更

### SKILL.md 全面改訂

**モデル情報:**
- `gpt-5.3-codex` を唯一の推奨モデルとして維持
- 他モデルは利用価値なしと明記

**新セクション追加:**
- Plan モード（v0.94.0 デフォルト有効化）: `/plan`、推論 effort medium、Shift+Tab サイクル
- マルチエージェント協調（v0.90.0+）: Sub-agent 最大 6、Explorer ロール、カスタマイズ可能ロール（v0.102.0）
- メモリ管理システム（v0.97.0+）: `/m_update`、`/m_drop`、シークレットサニタイザー
- JavaScript REPL（v0.100.0、実験的）: `js_repl` ツール
- パーソナリティ設定（v0.94.0 Stable）: デフォルト Pragmatic（v0.98.0）
- Steer モード（v0.98.0 Stable）: Enter 即送信、Tab フォローアップキュー
- 認証更新: ChatGPT プラン、Device-code auth、`codex app`

**新スラッシュコマンド追加:**
- `/plan`, `/permissions`, `/skill`, `/apps`
- `/personality`, `/debug-config`, `/statusline`
- `/m_update`, `/m_drop`, `/grant-read-access`

**承認モード更新:**
- Smart approvals デフォルト有効化（v0.93.0）
- `on-failure` 非推奨化（v0.102.0）
- 「Allow and remember」セッションスコープ承認

**サンドボックス更新:**
- Linux Bubblewrap（bwrap）
- Windows サンドボックス
- SOCKS5 プロキシ、構造化ネットワーク承認

**破壊的変更:**
- `approval_policy: on-failure` 非推奨
- `get_memory` ツール削除
- Steer モードで Enter 動作変更
- Git 操作の安全性強化

**CLI バージョン情報:**
- 最新: v0.104.0（2026-02-18）

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- README.md: ユーザー向け情報
- CLAUDE.md: 設計方針と内部構造、バージョン更新内容
- plugin.json: バージョン番号
