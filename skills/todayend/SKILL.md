---
name: todayend
description: 하루 마무리. 오늘 세션 로그들을 취합해 brain/04_archive/daily에 요약 파일을 만들고, 프로젝트 문서에 변경점을 반영. 금요일엔 주간 로그도 작성.
---

# todayend

`BRAIN=/Users/hyohwan/Documents/main/brain`

하루 마지막에 사용자가 수동 호출.

## 수행 순서

1. **날짜**: `DATE=$(date +%Y-%m-%d)`.

2. **오늘 세션 로그 수집**:
   - `$BRAIN/00_inbox/sessions/${DATE}/*.md` 전부 읽기 (시각순).
   - 없으면 "오늘 세션 기록 없음." 안내 후 종료.

3. **오늘 daily plan 읽기**:
   - `$BRAIN/00_inbox/daily/${DATE}.md` 읽어 계획 대비 달성도 파악.

4. **오늘 변경 범위 효율 스캔** (병목 방지):
   - `cd $BRAIN && git log --since="today 00:00" --name-only --pretty=format:`
   - 이 목록에서 `01_projects/*/experiments/EXP-*.md`, `01_projects/*/decisions/ADR-*.md` 필터.
   - 오늘 건드린 프로젝트 목록만 추출. **전체 프로젝트 스캔 금지**.

5. **하루 요약 생성**:
   - 템플릿 `$BRAIN/03_templates/project-update.md` 치환.
   - 세션들의 "한 일" 병합, 중복 제거, 시간순 정리.
   - step 4에서 뽑은 EXP/ADR만 집계해 "## 오늘의 실험 진척", "## 오늘의 결정" 섹션 추가.
   - 저장: `$BRAIN/04_archive/daily/${DATE}.md` (이미 있으면 덮어쓰기 확인).

6. **프로젝트 반영**:
   - 오늘 변경된 `01_projects/**/*.md` 목록 제시.
   - 사용자 확인 후 각 파일 끝에 `## ${DATE} 업데이트` 섹션 추가.
   - EXP/ADR 변경이 있었던 프로젝트의 `roadmap.md` "## 최근 업데이트" 에 `- ${DATE}: <한줄>` append.

7. **금요일이면 주간 로그**:
   - `[ $(date +%u) = "5" ]` 조건 체크.
   - 상세 로직: `references/friday-weekly-log.md` 참조 (필요 시 Read).

8. **정리**:
   - 세션 로그 / daily plan 는 그대로 유지.
   - 필요 시 `/taskend` 로 git 커밋 유도.

## 주의

- 프로젝트 문서 자동 수정 금지. 반드시 확인 후.
- roadmap 업데이트는 "최근 업데이트" 섹션에만 append (마일스톤 체크박스 손대지 않음).
- 전체 프로젝트 `01_projects/*/` 전수 스캔 금지 — step 4의 git 기반 목록만 사용.
