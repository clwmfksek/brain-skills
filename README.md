# Claude Code Brain Skills — 사용 가이드

Obsidian vault("brain")을 Claude Code의 작업 메모리로 쓰는 skill 묶음입니다.

## 🎯 개요

하루/세션 단위로 작업을 자동 기록하고, 프로젝트 문서·실험·의사결정을 구조화하여 컨텍스트 손실 없이 이어갑니다.

### 제공 스킬

| 스킬 | 호출 방식 | 역할 |
|---|---|---|
| `startread` | SessionStart hook이 자동 | 직전 세션 로그 + 오늘 daily plan 읽기 |
| `todaystart` | 수동 `/todaystart` | 어제 요약 + roadmap/실험 훑고 오늘 plan 생성 |
| `todaying` | 수동 `/todaying` | 세션 중간 진척도 체크, plan 업데이트 |
| `endwrite` | 종료 명령 시 hook이 유도 | 세션 요약 저장, 새 EXP/ADR 후보 감지 |
| `todayend` | 수동 `/todayend` | 오늘 세션들 취합 → archive daily. 금요일이면 주간 로그 |
| `taskend` | Stop hook이 조건부 / 수동 | brain git 커밋·푸시·PR 확인 |

### 제공 hook

| Hook | 이벤트 | 역할 |
|---|---|---|
| `session-start-inject.sh` | SessionStart | startread skill 유도 |
| `pre-exit-check.sh` | UserPromptSubmit | `/clear`·`/compact`·`exit`·`quit` 차단, endwrite 유도 |
| `task-end-check.sh` | Stop | brain에 dirty + 변경 파일 ≥3개 시 10분 throttle로 taskend 제안 |

---

## 📁 필요한 Vault 폴더 구조

이 skills는 아래 구조를 가정합니다. 없으면 첫 사용 전에 만들어야 합니다.

```
<BRAIN_ROOT>/                         # 예: /Users/<you>/Documents/brain
├── 00_inbox/
│   ├── daily/                        # 오늘 진행 중 plan: YYYY-MM-DD.md
│   └── sessions/                     # 세션 로그 (날짜별 폴더)
│       └── YYYY-MM-DD/               # endwrite가 자동 생성
│           └── HHMM.md
├── 01_projects/
│   └── <project_name>/               # 예: buddydoc_rnd
│       ├── overview.md
│       ├── architecture.md
│       ├── pipeline.md
│       ├── roadmap.md                # 마일스톤 + 최근 업데이트 hub
│       ├── experiments/              # EXP-NNN-<slug>.md
│       ├── decisions/                # ADR-NNN-<slug>.md
│       ├── logs/                     # YYYY-WNN.md (주간 로그)
│       ├── metrics/
│       ├── milestones/               # 마일스톤별 상세
│       └── decisions/
├── 02_knowledge/
├── 03_templates/                     # 필수 템플릿 (아래 참고)
│   ├── daily-plan.md
│   ├── session-log.md
│   ├── project-update.md
│   ├── experiment.md
│   ├── adr.md
│   └── weekly-log.md
└── 04_archive/
    └── daily/                        # todayend 결과: YYYY-MM-DD.md
```

### 파일 네이밍 규칙

| 항목 | 형식 | 예 |
|---|---|---|
| Daily plan | `YYYY-MM-DD.md` | `2026-04-19.md` |
| Session log | `HHMM.md` (날짜 폴더 내) | `1430.md` |
| Daily archive | `YYYY-MM-DD.md` | `2026-04-19.md` |
| Experiment | `EXP-NNN-<slug>.md` | `EXP-007-rag-chunking.md` |
| ADR | `ADR-NNN-<slug>.md` | `ADR-003-vector-db.md` |
| Weekly log | `YYYY-WNN.md` | `2026-W16.md` |
| Milestone | `M<N>-<slug>.md` | `M1-alpha-release.md` |

---

## 🛠️ 설치

### 1. Vault 준비

위 폴더 구조를 원하는 경로에 만듭니다. 예:

```bash
BRAIN=~/Documents/brain
mkdir -p $BRAIN/{00_inbox/{daily,sessions},02_knowledge,03_templates,04_archive/daily}
mkdir -p $BRAIN/01_projects/<your_project>/{experiments,decisions,logs,metrics,milestones}
```

`03_templates/` 에 6개 템플릿 파일이 필요합니다. 이 repo의 `templates/` 폴더 또는 소유자의 brain에서 복사.

