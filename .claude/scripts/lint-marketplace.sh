#!/bin/bash
# marketplace.json のリントスクリプト
#
# 検証項目:
# - JSON 構文
# - 必須フィールド (name, owner, plugins)
# - 各プラグインの必須フィールド (name, source)
# - プラグインパスの存在確認

set -e

MARKETPLACE_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MARKETPLACE="$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    ERRORS=$((ERRORS + 1))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# marketplace.json の存在確認
if [[ ! -f "$MARKETPLACE" ]]; then
    error "marketplace.json が見つかりません: $MARKETPLACE"
    exit 2
fi

echo "Linting: $MARKETPLACE"
echo ""

# JSON 構文チェック
if ! command -v jq &> /dev/null; then
    error "jq がインストールされていません"
    exit 2
fi

if ! jq empty "$MARKETPLACE" 2>/dev/null; then
    error "JSON 構文エラー"
    exit 2
fi

success "JSON 構文 OK"

# 必須フィールドチェック
NAME=$(jq -r '.name // empty' "$MARKETPLACE")
if [[ -z "$NAME" ]]; then
    error "必須フィールド 'name' がありません"
fi

OWNER=$(jq -r '.owner // empty' "$MARKETPLACE")
if [[ -z "$OWNER" ]]; then
    error "必須フィールド 'owner' がありません"
fi

PLUGINS=$(jq -r '.plugins // empty' "$MARKETPLACE")
if [[ -z "$PLUGINS" || "$PLUGINS" == "null" ]]; then
    error "必須フィールド 'plugins' がありません"
fi

# 各プラグインの検証
PLUGIN_COUNT=$(jq '.plugins | length' "$MARKETPLACE")

for ((i=0; i<PLUGIN_COUNT; i++)); do
    PLUGIN_NAME=$(jq -r ".plugins[$i].name // empty" "$MARKETPLACE")
    PLUGIN_SOURCE=$(jq -r ".plugins[$i].source // empty" "$MARKETPLACE")

    if [[ -z "$PLUGIN_NAME" ]]; then
        error "plugins[$i]: 'name' フィールドがありません"
        continue
    fi

    if [[ -z "$PLUGIN_SOURCE" ]]; then
        error "plugins[$i] ($PLUGIN_NAME): 'source' フィールドがありません"
        continue
    fi

    # パスの存在確認
    PLUGIN_PATH="$MARKETPLACE_ROOT/${PLUGIN_SOURCE#./}"
    if [[ ! -d "$PLUGIN_PATH" ]]; then
        error "plugins[$i] ($PLUGIN_NAME): パスが存在しません: $PLUGIN_SOURCE"
        continue
    fi

    # plugin.json の存在確認
    if [[ ! -f "$PLUGIN_PATH/.claude-plugin/plugin.json" ]]; then
        error "plugins[$i] ($PLUGIN_NAME): plugin.json が存在しません"
        continue
    fi

    success "plugins[$i] ($PLUGIN_NAME): OK"
done

echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Lint failed: $ERRORS error(s)${NC}"
    exit 2
else
    echo -e "${GREEN}Lint passed${NC}"
    exit 0
fi
