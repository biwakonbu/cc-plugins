---
name: file-path-matcher
description: 任意のファイルパスが .claude/rules/ の paths 条件に該当するかを判定する。ファイル操作前の確認、paths 条件のテスト、rules 適用範囲の確認に使用。Determines if a file path matches any paths conditions in .claude/rules/. Use when checking if a file is covered by rules, testing path patterns, verifying rules coverage, or when the user asks about rule applicability.
allowed-tools: Read, Glob, Grep, Bash
---

# file-path-matcher スキル

このスキルは、指定されたファイルパスが `.claude/rules/` 配下のルールファイルの `paths` 条件に該当するかを判定します。

## 使用場面

- ファイル編集・作成前に適用される rules を確認したい
- paths 条件のパターンマッチングをテストしたい
- プロジェクト内のファイルがどの rules でカバーされているかを知りたい
- rules の適用範囲を視覚化したい

## 主要機能

### 1. ファイルパスのマッチング判定

指定されたファイルパスに対して、以下を実行します：

1. `.claude/rules/` 配下の全ルールファイル（`*.md`）を検索
2. 各ルールファイルのフロントマターから `paths` フィールドを抽出
3. paths パターンと指定ファイルパスのマッチング判定
4. マッチした rules をリスト化

### 2. Glob パターンマッチングロジック

以下の glob パターンに対応：

| パターン | 説明 | 例 |
|---------|------|-----|
| `*` | 任意の文字列（パスセパレータを除く） | `*.ts` → `app.ts` |
| `**` | 任意のディレクトリ階層 | `src/**/*.tsx` → `src/components/Button.tsx` |
| `?` | 任意の1文字 | `test?.ts` → `test1.ts` |
| `[abc]` | 指定文字のいずれか | `file[123].ts` → `file1.ts` |
| `{a,b}` | いずれかのパターン | `{src,lib}/*.ts` → `src/app.ts` |

### 3. マッチング結果の表示

以下の形式で結果を表示します：

```
File: src/components/Button.tsx

Matching Rules:
✓ .claude/rules/frontend-standards.md
  - Paths: ["src/components/**/*.tsx", "src/pages/**/*.tsx"]
  - Match pattern: src/components/**/*.tsx

✓ .claude/rules/typescript-guidelines.md
  - Paths: ["**/*.tsx", "**/*.ts"]
  - Match pattern: **/*.tsx

Applied Rules (in priority order):
1. frontend-standards.md
2. typescript-guidelines.md

No rules match
```

## 実装ガイドライン

### Step 1: ルールファイルの検索

```bash
# .claude/rules/ 配下の全 .md ファイルを検索
find .claude/rules -type f -name "*.md" 2>/dev/null
```

### Step 2: paths 条件の抽出

各ルールファイルのフロントマターから `paths` フィールドを抽出：

```bash
# フロントマターの paths を抽出（YAML配列形式）
sed -n '/^---$/,/^---$/p' .claude/rules/example.md | grep '^paths:' -A 100
```

### Step 3: パターンマッチング

Bash の `case` 文を使用してパターンマッチング：

```bash
file_path="src/components/Button.tsx"
pattern="src/**/*.tsx"

# Bash の extglob を有効化
shopt -s extglob

case "$file_path" in
  $pattern) echo "Match" ;;
  *) echo "No match" ;;
esac
```

**重要な注意事項**:
- Bash の `case` 文では `**` を標準サポートしない
- `**` パターンは手動で再帰的マッチングを実装する必要がある
- 代替手段として `find` コマンドの `-path` オプションを使用可能

### Step 4: 優先順位の決定

複数の rules がマッチした場合、以下の優先順位で適用：

1. より具体的なパターン（`src/components/*.tsx` > `**/*.tsx`）
2. ファイル名の辞書順（同じ具体性の場合）

## 使用例

### 例1: 単一ファイルの確認

```
ユーザー: src/components/Button.tsx はどの rules が適用されますか？
```

AI の応答:
1. `.claude/rules/` 配下のルールファイルを検索
2. 各ルールの paths 条件を抽出
3. `src/components/Button.tsx` とマッチング判定
4. マッチした rules をリスト表示

### 例2: paths パターンのテスト

```
ユーザー: "src/**/*.tsx" パターンは src/components/Header/index.tsx にマッチしますか？
```

AI の応答:
1. パターン `src/**/*.tsx` を解析
2. ファイルパス `src/components/Header/index.tsx` とマッチング
3. 結果を明示（この場合は Match）

### 例3: 未カバーファイルの検出

```
ユーザー: scripts/deploy.sh はどの rules でカバーされていますか？
```

AI の応答:
1. 全 rules の paths 条件を確認
2. `scripts/deploy.sh` とマッチング判定
3. マッチしない場合は "No rules apply" と表示

## パフォーマンス考慮事項

- 小規模プロジェクト（< 10 rules）: 即座に結果を返す
- 中規模プロジェクト（10-50 rules）: 数秒以内に完了
- 大規模プロジェクト（> 50 rules）: 結果をキャッシュしない（最新状態を保証）

## エラーハンドリング

以下のケースを適切に処理：

1. `.claude/rules/` ディレクトリが存在しない
   → "No rules directory found" と表示

2. ルールファイルに paths フィールドがない
   → そのルールをスキップ

3. paths フィールドが不正な形式
   → 警告を表示してスキップ

4. ファイルパスが相対パスでない
   → プロジェクトルートからの相対パスに変換

## ベストプラクティス

1. **ファイル操作前の確認**
   - 編集や削除の前に該当 rules を確認
   - rules で定義されたガイドラインを遵守

2. **paths 条件の設計検証**
   - 新しい paths パターンを追加する前にテスト
   - 意図したファイルのみがマッチするかを確認

3. **カバレッジの可視化**
   - 定期的に未カバーファイルをチェック
   - 重要なファイルタイプが漏れていないか確認

## 関連スキル

- `memory-optimizer:rules-guide` - rules フォルダの基本的な使い方
- `memory-optimizer:memory-audit` - メモリ全体の監査
- `memory-optimizer:best-practices` - メモリ管理のベストプラクティス

## トラブルシューティング

### Q: "**" パターンがマッチしない

A: Bash の `case` 文は `**` を標準サポートしません。以下の代替手段を使用：

```bash
# find コマンドを使用
find . -path "src/**/*.tsx" -type f
```

### Q: 相対パスと絶対パスの混在

A: 全てのパスをプロジェクトルートからの相対パスに正規化：

```bash
# 絶対パスを相対パスに変換
realpath --relative-to="$PROJECT_ROOT" "$file_path"
```

### Q: paths が YAML 配列として正しく抽出できない

A: 複数行にわたる YAML 配列を正しく解析：

```bash
# Python や jq を使用して確実に解析
python3 -c "import yaml; print(yaml.safe_load(open('rule.md'))['paths'])"
```

---

## 実装チェックリスト

AI がこのスキルを実装する際の確認項目：

- [ ] `.claude/rules/` ディレクトリの存在確認
- [ ] 全ルールファイル（`*.md`）の検索
- [ ] 各ルールのフロントマターから paths 抽出
- [ ] glob パターンマッチングの実装
- [ ] マッチング結果の整形と表示
- [ ] エラーケースの適切な処理
- [ ] 優先順位の正しい計算
- [ ] ユーザーフレンドリーな出力形式
