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

## 最新の変更（v1.1.0）

### SKILL.md の更新内容

**モデル情報の改善**:
- モデル名は頻繁に更新されることを明記
- `/model` コマンドで最新モデル一覧を確認するよう案内
- 具体例としてモデル名を示す（ただし固定的な表現は回避）

**承認ポリシーの改善**:
- 従来の「Suggest / Auto Edit / Full Auto」から実装的な承認ポリシー概念に移行
- `--ask-for-approval` フラグの具体的な値を記載
- ユーザーフレンドリーなモード名の対応表を追加

**新しいサブコマンド追加**:
- `codex exec`: 非インタラクティブなスクリプト実行
- `codex apply`: Codex Cloud の diff をローカルに適用
- `codex login`: OAuth または API キーで認証
- `codex mcp`: MCP サーバーの管理（Experimental）

**フラグの整理**:
- `--ask-for-approval` の具体的な値（untrusted/on-failure/on-request/never）
- `--sandbox` の具体的な値（read-only/workspace-write/danger-full-access）
- `--full-auto` ショートカットの実装詳細
- 追加フラグの拡充（`--search`、`--oss`、`--image` など）

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- README.md: ユーザー向け情報
- CLAUDE.md: 設計方針と内部構造、バージョン更新内容
- plugin.json: バージョン番号
