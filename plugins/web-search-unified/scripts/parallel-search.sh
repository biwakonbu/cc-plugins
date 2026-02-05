#!/bin/bash
# parallel-search.sh - Gemini CLI と Codex CLI を並列実行して結果を取得
#
# 使用方法:
#   ./parallel-search.sh "検索クエリ"
#
# 出力: JSON 形式で各エンジンの結果を出力

set -euo pipefail

QUERY="${1:-}"
TIMEOUT=60
OUTPUT_DIR="${TMPDIR:-/tmp}/web-search-unified-$$"

if [[ -z "$QUERY" ]]; then
  echo '{"error": "クエリが指定されていません", "usage": "./parallel-search.sh \"検索クエリ\""}' >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# 各エンジンの検出フラグ
HAS_GEMINI=false
HAS_CODEX=false

if command -v gemini &>/dev/null; then
  HAS_GEMINI=true
fi

if command -v codex &>/dev/null; then
  HAS_CODEX=true
fi

# 結果を格納するファイル
GEMINI_RESULT="$OUTPUT_DIR/gemini.json"
CODEX_RESULT="$OUTPUT_DIR/codex.json"

# Gemini CLI で検索（バックグラウンド実行）
run_gemini() {
  if [[ "$HAS_GEMINI" == "true" ]]; then
    timeout "$TIMEOUT" gemini --yolo "Use google_web_search tool to search for: $QUERY. Return the results in a structured format with title, url, and snippet for each result." 2>/dev/null | tee "$GEMINI_RESULT.raw" || true

    # 結果を JSON 化
    if [[ -s "$GEMINI_RESULT.raw" ]]; then
      echo "{\"engine\": \"gemini\", \"status\": \"success\", \"raw_output\": $(cat "$GEMINI_RESULT.raw" | jq -Rs .)}" > "$GEMINI_RESULT"
    else
      echo '{"engine": "gemini", "status": "no_output", "raw_output": ""}' > "$GEMINI_RESULT"
    fi
  else
    echo '{"engine": "gemini", "status": "not_installed", "raw_output": ""}' > "$GEMINI_RESULT"
  fi
}

# Codex CLI で検索（バックグラウンド実行）
run_codex() {
  if [[ "$HAS_CODEX" == "true" ]]; then
    timeout "$TIMEOUT" codex -q "Search the web for: $QUERY. Provide comprehensive results with sources." 2>/dev/null | tee "$CODEX_RESULT.raw" || true

    # 結果を JSON 化
    if [[ -s "$CODEX_RESULT.raw" ]]; then
      echo "{\"engine\": \"codex\", \"status\": \"success\", \"raw_output\": $(cat "$CODEX_RESULT.raw" | jq -Rs .)}" > "$CODEX_RESULT"
    else
      echo '{"engine": "codex", "status": "no_output", "raw_output": ""}' > "$CODEX_RESULT"
    fi
  else
    echo '{"engine": "codex", "status": "not_installed", "raw_output": ""}' > "$CODEX_RESULT"
  fi
}

# 並列実行
run_gemini &
GEMINI_PID=$!

run_codex &
CODEX_PID=$!

# 完了待機
wait $GEMINI_PID 2>/dev/null || true
wait $CODEX_PID 2>/dev/null || true

# 結果を統合して出力
echo "{"
echo "  \"query\": $(echo "$QUERY" | jq -Rs .),"
echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
echo "  \"engines\": {"
echo "    \"gemini_available\": $HAS_GEMINI,"
echo "    \"codex_available\": $HAS_CODEX"
echo "  },"
echo "  \"results\": ["

# Gemini 結果
if [[ -f "$GEMINI_RESULT" ]]; then
  cat "$GEMINI_RESULT"
else
  echo '{"engine": "gemini", "status": "failed", "raw_output": ""}'
fi

echo ","

# Codex 結果
if [[ -f "$CODEX_RESULT" ]]; then
  cat "$CODEX_RESULT"
else
  echo '{"engine": "codex", "status": "failed", "raw_output": ""}'
fi

echo "  ]"
echo "}"

# クリーンアップ
rm -rf "$OUTPUT_DIR"
