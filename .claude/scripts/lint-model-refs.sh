#!/bin/bash
# モデル参照リンター
#
# Usage: lint-model-refs.sh <plugin-path>
#
# allowed-models.conf に記載されたモデルのみを許可し、
# プラグイン内の全 Markdown ファイルのモデル参照を検証する。
# allowed-models.conf が存在しないプラグインはスキップ。

set -euo pipefail

PLUGIN_PATH="${1:?Usage: lint-model-refs.sh <plugin-path>}"
ALLOWED_FILE="$PLUGIN_PATH/.claude-plugin/allowed-models.conf"

# allowed-models.conf が無ければスキップ
if [[ ! -f "$ALLOWED_FILE" ]]; then
    exit 0
fi

# メタデータからベンダー固有の検出パターンを読み取る
PATTERN=$(grep '^# pattern:' "$ALLOWED_FILE" | sed 's/^# pattern: //' || true)
if [[ -z "$PATTERN" ]]; then
    # デフォルト: OpenAI パターン
    PATTERN='gpt-[0-9][0-9a-z._-]+|o[0-9]+-?[a-z]*'
fi

# 許可モデルリストを構築（コメントと空行を除外）
ALLOWED_MODELS=()
while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue
    [[ -z "${line// /}" ]] && continue
    ALLOWED_MODELS+=("$line")
done < "$ALLOWED_FILE"

if [[ ${#ALLOWED_MODELS[@]} -eq 0 ]]; then
    echo "WARNING: allowed-models.conf にモデルが定義されていません"
    exit 0
fi

# 対象ファイルを列挙
TARGET_FILES=()
while IFS= read -r f; do
    [[ -f "$f" ]] && TARGET_FILES+=("$f")
done < <(
    find "$PLUGIN_PATH/skills" -name "SKILL.md" 2>/dev/null || true
    find "$PLUGIN_PATH/commands" -name "*.md" 2>/dev/null || true
    find "$PLUGIN_PATH/agents" -name "*.md" 2>/dev/null || true
    # CLAUDE.md は変更履歴に過去のモデル名を含むため除外
    for f in "$PLUGIN_PATH/README.md"; do
        [[ -f "$f" ]] && echo "$f"
    done
)

if [[ ${#TARGET_FILES[@]} -eq 0 ]]; then
    echo "対象ファイルなし（スキップ）"
    exit 0
fi

# 各ファイルからモデル名を検出し照合
ERRORS=0
for file in "${TARGET_FILES[@]}"; do
    FOUND_MODELS=$(grep -oE "$PATTERN" "$file" 2>/dev/null | sort -u || true)
    for model in $FOUND_MODELS; do
        ALLOWED=false
        for allowed in "${ALLOWED_MODELS[@]}"; do
            if [[ "$model" == "$allowed" ]]; then
                ALLOWED=true
                break
            fi
        done
        if [[ "$ALLOWED" == "false" ]]; then
            REL_PATH="${file#$PLUGIN_PATH/}"
            echo "  ERROR: 未許可モデル '$model' が $REL_PATH で検出されました"
            ERRORS=$((ERRORS + 1))
        fi
    done
done

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "  許可モデル: ${ALLOWED_MODELS[*]}"
    echo "  allowed-models.conf を更新するか、ドキュメントのモデル参照を修正してください"
    exit 1
fi

echo "  モデル参照検証: OK (${#ALLOWED_MODELS[@]} モデル許可)"
exit 0
