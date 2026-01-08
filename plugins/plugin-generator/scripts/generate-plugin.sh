#!/bin/bash
# プラグイン生成スクリプト
# Usage: generate-plugin.sh <plugin-name>
#
# 環境変数:
#   CLAUDE_PLUGIN_ROOT: プラグインのルートディレクトリ

set -e

PLUGIN_NAME="$1"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
# キャッシュから実行されるため、CLAUDE_PROJECT_DIR を使用
MARKETPLACE_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TEMPLATE_DIR="$PLUGIN_ROOT/templates"

# ヘルプ表示
show_help() {
    cat << 'EOF'
Usage: generate-plugin.sh <plugin-name>

新しい Claude Code プラグインを生成します。

Arguments:
  plugin-name    プラグイン名（kebab-case）

Examples:
  generate-plugin.sh my-plugin
  generate-plugin.sh awesome-tool
EOF
}

# エラー出力
error() {
    echo "Error: $1" >&2
    exit 1
}

# 引数チェック
if [[ -z "$PLUGIN_NAME" ]]; then
    show_help
    exit 1
fi

if [[ "$PLUGIN_NAME" == "-h" || "$PLUGIN_NAME" == "--help" ]]; then
    show_help
    exit 0
fi

# kebab-case チェック
if ! [[ "$PLUGIN_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    error "プラグイン名は kebab-case（小文字、数字、ハイフン）で指定してください: $PLUGIN_NAME"
fi

# ターゲットディレクトリ
TARGET_DIR="$MARKETPLACE_ROOT/plugins/$PLUGIN_NAME"

# 重複チェック
if [[ -d "$TARGET_DIR" ]]; then
    error "プラグイン '$PLUGIN_NAME' は既に存在します: $TARGET_DIR"
fi

# marketplace.json 確認
MARKETPLACE="$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"
if [[ ! -f "$MARKETPLACE" ]]; then
    error "マーケットプレイスルートではありません（marketplace.json が見つかりません）"
fi

# 作者名取得
AUTHOR_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$MARKETPLACE" | head -1 | sed 's/"name"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
if [[ -z "$AUTHOR_NAME" ]]; then
    AUTHOR_NAME="Author"
fi

# 変数設定
DATE=$(date +%Y-%m-%d)
VERSION="0.1.0"

echo "═══════════════════════════════════════════════════════════"
echo "Plugin Generator"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Plugin: $PLUGIN_NAME"
echo "Author: $AUTHOR_NAME"
echo "Location: $TARGET_DIR"
echo ""

# ディレクトリ作成
echo "Creating directories..."
mkdir -p "$TARGET_DIR/.claude-plugin"
mkdir -p "$TARGET_DIR/commands"

# テンプレート展開関数
expand_template() {
    local src="$1"
    local dst="$2"

    sed -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
        -e "s/{{AUTHOR_NAME}}/$AUTHOR_NAME/g" \
        -e "s/{{DATE}}/$DATE/g" \
        -e "s/{{VERSION}}/$VERSION/g" \
        "$src" > "$dst"

    echo "  Created: ${dst#$MARKETPLACE_ROOT/}"
}

# 基本ファイル生成
echo ""
echo "Generating files..."
expand_template "$TEMPLATE_DIR/base/plugin.json.tmpl" "$TARGET_DIR/.claude-plugin/plugin.json"
expand_template "$TEMPLATE_DIR/base/CLAUDE.md.tmpl" "$TARGET_DIR/CLAUDE.md"
expand_template "$TEMPLATE_DIR/base/hello.md.tmpl" "$TARGET_DIR/commands/hello.md"

# marketplace.json 更新
echo ""
echo "Updating marketplace.json..."
if command -v jq &> /dev/null; then
    jq --arg name "$PLUGIN_NAME" --arg source "./plugins/$PLUGIN_NAME" \
       '.plugins += [{"name": $name, "source": $source, "description": ""}]' \
       "$MARKETPLACE" > "${MARKETPLACE}.tmp" && mv "${MARKETPLACE}.tmp" "$MARKETPLACE"
    echo "  Updated: .claude-plugin/marketplace.json"
else
    echo "  Note: jq がインストールされていません。"
    echo "  以下を marketplace.json に手動で追加してください:"
    echo "    {\"name\": \"$PLUGIN_NAME\", \"source\": \"./plugins/$PLUGIN_NAME\", \"description\": \"\"}"
fi

# 完了メッセージ
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Plugin '$PLUGIN_NAME' created successfully!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Generated files:"
echo "  - .claude-plugin/plugin.json"
echo "  - CLAUDE.md"
echo "  - commands/hello.md"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md to describe your plugin"
echo "  2. Update plugin.json description"
echo "  3. Update marketplace.json description"
echo "  4. Add your commands/skills/agents"
echo "  5. Test with: claude --plugin-dir ./plugins/$PLUGIN_NAME"
