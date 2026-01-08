---
name: image-generate
description: Gemini CLI (Nano Banana Pro) で画像を生成する。テキストプロンプトからイラスト、写真、デザインを作成。Use when user wants to generate, create, or design images from text. Also use when user says 画像生成, イラスト作成, 画像を作って, デザイン生成, 絵を描いて.
allowed-tools: Bash, Read, Write, Glob, AskUserQuestion
---

# Image Generate

Gemini CLI の Nano Banana Pro モデルを使用してテキストから画像を生成するスキル。

## 前提条件

- Gemini CLI がインストールされていること
- Google OAuth 認証または `GEMINI_API_KEY` が設定されていること

## Instructions

### 1. プロンプトの確認

ユーザーから画像の説明を受け取る。説明が曖昧な場合は詳細を確認する。

**確認すべき項目**:
- 何を描くか（被写体、シーン）
- スタイル（写真風、イラスト、アニメ、水彩画など）
- 雰囲気（明るい、暗い、ファンタジー、リアルなど）

### 2. 保存先の確認

`--output` または `-o` オプションで保存先が指定されているか確認する。

**指定がない場合**:
AskUserQuestion ツールを使用してユーザーに保存先を確認する。

**デフォルトの提案**:
- カレントディレクトリ: `./generated_image.png`
- 専用ディレクトリ: `./generated-images/image_YYYYMMDD_HHMMSS.png`

### 3. プロンプトの最適化

英語のプロンプトが最も良い結果を生成する。日本語プロンプトの場合は英語に変換することを検討。

**良いプロンプトの要素**:
- 具体的な描写（サイズ、色、位置関係）
- スタイル指定（photorealistic, anime style, watercolor, etc.）
- 品質指定（high quality, detailed, 4K resolution）
- 構図指定（close-up, wide shot, bird's eye view）

**プロンプト例**:
```
A fluffy orange cat sitting on a windowsill, looking outside at falling snow,
warm indoor lighting, photorealistic, high detail, cozy atmosphere
```

### 4. 画像生成の実行

以下のコマンドで画像を生成:

```bash
gemini -m gemini-2.0-flash-preview-image-generation --save "{保存先パス}" "{プロンプト}"
```

**オプション**:
- `--save {path}`: 生成画像の保存先を指定
- `--yolo`: 確認プロンプトをスキップ

**注意**:
- 保存先ディレクトリが存在しない場合は事前に作成する
- ファイル名に日本語は使用しない（ASCII文字のみ）

### 5. 結果の確認と報告

生成完了後:

1. ファイルの存在を確認
2. ファイルサイズを確認
3. 保存パスをユーザーに報告

```bash
ls -la "{保存先パス}"
```

**報告内容**:
- 生成された画像のパス
- ファイルサイズ
- 使用したプロンプト（参考用）

## Examples

### 基本的な画像生成

**ユーザー**: 「猫の画像を作って」

**実行**:
1. 詳細を確認（どんな猫？背景は？スタイルは？）
2. 保存先を確認
3. プロンプトを最適化して実行

```bash
mkdir -p ./generated-images
gemini -m gemini-2.0-flash-preview-image-generation --save "./generated-images/cat_20260109.png" "A cute fluffy cat with big eyes, sitting pose, soft lighting, photorealistic style, high quality"
```

### スタイル指定の画像生成

**ユーザー**: 「アニメ風の女の子のイラストを ./output/girl.png に保存して」

**実行**:
```bash
mkdir -p ./output
gemini -m gemini-2.0-flash-preview-image-generation --save "./output/girl.png" "Anime style illustration of a young girl with long hair, cherry blossom background, soft pastel colors, detailed, high quality anime art"
```

### 風景画像の生成

**ユーザー**: 「夕焼けの海の写真風画像を生成」

**実行**:
```bash
gemini -m gemini-2.0-flash-preview-image-generation --save "./sunset_ocean.png" "Beautiful ocean sunset, golden hour lighting, calm waves reflecting orange and purple sky, photorealistic, 4K quality, dramatic clouds"
```

## トラブルシューティング

### 認証エラー

```
Error: Authentication required
```

**対処**:
1. `gemini auth` で認証を実行
2. または `GEMINI_API_KEY` 環境変数を設定

### モデルが見つからない

```
Error: Model not found
```

**対処**:
モデル名を確認。利用可能なモデル一覧を確認:
```bash
gemini models list
```

### 画像が生成されない

**対処**:
1. プロンプトがコンテンツポリシーに違反していないか確認
2. プロンプトを具体的に書き直す
3. 英語のプロンプトを試す

## 制限事項

- 不適切なコンテンツ（暴力、成人向けなど）は生成不可
- 著作権で保護されたキャラクターの生成は避ける
- 実在の人物の顔画像生成は推奨しない
- 1回のリクエストで1枚の画像を生成
