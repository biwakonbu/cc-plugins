# plugin-generator

Claude Code プラグインのスキャフォールディングとバリデーションを提供するメタプラグイン。

## インストール

```bash
claude plugin install plugin-generator@cc-plugins
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `/plugin-generator:create` | 新規プラグイン生成 |

## スキル

| スキル | 説明 |
|--------|------|
| `scaffolding` | スキャフォールディングの知識と生成フロー |
| `plugin-spec` | commands, hooks, skills, agents の仕様知識 |
| `plugin-validation` | プラグイン構造の検証 |
| `component-add` | コンポーネント（command, skill, agent, hook）の追加 |

## 使用例

### 新規プラグイン生成

```bash
/plugin-generator:create my-awesome-plugin
```

生成物:
- `plugins/my-awesome-plugin/.claude-plugin/plugin.json`
- `plugins/my-awesome-plugin/CLAUDE.md`
- `plugins/my-awesome-plugin/commands/hello.md`
- marketplace.json への自動登録

### バリデーション

「このプラグインが正しいか確認して」と依頼すると、`plugin-validation` スキルが適用され検証を実行。

### コンポーネント追加

「スキルを追加したい」と依頼すると、`component-add` スキルが適用されテンプレートから生成。

## 対応コンポーネント

| コンポーネント | 説明 |
|--------------|------|
| command | スラッシュコマンド（.md） |
| skill | スキル（SKILL.md） |
| agent | サブエージェント（.md） |
| hook | イベントフック（hooks.json） |

## バリデーション項目

- plugin.json の必須フィールド
- 各コンポーネントのフロントマター
- パス整合性
- JSON 構文

## テスト

```bash
# 全テスト実行
./tests/run-all-tests.sh

# 個別テスト実行
./tests/test-generate.sh      # プラグイン生成テスト
./tests/test-validate.sh      # バリデーションテスト
./tests/test-add-component.sh # コンポーネント追加テスト
```

## ライセンス

MIT
