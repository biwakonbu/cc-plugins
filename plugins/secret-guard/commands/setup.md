---
description: シークレット操作用のテンプレートスクリプトを生成
allowed-tools: Bash, Read, Write, Glob, AskUserQuestion
argument-hint: [script-type]
---

# secret-guard: セットアップ

シークレットファイルの安全な操作を支援するテンプレートスクリプトを生成する。

## 引数

$ARGUMENTS

## 利用可能なスクリプトタイプ

- `env-loader`: .env ファイルから環境変数を安全に読み込むスクリプト
- `env-example`: .env.example テンプレートファイル
- `docker-secrets`: Docker Compose secrets 設定テンプレート
- `vault-config`: HashiCorp Vault 連携スクリプト

スクリプトタイプが指定されない場合は、`secret-operations` スキルを使用して
ユーザーに対話的に必要なテンプレートを確認する。

## 実行内容

`secret-operations` スキルを使用して以下を実行:

1. プロジェクトの技術スタックを確認
2. 指定されたテンプレートスクリプトを生成
3. セットアップ手順を案内
