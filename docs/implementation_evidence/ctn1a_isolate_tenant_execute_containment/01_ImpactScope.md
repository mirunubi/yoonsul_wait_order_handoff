# ImpactScope.md — CTN-1a

Change ID: ctn1a_isolate_tenant_execute_containment (Stage 3 확정 — 2026-09-22)
Status: Draft
Draft Status: Verified (Claude) — Stage 3 검토 반영 2026-09-22
Stage: 000701 Stage 2 Design Draft
Written: 2026-09-22
Stage 1 원본: `00_CodexScan.md` (Codex raw scan · 구속력 없음)

> 이 문서는 구속력이 없다. Stage 3 에서 Claude(앵커)가 검토한다.
> 이 세션이 만든 prototype `0179` · `601513` 은 근거로 쓰지 않았다. 아래 사실은 migration 원문 · 정책 문서 · live 카탈로그(read-only)에서 다시 도출했다.

## Change ID

- 제안: `ctn1a_isolate_tenant_execute_containment`
- 근거와 대안: 아래 [제안] 절 P-1
- 현재 임시 식별자: `CTN-1a` (Human 결정 표기)

## Change Summary

두 `SECURITY DEFINER` 함수에서 `PUBLIC` · `anon` · `authenticated` 의 EXECUTE 를 회수한다. 그 밖의 것은 바꾸지 않는다 (HD-CTN-02).

| 함수 | 정의 |
|---|---|
| `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` | `0090` L1256 |
| `catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` | `0121` L762 |

정규 구현은 prototype 이 없는 clean baseline(0178 까지)에서 Codex 가 Stage 8 로 다시 수행한다 (HD-CTN-03).

## Candidate Affected Files

### 새로 만들 파일 (Stage 3 확정 이름 · 번호)

| 파일 | 비고 |
|---|---|
| `sql/migrations/0180_ctn1a_isolate_tenant_execute_containment.sql` | P-3 결정 M1. 첫 5줄에 `Workpacket: 603010` (`tools/Check-Governance.ps1` L971 · L979) |
| `docs/600000_implementation_lifecycle/603000_containment/603000_Readme_Containment.md` | P-2 결정 B. 예외 레지스트리 포함 (P-4) |
| `…/603000_containment/603010_ctn1a_isolate_tenant_execute_containment/` 아래 Stage 5 `ChangeContract` · `TestPlan` | G15 규칙 ①(폴더)로 찾는다 |

폴더 · 색인 등록은 **Stage 10** 에 한다 (P-2 · Stage 6 처분 F-13 으로 시점 통일 — 이전 표기 "Stage 7 승인 직후 · Stage 8 전"). 이 단계에서는 아무 폴더도 만들지 않았다.

### 수정 후보 (Stage 7 결정 전에는 건드리지 않음)

