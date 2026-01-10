#!/bin/bash
# プラグインバリデーションスクリプト
# Usage: validate-plugin.sh [path]
#
# 検証項目:
# - plugin.json の必須フィールド
# - 各コンポーネントのフロントマター
# - description の複数行チェック（パースエラー防止）
# - パス整合性
# - JSON 構文

set -e

TARGET_PATH="${1:-.}"
ERRORS=0
WARNINGS=0

# 色定義（ターミナル対応）
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# 出力関数
error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo "   $1"
}

# description 複数行チェック関数
# YAML の description フィールドが複数行になっていないかを検証
# 複数行の description は Claude Code のパーサーでエラーになる可能性がある
check_description_multiline() {
    local file="$1"
    local component_name="$2"

    # フロントマターの範囲を特定（最初の --- から次の --- まで）
    local in_frontmatter=0
    local frontmatter_end=0
    local line_num=0
    local desc_line=0
    local desc_started=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        if [[ $line_num -eq 1 && "$line" == "---" ]]; then
            in_frontmatter=1
            continue
        fi

        if [[ $in_frontmatter -eq 1 && "$line" == "---" ]]; then
            frontmatter_end=$line_num
            break
        fi

        if [[ $in_frontmatter -eq 1 ]]; then
            # description: で始まる行を検出
            if [[ "$line" =~ ^description: ]]; then
                desc_line=$line_num
                desc_started=1
                # description: | や description: > の場合は明示的なマルチライン
                if [[ "$line" =~ ^description:\ *\|  ]] || [[ "$line" =~ ^description:\ *\> ]]; then
                    error "$component_name: description に YAML マルチライン記法（| または >）を使用しています。単一行に変更してください"
                    return 1
                fi
            elif [[ $desc_started -eq 1 ]]; then
                # description の次の行が別のフィールドか --- でない場合、複数行の可能性
                if [[ ! "$line" =~ ^[a-zA-Z_-]+: ]] && [[ "$line" != "---" ]] && [[ -n "$line" ]]; then
                    error "$component_name: description が複数行になっています（行 $desc_line-$line_num）。単一行に変更してください"
                    return 1
                fi
                desc_started=0
            fi
        fi
    done < "$file"

    return 0
}

