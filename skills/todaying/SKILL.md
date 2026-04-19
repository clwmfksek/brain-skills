---
name: todaying
description: 세션 중간 진척도 체크. 오늘 daily plan 체크리스트 + 오늘 세션 로그 + 오늘 git 커밋을 종합해서 완료/진행 후보를 제시하고, 사용자 확인 후 plan을 업데이트합니다.
---

# todaying

`BRAIN=/Users/hyohwan/Documents/main/brain`

세션 중간에 사용자가 수동 호출. "오늘 얼마나 했지?" 확인.

## 실행 모델

근거 수집/진척도 분석까지 Sonnet subagent 위임:
```
Agent(subagent_type="oh-my-claudecode:executor", model="sonnet",
      description="todaying: 진척도 분석",
      prompt="<수행 순서 1~3 + $BRAIN + 오늘 날짜>")
```
subagent는 분석 결과(완료 후보 목록, 상태 요약)를 반환. **완료 체크/새 task 추가 등 y/n 확인(step 4~5)은 메인 Claude가 처리**. 승인된 편집만 subagent가 수행 또는 메인이 직접.

## 수행 순서

1. **오늘 daily plan 읽기**
   - `$BRAIN/00_inbox/daily/${DATE}.md` 읽기.
   - 없으면 "오늘 plan이 없습니다. `/todaystart`부터 실행하세요." 안내 후 종료.

2. **진행 근거 수집**
   - 오늘 세션 로그: `$BRAIN/00_inbox/sessions/${DATE}/*.md` 시간순 읽기.
   - 오늘 커밋 목록: `cd $BRAIN && git log --since="today 00:00" --oneline`.
   - 오늘 변경된 파일: 위 커밋들에서 `git show --name-only <hash>` 수집.
   - 진행 중 실험: `01_projects/*/experiments/*.md` 에서 `status: running` 파일 중 오늘 변경된 것.

3. **진척도 분석**
   - 전체 task 수 / `- [x]` 체크된 task 수 집계.
   - 커밋/변경 파일/세션 로그의 "한 일" 과 매칭되는 미완료 task를 "완료 후보"로 추출.

4. **사용자에게 보고 및 확인**
   - 상태 요약: "완료 n / 진행 중 m / 남음 k"
   - **진행 중 실험 현황**: running 실험이 있으면 1~2줄로 "`[[EXP-NNN]]` 진행 중, 결과 반영할까요?" 질문.
   - 완료 후보 각각을 한 줄씩 확인:
     "`[ ] X` → 완료로 체크? (y/n)"
   - 새 task 유도: "지금 추가할 task나 떠오른 블로커 있나요?"

5. **plan 업데이트 (사용자 확인 후에만)**
   - 승인된 항목 `- [ ]` → `- [x]` 변경.
   - "## 진행 중 메모"에 타임스탬프 prefix로 append:
     `- (HH:MM) <한 줄 요약>`
   - 새 task가 있으면 "## 오늘 할 일"에 append.
   - "## 블로커 / 질문"에 새 블로커 있으면 추가.

6. **남은 시간 우선순위 제안**
   - 남은 task 중 블로커/의존성/마감 있는 항목 먼저.
   - 시간 추정은 하지 않음 (근거 없음).

## 주의

- plan 파일 수정은 반드시 사용자 승인 후.
- 완료 판정을 자동으로 하지 않음. 반드시 1개씩 y/n 확인.
- 여러 번 `/todaying` 호출 시 "진행 중 메모"에 타임스탬프로 히스토리 남기기.
- 세션 로그 경로가 `sessions/${DATE}/*.md` 구조임을 유의 (날짜 폴더).
