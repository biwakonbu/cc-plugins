# web-search-codex プラグイン

Codex CLI 環境内で Gemini CLI の `google_web_search` ツールを活用した Web 検索プラグイン。

## バージョン履歴

### v1.1.0
- 情報鮮度フィルタリング機能追加
- ドメイン別鮮度基準（AI/LLM は 6ヶ月、フロントエンドは 1年等）
- AI モデル旧世代情報の自動破棄（GPT-3.5以前、Claude 2以前等）
- 出力フォーマットに鮮度マーク（✓/⚠参考/古い情報）付与
- agents/codex-researcher.md に詳細版フィルタリング追加

### v1.0.0
- 初期リリース
- `context: fork` 対応

## 概要

Codex CLI から Gemini CLI を呼び出し、Google Search によるリアルタイム Web 検索を実行する。
Codex の `--full-auto` モードと組み合わせることで、自動的な情報収集とタスク実行が可能。

## ディレクトリ構造

```
web-search-codex/
├── .claude-plugin/
│   └── plugin.json           # メタデータ
├── CLAUDE.md                 # 本ファイル
├── README.md                 # ユーザー向けドキュメント
├── commands/
│   └── search.md             # 明示的検索コマンド
├── agents/
│   └── codex-researcher.md   # 複雑調査用エージェント
└── skills/
    └── codex-web-search/
        └── SKILL.md          # Web 検索スキル
```

## コンポーネント

| 種類 | 名前 | 用途 |
|------|------|------|
| スキル | `codex-web-search` | 自動発動する Web 検索（「調べて」「検索して」） |
| エージェント | `codex-researcher` | 複雑な調査タスク（比較、分析、レポート） |
| コマンド | `/web-search-codex:search` | 明示的な検索実行 |

## アーキテクチャ

```
ユーザーリクエスト（Codex CLI 内）
    │
    ├─→ 単純な検索「〜を調べて」
    │     └─→ codex-web-search スキル（自動発動）
    │           └─→ gemini --yolo "{query}"
    │
    ├─→ 明示的な検索
    │     └─→ /web-search-codex:search
    │           └─→ codex-web-search スキル参照
    │
    └─→ 複雑な調査タスク
          └─→ Task ツール → codex-researcher エージェント
                └─→ 複数検索 + 分析 + レポート
```

## Codex CLI 統合

### Full Auto モード

```bash
codex --full-auto "TypeScript 5.0 の新機能を調べて、サンプルコードを作成"
```

Codex は自動的にスキルを使用し、検索結果を活用してタスクを完了する。

### インタラクティブモード

```bash
codex
> React 19 の新機能を検索して
# → スキルが自動発動 → Gemini CLI で検索実行
```

## Gemini CLI の使い方

### 基本コマンド

```bash
# Web 検索を確実に実行（推奨）
gemini --yolo "Use the google_web_search tool to search for: {検索クエリ}. You MUST perform a web search."
```

### Web 検索の動作

1. Gemini に明示的に `google_web_search` ツール使用を指示
2. Google Web Search を実行
3. 検索結果を要約し、ソース付きで返却

**重要**: プロンプトに「Use the google_web_search tool to search for:」を含める。
これにより Gemini が確実に Web 検索を実行する。

## 前提条件

### 必須

- **Codex CLI**: `npm install -g @openai/codex`
- **Gemini CLI**: `npm install -g @google/gemini-cli` または `brew install gemini-cli`
- **Gemini API キー**: 設定済みであること

### インストール確認

```bash
# Codex CLI
codex --version

# Gemini CLI
gemini --version
```

## 用途別ガイド

### 技術調査

- ライブラリ・フレームワークの最新情報
- API ドキュメントの検索
- エラーメッセージの解決策

### 汎用リサーチ

- 一般的なトピックの調査
- 比較分析
- 市場動向

### ニュース・最新情報

- 最新リリース情報
- 業界ニュース
- トレンド把握

## web-search-gemini との違い

| 項目 | web-search-codex | web-search-gemini |
|------|------------------|-------------------|
| 対象環境 | Codex CLI | Claude Code |
| 統合 | Codex --full-auto | Claude Code 直接 |
| フック | なし | WebSearch 誘導 |
| 用途 | Codex 内での検索 | Claude Code 内での検索 |

## 注意事項

- 機密情報を検索クエリに含めないこと
- API レート制限に注意
- 結果は要約されるため、詳細は元ソースを確認

## ドキュメント維持規則

**README.md と CLAUDE.md は常に最新状態を維持すること。**

### 更新タイミング

以下の変更時は必ずドキュメントを更新:

- コマンドの追加・変更・削除
- スキルの追加・変更・削除
- エージェントの追加・変更・削除
- plugin.json の変更（バージョン含む）
- 設計方針や動作の変更

### README.md の役割

- **対象**: ユーザー（プラグイン利用者）
- **内容**: インストール方法、使い方、機能一覧、使用例

### CLAUDE.md の役割

- **対象**: AI（Claude）と開発者
- **内容**: 設計方針、アーキテクチャ、内部構造、開発ルール
