---
description: Codex CLI 環境で Gemini CLI を使用して Web 検索を実行する。Use when user explicitly wants to search within Codex CLI.
allowed-tools: Bash
argument-hint: [search query]
---

# Web Search with Codex

`codex-web-search` スキルに従って、指定された検索クエリで Web 検索を実行してください。

検索クエリ: $ARGUMENTS

## 実行手順

1. 引数が空の場合は、何を検索するか確認する
2. `codex-web-search` スキルの手順に従って検索を実行
3. 結果をソース付きで報告
