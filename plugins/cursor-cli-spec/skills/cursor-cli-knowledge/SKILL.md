---
name: cursor-cli-knowledge
description: Cursor IDE および cursor-agent CLI の仕様と使い方に関する知識を提供。エディタ CLI、ターミナルエージェント、モデル選択、@ シンボル、MCP サーバー連携、Composer、設定方法について回答。Use when user asks about Cursor, cursor command, cursor-agent, terminal agent, @ symbols, model selection, MCP servers, Composer, or Cursor settings. Also use when user says Cursor について, cursor の使い方, cursor-agent, ターミナルエージェント.
context: fork
---

# Cursor CLI 仕様知識

Cursor IDE および cursor-agent CLI の公式仕様と使用方法のリファレンス。

**公式ドキュメント**: https://docs.cursor.com/

---

## 概要

Cursor は VS Code をベースにした AI 統合コードエディタで、2つの CLI ツールを提供する:

| CLI | 説明 |
|-----|------|
| `cursor` | VS Code 互換のエディタ CLI。ファイルを開く、diff 表示、拡張機能管理など |
| `cursor-agent` | ターミナルから AI エージェントを直接操作する CLI |

---

## インストール

### cursor-agent CLI

```bash
curl https://cursor.com/install -fsS | bash
```

### Shell コマンドのパス設定

Cursor エディタ内で:
1. コマンドパレットを開く（`Cmd+Shift+P` / `Ctrl+Shift+P`）
2. `Shell Command: Install 'cursor' command in PATH` を実行

**参考**: https://docs.cursor.com/cli/overview

---

## cursor コマンド（エディタ CLI）

VS Code 互換の CLI オプションを提供。

### 主要オプション

| オプション | 説明 | 例 |
|-----------|------|-----|
| `cursor .` | 現在のディレクトリを開く | |
| `cursor <path>` | ファイル/ディレクトリを開く | `cursor src/main.ts` |
| `-n`, `--new-window` | 新しいウィンドウで開く | `cursor -n project/` |
| `-r`, `--reuse-window` | 最後のウィンドウで開く | `cursor -r file.ts` |
| `-d <file1> <file2>` | 2ファイルの差分を表示 | `cursor -d old.ts new.ts` |
| `-g <file>:<line>` | 指定行でファイルを開く | `cursor -g src/main.ts:42` |
| `-w`, `--wait` | ウィンドウが閉じるまで待機 | |
| `--install-extension <id>` | 拡張機能をインストール | |
| `--list-extensions` | 拡張機能一覧を表示 | |

### Git エディタとして設定

```bash
git config --global core.editor "cursor --wait"
```

---

## cursor-agent コマンド（ターミナル AI エージェント）

ターミナルから Cursor AI を直接操作できる CLI。

**参考**: https://docs.cursor.com/agent/terminal

### 基本コマンド

| コマンド | 説明 |
|---------|------|
| `cursor-agent` | 対話型セッションを開始 |
| `cursor-agent "プロンプト"` | 非対話モードでタスク実行 |
| `cursor-agent login` | 認証 |
| `cursor-agent logout` | ログアウト |
| `cursor-agent status` | 認証状態を確認 |
| `cursor-agent update` | CLI を更新 |
| `cursor-agent ls` | セッション一覧を表示 |
| `cursor-agent resume [chatId]` | セッションを再開 |
| `cursor-agent mcp list` | MCP サーバーとツールを確認 |
| `cursor-agent create-chat` | 新規チャットを作成（ID を返す） |
| `cursor-agent install-shell-integration` | ~/.zshrc にシェル統合をインストール |
| `cursor-agent uninstall-shell-integration` | シェル統合を削除 |
| `cursor-agent agent [prompt...]` | エージェントモードを開始 |

### 利用可能なモデル

`-m` / `--model` オプションで指定可能:

| モデル | 説明 |
|--------|------|
| `gpt-5` | OpenAI GPT-5 |
| `sonnet-4` | Claude Sonnet 4 |
| `sonnet-4-thinking` | Claude Sonnet 4 with Extended Thinking |

例:
```bash
cursor-agent -m gpt-5 "タスク説明"
cursor-agent -m sonnet-4 "別のプロンプト"
cursor-agent -m sonnet-4-thinking "複雑な推論タスク"
```

