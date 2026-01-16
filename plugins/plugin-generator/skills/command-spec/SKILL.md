---
name: command-spec
description: Claude Code プラグインの command 仕様知識。スラッシュコマンドの正しい形式、フロントマター、変数、model 指定を提供。Use when creating, updating, or maintaining commands, understanding command structure, or implementing slash commands. Also use when user says コマンド, スラッシュコマンド, commands.
context: fork
user-invocable: false
allowed-tools: Read, Grep, Glob
---

# Command Spec スキル

Claude Code プラグインの command（スラッシュコマンド）仕様知識を提供する。

## Instructions

このスキルは command の正しい形式と実装パターンについての知識を提供します。

**重要**: 実装前に必ず公式ドキュメント（英語版）を確認し、最新の仕様に従ってください。

## 公式ドキュメント

- [Slash Commands](https://code.claude.com/docs/en/slash-commands)

---

## ファイル配置

```
commands/{command-name}.md
```

- ファイル名がコマンド名になる
- kebab-case を使用（例: `my-command.md`）

---

## フロントマター

### 必須フィールド

```yaml
---
description: コマンドの説明（必須）
---
```

### オプションフィールド

```yaml
---
description: コマンドの説明
model: claude-haiku-4-5-20251001
allowed-tools: Read, Glob, Grep, Bash
argument-hint: [引数のヒント]
disable-model-invocation: false
---
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `description` | String | コマンドの説明（必須） |
| `model` | String | 使用モデル（フルモデル ID） |
| `allowed-tools` | String | 使用可能ツールを制限 |
| `argument-hint` | String | 引数のヒント表示 |
| `disable-model-invocation` | Boolean | true でモデル呼び出し無効化 |

---

## model フィールド

commands ではフルモデル ID を指定：

| モデル | ID | 用途 |
|--------|-----|------|
| Haiku 4.5 | `claude-haiku-4-5-20251001` | 高速・定型タスク向け（推奨） |
| Opus 4.5 | `claude-opus-4-5-20251101` | 高精度・複雑なタスク向け |

**注意**: Sonnet は現在の Claude Code では推奨されません。

---

## 変数

| 変数 | 説明 | 例 |
|------|------|-----|
| `$ARGUMENTS` | 引数全体 | `fix bug` |
| `$1` | 第1引数 | `fix` |
| `$2` | 第2引数 | `bug` |
| `$3`, `$4`, ... | 第3引数以降 | |

### 使用例

```markdown
# 単一引数
コミットメッセージ: $ARGUMENTS

# 複数引数
PR #$1 をレビュー（優先度: $2）
```

---

## コマンド呼び出し

```
/plugin-name:command-name [arguments]
```

例:
- `/git-actions:commit-push "fix: bug修正"`
- `/plugin-generator:create my-plugin`

---

## 実装例

### 基本的なコマンド

```markdown
---
description: ファイルを検索する
---

# Search

指定されたパターンでファイルを検索します。

引数: $ARGUMENTS

1. パターンを解析
2. Glob で検索を実行
3. 結果を報告
```

### model 指定付きコマンド

```markdown
---
description: コードをレビューする
model: claude-haiku-4-5-20251001
allowed-tools: Read, Glob, Grep
---

# Code Review

指定されたファイルのコードをレビューします。

対象: $ARGUMENTS

1. ファイルを読み込む
2. コード品質をチェック
3. 改善点を報告
```

### 動的コンテキスト埋め込み

```markdown
---
description: Git コミットを作成する
model: claude-haiku-4-5-20251001
---

# Git Commit

現在の状態:
- Status: !`git status`
- Diff: !`git diff HEAD`

コミットメッセージ: $ARGUMENTS
```

**構文:**
- `!`バッククォート`command`バッククォート: Bash コマンド実行結果を埋め込み
- `@/path/to/file`: ファイル内容を埋め込み

---

## バリデーションルール

| ルール | 重要度 |
|--------|--------|
| フロントマターに `description` 必須 | エラー |
| ファイル名は kebab-case | 推奨 |
| model はフルモデル ID | 必須（指定時） |

## Examples

### コマンド作成の相談

```
Q: 新しいコマンドを作りたい
A: commands/{name}.md を作成し、フロントマターに description を必ず含めてください。
   $ARGUMENTS で引数を受け取れます。model を指定する場合はフルモデル ID を使用してください。
```

### model 指定の相談

```
Q: コマンドで使うモデルを軽量にしたい
A: フロントマターに model: claude-haiku-4-5-20251001 を追加してください。
   定型タスクには Haiku 4.5 が推奨です。
```
