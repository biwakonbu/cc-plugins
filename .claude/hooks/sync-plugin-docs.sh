#!/bin/bash
# sync-plugin-docs.sh - プラグイン情報を収集し、関連ドキュメントを自動更新
#
# トリガー: git commit 時（plugins/ 配下の変更がある場合）
# スキップ: SKIP_DOCS_SYNC=1

set -e

# スキップオプション
if [[ "${SKIP_DOCS_SYNC:-}" = "1" ]]; then
    exit 0
fi

# stdin から JSON を読み取り
INPUT=$(cat)

# jq がある場合は使用、なければ grep/sed
if command -v jq &>/dev/null; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)
fi

# git commit 以外は即座に終了
if [[ ! "$COMMAND" =~ ^git\ commit ]]; then
    exit 0
fi

# プロジェクトルートに移動
MARKETPLACE_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$MARKETPLACE_ROOT"

# plugins/ の変更がなければ終了
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
if ! echo "$STAGED_FILES" | grep -q '^plugins/'; then
    exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "🔄 プラグインドキュメント自動同期を実行中..." >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

# プラグイン情報を収集
declare -a PLUGIN_NAMES
declare -a PLUGIN_VERSIONS
declare -a PLUGIN_DESCRIPTIONS

for plugin_dir in plugins/*/; do
    if [[ ! -d "$plugin_dir" ]]; then
        continue
    fi

    plugin_name=$(basename "$plugin_dir")
    plugin_json="$plugin_dir/.claude-plugin/plugin.json"

    if [[ -f "$plugin_json" ]]; then
        if command -v jq &>/dev/null; then
            version=$(jq -r '.version // "0.0.0"' "$plugin_json")
            description=$(jq -r '.description // ""' "$plugin_json")
        else
            version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$plugin_json" | sed 's/"version"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)
            description=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$plugin_json" | sed 's/"description"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//' | head -1)
        fi

        PLUGIN_NAMES+=("$plugin_name")
        PLUGIN_VERSIONS+=("$version")
        PLUGIN_DESCRIPTIONS+=("$description")

        echo "  📦 $plugin_name v$version" >&2
    fi
done

# プラグインがなければ終了
if [[ ${#PLUGIN_NAMES[@]} -eq 0 ]]; then
    echo "⚠️ プラグインが見つかりませんでした" >&2
    exit 0
fi

# アルファベット順にソート（インデックス配列を作成）
SORTED_INDICES=($(for i in "${!PLUGIN_NAMES[@]}"; do echo "$i ${PLUGIN_NAMES[$i]}"; done | sort -k2 | cut -d' ' -f1))

# ========================================
# CLAUDE.md の「収録プラグイン」テーブルを更新
# ========================================
CLAUDE_MD="$MARKETPLACE_ROOT/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]]; then
    echo "" >&2
    echo "📝 CLAUDE.md を更新中..." >&2

    # 新しいテーブルを生成
    NEW_TABLE="| プラグイン | バージョン | 説明 |
|-----------|-----------|------|"

    for i in "${SORTED_INDICES[@]}"; do
        name="${PLUGIN_NAMES[$i]}"
        version="${PLUGIN_VERSIONS[$i]}"
        desc="${PLUGIN_DESCRIPTIONS[$i]}"
        NEW_TABLE="$NEW_TABLE
| $name | $version | $desc |"
    done

    # プロジェクト構造セクションのプラグイン一覧も更新
    STRUCTURE_LIST=""
    for i in "${SORTED_INDICES[@]}"; do
        name="${PLUGIN_NAMES[$i]}"
        version="${PLUGIN_VERSIONS[$i]}"
        # 説明を短縮（20文字まで）
        short_desc="${PLUGIN_DESCRIPTIONS[$i]}"
        if [[ ${#short_desc} -gt 30 ]]; then
            short_desc="${short_desc:0:27}..."
        fi
        STRUCTURE_LIST="$STRUCTURE_LIST
    ├── $name/   # $short_desc (v$version)"
    done
    # 最後の行を └── に変換
    STRUCTURE_LIST=$(echo "$STRUCTURE_LIST" | sed '$ s/├──/└──/')

    # 一時ファイルを使用してテーブルを置換
    TEMP_FILE=$(mktemp)
    TABLE_FILE=$(mktemp)

    # テーブル内容を一時ファイルに書き込み
    echo "$NEW_TABLE" > "$TABLE_FILE"

    # テーブル部分を置換（awk でテーブルファイルを読み込み）
    awk -v table_file="$TABLE_FILE" '
    BEGIN { in_table = 0 }
    /^\| プラグイン \| バージョン \| 説明 \|/ {
        while ((getline line < table_file) > 0) print line
        close(table_file)
        in_table = 1
        next
    }
    in_table && /^\|/ { next }
    in_table && !/^\|/ { in_table = 0 }
    !in_table { print }
    ' "$CLAUDE_MD" > "$TEMP_FILE"

    rm -f "$TABLE_FILE"
    mv "$TEMP_FILE" "$CLAUDE_MD"

    git add "$CLAUDE_MD" 2>/dev/null || true
    echo "  ✅ CLAUDE.md 更新完了" >&2
fi

# ========================================
# README.md の「収録プラグイン」テーブルを更新
# ========================================
README_MD="$MARKETPLACE_ROOT/README.md"
if [[ -f "$README_MD" ]]; then
    echo "" >&2
    echo "📝 README.md を更新中..." >&2

    # 新しいテーブルを生成（リンク付き）
    NEW_README_TABLE="| プラグイン | バージョン | 説明 |
|-----------|-----------|------|"

    for i in "${SORTED_INDICES[@]}"; do
        name="${PLUGIN_NAMES[$i]}"
        version="${PLUGIN_VERSIONS[$i]}"
        desc="${PLUGIN_DESCRIPTIONS[$i]}"
        NEW_README_TABLE="$NEW_README_TABLE
| [$name](./plugins/$name/) | $version | $desc |"
    done

    # テーブルが存在するかチェック
    if grep -q '^| プラグイン | バージョン | 説明 |' "$README_MD" 2>/dev/null; then
        # テーブルを置換
        TEMP_FILE=$(mktemp)
        TABLE_FILE=$(mktemp)

        # テーブル内容を一時ファイルに書き込み
        echo "$NEW_README_TABLE" > "$TABLE_FILE"

        awk -v table_file="$TABLE_FILE" '
        BEGIN { in_table = 0 }
        /^\| プラグイン \| バージョン \| 説明 \|/ {
            while ((getline line < table_file) > 0) print line
            close(table_file)
            in_table = 1
            next
        }
        in_table && /^\|/ { next }
        in_table && !/^\|/ { in_table = 0 }
        !in_table { print }
        ' "$README_MD" > "$TEMP_FILE"

        rm -f "$TABLE_FILE"
        mv "$TEMP_FILE" "$README_MD"

        git add "$README_MD" 2>/dev/null || true
        echo "  ✅ README.md 更新完了" >&2
    else
        echo "  ⚠️ README.md にテーブルが見つかりません（スキップ）" >&2
    fi
fi

# ========================================
# marketplace.json の description を同期
# ========================================
MARKETPLACE_JSON="$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"
if [[ -f "$MARKETPLACE_JSON" ]] && command -v jq &>/dev/null; then
    echo "" >&2
    echo "📝 marketplace.json を更新中..." >&2

    TEMP_FILE=$(mktemp)
    cp "$MARKETPLACE_JSON" "$TEMP_FILE"

    UPDATED=0
    for i in "${!PLUGIN_NAMES[@]}"; do
        name="${PLUGIN_NAMES[$i]}"
        desc="${PLUGIN_DESCRIPTIONS[$i]}"

        # 現在の description を取得
        current_desc=$(jq -r --arg name "$name" '.plugins[] | select(.name == $name) | .description // ""' "$TEMP_FILE")

        if [[ "$current_desc" != "$desc" ]] && [[ -n "$desc" ]]; then
            jq --arg name "$name" --arg desc "$desc" \
               '(.plugins[] | select(.name == $name)).description = $desc' \
               "$TEMP_FILE" > "${TEMP_FILE}.new" && mv "${TEMP_FILE}.new" "$TEMP_FILE"
            UPDATED=1
        fi
    done

    if [[ $UPDATED -eq 1 ]]; then
        mv "$TEMP_FILE" "$MARKETPLACE_JSON"
        git add "$MARKETPLACE_JSON" 2>/dev/null || true
        echo "  ✅ marketplace.json 更新完了" >&2
    else
        rm -f "$TEMP_FILE"
        echo "  ℹ️ marketplace.json は最新です" >&2
    fi
fi

echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "✅ ドキュメント同期完了" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

exit 0
