---
allowed-tools: Read, Glob, Grep, Bash
argument-hint: <filepath>
description: 指定されたファイルパスがどの .claude/rules/ に該当するかを即座に確認
model: claude-haiku-4-5-20251001
---

# Check File Rules Coverage

指定されたファイルパスに適用される `.claude/rules/` のルールを確認します。

## 使用方法

```
/memory-optimizer:check-file <filepath>
```

## 引数

- `<filepath>`: チェックするファイルのパス（相対パスまたは絶対パス）

## 実行内容

以下のステップを自動的に実行します：

### Step 1: 引数の解析

```
ファイルパス: $ARGUMENTS
```

- 引数が空の場合はエラーメッセージを表示
- 相対パスを絶対パスに正規化（必要に応じて）

### Step 2: Rules ディレクトリの確認

```bash
# .claude/rules/ ディレクトリの存在確認
if [ ! -d ".claude/rules" ]; then
  echo "Error: .claude/rules/ directory not found"
  echo "This project does not have any rules configured."
  exit 1
fi
```

### Step 3: 全ルールファイルの検索

```bash
# .claude/rules/ 配下の全 .md ファイルを検索
find .claude/rules -type f -name "*.md" | sort
```

### Step 4: 各ルールの paths 条件を抽出

各ルールファイルについて：

1. フロントマターを抽出
2. `paths` フィールドの値を取得
3. JSON/YAML 配列を解析

例:
```bash
# フロントマターの抽出（--- から --- まで）
sed -n '/^---$/,/^---$/p' .claude/rules/example.md

# paths フィールドの抽出
grep '^paths:' -A 100 | sed '/^[a-z]:/q'
```

### Step 5: パターンマッチング判定

各 paths パターンについて、指定されたファイルパスとのマッチングを判定：

```bash
# 簡易的なマッチング（Bash の case 文を使用）
file_path="$ARGUMENTS"
pattern="src/**/*.tsx"

# extglob を有効化
shopt -s extglob nullglob

# パターンマッチング
case "$file_path" in
  $pattern)
    echo "✓ Match: $pattern"
    ;;
  *)
    echo "✗ No match"
    ;;
esac
```

**注意**: Bash の `case` 文は `**` パターンを完全にはサポートしないため、以下の代替実装を使用：

```bash
# find コマンドを使用した判定
if find . -path "./$pattern" -type f 2>/dev/null | grep -q "^\./$file_path$"; then
  echo "✓ Match"
else
  echo "✗ No match"
fi
```

または、より確実な方法として Python を使用：

```bash
python3 <<EOF
import fnmatch
import sys

file_path = "$file_path"
pattern = "$pattern"

# ** を * に変換して fnmatch で判定（簡易実装）
if '**' in pattern:
    # ** を含むパターンは pathlib.Path.match を使用
    from pathlib import Path
    p = Path(file_path)
    if p.match(pattern):
        print("✓ Match")
        sys.exit(0)

# 通常の fnmatch
if fnmatch.fnmatch(file_path, pattern):
    print("✓ Match")
else:
    print("✗ No match")
EOF
```

### Step 6: 結果の整形と表示

```
File: src/components/Button.tsx

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Matching Rules:

✓ .claude/rules/frontend-standards.md
  Paths: ["src/components/**/*.tsx", "src/pages/**/*.tsx"]
  Match pattern: src/components/**/*.tsx

✓ .claude/rules/typescript-guidelines.md
  Paths: ["**/*.tsx", "**/*.ts"]
  Match pattern: **/*.tsx

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Applied Rules (in priority order):
1. frontend-standards.md (more specific)
2. typescript-guidelines.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
- 2 rules apply to this file
- Most specific rule: frontend-standards.md

Recommendation:
When editing this file, ensure compliance with:
- frontend-standards.md guidelines
- typescript-guidelines.md guidelines
```

マッチしない場合:

```
File: scripts/deploy.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

No matching rules found.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommendation:
This file is not covered by any .claude/rules/.
Consider adding a rule if this file type requires specific guidelines.

Example rule creation:
  .claude/rules/scripts-guidelines.md
  paths: ["scripts/**/*.sh"]
```

## エラーハンドリング

### ケース 1: 引数が指定されていない

