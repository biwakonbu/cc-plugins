#!/bin/bash
# marketplace.json コミット時のリントフック
#
# PreToolUse フックとして実行
# git commit で marketplace.json が含まれている場合にリントを実行

# stdin から JSON を読み取る
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Bash ツールで git commit の場合のみ処理
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

if ! echo "$COMMAND" | grep -q "git commit"; then
    exit 0
fi

# marketplace.json がステージングされているか確認
MARKETPLACE_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$MARKETPLACE_ROOT"

STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)

if ! echo "$STAGED_FILES" | grep -q "marketplace.json"; then
    exit 0
fi

# marketplace.json がステージングされている場合、リントを実行
echo "marketplace.json の変更を検出しました。リントを実行します..."
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINT_SCRIPT="$SCRIPT_DIR/../scripts/lint-marketplace.sh"

if [[ -f "$LINT_SCRIPT" ]]; then
    if ! bash "$LINT_SCRIPT"; then
        echo ""
        echo "marketplace.json のリントに失敗しました。コミットをブロックします。"
        exit 2
    fi
else
    echo "Warning: lint-marketplace.sh が見つかりません"
fi

exit 0
