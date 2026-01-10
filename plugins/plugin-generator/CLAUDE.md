# plugin-generator プラグイン

Claude Code プラグインのスキャフォールディングとバリデーションを提供するメタプラグイン。

## 概要

新しいプラグインの作成を支援し、既存プラグインの構造検証を行う。
各コンポーネント（command, skill, agent）は個別のスキル・エージェント・コマンドとして分離され、
それらを統合した `plugin-spec` スキルが全体の仕様知識を提供。

## コマンド

| コマンド | 説明 | 例 |
|---------|------|-----|
| `/plugin-generator:create` | 新規プラグイン生成 | `/plugin-generator:create my-plugin` |
| `/plugin-generator:create-command` | コマンド追加 | `/plugin-generator:create-command my-cmd` |
| `/plugin-generator:create-skill` | スキル追加 | `/plugin-generator:create-skill my-skill` |
| `/plugin-generator:create-agent` | エージェント追加 | `/plugin-generator:create-agent my-agent` |

## スキル

| スキル | 説明 |
|--------|------|
| `plugin-spec` | 全仕様の統合。plugin.json と各コンポーネントの概要を提供 |
| `command-spec` | command の詳細仕様（フロントマター、変数、model 指定） |
| `skill-spec` | skill の詳細仕様（ディレクトリ構造、description ベストプラクティス） |
| `agent-spec` | agent の詳細仕様（tools, model, skills フィールド） |
| `scaffolding` | スキャフォールディングの知識と生成フロー |
| `validation` | プラグイン構造の検証 |

## エージェント

| エージェント | 説明 |
|-------------|------|
| `command-creator` | command の作成・メンテナンス。`command-spec` スキルを使用 |
| `skill-creator` | skill の作成・メンテナンス。`skill-spec` スキルを使用 |
| `agent-creator` | agent の作成・メンテナンス。`agent-spec` スキルを使用 |

**自動起動**: 各エージェントは description に `Use when creating, updating, modifying, or maintaining ...` を含むため、ユーザーの要求にマッチした場合に自動的に呼び出されます。

**更新モード**: 既存コンポーネントが存在する場合、差分適用方式で更新します（他の設定を維持しつつ要求部分のみ変更）。

## ディレクトリ構造

```
plugin-generator/
├── .claude-plugin/
│   └── plugin.json               # プラグインメタデータ (v1.2.0)
├── CLAUDE.md                     # このファイル
├── commands/
│   ├── create.md                 # 新規プラグイン生成
│   ├── create-command.md         # コマンド追加
│   ├── create-skill.md           # スキル追加
│   └── create-agent.md           # エージェント追加
├── skills/
│   ├── plugin-spec/SKILL.md      # 統合仕様（個別スキルを参照）
│   ├── command-spec/SKILL.md     # command 仕様
│   ├── skill-spec/SKILL.md       # skill 仕様
│   ├── agent-spec/SKILL.md       # agent 仕様
│   ├── scaffolding/SKILL.md      # スキャフォールディング
│   └── validation/SKILL.md       # バリデーション
├── agents/
│   ├── command-creator.md        # command 作成エージェント
│   ├── skill-creator.md          # skill 作成エージェント
│   └── agent-creator.md          # agent 作成エージェント
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
│   └── validate-plugin.sh        # バリデーション
└── tests/                        # テストスクリプト
    ├── run-all-tests.sh
    ├── test-generate.sh
    └── test-validate.sh
```

## 設計方針

### コンポーネント分離アーキテクチャ

各コンポーネントタイプ（command, skill, agent）に対して:

1. **仕様スキル** (`*-spec`): 正しい形式の知識を提供
2. **作成・メンテナンスエージェント** (`*-creator`): 仕様スキルを使用してファイル生成・更新
3. **作成コマンド** (`create-*`): ユーザーインターフェース

この分離により:
- 単一責任の原則を遵守
- 再利用性の向上
- テスト容易性の改善

### model 指定の規則

| コンポーネント | model 指定 | 形式 |
|--------------|-----------|------|
| commands | 可能 | フル ID（`claude-haiku-4-5-20251001`） |
| skills | **不可** | - |
| agents | 可能 | 短縮名（`haiku`, `opus`, `inherit`） |

**注意**: Sonnet は現在の Claude Code では推奨されません。

### テンプレート駆動

- 繰り返し生成される部分はテンプレートファイルに集約
- 変数置換でプラグイン名や作者名を展開
- シェルスクリプトで効率的に処理

## 使用例

### 新規プラグイン生成

```
/plugin-generator:create my-awesome-plugin
```

### コンポーネント追加

```
/plugin-generator:create-command my-command
/plugin-generator:create-skill my-skill
/plugin-generator:create-agent my-agent
```

### バリデーション（スキルによる自動適用）

「このプラグインが正しいか確認して」と依頼すると、`validation` スキルが適用され検証を実行。

## テスト

```bash
# 全テスト実行
./tests/run-all-tests.sh

# 個別テスト実行
./tests/test-generate.sh    # プラグイン生成テスト
./tests/test-validate.sh    # バリデーションテスト
```

## ドキュメント維持規則

**README.md と CLAUDE.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- コマンドの追加・変更・削除
- スキルの追加・変更・削除
- エージェントの追加・変更・削除
- テンプレートの追加・変更・削除
- plugin.json の変更（バージョン含む）
- 設計方針や動作の変更

### README.md の役割

- **対象**: ユーザー（プラグイン利用者）
- **内容**: インストール方法、使い方、機能一覧、使用例

### CLAUDE.md の役割

- **対象**: AI（Claude）と開発者
- **内容**: 設計方針、アーキテクチャ、内部構造、開発ルール

## コマンド実装ガイドライン

### ユーザー確認（AskUserQuestion ツール使用）

各コマンドでは以下の場面でユーザーに確認を求める:

**create コマンド:**
- 同名プラグインが既に存在する場合（上書き/別名/キャンセル）
- プラグイン名が引数で未指定の場合
- 含めるコンポーネント（commands/skills/agents）の選択
- 初期設定（author, license など）の確認

**create-command コマンド:**
- コマンド名が既に存在する場合（上書き/別名/キャンセル）
- 引数や allowed-tools の設定確認

**create-skill コマンド:**
- スキル名が既に存在する場合（上書き/別名/キャンセル）
- description の確認（description は自動発動の鍵となるため重要）

**create-agent コマンド:**
- エージェント名が既に存在する場合（上書き/別名/キャンセル）
- tools/model/skills フィールドの設定確認