| 파일 | 이유 |
|---|---|
| `sql/migrations/CHANGELOG.md` | prototype 처분 시 기록 선례 L167~181 (`0073`) |
| `docs/000005_Index_Document_Number.md` · `603000_Readme_Containment.md` · `000007` | 정규 문서 등록 (Stage 10) |
| `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | 예외 기록 1행 (P-4 결정) |
| `601500_Readme…` §5 표 | L146~147 「경계 문서를 발견하면 그 Overview 작성과 동시에 이 표에도 추가」 — **결정: 적용하지 않음 (권위 보류 폴더 · OQ-IS-5)** |

### 처분 대상 (prototype — HD-CTN-03, Stage 7 확정)

| 파일 | 상태 |
|---|---|
| `sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql` | untracked · 현재 local DB 에 success=t 행 |
| `docs/…/601500_…/601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` | untracked |
| `docs/000005_Index_Document_Number.md` (601513 행) | tracked · 미커밋 수정 |
| `601500_Readme_Operational_Authority_Foundation.md` L104 (601513 행) | tracked · 미커밋 수정 |

### 읽기 전용 근거 (수정 대상 아님)

`0090` · `0112` · `0121` · `0130` · `0131` — 정의와 호출부. 기존 migration 수정은 000701 §14.5 불변 경계와 HD-CTN-02(본문 · signature 변경 금지)로 배제.

## Direct Dependencies

### migration 원문에서 도출한 prototype 이전 ACL

| 함수 | 원문 | 도출 |
|---|---|---|
| `isolate_tenant` | `0090` L1448~1451 `revoke all on function catchmenu_common.isolate_tenant(uuid, text, boolean, uuid, text) from public;` · L1452~1455 `grant execute … to authenticated;` | owner `postgres` · `authenticated` 명시 EXECUTE · PUBLIC 없음 |
| `detect_threat` | `0121` L1545~1549 `grant execute … detect_threat(text, int, text, text, jsonb, uuid, uuid, uuid, text, text) to authenticated;` · PUBLIC revoke 없음 | owner `postgres` · PUBLIC 기본 EXECUTE · `authenticated` 명시 EXECUTE |

`sql/migrations/*.sql` 전수(0179 제외)에서 두 함수 이름을 포함하는 `grant` · `revoke` · `create or replace function` · `alter function` · `drop function` 은 위 줄 외에 없다 (검증 a).

### 현재 live 상태 (prototype 효과 포함 — 정규 기대값 아님)

```text
SQL: select p.oid::regprocedure, pg_get_userbyid(p.proowner), p.prosecdef, p.proconfig, md5(p.prosrc), p.proacl ...
detect_threat   postgres  t  {search_path=catchmenu_common}  992c78c881be2f23bcac8050b60ad2b7  {postgres=X/postgres}
isolate_tenant  postgres  t  {"search_path=catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit"}
                                                          f53ea7f556e89cec883b9ca6b482ca3e  {postgres=X/postgres}
```

### 역할

```text
SQL: select rolname, rolbypassrls, rolsuper from pg_roles where rolname in (...);
authenticated  f f
anon           f f
service_role   t f
postgres       t f
authenticator  f f
```

```text
SQL: select m.rolname, r.rolname, m.rolcanlogin, m.rolinherit from pg_auth_members am ... where r.rolname in ('authenticated','anon','service_role')
 authenticator           | anon          | t | f
 postgres                | anon          | t | t
 supabase_realtime_admin | anon          | f | f
 authenticator           | authenticated | t | f
 postgres                | authenticated | t | t
 supabase_realtime_admin | authenticated | f | f
 authenticator           | service_role  | t | f
 postgres                | service_role  | t | t
 supabase_realtime_admin | service_role  | f | f
```
- schema `catchmenu_common` USAGE: `authenticated` t · `anon` f · `service_role` f

## Indirect Dependencies

### 호출 관계 — 두 방법 일치

| caller → callee | migration 원문 호출 줄 | live prosrc 줄 |
|---|---|---|
| `catchmenu_common.manage_subscription → isolate_tenant` | `0112` L600 · L616 | 79 · 95 |
| `catchmenu_common.detect_threat → isolate_tenant` | `0121` L876 | 97 |
| `catchmenu_common.verify_security_token → detect_threat` | `0121` L628 · L662 · L700 | 26 · 60 · 98 |
| `catchmenu_common.gateway_audit_entry → detect_threat` | `0121` L971 · L989 | 24 · 42 |
| `catchmenu_payment.record_van_transaction → detect_threat` | `0130` L335 | 29 |
| `catchmenu_store.check_staff_permission → detect_threat` | `0131` L462 | 102 |

- 서로 다른 caller→callee 관계 6개 · 호출 지점 10개
- 상위 호출자 5개는 모두 `SECURITY DEFINER` · owner `postgres`:

```text
SQL: select p.oid::regprocedure, pg_get_userbyid(p.proowner), p.prosecdef from pg_proc ... where proname in (5개)
catchmenu_common.manage_subscription(uuid,text,text,text,uuid,text)              | postgres | t
catchmenu_payment.record_van_transaction(uuid,uuid,text,...,boolean,text)       | postgres | t
catchmenu_common.verify_security_token(text,text,text,boolean)                  | postgres | t
catchmenu_common.gateway_audit_entry(text,text,text,text,uuid,uuid,uuid,...)    | postgres | t
catchmenu_store.check_staff_permission(uuid,uuid,uuid,text,integer,text)        | postgres | t
```

- 알려진 3개 `isolate_tenant` 호출(`0112` L600 · L616 · `0121` L876)은 `p_reason` 인자명 때문에 `42883` 으로 실패한다 (`601505` §4.1.2 L351~367). ACL 회수는 이 방벽과 무관하다.
- trigger 0 · `cron.job` 0 rows · public wrapper 0 (검증 c)

## Database Tables

live 본문(`pg_get_functiondef`)에서 확인한 쓰기 대상:

| 함수 | prosrc 줄 | 대상 |
|---|---|---|
| `isolate_tenant` | 22 | `update catchmenu_hq.tenants` |
| `isolate_tenant` | 38 | `insert … security_audit_log` |
| `isolate_tenant` | 62 | `catchmenu_audit.append_audit_record` |
| `isolate_tenant` | 78 | `insert … catchmenu_ledger.events` |
| `detect_threat` | 28 | `insert … security_threats` |
| `detect_threat` | 68 | `create_operation_alert` |
| `detect_threat` | 97 | `isolate_tenant` 호출 |
| `detect_threat` | 114 | `insert … sandbox_violations` |

이번 변경은 테이블을 바꾸지 않는다.

## Migrations

| 구분 | 내용 |
|---|---|
| 정의 | `0090` · `0121` |
| 호출자 | `0112` · `0121` · `0130` · `0131` |
| 이후 재정의 · ACL 변경 | 없음 (0179 제외) |
| 현재 파일 | `sql/migrations` 에 `NNNN_` 파일 178개. 번호 공백 `0073`(제외 폴더로 이동) · `0128`(git 이력 없음) |
| prototype | `0179_ctn1a_revoke_isolate_tenant_execute.sql` — untracked |
| local history | `success=t` 178행(`0000`~`0179`, `0073` 없음) · `success=f` 1행(`0073`) |

```text
SQL: select success, count(*), min(filename), max(filename) from catchmenu_meta.migration_history group by success;
 f |   1 | 0073_final_verification.sql             | 0073_final_verification.sql
 t | 178 | 0000_create_migration_history_table.sql | 0179_ctn1a_revoke_isolate_tenant_execute.sql

SQL: ... where filename >= '0176'
 0178_order_request_identity_and_numbering.sql | t | 2026-09-11 05:32:58.083829+00
 0179_ctn1a_revoke_isolate_tenant_execute.sql  | t | 2026-09-21 11:15:56.588353+00
```

## RLS Policies

Stage 1 의 6개 테이블 policy 목록(`00_CodexScan.md` "RLS Policies")을 그대로 둔다. 다만 두 함수 owner `postgres` 는 `rolbypassrls=t` 이므로 **이 policy 들은 두 함수 안의 쓰기를 제약하지 않는다.** 이번 변경은 RLS 를 바꾸지 않는다.

## Tests Found

| 위치 | 대상 함수 참조 |
|---|---|
| `tests/` (`hydration_registry` · `source_module_map` · `static_validation`) | 0 |
| `catchmenu_app/test` | 0 |
| `tools/` · `supabase/` | 0 |

`grep -rln "isolate_tenant\|detect_threat" tests catchmenu_app tools supabase` → 출력 없음.

회귀용 기존 검증(대상 비특정): `tools/static_validation/validate_hydration_registry.py` · `validate_source_module_map.py` (`602010` §7.4 L610~620 선례) · `tools/Check-Governance.ps1`.

## Tests Missing

- 역할별 EXECUTE 행렬(PUBLIC · anon · authenticated · service_role · postgres) 검증
- 불변 조건 검증: 두 함수 md5 · signature · owner · proconfig · 다른 함수 ACL
- clean baseline 에 prototype history 가 없다는 증명
- 간접 경로 관측(상위 5개 호출자의 EXECUTE 는 그대로라는 사실) — **실행 호출 없이** 카탈로그로만
- 구체 설계는 Stage 5 소관

## Provider / POS / PG / VAN / Bank / Payout Impact

직접 영향 없음. `catchmenu_payment.record_van_transaction` 이 `detect_threat` 를 부르지만 DEFINER 이므로 ACL 회수 후에도 owner 권한으로 부른다 (03_Logic "간접 경로").

## Audit Ledger / Evidence Impact

- 두 함수의 audit · ledger 쓰기 경로 자체는 바뀌지 않는다.
- 이 변경의 증거: `catchmenu_meta.migration_history` 행(checksum = `tools/apply_migrations.py` L100~102) · Stage 9 raw log

## Monitoring / Alert Impact

`detect_threat` 의 `create_operation_alert` 경로는 직접 호출자(`authenticated` · PUBLIC)에게서 닫힌다. DEFINER 상위 호출자 경로는 그대로다.

## Related Documentation References

Stage 1 목록(`00_CodexScan.md` "Related Documentation References")에 아래를 더하고 고친다.

| 문서 | 위치 | 비고 |
|---|---|---|
| `601505` §4.4 | L394 · **L403** | 원문: `ALTER FUNCTION … OWNER TO` / `REVOKE … FROM PUBLIC` / `GRANT EXECUTE` / `SET search_path` — 이유 「대상 함수가 존재하지 않는다. 0-C 필수 규칙(601503 §9)으로 이월」. 해석 두 가지 (02_Overview) |
| `601505` §4.5 | L415 | 신규 호출자 배포 금지 — Stage 1 누락 |
| `601505` §8.1 Open Item (p) | 본문 **L764** (L762 는 절 제목) | `p_reason` 불일치 — Stage 1 누락 |
| `601505` §4.3 | 본문 **L381** (L389 는 적용 범위 문장) | 0-A-2 전 `ACTIVE` 승격 금지 |
| `601505` §8A.1 | L811 · L828 | 0121 보안 파이프라인 실연동은 0-A-2 이후 |
| `601505` §8A.2 | L840~841 | 「0-A-2 완료가 해제하는 금지 조항: §4.1.1 · §4.3 · §4.5 … 별도 Human 판단으로만」 |
| `601505` §9 · §10 | **L956 · L968** (L924 는 절 제목 — 근거에서 뺌) | Stage 7 대기 · Decision 공란 |
| `601503` §9 | L731 · 6항목 본문 **L741~746** | §4.4 가 이월한 0-C 필수 6규칙 — Stage 1 누락 |
| `600020` §1.4 · §1.5 | 금지 문장 **L81** (L65 는 절 제목) · L84 · **L98** | 「601505 §4의 금지 조항(호출 금지·ACTIVE 승격 금지·신규 호출자 배포 금지)은 계속 유효하다」 — 금지의 현재 효력 근거 |
| `600021` | — | 601800 권위 보류 (600023 §8 표) |
| `000221` §4.1 | **L215~216** · **L499** | Stage 1 의 L202 는 후보 범위 문장. L499 `601505 §4 · §8A | 호출 금지 조항 · 순서 — 권위보류. evidence 로만 인용` 누락 |
| `600023` §4 · §6 | **L215** · L264~270 | L215 「`601505` §4 호출 금지 조항은 계속 유효하다」 · `602000 ~ 602999 Runtime Gate` · `RG-N 은 602010 부터 10단위` |
| `000001` §5.4.2 · §5.10 | L162 · L444 | 임시 위치 규칙 · frozen snapshot 수정 금지 |
| `000002` §2.1 | L322 | 폴더 번호 대역 소유 |
| `602061` §3.1 · §3.4 | L243 · **L250** · **L383** · L390 | 발견 경위 사실 — 금지 호출 기록 (비권위) |
| `sql/migrations/CHANGELOG.md` | L167~181 | `0073` 제외 선례 · 과거 local replay 가 순서대로 한 번에 통과하지 못해 파일을 임시로 옮겨 재실행한 기록(L177) |
| `docs/000000_Readme_Root.md` | L16 | cloud project `upzthfwhtvazfftxnyfu` |
| `600300_Readme…` · `600301` | L10 · L30 · L7 | cloud 는 `tools/apply_migrations_cloud.py` 로 별도 적용 |

## Related SOP / Policy / Matrix / Checklist References

- Policy: `010004` §7 — containment block **L238** · fail closed **L241** (L221 은 절 제목)
- Governance: `600020` · `600021` · `600023` · `000701`
- 대상 함수 전용 SOP · Matrix · Checklist: 없음 (Stage 1 과 같음)

## Master / Domain Index References

Stage 1 목록에 더함: `600000_Readme_Implementation_Lifecycle.md` · `600010_Tracker_Spiral_Workpacket_Progress.md` · `601200_Readme_Caller_Authorization_Foundation.md` (0-C 소관 — 재개방 금지 확인용).

## Module Domain Tags

- DB · RLS(권한) · AUDIT_EVIDENCE

## Required Context Snapshot Candidates

### Master Anchor

- Human Approved 2026-09-22 09:41 KST: HD-CTN-01 ~ HD-CTN-04 (02_Overview 에 원문)
- `000701` (Full tier)
- `600020` §1 (권위 보류 · 금지 효력 L98)

### Rule Summaries

- `601500_Readme_Operational_Authority_Foundation.md` (권위 보류 배너 L3~45)
- `602000_Readme_Runtime_Gate.md` §5 — RG-F2 **L181** · RG-F15 **L194** (L176 은 절 제목)

### Full Rules Required

- `601505` §4.1.1 · §4.1.2 · §4.3 · §4.4 · §4.5 · §8.1(p) · §8A.1 · §8A.2
- `601503` §9
- `601902` §0.3 L54 · §5 L1075~1081
- `600020` §1 · §4 · `600023` §2 · §4 · §6
- `000221` §4.1 · L499
- `000701` §3 · §6.5 · §8.5~§8.10 · §14.5 · §37 · §42 · §44 · §46
- `000001` §5.4 · §5.10 · `000002` §1.1 · §2.1 · `000015`
- migration 원문 `0090` · `0112` · `0121` · `0130` · `0131`
- `tools/apply_migrations.py` · `tools/Check-Governance.ps1` G15 (L879~1023)

### Domain Indexes

- `000005` · `000007` · `601500_Readme` · `601900_Readme` · `602000_Readme` · `sql/migrations/CHANGELOG.md`

### Excluded Rule Families

| Excluded Rule Family | Reason |
|---|---|
| `602060` · `602061` · `601513` · prototype `0179` | 비권위 — 발견 경위 사실 인용에만 |
| `601800` 대역 판정 | `600021` 권위 보류 |
| 0-C caller-authorization 설계(`601200` · `601902` §5 결정 사항) | HD-CTN-02 — 0-C 재개방 금지 |
| 0-A-2 (`isolate_tenant` 재작성 · `p_reason` · phantom 해소) | HD-CTN-02 금지 · `601505` §8A |
| payment · KDS · order runtime gate | ACL 두 건과 직접 무관 |
| Flutter UI | 앱 직접 참조 0 |

## Context Budget Decision

FULL — 권한(ACL) · migration · 권위 보류 문서와의 교차 판단이 필요하다.

## Risk Notes

1. prototype 이전, `authenticated` 는 두 함수를 직접 EXECUTE 할 수 있었고 `detect_threat` 는 PUBLIC EXECUTE 였다 (원문 도출).
2. 두 함수 owner 는 BYPASSRLS — 함수 안에서는 RLS 가 막지 않는다.
3. 간접 경로(DEFINER 5개)는 이 변경으로 닫히지 않는다. 현재 `isolate_tenant` 간접 호출 3개를 막는 것은 `42883` 뿐이다 (「우연한 방벽」 — `601505` §4.1.1 L331. `p_reason` · `42883` 사실은 §4.1.2 L351~358).
4. `tools/apply_migrations.py` L91 은 `sql/migrations/*.sql` 을 파일시스템에서 고르므로 untracked prototype 도 집는다. 옵션 없음(argparse 등 0).
5. 현재 local DB 는 prototype 효과를 품고 있어 정규 Stage 9 환경이 아니다.
6. ~~clean 0178 재구축 성공은 미검증.~~ **갱신 (HD-CTN-06 실측 · 2026-09-23)**: disposable 컨테이너에서 `CHANGELOG.md` L177 의 2단계 절차(1차 158개 번호순 → 2차 19개 L177 순서 · `0073` 영구 제외)로 두 차례 실행해 **177/177 성공 · `0178` 도달**했다. 남는 위험은 순수 번호순 재생이 `0093` 에서 `23514` 로 실패한다는 점이다 (`0093` 이 뒤 번호 `0140` 의 제약 확장을 전제) → 아래 `F-REPLAY`.
7. 이 세션이 RG-06 조사 중 `isolate_tenant` 를 호출했다 (`602061` L250 · L383 · L390). `601505` §4.1.1 위반 — 절차 위반 finding 등록은 미완.

## Uncertainties

### 닫힌 항목 (Stage 4 갱신 · F-7 · Cursor 3)

| 항목 | 처분 |
|---|---|
| `0001`~`0178` replay 가 성공하는지 | **2026-09-23 실측으로 해소** — B5 절차로 두 차례 177/177 |
| 워크패킷 번호 · 폴더 | **Stage 3 결정** — `603000_containment/` · `603010_…` (OQ-IS-2. 단 대역 적합성은 OQ-S6-2 로 Stage 6) |
| migration 번호 | **Stage 3 결정** — `0180_ctn1a_isolate_tenant_execute_containment.sql` (OQ-IS-3) |
| CHANGE_ID | **Stage 3 결정** — `ctn1a_isolate_tenant_execute_containment` (OQ-IS-1) |
| local dev 컨테이너가 §14.5 의 "공유 환경"인가 | **Stage 3 결정** — 공유 환경 아님 (03_Logic 조건 3) |

### 열린 채로 남는 것

- prototype 처분 (Stage 7 · HD-CTN-03)
- clean baseline **방식 확정** (Stage 7 · 앵커 권고는 B5)
- cloud PostgREST exposed schemas (저장소에 없음)
- HD-CTN-02 영구 기록 위치 (E1 결정의 실제 문면 · Stage 5)

## Known Gaps

- cloud 측 ACL 은 조회하지 않았다 (접속 범위 밖).
- Stage 0 Issue Record 는 형식 문서로 존재하지 않는다 (000701 L112 「선택, 형식 자유」). 발견 사실은 `602061` 에만 있다.
- clean baseline 과 현재 DB 의 role 차이 2건 (`supabase_functions_admin` · `supabase_realtime_admin`) — tracked migration 이 만들지 않는 **환경 차이**이며 생성 주체는 미확정이다 (SP-4 실측 · 2026-09-23). replay fidelity 결함이 아니다.

### 별도 finding 후보 — `F-REPLAY` (CTN-1a 에서 고치지 않는다)

| 항목 | 내용 |
|---|---|
| 현상 | committed migration 이 번호 순서대로 재현되지 않는다. `0093` 이 뒤 번호 `0140` 의 제약 확장을 전제한다 (`23514`) |
| 재현 방법 | `CHANGELOG.md` L177 의 2단계 절차가 필요하며, 현재 HEAD 에서도 유효하다 (2026-09-23 두 차례 177/177) |
| 영향 | 새 환경 구축 · cloud 재동기화 · 재해 복구가 저장소만으로는 되지 않는다 |
| 관련 가능성 | `600311` 의 cloud replay 1차 실패 19건도 같은 원인일 가능성 (미검증) |
| 부수 | `CHANGELOG` L151 의 "19 files" 표기와 실제 열거 21개가 불일치 |
| 처분 | 별도 워크패킷 후보. CTN-1a 에서 고치지 않는다 |

## Codex Scan Corrections

(000701 §8.8 의 `Cursor Scan Corrections` 절. 이번 Stage 1 수행자는 Codex.)

### 검증 표

| # | Stage 1 주장 | 재확인 방법 | 결과 | 근거 |
|---|---|---|---|---|
| a1 | `isolate_tenant` 초기 ACL = REVOKE ALL FROM PUBLIC · GRANT authenticated | 원문 읽기 | 일치 | `0090` L1448~1455 |
| a2 | `detect_threat` = GRANT authenticated · PUBLIC 회수 없음 | 원문 읽기 | 일치 | `0121` L1545~1549 |
| a3 | 이후 재정의 · ACL 변경 없음 | `sql/migrations/*.sql`(0179 제외) 전수 — 함수명 포함 grant/revoke/create/alter/drop | 일치 (위 줄 외 0) | Python 전수 스캔 |
| b | 호출 그래프 10행 | live prosrc 정규식 · migration 원문 grep | 관계 6 · 호출 지점 10. "10행" 표는 depth-2 행이 depth-1 관계 4개를 반복 | 위 Indirect Dependencies 표 |
| c | trigger 0 · cron 0 · wrapper 0 · 앱 참조 0 | `pg_trigger` · `cron.job` · public 함수 prosrc · `grep -rln` | 일치 | 00_CodexScan 원출력과 같은 결과 |
| d | `apply_migrations.py` 가 untracked 0179 를 집음 | 코드 읽기 | 일치 | L91 `MIGRATIONS_DIR.glob("*.sql")` · L203 skip · L219 APPLY |
| e | G15 규칙 L913~991 | 코드 읽기 | **범위 부족** | 아래 C-1 |
| f | 정책 원문 | 원문 읽기 | 대부분 일치 · 2건 정정 | 아래 C-4 · C-5 |
| g | 현재 ACL `{postgres=X/postgres}` | `proacl` · `aclexplode` · `has_function_privilege` | 일치 | 위 Direct Dependencies |
| h | `authenticated` 만 schema USAGE | `has_schema_privilege` | 일치 | 위 |
| i | 로컬 config 는 `catchmenu_common` 비노출 | `supabase/config.toml` L7~15 | 일치 · 단 C-8 | |
| j | 0073 제외 선례 | 폴더 · CHANGELOG | 일치 | `sql/_excluded_from_local_replay/` = 0073 1개 · CHANGELOG L167~181 |
| k | 604278 같은 컨테이너 별도 DB 선례 | 원문 읽기 | 일치 | `604278` §4 L57 · §5 L71 (0042 에서 실패) |
| l | `601500_Readme` 7함수 행 L143 | 원문 읽기 | 일치 | L143 |

### 정정 목록

| # | 구분 | 내용 | 근거 |
|---|---|---|---|
| C-1 | 정정 | G15 는 L879(머리 주석) ~ L1023. `Get-Stage7State` 는 L910 부터(L913 은 내부 주석). **판정 분기 L1000~1019 누락**: L1004 APPROVED → 통과 · L1006~1010 UNPARSEABLE → WARN · L1012~1019 PENDING → `MIGRATION_WITHOUT_APPROVAL`(WARN, `-StrictStage7` 이면 ERROR). L979 헤더 없는 migration 은 NO_HEADER 로 집계만. L1023 폴더 없음 경고 | `tools/Check-Governance.ps1` |
| C-2 | 추가 | G15 는 **파일만 읽고 `migration_history` 를 읽지 않는다**. 즉 "적용됨" 여부가 아니라 `sql/migrations` 에 파일이 있는지로 판정한다. `sql/_excluded_from_local_replay/` 는 대상 밖 | L972 `Get-ChildItem -LiteralPath $MigrationsDir` |
| C-3 | 정정 | "호출 관계 10행" → 관계 6 · 호출 지점 10 | 검증 b |
| C-4 | 정정 | `000221` 인용 L202 → **L215~216**. **L499 누락** (`601505 §4 · §8A` 권위보류 · evidence 로만 인용). 따라서 호출 금지의 현재 효력은 `601505` 자체가 아니라 `600020` §1.5 L98 에 기댄다 | `000221` L499 · `600020` L98 |
| C-5 | 정정 | Stage 1 은 `601505` §4.4 를 「함수·ACL 변경을 0-C로 이월한 기존 금지」로 한 해석만 적었다. L403 이유 「대상 함수가 존재하지 않는다」 때문에 해석이 둘이다 → 02_Overview · OQ | `601505` L403 |
| C-6 | 추가 | owner `postgres` `rolbypassrls=t` — Stage 1 RLS 표는 함수 안 쓰기를 제약하지 않는다 | `pg_roles` 원출력 |
| C-7 | 추가 | 상위 호출자 5개 모두 DEFINER · owner postgres (Stage 1 은 호출 관계만) | 위 원출력 |
| C-8 | 추가 | 이 프로젝트의 local API stack 은 떠 있지 않다. `docker ps` 에 `supabase_db_yoonsul_wait_order_handoff` 만 있고, host `54321` 은 다른 프로젝트 `supabase_kong_ajumsocks` 가 점유한다. DB 포트는 `0.0.0.0:54322` | `docker ps --format '{{.Names}}\t{{.Ports}}'` 원출력 |
| C-9 | 추가 | `anon` · `authenticated` · `service_role` 각각의 member 3개(`authenticator` · `postgres` · `supabase_realtime_admin`) — 역할 행렬에 필요 | `pg_auth_members` 원출력 (위 Direct Dependencies) |
| C-10 | 추가 | `.gitattributes` L1 `*.sql text eol=lf` (파일 자신은 BOM 으로 시작). 새 migration EOL 과 checksum(L101 CRLF→LF 정규화) 관련 | `.gitattributes` |
| C-11 | 추가 | 회귀용 검증 도구 `tools/static_validation/validate_hydration_registry.py` · `validate_source_module_map.py` | `602010` §7.4 |
| C-12 | 추가 | `601505` §4.5 L415 · §8.1(p) L764 · §8A.1 L811/L828 · `601503` §9 L741~746 · `600023` §4 L215 · §6 L264 · `000001` §5.10 L444 · `000002` §2.1 L322 · `600021` | 위 Related Documentation |
| C-13 | 추가 | `CHANGELOG.md` L177 — 과거 local replay 는 파일을 임시로 폴더 밖으로 옮겨 재실행해야 통과했다. Stage 1 [5] 는 604278 · 600311 만 인용 | L177 |
| C-14 | 추가 | 번호 공백 `0128` (git 이력 없음 · CHANGELOG 기록 없음) — 번호 공백 선례 | `git log --all -- 'sql/migrations/0128*'` 출력 없음 |
| C-15 | 추가 | `602061` §3.1 L250 · §3.4 L383 · L390 — 이 세션의 금지 호출 기록. Stage 1 은 602061 을 비권위 참조로만 적었다 | 원문 |
| C-16 | 재분류 | Stage 1 "Candidate Affected Files" 의 `0090` · `0112` · `0121` · `0130` · `0131` 은 수정 대상이 아니라 읽기 전용 근거. prototype 3건은 정규 변경 파일이 아니라 처분 대상 | HD-CTN-02 · HD-CTN-03 · 000701 §14.5 |
| C-17 | 제외 | Stage 1 [3] Antigravity 동기화는 CTN-1a 범위 밖 → OQ-IS-4 로만 | 운영 결정 2026-09-22 |
| C-18 | 추가 | `sql/migrations/seed_yoonsul_menu.sql` 은 `^\d{4}_` 패턴 밖이라 `apply_migrations.py` 대상이 아니다 (clean baseline 파일 수 계산용) | `ls sql/migrations` |

오포함으로 뺀 항목: 없음 (C-16 은 재분류).

## [제안] (Stage 3 결정 대상)

### P-1 CHANGE_ID

`ctn1a_isolate_tenant_execute_containment`

| 선례 | 형식 |
|---|---|
| `601502` | `operational_authority_foundation_ddl` — snake_case · 대상 + 성격 |
| `implementation_evidence/order_sessions_customer_id_fk_and_guest_promotion/DesignPack.md` L3 | snake_case · 대상 + 동작 |
| `601717` L41~47 | `Workpacket 601700` 블록 (번호 중심) |

근거: 앞의 두 선례와 같은 snake_case 서술형. `ctn1a` 는 Human 결정 라벨과 연결하려고 앞에 붙였다. 도메인 단어가 아닌 라벨이 들어가는 것이 괜찮은지는 OQ-IS-1.

**결정: `ctn1a_isolate_tenant_execute_containment` 확정 (Stage 3).**

### P-2 워크패킷 번호 · 폴더

G15 연결 조건: migration 첫 5줄 `Workpacket: NNNNNN`(L971) → ① `NNNNNN*` 폴더 아래 `*ChangeContract*.md` 또는 ② 파일명에 번호가 든 `*ChangeContract*.md`(L951~967) → 그 문서의 Stage 7 이 APPROVED(L1004).

| 후보 | G15 | 장점 | 단점 |
|---|---|---|---|
| **A** `601514` · `601500_operational_authority_foundation/` | 규칙 ② (파일명) | `601505` §4.4 원천과 같은 폴더 · Readme §5 L143 행이 이미 7함수를 가리킴 · 대역 601500~601599 안 | 폴더 전체 AUTHORITY SUSPENDED (L3~45 · L30 「새 설계의 근거로 인용 금지」) — 효력 있는 계약을 권위 보류 폴더에 둔다 · prototype `601513` 바로 옆 번호 · 규칙 ① 은 `601514*` 폴더가 없어 동작 안 함 |
| **B** `603000` 새 폴더 (`600000_implementation_lifecycle/603000_<name>/`) | 규칙 ① (폴더) | 권위 보류 · RG 대역과 분리 · 기존 100단위 워크스트림 폴더 관행(601200~602000) · `600023` §6 이 602000~602999 까지만 가지므로 603000 은 RG 밖 | 새 폴더 = Readme(G07) · `000005` · `000007` 등록 · 폴더 이름 결정 필요(Stage 3/Human) · `000002` §2.1 로 602000 폴더 소유 대역이 603000 앞에서 끝나게 된다(현재 다음 형제는 `604000_workpackets`) |
| **C** `602070` · `602000_runtime_gate/` | 규칙 ② | 발견 지점(RG-06 · `602061`)과 가까움 | `600023` §6 「RG-N 은 602010 부터 10단위」 — 602070 은 RG-07 자리 · HD-CTN-04 가 수정 소관을 RG 밖(CTN-1a)으로 옮김 · RG 정의 수정 필요 |

제외: `601200_caller_authorization_foundation` (0-C — HD-CTN-02 재개방 금지).

빈 번호 확인 (`find docs -name "${n}*"` · `grep -c` 000005):

```text
601514 files=0 index=0    601515 files=0 index=0
602070 files=0 index=0    602071 files=0 index=0
603000 files=0 index=0    603010 files=0 index=0
600022 files=0 index=0    600024 files=0 index=0    600025 files=0 index=0
```

(`602100` 대는 `990000_legacy_quarantine/602000_source_map/602100_…` 가 사용 중 — `000005` L1594)

Claude Code 기울기: B. A 는 배너가 권위 사용을 막고, C 는 `600023` §6 과 HD-CTN-04 에 부딪힌다. 결정은 OQ-IS-2.

**결정: B (Stage 3).**

| 항목 | 확정 |
|---|---|
| 대역 폴더 | `603000_containment/` (Readme: `603000_Readme_Containment.md`) |
| 워크패킷 폴더 | `603010_ctn1a_isolate_tenant_execute_containment/` |
| migration 머리 | `Workpacket: 603010` → G15 규칙 ①(폴더)로 ChangeContract 를 찾는다 |
| 생성 시점 | 폴더 생성 · `000005` · `000007` · Readme 등록은 **Stage 10** 에 한다 (Stage 6 처분 F-13 으로 통일) |
| Stage 1 ~ 6 초안 | 현 임시 위치 유지 (`000001` §5.4.2) |

### P-3 migration 번호 · 파일명

| 후보 | 내용 | clean DB | 현재 local DB | CHANGELOG · G15 |
|---|---|---|---|---|
| **M1** | 정규 `0180_<name>.sql` · prototype 은 `sql/migrations` 밖으로 | `0179` 공백(선례 `0073` · `0128`) | prototype 행(success=t) 이 남은 채 `0180` 이 적용됨 — 효과 중복(REVOKE 재실행 no-op) | prototype 처분 기록 필요 · prototype 이 밖으로 가면 G15 대상에서 빠짐 |
| **M2** | 정규 `0179_<new name>.sql` · prototype 제거 후 | 번호 연속 | `0179` 두 행(파일명 다름) — history 해석 혼동 · 현재 DB 는 어차피 Stage 9 에 쓰지 않음 | 처분 기록 필요 |
| **M3** | prototype 파일명 · 내용 그대로 재사용 | — | checksum 같아 L203 에서 skip → 재수행 증거가 안 남음 | HD-CTN-03 「정규 Stage 8 · 9 증거 아님」 · 「Codex 가 다시 수행」과 충돌 — 배제 권고 |

번호 겹침 후보: RG-06 `602061` L577 「새 migration 1개 | 함수 본문 교체용. 다음 순번은 `0179` 이나 이 문서에서 확정하지 않는다」 (H03-F1 용 — HD-CTN-04 로 CTN-1a 에 이관). RG-06 에 남은 H03-F2 도 migration 을 낼 수 있으므로 번호 순서 조정이 필요하다 (03_Logic OQ-LG-11).

파일명 이름 부분은 P-1 과 맞춘다(예: `<NNNN>_ctn1a_isolate_tenant_execute_containment.sql`). 결정은 OQ-IS-3.

**결정: M1 — 정규 migration 은 `0180_ctn1a_isolate_tenant_execute_containment.sql` (Stage 3).**

- 근거: `000002` §1 의 번호 재사용 금지 취지. `0179` 는 영구히 prototype(철회)으로 남긴다.
- 번호 공백 선례: `0073` · `0128`.
- RG-06(H03-F2)은 Stage 7 승인 순서에 따라 그다음 번호를 쓴다.

### P-4 HD-CTN-02 영구 기록 문서

| 후보 | 장점 | 단점 |
|---|---|---|
| **E1** 정규 ChangeContract (Stage 5) 안 §예외 | G15 가 읽는 문서 · Stage 7 승인과 한 곳 | 워크패킷 문서라 다른 작업이 예외 존재를 찾기 어렵다 |
| **E2** 새 governance 문서 `600022` 또는 `600024` (600020 · 600021 · 600023 옆) | `600020` HOLD 에 대한 예외를 같은 층에서 기록 · 이후 0-A-2 · 0-C 가 찾기 쉬움 | 새 governance 문서 = Human 결정 층 · 번호 선택 |
| E3 `601505` 개정 | 원천 곁 | `000001` §5.10 L444 · `600020` §1.4 — frozen/권위 보류 문서 수정 금지. 배제 |
| E4 `600023` 개정 | — | CTN-1a 는 RG 가 아님 (HD-CTN-04). 배제 |

Claude Code 기울기: E1 + E2 (E2 가 예외 자체, E1 이 구현 계약). 결정은 OQ-IS-6.

**결정: E1 ChangeContract + `603000` Readme 의 예외 레지스트리 + `600010` Tracker 1행 (Stage 3). E2(새 governance 문서)는 보류.**

## Open Questions For Claude

- OQ-IS-1 CHANGE_ID 에 Human 라벨 `ctn1a` 를 넣어도 되는가. — **결정: `ctn1a_isolate_tenant_execute_containment` 확정 (Stage 3)**
- OQ-IS-2 워크패킷 번호 · 폴더 (A · B · C). — **결정: B — `603000_containment/` 대역 + `603010_ctn1a_isolate_tenant_execute_containment/` (Stage 3).** 폴더 · 색인 등록은 **Stage 10** (Stage 6 처분 F-13)
- OQ-IS-3 migration 번호 (M1 · M2). — **결정: M1 — `0180_ctn1a_isolate_tenant_execute_containment.sql` (Stage 3)**
- OQ-IS-4 `000701` Antigravity 문면과 2026-09-22 운영 결정의 동기화 — CTN-1a 밖. — **결정: 백로그 (CTN-1a 밖) (Stage 3)**
- OQ-IS-5 `601500_Readme` §5 L146~147 의 "경계 문서 동시 추가" 규칙이 권위 보류 폴더에도 적용되는가. — **결정: 적용하지 않음 (권위 보류 폴더) (Stage 3)**
- OQ-IS-6 HD-CTN-02 영구 기록 위치 (E1 · E2). — **결정: E1 ChangeContract + `603000` Readme 예외 레지스트리 + `600010` Tracker 1행. E2 는 보류 (Stage 3)**
- OQ-IS-7 이 임시 폴더의 파일명 `00_` ~ `03_` 는 `000001` §5.4.2 `<DocumentType>.md` 와 다르다(`CodexScan` 은 승인 DocumentType 도 아님). 사용자 지시에 따랐다. Check-Governance 는 이 4개 파일로 새 finding 을 내지 않았다(합계 511 그대로) — 허용할지. — **결정: 허용 (`000002` §1.2.2 정렬용 두 자리 순번) (Stage 3)** · **결정: 전제 정정 (앵커, 2026-09-25). `000701` §15 L2371~2390 이 `00_CursorScan.md` ~ `07_VerificationResult.md` 와 `raw_logs/` 를 권장 구조로 직접 규정한다. 현재 파일명은 일탈이 아니라 §15 그대로다. `000001` §5.4.2 와의 차이는 §15 가 더 구체적인 것이다.**
- OQ-IS-8 `602061` L250 · L383 · L390 금지 호출의 절차 위반 finding 을 어디에 등록하는가. — **결정: CTN-1a 밖 — RG-06 정정 묶음에서 `RG-F16` (Stage 3)**

## Files Claude Code Must Not Modify

- `sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql` (HD-CTN-03 · 지시)
- `sql/migrations/0000`~`0178` 전부 (000701 §14.5)
- `601505` · `601509`~`601511` (`000001` §5.10)
- `601513` · `602060` · `602061` (비권위 · 이번 단계 범위 밖)
- `business_day_probe_out.txt` (이 세션이 만들지 않음)
- 이 폴더 밖의 모든 파일 (Stage 2 지시)

## Snapshot Decision

READY_FOR_CLAUDE_DESIGN — OQ-IS-2 · OQ-IS-3 · OQ-IS-6 은 Stage 3 에서 닫혔다. 03_Logic 의 prototype 처분(OQ-LG-9 · LG-10)은 Stage 7 에서 baseline 방식과 함께 확정한다.

## Draft Status

Verified (Claude) — Stage 4 반영 2026-09-25

## Stage 3 Review (Claude 앵커)

Stage 3 검토 · 결정은 2026-09-22. 본문에 반영된 HD-CTN-06 · SP-4 실측은 그 결정에서 지시한 후속 실측이며 2026-09-23 에 수행됐다.

이 절은 **앵커 판단**이다. Human 결정이 아니다 (Human 결정은 02_Overview "Human Decision" 절).

| 항목 | 결정 | 근거 | 반영 위치 |
|---|---|---|---|
| tier | Critical 확정 | DB migration · ACL 보안 경계 · cross-tenant 경로 (`000701` §9.5 · §31) | 02_Overview OQ-OV-6 |
| OQ-IS-1 | CHANGE_ID `ctn1a_isolate_tenant_execute_containment` 확정 | P-1 선례 비교 | 머리 · P-1 |
| OQ-IS-2 | B — `603000_containment/` + `603010_ctn1a_isolate_tenant_execute_containment/` · `Workpacket: 603010` | G15 규칙 ①(폴더) · `600023` §6 대역 · `600020` 권위 보류 회피 | P-2 · Candidate Affected Files |
| OQ-IS-3 | M1 — `0180_ctn1a_isolate_tenant_execute_containment.sql` | `000002` §1 번호 재사용 금지 취지 · 공백 선례 `0073` · `0128` | P-3 · Candidate Affected Files · 03_Logic |
| OQ-IS-4 | 백로그 (CTN-1a 밖) | 운영 결정 2026-09-22 | OQ 목록 |
| OQ-IS-5 | 적용하지 않음 (권위 보류 폴더) | `601500_Readme` 배너 | 수정 후보 표 · OQ 목록 |
| OQ-IS-6 | E1 ChangeContract + `603000` Readme 예외 레지스트리 + `600010` Tracker 1행 (E2 보류) | P-4 | P-4 · 수정 후보 표 |
| OQ-IS-7 | 허용 (`000002` §1.2.2 정렬용 두 자리 순번) | — | OQ 목록 |
| OQ-IS-8 | CTN-1a 밖 — RG-06 정정 묶음 `RG-F16` | HD-CTN-04 | OQ 목록 |
| Risk Note 6 | 실측으로 갱신 — B5 절차로 두 차례 177/177 | HD-CTN-06 (2026-09-23) | Risk Notes |
| `F-REPLAY` | 별도 워크패킷 후보로 등록. CTN-1a 에서 고치지 않는다 | `0093` → `23514` · `CHANGELOG` L151 · L177 | Known Gaps 아래 |
| SP-4 정정 | 앵커가 앞서 "현재 DB 에만 있는 role" 로 적은 추론은 실측(SP-4, 2026-09-23)으로 철회됐다 | SP-4 실측 | Known Gaps · 03_Logic S0 |

### 2026-09-23 실측으로 PASS 한 것

```text
committed migration 0000 ~ 0178 의 replay 재현성
  (disposable 컨테이너 + CHANGELOG L177 2단계 절차 · 두 차례 177/177)
clean baseline 의 S0 ACL 이 03_Logic 도출값과 일치
clean baseline 의 role parity (catchmenu_authority_owner 는 0169 가 생성)
```

### 아직 PASS 하지 않은 것

```text
CTN-1a 최종 설계 (Stage 4 · 6 검증 전)
TestPlan · ChangeContract (Stage 5)
Human Boundary Approval (Stage 7)
정규 migration 0180 (Stage 8)
Stage 9 독립 검증 · Stage 11 감사
```

"clean baseline PASS" 를 "CTN-1a 가 PASS 했다" 로 읽지 않는다.

## Stage 4 Architecture Review (2026-09-25)

이 절은 **앵커 판단**이다. Human 결정이 아니다. 검증자는 Codex(문서↔실제) · Cursor(문서↔문서 · 정책)이며, **앵커가 전건 수용했다.**

| # | 심각도 | 위치 | 발견 | 처분 · 반영 위치 |
|---|---|---|---|---|
| F-1 | 설계 결함 | 03_Logic V-3 · V-6 | B5 환경은 `migration_history` 가 비어 있어 `max(filename)` · `min(applied_at)` 이 NULL — 증명식이 성립하지 않는다 | 수용. V-3 · V-6 대체 · V-4 를 "가장 강한 증거"로 표시 · "자동 성립" 문장 삭제 → 03_Logic 「Stage 9 환경 … 증명」 |
| F-2 | 설계 결함 | 03_Logic Success Path · Output Conditions | `apply_migrations.py` 는 컨테이너 고정(L18~22)이라 B5 환경을 대상으로 지정할 수 없다 | 수용. psql 직접 실행 · history 행은 Stage 8 이 별도 `INSERT` · 구체 절차는 Stage 5 TestPlan · 도구 수정은 범위 밖 → 03_Logic |
| F-3 | 설계 결함 | 03_Logic I-6 · I-8 | 측정식이 모호해 재현 불가 | 수용. I-6 · I-8 측정식 확정 + I-10 · I-11 신설. I-6 참고값(현재 DB) `function_count=4039` · `acl_snapshot_md5=9362a19552986db3d549bf93de87b18e`, B5 기준값은 Stage 8 직전 재측정 → 03_Logic |
| F-4 | 누락 | 03_Logic S0 · S1 행렬 | `authenticator` 행 없음 | 수용. 두 행렬에 추가 (S1 현재 local 실측 f · f) → 03_Logic |
| F-5 | 사실 오류 | 03_Logic Clean Baseline 전제 | L177 목록 수 18개 | 수용. 19개로 정정 → 03_Logic |
| F-6 | 증거 보존 | 03_Logic B5 | manifest 미기록 | 수용. manifest SHA-256 `8958ad05…a6e389` 과 산출 방식 기록 → 03_Logic B5 표 |
| F-7 | 정리 | 01 Uncertainties | 닫힌 항목이 열린 것처럼 남아 있다 | 수용. 「닫힌 항목」 · 「열린 채로 남는 것」으로 분리 → 위 Uncertainties |
| Cursor 1 | 인용 오류 | 01 Risk Notes 3 · 03 간접 경로 | 「우연한 방벽」 출처는 §4.1.2 L351~367 이 아니라 §4.1.1 L331 | 수용. 두 곳 정정 (`p_reason` · `42883` 사실은 §4.1.2 L351~358) |
| Cursor 2 | 지위 과대 | 03 B5 · 02 Risk Summary | B5 를 "확정"으로 적었다 — 확정 권한은 Stage 7 | 수용. "Stage 7 승인 대상 · 앵커 권고"로 낮춤 → 01 · 02 · 03 |
| Cursor 3 | 혼동 | 03 §14.5 판정 | Draft 판정과 처분이 섞여 읽힌다 | 수용. 「판정은 Stage 3 · 처분은 Stage 7」 한 줄 명시 → 03_Logic |
| Cursor 4 | 원문 초과 | 02 Non-Goals 5 | 「(role · 판정 위치 · approver)」는 HD-CTN-02 원문에 없다 | 수용. 부연임을 밝히고 출처를 `601902` L1081 로 표기 → 02_Overview |
| Cursor 5 | 비권위 인용 | 03 조건 3 · 불변 선례 | `602061` HD-4 인용 · `601500_Readme` L33 의 주어는 `0168`/`0169` | 수용. HD-4 인용 삭제 · L33 을 일반 선례로 쓰지 않음 → 03_Logic |
| Cursor 6 | 인용 정밀도 | 01 Related Documentation | `601505` §9 근거에 절 제목 L924 가 들어갔다 | 수용. L956 · L968 만 남김 → 위 표 |
| Cursor 인용 정정 | 인용 정밀도 | 01 각처 | 절 제목 줄을 근거로 쓴 곳 | 수용. `601505` §8.1(p) L764 · §4.3 L381 · `601503` §9 L741~746 · `600020` §1.4 L81 · `600023` §4 L215 · `010004` L238 · L241 · `602000_Readme` L181 · L194 |

## Stage 4 Architecture Review 반영 (2026-09-25)

이 절은 **앵커 판단**이다. Human 결정이 아니다.

이 문서에서 바뀐 것: Risk Notes 3 인용 정정(Cursor 1) · Related Documentation 과 SOP · Index 인용 줄 정정(Cursor 6 · 인용 정정) · Uncertainties 를 닫힌 항목/열린 항목으로 분리(F-7) · 위 Stage 4 발견 표 추가 · Draft Status 갱신. Stage 3 Review 절의 clean baseline 행은 "앵커 권고 · 확정은 Stage 7"로 낮췄다.

## Stage 5 반영 (2026-09-25)

OQ-IS-7 의 전제를 정정했다 — `000701` §15 L2371~2390 이 `00_CursorScan.md` ~ `07_VerificationResult.md` 와 `raw_logs/` 를 권장 구조로 직접 규정하므로, 이 폴더의 `NN_` 파일명은 `000001` §5.4.2 로부터의 일탈이 아니라 §15 그대로다 (앵커, 2026-09-25).
