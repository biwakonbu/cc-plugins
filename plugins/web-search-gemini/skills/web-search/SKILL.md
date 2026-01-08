---
name: web-search
description: Gemini CLI を使用した Web 検索を実行。技術情報、最新ニュース、一般的なリサーチに対応。Use when user asks to search the web, look up information, find recent news, or research a topic. Also use when user says 調べて, 検索して, 最新情報, ニュース, リサーチ.
allowed-tools: Bash
---

# Web Search スキル

Gemini CLI の `google_web_search` ツールを活用した Web 検索機能を提供。

## Instructions

### 1. 検索クエリの準備

ユーザーのリクエストから適切な検索クエリを構築する。

**クエリ最適化のポイント**:

- **技術調査**: 具体的な技術名、バージョン、「documentation」「official」を含める
  - 例: `"React 19 new features official documentation"`
- **エラー解決**: エラーメッセージをそのまま含め、「fix」「solution」を追加
  - 例: `"TypeError: Cannot read property 'map' of undefined fix React"`
- **最新情報**: 「latest」「2025」などの時間指定を含める
  - 例: `"TypeScript latest version features 2025"`
- **比較調査**: 比較対象を明確に、「vs」「comparison」を使用
  - 例: `"React vs Vue performance comparison 2025"`

### 2. Gemini CLI で検索実行

```bash
gemini --yolo "{検索クエリ}"
```

**フラグ説明**:
- `--yolo`: ツール実行の許可プロンプトをスキップ（自動実行）

**動作**:
1. Gemini が検索の必要性を自動判断
2. `google_web_search` ツールで Google 検索を実行
3. 検索結果を要約して返却

### 3. 結果のフォーマット

Gemini の応答を以下の形式で報告:

```markdown
## 検索結果: {クエリ}

### 要約
{主要なポイントを2-3文で}

### 詳細
{関連情報の詳細}

### ソース
- [タイトル1](URL1)
- [タイトル2](URL2)
- ...
```

### 4. エラーハンドリング

| エラー | 対処 |
|--------|------|
| Gemini CLI が見つからない | `gemini` コマンドのインストールを案内 |
| API エラー | 再試行、またはユーザーに報告 |
| 検索結果なし | クエリを変更して再検索を提案 |

## Examples

### 技術調査

**ユーザー**: 「Next.js 15 の新機能を調べて」

**実行**:
```bash
gemini --yolo "Next.js 15 new features official documentation"
```

**結果報告**:
```markdown
## 検索結果: Next.js 15 新機能

### 要約
Next.js 15 では、Turbopack がデフォルトの開発サーバーとして採用され...

### 詳細
- Turbopack: 開発時のビルド速度が大幅に向上
- React 19 対応: Server Components の強化
- ...

### ソース
- [Next.js 15 Blog](https://nextjs.org/blog/next-15)
- [Next.js Documentation](https://nextjs.org/docs)
```

### エラー解決

**ユーザー**: 「React で "Cannot read property 'map' of undefined" エラーが出る」

**実行**:
```bash
gemini --yolo "Cannot read property map of undefined React fix solution"
```

### 最新ニュース

**ユーザー**: 「AI 関連の最新ニュースを検索して」

**実行**:
```bash
gemini --yolo "AI artificial intelligence latest news today"
```

## 注意事項

- 機密情報（API キー、パスワード等）を検索クエリに含めない
- 検索結果は要約されるため、詳細は元ソースを確認
- 連続した大量の検索は API レート制限に注意
