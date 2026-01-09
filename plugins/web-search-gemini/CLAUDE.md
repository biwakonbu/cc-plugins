# web-search-gemini プラグイン

Gemini CLI の `google_web_search` ツールを活用した Web 検索プラグイン。

## 概要

Claude Code から Gemini CLI を呼び出し、Google Search によるリアルタイム Web 検索を実行する。
技術調査、汎用リサーチ、最新情報取得に対応。

## ディレクトリ構造

```
web-search-gemini/
├── .claude-plugin/
│   └── plugin.json           # メタデータ
├── CLAUDE.md                 # 本ファイル
├── commands/
│   └── search.md             # 明示的検索コマンド
├── agents/
│   └── gemini-researcher.md  # 複雑調査用エージェント
└── skills/
    └── web-search/
        └── SKILL.md          # Web 検索スキル
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `web-search` | 自動発動する Web 検索（「調べて」「検索して」） |
| エージェント | `gemini-researcher` | 複雑な調査タスク（比較、分析、レポート） |
| コマンド | `/web-search-gemini:search` | 明示的な検索実行 |

## アーキテクチャ

```
ユーザーリクエスト
    │
    ├─→ 単純な検索「〜を調べて」
    │     └─→ web-search スキル（自動発動）
    │           └─→ gemini --yolo "{query}"
    │
    ├─→ 明示的な検索
    │     └─→ /web-search-gemini:search
    │           └─→ web-search スキル参照
    │
    └─→ 複雑な調査タスク
          └─→ Task ツール → gemini-researcher エージェント
                └─→ 複数検索 + 分析 + レポート
```

## Gemini CLI の使い方

### 基本コマンド

```bash
# Web 検索を確実に実行（推奨）
gemini --yolo "Use the google_web_search tool to search for: {検索クエリ}. You MUST perform a web search."

# 自分の知識で答える（古い形式）
gemini "検索クエリ"
```

### Web 検索の動作

1. Gemini に明示的に `google_web_search` ツール使用を指示
2. Google Web Search を実行
3. 検索結果を要約し、ソース付きで返却

**重要**: プロンプトに「Use the google_web_search tool to search for:」を含める。
これにより Gemini が確実に Web 検索を実行する。

## 前提条件

- Gemini CLI がインストールされていること
- API キーが設定済みであること

### インストール方法

```bash
npm install -g @google/gemini-cli
```

または

```bash
brew install gemini-cli
```

## 用途別ガイド

### 技術調査

- ライブラリ・フレームワークの最新情報
- API ドキュメントの検索
- エラーメッセージの解決策

### 汎用リサーチ

- 一般的なトピックの調査
- 比較分析
- 市場動向

### ニュース・最新情報

- 最新リリース情報
- 業界ニュース
- トレンド把握

## 注意事項

- 機密情報を検索クエリに含めないこと
- API レート制限に注意
- 結果は要約されるため、詳細は元ソースを確認

## ドキュメント維持規則

**README.md と CLAUDE.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- コマンドの追加・変更・削除
- スキルの追加・変更・削除
- エージェントの追加・変更・削除
- plugin.json の変更（バージョン含む）
- 設計方針や動作の変更

### README.md の役割

- **対象**: ユーザー（プラグイン利用者）
- **内容**: インストール方法、使い方、機能一覧、使用例

### CLAUDE.md の役割

- **対象**: AI（Claude）と開発者
- **内容**: 設計方針、アーキテクチャ、内部構造、開発ルール

### 同期チェック

プラグイン変更時、フックにより README.md と CLAUDE.md の整合性がチェックされる。
不整合がある場合は警告が表示される。
