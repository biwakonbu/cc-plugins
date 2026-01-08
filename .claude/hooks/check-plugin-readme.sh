#!/bin/bash
# check-plugin-readme.sh - プラグインの README.md と CLAUDE.md の存在と最新性をチェック
#
# PreToolUse フックとして動作
# exit 0: 許可
# exit 2: ブロック
#
# 環境変数:
#   SKIP_README_CHECK=1  README チェックをスキップ

set -e

# 環境変数でスキップ可能
if [ "${SKIP_README_CHECK:-}" = "1" ]; then
    exit 0
fi

INPUT=$(cat)

# git commit コマンドかどうか判定
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | \
          sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)

if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
    exit 0
fi

# プロジェクトルートに移動
MARKETPLACE_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$MARKETPLACE_ROOT"

# ステージングされたファイルを取得
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# plugins/ 内の変更をチェック
if ! echo "$STAGED_FILES" | grep -q '^plugins/'; then
    exit 0
fi

# 変更されたプラグインを特定
CHANGED_PLUGINS=""
while IFS= read -r file; do
    case "$file" in
        plugins/*/*)
            PLUGIN_NAME=$(echo "$file" | sed 's|^plugins/\([^/]*\)/.*|\1|')
            if ! echo "$CHANGED_PLUGINS" | grep -q " $PLUGIN_NAME "; then
                CHANGED_PLUGINS="$CHANGED_PLUGINS $PLUGIN_NAME "
            fi
            ;;
    esac
done <<< "$STAGED_FILES"

# 各プラグインの README.md と CLAUDE.md をチェック
MISSING_README=""
MISSING_CLAUDEMD=""
OUTDATED_DOCS=""

for PLUGIN in $CHANGED_PLUGINS; do
    PLUGIN_DIR="plugins/$PLUGIN"
    README_FILE="$PLUGIN_DIR/README.md"
    CLAUDEMD_FILE="$PLUGIN_DIR/CLAUDE.md"
    PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

    # README.md の存在チェック
    if [ ! -f "$README_FILE" ]; then
        MISSING_README="$MISSING_README
- $PLUGIN/README.md"
    fi

    # CLAUDE.md の存在チェック
    if [ ! -f "$CLAUDEMD_FILE" ]; then
        MISSING_CLAUDEMD="$MISSING_CLAUDEMD
- $PLUGIN/CLAUDE.md"
    fi

    # plugin.json が変更されている場合、README.md と CLAUDE.md も更新されているかチェック
    if echo "$STAGED_FILES" | grep -q "^plugins/$PLUGIN/.claude-plugin/plugin.json$"; then
        README_STAGED=$(echo "$STAGED_FILES" | grep -c "^plugins/$PLUGIN/README.md$" || echo "0")
        CLAUDEMD_STAGED=$(echo "$STAGED_FILES" | grep -c "^plugins/$PLUGIN/CLAUDE.md$" || echo "0")

        if [ "$README_STAGED" = "0" ] && [ -f "$README_FILE" ]; then
            OUTDATED_DOCS="$OUTDATED_DOCS
- $PLUGIN/README.md (plugin.json 変更に伴う更新が必要)"
        fi
        if [ "$CLAUDEMD_STAGED" = "0" ] && [ -f "$CLAUDEMD_FILE" ]; then
            OUTDATED_DOCS="$OUTDATED_DOCS
- $PLUGIN/CLAUDE.md (plugin.json 変更に伴う更新が必要)"
        fi
    fi
done

# エラーメッセージを構築
ERROR_MSG=""

if [ -n "$MISSING_README" ]; then
    ERROR_MSG="$ERROR_MSG
### README.md が見つかりません
$MISSING_README
"
fi

if [ -n "$MISSING_CLAUDEMD" ]; then
    ERROR_MSG="$ERROR_MSG
### CLAUDE.md が見つかりません
$MISSING_CLAUDEMD
"
fi

if [ -n "$OUTDATED_DOCS" ]; then
    ERROR_MSG="$ERROR_MSG
### ドキュメントの更新が必要です
$OUTDATED_DOCS
"
fi

if [ -n "$ERROR_MSG" ]; then
    echo "## プラグインドキュメントの問題を検出
$ERROR_MSG
### 対応方法
1. 不足しているドキュメントを作成
2. 変更に合わせて既存ドキュメントを更新
3. 更新したファイルを \`git add\` でステージング
4. 再度コミットを実行

### スキップする場合
\`\`\`bash
SKIP_README_CHECK=1 git commit -m \"message\"
\`\`\`
" >&2
    exit 2
fi

exit 0
