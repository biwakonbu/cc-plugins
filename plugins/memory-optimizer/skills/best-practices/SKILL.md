---
name: best-practices
description: メモリ管理のベストプラクティス集。推奨パターン、アンチパターン、実践的なヒントを提供。Use when user asks about best practices, recommended patterns, memory tips, or how to write good memory. Also use when user says ベストプラクティス, 推奨, コツ, ヒント, 良い書き方.
context: fork
---

# Best Practices スキル

メモリ管理のベストプラクティスとアンチパターンを提供。

## Instructions

このスキルはメモリ管理の推奨パターンと避けるべきパターンを説明します。

---

## ベストプラクティス一覧

### 1. 簡潔さを保つ

**推奨**:
```markdown
## コマンド
- `npm run dev` - 開発サーバー
- `npm test` - テスト実行
```

**避ける**:
```markdown
## 開発コマンドについて
開発を行う際には、以下のコマンドを使用します。
まず、npm run dev コマンドを実行すると開発サーバーが起動します。
このコマンドは Hot Module Replacement をサポートしており...
（長い説明が続く）
```

### 2. 具体的に書く

**推奨**:
```markdown
## 命名規則
- 変数: camelCase（例: `userName`, `isActive`）
- 定数: UPPER_SNAKE（例: `MAX_RETRY_COUNT`）
- クラス: PascalCase（例: `UserService`）
```

**避ける**:
```markdown
## 命名規則
適切な命名を心がけてください。
```

### 3. 階層を活用

**推奨**:
```
project/
├── CLAUDE.md           # 全体ルール（100行）
├── .claude/rules/
│   ├── api.md          # API ルール
│   └── testing.md      # テストルール
└── src/
    └── CLAUDE.md       # src 固有ルール
```

**避ける**:
```
project/
└── CLAUDE.md           # 全部入り（500行）
```

### 4. paths 条件を活用

**推奨**:
```yaml
---
paths:
  - "**/*.test.ts"
---

# テストルール
テストファイルにのみ適用されるルール
```

**避ける**:
```markdown
# テストルール
※ このルールは *.test.ts ファイルにのみ適用してください
（paths 条件を使っていない）
```

### 5. 重複を避ける

**推奨**:
```markdown
# CLAUDE.md
セキュリティについては `.claude/rules/security.md` を参照。
```

**避ける**:
```markdown
# CLAUDE.md
## セキュリティ
- 入力検証必須
...

# .claude/rules/api.md
## セキュリティ（重複）
- 入力検証必須
...
```

---

## アンチパターン

### 1. 巨大な CLAUDE.md

**問題**: 500行以上の単一ファイル

**影響**:
- トークン効率低下
- 読みづらい
- 更新が困難

**対策**: rules フォルダに分離

### 2. 曖昧な指示

**問題**:
```markdown
- 良いコードを書く
- 適切にエラーハンドリング
```

**影響**:
- Claude が判断できない
- 一貫性がない

**対策**: 具体的なルールを記載

### 3. 秘密情報の記載

**問題**:
```markdown
## API Keys
- OpenAI: sk-xxx...
- AWS: AKIA...
```

**影響**:
- セキュリティリスク
- Git に含まれる

**対策**: 環境変数を使用、CLAUDE.local.md に分離

### 4. 過度な細分化

**問題**: 50個の小さな rules ファイル

**影響**:
- 管理困難
- 全体像が見えない

**対策**: 関連ルールを統合

### 5. 更新されない情報

**問題**: 古いコマンドやルールが残っている

**影響**:
- 誤った指示
- 混乱

**対策**: 定期的なレビュー

---

## 実践的なヒント

### ヒント1: テンプレートから始める

新規プロジェクトは以下から開始:

```markdown
# プロジェクト名

## 概要
1-2文で説明

## 技術スタック
- 言語:
- フレームワーク:
- DB:

## コマンド
| コマンド | 説明 |
|---------|------|
| | |

## 規約
- 変数名: camelCase
- コメント: 日本語
```

### ヒント2: 段階的に拡充

```
Week 1: 基本情報のみ
Week 2: コーディング規約追加
Week 3: 必要に応じて rules 分離
Week 4: レビューと最適化
```

### ヒント3: チーム共有

```markdown
# チームでのメモリ管理

1. CLAUDE.md はリポジトリに含める
2. CLAUDE.local.md は各自で設定
3. rules の追加は PR でレビュー
```

