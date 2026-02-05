# web-search-unified プラグイン

Gemini CLI、Codex CLI、Claude WebSearch の3エンジンを並列実行し、結果を統合する高精度 Web 検索プラグイン。

## バージョン履歴

### v1.1.0
- 情報鮮度フィルタリング機能追加
- ドメイン別鮮度基準（AI/LLM は 6ヶ月、フロントエンドは 1年等）
- AI モデル旧世代情報の自動破棄（GPT-3.5以前、Claude 2以前等）
- 出力フォーマットに鮮度マーク（✓/⚠参考/古い情報）付与
- agents/unified-researcher.md に詳細版フィルタリング追加

### v1.0.0
- 初期リリース
- 3エンジン並列検索
- 結果統合と信頼度スコアリング
- `context: fork` 対応

## アーキテクチャ

```
ユーザークエリ
    │
    ├─→ parallel-search.sh（Bash バックグラウンド）
    │     ├─→ Gemini CLI &
    │     └─→ Codex CLI &
    │           └─→ wait
    │
    ├─→ WebSearch ツール（直接呼び出し）
    │
    └─→ 結果統合
          ├─→ URL 重複排除
          ├─→ 信頼度スコアリング
          └─→ レポート出力
```

## コンポーネント

| コンポーネント | 役割 |
|---------------|------|
| `scripts/parallel-search.sh` | Gemini + Codex 並列実行 |
| `skills/unified-search/` | 統合検索の実行手順 |
| `commands/search.md` | `/web-search-unified:search` コマンド |
| `agents/unified-researcher.md` | 包括的調査エージェント |

## 検索エンジン特性

| エンジン | 強み | 弱み |
|----------|------|------|
| Gemini | Google Search 直接、最新情報 | API キー必須 |
| Codex | 技術情報に強い | 検索機能は補助的 |
| WebSearch | 安定、Claude 組み込み | 結果数が限定的 |

## 信頼度スコアリング

| 条件 | スコア |
|------|--------|
| 複数エンジンで確認 | +2 |
| 公式ドメイン | +1 |
| 最新日付 | +1 |

## エラーハンドリング

- 1エンジン失敗: 残り2エンジンで継続
- 2エンジン失敗: 残り1エンジンで継続（警告付き）
- 全失敗: エラー報告と再試行案

**フォールバック優先度**: Gemini > WebSearch > Codex

## 前提条件

- Gemini CLI: `npm install -g @google/gemini-cli`（オプション）
- Codex CLI: `npm install -g @openai/codex`（オプション）
- 各 API キーの設定（使用するエンジンのみ）

**注意**: 全エンジンがなくても、利用可能なエンジンのみで動作する。
