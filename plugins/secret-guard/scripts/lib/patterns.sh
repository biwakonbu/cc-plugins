#!/bin/bash
# シークレットファイルパターン定義ライブラリ
# secret-guard プラグインで使用するブロック対象パターン

# --- 設定ファイル（.secret-guard.json）関連 ---

# allowlist/blocklist 配列（load_config で設定）
ALLOWLIST_PATTERNS=()
BLOCKLIST_PATTERNS=()

# 過度に広い allowlist パターンを拒否（セキュリティバイパス防止）
# 引数: $1 = パターン文字列
# 戻り値: 0 = 危険（拒否すべき）, 1 = 安全
is_dangerous_allowlist_pattern() {
    local pattern="$1"
    # 全マッチパターンを拒否
    case "$pattern" in
        '*'|'**'|'*.*'|'*/'|'**/'|'*/**') return 0 ;;
    esac
    return 1
}

# 設定ファイルを読み込み、allowlist/blocklist を配列に格納
# 検索先: $CLAUDE_PROJECT_DIR/.secret-guard.json
load_config() {
    # 多重呼び出し対策: 配列を初期化
    ALLOWLIST_PATTERNS=()
    BLOCKLIST_PATTERNS=()

    local config_file=""

    # プロジェクトルートの設定ファイルを検索
    if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -f "${CLAUDE_PROJECT_DIR}/.secret-guard.json" ]; then
        config_file="${CLAUDE_PROJECT_DIR}/.secret-guard.json"
    fi

    # 設定ファイルがなければデフォルト（空配列）のまま
    if [ -z "$config_file" ]; then
        return 0
    fi

    # JSON パース（jq が必要）
    if ! command -v jq &>/dev/null; then
        echo "[secret-guard] 警告: jq がインストールされていません。.secret-guard.json は無視されます。" >&2
        return 0
    fi

    # JSON の妥当性を検証
    if ! jq empty "$config_file" 2>/dev/null; then
        echo "[secret-guard] 警告: ${config_file} は不正な JSON です。設定は無視されます。" >&2
        return 0
    fi

    # allowlist を読み込み（文字列型のみ、空文字列除外）
    local allowlist_json
    allowlist_json=$(jq -r '.allowlist // [] | .[] | select(type == "string" and length > 0)' "$config_file" 2>/dev/null || true)
    if [ -n "$allowlist_json" ]; then
        while IFS= read -r pattern; do
            [ -z "$pattern" ] && continue
            # 過度に広いパターンを拒否
            if is_dangerous_allowlist_pattern "$pattern"; then
                echo "[secret-guard] 警告: allowlist パターン '${pattern}' は過度に広いため無視されます。" >&2
                continue
            fi
            ALLOWLIST_PATTERNS+=("$pattern")
        done <<< "$allowlist_json"
    fi

    # blocklist を読み込み（文字列型のみ、空文字列除外）
    local blocklist_json
    blocklist_json=$(jq -r '.blocklist // [] | .[] | select(type == "string" and length > 0)' "$config_file" 2>/dev/null || true)
    if [ -n "$blocklist_json" ]; then
        while IFS= read -r pattern; do
            [ -n "$pattern" ] && BLOCKLIST_PATTERNS+=("$pattern")
        done <<< "$blocklist_json"
    fi
}

# パスが allowlist パターンにマッチするか判定
# 引数: $1 = チェック対象のファイルパス
# 戻り値: 0 = マッチ（許可）, 1 = 非マッチ
is_allowlisted() {
    local filepath="$1"
    local basename
    basename="$(basename "$filepath")"

    # 空配列の場合は即座に非マッチ（set -u 対策）
    if [ ${#ALLOWLIST_PATTERNS[@]} -eq 0 ]; then
        return 1
    fi

    for pattern in "${ALLOWLIST_PATTERNS[@]}"; do
        # ディレクトリパターン（末尾が /）
        if [[ "$pattern" == */ ]]; then
            local dir_name="${pattern%/}"
            if [[ "$filepath" == *"/${dir_name}/"* ]] || [[ "$filepath" == "${dir_name}/"* ]] || \
               [[ "$filepath" == *"/${dir_name}" ]] || [[ "$filepath" == "${dir_name}" ]]; then
                return 0
            fi
            continue
        fi
        # basename でのマッチ
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern) return 0 ;;
        esac
        # フルパスでのマッチ
        # shellcheck disable=SC2254
        case "$filepath" in
            $pattern) return 0 ;;
        esac
    done

    return 1
}

# パスが blocklist パターンにマッチするか判定
# 引数: $1 = チェック対象のファイルパス
# 戻り値: 0 = マッチ（ブロック）, 1 = 非マッチ
is_blocklisted() {
    local filepath="$1"
    local basename
    basename="$(basename "$filepath")"

    # 空配列の場合は即座に非マッチ（set -u 対策）
    if [ ${#BLOCKLIST_PATTERNS[@]} -eq 0 ]; then
        return 1
    fi

    for pattern in "${BLOCKLIST_PATTERNS[@]}"; do
        # ディレクトリパターン（末尾が /）
        if [[ "$pattern" == */ ]]; then
            local dir_name="${pattern%/}"
            if [[ "$filepath" == *"/${dir_name}/"* ]] || [[ "$filepath" == "${dir_name}/"* ]] || \
               [[ "$filepath" == *"/${dir_name}" ]] || [[ "$filepath" == "${dir_name}" ]]; then
                return 0
            fi
            continue
        fi
        # basename でのマッチ
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern) return 0 ;;
        esac
        # フルパスでのマッチ
        # shellcheck disable=SC2254
        case "$filepath" in
            $pattern) return 0 ;;
        esac
    done

    return 1
}