# ヘルプ表示
show_help() {
    cat << 'EOF'
Usage: validate-plugin.sh [path]

Claude Code プラグインの構造を検証します。

Arguments:
  path    検証対象のパス（省略時はカレントディレクトリ）

Validation:
  - plugin.json の必須フィールド
  - commands/*.md のフロントマター
  - skills/*/SKILL.md のフロントマター
  - agents/*.md のフロントマター
  - hooks.json の JSON 構文
  - パス整合性
EOF
}

if [[ "$TARGET_PATH" == "-h" || "$TARGET_PATH" == "--help" ]]; then
    show_help
    exit 0
fi

# 絶対パスに変換
if [[ ! "$TARGET_PATH" = /* ]]; then
    TARGET_PATH="$(pwd)/$TARGET_PATH"
fi

# パス存在確認
if [[ ! -d "$TARGET_PATH" ]]; then
    error "ディレクトリが存在しません: $TARGET_PATH"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════"
echo "Plugin Validator"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Target: $TARGET_PATH"
echo ""

# --- plugin.json 検証 ---
echo "--- plugin.json ---"

PLUGIN_JSON="$TARGET_PATH/.claude-plugin/plugin.json"
if [[ ! -f "$PLUGIN_JSON" ]]; then
    error ".claude-plugin/plugin.json が存在しません"
else
    success ".claude-plugin/plugin.json exists"

    # JSON 構文チェック
    if command -v jq &> /dev/null; then
        if ! jq empty "$PLUGIN_JSON" 2>/dev/null; then
            error "plugin.json の JSON 構文が無効です"
        else
            # 必須フィールド: name
            NAME=$(jq -r '.name // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -z "$NAME" ]]; then
                error "'name' フィールドが必須です"
            else
                success "name: $NAME"
            fi

            # 推奨フィールド: version
            VERSION=$(jq -r '.version // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -z "$VERSION" ]]; then
                warning "'version' フィールドを推奨します"
            else
                success "version: $VERSION"
            fi

            # 推奨フィールド: description
            DESCRIPTION=$(jq -r '.description // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -z "$DESCRIPTION" ]]; then
                warning "'description' フィールドを推奨します"
            else
                success "description: (set)"
            fi

            # パス整合性チェック
            COMMANDS_PATH=$(jq -r '.commands // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -n "$COMMANDS_PATH" ]]; then
                CMD_DIR="$TARGET_PATH/${COMMANDS_PATH#./}"
                if [[ ! -d "$CMD_DIR" ]]; then
                    error "commands ディレクトリが存在しません: $CMD_DIR"
                else
                    success "commands directory exists"
                fi
            fi

            SKILLS_PATH=$(jq -r '.skills // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -n "$SKILLS_PATH" ]]; then
                SKILLS_DIR="$TARGET_PATH/${SKILLS_PATH#./}"
                if [[ ! -d "$SKILLS_DIR" ]]; then
                    error "skills ディレクトリが存在しません: $SKILLS_DIR"
                else
                    success "skills directory exists"
                fi
            fi

            AGENTS_PATH=$(jq -r '.agents // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -n "$AGENTS_PATH" ]]; then
                AGENTS_DIR="$TARGET_PATH/${AGENTS_PATH#./}"
                if [[ ! -d "$AGENTS_DIR" ]]; then
                    error "agents ディレクトリが存在しません: $AGENTS_DIR"
                else
                    success "agents directory exists"
                fi
            fi

            HOOKS_PATH=$(jq -r '.hooks // empty' "$PLUGIN_JSON" 2>/dev/null)
            if [[ -n "$HOOKS_PATH" ]]; then
                # 標準パスの重複チェック
                # Claude Code は hooks/hooks.json を自動ロードするため、
                # plugin.json で明示指定すると重複エラーになる
                NORMALIZED_HOOKS="${HOOKS_PATH#./}"
                if [[ "$NORMALIZED_HOOKS" == "hooks/hooks.json" ]]; then
                    error "hooks: './hooks/hooks.json' は自動ロードされるため plugin.json での指定は不要です（重複エラーの原因）"
                else
                    HOOKS_FILE="$TARGET_PATH/${HOOKS_PATH#./}"
                    if [[ ! -f "$HOOKS_FILE" ]]; then
                        error "hooks ファイルが存在しません: $HOOKS_FILE"
                    else
                        success "hooks file exists"
                    fi
                fi
            fi
        fi
    else
        warning "jq がインストールされていないため、詳細な検証をスキップします"
        # 簡易チェック
        if grep -q '"name"' "$PLUGIN_JSON"; then
            success "name field found"
        else
            error "'name' フィールドが見つかりません"
        fi
    fi
fi

# --- CLAUDE.md 検証 ---
echo ""
echo "--- CLAUDE.md ---"

if [[ ! -f "$TARGET_PATH/CLAUDE.md" ]]; then
    warning "CLAUDE.md が存在しません（推奨）"
else
    success "CLAUDE.md exists"
fi

# --- commands 検証 ---
echo ""
echo "--- commands ---"

COMMANDS_DIR="$TARGET_PATH/commands"
if [[ -d "$COMMANDS_DIR" ]]; then
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        if [[ -f "$cmd_file" ]]; then
            filename=$(basename "$cmd_file")
            # フロントマターチェック
            if head -1 "$cmd_file" | grep -q '^---$'; then
                # description フィールドチェック
                if grep -q '^description:' "$cmd_file"; then
                    success "commands/$filename: description OK"
                    # description 複数行チェック
                    check_description_multiline "$cmd_file" "commands/$filename"
                else
                    error "commands/$filename: 'description' フィールドがありません"
                fi
                # allowed-tools フィールドチェック（推奨）
                if grep -q '^allowed-tools:' "$cmd_file"; then
                    success "commands/$filename: allowed-tools OK"
                else
                    warning "commands/$filename: 'allowed-tools' フィールドを推奨します"
                fi
            else
                error "commands/$filename: フロントマターがありません"
            fi
        fi
    done
else
    info "commands ディレクトリなし（スキップ）"
fi

# --- skills 検証 ---
echo ""
echo "--- skills ---"

SKILLS_DIR="$TARGET_PATH/skills"
if [[ -d "$SKILLS_DIR" ]]; then
    for skill_dir in "$SKILLS_DIR"/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")
            skill_file="$skill_dir/SKILL.md"
            if [[ -f "$skill_file" ]]; then
                # フロントマターチェック
                if head -1 "$skill_file" | grep -q '^---$'; then
                    # 必須フィールドチェック
                    has_name=$(grep -c '^name:' "$skill_file" || true)
                    has_desc=$(grep -c '^description:' "$skill_file" || true)
                    has_tools=$(grep -c '^allowed-tools:' "$skill_file" || true)

                    if [[ $has_name -eq 0 ]]; then
                        error "skills/$skill_name/SKILL.md: 'name' フィールドがありません"
                    elif [[ $has_desc -eq 0 ]]; then
                        error "skills/$skill_name/SKILL.md: 'description' フィールドがありません"
                    else
                        success "skills/$skill_name/SKILL.md: name, description OK"
                        # description 複数行チェック
                        check_description_multiline "$skill_file" "skills/$skill_name/SKILL.md"
                    fi

                    # allowed-tools チェック（推奨）
                    if [[ $has_tools -eq 0 ]]; then
                        warning "skills/$skill_name/SKILL.md: 'allowed-tools' フィールドを推奨します"
                    else
                        success "skills/$skill_name/SKILL.md: allowed-tools OK"
                    fi
                else
                    error "skills/$skill_name/SKILL.md: フロントマターがありません"
                fi
            else
                error "skills/$skill_name: SKILL.md が存在しません"
            fi
        fi
    done
else
    info "skills ディレクトリなし（スキップ）"
fi

# --- agents 検証 ---
echo ""
echo "--- agents ---"

AGENTS_DIR="$TARGET_PATH/agents"
if [[ -d "$AGENTS_DIR" ]]; then
    # 再帰的に .md ファイルを検索
    find "$AGENTS_DIR" -name "*.md" -type f | while read -r agent_file; do
        rel_path="${agent_file#$AGENTS_DIR/}"
        # フロントマターチェック
        if head -1 "$agent_file" | grep -q '^---$'; then
            # 必須フィールドチェック
            has_name=$(grep -c '^name:' "$agent_file" || true)
            has_desc=$(grep -c '^description:' "$agent_file" || true)
            has_tools=$(grep -c '^tools:' "$agent_file" || true)

            if [[ $has_name -eq 0 ]]; then
                error "agents/$rel_path: 'name' フィールドがありません"
            elif [[ $has_desc -eq 0 ]]; then
                error "agents/$rel_path: 'description' フィールドがありません"
            else
                success "agents/$rel_path: name, description OK"
                # description 複数行チェック
                check_description_multiline "$agent_file" "agents/$rel_path"
            fi

            # tools チェック（推奨）
            if [[ $has_tools -eq 0 ]]; then
                warning "agents/$rel_path: 'tools' フィールドを推奨します"
            else
                success "agents/$rel_path: tools OK"
            fi
        else
            error "agents/$rel_path: フロントマターがありません"
        fi
    done
else
    info "agents ディレクトリなし（スキップ）"
fi

# --- hooks 検証 ---
echo ""
echo "--- hooks ---"

HOOKS_DIR="$TARGET_PATH/hooks"
if [[ -d "$HOOKS_DIR" ]]; then
    HOOKS_JSON="$HOOKS_DIR/hooks.json"
    if [[ -f "$HOOKS_JSON" ]]; then
        if command -v jq &> /dev/null; then
            if jq empty "$HOOKS_JSON" 2>/dev/null; then
                success "hooks/hooks.json: JSON syntax OK"
            else
                error "hooks/hooks.json: JSON 構文が無効です"
            fi
        else
            success "hooks/hooks.json: exists (jq not available for syntax check)"
        fi
    fi
else
    info "hooks ディレクトリなし（スキップ）"
fi

# --- 結果サマリー ---
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation Result"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}❌ FAILED - エラーを修正してください${NC}"
    exit 1
else
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  PASSED with warnings${NC}"
    else
        echo -e "${GREEN}✅ PASSED${NC}"
    fi
    exit 0
fi
