# image-gen-gemini

Gemini CLI (Nano Banana Pro) を使用した AI 画像生成プラグイン。

## インストール

```bash
claude plugin install image-gen-gemini@cc-plugins
```

## 前提条件

### 1. Gemini CLI のインストール

```bash
npm install -g @google/gemini-cli
```

### 2. 認証設定

**方法 A: Google OAuth（推奨）**

```bash
gemini auth
```

**方法 B: API キー**

```bash
export GEMINI_API_KEY=your_api_key_here
```

## 使用方法

### コマンドで明示的に実行

```bash
# 基本的な使用
/image-gen-gemini:generate 可愛い猫の画像

# 保存先を指定
/image-gen-gemini:generate 夕焼けの風景 --output ./images/sunset.png
```

### スキルで自動発動

以下のような発言で自動的にスキルが発動:

- 「画像を生成して」
- 「イラストを作成して」
- 「〜の絵を描いて」
- 「デザインを作って」

### エージェントで複雑なタスク

複数バリエーションやデザイン提案が必要な場合:

- 「ロゴをいくつかパターン見せて」
- 「このイラストを改善して」
- 「異なるスタイルで作って」

## 機能

| コンポーネント | 説明 |
|---------------|------|
| **image-generate スキル** | テキストから画像を生成する基本機能 |
| **image-designer エージェント** | 複数バリエーション、スタイル提案、改善サイクル |
| **generate コマンド** | 明示的な画像生成 |

## プロンプトのコツ

英語のプロンプトが最も良い結果を生成します。

**良いプロンプトの要素:**

- 具体的な描写（サイズ、色、位置関係）
- スタイル指定（photorealistic, anime style, watercolor）
- 品質指定（high quality, detailed, 4K resolution）
- 構図指定（close-up, wide shot, bird's eye view）

**例:**

```
A fluffy orange cat sitting on a windowsill, looking outside at falling snow,
warm indoor lighting, photorealistic, high detail, cozy atmosphere
```

## 使用モデル

- **モデル名**: `gemini-2.0-flash-preview-image-generation`
- **別名**: Nano Banana Pro
- **特徴**: 高品質な画像生成、テキストレンダリング対応

## 制限事項

- 不適切なコンテンツは生成不可
- 著作権で保護されたキャラクターの生成は避ける
- 実在の人物の顔画像生成は推奨しない

## ライセンス

MIT
