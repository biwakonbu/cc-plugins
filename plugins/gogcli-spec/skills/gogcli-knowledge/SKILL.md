---
name: gogcli-knowledge
description: Google Suite CLI (gogcli/gog) の仕様と使い方に関する知識を提供。Gmail、Calendar、Drive、Contacts、Tasks、Sheets、Docs、Chat、Classroom、People、Groups、Keep の操作について回答。Use when user asks about gogcli, gog CLI, Google CLI, Gmail CLI, Google Calendar CLI, Google Drive CLI, or Google Workspace CLI. Also use when user says gogcli について, Google CLI について, gog コマンド, Gmail 操作, カレンダー操作, ドライブ操作.
context: fork
---

# gogcli Knowledge

Google Suite CLI (gogcli/gog) の仕様と使い方に関する包括的な知識を提供するスキル。

## 概要

gogcli は Google のサービス群（Gmail、Calendar、Drive、Contacts、Tasks、Sheets、Docs、Chat、Classroom 等）をターミナルから操作するための CLI ツール。JSON ファースト出力、マルチアカウント対応、最小権限認証を備える。

| 項目 | 内容 |
|------|------|
| 正式名称 | gogcli |
| コマンド名 | `gog` |
| GitHub リポジトリ | https://github.com/steipete/gogcli |
| ホームページ | https://gogcli.sh |
| 開発言語 | Go |
| ライセンス | MIT |
| 作者 | steipete (Peter Steinberger) |

---

## 対応サービス

| サービス | コマンドグループ | 説明 |
|---------|----------------|------|
| Gmail | `gog gmail` | スレッド・メッセージ検索、送信、ラベル、フィルタ、委任、Watch (Pub/Sub)、メール追跡 |
| Calendar | `gog calendar` | イベント CRUD、空き状況、チーム、招待、繰り返し、focus/OOO/working-location |
| Chat | `gog chat` | スペース、メッセージ、スレッド、DM（Workspace のみ） |
| Classroom | `gog classroom` | コース、名簿、課題、提出物、成績、お知らせ（Workspace for Education） |
| Drive | `gog drive` | ファイル一覧・検索・アップロード・ダウンロード、フォルダ、権限、共有ドライブ |
| Docs | `gog docs` | 情報取得、テキスト抽出、作成、コピー、エクスポート |
| Slides | `gog slides` | 情報取得、作成、コピー、エクスポート |
| Sheets | `gog sheets` | 読み書き、フォーマット、作成、エクスポート |
| Contacts | `gog contacts` | 個人連絡先、その他の連絡先、ディレクトリ（Workspace） |
| Tasks | `gog tasks` | タスクリスト管理、タスク CRUD、繰り返し |
| People | `gog people` | プロフィール、検索、リレーション |
| Groups | `gog groups` | グループ一覧、メンバー一覧（Workspace のみ） |
| Keep | `gog keep` | ノート一覧・取得・検索、添付ファイル（Workspace のみ、サービスアカウント必須） |
| Time | `gog time` | ローカル/UTC 時刻表示 |

---

## インストール方法

### Homebrew（推奨）

```bash
brew install steipete/tap/gogcli
```

### ソースからビルド

```bash
git clone https://github.com/steipete/gogcli.git
cd gogcli
make
./bin/gog --help
```

### ヘルプの確認

```bash
gog --help                        # トップレベルコマンド一覧
gog <group> --help                # サブコマンドヘルプ
GOG_HELP=full gog --help          # 全コマンド展開表示
```

---

## 認証設定

gogcli は OAuth2 で Google API にアクセスする。

### OAuth2 クイックスタート

```bash
# 1. Google Cloud Console で OAuth2 クライアント資格情報を作成
#    - Desktop app タイプで作成
#    - JSON ファイルをダウンロード

# 2. 資格情報を保存
gog auth credentials ~/Downloads/client_secret_....json

# 3. アカウントを認証（ブラウザが開く）
gog auth add you@gmail.com

# 4. テスト
export GOG_ACCOUNT=you@gmail.com
gog gmail labels list
```

