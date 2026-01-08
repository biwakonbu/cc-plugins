#!/bin/bash
# 全テスト実行スクリプト
# Usage: run-all-tests.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

echo "═══════════════════════════════════════════════════════════"
echo "Plugin Generator - Test Suite"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Plugin Root: $PLUGIN_ROOT"
echo "Marketplace Root: $MARKETPLACE_ROOT"
echo ""

run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)

    echo -e "${BLUE}Running: $test_name${NC}"

    if bash "$test_file"; then
        echo -e "${GREEN}✅ $test_name: PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $test_name: FAILED${NC}"
        ((FAILED++))
    fi
    echo ""
}

# テスト実行
for test_file in "$SCRIPT_DIR"/test-*.sh; do
    if [[ -f "$test_file" ]]; then
        run_test "$test_file"
    fi
done

# 結果サマリー
echo "═══════════════════════════════════════════════════════════"
echo "Test Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "  Passed: ${GREEN}$PASSED${NC}"
echo -e "  Failed: ${RED}$FAILED${NC}"
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    exit 0
fi
