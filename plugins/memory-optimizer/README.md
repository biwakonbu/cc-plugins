# memory-optimizer

Claude Code のメモリ管理（CLAUDE.md、rules、imports）を最適化するための知識とワークフローを提供するプラグイン。

**v1.1.0 新機能**: ファイルパスの rules マッチング判定機能を追加。

## インストール

```bash
/plugin install memory-optimizer@cc-plugins
```

## 概要

Claude Code のメモリシステムを効果的に活用するために、CLAUDE.md ファイル、Rules フォルダ、imports 機能の管理と最適化に関する包括的なガイダンスを提供します。

対応バージョン: Claude Code v2.1.3+

## 使い方

### 自動発動（スキル）

以下のような質問をすると自動的に発動します:

```
# メモリ監査
メモリの使用状況を監査したい
CLAUDE.md のサイズが大きすぎるかもしれない

# 最適化ガイド
CLAUDE.md を効率的に書く方法は?
Rules フォルダの構成ベストプラクティスは?

# ベストプラクティス
メモリ管理の基本的な考え方は?
imports 機能をどう活用すべき?

# マイグレーション
複数ファイルから CLAUDE.md へ統合したい
既存の設定を整理したい

# ファイルパスのマッチング判定（v1.1.0 新機能）
src/components/Button.tsx はどの rules が適用されますか?
このファイルパスが該当する rules を確認したい
```

### コマンド実行

明示的にコマンドを実行することもできます:

```bash
# メモリ全体の監査（paths カバレッジ分析を含む）
/memory-optimizer:audit

# 最適化提案の生成
/memory-optimizer:optimize

# 特定ファイルの rules 確認（v1.1.0 新機能）
/memory-optimizer:check-file src/components/Button.tsx
```

## 提供される知識

- **CLAUDE.md 管理**: ファイル構造、内容品質基準、更新タイミング
- **Rules フォルダ**: パスベースルール定義、優先度管理
- **imports 機能**: 外部ファイル参照、モジュール化
- **メモリ監査**: 使用状況の診断、改善提案
- **最適化ワークフロー**: 段階的な改善手法
- **ベストプラクティス**: メモリ利用の推奨パターン
- **マイグレーション**: 既存設定から新体系への移行ガイド
- **ファイルパスマッチング（v1.1.0）**: 任意のファイルが rules の paths 条件に該当するかの判定

## 機能

| 種類 | 名前 | 用途 |
|------|------|------|
| コマンド | `/memory-optimizer:audit` | メモリ使用状況の監査（paths カバレッジ分析を含む） |
| コマンド | `/memory-optimizer:optimize` | メモリの最適化提案 |
| **コマンド** | **`/memory-optimizer:check-file`** | **指定ファイルに該当する rules の確認（v1.1.0）** |
| スキル | `memory-overview` | メモリシステムの概要説明 |
| スキル | `memory-audit` | メモリ監査の実行ガイド |
| スキル | `best-practices` | ベストプラクティスの提供（paths 設計を追加） |
| スキル | `claude-md-guide` | CLAUDE.md 管理ガイド |
| スキル | `rules-guide` | Rules フォルダ管理ガイド |
| スキル | `migration-guide` | マイグレーションガイド |
| **スキル** | **`file-path-matcher`** | **ファイルパスの rules マッチング判定（v1.1.0）** |
| エージェント | `memory-advisor` | メモリ最適化アドバイザー（file-path-matcher を統合） |

## 前提条件

Claude Code がインストールされていること:

```bash
npm install -g @anthropic/claude-code
```

## ライセンス

MIT
