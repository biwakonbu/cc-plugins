---
name: component-add
description: プラグインにコンポーネント（command, skill, agent, hook）を追加する。テンプレートを使用して正しい形式のファイルを生成。Use when adding a command to plugin, adding a skill, adding an agent, adding hooks, or creating new plugin components.
allowed-tools: Bash, Read, Write, Glob
---

# Component Add スキル

プラグインへのコンポーネント追加を提供する。

## Instructions

### 概要

このスキルは既存プラグインにコンポーネントを追加します。
`add-component.sh` スクリプトを使用するか、テンプレートを参照して手動で作成できます。

### 前提条件

- プラグインルートで実行すること（`.claude-plugin/plugin.json` が存在）
- コンポーネント名は kebab-case

### 追加スクリプト実行

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/add-component.sh" <type> <name>
```

type: `command`, `skill`, `agent`, `hook`

### コンポーネント別追加方法

#### Command 追加

```bash
# スクリプト使用
"${CLAUDE_PLUGIN_ROOT}/scripts/add-component.sh" command my-command

# 手動作成
mkdir -p commands
cat > commands/my-command.md << 'EOF'
---
description: コマンドの説明
---

# my-command

処理内容を記述。

引数: $ARGUMENTS
EOF
```

**必須**: フロントマターに `description`

#### Skill 追加

```bash
# スクリプト使用
"${CLAUDE_PLUGIN_ROOT}/scripts/add-component.sh" skill my-skill

# 手動作成
mkdir -p skills/my-skill
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: スキルの説明。Use when ...
allowed-tools: Read, Grep, Glob
---

# my-skill

## Instructions

1. ステップ1
2. ステップ2

## Examples

使用例を記述
EOF
```

**必須**: フロントマターに `name`, `description`
**注意**: plugin.json に `"skills": "./skills/"` が必要

#### Agent 追加

```bash
# スクリプト使用
"${CLAUDE_PLUGIN_ROOT}/scripts/add-component.sh" agent my-agent

# 手動作成
mkdir -p agents
cat > agents/my-agent.md << 'EOF'
---
name: my-agent
description: エージェントの説明。いつ呼ばれるかを明記。
tools: Read, Glob, Grep, Bash
model: sonnet
---

# my-agent エージェント

役割と実行フローを記述。
EOF
```

**必須**: フロントマターに `name`, `description`
**注意**: plugin.json に `"agents": "./agents/"` が必要

#### Hook 追加

```bash
# スクリプト使用
"${CLAUDE_PLUGIN_ROOT}/scripts/add-component.sh" hook init

# 手動作成
mkdir -p hooks
cat > hooks/hooks.json << 'EOF'
{
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": []
  }
}
EOF
```

**注意**: plugin.json に `"hooks": "./hooks/hooks.json"` が必要

### plugin.json 更新

コンポーネント追加後、plugin.json の更新が必要な場合があります:

```json
{
  "name": "my-plugin",
  "commands": "./commands/",
  "skills": "./skills/",      // スキル追加時
  "agents": "./agents/",      // エージェント追加時
  "hooks": "./hooks/hooks.json"  // フック追加時
}
```

### テンプレート参照

テンプレートファイルは以下にあります:

```
${CLAUDE_PLUGIN_ROOT}/templates/
├── command.md.tmpl
├── skill.md.tmpl
├── agent.md.tmpl
└── hooks.json.tmpl
```

## Examples

### コマンド追加

```
Q: search コマンドを追加したい
A: add-component.sh command search を実行し、生成されたファイルを編集するよう案内します。
```

### スキル追加

```
Q: データベース操作のスキルを追加して
A: add-component.sh skill database を実行し、plugin.json への skills パス追加も案内します。
```

### 複数コンポーネント追加

```
Q: コマンドとスキルを両方追加したい
A: それぞれ add-component.sh を実行し、plugin.json の更新を案内します。
```
