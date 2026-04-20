---
name: gemini-video-generation
description: Use when user asks about Gemini video generation, Veo, video model, video creation, or video editing. Also use when user says 動画生成, Veo, ビデオ生成, 動画モデル, 動画作成. Veo 3.1 動画生成モデルの機能、解像度、アスペクト比、ネイティブオーディオ、価格を提供する。
context: fork
---

# Gemini Video Generation（Veo 3.1）

Veo 3.1 動画生成モデルの機能と使用法。

---

## Veo 3.1 概要

| 項目 | 値 |
|------|-----|
| モデル ID | `veo-3.1` |
| 最大解像度 | 4K（3840x2160） |
| 最大長さ | 8 秒 |
| フレームレート | 24fps |
| ネイティブオーディオ | 対応（音声自動生成） |
| 入力 | テキストプロンプト / 参照画像 |

---

## 機能

### ネイティブオーディオ

Veo 3.1 は動画と同時に音声を自動生成。環境音、効果音、BGM がシーンに合わせて生成される。

### Ingredients to Video

参照画像を「素材」として動画に組み込む機能。キャラクター、オブジェクト、背景を指定可能。

### 対応アスペクト比

| アスペクト比 | 解像度例 | 用途 |
|-------------|---------|------|
| 16:9 | 1920x1080 / 3840x2160 | YouTube、横長動画 |
| 9:16 | 1080x1920 | TikTok、Instagram リール |
| 1:1 | 1080x1080 | SNS 投稿 |
| 4:3 | 1440x1080 | 従来型ディスプレイ |

---

## 選択ガイド

### コスト優先

- 低解像度（1080p）で短尺（4秒以下）
- ネイティブオーディオなし
- シンプルなプロンプト

### パフォーマンス優先

- 4K 解像度
- ネイティブオーディオ同期
- 参照画像を使った Ingredients to Video
- 詳細なプロンプト指定

---

## SDK 使用法

### Python（テキストから動画生成）

```python
import time
from google import genai
from google.genai import types

client = genai.Client(api_key="YOUR_API_KEY")

# 動画生成リクエスト（非同期）
operation = client.models.generate_videos(
    model="veo-3.1",
    prompt="A cat playing with a ball of yarn in a sunlit room, cinematic lighting",
    config=types.GenerateVideoConfig(
        aspect_ratio="16:9",
        number_of_videos=1,
        include_audio=True,  # ネイティブオーディオ
    )
)

# 生成完了を待機
while not operation.done:
    time.sleep(10)
    operation = client.operations.get(operation)

# 動画の取得
for video in operation.result.generated_videos:
    client.files.download(file=video.video, path="output.mp4")
    print(f"生成完了: output.mp4")
```

### Python（参照画像から動画生成）

```python
# 参照画像のアップロード
ref_image = client.files.upload(file="character.png")

operation = client.models.generate_videos(
    model="veo-3.1",
    prompt="The character walking through a forest",
    image=ref_image,  # 参照画像
    config=types.GenerateVideoConfig(
        aspect_ratio="16:9",
        number_of_videos=1,
    )
)
```

---

## プロンプトのベストプラクティス

### 効果的なプロンプト構成

1. **被写体**: 何が映っているか
2. **アクション**: 何をしているか
3. **環境**: どこで、どんな背景か
4. **スタイル**: 映像のスタイル（cinematic, anime, documentary）
5. **カメラ**: カメラワーク（tracking shot, close-up, aerial view）
6. **ライティング**: 照明（golden hour, dramatic lighting, soft light）

### 良いプロンプト例

```
A golden retriever running through a field of sunflowers,
slow motion, golden hour lighting, cinematic depth of field,
tracking shot following the dog, 4K quality
```

### 避けるべきこと

- 複雑すぎるシーン構成（複数のアクションの同時指定）
- テキスト表示の要求（動画内テキストは精度が低い）
- 著名人のリアルな描写

---

## 制限事項

| 項目 | 制限 |
|------|------|
| 最大動画長 | 8 秒 |
| 最大解像度 | 4K |
| 生成時間 | 数分（解像度・複雑さによる） |
| 1 リクエストあたり | 最大 2 動画 |
| コンテンツ制限 | 暴力・性的コンテンツは生成不可 |
| 透かし | SynthID 埋め込み |

---

## 生成時間の目安

| 解像度 | オーディオ | 目安時間 |
|--------|----------|---------|
| 1080p | なし | 1-2 分 |
| 1080p | あり | 2-3 分 |
| 4K | なし | 3-5 分 |
| 4K | あり | 5-8 分 |

**注意**: 生成時間はサーバー負荷により変動する。
