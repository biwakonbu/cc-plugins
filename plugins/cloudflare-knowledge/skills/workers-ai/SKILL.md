---
name: workers-ai
description: Cloudflare Workers AI の完全ガイド。利用可能モデル（LLM、画像、音声、埋め込み）、
Vectorize、AI Gateway の使い方と設定を提供。
Use when user asks about Workers AI, AI models, Vectorize, AI Gateway,
LLM, image generation, speech recognition, embeddings, or RAG.
Also use when user says Workers AI, AI モデル, ベクトル検索, 埋め込み, RAG.
---

# Cloudflare Workers AI

## 概要

Workers AI は Cloudflare エッジネットワーク上でサーバーレス AI 推論を提供。
LLM、画像生成、音声認識、埋め込みなど多様なモデルをサポート。

## 設定

```toml
# wrangler.toml
[ai]
binding = "AI"
```

## 基本的な使い方

```typescript
export default {
  async fetch(request: Request, env: Env) {
    const response = await env.AI.run(
      "@cf/meta/llama-3.1-8b-instruct",
      {
        messages: [
          { role: "system", content: "You are a helpful assistant." },
          { role: "user", content: "Hello!" },
        ],
      }
    );

    return Response.json(response);
  },
};
```

---

## 利用可能モデル

### LLM（大規模言語モデル）

| モデル | パラメータ | 特徴 |
|--------|-----------|------|
| `@cf/meta/llama-4-scout-17b-16e-instruct` | 17B | マルチモーダル、MoE |
| `@cf/meta/llama-3.3-70b-instruct-fp8-fast` | 70B | 高性能 |
| `@cf/meta/llama-3.2-11b-vision-instruct` | 11B | 画像認識 |
| `@cf/meta/llama-3.2-3b-instruct` | 3B | 軽量 |
| `@cf/meta/llama-3.1-8b-instruct` | 8B | バランス型 |
| `@cf/mistral/mistral-small-3.1-24b-instruct` | 24B | 128K コンテキスト |
| `@hf/nousresearch/hermes-2-pro-mistral-7b` | 7B | Function Calling |

### 画像生成

| モデル | 特徴 |
|--------|------|
| `@cf/stabilityai/stable-diffusion-xl-base-1.0` | SDXL 基本 |
| `@cf/bytedance/stable-diffusion-xl-lightning` | 高速生成 |
| `@cf/lykon/dreamshaper-8-lcm` | 高品質 |

### 音声認識

| モデル | 特徴 |
|--------|------|
| `@cf/openai/whisper-large-v3-turbo` | 高精度、多言語 |
| `@cf/openai/whisper` | 標準 |

### 埋め込み

| モデル | 次元数 | 特徴 |
|--------|--------|------|
| `@cf/baai/bge-base-en-v1.5` | 768 | 英語特化 |
| `@cf/baai/bge-m3` | 1024 | 100言語対応 |
| `@cf/baai/bge-small-en-v1.5` | 384 | 軽量 |

### テキスト分類・翻訳

| モデル | 用途 |
|--------|------|
| `@cf/huggingface/distilbert-sst-2-int8` | 感情分析 |
| `@cf/meta/m2m100-1.2b` | 多言語翻訳 |

---

## LLM 使用例

### 基本的なチャット

```typescript
const response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
  messages: [
    { role: "system", content: "あなたは親切なアシスタントです。" },
    { role: "user", content: "東京の天気を教えて" },
  ],
  max_tokens: 256,
  temperature: 0.7,
});

console.log(response.response);
```

### ストリーミング

```typescript
const stream = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
  messages: [{ role: "user", content: "長い物語を書いて" }],
  stream: true,
});

return new Response(stream, {
  headers: { "Content-Type": "text/event-stream" },
});
```

### Function Calling

```typescript
const response = await env.AI.run(
  "@hf/nousresearch/hermes-2-pro-mistral-7b",
  {
    messages: [{ role: "user", content: "東京の天気は？" }],
    tools: [
      {
        type: "function",
        function: {
          name: "get_weather",
          description: "指定した場所の天気を取得",
          parameters: {
            type: "object",
            properties: {
              location: { type: "string", description: "場所" },
            },
            required: ["location"],
          },
        },
      },
    ],
  }
);
```

---

## 画像生成

```typescript
const response = await env.AI.run(
  "@cf/stabilityai/stable-diffusion-xl-base-1.0",
  {
    prompt: "A beautiful sunset over mountains, high quality, 4k",
    negative_prompt: "blurry, low quality",
    num_steps: 20,
    guidance: 7.5,
  }
);

return new Response(response, {
  headers: { "Content-Type": "image/png" },
});
```

---

## 音声認識

```typescript
const audioData = await request.arrayBuffer();

const response = await env.AI.run(
  "@cf/openai/whisper-large-v3-turbo",
  {
    audio: [...new Uint8Array(audioData)],
  }
);

return Response.json({
  text: response.text,
  language: response.detected_language,
});
```

---

## 埋め込み

```typescript
const response = await env.AI.run("@cf/baai/bge-base-en-v1.5", {
  text: ["Hello, world!", "How are you?"],
});

// response.data = [
//   { embedding: [0.1, 0.2, ...], shape: [768] },
//   { embedding: [0.3, 0.4, ...], shape: [768] }
// ]
```

---

## Vectorize

### 概要

