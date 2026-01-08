#!/bin/bash
# plugins/ 内のファイルをコミットする際に plugin.json のバージョン更新をチェック
#
# PreToolUse フックとして動作
# exit 0: 許可
# exit 2: ブロック

set -e

INPUT=$(cat)

# git commit コマンドかどうか判定
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)

if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
    exit 0
fi

# ステージングされたファイルを取得
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# plugins/ 内の変更されたプラグインを特定
CHANGED_PLUGINS=""
while IFS= read -r file; do
    if [[ "$file" =~ ^plugins/([^/]+)/ ]]; then
        PLUGIN_NAME="${BASH_REMATCH[1]}"
        if [[ ! " $CHANGED_PLUGINS " =~ " $PLUGIN_NAME " ]]; then
            CHANGED_PLUGINS="$CHANGED_PLUGINS $PLUGIN_NAME"
        fi
    fi
done <<< "$STAGED_FILES"

if [ -z "$CHANGED_PLUGINS" ]; then
    exit 0
fi

# 各プラグインについてバージョン更新をチェック
MISSING_VERSION_UPDATE=""
for PLUGIN in $CHANGED_PLUGINS; do
    PLUGIN_JSON="plugins/$PLUGIN/.claude-plugin/plugin.json"

    if ! echo "$STAGED_FILES" | grep -q "^$PLUGIN_JSON$"; then
        MISSING_VERSION_UPDATE="$MISSING_VERSION_UPDATE $PLUGIN"
    fi
done

if [ -n "$MISSING_VERSION_UPDATE" ]; then
    echo "以下のプラグインで plugin.json のバージョン更新が検出されませんでした:$MISSING_VERSION_UPDATE" >&2
    echo "バージョンを更新してから再度コミットしてください。" >&2
    exit 2
fi

exit 0
