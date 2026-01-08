# image-gen-gemini プラグイン

Gemini CLI の Nano Banana Pro モデルを使用した AI 画像生成プラグイン。

## 概要

テキストプロンプトから画像を生成する。スキル中心の設計で、複雑な知識は `image-generate` スキルに集約。

## 構造

```
image-gen-gemini/
├── .claude-plugin/
│   └── plugin.json        # プラグインメタデータ
├── commands/
│   └── generate.md        # 明示的な画像生成コマンド
├── agents/
│   └── image-designer.md  # 複雑なデザインタスク用
├── skills/
│   └── image-generate/
│       └── SKILL.md       # 画像生成の知識・手順
├── CLAUDE.md              # このファイル
└── README.md              # ユーザー向けドキュメント
```

## 設計方針

### スキル中心設計

- **image-generate スキル**: 画像生成の全知識を集約
  - Gemini CLI コマンドの使い方
  - プロンプト最適化のコツ
  - 保存先の取り扱い
  - トラブルシューティング

### コマンドは薄く

- **generate コマンド**: スキル参照のポインタ
  - 引数の受け取りと転送
  - スキルへの指示

### エージェントは複雑タスク用

- **image-designer エージェント**:
  - 複数バリエーション生成
  - スタイル提案
  - 改善サイクル

## 前提条件

### Gemini CLI のインストール

```bash
npm install -g @google/gemini-cli
```

### 認証設定

以下のいずれかで認証:

1. **Google OAuth**: `gemini auth` を実行
2. **API キー**: `GEMINI_API_KEY` 環境変数を設定

## 使用モデル

- **モデル名**: `gemini-2.0-flash-preview-image-generation`
- **別名**: Nano Banana Pro
- **特徴**: テキスト→画像生成、高品質出力

## 保存先の取り扱い

ユーザー指定方式を採用:

1. `--output` オプションで明示的に指定
2. 指定がない場合は AskUserQuestion で確認
3. ディレクトリが存在しない場合は自動作成

## 開発ルール

- ドキュメント・コメント: 日本語
- コード・変数名: 英語
- バージョン更新: 内容変更時は必ず plugin.json の version を更新

## ドキュメント維持規則

**README.md と CLAUDE.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- コマンドの追加・変更・削除
- スキルの追加・変更・削除
- エージェントの追加・変更・削除
- plugin.json の変更（バージョン含む）
- 設計方針や動作の変更

### README.md の役割

- **対象**: ユーザー（プラグイン利用者）
- **内容**: インストール方法、使い方、機能一覧、使用例

### CLAUDE.md の役割

- **対象**: AI（Claude）と開発者
- **内容**: 設計方針、アーキテクチャ、内部構造、開発ルール

### 同期チェック

プラグイン変更時、フックにより README.md と CLAUDE.md の整合性がチェックされる。
不整合がある場合は警告が表示される。