### オプション

| オプション | 説明 |
|-----------|------|
| `-p`, `--print` | 応答を標準出力に表示（スクリプト用） |
| `-m`, `--model <model>` | AI モデルを指定（gpt-5, sonnet-4, sonnet-4-thinking） |
| `-f`, `--force` | 確認なしでコマンド実行 |
| `--output-format <format>` | 出力形式: `text`, `json`, `stream-json` |
| `-a`, `--api-key <key>` | API キーを直接指定 |
| `-H`, `--header <header>` | カスタムヘッダーを追加（複数回使用可） |
| `--stream-partial-output` | 部分出力をストリーミング |
| `-c`, `--cloud` | クラウドモード（Composer picker 起動） |
| `--sandbox <mode>` | サンドボックスモード: `enabled`, `disabled` |
| `--approve-mcps` | MCP サーバーを自動承認（--print モード用） |
| `--browser` | ブラウザ自動化サポートを有効化 |
| `--workspace <path>` | ワークスペースディレクトリを指定 |

### インタラクティブモード内コマンド

| コマンド | 説明 |
|---------|------|
| `@` | ファイル/フォルダをコンテキストに追加 |
| `/model` | 使用モデルを変更 |
| `/auto run` | コマンド自動実行モードの切替 |
| `/new chat` | 新規チャットを開始 |

---

## AI 機能

### Cursor Composer

マルチファイル編集機能。複数ファイルにまたがる変更を一度に生成・適用できる。

- **マルチファイル編集**: 複数ファイルの同時変更
- **自律的ファイル操作**: ファイルの作成/削除/移動
- **チェックポイント**: 変更適用前の確認と復元

### Inline Edit（Ctrl+K / Cmd+K）

選択したコード範囲に対して AI に直接変更を指示。

- コード選択後に `Ctrl+K`（Windows/Linux）または `Cmd+K`（macOS）
- 自然言語で変更内容を指示
- インラインで差分をプレビュー

### エージェントモード

複雑なタスクを自律的に実行するモード。

- ファイルの読み書き
- コマンドの実行
- `.cursor/rules` に従った動作

### ターミナル AI 支援

- 自然言語からコマンドを提案
- `@` シンボルでファイル/コードをコンテキストに追加

---

## @ シンボル（コンテキスト指定）

AI に追加のコンテキストを提供するためのシンボル。

**参考**: https://docs.cursor.com/context

| シンボル | 説明 |
|---------|------|
| `@Files` | 特定のファイルをコンテキストに含める |
| `@Folders` | フォルダ全体の情報を参照 |
| `@Code` / `@Symbols` | 関数、クラス、変数などのシンボルを参照 |
| `@Docs` | サードパーティライブラリのドキュメントを参照 |
| `@Web` | ウェブ検索を実行 |
| `@Codebase` | プロジェクト全体のコードベースをスキャン |
| `@Git` | コミット履歴や現在の差分を参照 |

### 使用例

```
@Files src/main.ts このファイルをリファクタリングして
@Codebase 認証機能はどこに実装されている？
@Web Next.js 15 の新機能を教えて
```

---

## MCP サーバー連携

Model Context Protocol (MCP) を使用して外部ツールと連携。

**参考**: https://docs.cursor.com/context/model-context-protocol

### 設定方法

1. `Cursor Settings` > `Features` > `MCP` セクション
2. サーバーを追加
3. `stdio`（ローカル）または `sse`（HTTP/HTTPS）で接続

### サポート機能

- ファイルシステム操作
- データベースクエリ（Postgres, Supabase など）
- Google 検索
- GitHub 連携

### CLI コマンド

```bash
cursor-agent mcp list                      # 接続済み MCP サーバーとツールを表示
cursor-agent mcp login <identifier>        # MCP サーバーを認証
cursor-agent mcp list-tools <identifier>   # 特定のサーバーが提供するツール一覧表示
cursor-agent mcp disable <identifier>      # MCP サーバーを無効化
```

### スクリプト実行時の MCP 承認

非対話モード（`--print`）で MCP サーバーを自動的に承認する場合:

```bash
cursor-agent --print --approve-mcps "MCP ツールを使用するタスク"
```

---

## 環境変数

### cursor-agent が使用する環境変数

