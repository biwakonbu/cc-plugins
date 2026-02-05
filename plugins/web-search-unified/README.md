# web-search-unified

Gemini CLI、Codex CLI、Claude WebSearch の3つの検索エンジンを**並列実行**し、結果を統合する高精度 Web 検索プラグイン。

## 特徴

- 🔍 **並列検索**: 3エンジンを同時実行で高速
- 🎯 **高精度**: 複数ソースで確認された情報を高信頼としてマーク
- 🛡️ **フォールバック**: 一部エンジンが利用不可でも動作
- 📊 **統合レポート**: 信頼度付きの整理された結果

## インストール

```bash
# Claude Code にプラグインを追加
claude /install-plugin --source ./plugins/web-search-unified
```

### 前提条件（オプション）

全てのエンジンを使用する場合:

```bash
# Gemini CLI
npm install -g @google/gemini-cli
# API キー設定が必要

# Codex CLI
npm install -g @openai/codex
# API キー設定が必要
```

**注意**: WebSearch は Claude Code に組み込まれているため追加インストール不要。
一部のエンジンのみでも動作します。

## 使い方

### コマンド

```
/web-search-unified:search TypeScript 5.0 新機能
```

### スキル（自動発動）

「〜を調べて」「〜について検索」などのリクエストで unified-search スキルが発動。

### エージェント

包括的な調査が必要な場合、unified-researcher エージェントが利用可能。

## 出力例

```markdown
## 統合検索結果: TypeScript 5.0 新機能

### 要約
- const 型パラメータの導入
- デコレータの標準化
- 複数の設定ファイルの extends サポート
- enum の改善
- モジュール解決のバンドラーモード追加

### 高信頼度情報（複数エンジンで確認）
- [TypeScript 5.0 Release Notes](https://...) - 出典: Gemini, WebSearch

### エンジン別詳細
...

### ソース一覧
| ソース | URL | 検出エンジン | 信頼度 |
|--------|-----|-------------|--------|
| 公式ドキュメント | ... | Gemini, Codex, WebSearch | ⭐⭐⭐ |
```

## 検索エンジン比較

| エンジン | 強み | 用途 |
|----------|------|------|
| Gemini | Google Search 直接 | 最新情報、幅広い結果 |
| Codex | 技術情報に強い | プログラミング関連 |
| WebSearch | 安定性 | 一般的な検索 |

## 関連プラグイン

| プラグイン | 用途 | 推奨シーン |
|-----------|------|-----------|
| web-search-gemini | Gemini のみ | 高速・シンプル |
| web-search-codex | Codex 環境向け | Codex CLI 内 |
| **web-search-unified** | 並列統合 | **高精度・包括的** |

## ライセンス

MIT
