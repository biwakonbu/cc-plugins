---
description: プロジェクトのシークレット保護状況をスキャンしレポート
allowed-tools: Bash, Read, Glob, Grep, Write, Edit, AskUserQuestion
argument-hint: [--fix]
---

# secret-guard: スキャン

プロジェクトのシークレット保護状況をスキャンする。

## 引数

$ARGUMENTS

## 実行内容

`secret-scan` スキルを使用して以下を実行:

1. プロジェクト内のシークレットファイル候補を検出
2. .gitignore との突合せ（保護済み / 未保護 / git追跡済みに分類）
3. スキャン結果レポートの出力
4. 未保護ファイルがある場合は .gitignore への追加を提案

`--fix` 引数が指定された場合:
- ユーザー確認をスキップして .gitignore を自動更新
- ただし git 追跡済みファイルの操作は常にユーザー確認必須
