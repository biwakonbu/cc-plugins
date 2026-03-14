---
name: gemini-api-overview
description: Gemini API の全体概要、モデルファミリー一覧、用途別推奨モデル早見表、SDK 基本使用法を提供。Use when user asks about Gemini API overview, model selection, which Gemini model to use, Gemini model comparison, or SDK setup. Also use when user says Gemini API について, モデル選択, どのモデルを使うべき, Gemini SDK.
context: fork
---

# Gemini API Overview

Gemini API の全体像とモデル選択ナビゲーション。

---

## モデルファミリー一覧

### Gemini 3.1 系（最新・推奨）

| モデル | モデル ID | 特徴 | 推奨用途 |
|--------|----------|------|----------|
| **3.1 Pro** | `gemini-3.1-pro-preview` | 最高性能、推論モード対応 | 高精度タスク、複雑な分析 |
| **3.1 Flash** | `gemini-3.1-flash-preview` | コスト効率と性能のバランス | **汎用推奨** |
| **3.1 Flash Lite** | `gemini-3.1-flash-lite-preview` | 最速・最安 | **大量処理・基本利用推奨** |

### Gemini 3.0 系

| モデル | モデル ID | 状態 |
|--------|----------|------|
| 3.0 Pro | `gemini-3-pro` | 安定版（3.1 Pro への移行推奨） |
| 3.0 Flash | `gemini-3-flash` | 安定版（3.1 Flash への移行推奨） |

### 特殊用途モデル

| モデル | モデル ID | 用途 |
|--------|----------|------|
| Nano Banana 2 | `gemini-3-flash-image-preview` | 画像生成（Flash ベース、高速） |
| Nano Banana Pro | `gemini-3-pro-image-preview` | 画像生成（Pro ベース、高品質） |
| Veo 3.1 | `veo-3.1` | 動画生成 |
| Chirp 3 | `chirp-3` | 音声認識・TTS 専用 |

### レガシーモデル（非推奨）

- Gemini 2.5 Pro / Flash → 3.0 以降に移行すべき
- Gemini 2.0 以前 → サポート終了予定

---

## 用途別推奨モデル早見表

| 用途 | コスト優先 | パフォーマンス優先 |
|------|-----------|-------------------|
| チャット・QA | Flash Lite | Flash |
| コード生成 | Flash | Pro |
| 文書要約 | Flash Lite | Flash |
| データ分析 | Flash | Pro |
| 推論・数学 | Flash（thinking） | Pro（thinking） |
| 画像生成 | Nano Banana 2 | Nano Banana Pro |
| 音声・TTS | Flash Live | Pro Live |
| 動画生成 | Veo 3.1（短尺） | Veo 3.1（4K） |
| 翻訳 | Flash Lite | Flash |
| マルチモーダル入力 | Flash | Pro |

---

## SDK 基本使用法

### Python

```python
from google import genai

client = genai.Client(api_key="YOUR_API_KEY")

# テキスト生成
response = client.models.generate_content(
    model="gemini-3.1-flash-preview",
    contents="Hello, Gemini!"
)
print(response.text)
```

### Node.js

```typescript
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: "YOUR_API_KEY" });

// テキスト生成
const response = await ai.models.generateContent({
  model: "gemini-3.1-flash-preview",
  contents: "Hello, Gemini!",
});
console.log(response.text);
```

### REST API

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-preview:generateContent" \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -d '{"contents": [{"parts": [{"text": "Hello, Gemini!"}]}]}'
```

---

## 認証方法

| 方法 | 用途 | 設定 |
|------|------|------|
| API キー | 個人開発・プロトタイプ | `GEMINI_API_KEY` 環境変数 |
| OAuth 2.0 | ユーザー認証が必要なアプリ | Google Cloud Console で設定 |
| サービスアカウント | サーバーサイド・本番環境 | Vertex AI 経由 |

### AI Studio vs Vertex AI

| 項目 | AI Studio | Vertex AI |
|------|-----------|-----------|
| 認証 | API キー | サービスアカウント / OAuth |
| 無料枠 | あり | なし（課金必須） |
| SLA | なし | あり |
| リージョン | グローバル | リージョン指定可 |
| エンタープライズ機能 | 限定的 | フル |

---

## コンテキストウィンドウ

| モデル | 入力上限 | 出力上限 |
|--------|---------|---------|
| 3.1 Pro | 2M トークン | 65K トークン |
| 3.1 Flash | 1M トークン | 65K トークン |
| 3.1 Flash Lite | 1M トークン | 32K トークン |

---

## 関連スキル参照

- テキストモデルの詳細 → `gemini-text-models`
- 画像生成 → `gemini-image-generation`
- 音声・TTS → `gemini-audio-tts`
- 動画生成 → `gemini-video-generation`
- 価格・レート制限 → `gemini-api-pricing`
