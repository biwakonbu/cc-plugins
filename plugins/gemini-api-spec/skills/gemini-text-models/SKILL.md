---
name: gemini-text-models
description: Gemini テキスト生成モデル（3.1 Pro / Flash / Flash Lite）の詳細比較、推論モード、コンテキストウィンドウ、移行ガイドを提供。Use when user asks about Gemini text models, Flash vs Pro, Flash Lite, thinking mode, reasoning, context window, or model migration. Also use when user says テキストモデル, Flash と Pro の違い, 推論モード, thinking モード, コンテキストウィンドウ.
context: fork
---

# Gemini Text Models

Gemini テキスト生成モデルの詳細比較と選択ガイド。

---

## モデル比較

### Gemini 3.1 Pro

| 項目 | 値 |
|------|-----|
| モデル ID | `gemini-3.1-pro-preview` |
| コンテキスト | 入力 2M / 出力 65K トークン |
| 推論モード | 対応（thinking budget 設定可） |
| マルチモーダル | テキスト、画像、音声、動画、PDF |
| 強み | 最高精度、複雑な推論、コード生成 |
| 推奨場面 | 高精度が必要なタスク、複雑な分析 |

### Gemini 3.1 Flash（基本推奨）

| 項目 | 値 |
|------|-----|
| モデル ID | `gemini-3.1-flash-preview` |
| コンテキスト | 入力 1M / 出力 65K トークン |
| 推論モード | 対応（thinking budget 設定可） |
| マルチモーダル | テキスト、画像、音声、動画、PDF |
| 強み | コストと性能のバランス、高速レスポンス |
| 推奨場面 | **汎用用途のデフォルト選択** |

### Gemini 3.1 Flash Lite（基本利用推奨）

| 項目 | 値 |
|------|-----|
| モデル ID | `gemini-3.1-flash-lite-preview` |
| コンテキスト | 入力 1M / 出力 32K トークン |
| 推論モード | 非対応 |
| マルチモーダル | テキスト、画像 |
| 強み | 最速レスポンス、最低コスト |
| 推奨場面 | **大量処理、シンプルなタスク、コスト最優先** |

---

## 選択フローチャート

```
タスクの複雑さは？
├── シンプル（分類、抽出、翻訳）→ Flash Lite
├── 中程度（要約、QA、コード補完）→ Flash
└── 複雑（推論、分析、コード設計）→ Pro
    └── コスト制約がある？ → Flash + thinking mode
```

---

## 推論モード（Thinking）

Pro と Flash は推論モード（thinking）を使用して、回答前に内部で段階的推論を実行できる。

### 設定方法

```python
from google import genai
from google.genai import types

client = genai.Client(api_key="YOUR_API_KEY")

response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="17 * 23 + 42 / 6 を計算して、手順を説明して",
    config=types.GenerateContentConfig(
        thinking_config=types.ThinkingConfig(
            thinking_budget=2048  # thinking トークン数上限
        )
    )
)

# 思考プロセスと最終回答の取得
for part in response.candidates[0].content.parts:
    if part.thought:
        print(f"思考: {part.text}")
    else:
        print(f"回答: {part.text}")
```

### Thinking Budget ガイド

| 値 | 用途 |
|----|------|
| 0 | thinking 無効 |
| 1024 | 軽い推論（計算、簡単な論理） |
| 2048-4096 | 中程度の推論（数学、コード分析） |
| 8192-16384 | 深い推論（複雑な証明、設計判断） |
| -1 | 制限なし（モデルが自動判断） |

---

## マルチモーダル入力

### 画像入力

```python
from google.genai import types

response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents=[
        types.Part.from_text("この画像を説明して"),
        types.Part.from_image(types.Image.from_file("photo.jpg")),
    ]
)
```

### PDF 入力

```python
response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents=[
        types.Part.from_text("この PDF を要約して"),
        types.Part.from_uri(
            file_uri="gs://bucket/document.pdf",
            mime_type="application/pdf"
        ),
    ]
)
```

### 音声入力

```python
response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents=[
        types.Part.from_text("この音声を文字起こしして"),
        types.Part.from_uri(
            file_uri="gs://bucket/audio.mp3",
            mime_type="audio/mp3"
        ),
    ]
)
```

---

## システム指示

```python
response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="ユーザーの質問",
    config=types.GenerateContentConfig(
        system_instruction="あなたは親切な日本語アシスタントです。"
    )
)
```

---

## 構造化出力（JSON モード）

```python
import json

response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="東京の天気を教えて",
    config=types.GenerateContentConfig(
        response_mime_type="application/json",
        response_schema={
            "type": "object",
            "properties": {
                "city": {"type": "string"},
                "temperature": {"type": "number"},
                "condition": {"type": "string"}
            }
        }
    )
)
data = json.loads(response.text)
```

---

## ツール使用（Function Calling）

```python
# ツール定義
weather_tool = types.Tool(
    function_declarations=[
        types.FunctionDeclaration(
            name="get_weather",
            description="指定都市の天気を取得",
            parameters=types.Schema(
                type="object",
                properties={
                    "city": types.Schema(type="string", description="都市名")
                },
                required=["city"]
            )
        )
    ]
)

response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="東京の天気は？",
    config=types.GenerateContentConfig(
        tools=[weather_tool]
    )
)
```

---

## 3.0 / 2.5 系からの移行ガイド

### 主な変更点

| 項目 | 3.0 以前 | 3.1 |
|------|---------|-----|
| コンテキスト | Pro: 1M, Flash: 1M | Pro: 2M, Flash: 1M |
| 推論モード | Flash 非対応 | Flash も対応 |
| 出力上限 | 8K-32K | 32K-65K |
| 構造化出力 | 基本対応 | 改善（精度向上） |

### 移行手順

1. モデル ID を `gemini-3.1-*-preview` に変更
2. 推論モードの活用を検討（Flash でも使用可能に）
3. 出力上限の拡大を活用（max_output_tokens の調整）
4. テストを実行して互換性を確認
