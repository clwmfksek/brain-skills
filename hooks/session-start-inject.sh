#!/bin/bash
# SessionStart hook — brain vault 워크플로우를 위해 startread skill 호출을 유도.
# stdin JSON은 무시해도 됨. stdout이 세션 컨텍스트로 injection됨.

cat <<'EOF'
[auto-skill-trigger: startread]
새 세션이 시작되었습니다. brain 워크플로우가 활성화된 프로젝트입니다.
즉시 `startread` skill을 invoke하여 다음을 수행하세요:
1. /Users/hyohwan/Documents/main/brain/00_inbox/sessions/YYYY-MM-DD/ 구조에서 최신 날짜 폴더 → 그 안 최신 파일 1개 읽기
2. /Users/hyohwan/Documents/main/brain/00_inbox/daily/$(date +%Y-%m-%d).md 있으면 읽기
3. 사용자에게 2~5줄로 컨텍스트 브리핑 후 대기
사용자 질문에 답변하기 전에 먼저 실행하세요.
EOF

exit 0