### 2. Skills & Hooks 배치

이 repo의 `.claude/` 디렉토리를 사용할 Claude Code 프로젝트에 복사:

```bash
cp -r .claude/skills YOUR_PROJECT/.claude/
cp -r .claude/hooks  YOUR_PROJECT/.claude/
cp .claude/settings.json YOUR_PROJECT/.claude/
chmod +x YOUR_PROJECT/.claude/hooks/*.sh
```

### 3. BRAIN 경로 수정 (필수)

**각 skill의 `BRAIN=...` 줄**과 **각 hook의 `BRAIN=...` 변수**를 본인 vault 경로로 바꿉니다. 간단한 sed:

```bash
OLD=/Users/hyohwan/Documents/main/brain
NEW=$BRAIN
grep -rlE "$OLD" YOUR_PROJECT/.claude/ | xargs sed -i '' "s|$OLD|$NEW|g"
```

### 4. Hook 경로 등록 확인

`settings.json`의 hook command 경로가 현재 프로젝트 기준으로 맞는지 확인. 절대경로 사용 중이면 수정.

### 5. Vault git 초기화 (taskend skill용)

`taskend`는 brain이 git 저장소임을 가정합니다:

```bash
cd $BRAIN
git init -b main
git add .
git commit -m "chore: initialize brain vault"
gh repo create <username>/brain --private --source=. --push
```

---

## 🔁 일반 워크플로우

```
세션 시작
  └─ SessionStart hook → startread 자동
      └─ 직전 세션 로그 요약 브리핑

사용자: /todaystart   (하루 처음에만)
  └─ 어제 archive + roadmap 읽고 오늘 plan 생성

작업 중 몇 시간 뒤:
사용자: /todaying
  └─ 진척도 체크 + plan 업데이트

(Stop hook이 10분마다 brain 변경 ≥3개면 taskend 제안)
사용자: /taskend  → git 커밋/푸시

세션 종료:
사용자: exit
  └─ pre-exit-check hook 차단 → endwrite 유도
      └─ 세션 요약 저장 + 새 EXP/ADR 후보 감지
사용자: exit (다시)
  └─ 통과

하루 끝:
사용자: /todayend
  └─ 오늘 세션들 취합 → archive/daily
  └─ 금요일이면 주간 로그도 생성
```

---

## ⚙️ Progressive Disclosure

일부 스킬은 조건부 상세 로직을 `references/` 하위 파일로 분리해 기본 로드를 가볍게 했습니다:

- `endwrite/references/exp-adr-detection.md` — EXP/ADR 후보 감지 상세
- `todayend/references/friday-weekly-log.md` — 금요일 주간 로그 상세

Claude는 해당 조건일 때만 이 파일을 추가 Read합니다.

---

## 🔧 커스터마이징

- **기본 브랜치**: `taskend` 는 `main` 가정. 다른 브랜치면 skill 내부 수정.
- **파일명 규칙**: 위 네이밍 규칙은 권장값. 변경 시 skills의 glob 패턴도 같이 업데이트.
- **Stop hook 임계치**: `.claude/hooks/task-end-check.sh` 의 `DIRTY_COUNT -lt 3` 와 `AGE -lt 600` 조정.
- **종료 감지 패턴**: `.claude/hooks/pre-exit-check.sh` 의 `case` 에 추가 키워드 삽입.

---

## 🐛 트러블슈팅

| 증상 | 원인 / 해결 |
|---|---|
| SessionStart에서 startread 안 뜸 | `settings.json` 의 hook command 경로가 절대경로인지, 실행 권한 있는지 확인 |
| exit 차단 안 됨 | `/clear`·`/compact` 는 harness가 먼저 잡아 hook까지 안 올 수 있음. `exit` / `quit` 로 테스트 |
| taskend 알림 과다 | `DIRTY_COUNT` 임계치 높이거나 throttle 10→20분으로 늘림 |
| 스킬이 `/skill-name` 으로 안 잡힘 | 프로젝트 `.claude/skills/<name>/SKILL.md` 위치와 frontmatter `name` 확인 |

---

## 📦 이 repo의 구성

- `.claude/skills/` — 6개 skill
- `.claude/hooks/` — 3개 hook 스크립트
- `.claude/settings.json` — hook 등록
- `.claude/README.md` — 본 문서
