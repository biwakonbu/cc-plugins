# web-search-gemini

Gemini CLI を活用した Claude Code 用 Web 検索プラグイン。技術調査、汎用リサーチ、最新情報取得に対応。

## インストール

```bash
claude plugin install web-search-gemini@cc-plugins
```

## 前提条件

Gemini CLI がインストールされ、認証設定が完了していること。

```bash
# インストール
npm install -g @google/gemini-cli

# 認証（いずれか）
gemini auth          # Google OAuth
export GEMINI_API_KEY=your_key  # API キー
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `/web-search-gemini:search` | 明示的に Web 検索を実行 |

## スキル

| スキル | 説明 |
|--------|------|
| `web-search` | 「調べて」「検索して」で自動発動する Web 検索 |

## エージェント

| エージェント | 説明 |
|-------------|------|
| `gemini-researcher` | 複雑な調査タスク（比較分析、レポート作成）を担当 |

## 使用例

```bash
# 明示的な検索
/web-search-gemini:search TypeScript 5.0 の新機能

# 自動発動（会話内で）
「React 19 について調べて」
「最新の Node.js LTS バージョンを検索して」
```

## 機能

### 自動発動

「調べて」「検索して」「リサーチして」などのキーワードで自動的に Web 検索スキルが発動。

### 複雑な調査タスク

複数の検索を組み合わせた比較分析やレポート作成には、`gemini-researcher` エージェントが自動的に使用される。

### 対応する調査タイプ

- **技術調査**: ライブラリ、フレームワーク、API ドキュメント
- **汎用リサーチ**: 一般的なトピック、比較分析、市場動向
- **ニュース**: 最新リリース、業界ニュース、トレンド

## アーキテクチャ

```
ユーザーリクエスト
    │
    ├─→ 単純な検索「〜を調べて」
    │     └─→ web-search スキル（自動発動）
    │
    ├─→ 明示的な検索
    │     └─→ /web-search-gemini:search
    │
    └─→ 複雑な調査タスク
          └─→ gemini-researcher エージェント
                └─→ 複数検索 + 分析 + レポート
```

## 注意事項

- 機密情報を検索クエリに含めないこと
- API レート制限に注意
- 結果は要約されるため、詳細は元ソースを確認

## ライセンス

MIT