### マルチアカウント

```bash
# 複数アカウントの認証
gog auth add personal@gmail.com
gog auth add work@company.com

# アカウント一覧
gog auth list
gog auth list --check             # トークン有効性確認

# アカウント切り替え
gog gmail search 'is:unread' --account personal@gmail.com
gog gmail search 'is:unread' --account work@company.com

# デフォルトアカウント設定
export GOG_ACCOUNT=work@company.com

# エイリアス設定
gog auth alias set work work@company.com
gog gmail search 'is:unread' --account work
```

### マルチ OAuth クライアント

```bash
# 別のクライアントで資格情報を保存
gog --client work auth credentials ~/Downloads/work.json

# ドメインマッピング（自動選択）
gog --client work auth credentials ~/Downloads/work.json --domain example.com

# クライアント一覧
gog auth credentials list
```

クライアント選択順序:
1. `--client` / `GOG_CLIENT` フラグ
2. `account_clients` 設定（email -> client）
3. `client_domains` 設定（domain -> client）
4. メールドメインと同名の credentials ファイル
5. `default`

### サービスアカウント（Workspace のみ）

ドメイン全体の委任（domain-wide delegation）によるユーザー偽装:

```bash
# サービスアカウントキーを設定
gog auth service-account set you@yourdomain.com --key ~/Downloads/service-account.json

# 確認
gog --account you@yourdomain.com auth status
gog auth list
```

### サービススコープ

```bash
# 特定サービスのみ認証
gog auth add you@gmail.com --services drive,calendar

# 読み取り専用
gog auth add you@gmail.com --services drive,calendar --readonly

# Drive スコープ制御
gog auth add you@gmail.com --services drive --drive-scope full      # フルアクセス
gog auth add you@gmail.com --services drive --drive-scope readonly  # 読み取り専用
gog auth add you@gmail.com --services drive --drive-scope file      # 自アプリファイルのみ

# スコープ追加時（再認証が必要な場合）
gog auth add you@gmail.com --services sheets --force-consent
```

### キーリングバックエンド

| バックエンド | 説明 |
|------------|------|
| `auto` | OS に最適なバックエンド（デフォルト） |
| `keychain` | macOS Keychain（推奨） |
| `file` | 暗号化ファイル（CI/SSH 向け） |

```bash
# バックエンド設定
gog auth keyring file
gog auth keyring keychain
gog auth keyring auto

# 現在のバックエンド確認
gog auth keyring

# CI/非インタラクティブ環境
export GOG_KEYRING_BACKEND=file
export GOG_KEYRING_PASSWORD='...'
gog --no-input auth status
```

### 認証状態確認

```bash
gog auth status                   # 現在のアカウントの認証状態
gog auth services                 # 利用可能なサービスとスコープ一覧
gog auth list                     # 保存済みアカウント一覧
gog auth list --check             # トークン有効性検証
gog auth remove <email>           # アカウント削除
```

---

## コマンド体系

### グローバルフラグ

| フラグ | 説明 |
|--------|------|
| `--account <email\|alias\|auto>` | 使用アカウント |
| `--client <name>` | OAuth クライアント名 |
| `--json` | JSON 出力 |
| `--plain` | TSV 出力（パイプ向け） |
| `--color <auto\|always\|never>` | カラーモード |
| `--force` | 確認スキップ |
| `--no-input` | 非インタラクティブモード |
| `--verbose` | 詳細ログ |
| `--enable-commands <csv>` | コマンド許可リスト |

### Gmail

