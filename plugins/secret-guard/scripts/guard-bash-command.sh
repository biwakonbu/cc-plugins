#!/bin/bash
# secret-guard: Bash コマンドガード
# PreToolUse フックで Bash ツールをインターセプト
# シークレットファイルへのアクセスやgit操作をブロックする

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/patterns.sh
source "${SCRIPT_DIR}/lib/patterns.sh"

# 設定ファイルを読み込み
load_config

# stdin から JSON を読み取り
INPUT=$(cat)

# コマンド文字列を取得
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# ブロックメッセージを出力して終了（jq で安全に JSON 生成）
block_with_message() {
    local reason="$1"
    local detail="$2"
    jq -n \
        --arg reason "$reason" \
        --arg detail "$detail" \
        '{ decision: "block", systemMessage: "[secret-guard] ブロックしました: \($reason)\n\($detail)\n\nシークレットファイルは AI が直接操作できない対象です。\n操作が必要な場合は、ユーザー自身がターミナルで実行してください。" }'
    exit 0
}

# コマンドからファイル引数を抽出してシークレットチェック
check_file_access_command() {
    for cmd in "${FILE_ACCESS_COMMANDS[@]}"; do
        # コマンドがファイルアクセスコマンドで始まるか、パイプ後に含まれるかチェック
        if echo "$COMMAND" | grep -qE "(^|[;&|]\s*)${cmd}\s+"; then
            # コマンド引数からファイルパスを抽出
            local args
            args=$(echo "$COMMAND" | grep -oE "(^|[;&|]\s*)${cmd}\s+[^;&|]+" | sed "s/.*${cmd}\s\+//" | tr ' ' '\n')

            while IFS= read -r arg; do
                [ -z "$arg" ] && continue
                # オプション引数はスキップ
                [[ "$arg" == -* ]] && continue
                # リダイレクトはスキップ
                [[ "$arg" == ">" ]] || [[ "$arg" == ">>" ]] && continue

                if is_secret_path "$arg"; then
                    local reason
                    reason=$(get_secret_reason "$arg")
                    block_with_message "${cmd} による${reason}へのアクセス" "コマンド: ${COMMAND}"
                fi
            done <<< "$args"
        fi
    done
}

# curl でシークレットファイルをデータとして送信するパターンをチェック
check_curl_data_upload() {
    if echo "$COMMAND" | grep -qE "curl\s+.*(-d|--data|--data-binary|--data-raw|--data-urlencode)\s+@"; then
        local file_refs
        file_refs=$(echo "$COMMAND" | grep -oE '@[^ ]+' | sed 's/^@//')

        while IFS= read -r filepath; do
            [ -z "$filepath" ] && continue
            if is_secret_path "$filepath"; then
                local reason
                reason=$(get_secret_reason "$filepath")
                block_with_message "curl によるシークレットファイルのアップロード" "ファイル: ${filepath} (${reason})"
            fi
        done <<< "$file_refs"
    fi
}

# git add でシークレットファイルをステージングするパターンをチェック
check_git_add() {
    if echo "$COMMAND" | grep -qE "(^|[;&|]\s*)git\s+add\s+"; then
        local files
        files=$(echo "$COMMAND" | grep -oE "(^|[;&|]\s*)git\s+add\s+[^;&|]+" | sed 's/.*git\s\+add\s\+//' | tr ' ' '\n')

        while IFS= read -r filepath; do
            [ -z "$filepath" ] && continue
            [[ "$filepath" == -* ]] && continue

            # -A や . は特別扱い（ステージング内容を後でチェック）
            if [[ "$filepath" == "." ]] || [[ "$filepath" == "-A" ]] || [[ "$filepath" == "--all" ]]; then
                continue
            fi

            if is_secret_path "$filepath"; then
                local reason
                reason=$(get_secret_reason "$filepath")
                block_with_message "git add による${reason}のステージング" "ファイル: ${filepath}"
            fi
        done <<< "$files"
    fi
}

# git commit 時にステージング済みのシークレットをチェック
check_git_commit() {
    if echo "$COMMAND" | grep -qE "(^|[;&|]\s*)git\s+commit\s*"; then
        # ステージング済みファイルを取得
        local staged_files
        staged_files=$(git diff --cached --name-only 2>/dev/null || true)

        if [ -z "$staged_files" ]; then
            return
        fi

        while IFS= read -r filepath; do
            [ -z "$filepath" ] && continue
            if is_secret_path "$filepath"; then
                local reason
                reason=$(get_secret_reason "$filepath")
                block_with_message "ステージングにシークレットファイルが含まれています" "ファイル: ${filepath} (${reason})\n\ngit reset HEAD ${filepath} でステージングから除外してください。"
            fi
        done <<< "$staged_files"
    fi
}

# git push 時にステージング済みまたは直近コミットのシークレットをチェック
check_git_push() {
    if echo "$COMMAND" | grep -qE "(^|[;&|]\s*)git\s+push(\s|$)"; then
        # リモートにない直近コミットの変更ファイルを確認
        local remote_branch
        remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")

        local changed_files=""
        if [ -n "$remote_branch" ]; then
            changed_files=$(git diff --name-only "${remote_branch}..HEAD" 2>/dev/null || true)
        else
            # リモートブランチがない場合は直近のコミットをチェック
            changed_files=$(git diff --name-only HEAD~1..HEAD 2>/dev/null || true)
        fi

        if [ -z "$changed_files" ]; then
            return
        fi

        while IFS= read -r filepath; do
            [ -z "$filepath" ] && continue
            if is_secret_path "$filepath"; then
                local reason
                reason=$(get_secret_reason "$filepath")
                block_with_message "プッシュ対象にシークレットファイルが含まれています" "ファイル: ${filepath} (${reason})\n\nプッシュ前にシークレットファイルをコミットから除外してください。"
            fi
        done <<< "$changed_files"
    fi
}

# 全チェックを実行
check_file_access_command
check_curl_data_upload
check_git_add
check_git_commit
check_git_push

# マッチしない場合は許可（何も出力せず正常終了）
exit 0
