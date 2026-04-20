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

# AGENTS.md 自動同期 (5 ツール共通認識)
AGENTS_MD="$CURRENT_DIR/AGENTS.md"

# hook は AGENTS.md への列挙対象外 (セクションが別管理)
case "$TYPE" in
    command|skill|agent)
        # AGENTS.md が無ければテンプレートから作成
        if [[ ! -f "$AGENTS_MD" ]]; then
            PLUGIN_DESC=""
            if command -v jq &> /dev/null; then
                PLUGIN_DESC=$(jq -r '.description // ""' "$CURRENT_DIR/.claude-plugin/plugin.json")
            fi
            sed -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
                -e "s|{{DESCRIPTION}}|${PLUGIN_DESC:-プラグインの 1 行説明をここに記述}|g" \
                "$TEMPLATE_DIR/agents-md.tmpl" > "$AGENTS_MD"
            echo "Created: AGENTS.md (5 ツール共通入口)"
        fi

        # セクション名と追記行を決定
        case "$TYPE" in
            skill)
                SECTION="## Skills"
                ENTRY="- **$NAME** — Use when <発動条件>. 詳細: \`skills/$NAME/SKILL.md\`"
                ;;
            agent)
                SECTION="## Agents"
                ENTRY="- **$NAME** — Use when <発動条件>. 詳細: \`agents/$NAME.md\`"
                ;;
            command)
                SECTION="## Commands"
                ENTRY="- **/$PLUGIN_NAME:$NAME** — <コマンドの概要>. 詳細: \`commands/$NAME.md\`"
                ;;
        esac

        # 既に同名行があればスキップ (重複防止)
        if grep -F "$NAME" "$AGENTS_MD" | grep -qE "(skills/$NAME/SKILL\.md|agents/$NAME\.md|commands/$NAME\.md)"; then
            echo "AGENTS.md: $TYPE '$NAME' は既に列挙されています (スキップ)"
        elif grep -qF "$SECTION" "$AGENTS_MD"; then
            # 既存セクションヘッダの直後に挿入 (コメントブロックを跨がない)
            awk -v section="$SECTION" -v entry="$ENTRY" '
                BEGIN { inserted = 0 }
                {
                    print
                    if (!inserted && $0 == section) {
                        print ""
                        print entry
                        inserted = 1
                    }
                }
            ' "$AGENTS_MD" > "$AGENTS_MD.tmp" && mv "$AGENTS_MD.tmp" "$AGENTS_MD"
            echo "AGENTS.md: $SECTION に '$NAME' を追記"
        else
            # セクション自体が無い → 末尾に追加
            {
                echo ""
                echo "$SECTION"
                echo ""
                echo "$ENTRY"
            } >> "$AGENTS_MD"
            echo "AGENTS.md: $SECTION セクションを新設して '$NAME' を追記"
        fi
        ;;
    hook)
        if [[ -f "$AGENTS_MD" ]]; then
            echo "Note: AGENTS.md の ## Hooks セクションを手動で更新してください"
        fi
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Done!"
echo "═══════════════════════════════════════════════════════════"