### ヒント4: 定期レビュー

```
□ 月次: 内容の正確性確認
□ 四半期: 構成の見直し
□ 年次: 大規模リファクタリング
```

---

## チェックリスト

### CLAUDE.md チェック

```
□ 300行以下か
□ プロジェクト概要があるか
□ 技術スタックが明記されているか
□ 開発コマンドが正確か
□ 秘密情報が含まれていないか
□ 具体的なルールが記載されているか
```

### rules チェック

```
□ 20ファイル以下か
□ 各ファイル200行以下か
□ paths 条件が適切か
□ 重複がないか
□ 命名が分かりやすいか
```

### 全体チェック

```
□ 構成が分かりやすいか
□ 更新しやすいか
□ チームメンバーが理解できるか
□ 実際に Claude の応答が改善されているか
```

---

## 良い例・悪い例

### コーディング規約

**良い例**:
```markdown
## TypeScript 規約

### 型定義
- `any` は禁止（`unknown` を使用）
- 戻り値の型は明示
- オブジェクトは `interface` を使用

### エラー処理
- try-catch は最外層で
- カスタムエラークラスを使用
```

**悪い例**:
```markdown
## TypeScript 規約
TypeScript のベストプラクティスに従ってください。
型安全なコードを書きましょう。
```

### プロジェクト概要

**良い例**:
```markdown
## 概要
EC サイトのバックエンド API。
ユーザー認証、商品管理、注文処理を提供。
```

**悪い例**:
```markdown
## 概要
このプロジェクトは素晴らしいアプリケーションです。
多くの機能があります。
```

---

## Examples

### 新規プロジェクトの設定

```
Q: 新しいプロジェクトのメモリ設定のベストプラクティスを教えて
A: テンプレートから始め、プロジェクト概要、技術スタック、コマンドを記載。
   規模が大きくなったら rules に分離することを推奨します。
```

### 既存プロジェクトの改善

```
Q: 今の CLAUDE.md をベストプラクティスに沿って改善したい
A: まず監査を実施し、肥大化したセクションの分離、曖昧な記述の具体化、
   重複の削除を順に行います。
```

---

## 新機能: paths 条件設計とファイル検出活用

### 1. paths 条件設計のベストプラクティス

#### 具体性の原則

**推奨**: 必要な範囲のみを対象にする

```yaml
# Good: 具体的なディレクトリとファイルタイプを指定
paths:
  - "src/components/**/*.tsx"
  - "src/pages/**/*.tsx"
```

**避ける**: 過度に広範囲なパターン

```yaml
# Bad: プロジェクト全体を対象にしてしまう
paths:
  - "**/*.tsx"  # すべての .tsx ファイルが対象
```

#### 重複の最小化

**推奨**: 重複しない paths 設計

```yaml
# .claude/rules/frontend.md
paths:
  - "src/components/**/*.tsx"

# .claude/rules/typescript.md
paths:
  - "src/utils/**/*.ts"  # 重複しない
```

**避ける**: 広範囲な重複

```yaml
# .claude/rules/frontend.md
paths:
  - "src/**/*.tsx"

# .claude/rules/typescript.md
paths:
  - "**/*.tsx"  # frontend.md と重複が多い
```

#### 階層構造の活用

**推奨**: ディレクトリ構造に合わせた paths

```yaml
# .claude/rules/api-routes.md
paths:
  - "src/app/api/**/*.ts"

# .claude/rules/server-actions.md
paths:
  - "src/app/actions/**/*.ts"
```

**避ける**: 不規則なパターン

```yaml
# .claude/rules/backend.md
paths:
  - "src/app/api/**/*.ts"
  - "lib/utils/api-*.ts"
  - "config/api.ts"
  # 関連性が薄いパスが混在
```

### 2. ファイル検出を活用した運用フロー

#### 新規ファイル作成前の確認

ファイルを作成する前に、該当する rules を確認:

```
1. 作成予定のファイルパスを決定
   例: src/components/NewButton.tsx

2. /memory-optimizer:check-file で該当 rules を確認
   /memory-optimizer:check-file src/components/NewButton.tsx

3. 表示された rules のガイドラインに従って実装
```

#### 既存ファイル編集時の確認手順

編集前に適用される rules を把握:

```
1. 編集対象ファイルを特定
   例: src/utils/format.ts

2. check-file コマンドで rules を確認
   /memory-optimizer:check-file src/utils/format.ts

3. 該当 rules の内容を読んで編集方針を決定
```

