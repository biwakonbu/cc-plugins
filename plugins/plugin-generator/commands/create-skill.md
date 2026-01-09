---
description: 既存プラグインに新しい skill を追加する
model: claude-haiku-4-5-20251001
argument-hint: [skill-name]
---

# Create Skill

既存プラグインに新しいスキルを追加します。

`skill-creator` エージェントと `skill-spec` スキルを使用して、
正しい形式の skill ファイルを生成します。

## 使用方法

```
/plugin-generator:create-skill [skill-name]
```

## 引数

- `$ARGUMENTS`: スキル名（kebab-case）

## 実行

1. プラグインルートにいることを確認（.claude-plugin/plugin.json 存在）
2. スキル名を検証（kebab-case）
3. `skill-spec` スキルの知識に従って skill を生成
4. `skills/{skill-name}/SKILL.md` を作成
5. plugin.json の更新を案内
6. 次のステップを案内

引数: $ARGUMENTS
