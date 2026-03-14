# gemini-api-spec プラグイン

Gemini API の最新モデル・機能・価格に関する包括的な知識プラグイン。

## 概要

このプラグインは Gemini API に関する質問に対して自動発動し、以下の知識を提供する:

- モデルファミリー一覧と用途別推奨
- テキスト生成モデル（3.1 Pro / Flash / Flash Lite）の比較
- 画像生成モデル（Nano Banana 2 / Pro）の選択ガイド
- 音声・TTS・Live API の構成
- 動画生成（Veo 3.1）の機能と制限
- 全モデルの価格・レート制限

## ディレクトリ構造

```
gemini-api-spec/
├── .claude-plugin/
│   └── plugin.json               # メタデータ
├── CLAUDE.md                     # 本ファイル
└── skills/
    ├── gemini-api-overview/
    │   └── SKILL.md              # 全体概要・ナビゲーション
    ├── gemini-text-models/
    │   └── SKILL.md              # テキスト生成モデル
    ├── gemini-image-generation/
    │   └── SKILL.md              # 画像生成ガイド
    ├── gemini-audio-tts/
    │   └── SKILL.md              # 音声・TTS・Live API
    ├── gemini-video-generation/
    │   └── SKILL.md              # 動画生成（Veo 3.1）
    └── gemini-api-pricing/
        └── SKILL.md              # 価格・レート制限
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `gemini-api-overview` | Gemini API 全体概要とモデル選択ナビゲーション |
| スキル | `gemini-text-models` | テキスト生成モデルの詳細比較 |
| スキル | `gemini-image-generation` | 画像生成モデルの選択ガイド |
| スキル | `gemini-audio-tts` | 音声・TTS・Live API ガイド |
| スキル | `gemini-video-generation` | 動画生成（Veo 3.1）ガイド |
| スキル | `gemini-api-pricing` | 全モデル価格・レート制限一覧 |

## 設計方針

### シンプルさ優先

- 知識スキルのみで構成
- コマンドやエージェントは含めない
- 軽量で高速な発動

### context: fork の活用

全スキルに `context: fork` を設定。大規模な知識コンテンツがサブエージェント化され、メインコンテキストを保護。

### モデル推奨方針

- **テキスト**: Flash / Flash Lite を基本推奨、Pro は高精度が必要な場合
- **画像**: Nano Banana 2 をデフォルト推奨、Pro はユーザー明示時のみ
- **音声/動画**: コスト優先とパフォーマンス優先の両軸で推奨を分離

### 自動発動トリガー

以下のキーワードで発動:

- 「Gemini API」「Gemini モデル」
- モデル名（gemini-3.1-pro, flash, flash-lite）
- 「画像生成」「TTS」「音声」「動画生成」
- 「価格」「レート制限」「料金」

## 関連プラグイン

- `gemini-cli-spec`: Gemini CLI の使い方（API ではなく CLI 操作）
- `nano-banana-image`: 画像生成の実行プラグイン（本プラグインはナレッジ提供）

## 前提条件

このプラグインは知識提供のみ。Gemini API の実際の使用には以下が必要:

- Google AI Studio または Vertex AI のアカウント
- API キーまたはサービスアカウント認証

## ドキュメント維持規則

プラグイン変更時は以下を必ず更新:

- CLAUDE.md: 設計方針と内部構造
- plugin.json: バージョン番号
