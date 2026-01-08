#!/bin/bash
# add-component.sh のテスト
# Usage: test-add-component.sh

# set -e を使わない（テスト対象のエラーを捕捉するため）

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"
ADD_SCRIPT="$PLUGIN_ROOT/scripts/add-component.sh"

# テスト用の一時ディレクトリ
TEST_DIR=$(mktemp -d)

# クリーンアップ関数
cleanup() {
    rm -rf "$TEST_DIR"
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

echo "=== Test: add-component.sh ==="
echo ""

# テスト用プラグイン作成
TEST_PLUGIN="$TEST_DIR/test-plugin"
mkdir -p "$TEST_PLUGIN/.claude-plugin"
echo '{"name": "test-plugin", "version": "1.0.0"}' > "$TEST_PLUGIN/.claude-plugin/plugin.json"

# --- Test 1: コマンド追加 ---
echo "Test 1: コマンド追加"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" command my-command > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_dir_exists "$TEST_PLUGIN/commands" "commands ディレクトリ作成"
assert_file_exists "$TEST_PLUGIN/commands/my-command.md" "my-command.md 作成"
assert_contains "$TEST_PLUGIN/commands/my-command.md" "description:" "description フィールド"
assert_contains "$TEST_PLUGIN/commands/my-command.md" "allowed-tools:" "allowed-tools フィールド"

echo ""

# --- Test 2: スキル追加 ---
echo "Test 2: スキル追加"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" skill my-skill > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_dir_exists "$TEST_PLUGIN/skills/my-skill" "skills/my-skill ディレクトリ作成"
assert_file_exists "$TEST_PLUGIN/skills/my-skill/SKILL.md" "SKILL.md 作成"
assert_contains "$TEST_PLUGIN/skills/my-skill/SKILL.md" "name:" "name フィールド"
assert_contains "$TEST_PLUGIN/skills/my-skill/SKILL.md" "description:" "description フィールド"
assert_contains "$TEST_PLUGIN/skills/my-skill/SKILL.md" "allowed-tools:" "allowed-tools フィールド"

echo ""

# --- Test 3: エージェント追加 ---
echo "Test 3: エージェント追加"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" agent my-agent > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_dir_exists "$TEST_PLUGIN/agents" "agents ディレクトリ作成"
assert_file_exists "$TEST_PLUGIN/agents/my-agent.md" "my-agent.md 作成"
assert_contains "$TEST_PLUGIN/agents/my-agent.md" "name:" "name フィールド"
assert_contains "$TEST_PLUGIN/agents/my-agent.md" "description:" "description フィールド"
assert_contains "$TEST_PLUGIN/agents/my-agent.md" "tools:" "tools フィールド"

echo ""

# --- Test 4: フック追加 ---
echo "Test 4: フック追加"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" hook init > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 0 $EXIT_CODE "終了コード 0"
assert_dir_exists "$TEST_PLUGIN/hooks" "hooks ディレクトリ作成"
assert_file_exists "$TEST_PLUGIN/hooks/hooks.json" "hooks.json 作成"

# JSON 構文チェック
if command -v jq &> /dev/null; then
    if jq empty "$TEST_PLUGIN/hooks/hooks.json" 2>/dev/null; then
        echo "  ✓ hooks.json 有効な JSON"
    else
        echo "  ✗ hooks.json 無効な JSON"
        ((ERRORS++))
    fi
fi

echo ""

# --- Test 5: エラー系 - プラグインルートでない ---
echo "Test 5: エラー系 - プラグインルートでない"
cd "$TEST_DIR"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" command test > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（プラグインルートでない）"

echo ""

# --- Test 6: エラー系 - 不正な名前 ---
echo "Test 6: エラー系 - 不正な名前"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" command "Invalid Name" > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（不正な名前）"

echo ""

# --- Test 7: エラー系 - 重複コンポーネント ---
echo "Test 7: エラー系 - 重複コンポーネント"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" command my-command > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（重複）"

echo ""

# --- Test 8: エラー系 - 不明なコンポーネント種別 ---
echo "Test 8: エラー系 - 不明なコンポーネント種別"
cd "$TEST_PLUGIN"
CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" "$ADD_SCRIPT" unknown test > /dev/null 2>&1
EXIT_CODE=$?

assert_exit_code 1 $EXIT_CODE "終了コード 1（不明な種別）"

echo ""

# 結果
if [[ $ERRORS -gt 0 ]]; then
    echo "Errors: $ERRORS"
    exit 1
else
    echo "All assertions passed"
    exit 0
fi
