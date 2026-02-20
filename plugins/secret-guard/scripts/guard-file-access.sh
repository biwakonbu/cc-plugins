#!/bin/bash
# secret-guard: ファイルアクセスガード
# PreToolUse フックで Read/Write/Edit/Glob/Grep ツールをインターセプト
# シークレットファイルへのアクセスをブロックする

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/patterns.sh
source "${SCRIPT_DIR}/lib/patterns.sh"

# 設定ファイルを読み込み
load_config

# stdin から JSON を読み取り
INPUT=$(cat)

# ツール名を取得
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# ツールごとにファイルパスを抽出
extract_paths() {
    local paths=()

    case "$TOOL_NAME" in
        Read|Write|Edit)
            local file_path
            file_path=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
            if [ -n "$file_path" ]; then
                paths+=("$file_path")
            fi
            ;;
        Glob)
            local pattern
            pattern=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
            if [ -n "$pattern" ]; then
                # Glob パターンからディレクトリ部分を抽出してチェック
                paths+=("$pattern")
            fi
            local glob_path
            glob_path=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
            if [ -n "$glob_path" ]; then
                paths+=("$glob_path")
            fi
            ;;
        Grep)
            local grep_path
            grep_path=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
            if [ -n "$grep_path" ]; then
                paths+=("$grep_path")
            fi
            local grep_glob
            grep_glob=$(echo "$INPUT" | jq -r '.tool_input.glob // empty')
            if [ -n "$grep_glob" ]; then
                paths+=("$grep_glob")
            fi
            ;;
    esac

    if [ ${#paths[@]} -gt 0 ]; then
        printf '%s\n' "${paths[@]}"
    fi
}

# パスをチェック
check_paths() {
    local paths
    paths=$(extract_paths)

    if [ -z "$paths" ]; then
        exit 0
    fi

    while IFS= read -r filepath; do
        [ -z "$filepath" ] && continue

        if is_secret_path "$filepath"; then
            local reason
            reason=$(get_secret_reason "$filepath")

            # ブロック: jq で安全に JSON 生成
            jq -n \
                --arg reason "$reason" \
                --arg filepath "$filepath" \
                '{ decision: "block", systemMessage: "[secret-guard] ブロックしました: \($reason)\nファイル: \($filepath)\n\nシークレットファイルは AI が直接読み取ることができない対象です。\n操作が必要な場合は、ユーザー自身がターミナルで実行するか、\n/secret-guard:setup で生成されるテンプレートスクリプトを使用してください。" }'
            exit 0
        fi
    done <<< "$paths"

    # マッチしない場合は許可（何も出力せず正常終了）
    exit 0
}

check_paths
