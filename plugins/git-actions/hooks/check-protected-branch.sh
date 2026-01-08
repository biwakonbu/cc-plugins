#!/bin/bash
# git commit/push を main/develop ブランチで実行しようとした場合にブロックする
#
# PreToolUse フックとして動作
# stdin: JSON 形式のツール入力
# stdout: JSON レスポンス
# exit 2: ブロッキングエラー（アクション防止）
# exit 0: 許可

set -e

# stdin から JSON を読み取る
INPUT=$(cat)

# tool_input.command を抽出
if command -v jq &>/dev/null; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
else
    COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)
fi

# git commit または git push コマンドかどうか判定
if ! echo "$COMMAND" | grep -qE 'git\s+(commit|push)'; then
    # git commit/push 以外は許可
    exit 0
fi

# カレントブランチを取得
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if [ -z "$CURRENT_BRANCH" ]; then
    # ブランチが取得できない場合は許可（git リポジトリ外など）
    exit 0
fi

# main または develop ブランチかどうか判定
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "develop" ]; then
    # 環境変数での回避チェック
    if [ "${GIT_ACTIONS_ALLOW_PROTECTED_BRANCH:-}" = "1" ]; then
        exit 0
    fi

    # ブロックして警告メッセージを出力
    echo "⚠️ Protected branch: $CURRENT_BRANCH ブランチへの直接 commit/push はブロックされました。" >&2
    echo "フィーチャーブランチを作成してから作業してください。" >&2
    echo "" >&2
    echo "例: git checkout -b feature/your-feature-name" >&2
    exit 2
fi

# その他のブランチは許可
exit 0
