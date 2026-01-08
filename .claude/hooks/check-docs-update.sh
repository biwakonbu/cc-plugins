#!/bin/bash
# plugins/ 内のコンポーネント変更時にドキュメント更新をチェック
#
# PreToolUse フックとして動作
# exit 0: 許可
# exit 2: ブロック
#
# 環境変数:
#   SKIP_DOCS_CHECK=1  ドキュメントチェックをスキップ

set -e

# 環境変数でスキップ可能
if [ "${SKIP_DOCS_CHECK:-}" = "1" ]; then
    exit 0
fi

INPUT=$(cat)

# git commit コマンドかどうか判定
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | \
          sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)

if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
    exit 0
fi

# ステージングされたファイルを取得
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# plugins/ 内の変更されたプラグインを特定（POSIX 互換）
PLUGIN_CHANGES=""
PLUGIN_DOC_UPDATED=""

while IFS= read -r file; do
    # plugins/{name}/ パターンを抽出
    case "$file" in
        plugins/*/*)
            PLUGIN_NAME=$(echo "$file" | sed 's|^plugins/\([^/]*\)/.*|\1|')

            # ドキュメントファイル自体の更新を記録
            case "$file" in
                plugins/$PLUGIN_NAME/CLAUDE.md|plugins/$PLUGIN_NAME/README.md)
                    if ! echo "$PLUGIN_DOC_UPDATED" | grep -q " $PLUGIN_NAME "; then
                        PLUGIN_DOC_UPDATED="$PLUGIN_DOC_UPDATED $PLUGIN_NAME "
                    fi
                    continue
                    ;;
            esac

            # plugin.json のみの変更はスキップ
            case "$file" in
                plugins/$PLUGIN_NAME/.claude-plugin/plugin.json)
                    continue
                    ;;
            esac

            # コンポーネント変更を記録
            case "$file" in
                plugins/$PLUGIN_NAME/commands/*|plugins/$PLUGIN_NAME/skills/*|plugins/$PLUGIN_NAME/agents/*|plugins/$PLUGIN_NAME/hooks/*)
                    if ! echo "$PLUGIN_CHANGES" | grep -q " $PLUGIN_NAME "; then
                        PLUGIN_CHANGES="$PLUGIN_CHANGES $PLUGIN_NAME "
                    fi
                    ;;
            esac
            ;;
    esac
done <<< "$STAGED_FILES"

# コンポーネント変更があるプラグインでドキュメント未更新をチェック
MISSING_DOCS=""
for PLUGIN in $PLUGIN_CHANGES; do
    if ! echo "$PLUGIN_DOC_UPDATED" | grep -q " $PLUGIN "; then
        MISSING_DOCS="$MISSING_DOCS
- $PLUGIN"
    fi
done

if [ -n "$MISSING_DOCS" ]; then
    echo "## ドキュメント更新が必要です

以下のプラグインでコンポーネント（commands/skills/agents/hooks）が変更されましたが、ドキュメントが更新されていません:
$MISSING_DOCS

### 対応方法
1. 各プラグインの \`CLAUDE.md\` または \`README.md\` を更新
2. 更新したファイルを \`git add\` でステージング
3. 再度コミットを実行

### スキップする場合
\`\`\`bash
SKIP_DOCS_CHECK=1 git commit -m \"message\"
\`\`\`
" >&2
    exit 2
fi

exit 0
