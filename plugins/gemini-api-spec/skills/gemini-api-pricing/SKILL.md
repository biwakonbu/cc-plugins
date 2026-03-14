---
name: gemini-api-pricing
description: Gemini API 全モデルの価格表、レート制限、無料枠、コンテキストキャッシュ価格を提供。Use when user asks about Gemini pricing, cost, rate limits, free tier, API pricing, token cost, or billing. Also use when user says Gemini 価格, 料金, レート制限, 無料枠, コスト, 課金, トークン単価.
context: fork
---

# Gemini API Pricing

Gemini API 全モデルの価格・レート制限一覧。

**注意**: 価格は 2026 年 3 月時点の情報。最新価格は [Google AI Studio](https://aistudio.google.com/) を参照。

---

## テキストモデル価格

### Gemini 3.1 系

| モデル | 入力（/1M トークン） | 出力（/1M トークン） | 備考 |
|--------|------------------:|-------------------:|------|
| 3.1 Pro | $3.50 | $10.50 | 128K 以下 |
| 3.1 Pro | $7.00 | $21.00 | 128K 超 |
| 3.1 Flash | $0.15 | $0.60 | 128K 以下 |
| 3.1 Flash | $0.30 | $1.20 | 128K 超 |
| 3.1 Flash Lite | $0.075 | $0.30 | 全長 |

### Thinking トークン

| モデル | Thinking 出力（/1M トークン） |
|--------|---------------------------:|
| 3.1 Pro (thinking) | $3.50 |
| 3.1 Flash (thinking) | $0.20 |

---

## 画像生成価格

### Nano Banana 2（gemini-3-flash-image-preview）

| 解像度 | 価格（/画像） |
|--------|------------:|
| 1K | $0.02 |
| 2K | $0.04 |

### Nano Banana Pro（gemini-3-pro-image-preview）

| 解像度 | 価格（/画像） |
|--------|------------:|
| 1K | $0.04 |
| 2K | $0.08 |
| 4K | $0.16 |

---

## 音声・TTS 価格

| モデル | 入力音声（/1M トークン） | 出力音声（/1M トークン） |
|--------|----------------------:|------------------------:|
| Flash TTS | $0.15 | $2.40 |
| Pro TTS | $3.50 | $16.80 |
| Flash Live | $0.15 | $2.40 |
| Pro Live | $3.50 | $16.80 |

---

## 動画生成価格

### Veo 3.1

| 解像度 | オーディオ | 価格（/秒） |
|--------|----------|----------:|
| 1080p | なし | $0.35 |
| 1080p | あり | $0.50 |
| 4K | なし | $0.70 |
| 4K | あり | $1.00 |

---

## 無料枠（AI Studio）

| モデル | 無料枠 | 制限 |
|--------|--------|------|
| 3.1 Flash | 15 RPM / 100万 TPM / 1500 RPD | レート制限あり |
| 3.1 Flash Lite | 30 RPM / 100万 TPM / 1500 RPD | レート制限あり |
| 3.1 Pro | 2 RPM / 32K TPM / 50 RPD | 厳しい制限 |
| 画像生成 | 10 画像/日 | Nano Banana 2 のみ |
| Veo 3.1 | 5 動画/日 | 1080p のみ |

**RPM**: Requests Per Minute / **TPM**: Tokens Per Minute / **RPD**: Requests Per Day

---

## Tier 別レート制限（有料）

### Tier 1（Pay-as-you-go）

| モデル | RPM | TPM | RPD |
|--------|----:|----:|----:|
| 3.1 Flash | 2000 | 4M | 無制限 |
| 3.1 Flash Lite | 4000 | 4M | 無制限 |
| 3.1 Pro | 1000 | 4M | 無制限 |
| 画像生成 | 10 | - | 1500 |
| Veo 3.1 | 5 | - | 100 |

### Tier 2（月額 $1,000+）

| モデル | RPM | TPM |
|--------|----:|----:|
| 3.1 Flash | 10000 | 10M |
| 3.1 Flash Lite | 10000 | 10M |
| 3.1 Pro | 5000 | 10M |

---

## コンテキストキャッシュ

コンテキストキャッシュは、繰り返し使用するプロンプトやファイルをキャッシュしてコストを削減する機能。

### 価格

| モデル | キャッシュ入力（/1M トークン） | ストレージ（/1M トークン/時間） |
|--------|----------------------------:|-------------------------------:|
| 3.1 Pro | $0.875 | $1.25 |
| 3.1 Flash | $0.0375 | $0.025 |
| 3.1 Flash Lite | $0.01875 | $0.0125 |

### 使用法

```python
from google import genai
from google.genai import types

client = genai.Client(api_key="YOUR_API_KEY")

# キャッシュの作成
cache = client.caches.create(
    model="gemini-3.1-flash-preview",
    config=types.CreateCachedContentConfig(
        display_name="my-cache",
        contents=[
            types.Content(
                role="user",
                parts=[types.Part.from_text("大量のコンテキスト情報...")]
            )
        ],
        ttl="3600s",  # 1 時間
    )
)

# キャッシュを使用してリクエスト
response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="質問",
    config=types.GenerateContentConfig(
        cached_content=cache.name,
    )
)
```

### キャッシュの要件

| 項目 | 値 |
|------|-----|
| 最小トークン数 | 32,768 トークン |
| 最大 TTL | 24 時間（延長可能） |
| 最大サイズ | コンテキストウィンドウの 80% |

---

## コスト最適化のヒント

1. **Flash Lite を優先**: シンプルなタスクには最安モデルを使用
2. **コンテキストキャッシュ活用**: 繰り返しリクエストのコストを 75% 削減
3. **Thinking Budget 管理**: 不要な推論トークンを抑制
4. **バッチリクエスト**: 複数リクエストをまとめて送信
5. **出力トークン制限**: `max_output_tokens` で不要な出力を防止
6. **128K 以下に収める**: Pro / Flash の入力は 128K 以下で半額
