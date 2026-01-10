---
name: rules-guide
description: .claude/rules フォルダの活用ガイド。paths 条件の書き方、ディレクトリ構成、ルール分離のベストプラクティスを提供。Use when user asks about rules folder, paths condition, rule files, or modular memory. Also use when user says rules フォルダ, paths 条件, ルール分離, モジュール化.
---

# Rules Guide スキル

`.claude/rules/` フォルダを活用したモジュラーなメモリ管理の知識を提供。

## Instructions

このスキルは rules フォルダの構成方法と paths 条件の書き方を詳しく説明します。

---

## rules フォルダとは

`.claude/rules/` に配置された Markdown ファイル群。トピック別にルールを分離し、paths 条件で適用範囲を制御できます。

**配置場所**: `./.claude/rules/*.md`

---

## 基本構成

### 推奨ディレクトリ構造

```
.claude/
├── settings.json
├── settings.local.json      # ローカル設定（Git 除外）
└── rules/
    ├── code-style.md        # コードスタイル
    ├── testing.md           # テスト規約
    ├── security.md          # セキュリティ
    ├── api-design.md        # API 設計
    ├── frontend/
    │   ├── react.md         # React ルール
    │   └── styling.md       # スタイリング
    └── backend/
        ├── database.md      # DB 操作
        └── api-endpoints.md # エンドポイント
```

---

## paths 条件

### フロントマター形式

```yaml
---
paths:
  - "src/api/**/*"
  - "tests/api/**/*"
---

# API 開発ルール

このルールは src/api と tests/api 配下のファイルにのみ適用されます。
```

### 対応パターン

| パターン | 説明 | 例 |
|---------|------|-----|
| `*` | 任意の文字（ディレクトリ区切り除く） | `*.ts` |
| `**` | 任意の深さのディレクトリ | `src/**/*.ts` |
| `[abc]` | 文字クラス | `[jt]s` → js, ts |
| `{a,b}` | OR 選択 | `{src,lib}/**/*` |
| `?` | 任意の1文字 | `file?.ts` |

### パターン例

```yaml
# TypeScript ファイルのみ
paths:
  - "**/*.ts"
  - "**/*.tsx"

# src と lib 配下
paths:
  - "{src,lib}/**/*"

# テストファイルのみ
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"

# 特定ディレクトリ
paths:
  - "src/components/**/*"
  - "src/hooks/**/*"

# 設定ファイル
paths:
  - "*.config.{js,ts,json}"
  - ".eslintrc.*"
```

---

## ルールファイルの書き方

### 基本テンプレート

```markdown
---
paths:
  - "src/api/**/*"
---

# API 開発ルール

## エンドポイント命名

- リソース名は複数形（`/users`, `/posts`）
- 動詞は使用しない（`/getUsers` → `/users`）
- ネストは2レベルまで

## レスポンス形式

```json
{
  "success": true,
  "data": {...},
  "meta": {...}
}
```

## エラーハンドリング

- 400: バリデーションエラー
- 401: 認証エラー
- 404: リソース未発見
- 500: サーバーエラー
```

### paths なしのルール

paths を省略すると全ファイルに適用:

```markdown
---
# paths を省略 = 全ファイルに適用
---

# 全体セキュリティルール

- 入力値は必ずバリデーション
- SQL インジェクション対策
- XSS 対策
```

---

## ルール分離の基準

### rules に分離すべき内容

| 条件 | 理由 |
|------|------|
| 50行以上のセクション | CLAUDE.md の肥大化防止 |
| 特定ファイル形式のみに適用 | paths 条件の活用 |
| 頻繁に更新される | 影響範囲の限定 |
| 独立したトピック | 可読性向上 |

### CLAUDE.md に残すべき内容

| 内容 | 理由 |
|------|------|
| プロジェクト概要 | 常に参照される |
| 技術スタック | 基本情報 |
| 開発コマンド | 頻繁に使用 |
| 重要な制約 | 常に意識すべき |

---

## 読み込み順序と優先度

1. 全ての rules ファイルがスキャンされる
2. paths 条件でフィルタリング
3. マッチしたルールが適用される
4. 同じ内容は後のルールが上書き

**注意**: 複数ルールがマッチした場合、全て適用されます。

---

## ベストプラクティス

### ファイル命名

```
.claude/rules/
├── 01-code-style.md      # 番号プレフィックスで順序制御
├── 02-testing.md
├── 03-security.md
└── api/
    ├── design.md
    └── validation.md
```

### 内容の粒度

```markdown
# 良い例: 具体的
- 関数名は動詞から始める（getUser, createPost）
- 型定義は types/ ディレクトリに集約

# 悪い例: 抽象的
- 良いコードを書く
- 適切に命名する
```

### 重複の回避

```markdown
# セキュリティルール（security.md）
このルールでは認証・認可について記載。

# API ルール（api-design.md）では認証の詳細は security.md を参照。
認証については `.claude/rules/security.md` を参照してください。
```

---

## Examples

### React コンポーネント用ルール

```markdown
---
paths:
  - "src/components/**/*.tsx"
  - "src/components/**/*.ts"
---

# React コンポーネントルール

## ファイル構成

- 1ファイル1コンポーネント
- スタイルは同ディレクトリに配置

## 命名規則

- コンポーネント: PascalCase
- ファイル: コンポーネント名と同じ

## Props 定義

```typescript
interface Props {
  // 必須 props
  title: string;
  // オプション props
  className?: string;
}
```
```

### テスト用ルール

```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
---

# テストルール

## 命名規則

```typescript
describe('UserService', () => {
  it('should create a new user', () => {
    // ...
  });
});
```

## アサーション

- `expect().toBe()` - プリミティブ値
- `expect().toEqual()` - オブジェクト
- `expect().toThrow()` - 例外
```
