#!/bin/bash
# generate-plugin.sh のテスト
# Usage: test-generate.sh

# set -e を使わない（テスト対象のエラーを捕捉するため）

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"
GENERATE_SCRIPT="$PLUGIN_ROOT/scripts/generate-plugin.sh"

# テスト用の一時ディレクトリ
TEST_PLUGIN_NAME="test-plugin-$(date +%s)"
TEST_PLUGIN_DIR="$MARKETPLACE_ROOT/plugins/$TEST_PLUGIN_NAME"

# クリーンアップ関数
cleanup() {
    # テストプラグインを削除
    if [[ -d "$TEST_PLUGIN_DIR" ]]; then
        rm -rf "$TEST_PLUGIN_DIR"
    fi
    # marketplace.json からエントリを削除
    if command -v jq &> /dev/null; then
        jq --arg name "$TEST_PLUGIN_NAME" 'del(.plugins[] | select(.name == $name))' \
            "$MARKETPLACE_ROOT/.claude-plugin/marketplace.json" > "${MARKETPLACE_ROOT}/.claude-plugin/marketplace.json.tmp" \
            && mv "${MARKETPLACE_ROOT}/.claude-plugin/marketplace.json.tmp" "$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"
    fi
}

# テスト終了時にクリーンアップ
trap cleanup EXIT

ERRORS=0

assert_file_exists() {
    local file="$1"
    local desc="$2"
    if [[ -f "$file" ]]; then
        echo "  ✓ $desc"
    else
        echo "  ✗ $desc: ファイルが存在しません"
        ((ERRORS++))
    fi
}

assert_dir_exists() {
    local dir="$1"
    local desc="$2"
    if [[ -d "$dir" ]]; then
        echo "  ✓ $desc"
    else
        echo "  ✗ $desc: ディレクトリが存在しません"
        ((ERRORS++))
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    local desc="$3"
    if grep -q "$pattern" "$file"; then
        echo "  ✓ $desc"
    else
        echo "  ✗ $desc: パターンが見つかりません"
        ((ERRORS++))
    fi
}

assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local desc="$3"
    if [[ "$actual" -eq "$expected" ]]; then
        echo "  ✓ $desc"
    else
        echo "  ✗ $desc: 終了コード $actual (expected: $expected)"
        ((ERRORS++))
    fi
}

echo "=== Test: generate-plugin.sh ==="
echo ""

# --- Test 1: 正常系 - プラグイン生成 ---
echo "Test 1: 正常系 - プラグイン生成"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$GENERATE_SCRIPT" "$TEST_PLUGIN_NAME" > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_dir_exists "$TEST_PLUGIN_DIR" "プラグインディレクトリ作成"
assert_dir_exists "$TEST_PLUGIN_DIR/.claude-plugin" ".claude-plugin ディレクトリ作成"
assert_dir_exists "$TEST_PLUGIN_DIR/commands" "commands ディレクトリ作成"
assert_file_exists "$TEST_PLUGIN_DIR/.claude-plugin/plugin.json" "plugin.json 作成"
assert_file_exists "$TEST_PLUGIN_DIR/CLAUDE.md" "CLAUDE.md 作成"
assert_file_exists "$TEST_PLUGIN_DIR/commands/hello.md" "hello.md 作成"
assert_contains "$TEST_PLUGIN_DIR/.claude-plugin/plugin.json" "\"name\": \"$TEST_PLUGIN_NAME\"" "plugin.json に正しい name"
assert_contains "$TEST_PLUGIN_DIR/commands/hello.md" "allowed-tools:" "hello.md に allowed-tools"

# marketplace.json に登録されているか確認
if command -v jq &> /dev/null; then
    REGISTERED=$(jq -r --arg name "$TEST_PLUGIN_NAME" '.plugins[] | select(.name == $name) | .name' "$MARKETPLACE_ROOT/.claude-plugin/marketplace.json")
    if [[ "$REGISTERED" == "$TEST_PLUGIN_NAME" ]]; then
        echo "  ✓ marketplace.json に登録"
    else
        echo "  ✗ marketplace.json に登録されていません"
        ((ERRORS++))
    fi
fi

echo ""

# --- Test 2: エラー系 - 重複プラグイン ---
echo "Test 2: エラー系 - 重複プラグイン"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$GENERATE_SCRIPT" "$TEST_PLUGIN_NAME" > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（重複エラー）"

echo ""

# --- Test 3: エラー系 - 不正な名前（大文字） ---
echo "Test 3: エラー系 - 不正な名前（大文字）"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$GENERATE_SCRIPT" "InvalidName" > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（不正な名前）"

echo ""

# --- Test 4: エラー系 - 引数なし ---
echo "Test 4: エラー系 - 引数なし"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$GENERATE_SCRIPT" > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（引数なし）"

echo ""

# 結果
if [[ $ERRORS -gt 0 ]]; then
    echo "Errors: $ERRORS"
    exit 1
else
    echo "All assertions passed"
    exit 0
fi
