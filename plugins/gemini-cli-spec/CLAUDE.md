# gemini-cli-spec プラグイン

Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは Gemini CLI に関する質問に対して自動発動し、以下の知識を提供する:

- 利用可能なモデルと選択基準
- スラッシュコマンドの一覧と使い方
- 組み込みツールの詳細
- CLI フラグとオプション
- 拡張機能システム
- フックシステム
- サンドボックス機能
- MCP 管理者制御

対応バージョン: Gemini CLI v0.29.0

## ディレクトリ構造

```
gemini-cli-spec/
├── .claude-plugin/
│   └── plugin.json           # メタデータ
├── CLAUDE.md                 # 本ファイル
├── README.md                 # ユーザー向けドキュメント
└── skills/
    └── gemini-cli-knowledge/
        └── SKILL.md          # Gemini CLI 仕様知識
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `gemini-cli-knowledge` | Gemini CLI の仕様に関する質問で自動発動 |

## 設計方針

### シンプルさ優先

- 知識スキルのみで構成
- コマンドやエージェントは含めない
- 軽量で高速な発動

### context: fork の活用（v1.1.0）

`gemini-cli-knowledge` スキルに `context: fork` を設定。
大規模な知識コンテンツがサブエージェント化され、メインコンテキストを保護。

### 自動発動トリガー

以下のキーワードで発動:

- 「Gemini CLI」
- 「gemini」
- 「モデル選択」
- `/model`、`/settings`、`/plan`、`/rewind` などのコマンド名
- ツール名（`google_web_search`、`web_fetch` など）
- 「フック」「サンドボックス」「MCP」

## 前提条件

このプラグインは知識提供のみ。Gemini CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @google/gemini-cli
```

または

```bash
brew install gemini-cli
```

## v2.0.0 の変更

### SKILL.md 全面改訂

**モデル情報の更新:**
- `gemini-3.1-pro-preview` を唯一の推奨モデルとして記載
- Auto オプション・旧モデルを削除
- Gemini 3 デフォルト化（v0.29.0）を記載

**新セクション追加:**
- フックシステム（v0.26.0+）: PreToolUse/PostToolUse、settings.json 設定、変更承認フロー
- サンドボックス強化: macOS Seatbelt、Docker/Podman、ポリシーエンジン
- MCP 管理者制御（v0.29.0）: 許可リスト、ツールフィルタリング
- 拡張機能マーケットプレイス（v0.29.0）: 探索 UI、レジストリクライアント
- 破壊的変更: Node.js 20 必須、非対話モード ask_user 削除

**新スラッシュコマンド追加:**
- `/plan`（v0.29.0）
- `/rewind`（v0.26.0+）
- `/prompt-suggest`（v0.28.0）

**CLI バージョン情報:**
- 最新: v0.29.0（2026-02-17）

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- README.md: ユーザー向け情報
- CLAUDE.md: 設計方針と内部構造
- plugin.json: バージョン番号
