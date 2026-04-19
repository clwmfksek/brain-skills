#!/bin/bash
# UserPromptSubmit hook — 세션 종료 의도 감지 시 endwrite skill 실행 유도.
# stdin JSON: {"session_id": "...", "prompt": "...", ...}
# 슬래시 명령(/clear, /compact)은 harness가 먼저 처리해 여기 안 올 수 있음.
# 따라서 텍스트형 "exit", "quit", "종료" 등을 주로 감지하고,
# 슬래시 명령은 best-effort로 시도.

PAYLOAD=$(cat)
PROMPT=$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null || echo "")
SESSION=$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "unknown")

# 종료 의도 패턴 (대소문자 무시)
TRIMMED=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

case "$TRIMMED" in
  /clear|/compact|/exit|/quit|exit|quit|"세션 종료"|"종료"|"끝"|"끝내자")
    MARKER="/tmp/claude-endwrite-done-${SESSION}"
    if [ ! -f "$MARKER" ]; then
      cat <<EOF
[auto-skill-trigger: endwrite — HIGH PRIORITY]
사용자가 세션 종료 의도를 표현했지만 이번 세션의 endwrite가 아직 실행되지 않았습니다.
"$PROMPT" 명령을 실제로 수행하기 전에 반드시 다음을 수행:
1. \`endwrite\` skill을 즉시 invoke하여 이번 세션 요약을 /Users/hyohwan/Documents/main/brain/00_inbox/sessions/ 에 저장.
2. endwrite가 끝나면 사용자에게 "세션 요약 저장 완료. 다시 '$PROMPT' 를 입력하면 종료됩니다." 안내.
3. endwrite가 touch /tmp/claude-endwrite-done-${SESSION} 마커를 만들면 두 번째 입력 때 이 hook이 통과시킵니다.
EOF
    fi
    ;;
esac

exit 0
