---
description: 既存プラグインに新しい skill を追加する
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

## ユーザー確認ガイドライン

以下の場面では **AskUserQuestion ツール**を使用してユーザーに確認を求める。

### 必須確認

- 同名ディレクトリが既に存在する場合（上書き/別名/キャンセル）

### 推奨確認

- 名前が引数で未指定の場合
- 追加先プラグインが複数候補ある場合の選択
- 作成する内容の概要確認（description, allowed-tools 等）

引数: $ARGUMENTS
