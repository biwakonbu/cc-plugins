---
description: Gemini CLI (Nano Banana Pro) で画像を生成する。Use when user explicitly wants to generate images with Gemini.
allowed-tools: Bash, Read, Write, Glob, AskUserQuestion
argument-hint: [画像の説明] [--output 保存先]
---

# Image Generate

`image-generate` スキルに従って画像を生成してください。

## 引数

プロンプト: $ARGUMENTS

## 実行手順

1. 引数が空の場合は、何を生成するか確認する
2. `--output` または `-o` オプションで保存先が指定されているか確認
3. 保存先が指定されていない場合は、AskUserQuestion でユーザーに確認
4. `image-generate` スキルの手順に従って画像を生成
5. 生成結果（ファイルパス、サイズ）を報告
