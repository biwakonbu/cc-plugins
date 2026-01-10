---
description: 既存プラグインに新しい agent を追加する
model: claude-haiku-4-5-20251001
argument-hint: [agent-name]
---

# Create Agent

既存プラグインに新しいサブエージェントを追加します。

`agent-creator` エージェントと `agent-spec` スキルを使用して、
正しい形式の agent ファイルを生成します。

## 使用方法

```
/plugin-generator:create-agent [agent-name]
```

## 引数

- `$ARGUMENTS`: エージェント名（kebab-case）

## 実行

1. プラグインルートにいることを確認（.claude-plugin/plugin.json 存在）
2. エージェント名を検証（kebab-case）
3. `agent-spec` スキルの知識に従って agent を生成
4. `agents/{agent-name}.md` を作成
5. plugin.json の更新を案内
6. 次のステップを案内

## ユーザー確認ガイドライン

以下の場面では **AskUserQuestion ツール**を使用してユーザーに確認を求める。

### 必須確認

- 同名ファイルが既に存在する場合（上書き/別名/キャンセル）

### 推奨確認

- 名前が引数で未指定の場合
- 追加先プラグインが複数候補ある場合の選択
- 作成する内容の概要確認（description, tools, model 等）

引数: $ARGUMENTS
