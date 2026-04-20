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

## v1.0.1 の変更

**5 ツール共通認識の標準化対応:**
- `AGENTS.md` を新規追加（Claude Code / Codex CLI / Cursor / Copilot CLI / OpenCode の入口ドキュメント）
- skills / agents / commands の `description` 1 行目を `Use when ...` で始まる形式に統一
  - Cursor / Codex / Copilot / OpenCode での発動判定精度を向上
- 既存の説明文は語順入れ替えにより先頭に移動。日本語説明は末尾に再配置し情報量は保持

**関連:**
- 仕様: `.claude/rules/plugin-development.md`
- リンター: `.claude/scripts/lint-multi-tool-compat.sh`
