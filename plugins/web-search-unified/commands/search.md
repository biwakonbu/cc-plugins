---
name: search
description: 統合 Web 検索を実行（Gemini + Codex + WebSearch 並列）
allowed-tools: Bash, WebSearch
---

# 統合 Web 検索コマンド

$ARGUMENTS の内容について、3つの検索エンジンを並列実行して徹底調査を行う。

## 実行内容

1. **並列検索の開始**
   - Gemini CLI と Codex CLI をバックグラウンドで並列実行
   - WebSearch ツールで同時に検索

2. **結果の統合**
   - 各エンジンの結果を収集
   - URL の重複を排除
   - 複数エンジンで確認された情報を高信頼としてマーク

3. **レポート出力**
   - 統合要約
   - 高信頼度情報のハイライト
   - エンジン別詳細
   - ソース一覧

## 検索クエリ

```
$ARGUMENTS
```

## 実行

unified-search スキルを使用して検索を実行してください。
