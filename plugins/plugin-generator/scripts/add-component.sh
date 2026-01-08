#!/bin/bash
# コンポーネント追加スクリプト
# Usage: add-component.sh <type> <name>
#
# 対応コンポーネント:
#   command - コマンド追加
#   skill   - スキル追加
#   agent   - エージェント追加
#   hook    - フック設定ファイル作成

set -e

TYPE="$1"
NAME="$2"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
TEMPLATE_DIR="$PLUGIN_ROOT/templates"

# カレントディレクトリがプラグインルートかどうか確認
CURRENT_DIR="$(pwd)"

# ヘルプ表示
show_help() {
    cat << 'EOF'
Usage: add-component.sh <type> <name>

プラグインにコンポーネントを追加します。

Arguments:
  type    コンポーネント種別（command, skill, agent, hook）
  name    コンポーネント名（kebab-case）

Examples:
  add-component.sh command hello
  add-component.sh skill database-helper
  add-component.sh agent code-reviewer
  add-component.sh hook pre-commit
EOF
}

# エラー出力
error() {
    echo "Error: $1" >&2
    exit 1
}

# 引数チェック
if [[ -z "$TYPE" || -z "$NAME" ]]; then
    show_help
    exit 1
fi

if [[ "$TYPE" == "-h" || "$TYPE" == "--help" ]]; then
    show_help
    exit 0
fi

# プラグインルートかどうか確認
if [[ ! -f "$CURRENT_DIR/.claude-plugin/plugin.json" ]]; then
    error "プラグインルートで実行してください（.claude-plugin/plugin.json が見つかりません）"
fi

# プラグイン名取得
if command -v jq &> /dev/null; then
    PLUGIN_NAME=$(jq -r '.name' "$CURRENT_DIR/.claude-plugin/plugin.json")
else
    PLUGIN_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$CURRENT_DIR/.claude-plugin/plugin.json" | sed 's/"name"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

# kebab-case チェック
if ! [[ "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    error "名前は kebab-case（小文字、数字、ハイフン）で指定してください: $NAME"
fi

echo "═══════════════════════════════════════════════════════════"
echo "Add Component"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Plugin: $PLUGIN_NAME"
echo "Type: $TYPE"
echo "Name: $NAME"
echo ""

# テンプレート展開関数
expand_template() {
    local src="$1"
    local dst="$2"
    local cmd_name="${3:-$NAME}"

    sed -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
        -e "s/{{COMMAND_NAME}}/$cmd_name/g" \
        -e "s/{{SKILL_NAME}}/$NAME/g" \
        -e "s/{{AGENT_NAME}}/$NAME/g" \
        "$src" > "$dst"

    echo "Created: $dst"
}

case "$TYPE" in
    command)
        # commands ディレクトリ作成
        mkdir -p "$CURRENT_DIR/commands"

        TARGET_FILE="$CURRENT_DIR/commands/$NAME.md"
        if [[ -f "$TARGET_FILE" ]]; then
            error "コマンド '$NAME' は既に存在します: $TARGET_FILE"
        fi

        expand_template "$TEMPLATE_DIR/command.md.tmpl" "$TARGET_FILE" "$NAME"

        echo ""
        echo "Next steps:"
        echo "  1. Edit commands/$NAME.md"
        echo "  2. Update CLAUDE.md with command documentation"
        ;;

    skill)
        # skills ディレクトリ作成
        mkdir -p "$CURRENT_DIR/skills/$NAME"

        TARGET_FILE="$CURRENT_DIR/skills/$NAME/SKILL.md"
        if [[ -f "$TARGET_FILE" ]]; then
            error "スキル '$NAME' は既に存在します: $TARGET_FILE"
        fi

        expand_template "$TEMPLATE_DIR/skill.md.tmpl" "$TARGET_FILE"

        # plugin.json に skills パスがなければ追加を促す
        if command -v jq &> /dev/null; then
            HAS_SKILLS=$(jq -r '.skills // empty' "$CURRENT_DIR/.claude-plugin/plugin.json")
            if [[ -z "$HAS_SKILLS" ]]; then
                echo ""
                echo "Note: plugin.json に skills パスを追加してください:"
                echo '  "skills": "./skills/"'
            fi
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Edit skills/$NAME/SKILL.md"
        echo "  2. Update CLAUDE.md with skill documentation"
        ;;

    agent)
        # agents ディレクトリ作成
        mkdir -p "$CURRENT_DIR/agents"

        TARGET_FILE="$CURRENT_DIR/agents/$NAME.md"
        if [[ -f "$TARGET_FILE" ]]; then
            error "エージェント '$NAME' は既に存在します: $TARGET_FILE"
        fi

        expand_template "$TEMPLATE_DIR/agent.md.tmpl" "$TARGET_FILE"

        # plugin.json に agents パスがなければ追加を促す
        if command -v jq &> /dev/null; then
            HAS_AGENTS=$(jq -r '.agents // empty' "$CURRENT_DIR/.claude-plugin/plugin.json")
            if [[ -z "$HAS_AGENTS" ]]; then
                echo ""
                echo "Note: plugin.json に agents パスを追加してください:"
                echo '  "agents": "./agents/"'
            fi
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Edit agents/$NAME.md"
        echo "  2. Update CLAUDE.md with agent documentation"
        ;;

    hook)
        # hooks ディレクトリ作成
        mkdir -p "$CURRENT_DIR/hooks"

        HOOKS_FILE="$CURRENT_DIR/hooks/hooks.json"
        if [[ -f "$HOOKS_FILE" ]]; then
            echo "hooks/hooks.json は既に存在します。手動で編集してください。"
        else
            cp "$TEMPLATE_DIR/hooks.json.tmpl" "$HOOKS_FILE"
            echo "Created: $HOOKS_FILE"
        fi

        # plugin.json に hooks パスがなければ追加を促す
        if command -v jq &> /dev/null; then
            HAS_HOOKS=$(jq -r '.hooks // empty' "$CURRENT_DIR/.claude-plugin/plugin.json")
            if [[ -z "$HAS_HOOKS" ]]; then
                echo ""
                echo "Note: plugin.json に hooks パスを追加してください:"
                echo '  "hooks": "./hooks/hooks.json"'
            fi
        fi

        echo ""
        echo "Next steps:"
        echo "  1. Edit hooks/hooks.json to add your hooks"
        echo "  2. Create hook scripts if needed"
        ;;

    *)
        error "不明なコンポーネント種別: $TYPE (command, skill, agent, hook のいずれかを指定)"
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Done!"
echo "═══════════════════════════════════════════════════════════"
