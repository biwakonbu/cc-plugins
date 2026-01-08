---
description: 新しい Claude Code プラグインを生成する
allowed-tools: Bash, Read, Write, Glob
---

# /plugin-generator:create

新しいプラグインをスキャフォールディングします。

## 使用方法

```
/plugin-generator:create <plugin-name>
```

## 引数

- `$1`: プラグイン名（kebab-case、必須）

## 入力

プラグイン名: $1

## 実行

`scaffolding` スキルに従って、以下を実行してください:

1. **事前チェック**
   - プラグイン名が kebab-case であること
   - 同名プラグインが存在しないこと

2. **生成スクリプト実行**
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/generate-plugin.sh" "$1"
   ```

3. **結果報告**
   - 生成されたファイル一覧
   - 次のステップの案内

## 生成物

```
plugins/{plugin-name}/
├── .claude-plugin/plugin.json
├── CLAUDE.md
└── commands/hello.md
```

## エラーケース

- プラグイン名が空: 使用方法を表示
- kebab-case でない: エラーメッセージを表示
- 既存プラグイン: 既存パスを報告
