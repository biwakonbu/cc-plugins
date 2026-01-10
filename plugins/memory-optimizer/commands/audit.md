---
description: 現在のメモリ構成を監査し、最適化ポイントをレポート
allowed-tools: Read, Glob, Grep, Bash(wc:*), Bash(ls:*)
---

# /memory-optimizer:audit

プロジェクトのメモリ構成を監査し、改善点を報告します。

## 監査手順

以下の順序で監査を実施してください:

### 1. ファイル存在チェック

確認するファイル:
- `./CLAUDE.md` - プロジェクトメモリ
- `./.claude/rules/` - ルールフォルダ
- `./CLAUDE.local.md` - ローカルメモリ

### 2. サイズ分析

各ファイルの行数を確認:
```bash
wc -l CLAUDE.md
```

評価基準:
- 〜150行: 最適
- 150-300行: 良好
- 300行超: 要改善

### 3. 内容チェック

CLAUDE.md に以下が含まれているか確認:
- [ ] プロジェクト概要
- [ ] 技術スタック
- [ ] 開発コマンド
- [ ] コーディング規約

### 4. rules フォルダ分析

存在する場合:
```bash
ls -la .claude/rules/
```

確認項目:
- ファイル数（推奨: 〜10）
- 各ファイルのサイズ
- paths 条件の有無

### 4.1. paths カバレッジ分析（新機能）

rules フォルダが存在する場合、各ルールの paths 条件を分析:

**手順**:

1. 全ルールファイルから paths 条件を抽出
2. 各 paths パターンに該当するファイルをリストアップ
3. カバレッジ統計を計算

**実装例**:

```bash
# 全ルールファイルを検索
for rule_file in .claude/rules/*.md; do
  echo "Rule: $(basename "$rule_file")"

  # フロントマターから paths を抽出
  paths=$(sed -n '/^---$/,/^---$/p' "$rule_file" | \
          grep '^paths:' -A 100 | \
          sed '/^[a-z]:/q' | \
          grep -o '"[^"]*"' | \
          tr -d '"')

  if [ -n "$paths" ]; then
    echo "Paths:"
    echo "$paths" | while read -r pattern; do
      # パターンにマッチするファイルを検索
      matched_count=$(find . -path "./$pattern" -type f 2>/dev/null | wc -l)
      echo "  - $pattern: $matched_count files"
    done
  else
    echo "  No paths condition"
  fi
  echo ""
done
```

**分析項目**:
- 各 paths パターンにマッチするファイル数
- 重複するカバレッジの検出
- カバーされていないファイルタイプの特定

**出力例**:

```
## Paths Coverage Analysis

### Rule: frontend-standards.md
Paths:
  - src/components/**/*.tsx: 45 files
  - src/pages/**/*.tsx: 12 files
Total coverage: 57 files

### Rule: typescript-guidelines.md
Paths:
  - **/*.ts: 120 files
  - **/*.tsx: 57 files
Total coverage: 177 files

### Coverage Summary
- Total rules with paths: 5
- Total files covered: 234
- Overlapping coverage: 57 files (multiple rules apply)
- Uncovered file types: .sh, .json, .md (consider adding rules)
```

### 5. 問題点の特定

以下をチェック:
- 300行超のファイル → 分離を推奨
- 特定ファイル向けルールが CLAUDE.md にある → rules に移動
- 重複内容 → 統合を推奨
- 秘密情報 → 即時削除

## 出力フォーマット

以下の形式でレポートを出力:

```markdown
# メモリ監査レポート

## 概要

| 項目 | 状態 | 詳細 |
|------|------|------|
| CLAUDE.md | ✓/△/× | XX行 |
| rules フォルダ | ✓/△/× | Xファイル |
| ローカルメモリ | ✓/− | 有無 |

## Paths カバレッジ分析（新機能）

### 全体統計

- Total rules: X
- Rules with paths: X
- Total files covered: XXX
- Uncovered files: XX
- Overlapping coverage: XX files

### ルール別詳細

#### Rule: frontend-standards.md
- Paths: ["src/components/**/*.tsx"]
- Matched files: 45
- Sample matches:
  - src/components/Button.tsx
  - src/components/Header.tsx

#### Rule: typescript-guidelines.md
- Paths: ["**/*.ts", "**/*.tsx"]
- Matched files: 177

### 未カバーファイル（サンプル）

以下のファイルはどの rules にも該当しません:
- scripts/deploy.sh
- config/webpack.config.js
- .eslintrc.js

推奨: これらのファイルタイプに rules が必要か検討してください。

### 重複カバレッジ

以下のファイルは複数の rules に該当します（優先度順に適用）:
- src/components/Button.tsx
  - frontend-standards.md (優先)
  - typescript-guidelines.md

## 評価: A/B/C/D

## 良い点

- ...

## 改善点

1. [優先度高] ...
2. [優先度中] ...
3. [優先度低] ...

## 推奨アクション

1. ...
2. ...
```

## 注意事項

- ファイルの内容を読み取り、構成を分析してください
- 具体的な改善提案を含めてください
- 優先度を付けて推奨アクションを提示してください
