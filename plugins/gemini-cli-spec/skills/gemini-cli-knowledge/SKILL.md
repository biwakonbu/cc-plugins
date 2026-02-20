---
name: gemini-cli-knowledge
description: Gemini CLI の仕様と使い方に関する知識を提供。モデル選択、スラッシュコマンド、組み込みツール、拡張機能、フックシステム、サンドボックス、MCP 管理者制御について回答。Use when user asks about Gemini CLI, gemini command, model selection, /model, /settings, /plan, /rewind, google_web_search, web_fetch, run_shell_command, sandbox, hooks, or Gemini extensions. Also use when user says Gemini CLI について, gemini の使い方, モデル選択.
context: fork
---

# Gemini CLI Knowledge

Gemini CLI の仕様と使い方に関する包括的な知識を提供するスキル。

**最新バージョン**: v0.29.0（2026-02-17）

---

## 利用可能なモデル

### 推奨モデル

| モデル | 説明 | 推奨度 |
|--------|------|--------|
| `gemini-3.1-pro-preview` | 最新の推論能力、創造性、コーディング性能 | **最推奨** |

**重要**: 上記以外のモデルは指示されない限り利用価値なし。常に `gemini-3.1-pro-preview` を使用すること。

### モデル変更方法

```bash
# セッション中に変更
/model

# 起動時に指定
gemini --model gemini-3.1-pro-preview
```

**注意**: `/model` コマンドはサブエージェントのモデルを上書きしない。

### Gemini 3 デフォルト化（v0.29.0）

v0.29.0 以降、Gemini 3 がデフォルトモデルとなった。プレビュー機能の有効化は不要。

---

## スラッシュコマンド一覧

### 会話管理

| コマンド | 説明 |
|----------|------|
| `/chat save <tag>` | 現在の会話履歴をタグ付きで保存 |
| `/chat resume <tag>` | 保存した会話を再開 |
| `/chat list` | 保存済みタグの一覧表示 |
| `/compress` | チャット文脈全体を要約に置き換えてトークン節約 |

### 計画・ナビゲーション

| コマンド | 説明 | バージョン |
|----------|------|-----------|
| `/plan` | プランモード。実装前に計画を策定 | v0.29.0+ |
| `/rewind` | 会話を任意のポイントまで巻き戻し | v0.26.0+ |
| `/prompt-suggest` | 次のプロンプトを提案 | v0.28.0+ |

### 表示・設定

| コマンド | 説明 |
|----------|------|
| `/clear` | ターミナル画面をクリア（Ctrl+L でも可） |
| `/settings` | 設定エディタを開く |
| `/theme` | ビジュアルテーマを変更 |
| `/model` | Gemini モデルを選択 |

### ツール・機能

| コマンド | 説明 |
|----------|------|
| `/tools` | 利用可能なツールのリスト表示 |
| `/mcp` | Model Context Protocol サーバーを管理 |
| `/memory` | AI の教示的文脈を管理（GEMINI.md から読み込み） |
| `/extensions` | アクティブな拡張機能を表示 |

### その他

| コマンド | 説明 |
|----------|------|
| `/bug <説明>` | GitHub に問題を報告 |
| `/help` | ヘルプ情報を表示 |
| `/quit` | Gemini CLI を終了 |

---

## 組み込みツール

### ファイルシステムツール

| ツール | 別名 | 説明 |
|--------|------|------|
| `list_directory` | ReadFolder | ディレクトリ内のファイル一覧表示。glob パターン対応、.gitignore 尊重オプション |
| `read_file` | ReadFile | テキスト、画像（PNG, JPG, GIF）、オーディオ、PDF 読み込み。行範囲指定可能 |
| `write_file` | WriteFile | ファイル書き込み。存在しない場合は作成、親ディレクトリも自動生成 |
| `glob` | FindFiles | glob パターンでファイル検索。修正時刻でソート |
| `search_file_content` | SearchText | 正規表現でファイル内検索。行番号付きで結果返却 |
| `replace` | Edit | ファイル内テキスト置換。前後3行以上のコンテキスト必要 |

### シェルツール

**`run_shell_command`**

シェルコマンドを実行するツール。

| プラットフォーム | シェル |
|------------------|--------|
| Windows | PowerShell |
| その他 | bash |