```bash
# 検索
gog gmail search 'newer_than:7d' --max 10
gog gmail messages search 'newer_than:7d' --max 10 --include-body

# スレッド・メッセージ取得
gog gmail thread get <threadId>
gog gmail thread get <threadId> --download --out-dir ./attachments
gog gmail get <messageId>
gog gmail get <messageId> --format metadata
gog gmail url <threadId>

# スレッドラベル操作
gog gmail thread modify <threadId> --add STARRED --remove INBOX

# 送信
gog gmail send --to a@b.com --subject "Hi" --body "Hello"
gog gmail send --to a@b.com --subject "Hi" --body-file ./message.txt
gog gmail send --to a@b.com --subject "Hi" --body-html "<p>Hello</p>"

# 下書き
gog gmail drafts list
gog gmail drafts create --subject "Draft" --body "Body"
gog gmail drafts send <draftId>

# ラベル
gog gmail labels list
gog gmail labels get INBOX --json
gog gmail labels create "My Label"

# バッチ操作
gog gmail batch delete <messageId> <messageId>
gog gmail batch modify <messageId> <messageId> --add STARRED

# フィルタ
gog gmail filters list
gog gmail filters create --from 'noreply@example.com' --add-label 'Notifications'

# 設定
gog gmail autoforward get
gog gmail vacation get
gog gmail vacation enable --subject "Out of office" --message "..."
gog gmail sendas list
gog gmail delegates list

# Watch (Pub/Sub)
gog gmail watch start --topic projects/<p>/topics/<t> --label INBOX
gog gmail history --since <historyId>
```

### メール追跡

```bash
# 追跡セットアップ
gog gmail track setup --worker-url https://gog-email-tracker.<acct>.workers.dev

# 追跡付き送信
gog gmail send --to a@b.com --subject "Hi" --body-html "<p>Hello</p>" --track

# 開封確認
gog gmail track opens <tracking_id>
gog gmail track opens --to recipient@example.com
gog gmail track status
```

### Calendar

```bash
# カレンダー一覧
gog calendar calendars
gog calendar colors

# イベント取得
gog calendar events <calendarId> --today
gog calendar events <calendarId> --tomorrow
gog calendar events <calendarId> --week
gog calendar events <calendarId> --days 3
gog calendar events <calendarId> --from today --to friday
gog calendar events --all
gog calendar event <calendarId> <eventId>
gog calendar search "meeting" --today

# イベント作成
gog calendar create <calendarId> \
  --summary "Meeting" \
  --from 2025-01-15T10:00:00Z \
  --to 2025-01-15T11:00:00Z \
  --attendees "alice@example.com,bob@example.com" \
  --location "Zoom"

# イベント更新
gog calendar update <calendarId> <eventId> \
  --summary "Updated" \
  --send-updates all

# 出席者追加（既存を保持）
gog calendar update <calendarId> <eventId> \
  --add-attendee "alice@example.com"

# 繰り返し + リマインダー
gog calendar create <calendarId> \
  --summary "Payment" \
  --from 2025-02-11T09:00:00-03:00 \
  --to 2025-02-11T09:15:00-03:00 \
  --rrule "RRULE:FREQ=MONTHLY;BYMONTHDAY=11" \
  --reminder "email:3d" \
  --reminder "popup:30m"

# 特殊イベント
gog calendar focus-time --from ... --to ...
gog calendar out-of-office --from ... --to ... --all-day
gog calendar working-location --type office --office-label "HQ" --from ... --to ...

# 削除
gog calendar delete <calendarId> <eventId>

# 招待応答
gog calendar respond <calendarId> <eventId> --status accepted
gog calendar respond <calendarId> <eventId> --status declined
gog calendar propose-time <calendarId> <eventId>

# 空き状況
gog calendar freebusy --calendars "primary,work@example.com" \
  --from 2025-01-15T00:00:00Z --to 2025-01-16T00:00:00Z
gog calendar conflicts --calendars "primary" --today

# チームカレンダー（Workspace + Cloud Identity API）
gog calendar team <group-email> --today
gog calendar team <group-email> --freebusy
```

### Chat（Workspace のみ）

