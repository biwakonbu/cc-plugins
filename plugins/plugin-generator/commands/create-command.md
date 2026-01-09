---
description: 既存プラグインに新しい command を追加する
model: claude-haiku-4-5-20251001
argument-hint: [command-name]
---

# Create Command

既存プラグインに新しいスラッシュコマンドを追加します。

`command-creator` エージェントと `command-spec` スキルを使用して、
正しい形式の command ファイルを生成します。

## 使用方法

```
/plugin-generator:create-command [command-name]
```

## 引数

- `$ARGUMENTS`: コマンド名（kebab-case）

## 実行

1. プラグインルートにいることを確認（.claude-plugin/plugin.json 存在）
2. コマンド名を検証（kebab-case）
3. `command-spec` スキルの知識に従って command を生成
4. `commands/{command-name}.md` を作成
5. 次のステップを案内

引数: $ARGUMENTS
