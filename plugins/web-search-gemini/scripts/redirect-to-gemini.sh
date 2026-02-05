#!/bin/bash

# Gemini CLI の利用可能性チェック
if ! command -v gemini &>/dev/null; then
  # Gemini が利用不可 → WebSearch を許可
  exit 0
fi

# Gemini が利用可能 → 誘導メッセージを返してブロック
cat <<'EOF'
{
  "decision": "block",
  "systemMessage": "WebSearch の代わりに Gemini search スキル (web-search-gemini:web-search) を使用してください。Gemini CLI の google_web_search ツールを活用することで、より効率的に Web 検索が実行できます。\n\n使用方法: Skill ツールで skill: \"web-search-gemini:web-search\" を呼び出すか、「〜を調べて」「〜を検索して」と言うと自動発動します。"
}
EOF
exit 0
