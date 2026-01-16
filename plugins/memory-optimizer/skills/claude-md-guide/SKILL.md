---
name: claude-md-guide
description: CLAUDE.md の記載ガイド。何を書くべきか、推奨サイズ、避けるべき内容を提供。Use when user asks about CLAUDE.md, what to write in CLAUDE.md, memory configuration, or project instructions. Also use when user says CLAUDE.md の書き方, メモリ設定, 何を書くべき, プロジェクト指示.
context: fork
---

# CLAUDE.md Guide スキル

CLAUDE.md に記載すべき内容と構成のベストプラクティスを提供。

## Instructions

このスキルは CLAUDE.md の適切な構成と内容について詳しく説明します。

---

## CLAUDE.md とは

プロジェクトのルートに配置する Markdown ファイル。Claude Code がセッション開始時に自動的に読み込み、プロジェクト固有のコンテキストとして使用します。

**配置場所**: `./CLAUDE.md`（プロジェクトルート）

---

## 推奨構成

### 基本テンプレート

```markdown
# プロジェクト名

## 概要

プロジェクトの目的と主要機能の簡潔な説明。

## 技術スタック

- 言語: TypeScript
- フレームワーク: Next.js 15
- データベース: PostgreSQL
- パッケージマネージャー: pnpm

## ディレクトリ構造

```
src/
├── app/          # Next.js App Router
├── components/   # React コンポーネント
├── lib/          # ユーティリティ
└── types/        # 型定義
```

## 開発コマンド

| コマンド | 説明 |
|---------|------|
| `pnpm dev` | 開発サーバー起動 |
| `pnpm build` | 本番ビルド |
| `pnpm test` | テスト実行 |
| `pnpm lint` | リント実行 |

## コーディング規約

- 変数名・関数名は英語（camelCase）
- コメントは日本語
- 型定義は明示的に記述

## 重要な制約

- 本番環境への直接デプロイは禁止
- `.env` ファイルはコミットしない
```

---

## 推奨サイズ

| 規模 | 推奨行数 | 説明 |
|------|---------|------|
| 小規模 | 50-100行 | シンプルなプロジェクト |
| 中規模 | 150-300行 | 一般的なプロジェクト |
| 大規模 | 300行以下 | 超えたら rules に分離 |

**警告**: 300行を超えたら `rules` フォルダへの分離を検討してください。

---

## 記載すべき内容

### 必須項目

| 項目 | 内容 | 例 |
|------|------|-----|
| プロジェクト概要 | 目的と主要機能 | 「ECサイトのバックエンドAPI」 |
| 技術スタック | 使用技術一覧 | 言語、フレームワーク、DB |
| 開発コマンド | 日常的に使うコマンド | dev, build, test, lint |

### 推奨項目

| 項目 | 内容 | 例 |
|------|------|-----|
| ディレクトリ構造 | 主要ディレクトリの説明 | src/, tests/, docs/ |
| コーディング規約 | 命名規則、スタイル | camelCase, 日本語コメント |
| 重要な制約 | 守るべきルール | 禁止事項、セキュリティ |

### オプション項目

| 項目 | 内容 |
|------|------|
| アーキテクチャ概要 | 全体構成図や設計方針 |
| API エンドポイント概要 | 主要な API の一覧 |
| 環境変数一覧 | 必要な環境変数（値は除く） |

---

## 避けるべき内容

### rules に移動すべき

| 内容 | 理由 | 移動先 |
|------|------|--------|
| 詳細な実装パターン | 肥大化防止 | `rules/patterns.md` |
| 特定ファイル形式のルール | paths 条件活用 | `rules/typescript.md` |
| テスト規約（詳細） | 独立管理 | `rules/testing.md` |
| セキュリティ規約（詳細） | 独立管理 | `rules/security.md` |

### 記載すべきでない

| 内容 | 理由 |
|------|------|
| 秘密情報（API キーなど） | セキュリティリスク |
| 一時的なメモ | メモリを汚染 |
| 変更履歴 | Git で管理 |
| 冗長な説明 | トークン効率低下 |

---

## imports の活用

巨大な CLAUDE.md を避けるため、imports を活用:

```markdown
# プロジェクト名

## 概要
...

## 詳細ドキュメント

アーキテクチャの詳細は @./docs/architecture.md を参照。
API 設計は @./docs/api-design.md を参照。
```

---

## 階層別 CLAUDE.md

サブディレクトリにも CLAUDE.md を配置可能:

```
project/
├── CLAUDE.md              # プロジェクト全体
├── src/
│   ├── CLAUDE.md          # src 固有のルール
│   └── components/
│       └── CLAUDE.md      # コンポーネント固有
└── tests/
    └── CLAUDE.md          # テスト固有
```

**注意**: 階層が深いほどスコープが限定される。

---

## Examples

### 最小構成

```markdown
# my-project

## 概要
シンプルな TODO アプリ。

## 技術スタック
- TypeScript
- React
- Vite

## コマンド
- `npm run dev` - 開発
- `npm test` - テスト
```

### 規約付き構成

```markdown
# my-project

## 概要
...

## コーディング規約

### 命名規則
- 変数・関数: camelCase
- クラス・型: PascalCase
- 定数: UPPER_SNAKE_CASE

### コメント
- 公開 API には JSDoc 必須
- 複雑なロジックには説明コメント
```
