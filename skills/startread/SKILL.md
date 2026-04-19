---
name: startread
description: 세션 시작 시 직전 세션 로그와 오늘 daily plan을 읽어 컨텍스트를 복원합니다. SessionStart hook이 자동으로 호출하거나 사용자가 수동으로 호출할 수 있습니다.
---

# startread

`BRAIN=/Users/hyohwan/Documents/main/brain`

세션 시작 시 이전 작업 컨텍스트를 복원하는 skill.

## 수행 순서

1. **오늘 날짜 확인**: `date +%Y-%m-%d`로 오늘 날짜 확보.

2. **오늘 daily plan 확인**:
   - `$BRAIN/00_inbox/daily/YYYY-MM-DD.md` 존재 여부 확인.
   - 있으면 전체 읽어서 오늘의 목표/진행 상황 파악.
   - 없으면 "오늘 아직 daily plan 없음. `/todaystart`로 하루 시작하세요." 안내.

3. **직전 세션 로그 읽기**:
   - 세션 로그는 `00_inbox/sessions/YYYY-MM-DD/HHMM.md` 구조.
   - 최신 날짜 폴더 찾기: `ls -1d $BRAIN/00_inbox/sessions/*/ 2>/dev/null | sort | tail -1`.
   - 그 폴더 안 최신 파일: `ls -1t <latest_folder>*.md | head -1`.
   - 이 파일 1개만 읽기. 폴더/파일 없으면 스킵.

4. **결과 요약**:
   - 읽은 내용에서 "다음 세션으로 넘기는 컨텍스트", "미해결/블로커", 오늘 plan의 "진행 중" 항목을 추출해 사용자에게 2~5줄로 브리핑.

## 주의

- 조용히(자동 호출 시) 실행 후 간결히 요약만 제시. 추측/추가 작업 시작하지 않음.
- 파일이 전혀 없으면 "깨끗한 상태로 시작합니다." 한 줄만 출력.
