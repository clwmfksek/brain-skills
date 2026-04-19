---
name: taskend
description: 한 작업(질문/턴)이 끝날 때 brain 저장소의 변경사항을 커밋/푸시/PR할지 사용자에게 확인합니다. Stop hook이 brain에 dirty가 있을 때 자동 호출하거나 사용자가 수동 호출할 수 있습니다.
---

# taskend

`BRAIN=/Users/hyohwan/Documents/main/brain`

작업 단위 완료 시 git 작업을 자동화하는 skill.

## 실행 모델

**git 상태 분석·커밋 메시지 생성**은 Sonnet subagent 위임:
```
Agent(subagent_type="oh-my-claudecode:executor", model="sonnet",
      description="taskend: git 커밋/푸시 준비",
      prompt="<수행 순서 1~2 + $BRAIN>")
```
subagent가 변경 요약·커밋 메시지 초안을 반환. **y/n/p 선택, 실제 commit/push/PR 실행은 메인 Claude** (사용자 승인 직접 받기).

## 전제

- 대상 저장소: `$BRAIN/`
- 이 저장소는 GitHub에 연결되어 있음 (첫 설정에서 생성됨).

## 수행 순서

1. **변경 확인**:
   - `cd $BRAIN && git status --porcelain`.
   - 비어있으면 "커밋할 변경사항 없음." 출력 후 종료.

2. **변경 요약 제시**:
   - `git diff --stat` 결과와 주요 변경 파일명, 한 줄 요약 3~5개 제시.

3. **사용자 확인**:
   - "커밋할까요? (y=커밋+푸시 / n=스킵 / p=PR 생성)"
   - y: 일반 커밋 + push to origin/main.
   - p: 새 브랜치 만들어 커밋 후 `gh pr create`.
   - n: 종료.

4. **커밋 메시지 생성**:
   - Conventional style: `docs:`, `chore:`, `feat:` 등 자동 선택.
   - 메시지 제시하고 수정 여부 물음.
   - HEREDOC으로 commit 실행.

5. **푸시 / PR**:
   - y: `git push origin main` (또는 현재 브랜치).
   - p: 브랜치명 제안 (예: `update/YYYY-MM-DD-topic`) 후 push + `gh pr create`.

6. **결과 보고**:
   - 커밋 해시, 푸시 상태, PR URL (있으면).

## 주의

- `git add -A` 대신 파일명 명시 또는 `git add .` (brain 전체는 노트라 안전).
- 민감 파일 없는지 확인 (.env 등은 brain에 둘 이유 없지만 체크).
- `--no-verify` 금지, hook 실패 시 원인 파악 후 재시도.
- 자동 호출일 경우 반드시 사용자 확인 받고 실행 (Stop hook이 reminder만 injection함).
