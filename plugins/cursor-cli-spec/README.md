# cursor-cli-spec

Cursor IDE および cursor-agent CLI の仕様と使い方を完璧に理解するための知識プラグイン。

## 概要

このプラグインは、Cursor IDE と cursor-agent CLI に関する包括的な知識を Claude Code に提供します。Cursor について質問すると、自動的にスキルが発動して正確な情報を回答します。

## 含まれる知識

- **cursor コマンド**: VS Code 互換のエディタ CLI
- **cursor-agent コマンド**: ターミナル AI エージェント CLI
- **AI 機能**: Composer、Inline Edit、エージェントモード
- **@ シンボル**: コンテキスト指定（@Files, @Codebase, @Web など）
- **MCP サーバー連携**: Model Context Protocol の設定と使用
- **設定ファイル**: .cursor/rules, .cursor/commands/ など

## インストール

```bash
/plugin install cursor-cli-spec@cc-plugins
```

## 使用例

プラグインインストール後、以下のような質問に自動で回答:

- 「Cursor CLI について教えて」
- 「cursor-agent の使い方は？」
- 「Cursor の @ シンボルについて」
- 「MCP サーバーの設定方法は？」

## 前提条件

このプラグインは知識のみを提供します。実際に Cursor を使用するには:

1. Cursor エディタ: https://cursor.com/
2. cursor-agent CLI:
   ```bash
   curl https://cursor.com/install -fsS | bash
   ```

## 参考リンク

- [Cursor 公式サイト](https://cursor.com/)
- [公式ドキュメント](https://docs.cursor.com/)
- [CLI ドキュメント](https://docs.cursor.com/cli/overview)

## ライセンス

MIT
