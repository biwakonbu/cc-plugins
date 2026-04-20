#!/bin/bash
# lint-multi-tool-compat.sh
#
# cc-plugins のプラグインが Claude Code / Codex CLI / Cursor / Copilot CLI / OpenCode の
# 5 ツールで共通認識可能な形式になっているかを検証する。
#
# 検証項目:
# 1. SKILL.md / agents/*.md / commands/*.md フロントマターの共通規約
#    - name が存在し kebab-case
#    - description が存在
#    - description 1 行目に "Use when" を含む (warning)
# 2. Claude Code 固有フィールドが適切な場所にあるか
#    - context: fork は skills のみ
#    - allowed-tools は skills/commands のみ (agents には tools を使う)
#    - skills に model は不可
# 3. プラグインに skills/agents/commands いずれかがあれば AGENTS.md 推奨 (warning)
# 4. AGENTS.md 内で参照されるパスが実在するか
#
# Usage:
#   lint-multi-tool-compat.sh [plugin-path]
#   plugin-path を省略するとカレントディレクトリを対象にする。
#
# Exit codes:
#   0: エラーなし (warning のみ許容)
#   1: エラーあり

set -e

TARGET="${1:-.}"
if [[ ! "$TARGET" = /* ]]; then
    TARGET="$(pwd)/$TARGET"
fi

if [[ ! -d "$TARGET" ]]; then
    echo "Error: ディレクトリが存在しません: $TARGET" >&2
    exit 1
fi

if [[ -t 1 ]]; then
    RED='\033[0;31m'; YELLOW='\033[0;33m'; GREEN='\033[0;32m'; NC='\033[0m'
else
    RED=''; YELLOW=''; GREEN=''; NC=''
fi

ERRORS=0
WARNINGS=0

err()  { echo -e "${RED}❌ $1${NC}" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; WARNINGS=$((WARNINGS + 1)); }
ok()   { echo -e "${GREEN}✅ $1${NC}"; }

# フロントマター (1 行目 --- から次の --- まで) を抽出
extract_frontmatter() {
    awk 'NR==1 && /^---$/{flag=1; next} flag && /^---$/{exit} flag' "$1"
}

# フロントマター内の単純 key 取得 (値が文字列の場合のみ、block scalar 非対応)
fm_get() {
    local file="$1" key="$2"
    extract_frontmatter "$file" | awk -v k="$key" '
        $0 ~ "^"k":" {
            sub("^"k":[[:space:]]*", "");
            print; exit
        }'
}

# description の 1 行目を取得 (block scalar | > にも簡易対応)
fm_desc_first_line() {
    local file="$1"
    extract_frontmatter "$file" | awk '
        /^description:/ {
            line=$0
            sub("^description:[[:space:]]*", "", line)
            if (line == "|" || line == ">" || line == "|-" || line == ">-") {
                in_block=1; next
            }
            print line; exit
        }
        in_block==1 {
            sub("^[[:space:]]+", "")
            print; exit
        }'
}

# kebab-case 判定
is_kebab() { [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]]; }

lint_frontmatter_file() {
    local file="$1" kind="$2" rel="$3"

    # フロントマター存在確認
    if ! head -1 "$file" | grep -q '^---$'; then
        err "$rel: フロントマターがありません"
        return
    fi

    # name (commands 以外は必須)
    local name
    name=$(fm_get "$file" name | tr -d '"'"'")
    if [[ "$kind" != "command" ]]; then
        if [[ -z "$name" ]]; then
            err "$rel: 'name' フィールドがありません"
        elif ! is_kebab "$name"; then
            err "$rel: 'name' が kebab-case ではありません: $name"
        fi
    fi

    # description 必須
    local desc_first
    desc_first=$(fm_desc_first_line "$file")
    if [[ -z "$desc_first" ]]; then
        err "$rel: 'description' フィールドがありません"
    else
        if ! echo "$desc_first" | grep -qi '^use when'; then
            warn "$rel: description 1行目が 'Use when' で始まっていません (他ツールの発動判定に影響)"
        fi
    fi

    # Claude Code 固有フィールドの配置チェック
    local has_context has_allowed has_model
    has_context=$(extract_frontmatter "$file" | grep -c '^context:' || true)
    has_allowed=$(extract_frontmatter "$file" | grep -c '^allowed-tools:' || true)
    has_model=$(extract_frontmatter "$file" | grep -c '^model:' || true)

    case "$kind" in
        skill)
            if [[ "$has_model" -gt 0 ]]; then
                err "$rel: skill に 'model' フィールドは指定できません"
            fi
            ;;
        agent)
            if [[ "$has_context" -gt 0 ]]; then
                err "$rel: 'context' フィールドは skill 専用です"
            fi
            if [[ "$has_allowed" -gt 0 ]]; then
                err "$rel: agent では 'allowed-tools' ではなく 'tools' を使用してください"
            fi
            ;;
        command)
            if [[ "$has_context" -gt 0 ]]; then
                err "$rel: 'context' フィールドは skill 専用です"
            fi
            ;;
    esac
}

echo "━━━ multi-tool compat lint: $TARGET ━━━"

# skills
if [[ -d "$TARGET/skills" ]]; then
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        lint_frontmatter_file "$f" skill "skills/$(basename "$(dirname "$f")")/SKILL.md"
    done < <(find "$TARGET/skills" -name SKILL.md -type f 2>/dev/null)
fi

# agents (再帰)
if [[ -d "$TARGET/agents" ]]; then
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        lint_frontmatter_file "$f" agent "agents/${f#$TARGET/agents/}"
    done < <(find "$TARGET/agents" -name '*.md' -type f 2>/dev/null)
fi

# commands
if [[ -d "$TARGET/commands" ]]; then
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        lint_frontmatter_file "$f" command "commands/$(basename "$f")"
    done < <(find "$TARGET/commands" -maxdepth 1 -name '*.md' -type f 2>/dev/null)
fi

# AGENTS.md 推奨 + 参照パス検証 + カバレッジ検証
if [[ -d "$TARGET/skills" || -d "$TARGET/agents" || -d "$TARGET/commands" ]]; then
    if [[ -f "$TARGET/AGENTS.md" ]]; then
        ok "AGENTS.md exists"
        # バッククォートで囲まれた相対パスを抽出して実在確認
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            # 先頭 / や http は無視
            [[ "$ref" == /* || "$ref" == http* ]] && continue
            # プラグイン内の相対パス (skills/agents/commands/hooks) のみ検証対象
            # .github/... や .cursor/... はリポジトリルート配置のため検証スキップ
            case "$ref" in
                skills/*|agents/*|commands/*|hooks/*) ;;
                *) continue ;;
            esac
            if [[ ! -e "$TARGET/$ref" ]]; then
                warn "AGENTS.md: 参照先が存在しません: $ref"
            fi
        done < <(grep -oE '`[^`]+\.md`' "$TARGET/AGENTS.md" 2>/dev/null | tr -d '`')

        # カバレッジ: 各 skill/agent/command が AGENTS.md で列挙されているか
        AGENTS_CONTENT=$(cat "$TARGET/AGENTS.md")
        if [[ -d "$TARGET/skills" ]]; then
            while IFS= read -r f; do
                [[ -z "$f" ]] && continue
                rel="skills/$(basename "$(dirname "$f")")/SKILL.md"
                if ! echo "$AGENTS_CONTENT" | grep -qF "$rel"; then
                    warn "AGENTS.md: $rel が列挙されていません (5 ツール発見性のため追加を推奨)"
                fi
            done < <(find "$TARGET/skills" -name SKILL.md -type f 2>/dev/null)
        fi
        if [[ -d "$TARGET/agents" ]]; then
            while IFS= read -r f; do
                [[ -z "$f" ]] && continue
                rel="agents/${f#$TARGET/agents/}"
                if ! echo "$AGENTS_CONTENT" | grep -qF "$rel"; then
                    warn "AGENTS.md: $rel が列挙されていません (5 ツール発見性のため追加を推奨)"
                fi
            done < <(find "$TARGET/agents" -name '*.md' -type f 2>/dev/null)
        fi
        if [[ -d "$TARGET/commands" ]]; then
            while IFS= read -r f; do
                [[ -z "$f" ]] && continue
                rel="commands/$(basename "$f")"
                if ! echo "$AGENTS_CONTENT" | grep -qF "$rel"; then
                    warn "AGENTS.md: $rel が列挙されていません (5 ツール発見性のため追加を推奨)"
                fi
            done < <(find "$TARGET/commands" -maxdepth 1 -name '*.md' -type f 2>/dev/null)
        fi
    else
        warn "AGENTS.md がありません (5 ツール共通認識のため作成を推奨)"
    fi
fi

echo ""
echo "Errors: $ERRORS  Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi
exit 0
