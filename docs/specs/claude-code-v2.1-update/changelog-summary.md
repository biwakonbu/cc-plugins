# Claude Code v2.1.x CHANGELOG サマリー

## v2.1.3

- スラッシュコマンドとスキルの統合
- リリースチャンネル（`stable` / `latest`）の切り替え
- 到達不能な権限ルールの警告と検出
- フックタイムアウトの延長（60秒 → 10分）
- プランファイルの `/clear` での適切なクリア

## v2.1.2

- ハイパーリンク対応（iTerm等のOSC 8対応ターミナル）
- Windows Package Manager（winget）対応
- Shift+Tab でプランモードの「auto-accept edits」オプション
- `FORCE_AUTOUPDATE_PLUGINS` 環境変数
- `agent_type` を SessionStart フック入力に追加

## v2.1.0

- スキルのホットリロード
- `context: fork` によるフォークコンテキスト
- `agent` フィールドでのエージェント指定
- `language` 設定
- Vim モーションの大幅拡張
- フックの `once: true` オプション
- フロントマターでのフック定義
- YAML形式の `allowed-tools`
- MCP `list_changed` 通知対応
- `/teleport` と `/remote-env` コマンド
- `Task(AgentName)` によるエージェント無効化
- ワイルドカードパターン（Bash権限）
- 統合 Ctrl+B バックグラウンド化

## v2.0.74

- LSP ツール追加
- `/terminal-setup` 対応ターミナル拡張（Kitty, Alacritty, Zed, Warp）
- `/theme` での Ctrl+T シンタックスハイライト切り替え

## v2.0.72

- Claude in Chrome（Beta）
- QRコード表示
- セッション再開時のローディング表示
- Alt+T でシンキングモード切り替え

## v2.0.70

- Enter でプロンプト提案の即時受け入れ
- MCP ワイルドカード（`mcp__server__*`）
- プラグインマーケットプレイスの自動更新トグル
- `current_usage` フィールド

## v2.0.64

- 名前付きセッション（`/rename`, `/resume <name>`）
- `.claude/rules/` ディレクトリ対応
- 画像リサイズ時のディメンションメタデータ
- 非同期エージェントとBashコマンド

## v2.0.60

- バックグラウンドエージェント
- Plan モードの Plan サブエージェント
- `--disable-slash-commands` フラグ
- 複数ターミナルクライアント対応（VSCode）

## v2.0.45

- PermissionRequest フック
- Microsoft Foundry 対応
- `&` プレフィックスでバックグラウンドタスク

## v2.0.43

- `permissionMode` フィールド
- `tool_use_id` フィールド
- `skills` フロントマターフィールド
- SubagentStart フック

## v2.0.30

- `disallowedTools` フィールド
- プロンプトベース Stop フック
- `allowUnsandboxedCommands` 設定
