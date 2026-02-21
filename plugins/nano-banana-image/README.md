# nano-banana-image

Gemini Nano Banana Pro（gemini-3-pro-image-preview）を活用した画像生成プラグイン。

## 機能

- テキストプロンプトからの画像生成
- 解像度指定（1K / 2K / 4K）
- アスペクト比指定（1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9）
- 参照画像を使った編集（最大14枚）

## インストール

```bash
/plugin install nano-banana-image@cc-plugins
```

## 使用方法

### コマンドによる明示的な実行

```
/nano-banana-image:generate "A serene Japanese garden with cherry blossoms"
```

オプション付き:

```
/nano-banana-image:generate "A mountain landscape" --aspect 16:9 --resolution 2K
```

### スキルによる自動発動

以下のような発話で自動的にスキルが発動:
- 「画像を生成して」
- 「イラストを作成して」
- 「絵を描いて」
- 「Generate an image of...」

## 前提条件

### Gemini CLI のインストール

```bash
npm install -g @google/gemini-cli
# または
brew install gemini-cli
```

### 認証設定（いずれかの方法）

**方法 1: Google OAuth（推奨）**

`gemini` コマンドを初回実行するとブラウザが開き、Google アカウントでログインする。
追加の設定不要。

```bash
gemini  # 初回実行時にブラウザが開く
```

**方法 2: API キー**

[Google AI Studio](https://aistudio.google.com/) で API キーを取得し、環境変数に設定:

```bash
export GEMINI_API_KEY="your-api-key"
```

### その他

- gemini-3-pro-image-preview モデルへのアクセス権限が必要

## オプション

| オプション | 値 | デフォルト |
|-----------|-----|-----------|
| --aspect | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 | 1:1 |
| --resolution | 1K, 2K, 4K | 2K |

## ライセンス

MIT
