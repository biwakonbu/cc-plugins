---
name: scaffolding
description: Claude Code プラグインのスキャフォールディング。新規プラグインのディレクトリ構造生成、テンプレート展開、marketplace.json への登録を実行。Use when user wants to create a new plugin, scaffold a plugin, or generate plugin structure.
allowed-tools: Bash, Read, Write, Glob
---

# Scaffolding スキル

新規プラグインの生成ワークフローを提供する。

## Instructions

### 概要

このスキルはプラグインスキャフォールディングの全ワークフローを提供します。
`generate-plugin.sh` スクリプトを使用してテンプレートからファイルを生成します。

### 入力解析

引数からプラグイン名を抽出:
- 第1引数: プラグイン名（必須、kebab-case）

### 生成フロー

1. **事前チェック**
   - プラグイン名が kebab-case であること
   - 同名のプラグインが存在しないこと
   - マーケットプレイスルートで実行されていること

2. **ディレクトリ作成**
   ```
   plugins/{plugin-name}/
   ├── .claude-plugin/
   └── commands/
   ```

3. **テンプレート展開**
   - `{{PLUGIN_NAME}}`: プラグイン名
   - `{{AUTHOR_NAME}}`: 作者名（marketplace.json から取得）
   - `{{DATE}}`: 生成日
   - `{{VERSION}}`: 初期バージョン（0.1.0）

4. **生成ファイル**
   - `.claude-plugin/plugin.json`: プラグインメタデータ
   - `CLAUDE.md`: プラグイン説明
   - `commands/hello.md`: サンプルコマンド

5. **marketplace.json 更新**
   - jq がある場合は自動追加
   - ない場合は手動追加を案内

### 実行方法

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/generate-plugin.sh" <plugin-name>
```

### 生成後の案内

生成完了後、以下を案内:
1. CLAUDE.md を編集してプラグインの説明を追加
2. plugin.json の description を更新
3. marketplace.json の description を更新
4. コマンド/スキル/エージェントを必要に応じて追加
5. テスト方法: `claude --plugin-dir ./plugins/{plugin-name}`

## Examples

### 基本的なプラグイン生成

```
/plugin-generator:create my-tool

生成結果:
plugins/my-tool/
├── .claude-plugin/plugin.json
├── CLAUDE.md
└── commands/hello.md

marketplace.json に登録済み
```

### エラーケース

```
/plugin-generator:create MyPlugin
→ Error: プラグイン名は kebab-case で指定してください

/plugin-generator:create agbullet
→ Error: プラグイン 'agbullet' は既に存在します
```