```bash
# スペース
gog chat spaces list
gog chat spaces find "Engineering"
gog chat spaces create "Engineering" --member alice@company.com

# メッセージ
gog chat messages list spaces/<spaceId> --max 5
gog chat messages list spaces/<spaceId> --unread
gog chat messages send spaces/<spaceId> --text "Hello"

# スレッド
gog chat threads list spaces/<spaceId>

# DM
gog chat dm space user@company.com
gog chat dm send user@company.com --text "ping"
```

### Classroom（Workspace for Education）

```bash
# コース
gog classroom courses list
gog classroom courses get <courseId>
gog classroom courses create --name "Math 101"

# 名簿
gog classroom roster <courseId>
gog classroom students add <courseId> <userId>

# 課題
gog classroom coursework list <courseId>
gog classroom coursework create <courseId> --title "Homework 1" --type ASSIGNMENT --state PUBLISHED

# 提出物・成績
gog classroom submissions list <courseId> <courseworkId>
gog classroom submissions grade <courseId> <courseworkId> <submissionId> --grade 85

# お知らせ・トピック
gog classroom announcements list <courseId>
gog classroom topics list <courseId>
```

### Drive

```bash
# 一覧・検索
gog drive ls --max 20
gog drive ls --parent <folderId>
gog drive search "invoice" --max 20
gog drive get <fileId>
gog drive url <fileId>

# アップロード・ダウンロード
gog drive upload ./path/to/file --parent <folderId>
gog drive download <fileId> --out ./downloaded.bin
gog drive download <fileId> --format pdf --out ./exported.pdf

# フォルダ操作
gog drive mkdir "New Folder" --parent <parentFolderId>
gog drive rename <fileId> "New Name"
gog drive move <fileId> --parent <destinationFolderId>
gog drive delete <fileId>
gog drive copy <fileId> "Copy Name"

# 権限
gog drive permissions <fileId>
gog drive share <fileId> --to user --email user@example.com --role reader
gog drive unshare <fileId> --permission-id <permissionId>

# 共有ドライブ
gog drive drives --max 100
```

### Docs / Slides

```bash
# Docs
gog docs info <docId>
gog docs cat <docId> --max-bytes 10000
gog docs create "My Doc"
gog docs copy <docId> "My Doc Copy"
gog docs export <docId> --format pdf --out ./doc.pdf

# Slides
gog slides info <presentationId>
gog slides create "My Deck"
gog slides copy <presentationId> "My Deck Copy"
gog slides export <presentationId> --format pptx --out ./deck.pptx
```

### Sheets

```bash
# メタデータ・読み取り
gog sheets metadata <spreadsheetId>
gog sheets get <spreadsheetId> 'Sheet1!A1:B10'

# 書き込み
gog sheets update <spreadsheetId> 'A1' 'val1|val2,val3|val4'
gog sheets update <spreadsheetId> 'A1' --values-json '[["a","b"],["c","d"]]'
gog sheets append <spreadsheetId> 'Sheet1!A:C' 'new|row|data'
gog sheets clear <spreadsheetId> 'Sheet1!A1:B10'

# フォーマット
gog sheets format <spreadsheetId> 'Sheet1!A1:B2' \
  --format-json '{"textFormat":{"bold":true}}' \
  --format-fields 'userEnteredFormat.textFormat.bold'

# 作成・エクスポート
gog sheets create "My Spreadsheet" --sheets "Sheet1,Sheet2"
gog sheets export <spreadsheetId> --format pdf --out ./sheet.pdf
gog sheets copy <spreadsheetId> "My Sheet Copy"
```

### Contacts

```bash
# 個人連絡先
gog contacts list --max 50
gog contacts search "Ada" --max 50
gog contacts get user@example.com
gog contacts create --given-name "John" --family-name "Doe" --email "john@example.com"
gog contacts update people/<resourceName> --given-name "Jane"
gog contacts delete people/<resourceName>

# その他の連絡先
gog contacts other list --max 50
gog contacts other search "John"

# Workspace ディレクトリ
gog contacts directory list --max 50
gog contacts directory search "Jane"
```