**引数:**
- `command` (必須): 実行するシェルコマンド
- `description` (オプション): コマンドの説明
- `directory` (オプション): 実行ディレクトリ

**返却値:**
- 標準出力・標準エラー出力
- 終了コード
- バックグラウンドプロセスの PID

**対話モード有効化:**
```
settings > tools.shell.enableInteractiveShell: true
```

### Web ツール

**`web_fetch`**

URL からコンテンツを取得。

- 最大 20 URL を 1 回のプロンプトで処理可能
- 要約、比較、情報抽出に対応
- Gemini API アクセス不可時はローカルからフォールバック取得

**`google_web_search`**

Google Search 経由で Web 検索を実行。

- ソース付きの要約を返却
- 生の検索結果リストではなく処理された要約

**使用例:**
```
google_web_search(query="AI 最新ニュース 2026")
```

### メモリツール

**`save_memory`**

セッション間で情報を保存・回想。

- 保存先: `~/.gemini/GEMINI.md`
- 簡潔で重要なファクト用に設計
- 大量データや会話履歴の保存には不向き

**使用例:**
```
save_memory(fact="My preferred programming language is Python.")
```

### タスク管理ツール

**`write_todos`**

複雑なタスクを管理するためのツール。

---

## CLI フラグ

| フラグ | 説明 |
|--------|------|
| `--yolo` | ツール実行の許可プロンプトをスキップ（自動実行） |
| `--model <model>` | 起動時に使用モデルを指定 |
| `-s`, `--sandbox` | サンドボックスモードを指定 |

**使用例:**
```bash
# 許可プロンプトなしで実行
gemini --yolo "ファイル一覧を表示して"

# モデル指定で起動
gemini --model gemini-3.1-pro-preview

# サンドボックスモードで起動
gemini -s docker
```

---

## フックシステム（v0.26.0+）

### 概要

Gemini CLI のライフサイクル全体で自動実行されるユーザー定義シェルコマンド。LLM に依存せず確定的な制御を提供。

### イベント

| イベント | トリガー |
|---------|---------|
| PreToolUse | ツール実行前 |
| PostToolUse | ツール実行成功後 |

### 設定方法

**settings.json で設定（3つのレベル）:**

| レベル | ファイル | 優先度 |
|--------|---------|--------|
| システム | `/etc/gemini/settings.json` | 最高 |
| ユーザー | `~/.gemini/settings.json` | 中 |
| プロジェクト | `.gemini/settings.json` | 最低 |

**設定例:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "run_shell_command",
        "hooks": [
          {
            "type": "command",
            "command": "validate-command.sh"
          }
        ]
      }
    ]
  }
}
```

### フック変更時の安全対策

- フック設定の変更時は警告が表示される
- ユーザーの承認が必要（セキュリティ保護）
- 拡張機能内にバンドルされたフックも同様

---

## サンドボックス機能

### macOS Seatbelt（sandbox-exec）

- Apple Seatbelt でプロセスをラップ
- 読み取り専用ジェイルで実行
- ワークスペースと一時ディレクトリのみ書き込み可能
- ネットワークは完全ブロック

### Docker / Podman

```bash
# Docker サンドボックスで起動
gemini -s docker

# Podman サンドボックスで起動
gemini -s podman
```

- コンテナ内でツールを実行
- ホストファイルシステムから隔離
- ネットワークアクセス制限

### ポリシーエンジン（実験的）

- カスタムポリシーファイルでサンドボックスの動作を定義
- ツールごとのアクセス制御
- ファイルパス・ネットワークの許可リスト

### サンドボックス設定方法

```bash
# CLI フラグ
gemini -s docker
gemini --sandbox seatbelt

# 環境変数
export GEMINI_SANDBOX=docker