```
Error: No file path specified

Usage:
  /memory-optimizer:check-file <filepath>

Examples:
  /memory-optimizer:check-file src/components/Button.tsx
  /memory-optimizer:check-file lib/utils/format.ts
```

### ケース 2: .claude/rules/ ディレクトリが存在しない

```
Error: .claude/rules/ directory not found

This project does not have any rules configured yet.

To get started:
1. Create .claude/rules/ directory
2. Add rule files (e.g., .claude/rules/typescript.md)
3. Define paths conditions in frontmatter

See: /memory-optimizer:rules-guide for more information
```

### ケース 3: ファイルが存在しない

```
Warning: File does not exist: src/components/Missing.tsx

Checking rules coverage anyway...
(This is useful for planning new file creation)
```

## 使用例

### 例 1: TypeScript ファイルの確認

```
/memory-optimizer:check-file src/utils/format.ts
```

### 例 2: React コンポーネントの確認

```
/memory-optimizer:check-file src/components/Header/index.tsx
```

### 例 3: 設定ファイルの確認

```
/memory-optimizer:check-file .eslintrc.js
```

### 例 4: 新規ファイル作成前の確認

```
/memory-optimizer:check-file src/pages/NewPage.tsx
```

## 実装のヒント

### glob パターンマッチングの実装

以下のいずれかの方法を使用：

**方法 1: Python を使用（推奨）**

```bash
python3 <<'EOF'
from pathlib import Path
import sys

file_path = sys.argv[1]
pattern = sys.argv[2]

p = Path(file_path)
if p.match(pattern):
    sys.exit(0)  # Match
else:
    sys.exit(1)  # No match
EOF
```

**方法 2: find コマンドを使用**

```bash
# パターンにマッチするファイルを検索
if find . -path "./$pattern" 2>/dev/null | grep -qF "./$file_path"; then
    echo "Match"
fi
```

**方法 3: Bash の case 文（限定的）**

```bash
# ** を除く単純なパターンのみ対応
shopt -s extglob
case "$file_path" in
    $pattern) echo "Match" ;;
esac
```

### paths フィールドの抽出

```bash
# YAML フロントマターから paths を抽出
extract_paths() {
    local rule_file="$1"

    # フロントマター部分を抽出
    sed -n '/^---$/,/^---$/p' "$rule_file" | \
    # paths 行以降を取得
    sed -n '/^paths:/,/^[a-z]:/p' | \
    # 最後の行（次のフィールド）を除外
    sed '$d' | \
    # paths: を除去
    sed 's/^paths://' | \
    # 配列要素を抽出（"..." 形式）
    grep -o '"[^"]*"' | \
    # クォートを除去
    tr -d '"'
}
```

### 優先順位の計算

より具体的なパターンを優先：

```bash
# パターンの具体性スコアを計算
calc_specificity() {
    local pattern="$1"
    local score=0

    # ディレクトリ階層の深さ
    score=$((score + $(echo "$pattern" | tr -cd '/' | wc -c)))

    # ワイルドカードの少なさ
    score=$((score - $(echo "$pattern" | tr -cd '*' | wc -c)))

    echo "$score"
}
```

## パフォーマンス

- 小規模プロジェクト（< 10 rules）: < 1秒
- 中規模プロジェクト（10-50 rules）: 1-3秒
- 大規模プロジェクト（> 50 rules）: 3-10秒

## トラブルシューティング

### Q: パターンマッチングが期待通りに動作しない

A: デバッグモードで実行して詳細を確認：

```bash
# デバッグ出力を有効化
set -x
# コマンド実行
set +x
```

### Q: 複数行の paths 配列が正しく解析できない

A: より堅牢な解析方法を使用：

```bash
# Python の yaml モジュールを使用
python3 -c "
import yaml
import sys
with open('$rule_file') as f:
    content = f.read()
    # フロントマター抽出
    parts = content.split('---')
    if len(parts) >= 3:
        frontmatter = yaml.safe_load(parts[1])
        if 'paths' in frontmatter:
            for p in frontmatter['paths']:
                print(p)
"
```

## 関連コマンド

- `/memory-optimizer:audit` - プロジェクト全体のメモリ監査
- `/memory-optimizer:optimize` - メモリ最適化の提案

## 関連スキル

- `file-path-matcher` - このコマンドが内部的に使用
- `rules-guide` - rules フォルダの使い方
- `memory-audit` - メモリ監査の詳細
