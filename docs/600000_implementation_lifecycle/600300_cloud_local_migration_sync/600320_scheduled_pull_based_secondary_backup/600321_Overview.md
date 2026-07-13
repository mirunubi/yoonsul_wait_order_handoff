# 600321_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`scheduled_pull_based_secondary_backup`

## Change Summary

클라우드 Supabase 프로젝트(`upzthfwhtvazfftxnyfu`)의 스키마를 로컬 PC의 `E:\` 드라이브(리포가 있는 `D:\`와 물리적으로 분리된 내장 SSD)로 매일 자동 pull-백업하는 스크립트를 신설한다. Windows Task Scheduler로 PC가 켜져 있는 동안 매일 1회 실행되며, `tools/apply_migrations_cloud.py`의 `confirm_cloud_target()` 안전장치를 재사용해 승인된 클라우드 프로젝트만 대상으로 함을 보장한다. 이번 산출물(Stage 1.5)은 문서만 — `.py` 파일은 생성하지 않는다.

## §0 확정된 설계 방향 재확인 (Human 결정, 2026-07-11, 재논의 금지)

- 스케줄: PC가 켜져 있는 동안만 실행(MVP 단계) — 상시 가동 서버/클라우드 스케줄러 아님.
- 저장 위치: `E:\catchmenu_backups\` — `E:\`는 내장 SSD(Fixed, `Get-Volume -DriveLetter E`로 이번 턴 재확인: `DriveType = Fixed`), 리포가 있는 `D:\`와 물리적으로 다른 디스크.
- 실행 방식: Windows Task Scheduler + 신규 스크립트(`tools/pull_secondary_backup.py`).
- 기반 도구: `apply_migrations_cloud.py`의 `confirm_cloud_target()` 안전장치 재사용, `supabase db dump --linked` 방식 재사용.
- `E:\` 드라이브는 내장 SSD이므로 매 실행마다 드라이브 존재 자체를 재확인할 필요성은 낮지만(외장 드라이브 대비 상시 연결 보장), "당연히 있겠지"로 방어 코드를 생략하지 않는다 — 경로 접근 실패 시 명확한 에러 로그를 남긴다(`600322_Logic.md` §2).

## Candidate Affected Files (신규 설계 대상 — 이번 턴에 생성하지 않음)

| 파일 | 역할 | 상태 |
|---|---|---|
| `tools/pull_secondary_backup.py` | E:\ 드라이브로 클라우드 스키마 pull 백업, 보관 정책 적용, 실행 로그 기록 | 신규 |
| `tools/cloud_target_config.py` | `EXPECTED_PROJECT_REF`/`EXPECTED_HOST`/`EXPECTED_POOLER_USERNAME` 공유 상수 모듈 — `pull_secondary_backup.py`가 import(Human 결정, Codex 검증 결과에 따른 보강. `600322_Logic.md` §2.2) | 신규 |

## Direct Dependencies

- `tools/apply_migrations_cloud.py`의 `EXPECTED_PROJECT_REF = "upzthfwhtvazfftxnyfu"` 상수와 `confirm_cloud_target()`의 REFUSED 메시지 패턴 — **단, 재사용 방식은 코드 재사용이 아니라 원칙 재사용**이다(§Database Tables 아래 상세). `apply_migrations_cloud.py` 자체는 이번 change에서 편집하지 않는다(지시 사항).
- `supabase db dump --linked` — Supabase CLI. 연결 대상은 URL이 아니라 CLI 자체의 "linked project" 상태(`supabase/.temp/project-ref`)로 결정된다는 점이 `apply_migrations_cloud.py`(명시적 `DATABASE_URL` 파싱)와 근본적으로 다르다 — 이번 턴에 `supabase/.temp/project-ref` 실제 내용을 재확인한 결과 `upzthfwhtvazfftxnyfu` (= `EXPECTED_PROJECT_REF`와 일치)임을 확인했다.
- Python 표준 라이브러리 `shutil.disk_usage()`(여유 공간 조회), `os.makedirs(exist_ok=True)`(폴더 생성), `datetime`(타임스탬프/보관 기간 계산) — 외부 패키지 신규 의존성 없음.

## Database Tables

해당 없음(이 change는 SQL 마이그레이션도 Flutter 클라이언트도 아닌 순수 로컬 운영 스크립트). 클라우드 DB에 대해서는 **읽기 전용**(`db dump`)만 수행하며 어떤 쓰기도 하지 않는다.

## `E:\` 경로와 `.gitignore`의 관계 (명확화)

`E:\catchmenu_backups\`는 리포지토리 디렉터리(`D:\workspace\yoonsul_wait_order_handoff\`) **바깥**에 있으므로 `.gitignore` 대상이 아니다 — 애초에 git이 추적할 수 있는 경로가 아니다(다른 드라이브). 이는 오늘 이전에 `.gitignore`에 추가한 `cloud_backup_*.sql`(리포 **내부** 루트에 생성된 일회성 조사용 덤프, git이 추적 범위 안에 있어서 명시적 제외가 필요했던 것)와 **완전히 다른 메커니즘**이다 — `600322_Logic.md`에서 이 구분을 재차 명시한다.

## Required Context Snapshot Candidates (§6.5 — Claude Code-Assisted Rule Filtering)

### Master Anchor

`000001_Md_Rules.md`, `000701_Guide_Controlled_AI_Development_Pipeline.md`(이번 change는 Stage 1.5)

### Full Rules Required

- `tools/apply_migrations_cloud.py` 전체(특히 `confirm_cloud_target()`, `EXPECTED_PROJECT_REF`/`EXPECTED_HOST`/`EXPECTED_POOLER_USERNAME` 상수 정의부) — 이 change가 재사용할 안전장치의 원본. **참조만, 편집 금지**(지시 사항).
- `.gitignore`의 `cloud_backup_*.sql` 규칙 — 위 §`.gitignore` 관계 절의 대조 근거.

### Excluded Rule Families

- `sql/migrations/**` 전체 — 이 change는 마이그레이션 파일을 만들거나 실행하지 않음, 제외.
- `600100`/`600200` 계열(고객 식별/Flutter) — 무관, 제외.

## Module Domain Tags

- OPS_TOOLING
- DOCUMENTATION_ONLY (이번 턴 자체는 문서만)

## Risk Notes

`confirm_cloud_target()`을 "재사용"한다는 것이 `apply_migrations_cloud.py`의 URL 파싱 코드를 그대로 가져다 쓴다는 뜻이 아님을 분명히 한다 — `supabase db dump --linked`는 `DATABASE_URL`을 받지 않고 CLI 자체의 linked-project 상태로 대상을 결정하므로, 이 change의 안전장치는 **동일한 project ref 상수(`upzthfwhtvazfftxnyfu`)와 동일한 "불일치 시 즉시 REFUSED, 아무 것도 실행 안 함" 원칙**을 `supabase/.temp/project-ref` 파일 대조 방식으로 재구현하는 것이다(`600322_Logic.md` §2에서 구체화). 이 차이를 Stage 2/4가 놓치면 "재사용"이 아니라 이름만 같은 별개의(그리고 더 약한) 검증이 될 위험이 있다.

**보강 배경(Human 결정, 2026-07-11, Codex 검증 완료)**: `supabase/.temp/project-ref` 파일 값 대조 단독으로는 "다른 실제 프로젝트로 잘못 link된 상태"를 막지 못하는 경우가 Codex의 재현 테스트로 확인됐다 — CLI가 링크 상태 자체를 그대로 신뢰하려 하는 지점이 있어 파일 값 비교라는 사후 대조 한 겹만으로는 불충분했다. 이에 따라 `EXPECTED_PROJECT_REF`를 `tools/cloud_target_config.py`라는 단일 공유 모듈로 분리하고, `pull_secondary_backup.py`는 파일 값과 이 모듈의 상수를 이중으로 대조하도록 설계를 보강했다(`600322_Logic.md` §2.2). 부수 효과로 이전에 Open Question이었던 "상수 이중 관리" 문제도 함께 해소된다.

## Uncertainties

- 보관 기간(30일) 적절성 — Human 확정 필요(`600322_Logic.md` §Open Questions).
- Task Scheduler 실행 시각(제안: 새벽 3시) — Human 확정 필요.
- 복구(restore) 절차를 이번 change 범위에 포함할지 — 별도 변경건 분리 제안(`600322_Logic.md` §Open Questions).

## Known Gaps

없음 — 이번 조사는 이 신규 change에 필요한 최소 컨텍스트(`apply_migrations_cloud.py`의 안전장치 원본, `.gitignore`와의 관계)만 다룬다.

## Snapshot Decision

이 스냅샷으로 `600322_Logic.md` 작성 진행 가능.