#### rules 追加時のカバレッジ検証

新しい rule を追加したら、カバレッジを検証:

```
1. 新しい rule ファイルを作成
   .claude/rules/new-feature.md

2. paths 条件を設定
   paths: ["src/features/new/**/*.ts"]

3. /memory-optimizer:audit で全体のカバレッジを確認
   - 意図したファイルがカバーされているか
   - 他の rules と重複していないか
   - 漏れているファイルがないか
```

### 3. paths パターンの実践例

#### プロジェクト規模別の推奨パターン

**小規模プロジェクト（< 50 ファイル）**

```yaml
# .claude/rules/typescript.md
paths:
  - "**/*.ts"
  - "**/*.tsx"

# シンプルな構成で十分
```

**中規模プロジェクト（50-500 ファイル）**

```yaml
# .claude/rules/components.md
paths:
  - "src/components/**/*.tsx"

# .claude/rules/utils.md
paths:
  - "src/utils/**/*.ts"

# .claude/rules/api.md
paths:
  - "src/api/**/*.ts"

# 機能別に分離
```

**大規模プロジェクト（500+ ファイル）**

```yaml
# .claude/rules/ui/buttons.md
paths:
  - "src/components/Button/**/*.tsx"
  - "src/components/IconButton/**/*.tsx"

# .claude/rules/ui/forms.md
paths:
  - "src/components/Form/**/*.tsx"
  - "src/components/Input/**/*.tsx"

# .claude/rules/features/auth.md
paths:
  - "src/features/auth/**/*.ts"
  - "src/features/auth/**/*.tsx"

# より細かく分離
```

#### 特殊なユースケース

**テストファイルのみ対象**

```yaml
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
```

**特定のディレクトリを除外**

```yaml
# paths では除外ができないため、該当する範囲のみを指定
paths:
  - "src/app/**/*.tsx"  # src/app 配下のみ
  # src/legacy は対象外（paths で除外できない）
```

**複数の拡張子を含む**

```yaml
paths:
  - "src/scripts/**/*.js"
  - "src/scripts/**/*.ts"
  - "src/scripts/**/*.sh"
```

### 4. トラブルシューティング

#### Q: paths が期待通りにマッチしない

**確認方法**:

```bash
# check-file コマンドでテスト
/memory-optimizer:check-file <your-file-path>
```

**よくある原因**:
- `**` パターンの誤用（ディレクトリ区切りを含む再帰的マッチング）
- 相対パスの基準が異なる（プロジェクトルートからの相対パス）
- glob パターンの記法ミス

#### Q: 複数の rules が同じファイルにマッチする

**対応方法**:

1. より具体的な paths に分離
2. 意図的な重複の場合は、優先順位を明示
3. audit コマンドで重複を可視化

```bash
/memory-optimizer:audit
# "Overlapping coverage" セクションで重複を確認
```

#### Q: カバーされていないファイルがある

**確認方法**:

```bash
/memory-optimizer:audit
# "Uncovered file types" セクションで未カバーファイルを確認
```

**対応方針**:
- 重要なファイルタイプは rules を追加
- 一時ファイルや自動生成ファイルは放置
- プロジェクト固有の判断で決定

### 5. 実践チェックリスト

#### 新しい rule を追加する前

- [ ] 対象ファイルの範囲を明確に定義
- [ ] paths パターンをテスト（check-file で確認）
- [ ] 既存 rules との重複をチェック
- [ ] 適用範囲が適切か検証（広すぎ/狭すぎないか）

#### 定期的なメンテナンス

- [ ] /memory-optimizer:audit で全体カバレッジを確認（月1回推奨）
- [ ] 重複する paths を整理
- [ ] 未カバーファイルに rules が必要か判断
- [ ] 使われていない rules を削除

#### ファイル操作時

- [ ] 編集・作成前に check-file で該当 rules を確認
- [ ] rules の内容を理解してから実装
- [ ] 複数 rules が該当する場合は優先順位を確認

---

## まとめ

paths 条件とファイル検出機能を活用することで、以下が実現できます:

1. **運用精度の向上**: AI が正しい rules を認識して実装
2. **開発効率の向上**: paths 条件のテストとカバレッジ把握が容易
3. **メンテナンス性の向上**: 重複や漏れを早期発見

これらの機能を組み合わせて、プロジェクトのメモリ管理を最適化してください。
