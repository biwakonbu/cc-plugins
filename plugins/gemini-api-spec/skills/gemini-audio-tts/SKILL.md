---
name: gemini-audio-tts
description: Use when user asks about Gemini TTS, text-to-speech, audio generation, Live API, voice synthesis, speech, or audio models. Also use when user says TTS, 音声合成, テキスト読み上げ, Live API, 音声モデル, 音声生成. Gemini 音声モデル、TTS（Text-to-Speech）、Live API の構成・使用法を提供し、コスト優先とパフォーマンス優先の両軸で推奨する。
context: fork
---

# Gemini Audio & TTS

Gemini の音声モデル、TTS、Live API の構成と使用法。

---

## モデル選択ガイド

### コスト優先

| モデル | モデル ID | 特徴 |
|--------|----------|------|
| **Flash Live** | `gemini-3.1-flash-preview` (Live API) | 低レイテンシ、低コスト、リアルタイム対話 |
| **Chirp 3** | `chirp-3` | ASR/TTS 専用、軽量 |

### パフォーマンス優先

| モデル | モデル ID | 特徴 |
|--------|----------|------|
| **Pro Live** | `gemini-3.1-pro-preview` (Live API) | 最高品質音声、複雑な対話 |
| **Native Audio** | `gemini-3.1-pro-preview` | ネイティブ音声出力、感情表現 |

---

## TTS（Text-to-Speech）

### 基本使用法

```python
from google import genai
from google.genai import types
import base64

client = genai.Client(api_key="YOUR_API_KEY")

response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="こんにちは、今日はいい天気ですね。",
    config=types.GenerateContentConfig(
        response_modalities=["AUDIO"],
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(
                    voice_name="Kore"  # 音声プロファイル
                )
            )
        )
    )
)

# 音声データの保存
for part in response.candidates[0].content.parts:
    if part.inline_data:
        audio_data = base64.b64decode(part.inline_data.data)
        with open("output.wav", "wb") as f:
            f.write(audio_data)
```

### 音声プロファイル一覧

| 名前 | 性別 | 特徴 | 言語 |
|------|------|------|------|
| Zephyr | 女性 | 明るく自然 | 多言語 |
| Puck | 男性 | 落ち着いた声 | 多言語 |
| Charon | 男性 | 深みのある声 | 多言語 |
| Kore | 女性 | クリアで親しみやすい | 多言語 |
| Fenrir | 男性 | 力強い声 | 多言語 |
| Aoede | 女性 | 温かみのある声 | 多言語 |
| Leda | 女性 | 柔らかい声 | 多言語 |
| Orus | 男性 | プロフェッショナル | 多言語 |
| Perseus | 男性 | 明瞭な声 | 多言語 |

---

## Live API（リアルタイム音声対話）

### 概要

Live API は WebSocket ベースのリアルタイム双方向音声通信を提供。

### 基本構成

```python
import asyncio
from google import genai
from google.genai import types

client = genai.Client(api_key="YOUR_API_KEY")

async def main():
    config = types.LiveConnectConfig(
        response_modalities=["AUDIO"],
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(
                    voice_name="Kore"
                )
            )
        )
    )

    async with client.aio.live.connect(
        model="gemini-3.1-flash-preview",
        config=config
    ) as session:
        # テキスト入力 → 音声出力
        await session.send_client_content(
            turns=types.Content(
                role="user",
                parts=[types.Part(text="こんにちは")]
            )
        )

        async for response in session.receive():
            if response.data:
                # 音声データを処理
                pass

asyncio.run(main())
```

### Live API の機能

| 機能 | 説明 |
|------|------|
| リアルタイム音声入力 | マイクからの音声ストリーミング |
| リアルタイム音声出力 | 低レイテンシ音声生成 |
| 音声活動検出（VAD） | 自動的に発話区間を検出 |
| 割り込み対応 | ユーザーの割り込み発話に対応 |
| マルチモーダル入力 | 音声 + テキスト + 画像の同時入力 |
| ツール使用 | Function Calling との組み合わせ |
| セッション維持 | 会話コンテキストの保持 |

### Live API の制限

| 項目 | 値 |
|------|-----|
| セッション時間 | 最大 30 分 |
| 音声フォーマット | PCM 16bit、24kHz |
| 最大同時接続 | Tier 依存 |

---

## 音声認識（Speech-to-Text）

### Gemini モデルでの音声認識

```python
response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents=[
        types.Part.from_text("この音声を文字起こしして"),
        types.Part.from_uri(
            file_uri="gs://bucket/recording.mp3",
            mime_type="audio/mp3"
        ),
    ]
)
print(response.text)
```

### 対応音声フォーマット

| フォーマット | MIME タイプ |
|-------------|-----------|
| MP3 | audio/mp3 |
| WAV | audio/wav |
| FLAC | audio/flac |
| OGG | audio/ogg |
| AAC | audio/aac |
| WebM | audio/webm |

---

## Chirp 3（ASR/TTS 専用）

| 項目 | 値 |
|------|-----|
| モデル ID | `chirp-3` |
| 用途 | 音声認識（ASR）・音声合成（TTS）専用 |
| 特徴 | 軽量、低コスト、100+ 言語対応 |
| 推奨場面 | バッチ音声処理、字幕生成、コスト最優先の TTS |

**注意**: Chirp 3 は Gemini のマルチモーダル機能とは別の専用モデル。対話的な用途には Live API を推奨。

---

## 用途別推奨

| 用途 | 推奨モデル | 理由 |
|------|-----------|------|
| 音声アシスタント | Flash Live | 低レイテンシ、コスト効率 |
| ナレーション生成 | Flash TTS | バッチ処理に最適 |
| 高品質対話 AI | Pro Live | 最高品質の音声 |
| 字幕生成 | Flash / Chirp 3 | コスト効率 |
| コールセンター | Flash Live | リアルタイム、低コスト |
| オーディオブック | Pro TTS | 感情表現が豊か |
