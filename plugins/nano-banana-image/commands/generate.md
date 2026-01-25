---
allowed-tools: Bash
argument-hint: <prompt> [--aspect 16:9] [--resolution 2K]
description: Nano Banana Pro で画像を生成する
---

# Image Generation Command

Gemini Nano Banana Pro（gemini-3-pro-image-preview）を使用して画像を生成する。

## 引数

```
$ARGUMENTS
```

## 対応オプション

| オプション | 値 | デフォルト |
|-----------|-----|-----------|
| --aspect | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 | 1:1 |
| --resolution | 1K, 2K, 4K | 2K |

## 実行手順

1. 引数からプロンプトとオプションを解析する
2. 英語のプロンプトが推奨されるため、必要に応じて翻訳する
3. 以下の形式で Gemini CLI を実行:

```bash
gemini --yolo --model gemini-3-pro-image-preview "Generate an image [with {aspect} aspect ratio] [at {resolution} resolution]: {prompt}"
```

4. 生成結果をユーザーに報告する

## 使用例

### 基本的な使用

```
/nano-banana-image:generate "A cute cat sitting on a windowsill"
```

### アスペクト比指定

```
/nano-banana-image:generate "A mountain landscape at dawn" --aspect 16:9
```

### 解像度指定

```
/nano-banana-image:generate "A detailed portrait" --resolution 4K
```

### 日本語での指示

```
/nano-banana-image:generate "桜が満開の日本庭園" --aspect 3:2 --resolution 2K
```

## 注意事項

- Gemini CLI がインストールされていること
- API キーが設定されていること
- 不適切なコンテンツの生成は拒否される
