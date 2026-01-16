# memory-optimizer プラグイン

## 概要

Claude Code のメモリ管理（CLAUDE.md、rules、imports）を最適化するための知識とワークフローを提供するプラグイン。
ユーザーがメモリ設定に関する質問をすると、適切なスキルが自動発動して情報を提供する。

## ディレクトリ構造

```
memory-optimizer/
├── .claude-plugin/plugin.json
├── CLAUDE.md
├── skills/
│   ├── memory-overview/SKILL.md     # 全体概要・ナビゲーション
│   ├── claude-md-guide/SKILL.md     # CLAUDE.md 記載ガイド
│   ├── rules-guide/SKILL.md         # rules フォルダ活用ガイド
│   ├── migration-guide/SKILL.md     # CLAUDE.md → rules 移行ガイド
│   ├── memory-audit/SKILL.md        # メモリ監査・最適化
│   └── best-practices/SKILL.md      # ベストプラクティス集
├── commands/
│   ├── audit.md                     # メモリ監査コマンド
│   ├── check-file.md                # ファイルの rules マッチング確認
│   └── optimize.md                  # 最適化提案コマンド
└── agents/                          # 自動発見（plugin.json での指定は非推奨）
    └── memory-advisor.md            # メモリ最適化アドバイザー
```

## スキル一覧

| スキル | 役割 | 発動条件 |
|--------|------|----------|
| memory-overview | 全体概要・ナビゲーション | 「メモリとは」「メモリ管理」 |
| claude-md-guide | CLAUDE.md 記載ガイド | 「CLAUDE.md の書き方」「何を書くべき」 |
| rules-guide | rules フォルダ活用 | 「rules フォルダ」「paths 条件」 |
| migration-guide | CLAUDE.md → rules 移行 | 「分離したい」「移行したい」 |
| memory-audit | メモリ監査・最適化 | 「監査」「チェック」「分析」 |
| best-practices | ベストプラクティス | 「ベストプラクティス」「推奨」 |
| **file-path-matcher** | **ファイルパスの rules マッチング判定（v1.1.0）** | **「該当する rules」「マッチング」** |

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `/memory-optimizer:audit` | 現在のメモリ構成を分析・レポート（paths カバレッジ分析を追加） |
| `/memory-optimizer:optimize` | 具体的な最適化提案を生成 |
| **`/memory-optimizer:check-file`** | **指定ファイルに該当する rules を即座に確認（v1.1.0）** |

## エージェント

| エージェント | 説明 |
|-------------|------|
| memory-advisor | 複雑なメモリ最適化相談に対応するアドバイザー（file-path-matcher スキルを統合） |

## 設計方針

### context: fork の活用（v1.2.0）

**知識提供スキル（4つ）**:
- `memory-overview`, `claude-md-guide`, `rules-guide`, `best-practices`
- `context: fork` でサブエージェント化

**参照スキル（1つ）**:
- `migration-guide`: `context: fork` + `user-invocable: false`
- スラッシュメニューから非表示だが、他スキルから参照可能

### スキル設計

- 各スキルは独立した知識領域を担当
- description に日英両方のキーワードを含む
- "Use when ..." パターンで発動条件を明確化

### コマンド設計

- 明示的なアクションが必要な場合に使用
- 分析結果を構造化されたフォーマットで出力

### エージェント設計

- 複数スキルを組み合わせた総合的なアドバイス
- haiku モデルで高速応答

## 情報ソース

- 公式ドキュメント: https://code.claude.com/docs/en/memory
- 実践例: cc-plugins プロジェクトの各プラグイン

## コマンド実装ガイドライン

### ユーザー確認（AskUserQuestion ツール使用）

各コマンドでは以下の場面でユーザーに確認を求める:

**optimize コマンド:**
- ファイル移動・削除の実行前
- CLAUDE.md の内容を rules に分離する前
- 既存ファイルを上書きする前

**audit コマンド:**
- paths カバレッジ分析結果の報告前

**check-file コマンド:**
- マッチング結果の表示前（複数 rules にマッチする場合は一覧表示）

## メンテナンス指針

- 公式ドキュメントの更新に追従
- 実践的なユースケースを随時追加
- バージョン更新時は plugin.json の version も更新
- コマンド変更時は CLAUDE.md の「コマンド実装ガイドライン」セクションも更新
