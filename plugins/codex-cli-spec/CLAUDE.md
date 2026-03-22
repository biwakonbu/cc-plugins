# codex-cli-spec プラグイン

OpenAI Codex CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは Codex CLI に関する質問に対して自動発動し、以下の知識を提供する:

- 利用可能なモデルとプロバイダー
- 承認モード（Suggest / Auto Edit / Full Auto）
- サンドボックス機能
- 主要コマンドとフラグ
- 設定方法（config.toml / 環境変数 / マルチプロファイル）
- AGENTS.md（プロジェクトドキュメント）
- Plan モード / `/collab` コマンド
- マルチエージェント協調（カスタムエージェント含む）
- メモリ管理システム
- Steer モード
- パーソナリティ設定
- プラグインシステム
- MCP 連携（MCP サーバー化含む）
- フックエンジン
- 音声機能

対応バージョン: Codex CLI v0.116.0

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
- 「プラグイン」「MCP サーバー」「フック」

## 前提条件

このプラグインは知識提供のみ。Codex CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @openai/codex
```

## v3.0.0 の変更

### SKILL.md 全面改訂（v0.104.0 → v0.116.0 対応）

**モデル情報:**
- `gpt-5.4-codex` を標準推奨モデルとして維持
- `gpt-5.4-mini` をサブエージェント用モデルとして追加

**新セクション追加:**
- プラグインシステム（v0.110.0+）: スキル、MCP、アプリコネクタのロード
- フックエンジン（v0.114.0+）: SessionStart, Stop, userpromptsubmit イベント
- MCP 連携: config.toml での MCP サーバー定義、`codex mcp-server` によるサーバー化
- 音声機能: 音声ディクテーション（v0.105.0+）、オーディオ制御（v0.107.0+）
- 実験的機能: コードモード（v0.114.0+）、`/fast` トグル（v0.110.0+）
- TUI: テーマピッカー、App-Server アーキテクチャ、ヘルスチェック
- `/collab` コマンド（v0.114.0+）: Plan / Pair Programming / Execute

**マルチエージェント大幅強化:**
- サブエージェント一般公開（v0.115.0）
- プリセットエージェント（explorer, worker）
- カスタムエージェント定義（`~/.codex/agents/*.toml`）
- CSV ファンアウト、スレッドフォーク、TUI 個別承認
- Git Worktree 隔離、シェル状態再利用による高速化

**設定ファイル移行:**
- config.yaml/json → config.toml への移行推奨
- マルチプロファイル対応（v0.115.0+）
- 認証情報の分離保存（auth.json）

**新スラッシュコマンド追加:**
- `/collab`, `/agent`, `/fast`, `/theme`, `/copy`, `/clear`

**新フラグ追加:**
- `--mode code`, `--disable-system-skills`, `--check-config`, `--last-message-file`

**新サブコマンド追加:**
- `codex mcp-server`, `codex mcp list`, `codex cloud`, `codex cloud list`
- `codex debug clear-memories`
- `codex exec` エイリアス（`codex e`）、`codex apply` エイリアス（`codex a`）

**新ツール追加:**
- `request_permissions`（動的権限要求、v0.113.0+）
- マルチモーダルカスタムツール（v0.107.0+）
- 統合ターミナル読み取り（v0.114.0+）

**サンドボックス強化:**
- Docker ベース（Linux、v0.107.0+）
- AppArmor 対応（v0.116.0+）
- Windows ネイティブサンドボックス（v0.115.0+）
- `sandbox_workspace_write.allow_network`（v0.109.0+）

**破壊的変更追加:**
- TUI App-Server 移行（v0.115.0+）
- コンテキスト除外設定のデフォルト化（v0.116.0）
- フォルダ信頼の導入（v0.115.0+）

**CLI バージョン情報:**
- 最新: v0.116.0（2026-03-19）

## v2.1.0 の変更

### モデル更新

- `gpt-5.3-codex` → `gpt-5.4-codex` に標準モデルを更新
- GPT-5.2 以下のモデル情報は削除済み（v2.0.0 で対応済み）

## v2.0.0 の変更

### SKILL.md 全面改訂

**モデル情報:**
- `gpt-5.3-codex` を唯一の推奨モデルとして設定
- 他モデルは利用価値なしと明記

**CLI バージョン情報:**
- v0.104.0（2026-02-18）対応

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- README.md: ユーザー向け情報
- CLAUDE.md: 設計方針と内部構造、バージョン更新内容
- plugin.json: バージョン番号
