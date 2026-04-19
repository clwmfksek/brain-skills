---
name: todaystart
description: 하루 시작 시 수동 호출. archive/daily의 최근 요약과 roadmap/진행중 실험을 읽고 오늘 daily plan을 생성.
---

# todaystart

`BRAIN=/Users/hyohwan/Documents/main/brain`

## 실행 모델

Sonnet subagent 위임 권장:
```
Agent(subagent_type="oh-my-claudecode:executor", model="sonnet",
      description="todaystart: 오늘 plan 생성",
      prompt="<수행 순서 1~6 + $BRAIN>")
```
subagent가 archive/roadmap 스캔 + plan 초안 생성. 메인 Claude는 브리핑(step 7)과 "수정할 것" 사용자 입력만 처리.

## 수행 순서

1. **날짜**: `DATE=$(date +%Y-%m-%d)`.

2. **중복 확인**:
   - `$BRAIN/00_inbox/daily/${DATE}.md` 있으면 "오늘 plan 이미 존재. 덮어쓸까요?" 확인.

3. **어제 요약 읽기**:
   - `ls -1t $BRAIN/04_archive/daily/*.md 2>/dev/null | head -1` → 최신 파일 1개 읽기.
   - 없으면 스킵.

4. **roadmap 훑기** (프로젝트 hub):
   - `Glob "01_projects/*/roadmap.md"` → 파일 목록.
   - 각 파일 상단 + "## 마일스톤" 섹션만 읽기 (전체 읽지 않음).
   - 체크 안 된 마일스톤 상위 3개 추출.

5. **진행 중 실험 / 대기 ADR 효율 스캔** (병목 방지):
   - `Grep "^status: running" --glob "01_projects/*/experiments/*.md" -l --files-with-matches` → 파일 경로만.
   - 상위 3개만 `Read` 로 frontmatter + H1 읽기 (본문 전체는 읽지 않음).
   - decisions도 동일하게 `status: proposed` 로 Grep.
   - **각 파일을 개별 Read 하는 방식 금지**. Grep -l 로 먼저 좁히고 상위만 읽기.

6. **오늘 daily plan 생성**:
   - 템플릿 `$BRAIN/03_templates/daily-plan.md` 읽어 `{{DATE}}` 치환.
   - 어제 요약의 "내일 이어갈 것" + 미해결을 "오늘 할 일"로 옮김.
   - 하단 섹션 자동 삽입:
     ```
     ## 이번 분기 마일스톤 (roadmap)
     - [[M?]] ...
     ## 진행 중 실험
     - [[EXP-NNN]] ...
     ## 대기 ADR
     - [[ADR-NNN]] ...
     ```
   - 저장: `$BRAIN/00_inbox/daily/${DATE}.md`.

7. **브리핑**:
   - 어제 핵심 3줄, 진행 중 실험/ADR 요약, 오늘 제안 task 3~5개.
   - "수정/추가할 것 있나요?" 물어봄.

## 주의

- Grep 먼저, Read 나중. 파일 개별 Read는 최대 5개 이내.
- 프로젝트 문서 훑기는 파일 상단/섹션만. 전체 읽기 금지.
