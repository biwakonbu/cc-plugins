# Claude Code v2.1.x 知識更新仕様

## 概要

本ドキュメントは、Claude Code v2.1.3 の新機能および変更点をプロジェクトの CLAUDE.md に反映するための仕様をまとめたものです。

## 対象バージョン

- Claude Code v2.1.0 〜 v2.1.3
- 更新日: 2026年1月10日

## 主要な新機能

### 1. スキルとスラッシュコマンドの統合（v2.1.3）

v2.1.3 以降、`SlashCommand` ツールは `Skill` ツールに統合されました。

**変更点**:
- `/skills/` ディレクトリ内のスキルがスラッシュコマンドメニューに自動表示
- `user-invocable: false` でメニューから非表示に設定可能
- スキルは自動トリガーと明示的呼び出しの両方に対応

### 2. フォークコンテキスト（v2.1.0）

スキル・スラッシュコマンドをサブエージェントとして独立したコンテキストで実行可能。

**フロントマター設定**:
```yaml
---
name: my-skill
context: fork
agent: custom-agent
---
```

### 3. ホットリロード（v2.1.0）

`~/.claude/skills/` または `.claude/skills/` 内のスキルファイルは、変更時に自動的にリロードされます。

### 4. 言語設定（v2.1.0）

応答言語を設定可能。

**settings.json**:
```json
{
  "language": "japanese"
}
```

### 5. フックの拡張

**新イベント**:
- PermissionRequest（v2.0.45+）
- SubagentStart（v2.0.43+）

**フロントマター対応**（v2.1.0+）:
```yaml
---
name: my-agent
hooks:
  PreToolUse:
    - command: "validate.sh"
---
```

**once オプション**（v2.1.0+）:
```json
{
  "type": "command",
  "command": "setup.sh",
  "once": true
}
```

**タイムアウト更新**: 60秒 → 10分（v2.1.2+）

### 6. LSPツール（v2.0.74）

Language Server Protocol によるコード解析機能。

**有効化**:
```bash
export ENABLE_LSP_TOOL=1
```

### 7. Rules フォルダ（v2.0.64）

`.claude/rules/` にパスベースのルールを定義可能。

### 8. 権限設定の拡張

**ワイルドカードパターン**（v2.1.0+）:
```json
{
  "permissions": {
    "allow": ["Bash(npm *)"]
  }
}
```

**エージェントの無効化**（v2.1.0+）:
```json
{
  "permissions": {
    "deny": ["Task(DangerousAgent)"]
  }
}
```

### 9. サブエージェントの新フィールド

- `permissionMode`（v2.0.43+）
- `disallowedTools`（v2.0.30+）
- `hooks`（v2.1.0+）

### 10. その他の機能

- Vim モーション拡張（v2.1.0+）
- 名前付きセッション（v2.0.64+）
- Claude in Chrome（v2.0.72+）
- Plan モード（v2.0.60+）
- バックグラウンドエージェント（v2.0.60+）

## 参照

- [Claude Code 公式ドキュメント](https://code.claude.com/docs/en/)
- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [プロジェクト CLAUDE.md](/Users/biwakonbu/github/cc-plugins/CLAUDE.md)
