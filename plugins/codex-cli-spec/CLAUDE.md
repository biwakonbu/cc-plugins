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
- プロバイダー名（`ollama`、`openrouter` など）

## 前提条件

このプラグインは知識提供のみ。Codex CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @openai/codex
```

## 最新の変更（v1.2.0）

### SKILL.md の更新内容

**デフォルトモデルを GPT-5.2 に更新**:
- `gpt-5.2-codex` をデフォルトモデルに設定
- `gpt-5.2` を汎用タスク用モデルとして追加
- モデル体系を整理（codex / codex-mini / codex-max）

**推論レベルの使い分けを明確化**:
- `medium`: 通常のコーディングタスク
- `high`: 設計、方針検討、評価、デバッグ
- `xhigh`: 最高の思考が必要な場合（codex-max のみ）

**ベストプラクティスの更新**:
- ユースケース別の推奨モデルと推論レベルを更新
- 汎用タスク（非コーディング）の案内を追加

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- README.md: ユーザー向け情報
- CLAUDE.md: 設計方針と内部構造、バージョン更新内容
- plugin.json: バージョン番号