### Tasks

```bash
# タスクリスト
gog tasks lists --max 50
gog tasks lists create <title>

# タスク操作
gog tasks list <tasklistId> --max 50
gog tasks get <tasklistId> <taskId>
gog tasks add <tasklistId> --title "Task title"
gog tasks add <tasklistId> --title "Weekly" --due 2025-02-01 --repeat weekly --repeat-count 4
gog tasks update <tasklistId> <taskId> --title "New title"
gog tasks done <tasklistId> <taskId>
gog tasks undo <tasklistId> <taskId>
gog tasks delete <tasklistId> <taskId>
gog tasks clear <tasklistId>
```

### People

```bash
gog people me
gog people get people/<userId>
gog people search "Ada Lovelace" --max 5
gog people relations
gog people relations people/<userId> --type manager
```

### Groups（Workspace のみ）

```bash
gog groups list
gog groups members engineering@company.com
```

### Keep（Workspace のみ）

```bash
gog keep list --account you@yourdomain.com
gog keep get <noteId> --account you@yourdomain.com
gog keep search <query> --account you@yourdomain.com
gog keep attachment <attachmentName> --out ./attachment.bin
```

### Time

```bash
gog time now
gog time now --timezone UTC
```

### Config

```bash
gog config path
gog config list
gog config keys
gog config get default_timezone
gog config set default_timezone UTC
gog config unset default_timezone
```

---

## 出力形式

| 形式 | フラグ | 用途 |
|------|--------|------|
| テーブル | (デフォルト) | 人間向け表示 |
| TSV | `--plain` | パイプ処理向け（タブ区切り） |
| JSON | `--json` | スクリプティング・自動化向け |

```bash
# JSON 出力でパイプ処理
gog --json drive ls --max 5 | jq '.files[] | select(.mimeType=="application/pdf")'

# Calendar JSON には曜日フィールドが追加される
gog calendar get <calendarId> <eventId> --json
# startDayOfWeek, endDayOfWeek フィールドが含まれる
```

- データは stdout、エラー・進捗は stderr に出力
- カラーは TTY 接続時のみ自動有効（`--json`, `--plain` では無効）

---

## 環境変数

| 変数 | 説明 |
|------|------|
| `GOG_ACCOUNT` | デフォルトアカウント（email またはエイリアス） |
| `GOG_CLIENT` | OAuth クライアント名 |
| `GOG_JSON` | デフォルト JSON 出力 |
| `GOG_PLAIN` | デフォルト plain 出力 |
| `GOG_COLOR` | カラーモード: `auto`, `always`, `never` |
| `GOG_TIMEZONE` | 出力タイムゾーン（IANA 名, `UTC`, `local`） |
| `GOG_ENABLE_COMMANDS` | コマンド許可リスト（カンマ区切り） |
| `GOG_KEYRING_BACKEND` | キーリングバックエンド: `auto`, `keychain`, `file` |
| `GOG_KEYRING_PASSWORD` | キーリングパスワード（CI/非インタラクティブ向け） |

---

## 設定ファイル

形式: JSON5（コメント、末尾カンマ対応）

パス:
- macOS: `~/Library/Application Support/gogcli/config.json`
- Linux: `~/.config/gogcli/config.json`
- Windows: `%AppData%\\gogcli\\config.json`

```json5
{
  keyring_backend: "file",
  default_timezone: "UTC",
  account_aliases: {
    work: "work@company.com",
    personal: "me@gmail.com",
  },
  account_clients: {
    "work@company.com": "work",
  },
  client_domains: {
    "example.com": "work",
  },
}
```

---

## 典型的なワークフロー

### メール検索と添付ファイルダウンロード

```bash
gog gmail search 'newer_than:7d has:attachment' --max 10
gog gmail thread get <threadId> --download --out-dir ./attachments
```

