---
name: endwrite
description: 세션 종료 직전 이번 세션 요약을 brain/00_inbox/sessions에 저장하고 종료 잠금을 해제합니다. exit/clear/compact 전에 반드시 실행.
---

# endwrite

`BRAIN=/Users/hyohwan/Documents/main/brain`

세션 종료 전 작업 요약 저장. UserPromptSubmit hook이 종료 명령을 차단하며 이 skill을 유도합니다.

## 수행 순서

1. **시각/세션 ID**:
   - `DATE=$(date +%Y-%m-%d)`, `HM=$(date +%H%M)`.
   - `SESSION_ID` 환경변수 또는 `${DATE}-${HM}` 대체.

2. **세션 요약 작성**:
   - 수행 작업·변경 파일·커밋·블로커를 5~15줄 정리.
   - touch한 `$BRAIN/01_projects/*/experiments/EXP-*.md`, `$BRAIN/01_projects/*/decisions/ADR-*.md` → `[[EXP-NNN]]`, `[[ADR-NNN]]` wikilink로 "변경된 파일" 섹션에 기록.
   - "이렇게 정리되었습니다. 맞나요?" 1회 확인.

3. **새 EXP/ADR 후보 감지** (조건부 확장):
   - 이번 세션에서 **실제로 실험/결정 키워드가 구체적으로 논의된 경우**에만 진행.
   - 확신 낮으면 스킵. 세션당 최대 2개.
   - 상세 로직: `references/exp-adr-detection.md` 참조 (필요 시에만 Read).

4. **파일 저장**:
   - 템플릿 `$BRAIN/03_templates/session-log.md` 읽어 치환.
   - 폴더 `$BRAIN/00_inbox/sessions/${DATE}/` (`mkdir -p` 필요).
   - 파일명 `${HM}.md` (충돌 시 `${HM}-${SESSION_ID:0:6}.md`).
   - frontmatter에 `date`/`session`/`started`/`ended` 채움.

5. **종료 잠금 해제**:
   - `touch /tmp/claude-endwrite-done-$CLAUDE_SESSION_ID`.
   - 이 마커가 있으면 pre-exit-check hook이 다음 종료 명령 통과시킴.

6. **완료 메시지**:
   - "세션 로그 저장 완료: `sessions/${DATE}/${HM}.md`. 이제 `/clear`/`exit` 가능합니다."
   - 새 EXP/ADR 생성됐으면 경로도 출력.

## 주의

- 사용자 수정 요청 시 다시 쓰고 확인 후 저장.
- 저장 실패 시 마커 남기지 않음.
- EXP/ADR 자동 생성 금지. 반드시 y/n 확인 후.
