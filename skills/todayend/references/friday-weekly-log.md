# 금요일 주간 로그 작성

todayend step 7 에서 참조.

## 실행 조건

- `date +%u` == `5` (금요일).
- 다른 요일이면 이 파일 읽지 않음.
- 사용자가 "`/todayend weekly`" 로 강제 요청 시 금요일 아니어도 실행 가능.

## 주 범위 계산

macOS:
```bash
MONDAY=$(date -v-mon +%Y-%m-%d)   # 해당 주 월요일
FRIDAY=$(date -v+fri +%Y-%m-%d)   # 해당 주 금요일
WEEK=$(date +%V)                   # ISO 주 번호 (01~53)
YEAR=$(date +%Y)
```

Python fallback:
```python
from datetime import date, timedelta
today = date.today()
monday = today - timedelta(days=today.weekday())
friday = monday + timedelta(days=4)
year, week, _ = today.isocalendar()
```

## 프로젝트 범위

오늘의 git 기반 변경 파일 목록(todayend step 4)에서 `01_projects/<PROJECT>/` 경로만 추출 → 이번 주 활동한 프로젝트.

각 프로젝트에 대해 반복 수행.

## 소스 데이터 수집 (각 프로젝트별)

- 이번 주 `$BRAIN/04_archive/daily/*.md` 에서 날짜 범위 맞는 파일들.
- `git log --since="$MONDAY" --until="$FRIDAY 23:59" --name-only` 에서 해당 프로젝트 경로 필터.
- 해당 프로젝트 `experiments/EXP-*.md` / `decisions/ADR-*.md` 중 이번 주 변경된 것.

## 주간 로그 작성

1. 템플릿 `$BRAIN/03_templates/weekly-log.md` 읽기.
2. 치환:
   - `{{YEAR}}` → 2026
   - `{{WEEK}}` → 16 (2자리)
   - `{{PROJECT}}` → 프로젝트명
   - `{{MONDAY}}` / `{{FRIDAY}}` → ISO 날짜
3. 섹션별 채우기:
   - **이번 주 한 일**: daily 요약의 "오늘 한 일" 병합 + 중복 제거.
   - **진척 실험/결정**: 주간 변경된 EXP/ADR wikilink + 상태 변화.
   - **마일스톤 진척**: 해당 프로젝트 `roadmap.md` 의 `- [x]` 변화 감지 (이번 주에 체크된 항목).
   - **블로커**: daily들의 "블로커" 섹션 합집합.
   - **다음 주 계획**: daily의 "내일 이어갈 것" 중 이번 주 내 해결 못한 것.
4. 저장: `$BRAIN/01_projects/<PROJECT>/logs/${YEAR}-W${WEEK}.md`.
5. 이미 있으면 사용자 확인 후 덮어쓰기.

## 완료 안내

"주간 로그 생성: `logs/${YEAR}-W${WEEK}.md` (프로젝트 N개)" 사용자에게 출력.
