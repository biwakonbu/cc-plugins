# gemini-cli-spec プラグイン

Gemini CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは Gemini CLI に関する質問に対して自動発動し、以下の知識を提供する:

- 利用可能なモデルと選択基準
- スラッシュコマンドの一覧と使い方
- 組み込みツールの詳細
- CLI フラグとオプション
- 拡張機能システム

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

### 自動発動トリガー

以下のキーワードで発動:

- 「Gemini CLI」
- 「gemini」
- 「モデル選択」
- `/model`、`/settings` などのコマンド名
- ツール名（`google_web_search`、`web_fetch` など）

## 前提条件

このプラグインは知識提供のみ。Gemini CLI の実際の使用には別途インストールが必要:

```bash
npm install -g @google/gemini-cli
```

または

```bash
brew install gemini-cli
```

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- README.md: ユーザー向け情報
- CLAUDE.md: 設計方針と内部構造
- plugin.json: バージョン番号
