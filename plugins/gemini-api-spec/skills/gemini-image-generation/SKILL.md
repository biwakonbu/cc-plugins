---
name: gemini-image-generation
description: Gemini 画像生成モデル（Nano Banana 2 / Pro）の選択ガイド、解像度・アスペクト比・価格比較、SDK 使用法を提供。Use when user asks about Gemini image generation, Nano Banana, image models, image resolution, aspect ratio, or image editing. Also use when user says 画像生成モデル, Nano Banana, 画像モデル選択, 解像度, アスペクト比.
context: fork
---

# Gemini Image Generation

Gemini 画像生成モデルの選択ガイドと使用法。

---

## モデル比較

### Nano Banana 2（デフォルト推奨）

| 項目 | 値 |
|------|-----|
| モデル ID | `gemini-3-flash-image-preview` |
| ベース | Flash ベース |
| 速度 | **高速**（Flash の推論速度） |
| コスト | **低コスト** |
| 解像度 | 最大 2K |
| 特徴 | ビジュアルグラウンディング、高速生成 |
| 推奨場面 | **一般用途のデフォルト選択** |

### Nano Banana Pro（明示指定時のみ）

| 項目 | 値 |
|------|-----|
| モデル ID | `gemini-3-pro-image-preview` |
| ベース | Pro ベース |
| 速度 | 中程度 |
| コスト | 高コスト |
| 解像度 | 最大 4K |
| 特徴 | 思考モード、スタイル継承、テキスト埋め込み精度 |
| 推奨場面 | 精密テキスト埋め込み、スタイル継承、プロフェッショナル用途 |

---

## 選択ガイド

```
画像生成が必要
├── 一般用途（ブログ、SNS、プロトタイプ）→ Nano Banana 2
├── テキスト埋め込みが必要 → Nano Banana Pro
├── スタイル継承が必要 → Nano Banana Pro
├── 4K 解像度が必要 → Nano Banana Pro
└── コスト最優先 → Nano Banana 2
```

**重要**: ユーザーが明示的に Pro / 高品質 / 4K を指定しない限り、Nano Banana 2 を使用すること。

---

## 対応解像度

| 解像度 | Nano Banana 2 | Nano Banana Pro |
|--------|:---:|:---:|
| 1K（1024px） | ○ | ○ |
| 2K（2048px） | ○ | ○ |
| 4K（4096px） | × | ○ |

## 対応アスペクト比

| アスペクト比 | 用途 |
|-------------|------|
| 1:1 | SNS アイコン、正方形画像 |
| 2:3 | ポートレート写真 |
| 3:2 | 横長写真 |
| 3:4 | タブレット縦 |
| 4:3 | プレゼン、モニター |
| 4:5 | Instagram 投稿 |
| 5:4 | 印刷物 |
| 9:16 | スマホ縦・ストーリーズ |
| 16:9 | ワイドスクリーン |
| 21:9 | ウルトラワイド |

---

## SDK 使用法

### Python（テキストから画像生成）

```python
from google import genai
from google.genai import types
import base64

client = genai.Client(api_key="YOUR_API_KEY")

response = client.models.generate_content(
    model="gemini-3-flash-image-preview",  # Nano Banana 2
    contents="A serene Japanese garden with cherry blossoms, watercolor style",
    config=types.GenerateContentConfig(
        response_modalities=["IMAGE", "TEXT"],
    )
)

# 画像データの取得
for part in response.candidates[0].content.parts:
    if part.inline_data:
        image_data = base64.b64decode(part.inline_data.data)
        with open("output.png", "wb") as f:
            f.write(image_data)
```

### Python（参照画像を使った編集）

```python
from google.genai import types

# 参照画像の読み込み
with open("input.jpg", "rb") as f:
    image_bytes = f.read()

response = client.models.generate_content(
    model="gemini-3-flash-image-preview",
    contents=[
        types.Part.from_text("この画像の背景を夕焼けに変えて"),
        types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg"),
    ],
    config=types.GenerateContentConfig(
        response_modalities=["IMAGE", "TEXT"],
    )
)
```

### 解像度・アスペクト比の指定

```python
response = client.models.generate_content(
    model="gemini-3-flash-image-preview",
    contents="A mountain landscape at sunset",
    config=types.GenerateContentConfig(
        response_modalities=["IMAGE", "TEXT"],
        image_generation_config=types.ImageGenerationConfig(
            aspect_ratio="16:9",
            number_of_images=1,
        )
    )
)
```

---

## 画像生成のベストプラクティス

### プロンプトの書き方

1. **具体的に記述**: 被写体、スタイル、色調、構図を明確に
2. **スタイル指定**: 「watercolor」「oil painting」「photorealistic」「anime style」
3. **ネガティブ要素**: 避けたい要素を明記（「without text」「no people」）
4. **品質指示**: 「high quality」「detailed」「professional」

### 良いプロンプト例

```
A cozy coffee shop interior with warm lighting,
wooden furniture, steaming cup of latte art on a table,
photorealistic style, soft bokeh background, 4K quality
```

### 制限事項

- 著名人のリアルな描写は生成不可
- 暴力的・性的コンテンツは生成不可
- 生成画像には SynthID 透かしが埋め込まれる
- 参照画像は最大 14 枚まで
- 1 リクエストで最大 4 枚生成

---

## nano-banana-image プラグインとの連携

画像生成を実行する場合は `nano-banana-image` プラグインを使用:

```
/nano-banana-image:generate "プロンプト" --aspect 16:9 --resolution 2K
```

本スキルはモデル選択のナレッジを提供。実行は `nano-banana-image` に委譲。
