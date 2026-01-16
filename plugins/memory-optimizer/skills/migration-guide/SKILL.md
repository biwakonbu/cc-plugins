---
name: migration-guide
description: CLAUDE.md から rules フォルダへの移行ガイド。分離すべき条件、移行手順、ステップバイステップの説明を提供。Use when user wants to migrate content from CLAUDE.md to rules, split memory, or reorganize memory structure. Also use when user says 分離したい, 移行したい, リファクタリング, 整理したい.
context: fork
user-invocable: false
---

# Migration Guide スキル

CLAUDE.md から rules フォルダへコンテンツを移行する方法を提供。

## Instructions

このスキルは CLAUDE.md の内容を rules フォルダに移行する判断基準と手順を説明します。

---

## 移行が必要なサイン

### 警告サイン

| サイン | 説明 | 対応 |
|--------|------|------|
| CLAUDE.md が300行超 | 肥大化 | 即座に分離検討 |
| 特定ファイル用のルールが混在 | 非効率 | paths 条件で分離 |
| セクションが50行超 | 読みづらい | 個別ファイルに分離 |
| 頻繁な更新 | 変更影響が大きい | 独立管理 |

### チェックリスト

```
□ CLAUDE.md の行数を確認
□ 特定ファイル形式向けのルールがあるか
□ 独立したトピック（テスト、セキュリティなど）があるか
□ 更新頻度が高いセクションがあるか
```

---

## 移行判断マトリクス

| 内容 | CLAUDE.md に残す | rules に移行 |
|------|-----------------|--------------|
| プロジェクト概要 | ✓ | |
| 技術スタック | ✓ | |
| 開発コマンド | ✓ | |
| コーディング規約（概要） | ✓ | |
| コーディング規約（詳細） | | ✓ |
| テスト規約 | | ✓ |
| セキュリティ規約 | | ✓ |
| API 設計ガイド | | ✓ |
| フレームワーク固有ルール | | ✓ |
| DB 操作ルール | | ✓ |

---

## 移行手順

### Step 1: 現状分析

```bash
# CLAUDE.md の行数確認
wc -l CLAUDE.md

# 現在の構成確認
/memory
```

### Step 2: 分離対象の特定

CLAUDE.md を読み、以下を特定:

1. **50行以上のセクション**をマーク
2. **特定ファイル向け**のルールをマーク
3. **独立トピック**をマーク

### Step 3: rules ディレクトリ作成

```bash
mkdir -p .claude/rules
```

### Step 4: ルールファイル作成

各トピックごとにファイルを作成:

```markdown
---
paths:
  - "適用対象のパスパターン"
---

# ルール名

移行した内容をここに記載
```

### Step 5: CLAUDE.md の更新

移行した内容を削除し、参照を追加:

```markdown
# プロジェクト名

## 概要
（残す内容）

## 詳細ルール

詳細なルールは `.claude/rules/` を参照:
- コードスタイル: `rules/code-style.md`
- テスト: `rules/testing.md`
- セキュリティ: `rules/security.md`
```

### Step 6: 検証

```bash
# メモリのロード確認
/memory

# 動作テスト
# 実際のファイルで Claude の応答を確認
```

---

## 移行例

### Before: 肥大化した CLAUDE.md

```markdown
# my-project

## 概要
...

## 技術スタック
...

## TypeScript ルール（50行以上）
...詳細な型定義ルール...
...エラーハンドリング...
...命名規則...

## テストルール（80行以上）
...テスト構成...
...モック方法...
...カバレッジ基準...

## セキュリティ（40行）
...認証...
...認可...
```

### After: 分離後

**CLAUDE.md（簡潔化）**:
```markdown
# my-project

## 概要
...

## 技術スタック
...

## ルール参照

詳細なルールは `.claude/rules/` を参照。
```

**.claude/rules/typescript.md**:
```yaml
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript ルール

...（移行した内容）...
```

**.claude/rules/testing.md**:
```yaml
---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
---

# テストルール

...（移行した内容）...
```

**.claude/rules/security.md**:
```markdown
---
# paths なし = 全ファイルに適用
---

# セキュリティルール

...（移行した内容）...
```

---

## 移行時の注意点

### やるべきこと

- 移行前に CLAUDE.md をバックアップ
- 段階的に移行（一度に全部やらない）
- 移行後に `/memory` で確認
- 実際の作業で動作確認

### 避けるべきこと

- 内容の重複（同じルールを複数箇所に書かない）
- 過度な細分化（ファイルが多すぎると管理困難）
- paths 条件の複雑化（シンプルに保つ）

---

## トラブルシューティング

### ルールが適用されない

```
1. paths 条件を確認
2. ファイルパスがパターンにマッチするか確認
3. /memory でロード状態を確認
```

### 複数ルールが競合

```
1. 内容を統合
2. より具体的な paths を設定
3. 一方を削除
```

---

## Examples

### 段階的移行

```
Week 1: テストルールを移行
Week 2: セキュリティルールを移行
Week 3: API ルールを移行
Week 4: 残りを整理
```

### 最小移行

CLAUDE.md から最も大きいセクションだけを移行:

```bash
# 最大セクションを特定
# → testing セクションが80行

# rules/testing.md を作成
# CLAUDE.md から testing セクションを削除
# 参照を追加
```
