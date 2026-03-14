# gemini-api-spec

Gemini API の最新モデル・機能・価格に関する包括的な知識プラグイン。

## 概要

このプラグインは Gemini API に関する質問に対して自動的に発動し、以下の知識を提供します:

- モデルファミリー一覧と用途別推奨
- テキスト生成モデル（3.1 Pro / Flash / Flash Lite）の比較
- 画像生成モデル（Nano Banana 2 / Pro）の選択ガイド
- 音声・TTS・Live API の構成
- 動画生成（Veo 3.1）の機能と制限
- 全モデルの価格・レート制限

## インストール

```bash
/plugin install gemini-api-spec@cc-plugins
```

## 使い方

プラグインをインストールすると、Gemini API に関する質問で自動的に知識が提供されます。

### 発動例

- 「Gemini API のモデルを教えて」
- 「Flash と Pro の違いは？」
- 「Gemini の画像生成モデルはどれがいい？」
- 「TTS の使い方」
- 「Veo で動画を生成したい」
- 「Gemini API の料金は？」

### 提供される知識

#### モデル推奨

| 用途 | コスト優先 | パフォーマンス優先 |
|------|-----------|-------------------|
| チャット・QA | Flash Lite | Flash |
| コード生成 | Flash | Pro |
| 画像生成 | Nano Banana 2 | Nano Banana Pro |
| 音声・TTS | Flash Live | Pro Live |
| 動画生成 | Veo 3.1（短尺） | Veo 3.1（4K） |

#### スキル一覧

| スキル | 説明 |
|--------|------|
| `gemini-api-overview` | 全体概要・モデル選択ナビゲーション |
| `gemini-text-models` | テキスト生成モデル詳細比較 |
| `gemini-image-generation` | 画像生成モデル選択ガイド |
| `gemini-audio-tts` | 音声・TTS・Live API ガイド |
| `gemini-video-generation` | 動画生成（Veo 3.1）ガイド |
| `gemini-api-pricing` | 価格・レート制限一覧 |

## 関連プラグイン

- **gemini-cli-spec**: Gemini CLI の使い方（API ではなく CLI 操作）
- **nano-banana-image**: 画像生成の実行プラグイン（本プラグインはナレッジ提供）

## 前提条件

このプラグインは知識提供のみです。Gemini API を実際に使用するには以下が必要です:

- Google AI Studio または Vertex AI のアカウント
- API キーまたはサービスアカウント認証

## ライセンス

MIT
