# agent-browser-spec プラグイン

agent-browser CLI の仕様と使い方に関する知識を提供するプラグイン。

## 概要

agent-browser は AI エージェント向けのヘッドレスブラウザ自動化 CLI。Rust で実装された高速な実行エンジンと Node.js/Playwright フォールバックを備えている。

## スキル

| スキル | 説明 |
|--------|------|
| `agent-browser-knowledge` | agent-browser CLI の完全なコマンドリファレンスと使い方 |

## 主な機能

- ヘッドレスブラウザ自動化
- アクセシビリティツリースナップショット（ref による要素参照）
- セマンティックロケーター（role, label, text, placeholder）
- セッション管理（独立したブラウザインスタンス）
- ネットワーク制御（リクエスト監視、ブロック、モック）
- Cookie/Storage 管理
- スクリーンショット/PDF 生成

## 基本ワークフロー

```bash
agent-browser open <url>       # 1. ページを開く
agent-browser snapshot -i      # 2. インタラクティブ要素を取得
agent-browser click @e2        # 3. ref で要素を操作
agent-browser screenshot       # 4. スクリーンショット取得
agent-browser close            # 5. ブラウザを閉じる
```

## 参考

- GitHub: https://github.com/vercel-labs/agent-browser
- 公式サイト: https://agent-browser.dev
