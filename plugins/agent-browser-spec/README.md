# agent-browser-spec

agent-browser CLI の仕様と使い方に関する知識を提供するプラグイン。

## 概要

[agent-browser](https://github.com/vercel-labs/agent-browser) は AI エージェント向けのヘッドレスブラウザ自動化 CLI。このプラグインは完全なコマンドリファレンスと実装ガイドを提供します。

## 主な機能

- **完全なコマンドリファレンス**: 50+ のコマンドと全オプションを網羅
- **セレクター種類**: Refs（`@e1`）、CSS セレクター、セマンティックロケーター
- **高度な操作**: ネットワーク制御、Cookie/Storage 管理、セッション管理
- **AI エージェント統合**: Claude Code、Cursor、Gemini などで活用可能
- **ベストプラクティス**: スナップショットファースト、適切な待機、エラーハンドリング

## インストール

```bash
/plugin install agent-browser-spec@cc-plugins
```

または marketplace から:

```bash
/plugin install
# 検索: agent-browser-spec
```

## 使用方法

スキルが自動的に有効になり、agent-browser 関連の質問に応答します。

### 例

```
ユーザー: agent-browser でフォームに入力する方法を教えて

Claude: agent-browser-knowledge スキルが自動発動し、
        フォーム入力のコマンドと使用例を提供します。
```

## スキル

### agent-browser-knowledge

- **説明**: agent-browser CLI の完全なコマンドリファレンス
- **自動発動**: agent-browser、ブラウザ自動化、スナップショット関連の質問
- **コンテキスト**: fork（独立したサブエージェント）

## 内容

### ナビゲーション

```bash
agent-browser open <url>
agent-browser back
agent-browser forward
agent-browser reload
```

### スナップショット（AI 推奨）

```bash
agent-browser snapshot -i          # インタラクティブ要素のみ
agent-browser snapshot -c          # コンパクト表示
agent-browser snapshot -d 3        # 深さ制限
```

### セレクター

```bash
# Refs（推奨）
agent-browser click @e2

# CSS
agent-browser click "#submit"

# セマンティック
agent-browser find role button click --name "Submit"
agent-browser find label "Email" fill "test@test.com"
```

### フォーム操作

```bash
agent-browser fill <selector> "text"
agent-browser check <selector>
agent-browser select <selector> "value"
agent-browser upload <selector> file.pdf
```

### 情報取得

```bash
agent-browser get text <selector>
agent-browser get value <selector>
agent-browser get title
agent-browser get url
```

### ネットワーク制御

```bash
agent-browser network route "**/*.js" --abort    # ブロック
agent-browser network route "**/*.css" --abort   # ブロック
agent-browser network requests                   # リクエスト一覧
```

### セッション管理

```bash
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com
agent-browser session list
```

## AI エージェント統合のベストプラクティス

1. **スナップショットファースト**: 必ずスナップショットで要素を確認
2. **待機を活用**: ページ遷移後は `wait --load networkidle`
3. **ref を使用**: セレクターには `@e1` などの ref を使用
4. **エラーハンドリング**: `is visible` で要素確認、タイムアウト設定

## 参考

- [GitHub: agent-browser](https://github.com/vercel-labs/agent-browser)
- [公式サイト: agent-browser.dev](https://agent-browser.dev)

## ライセンス

MIT
