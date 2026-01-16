---
name: memory-overview
description: Claude Code のメモリシステム全体の概要とナビゲーション。CLAUDE.md、rules フォルダ、imports 機能の関係性と使い分けを提供。Use when user asks about memory system, what is memory, memory overview, or how memory works. Also use when user says メモリとは, メモリ管理, メモリシステム, 概要.
context: fork
---

# Memory Overview スキル

Claude Code のメモリシステム全体を理解するためのナビゲーションスキル。

## Instructions

このスキルはメモリシステムの全体像を説明し、詳細な質問には適切なスキルへ誘導します。

---

## メモリシステム概要

Claude Code は複数のメモリソースからプロジェクト固有の指示を読み込みます。

### メモリの種類

| 種類 | ファイル/場所 | 用途 |
|------|--------------|------|
| **Project Memory** | `./CLAUDE.md` | プロジェクト全体の指示（チーム共有） |
| **Project Rules** | `./.claude/rules/*.md` | トピック別の詳細ルール |
| **User Memory** | `~/.claude/CLAUDE.md` | ユーザー個人の共通設定 |
| **Local Memory** | `./CLAUDE.local.md` | ローカル専用設定（Git 除外） |
| **Enterprise** | システム指定パス | 組織ポリシー |

### 優先順位（高→低）

1. **Enterprise Policy** - 組織のシステムポリシー
2. **Project Rules** - `.claude/rules/*.md`
3. **Project Memory** - `./CLAUDE.md`
4. **User Memory** - `~/.claude/CLAUDE.md`
5. **Local Memory** - `./CLAUDE.local.md`

### ロードタイミング

- セッション開始時に全メモリがロードされる
- `rules/*.md` は paths 条件でフィルタリング可能
- imports（`@`記法）は最大5段階まで再帰的に解決

---

## メモリ構成の選択指針

### CLAUDE.md に書くべき内容

- プロジェクト概要
- 技術スタック
- 共通ワークフロー（ビルド、テスト）
- 重要な制約

**詳細**: `claude-md-guide` スキルを参照

### rules フォルダに分離すべき内容

- 50行以上の詳細ルール
- 特定ファイル形式にのみ適用されるルール
- 頻繁に更新されるルール

**詳細**: `rules-guide` スキルを参照

### 移行が必要な場合

- CLAUDE.md が300行を超えた
- セクションが肥大化している
- パス固有のルールが混在している

**詳細**: `migration-guide` スキルを参照

---

## imports 機能（@ 記法）

他のファイルをメモリに含める機能:

```markdown
# プロジェクト内ファイル
@./README.md
@./docs/architecture.md

# ユーザーメモリ
@~/.claude/my-preferences.md

# 相対パス
@../shared/common-rules.md
```

**制限**:
- 最大5段階の再帰
- コードブロック内の `@` は無視

---

## 確認コマンド

```
/memory
```

現在ロードされている全メモリファイルを確認できます。

---

## 関連スキル

| 質問の種類 | 参照スキル |
|----------|----------|
| CLAUDE.md の書き方 | `claude-md-guide` |
| rules フォルダの使い方 | `rules-guide` |
| 移行方法 | `migration-guide` |
| 監査・分析 | `memory-audit` |
| ベストプラクティス | `best-practices` |

---

## Examples

### メモリの仕組みを知りたい

```
Q: Claude Code のメモリってどう機能するの？
A: このスキルで全体像を説明します。CLAUDE.md、rules フォルダ、imports 機能の3つが主要なメモリソースです。
```

### 何をどこに書くべきか

```
Q: CLAUDE.md と rules フォルダ、どっちに書けばいい？
A: 全プロジェクトに共通する基本情報は CLAUDE.md、詳細なルールや特定ファイル向けの指示は rules フォルダに分離することを推奨します。
```