| 環境変数 | 説明 | 例 |
|---------|------|-----|
| `CURSOR_API_KEY` | Cursor API キーを指定（`--api-key` オプションの代わりに使用） | `export CURSOR_API_KEY=your-key` |
| `NO_OPEN_BROWSER` | 値が `true` または `1` の場合、ブラウザの自動起動を無効化 | `export NO_OPEN_BROWSER=1` |

### 使用例

```bash
# API キーを環境変数で指定
export CURSOR_API_KEY=sk-xxxxx
cursor-agent "タスク実行"

# ブラウザ自動起動を無効化
export NO_OPEN_BROWSER=1
cursor-agent

# 両方を指定
export CURSOR_API_KEY=sk-xxxxx
export NO_OPEN_BROWSER=1
cursor-agent -m gpt-5 "タスク説明"
```

---

## 設定ファイル

### メイン設定ファイルの場所

| OS | パス |
|----|------|
| macOS | `~/.config/cursor/` |
| Linux | `~/.config/cursor/` |
| Windows | `%APPDATA%\Cursor\` |
| ワークスペース | `.vscode/settings.json` |

### Cursor 固有の設定例

```json
{
  "cursor.cpp.enabled": true,
  "cursor.chat.model": "claude-3.5-sonnet",
  "cursor.terminal.useAi": true,
  "cursor.composer.enabled": true
}
```

### プロジェクト固有ファイル

| ファイル/ディレクトリ | 説明 |
|---------------------|------|
| `.cursor/rules` | AI エージェントへのカスタムルール |
| `.cursor/hooks.json` | イベントフック定義 |
| `.cursor/commands/` | カスタムスラッシュコマンド |
| `cli-config.json` | CLI ツールの動作設定 |

### .cursor/rules の例

```
# プロジェクトルール

- TypeScript を使用
- コメントは日本語
- Prettier でフォーマット
- テストは Jest を使用
```

---

## スラッシュコマンド

### 定義方法

Markdown ファイルとして `.cursor/commands/` に保存。

### 保存場所

| 場所 | スコープ |
|------|----------|
| `.cursor/commands/` | プロジェクト単位 |
| `~/.cursor/commands/` | グローバル |

### 例

`.cursor/commands/test.md`:
```markdown
選択したコードのユニットテストを生成してください。
Jest を使用し、エッジケースも含めてください。
```

使用: `/test` でコマンドを実行

---

## よくある質問

### Q: cursor-agent が見つからない

A: インストールスクリプトを実行:
```bash
curl https://cursor.com/install -fsS | bash
```
その後、シェルを再起動するか `source ~/.bashrc` を実行。

### Q: cursor コマンドが PATH にない

A: Cursor エディタで `Shell Command: Install 'cursor' command in PATH` を実行。

### Q: MCP サーバーが接続できない

A: `cursor-agent mcp list` で接続状態を確認。設定が正しいか確認し、サーバーが起動しているかチェック。

### Q: @ シンボルが機能しない

A: ファイルパスが正しいか確認。`@Files` の後にスペースを入れてからファイル名を入力。

### Q: エージェントモードで実行したコマンドを確認したい

A: `cursor-agent ls` でセッション一覧を表示し、`cursor-agent resume [chatId]` で履歴を確認。

### Q: cursor-agent で使用できるモデルは？

A: `cursor-agent -m <model>` で指定。利用可能なモデルは Cursor アカウントのプランによる。

---

## Claude Code との比較

| 機能 | Cursor | Claude Code |
|------|--------|-------------|
| スラッシュコマンド | `.cursor/commands/` | `.claude/commands/` |
| ルール/設定 | `.cursor/rules` | `CLAUDE.md` |
| MCP サポート | あり | あり |
| ターミナル CLI | `cursor-agent` | `claude` |
| コンテキスト指定 | `@` シンボル | `@` シンボル |
| フック | `.cursor/hooks.json` | `.claude/settings.json` |

---

## 参考リンク

- **公式サイト**: https://cursor.com/
- **公式ドキュメント**: https://docs.cursor.com/
- **CLI ドキュメント**: https://docs.cursor.com/cli/overview
- **エージェント/ターミナル**: https://docs.cursor.com/agent/terminal
- **MCP サポート**: https://docs.cursor.com/context/model-context-protocol
- **Changelog**: https://www.cursor.com/changelog
