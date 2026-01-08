#!/bin/bash
# プラグインコミット時のリントフック
#
# PreToolUse フックとして実行
# git commit で plugins/ 配下のファイルが含まれている場合にリントを実行

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

# ステージングされたファイルを確認
MARKETPLACE_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$MARKETPLACE_ROOT"

STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)

if [[ -z "$STAGED_FILES" ]]; then
    exit 0
fi

# plugins/ 配下のファイルがあるか確認
PLUGIN_FILES=$(echo "$STAGED_FILES" | grep "^plugins/" || true)

if [[ -z "$PLUGIN_FILES" ]]; then
    exit 0
fi

# 変更されたプラグインを特定
CHANGED_PLUGINS=$(echo "$PLUGIN_FILES" | sed 's|^plugins/\([^/]*\)/.*|\1|' | sort -u)

if [[ -z "$CHANGED_PLUGINS" ]]; then
    exit 0
fi

echo "プラグインの変更を検出しました。リントを実行します..."
echo ""

ERRORS=0
VALIDATE_SCRIPT="$MARKETPLACE_ROOT/plugins/plugin-generator/scripts/validate-plugin.sh"

# validate-plugin.sh が存在するか確認
if [[ ! -f "$VALIDATE_SCRIPT" ]]; then
    echo "Warning: validate-plugin.sh が見つかりません"
    echo "プラグインのリントをスキップします"
    exit 0
fi

for PLUGIN_NAME in $CHANGED_PLUGINS; do
    PLUGIN_PATH="$MARKETPLACE_ROOT/plugins/$PLUGIN_NAME"

    if [[ ! -d "$PLUGIN_PATH" ]]; then
        # 削除されたプラグインはスキップ
        continue
    fi

    echo "━━━ $PLUGIN_NAME ━━━"

    if ! "$VALIDATE_SCRIPT" "$PLUGIN_PATH"; then
        ERRORS=$((ERRORS + 1))
    fi

    echo ""
done

if [[ $ERRORS -gt 0 ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "プラグインのリントに失敗しました ($ERRORS 件のエラー)"
    echo "コミットをブロックします。"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 2
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "全てのプラグインのリントが成功しました"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0
