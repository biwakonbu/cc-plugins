# Protected Branch Confirmation

前のフックの出力を確認してください。

## 判定ルール

- `CONFIRM_REQUIRED` が含まれている場合 → ユーザーに確認を求める
- それ以外 → `proceed` を返す

## 確認方法

AskUserQuestion ツールを使用:

- 質問: 「main/develop ブランチへの直接 commit/push は推奨されません。続行しますか？」
- 選択肢:
  - 「続行する」→ `proceed` を返す
  - 「キャンセル」→ `block` を返す
