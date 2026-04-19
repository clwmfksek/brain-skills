#!/bin/bash
# Stop hook — Claude가 응답을 끝낼 때마다 fire.
# brain 저장소에 커밋되지 않은 변경이 있으면 taskend skill 제안.
# 5분 throttle로 스팸 방지.

BRAIN="/Users/hyohwan/Documents/main/brain"

if [ ! -d "$BRAIN/.git" ]; then
  exit 0
fi

cd "$BRAIN" 2>/dev/null || exit 0

DIRTY=$(git status --porcelain 2>/dev/null)
if [ -z "$DIRTY" ]; then
  exit 0
fi

# 변경 파일 3개 미만이면 알림 스킵 (사소한 변경에 시끄럽지 않게)
DIRTY_COUNT=$(printf '%s\n' "$DIRTY" | wc -l | tr -d ' ')
if [ "$DIRTY_COUNT" -lt 3 ]; then
  exit 0
fi

# Session ID from stdin
PAYLOAD=$(cat)
SESSION=$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "unknown")

MARKER="/tmp/claude-taskend-notified-${SESSION}"

# 10분(600초) 이내 이미 알렸으면 스킵
if [ -f "$MARKER" ]; then
  AGE=$(( $(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || echo 0) ))
  if [ "$AGE" -lt 600 ]; then
    exit 0
  fi
fi

touch "$MARKER"

# 변경 요약
SUMMARY=$(echo "$DIRTY" | head -10)

cat <<EOF
[auto-skill-trigger: taskend]
brain 저장소에 커밋되지 않은 변경사항이 있습니다:
---
$SUMMARY
---
사용자의 작업이 한 단락 끝난 것 같으면 \`taskend\` skill을 invoke하여 커밋/푸시/PR 여부를 확인하세요.
(10분에 한 번 / 변경 파일 3개 이상일 때만 알림. 지금 묻기 어색하면 다음 턴까지 기다려도 됩니다.)
EOF

exit 0