### カレンダーイベント作成

```bash
# 空き状況確認
gog calendar freebusy --calendars "primary" \
  --from 2025-01-15T00:00:00Z --to 2025-01-16T00:00:00Z

# イベント作成
gog calendar create primary \
  --summary "Team Standup" \
  --from 2025-01-15T10:00:00Z --to 2025-01-15T10:30:00Z \
  --attendees "alice@example.com,bob@example.com"
```

### Drive ファイル検索とダウンロード

```bash
gog --json drive search "invoice filetype:pdf" --max 20 | \
  jq -r '.files[] | .id' | \
  while read fileId; do
    gog drive download "$fileId"
  done
```

### Sheets へのデータ書き込み

```bash
# CSV から書き込み
cat data.csv | tr ',' '|' | gog sheets update <spreadsheetId> 'Sheet1!A1'

# JSON 形式で書き込み
gog sheets update <spreadsheetId> 'A1' --values-json '[["a","b"],["c","d"]]'
```

### マルチアカウント運用

```bash
# エイリアス設定
gog auth alias set personal personal@gmail.com
gog auth alias set work work@company.com

# 使い分け
gog gmail search 'is:unread' --account personal
gog gmail search 'is:unread' --account work
```

### サンドボックス実行（エージェント向け）

```bash
# calendar と tasks のみ許可
export GOG_ENABLE_COMMANDS=calendar,tasks
gog calendar events primary --today
gog tasks list <tasklistId>
```

---

## シェル補完

```bash
# Bash
gog completion bash > $(brew --prefix)/etc/bash_completion.d/gog

# Zsh
gog completion zsh > "${fpath[1]}/_gog"

# Fish
gog completion fish > ~/.config/fish/completions/gog.fish

# PowerShell
gog completion powershell | Out-String | Invoke-Expression
```

---

## セキュリティ

### 資格情報ストレージ

- macOS: Keychain Access
- Linux: Secret Service (GNOME Keyring, KWallet)
- Windows: Credential Manager
- フォールバック: 暗号化ファイル（`GOG_KEYRING_BACKEND=file`）

### ベストプラクティス

- OAuth クライアント資格情報をバージョン管理にコミットしない
- 開発と本番で異なる OAuth クライアントを使用
- 不要なアカウントは `gog auth remove` で削除
- トークン漏洩の疑いがある場合は `--force-consent` で再認証

---

## FAQ

### Q: どの Google アカウントが使えますか？

A: 個人の Google アカウント（@gmail.com）と Google Workspace アカウントの両方に対応。ただし Chat、Groups、Keep、Classroom は Workspace アカウントが必要。

### Q: OAuth2 の設定手順は？

A: Google Cloud Console でプロジェクトを作成し、必要な API を有効化、OAuth2 クライアント（Desktop app タイプ）を作成してJSON をダウンロード。`gog auth credentials <path>` で保存後、`gog auth add <email>` で認証。

### Q: CI/CD 環境で使えますか？

A: はい。`GOG_KEYRING_BACKEND=file` と `GOG_KEYRING_PASSWORD` を設定し、`--no-input` フラグで非インタラクティブ実行が可能。

### Q: 複数の Google Cloud プロジェクトを使い分けられますか？

A: はい。`--client` フラグまたは `GOG_CLIENT` 環境変数で名前付き OAuth クライアントを選択可能。ドメインマッピングによる自動選択も対応。

### Q: コマンドを制限できますか？

A: はい。`--enable-commands` フラグまたは `GOG_ENABLE_COMMANDS` 環境変数でトップレベルコマンドの許可リストを設定可能。エージェント・サンドボックス実行に最適。

### Q: JSON 出力はどのコマンドで使えますか？

A: 全コマンドで `--json` フラグが使用可能。データは stdout、エラーは stderr に出力されるため、パイプ処理が安全に行える。