# ファイル名パターン（basename マッチ）
SECRET_FILE_PATTERNS=(
    '.env'
    '.env.*'
    '.env.local'
    '.env.production'
    '.env.staging'
    '.env.development'
    'credentials.json'
    'credentials.yml'
    'credentials.yaml'
    'secrets.json'
    'secrets.yml'
    'secrets.yaml'
    'secrets.toml'
    'service-account*.json'
    'serviceAccountKey*.json'
    '.netrc'
    '.npmrc'
    '.docker/config.json'
    'token.json'
    'tokens.json'
    'auth.json'
    'oauth*.json'
    '.htpasswd'
    '.htaccess'
    'wp-config.php'
    'database.yml'
)

# 拡張子パターン
SECRET_EXTENSION_PATTERNS=(
    '*.pem'
    '*.key'
    '*.p12'
    '*.pfx'
    '*.jks'
    '*.keystore'
    '*.p8'
    '*.gpg'
    '*.asc'
)

# ディレクトリパターン（このディレクトリ配下は全てブロック）
SECRET_DIR_PATTERNS=(
    '.ssh/'
    '.gnupg/'
    '.aws/'
    '.gcloud/'
)

# Bash コマンドでブロック対象のファイルアクセスコマンド
FILE_ACCESS_COMMANDS=(
    'cat'
    'head'
    'tail'
    'less'
    'more'
    'bat'
    'source'
    '.'
    'cp'
    'mv'
    'base64'
    'xxd'
)

# git 操作でブロック対象のサブコマンド
GIT_BLOCK_SUBCOMMANDS=(
    'add'
    'commit'
    'push'
)

# パスがシークレットパターンにマッチするか判定
# 判定フロー: allowlist → blocklist → デフォルトパターン
# 引数: $1 = チェック対象のファイルパス
# 戻り値: 0 = マッチ（シークレット）, 1 = 非マッチ
is_secret_path() {
    local filepath="$1"
    local basename
    basename="$(basename "$filepath")"

    # 1. allowlist にマッチ → 許可（即座に return）
    if is_allowlisted "$filepath"; then
        return 1
    fi

    # 2. blocklist にマッチ → ブロック
    if is_blocklisted "$filepath"; then
        return 0
    fi

    # 3. デフォルトパターンにマッチ → ブロック

    # ディレクトリパターンチェック
    for pattern in "${SECRET_DIR_PATTERNS[@]}"; do
        local dir_name="${pattern%/}"
        if [[ "$filepath" == *"/${dir_name}/"* ]] || [[ "$filepath" == "${dir_name}/"* ]] || \
           [[ "$filepath" == *"/${dir_name}" ]] || [[ "$filepath" == "${dir_name}" ]]; then
            return 0
        fi
    done

    # ファイル名パターンチェック（glob マッチ）
    for pattern in "${SECRET_FILE_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern) return 0 ;;
        esac
    done

    # フルパスで .docker/config.json 等をチェック
    if [[ "$filepath" == *".docker/config.json" ]]; then
        return 0
    fi

    # 拡張子パターンチェック
    for pattern in "${SECRET_EXTENSION_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern) return 0 ;;
        esac
    done

    # 4. いずれにもマッチしない → 許可
    return 1
}

# マッチしたパターンの説明を返す
# 引数: $1 = チェック対象のファイルパス
get_secret_reason() {
    local filepath="$1"
    local basename
    basename="$(basename "$filepath")"

    # blocklist マッチチェック（デフォルトパターンより先に確認）
    if [ ${#BLOCKLIST_PATTERNS[@]} -gt 0 ]; then
    for pattern in "${BLOCKLIST_PATTERNS[@]}"; do
        if [[ "$pattern" == */ ]]; then
            local dir_name="${pattern%/}"
            if [[ "$filepath" == *"/${dir_name}/"* ]] || [[ "$filepath" == "${dir_name}/"* ]] || \
               [[ "$filepath" == *"/${dir_name}" ]] || [[ "$filepath" == "${dir_name}" ]]; then
                echo "blocklist パターン (${pattern})"
                return
            fi
            continue
        fi
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern)
                echo "blocklist パターン (${pattern})"
                return
                ;;
        esac
        # shellcheck disable=SC2254
        case "$filepath" in
            $pattern)
                echo "blocklist パターン (${pattern})"
                return
                ;;
        esac
    done
    fi

    # デフォルトパターン
    for pattern in "${SECRET_DIR_PATTERNS[@]}"; do
        local dir_name="${pattern%/}"
        if [[ "$filepath" == *"/${dir_name}/"* ]] || [[ "$filepath" == "${dir_name}/"* ]] || \
           [[ "$filepath" == *"/${dir_name}" ]] || [[ "$filepath" == "${dir_name}" ]]; then
            echo "機密ディレクトリ (${dir_name}/) 配下のファイル"
            return
        fi
    done

    for pattern in "${SECRET_FILE_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern)
                echo "シークレットファイル (${pattern})"
                return
                ;;
        esac
    done

    if [[ "$filepath" == *".docker/config.json" ]]; then
        echo "Docker 認証設定ファイル (.docker/config.json)"
        return
    fi

    for pattern in "${SECRET_EXTENSION_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern)
                echo "機密鍵ファイル (${pattern})"
                return
                ;;
        esac
    done

    echo "不明なシークレットパターン"
}