エッジで動作する分散型ベクトルデータベース。RAG アプリケーション構築に最適。

### インデックス作成

```bash
# プリセット使用
wrangler vectorize create my-index \
  --preset @cf/baai/bge-small-en-v1.5

# 手動設定
wrangler vectorize create my-index \
  --dimensions 768 \
  --metric cosine
```

### 設定

```toml
# wrangler.toml
[[vectorize]]
binding = "VECTORIZE"
index_name = "my-index"
```

### ベクトル操作

```typescript
// 挿入
await env.VECTORIZE.upsert([
  {
    id: "doc-1",
    values: embedding,  // from Workers AI
    metadata: { title: "Document 1", category: "tech" },
  },
]);

// 検索
const results = await env.VECTORIZE.query(queryVector, {
  topK: 5,
  filter: { category: "tech" },
  returnMetadata: "all",
});

// 結果: results.matches = [
//   { id: "doc-1", score: 0.95, metadata: {...} },
//   ...
// ]

// 削除
await env.VECTORIZE.deleteByIds(["doc-1", "doc-2"]);
```

### RAG パターン

```typescript
export default {
  async fetch(request: Request, env: Env) {
    const { query } = await request.json();

    // 1. クエリを埋め込みに変換
    const embedResponse = await env.AI.run("@cf/baai/bge-base-en-v1.5", {
      text: [query],
    });
    const queryVector = embedResponse.data[0].embedding;

    // 2. 類似ドキュメント検索
    const results = await env.VECTORIZE.query(queryVector, {
      topK: 3,
      returnMetadata: "all",
    });

    // 3. コンテキスト構築
    const context = results.matches
      .map((m) => m.metadata?.content)
      .join("\n\n");

    // 4. LLM で回答生成
    const response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
      messages: [
        {
          role: "system",
          content: `以下のコンテキストに基づいて回答してください:\n\n${context}`,
        },
        { role: "user", content: query },
      ],
    });

    return Response.json({ answer: response.response });
  },
};
```

---

## AI Gateway

### 概要

複数の AI プロバイダー（OpenAI、Anthropic、Google など）を統合管理。
ログ、キャッシュ、レート制限、フォールバックを提供。

### 対応プロバイダー

- OpenAI
- Anthropic
- Google AI
- Groq
- DeepSeek
- Workers AI
- その他16以上

### 設定

ダッシュボードで AI Gateway を作成し、エンドポイントを取得。

### 使用例

```typescript
// AI Gateway 経由で OpenAI を呼び出し
const response = await fetch(
  "https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/openai/chat/completions",
  {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${env.OPENAI_KEY}`,
    },
    body: JSON.stringify({
      model: "gpt-4",
      messages: [{ role: "user", content: "Hello" }],
    }),
  }
);
```

### 機能

| 機能 | 説明 |
|------|------|
| **ログ** | リクエスト/レスポンスを記録 |
| **キャッシュ** | 同一リクエストのキャッシュ |
| **レート制限** | リクエスト数制限 |
| **フォールバック** | プロバイダー障害時の自動切り替え |
| **DLP** | 機密データ検出（ベータ） |

---

## 料金体系

### Workers AI

| 項目 | 無料枠 | 有料 |
|------|--------|------|
| ニューロン | 10,000/日 | $0.011/1,000ニューロン |

**ニューロン消費量**（目安）:
- LLM: 入力トークン数 × 係数
- 画像生成: 約10,000ニューロン/画像
- 埋め込み: 少量

### Vectorize

| 項目 | 無料枠 | 有料 |
|------|--------|------|
| クエリ | 30M/月 | $0.01/1M クエリ |
| ストレージ | 5M ベクトル次元 | $0.05/1M 次元月 |

---

## REST API

Workers 外からも使用可能:

```bash
curl https://api.cloudflare.com/client/v4/accounts/{account_id}/ai/run/@cf/meta/llama-3.1-8b-instruct \
  -X POST \
  -H "Authorization: Bearer {API_TOKEN}" \
  -d '{
    "messages": [
      {"role": "user", "content": "Hello"}
    ]
  }'
```

---

## ベストプラクティス

### モデル選択

| 用途 | 推奨モデル |
|------|-----------|
| 一般的なチャット | `llama-3.1-8b-instruct` |
| 高精度な回答 | `llama-3.3-70b-instruct-fp8-fast` |
| 画像理解 | `llama-3.2-11b-vision-instruct` |
| 軽量・高速 | `llama-3.2-3b-instruct` |
| Function Calling | `hermes-2-pro-mistral-7b` |

### パフォーマンス最適化

```typescript
// レスポンスをキャッシュ
const cacheKey = `ai:${hash(prompt)}`;
let response = await env.KV.get(cacheKey, "json");

if (!response) {
  response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
    messages: [{ role: "user", content: prompt }],
  });
  await env.KV.put(cacheKey, JSON.stringify(response), {
    expirationTtl: 3600,
  });
}
```

---

## 公式リソース

- [Workers AI Documentation](https://developers.cloudflare.com/workers-ai/)
- [Models Catalog](https://developers.cloudflare.com/workers-ai/models/)
- [Vectorize Documentation](https://developers.cloudflare.com/vectorize/)
- [AI Gateway Documentation](https://developers.cloudflare.com/ai-gateway/)
- [Pricing](https://developers.cloudflare.com/workers-ai/platform/pricing/)
