#!/bin/bash
# validate-plugin.sh のテスト
# Usage: test-validate.sh

# set -e を使わない（テスト対象のエラーを捕捉するため）

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"
VALIDATE_SCRIPT="$PLUGIN_ROOT/scripts/validate-plugin.sh"

# テスト用の一時ディレクトリ
TEST_DIR=$(mktemp -d)

# クリーンアップ関数
cleanup() {
    rm -rf "$TEST_DIR"
}

# テスト終了時にクリーンアップ
trap cleanup EXIT

ERRORS=0

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

assert_output_contains() {
    local output="$1"
    local pattern="$2"
    local desc="$3"
    if echo "$output" | grep -q "$pattern"; then
        echo "  ✓ $desc"
    else
        echo "  ✗ $desc: パターン '$pattern' が見つかりません"
        ((ERRORS++))
    fi
}

echo "=== Test: validate-plugin.sh ==="
echo ""

# --- Test 1: 正常系 - 有効なプラグイン ---
echo "Test 1: 正常系 - 有効なプラグイン（plugin-generator 自身）"
OUTPUT=$("$VALIDATE_SCRIPT" "$PLUGIN_ROOT" 2>&1)
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_output_contains "$OUTPUT" "PASSED" "PASSED メッセージ"

echo ""

# --- Test 2: エラー系 - plugin.json なし ---
echo "Test 2: エラー系 - plugin.json なし"
mkdir -p "$TEST_DIR/no-plugin-json"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/no-plugin-json" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "ERROR" "ERROR メッセージ"
assert_output_contains "$OUTPUT" "plugin.json" "plugin.json エラー"

echo ""

# --- Test 3: エラー系 - name フィールドなし ---
echo "Test 3: エラー系 - name フィールドなし"
mkdir -p "$TEST_DIR/no-name/.claude-plugin"
echo '{"version": "1.0.0"}' > "$TEST_DIR/no-name/.claude-plugin/plugin.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/no-name" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "name" "name エラー"

echo ""

# --- Test 4: 警告系 - version フィールドなし ---
echo "Test 4: 警告系 - version フィールドなし"
mkdir -p "$TEST_DIR/no-version/.claude-plugin"
echo '{"name": "test-plugin"}' > "$TEST_DIR/no-version/.claude-plugin/plugin.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/no-version" 2>&1)
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0（警告のみ）"
assert_output_contains "$OUTPUT" "WARNING" "WARNING メッセージ"
assert_output_contains "$OUTPUT" "version" "version 警告"

echo ""

# --- Test 5: エラー系 - コマンドに description なし ---
echo "Test 5: エラー系 - コマンドに description なし"
mkdir -p "$TEST_DIR/no-desc/.claude-plugin"
mkdir -p "$TEST_DIR/no-desc/commands"
echo '{"name": "test-plugin", "version": "1.0.0", "commands": "./commands/"}' > "$TEST_DIR/no-desc/.claude-plugin/plugin.json"
echo -e "---\n---\n# Test" > "$TEST_DIR/no-desc/commands/test.md"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/no-desc" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "description" "description エラー"

echo ""

# --- Test 6: 警告系 - コマンドに allowed-tools なし ---
echo "Test 6: 警告系 - コマンドに allowed-tools なし"
mkdir -p "$TEST_DIR/no-tools/.claude-plugin"
mkdir -p "$TEST_DIR/no-tools/commands"
echo '{"name": "test-plugin", "version": "1.0.0", "commands": "./commands/"}' > "$TEST_DIR/no-tools/.claude-plugin/plugin.json"
echo -e "---\ndescription: test\n---\n# Test" > "$TEST_DIR/no-tools/commands/test.md"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/no-tools" 2>&1)
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0（警告のみ）"
assert_output_contains "$OUTPUT" "allowed-tools" "allowed-tools 警告"

echo ""

# --- Test 7: エラー系 - スキルに name なし ---
echo "Test 7: エラー系 - スキルに name なし"
mkdir -p "$TEST_DIR/skill-no-name/.claude-plugin"
mkdir -p "$TEST_DIR/skill-no-name/skills/test"
echo '{"name": "test-plugin", "version": "1.0.0", "skills": "./skills/"}' > "$TEST_DIR/skill-no-name/.claude-plugin/plugin.json"
echo -e "---\ndescription: test skill\n---\n# Test" > "$TEST_DIR/skill-no-name/skills/test/SKILL.md"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/skill-no-name" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "name" "name エラー"

echo ""

# --- Test 8: 正常系 - 完全なスキル ---
echo "Test 8: 正常系 - 完全なスキル"
mkdir -p "$TEST_DIR/valid-skill/.claude-plugin"
mkdir -p "$TEST_DIR/valid-skill/skills/test"
echo '{"name": "test-plugin", "version": "1.0.0", "skills": "./skills/"}' > "$TEST_DIR/valid-skill/.claude-plugin/plugin.json"
echo -e "---\nname: test-skill\ndescription: test skill\nallowed-tools: Read, Glob\n---\n# Test" > "$TEST_DIR/valid-skill/skills/test/SKILL.md"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/valid-skill" 2>&1)
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_output_contains "$OUTPUT" "PASSED" "PASSED メッセージ"

echo ""

# --- Test 9: エラー系 - 無効な JSON (hooks.json) ---
echo "Test 9: エラー系 - 無効な JSON (hooks.json)"
mkdir -p "$TEST_DIR/invalid-json/.claude-plugin"
mkdir -p "$TEST_DIR/invalid-json/hooks"
echo '{"name": "test-plugin", "version": "1.0.0", "hooks": "./hooks/hooks.json"}' > "$TEST_DIR/invalid-json/.claude-plugin/plugin.json"
echo 'invalid json {' > "$TEST_DIR/invalid-json/hooks/hooks.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/invalid-json" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "JSON" "JSON エラー"

echo ""

# --- Test 10: エラー系 - パス整合性エラー ---
echo "Test 10: エラー系 - パス整合性エラー（存在しないディレクトリ参照）"
mkdir -p "$TEST_DIR/path-error/.claude-plugin"
echo '{"name": "test-plugin", "version": "1.0.0", "commands": "./commands/"}' > "$TEST_DIR/path-error/.claude-plugin/plugin.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/path-error" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "commands" "パス整合性エラー"

echo ""

echo "Test 11: エラー系 - hooks 重複エラー（標準パスを明示指定）"
mkdir -p "$TEST_DIR/hooks-dup/.claude-plugin"
mkdir -p "$TEST_DIR/hooks-dup/hooks"
echo '{"name": "test-plugin", "version": "1.0.0", "hooks": "./hooks/hooks.json"}' > "$TEST_DIR/hooks-dup/.claude-plugin/plugin.json"
echo '{"hooks": {}}' > "$TEST_DIR/hooks-dup/hooks/hooks.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$TEST_DIR/hooks-dup" 2>&1)
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1"
assert_output_contains "$OUTPUT" "自動ロード" "hooks 重複エラー検知"

echo ""

# 結果
if [[ $ERRORS -gt 0 ]]; then
    echo "Errors: $ERRORS"
    exit 1
else
    echo "All assertions passed"
    exit 0
fi
