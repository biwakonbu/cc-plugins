---
name: image-generation
description: Gemini Nano Banana Pro を使用した画像生成。テキストから画像、解像度・アスペクト比指定、参照画像を使った編集に対応。Use when user asks to generate images, create pictures, make illustrations, or edit images with AI. Also use when user says 画像生成, 画像を作って, イラスト作成, 絵を描いて, 画像編集.
allowed-tools: Bash
---

# Image Generation with Gemini Nano Banana Pro

Gemini API の gemini-3-pro-image-preview（Nano Banana Pro）モデルを使用して画像を生成する。

## モデル仕様

| 項目 | 内容 |
|------|------|
| モデル名 | `gemini-3-pro-image-preview` |
| 解像度 | 1K, 2K, 4K |
| アスペクト比 | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 |
| 参照画像 | 最大14枚 |

## 実行手順

### 1. ユーザーの要求を分析

ユーザーの発話から以下を抽出:
- 生成したい画像の説明（プロンプト）
- 解像度の指定（デフォルト: 2K）
- アスペクト比の指定（デフォルト: 1:1）
- 参照画像の有無

### 2. プロンプトの構築

画像生成に適したプロンプトを構築:
- 具体的な描写を含める
- スタイルや雰囲気を指定
- 英語でのプロンプトが推奨

### 3. Gemini CLI で画像生成

以下のコマンドで画像を生成:

```bash
gemini --yolo --model gemini-3-pro-image-preview "Generate an image: {プロンプト}"
```

### 4. 生成結果の確認

- 生成された画像のパスを確認
- ユーザーに結果を報告

## オプション指定

解像度やアスペクト比を指定する場合、プロンプトに含める:

```bash
gemini --yolo --model gemini-3-pro-image-preview "Generate an image with 16:9 aspect ratio at 2K resolution: {プロンプト}"
```

## 参照画像を使用する場合

既存の画像を参照して編集・生成する場合:

```bash
gemini --yolo --model gemini-3-pro-image-preview "Edit this image: {編集指示}" --files {画像パス}
```

## 注意事項

- Gemini CLI がインストールされている必要がある
- API キーが設定されている必要がある
- 生成された画像には SynthID 透かしが埋め込まれる
- 不適切なコンテンツの生成は拒否される

## 使用例

### 基本的な画像生成

ユーザー: 「夕焼けの富士山の画像を生成して」

```bash
gemini --yolo --model gemini-3-pro-image-preview "Generate an image: A majestic Mount Fuji at sunset with vibrant orange and purple sky, traditional Japanese aesthetic"
```

### アスペクト比指定

ユーザー: 「16:9 のワイドスクリーン形式で海岸の画像を作って」

```bash
gemini --yolo --model gemini-3-pro-image-preview "Generate an image with 16:9 aspect ratio: A peaceful beach scene with gentle waves, golden sand, and a clear blue sky"
```

### 参照画像を使った編集

ユーザー: 「この画像の背景を宇宙に変えて」

```bash
gemini --yolo --model gemini-3-pro-image-preview "Edit this image: Change the background to a starry outer space scene with galaxies and nebulae" --files /path/to/image.png
```
