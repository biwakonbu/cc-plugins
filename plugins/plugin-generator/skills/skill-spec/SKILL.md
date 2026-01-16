---
name: skill-spec
description: Claude Code プラグインの skill 仕様知識。スキルの正しい形式、フロントマター、description のベストプラクティスを提供。Use when creating, updating, or maintaining skills, understanding skill structure, or implementing SKILL.md files. Also use when user says スキル, SKILL.md, skills.
allowed-tools: Read, Grep, Glob
---

# Skill Spec スキル

Claude Code プラグインの skill 仕様知識を提供する。

## Instructions

このスキルは skill の正しい形式と実装パターンについての知識を提供します。

**重要**: 実装前に必ず公式ドキュメント（英語版）を確認し、最新の仕様に従ってください。

## 公式ドキュメント

- [Skills](https://code.claude.com/docs/en/skills)

---

## スキルとは

- Claude が特定タスクを実行する方法を教える Markdown ファイル
- ユーザーの要求が description にマッチすると Claude が**自動的に**適用
- PR レビュー、コミット生成、データベースクエリなどの標準化に最適

---

## ファイル配置

```
skills/{skill-name}/SKILL.md
```

- ディレクトリ名がスキル名になる
- kebab-case を使用（例: `my-skill/SKILL.md`）
- ファイル名は必ず `SKILL.md`（大文字）

---

## フロントマター

### 必須フィールド

```yaml
---
name: skill-name           # 必須: kebab-case（最大64文字）
description: 説明           # 必須: いつ使うか明記（最大1024文字）
---
```

### オプションフィールド

```yaml
---
name: skill-name
description: 説明
allowed-tools: Read, Grep, Glob
context: fork                     # v2.1.0+
agent: custom-agent               # v2.1.0+
user-invocable: true              # v2.1.3+
---
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `name` | String | スキル識別子（必須） |
| `description` | String | いつ使うかを含む説明（必須） |
| `allowed-tools` | String | 使用可能ツールを制限 |
| `context` | String | `fork` でサブエージェントとして実行（v2.1.0+） |
| `agent` | String | 実行エージェント指定（v2.1.0+） |
| `user-invocable` | Boolean | スラッシュメニュー表示制御（v2.1.3+） |
| `hooks` | Object | スキル固有フック（v2.1.0+） |

**重要**: skills では `model` 指定は使用できません。モデル指定が必要な場合は agents を使用してください。

---

## description のベストプラクティス

### 良い例

```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**ポイント:**
- 具体的なアクション名を含める（extract, fill, merge）
- ユーザーが使う用語を含める（PDFs, forms）
- いつ使うかを明記（Use when ...）

### 悪い例

```yaml
description: Helps with documents
```

**問題:**
- 曖昧すぎる
- いつ使うかが不明
- ユーザーの用語が含まれていない

---

## 構造

```markdown
---
name: my-skill
description: 説明。Use when ...
allowed-tools: Read, Grep, Glob
---

# スキル名

## Instructions

ステップバイステップの指示

## Examples

具体的な使用例
```

**重要**: フロントマターは必ず1行目から `---` で開始（空行不可）

---

## 呼び出しフロー

1. **Discovery**: 起動時に name と description のみロード
2. **Activation**: ユーザー要求が description にマッチ → 確認プロンプト
3. **Execution**: 承認後、完全な SKILL.md をロードして実行

---

## フォークコンテキスト（v2.1.0+）

`context: fork` を指定すると、スキルが独立したサブエージェントとして実行されます。

### 利点

- メイン会話のコンテキストを汚染しない
- トークン消費を抑制
- 複雑なスキルの干渉を防止

### agent フィールドとの組み合わせ

```yaml
---
name: web-research
description: Web 検索を実行。Use when user needs web research.
context: fork
agent: researcher  # ビルトイン: Explore, Plan / カスタム: .claude/agents/ のエージェント
---
```

### 使用ケース

| ケース | context 設定 |
|--------|-------------|
| 単純な知識提供 | 省略（メインコンテキスト） |
| 複雑な調査・分析 | `fork` |
| 独立した検索・レポート生成 | `fork` + `agent` 指定 |
| セキュリティレビュー | `fork` + `allowed-tools` 制限 |

### user-invocable オプション（v2.1.3+）

- `user-invocable: true`（デフォルト）: スラッシュコマンドメニューに表示
- `user-invocable: false`: メニューから非表示（自動トリガーのみ）

---

## 実装例

### 基本的なスキル

```markdown
---
name: code-formatter
description: コードをフォーマットする。Use when user mentions formatting, prettier, or code style.
allowed-tools: Read, Bash
---

# Code Formatter スキル

## Instructions

1. 対象ファイルを特定
2. prettier または適切なフォーマッターを実行
3. 結果を報告

## Examples

### TypeScript ファイルのフォーマット

```bash
npx prettier --write "src/**/*.ts"
```
```

### 知識提供型スキル

```markdown
---
name: api-design
description: REST API 設計の知識を提供。Use when user asks about API design, endpoints, or REST patterns.
allowed-tools: Read, Grep, Glob
---

# API Design スキル

## Instructions

このスキルは REST API 設計のベストプラクティスを提供します。

### エンドポイント命名規則

- リソース名は複数形（例: `/users`, `/posts`）
- 動詞は使用しない（例: `/getUsers` → `/users`）
- ネストは2レベルまで（例: `/users/{id}/posts`）

### HTTP メソッド

| メソッド | 用途 |
|---------|------|
| GET | リソース取得 |
| POST | リソース作成 |
| PUT | リソース全体更新 |
| PATCH | リソース部分更新 |
| DELETE | リソース削除 |

## Examples

### ユーザー API

- `GET /users` - ユーザー一覧
- `GET /users/{id}` - ユーザー詳細
- `POST /users` - ユーザー作成
```

### フォークコンテキストを使ったスキル

```markdown
---
name: comprehensive-research
description: 複数情報源から包括的調査を実施。Use when user needs deep analysis or multi-source research.
context: fork
agent: Explore
allowed-tools: Read, Bash, WebFetch, Grep
---

# Comprehensive Research スキル

## Instructions

1. 対象トピックの概要を把握
2. 複数の情報源から調査
3. 結果を統合して分析
4. 簡潔なレポートを作成

## Examples

### 技術調査

「React と Vue の比較調査」→ 公式ドキュメント、ベンチマーク、エコシステムを調査
```

---

## バリデーションルール

| ルール | 重要度 |
|--------|--------|
| フロントマターに `name` 必須 | エラー |
| フロントマターに `description` 必須 | エラー |
| ディレクトリ名は kebab-case | 推奨 |
| ファイル名は `SKILL.md` | 必須 |
| `model` フィールドは使用不可 | 注意 |

## Examples

### スキル作成の相談

```
Q: スキルの description はどう書けばいい？
A: 具体的なアクション名と「Use when ...」でいつ使うかを明記してください。
   例: "Extract data from CSV files. Use when user mentions CSV or spreadsheet data."
```

### model 指定の相談

```
Q: スキルで使うモデルを指定したい
A: skills では model 指定は使用できません。モデル指定が必要な場合は、
   agents を作成し、そのエージェントからスキルを参照してください。
```
