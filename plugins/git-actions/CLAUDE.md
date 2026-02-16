# git-actions プラグイン

Claude Code 用の Git ワークフロー管理プラグイン。

## 概要

commit、push、merge 操作を Claude Code の規則に準拠した形で実行するためのプラグイン。
**スキルに全ての知識を集約**し、コマンドはスキルを参照する設計。

## ディレクトリ構造

```
git-actions/
├── .claude-plugin/
│   └── plugin.json           # プラグインメタデータ
├── commands/
│   ├── commit-push.md        # コミット & プッシュコマンド
│   ├── merge-to-main.md      # main へマージ & プッシュコマンド
│   └── resolve-conflicts.md  # コンフリクト解消コマンド
├── hooks/
│   └── hooks.json            # フック定義（現在は空）
├── skills/
│   ├── commit/SKILL.md       # git-commit スキル
│   ├── push/SKILL.md         # git-push スキル
│   ├── merge/SKILL.md        # git-merge スキル
│   ├── resolve-conflicts/SKILL.md  # git-resolve-conflicts スキル
│   └── git-conventions/SKILL.md  # 共通規則スキル
└── CLAUDE.md
```

## コマンド

| コマンド | 説明 | 参照スキル |
|---------|------|-----------|
| `/git-actions:commit-push` | コミット & プッシュ実行 | `git-commit`, `git-push` |
| `/git-actions:merge-to-main` | main へマージ & プッシュ実行 | `git-merge` |
| `/git-actions:resolve-conflicts` | コンフリクト解消支援 | `git-resolve-conflicts` |

## スキル

| スキル名 | ディレクトリ | 役割 |
|----------|-------------|------|
| `git-commit` | skills/commit/ | 状態確認、変更分析、メッセージ生成、実行 |
| `git-push` | skills/push/ | 安全性チェック、プッシュ実行 |
| `git-merge` | skills/merge/ | feature ブランチを main にマージ & プッシュ |
| `git-resolve-conflicts` | skills/resolve-conflicts/ | コンフリクト分析、解消案生成、ユーザー承認後適用 |
| `git-conventions` | skills/git-conventions/ | 安全規則、機密ファイルチェック、禁止事項 |

## アーキテクチャ

```
/git-actions:commit-push
    │
    ├─→ git-commit スキル
    │     ├─→ 状態確認、変更分析
    │     ├─→ コミットメッセージ生成
    │     └─→ git-conventions (共通規則)
    │
    └─→ git-push スキル
          ├─→ 安全性チェック、プッシュ実行
          └─→ git-conventions (共通規則)

/git-actions:merge-to-main
    │
    └─→ git-merge スキル
          ├─→ 事前確認（状態チェック、コンフリクト検出）
          ├─→ main へチェックアウト、pull、マージ、プッシュ
          ├─→ コンフリクト時: git-resolve-conflicts スキルに委譲
          └─→ git-conventions (共通規則)

/git-actions:resolve-conflicts
    │
    └─→ git-resolve-conflicts スキル
          ├─→ コンフリクト検出・分析
          ├─→ 解消案生成・ユーザー確認
          ├─→ 適用・結果報告
          └─→ git-conventions (共通規則)
```

## v1.5.0 の変更

### resolve-conflicts スキル Step 3 強化（履歴ベース分析）
- `context: fork` は意図的に未設定（設計判断）
  - ファイル書き換え（Edit）を伴うアクションスキルのためメインコンテキストで実行が必要
  - merge スキルからの委譲時にコンテキスト断絶を防止
  - AskUserQuestion によるユーザー承認フローを正常に動作させるため
- Step 3 を履歴ベースのコンフリクト分析に全面書き換え
  - 3a: `git merge-base` でブランチ分岐点を特定
  - 3b: 両ブランチの変更履歴を `git log` で並列取得
  - 3c: 時系列・変更種類・意図・依存関係の4観点で分析
  - 3d: Read でコンフリクトマーカーを解析
  - 3e: パターン別解消戦略（追加vs追加、修正vs修正 等）を決定
- Step 5 の要判断グループに解消案提示フォーマットを追加
  - 変更履歴の概要（分岐点、両ブランチのコミット一覧）
  - コンフリクト箇所の詳細（行番号、パターン分類）
  - 判断根拠（時系列と内容に基づく解消理由）
- Examples セクションを履歴ベース分析フローに更新

## v1.4.0 の変更

### コンフリクト解消スキルの追加
- 新スキル: `git-resolve-conflicts` - コンフリクトを分析し解消案を提示
- 新コマンド: `/git-actions:resolve-conflicts` - コンフリクト解消の直接実行
- `git-merge` スキルのセクション4を新スキルへの委譲に変更
- ハイブリッド方式: AI が解消案を自動生成、適用はユーザー承認必須

## v1.3.1 の変更

**コマンドの model 指定削除**:
- commands/commit-push.md: 明示的な `model` 指定を削除
- commands/merge-to-main.md: 明示的な `model` 指定を削除

**理由:**
ユーザーが Claude Code で使用しているモデルをそのまま継承することで、
ユーザーの意図に沿った動作を実現。

## v1.3.0 の変更

### git-conventions スキルの非表示化
`git-conventions` スキルに `context: fork` + `user-invocable: false` を設定。
- 共通規則として他のスキル（git-commit, git-push, git-merge）に自動参照
- スラッシュメニューから非表示で、UI がすっきり
- ユーザーが直接呼び出す必要はない

## 設計方針

### スキル中心設計

- **知識の集約**: 全ての知識はスキルに集約
- **コマンドは薄い**: コマンドはスキルを参照するだけ
- **再利用性**: スキルは他のプラグインやエージェントからも利用可能

### コミットメッセージ原則

**コミットメッセージは書けば書くほど良い。**

必須セクション:
1. タイトル行
2. 背景・動機
3. 実装内容
4. 設計判断の理由
5. 参照情報

### 正しい git の使い方

**すべての git コマンドは作業ディレクトリで直接実行する。**

```bash
# ✅ 正しい
git status
git commit -m "message"

# ❌ 禁止
git -C /path/to/repo status
```

### 安全性

- **`git -C` オプション使用禁止**（作業ディレクトリで直接実行）
- 機密ファイルの自動検出と警告
- main/master/develop への force push は絶対禁止
- force push の明示的確認
- --amend の厳格な使用条件

### 効率性

- 読み取り系コマンドの並列実行
- HEREDOC 形式による複数行コミットメッセージ

## ドキュメント維持規則

**README.md と CLAUDE.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- コマンドの追加・変更・削除
- スキルの追加・変更・削除
- フックの追加・変更・削除
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
