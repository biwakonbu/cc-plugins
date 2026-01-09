---
name: agent-spec
description: Claude Code プラグインの agent 仕様知識。サブエージェントの正しい形式、フロントマター、tools/model/skills フィールドを提供。Use when creating, updating, or maintaining agents, understanding agent structure, or implementing subagents. Also use when user says エージェント, サブエージェント, agents.
allowed-tools: Read, Grep, Glob
---

# Agent Spec スキル

Claude Code プラグインの agent（サブエージェント）仕様知識を提供する。

## Instructions

このスキルは agent の正しい形式と実装パターンについての知識を提供します。

**重要**: 実装前に必ず公式ドキュメント（英語版）を確認し、最新の仕様に従ってください。

## 公式ドキュメント

- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Claude Models (API)](https://docs.anthropic.com/en/docs/about-claude/models)

---

## エージェントとは

- 独立したコンテキストでタスクを実行するサブプロセス
- 親から呼び出され、結果を返す
- 専用の tools, model, skills を持つことができる

---

## ファイル配置

```
agents/{agent-name}.md
agents/{category}/{agent-name}.md  # サブディレクトリ可
```

- ファイル名がエージェント名になる
- kebab-case を使用（例: `code-reviewer.md`）
- サブディレクトリでカテゴリ分類可能

---

## フロントマター

### 必須フィールド

```yaml
---
name: agent-name
description: いつ呼ばれるかの説明
---
```

### オプションフィールド

```yaml
---
name: agent-name
description: いつ呼ばれるかの説明
tools: Read, Glob, Grep, Bash
model: haiku
permissionMode: default
skills: skill1, skill2
---
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `name` | String | エージェント識別子（必須） |
| `description` | String | いつ呼ばれるかの説明（必須） |
| `tools` | String | 使用可能ツール（省略時は全継承） |
| `model` | String | 使用モデル |
| `permissionMode` | String | 権限モード |
| `skills` | String | 使用するスキル（カンマ区切り） |

---

## tools フィールド

| 指定 | 動作 |
|------|------|
| 省略 | 親の全ツール + MCP ツールを継承 |
| 指定 | 指定ツールのみ使用可能 |

### 例

```yaml
# 読み取り専用エージェント
tools: Read, Glob, Grep

# 実行可能エージェント
tools: Read, Glob, Grep, Bash, Write, Edit
```

---

## model フィールド

エージェントでは短縮名を指定：

| 値 | 説明 |
|----|------|
| `haiku` | 高速・定型タスク向け（推奨） |
| `opus` | 最高性能・複雑なタスク向け |
| `inherit` | 親から継承 |

**注意**: `sonnet` は現在の Claude Code では推奨されません。

### 例

```yaml
# 高速エージェント
model: haiku

# 高精度エージェント
model: opus

# 親と同じ
model: inherit
```

---

## skills フィールド

エージェントはスキルを**自動継承しません**。使用するスキルは明示的に指定：

```yaml
skills: security-check, code-style
```

**注意**: ビルトインエージェント（Explore, Plan, Verify）と Task ツールはスキルにアクセス不可

---

## permissionMode フィールド

| 値 | 説明 |
|----|------|
| `default` | デフォルト権限 |
| `bypassPermissions` | 権限チェックをバイパス |

---

## 実装例

### 基本的なエージェント

```markdown
---
name: code-reviewer
description: コードレビューを担当。コード品質、セキュリティ、パフォーマンスを評価。
tools: Read, Glob, Grep
model: haiku
---

# Code Reviewer エージェント

あなたはコードレビューを担当するサブエージェントです。

## 役割

1. コードを読み込む
2. 品質・セキュリティ・パフォーマンスを評価
3. 改善点を報告

## 出力フォーマット

レビュー結果を構造化して報告してください。
```

### スキル参照エージェント

```markdown
---
name: security-auditor
description: セキュリティ監査を担当。脆弱性、認証、認可をチェック。
tools: Read, Glob, Grep
model: haiku
skills: security-check, owasp-top10
---

# Security Auditor エージェント

あなたはセキュリティ監査を担当するサブエージェントです。

## 役割

1. security-check スキルに従ってコードを分析
2. owasp-top10 スキルの知識を活用
3. 脆弱性を報告

## 出力フォーマット

| 脆弱性 | 重要度 | 推奨対策 |
|--------|--------|---------|
| ... | ... | ... |
```

### 実行系エージェント

```markdown
---
name: test-runner
description: テスト実行を担当。ユニットテスト、統合テストを実行し結果を報告。
tools: Read, Glob, Grep, Bash
model: haiku
---

# Test Runner エージェント

あなたはテスト実行を担当するサブエージェントです。

## 役割

1. テストコマンドを実行
2. 結果を解析
3. 失敗テストを報告

## 実行フロー

1. テストスクリプト検出（package.json, pytest.ini など）
2. テスト実行
3. 結果解析と報告
```

---

## バリデーションルール

| ルール | 重要度 |
|--------|--------|
| フロントマターに `name` 必須 | エラー |
| フロントマターに `description` 必須 | エラー |
| ファイル名は kebab-case | 推奨 |
| model は短縮名（haiku, opus, inherit） | 必須（指定時） |

## Examples

### エージェント作成の相談

```
Q: 新しいエージェントを作りたい
A: agents/{name}.md を作成し、フロントマターに name と description を必ず含めてください。
   tools で使用可能ツールを制限、model でモデルを指定できます。
```

### スキル参照の相談

```
Q: エージェントでスキルを使いたい
A: フロントマターに skills: skill-name1, skill-name2 のように指定してください。
   エージェントはスキルを自動継承しないため、明示的な指定が必要です。
```

### model 指定の相談

```
Q: エージェントで使うモデルを軽量にしたい
A: フロントマターに model: haiku を追加してください。
   定型タスクには haiku が推奨です。短縮名（haiku, opus, inherit）を使用します。
```
