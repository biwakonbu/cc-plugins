# web-search-codex

Codex CLI 内で Gemini CLI を活用した Web 検索プラグイン。

## 概要

Codex CLI の実行環境内から Gemini CLI の `google_web_search` ツールを呼び出し、
リアルタイムの Web 検索を実行します。`--full-auto` モードとの組み合わせで、
自動的な情報収集とタスク実行が可能です。

## 前提条件

以下のツールがインストールされている必要があります:

### Codex CLI

```bash
npm install -g @openai/codex
```

### Gemini CLI

```bash
npm install -g @google/gemini-cli
# または
brew install gemini-cli
```

### API キー

- Gemini API キーが設定済みであること

## インストール

```bash
/plugin install web-search-codex@marketplace
```

## 機能

### スキル: codex-web-search

「調べて」「検索して」などのキーワードで自動発動する Web 検索機能。

**自動発動トリガー**:
- 調べて、検索して、最新情報、ニュース、リサーチ
- search, look up, research

**使用例**:
```
TypeScript 5.0 の新機能を調べて
```

### コマンド: /web-search-codex:search

明示的に Web 検索を実行するスラッシュコマンド。

**使用例**:
```
/web-search-codex:search React 19 new features
```

### エージェント: codex-researcher

複雑な調査タスク用のサブエージェント。
複数の検索を組み合わせた分析・レポート作成に対応。

**用途**:
- 技術比較調査
- トレンド分析
- 市場調査
- 問題解決のための情報収集

## 使い方

### Codex インタラクティブモード

```bash
codex
> TypeScript 5.0 の新機能を調べて
# → スキルが自動発動 → Web 検索実行
```

### Codex Full Auto モード

```bash
codex --full-auto "React 19 の新機能を調べて、実装サンプルを作成"
# → 自動で検索 → 情報取得 → コード生成
```

### 明示的コマンド

```bash
/web-search-codex:search Next.js 15 new features
```

## 検索のコツ

### 技術調査

```
# 具体的な技術名とバージョンを含める
Next.js 15 の新機能を調べて

# 「official」「documentation」で公式情報を優先
TypeScript 5.0 公式ドキュメントを検索して
```

### エラー解決

```
# エラーメッセージをそのまま含める
"Cannot read property 'map' of undefined" React fix を検索して
```

### 比較調査

```
# 比較対象を明確に
React vs Vue vs Svelte を比較調査して
```

## 出力形式

検索結果は以下の形式で報告されます:

```markdown
## 検索結果: {クエリ}

### 要約
主要なポイントの要約

### 詳細
関連情報の詳細

### ソース
- [タイトル1](URL1)
- [タイトル2](URL2)
```

## web-search-gemini との違い

| 項目 | web-search-codex | web-search-gemini |
|------|------------------|-------------------|
| 対象環境 | Codex CLI | Claude Code |
| 統合 | Codex --full-auto | Claude Code 直接 |
| 用途 | Codex 内での検索 | Claude Code 内での検索 |

## 注意事項

- 機密情報（API キー、パスワード等）を検索クエリに含めないでください
- 連続した大量の検索は API レート制限に注意してください
- 検索結果は要約されるため、詳細は元ソースを確認してください

## ライセンス

MIT License