# settings.json
{
  "sandbox": {
    "type": "docker"
  }
}
```

---

## MCP 管理者制御（v0.29.0）

### 許可リスト定義

システム設定で許可する MCP サーバーを定義可能:

```json
{
  "mcp": {
    "allowedServers": ["server1", "server2"],
    "toolFilters": {
      "server1": {
        "allow": ["tool1", "tool2"],
        "deny": ["dangerous_tool"]
      }
    }
  }
}
```

### ツールフィルタリング

- サーバーごとに許可・拒否するツールを指定
- システム設定が最優先（ユーザー・プロジェクト設定より上位）

---

## 拡張機能システム

### 概要

Gemini CLI 拡張機能は、プロンプト、MCP サーバー、カスタムコマンドを使いやすい形式にパッケージ化するツール。

### 拡張機能構造

```
my-extension/
├── gemini-extension.json    # マニフェスト
├── commands/                # カスタムコマンド（TOML 形式）
│   └── my-command.toml
├── hooks/
│   └── hooks.json           # フック定義
└── prompts/                 # プロンプトテンプレート
```

### カスタムコマンド

`commands/` ディレクトリに TOML ファイルを配置。

例: `gcp` 拡張機能
- `/deploy` コマンド
- `/gcs:sync` コマンド

### フック

`hooks/hooks.json` で定義。特定のライフサイクルイベントで Gemini CLI の動作をインターセプト・カスタマイズ可能。

### MCP サーバー統合

`gemini-extension.json` の `mcpServers` マップで設定。起動時に自動読み込み。

**優先度**: `settings.json` > 拡張機能設定

### 変数置換

| 変数 | 説明 |
|------|------|
| `${extensionPath}` | 拡張機能のルートディレクトリ |
| `${workspacePath}` | 現在のワークスペースパス |

### 拡張機能管理コマンド

```bash
# インストール
gemini extensions install <name>

# アンインストール
gemini extensions uninstall <name>

# 有効化/無効化
gemini extensions enable <name>
gemini extensions disable <name>
```

### 拡張機能マーケットプレイス（v0.29.0）

- 探索 UI でインストール可能な拡張機能を検索
- レジストリクライアントで公開・配布

```bash
# マーケットプレイスを探索
gemini extensions explore

# マーケットプレイスからインストール
gemini extensions install <publisher>/<name>
```

---

## メモリシステム（GEMINI.md）

### 概要

`~/.gemini/GEMINI.md` ファイルで AI の教示的文脈を管理。

### 用途

- ユーザー設定の記憶
- プロジェクト情報の保存
- よく使うパターンの定義

### 管理方法

```
# CLI から管理
/memory

# 手動編集も可能
vim ~/.gemini/GEMINI.md
```

---

## セキュリティ機能

### ツール実行確認

- ファイル修正やコマンド実行時に確認プロンプト表示
- `--yolo` フラグでスキップ可能

### サンドボックス制限

- すべてのツールはサンドボックス制限の対象
- `rootDirectory` 内でのみ動作

### コマンド制限

`tools.core` と `tools.exclude` で許可・ブロックするコマンドを指定。

**注意**: 制限機能はセキュリティメカニズムではなく、信頼できないコードの実行には不適切。

---

## 破壊的変更

### Node.js 20 必須（v0.7.0）

- Node.js 18 以下はサポート終了
- Node.js 20 以上が必須

### settings.json 形式更新

- 一部設定キーの名前変更
- 旧形式は非推奨だが後方互換性あり

### 一部 CLI 引数の非推奨化

- 旧フラグは将来のバージョンで削除予定
- 警告メッセージが表示される

### 非対話モードから ask_user 削除（v0.29.0）

- 非対話モード（`-q`）では `ask_user` ツールが利用不可に
- CI/CD パイプラインでの意図しない停止を防止

---

## インストール方法

```bash
# npm（Node.js 20+ 必須）
npm install -g @google/gemini-cli

# Homebrew
brew install gemini-cli
```

---

## よくある質問

### Q: モデルを変更するには？

```
/model
```
または起動時に `--model gemini-3.1-pro-preview` フラグ。

### Q: 推奨モデルは？

`gemini-3.1-pro-preview` を使用すること。他のモデルは利用価値なし。

### Q: 会話を保存するには？

```
/chat save my-session
```

### Q: 保存した会話を再開するには？

```
/chat resume my-session
```

### Q: Web 検索を行うには？

プロンプトで検索を依頼するだけ。Gemini が自動的に `google_web_search` を使用。

### Q: 許可プロンプトをスキップするには？

```bash
gemini --yolo "コマンド"
```

### Q: サンドボックスを使うには？

```bash
gemini -s docker
```

### Q: 会話を巻き戻すには？

```
/rewind
```

### Q: プランモードを使うには？

```
/plan
```
