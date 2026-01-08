# plugin-generator プラグイン

Claude Code プラグインのスキャフォールディングとバリデーションを提供するメタプラグイン。

## 概要

新しいプラグインの作成を支援し、既存プラグインの構造検証を行う。
テンプレート的な部分はシェルスクリプトで効率化し、各コンポーネントの知識はスキルで提供。

## コマンド

| コマンド | 説明 | 例 |
|---------|------|-----|
| `/plugin-generator:create` | 新規プラグイン生成 | `/plugin-generator:create my-plugin` |

## スキル

| スキル | 説明 |
|--------|------|
| `scaffolding` | スキャフォールディングの知識と生成フロー |
| `plugin-spec` | commands, hooks, skills, agents の仕様知識 |
| `plugin-validation` | プラグイン構造の検証 |
| `component-add` | コンポーネント（command, skill, agent, hook）の追加 |

## ディレクトリ構造

```
plugin-generator/
├── .claude-plugin/
│   └── plugin.json               # プラグインメタデータ
├── CLAUDE.md                     # このファイル
├── commands/
│   └── create.md                 # プラグイン生成コマンド
├── skills/
│   ├── scaffolding/SKILL.md      # スキャフォールディング知識
│   ├── plugin-spec/SKILL.md      # プラグイン仕様知識
│   ├── validation/SKILL.md       # バリデーション
│   └── component-add/SKILL.md    # コンポーネント追加
├── templates/                    # テンプレートファイル
│   ├── base/                     # 共通テンプレート
│   │   ├── CLAUDE.md.tmpl
│   │   ├── hello.md.tmpl
│   │   └── plugin.json.tmpl
│   ├── command.md.tmpl           # コマンドテンプレート
│   ├── skill.md.tmpl             # スキルテンプレート
│   ├── agent.md.tmpl             # エージェントテンプレート
│   └── hooks.json.tmpl           # フックテンプレート
├── scripts/
│   ├── generate-plugin.sh        # プラグイン生成
│   ├── validate-plugin.sh        # バリデーション
│   └── add-component.sh          # コンポーネント追加
└── tests/                        # テストスクリプト
    ├── run-all-tests.sh
    ├── test-generate.sh
    ├── test-validate.sh
    └── test-add-component.sh
```

## 設計方針

### コマンドは最小限

- スラッシュコマンドは `/plugin-generator:create` のみ
- バリデーションやコンポーネント追加はスキルとして提供
- Claude が文脈に応じて適切なスキルを自動適用

### テンプレート駆動

- 繰り返し生成される部分はテンプレートファイルに集約
- 変数置換でプラグイン名や作者名を展開
- シェルスクリプトで効率的に処理

### 知識集約

- プラグイン仕様の知識は `plugin-spec` スキルに集約
- commands, hooks, skills, agents の正しい形式を熟知
- 実装支援とバリデーションの両方で活用

## 使用例

### 新規プラグイン生成

```
/plugin-generator:create my-awesome-plugin
```

生成物:
- `plugins/my-awesome-plugin/.claude-plugin/plugin.json`
- `plugins/my-awesome-plugin/CLAUDE.md`
- `plugins/my-awesome-plugin/commands/hello.md`
- marketplace.json への自動登録

### バリデーション（スキルによる自動適用）

「このプラグインが正しいか確認して」と依頼すると、`plugin-validation` スキルが適用され検証を実行。

### コンポーネント追加（スキルによる自動適用）

「スキルを追加したい」と依頼すると、`component-add` スキルが適用されテンプレートから生成。

## テスト

```bash
# 全テスト実行
./tests/run-all-tests.sh

# 個別テスト実行
./tests/test-generate.sh    # プラグイン生成テスト
./tests/test-validate.sh    # バリデーションテスト
./tests/test-add-component.sh  # コンポーネント追加テスト
```

### テスト項目

| テスト | 内容 |
|--------|------|
| test-generate | プラグイン生成の正常系・エラー系（重複、不正な名前、引数なし） |
| test-validate | バリデーションの正常系・エラー系・警告系（10項目） |
| test-add-component | コンポーネント追加の正常系・エラー系（8項目） |

## ドキュメント維持規則

**README.md と CLAUDE.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- コマンドの追加・変更・削除
- スキルの追加・変更・削除
- テンプレートの追加・変更・削除
- plugin.json の変更（バージョン含む）
- 設計方針や動作の変更

### README.md の役割

- **対象**: ユーザー（プラグイン利用者）
- **内容**: インストール方法、使い方、機能一覧、使用例

### CLAUDE.md の役割

- **対象**: AI（Claude）と開発者
- **内容**: 設計方針、アーキテクチャ、内部構造、開発ルール

### 同期チェック

プラグイン変更時、フックにより README.md と CLAUDE.md の整合性がチェックされる。
不整合がある場合は警告が表示される。
