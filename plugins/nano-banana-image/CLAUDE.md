# nano-banana-image プラグイン

Gemini Nano Banana Pro（gemini-3-pro-image-preview）を活用した画像生成プラグイン。

## 概要

Gemini API の画像生成モデルを使用して、テキストプロンプトから高品質な画像を生成する。
解像度・アスペクト比の指定、参照画像を使った編集にも対応。

## 対応モデル

| 項目 | 内容 |
|------|------|
| モデル名 | `gemini-3-pro-image-preview`（Nano Banana Pro） |
| 解像度 | 1K, 2K, 4K |
| アスペクト比 | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 |
| 参照画像 | 最大14枚 |
| 特徴 | SynthID 透かし埋め込み、高度な推論、プロフェッショナルアセット制作向け |

## コマンド

| コマンド | 説明 |
|---------|------|
| `/nano-banana-image:generate` | プロンプトから画像を生成（解像度・アスペクト比指定可能） |

## スキル

| スキル | 説明 |
|--------|------|
| `image-generation` | 画像生成リクエストを自動検出して実行 |

## 使用方法

### コマンドによる明示的な実行

```
/nano-banana-image:generate "A serene Japanese garden with cherry blossoms" --aspect 16:9 --resolution 2K
```

### スキルによる自動発動

以下のような発話で自動的にスキルが発動:
- 「画像を生成して」
- 「イラストを作成して」
- 「絵を描いて」
- 「Generate an image of...」

## 前提条件

- Gemini CLI がインストールされていること
- API キーが設定済みであること
- gemini-3-pro-image-preview モデルへのアクセス権限

## ディレクトリ構造

```
nano-banana-image/
├── .claude-plugin/
│   └── plugin.json           # プラグインメタデータ
├── CLAUDE.md                 # このファイル
├── commands/
│   └── generate.md           # 明示的画像生成コマンド
└── skills/
    └── image-generation/
        └── SKILL.md          # 自動発動する画像生成スキル
```
