# 601906_Audit_Stage3_Adjacent_Domain_Codex.md

DocumentType: Audit
Status: Complete
Lifecycle: Audit
Last Updated: 2026-09-04
Verifier: Codex — Verifier A, 실측 축

## 판본 확인

독립 새 대화에서 사전 산출물 작성 맥락 없이 검증을 시작했다. 내용 열람 전에 `git rev-parse HEAD`, `git ls-files --eol`, SHA-256을 순서대로 확인했으며, 아래 세 판본과 커밋 `01dec6c79350c53054616c7179c02b5fc56aa298`가 모두 지시와 일치했다. 검증 절차 근거는 `000701` §47.1이고, 대상 판본의 역할은 `601902` §0 및 `601905` §0이다.

| 문서 | 지시서 SHA-256 | 실측 | 일치 |
|---|---|---|---|
| `601902_Register_Stage1_Business_Rules.md` | `1A42391B85B878C28876747821D66B3FE6ED95B70576367EFDD3635D857FD585` | `w/lf`; `1A42391B85B878C28876747821D66B3FE6ED95B70576367EFDD3635D857FD585` | 예 |
| `601905_Diagram_Tenant_Isolation_Axis_Model.md` | `33106696F0CA32CF814E10FDD5D9C9AB94FD7217431C8F3025B501F73AAB3351` | `w/lf`; `33106696F0CA32CF814E10FDD5D9C9AB94FD7217431C8F3025B501F73AAB3351` | 예 |
| `601901_Register_Stage0_Evidence_Collection.md` | `9C494EA29D02A8445976BF7CF38AE79C1AE71F8F0FEB53FF9EE0F5783F0195BE` | `w/lf`; `9C494EA29D02A8445976BF7CF38AE79C1AE71F8F0FEB53FF9EE0F5783F0195BE` | 예 |

## 종합

| 축 | 발견 | blocking | informational |
|---|---:|---:|---:|
| A1 내부 정합성 | 2 | 0 | 2 |
| A2 수직 추적성 | 1 | 1 | 0 |
| A3 실제 PostgreSQL 가능성 | 0 | 0 | 0 |
| A4 외부 타당성 | 1 | 1 | 0 |
| 합계(고유 finding) | 3 | 1 | 2 |

종합 판정은 **blocking 1건**이다. 같은 finding이 A2와 A4에 동시에 걸리므로 축별 합은 고유 finding 합과 다르다. 그 밖의 PostgreSQL 실측은 `601901` §17~§21과 `601904` §2~§6의 관측을 재현했다. `tenant_status`와 `isolation_state`는 독립 NOT NULL/CHECK 축이고, `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)`는 SECURITY DEFINER이며 `authenticated` EXECUTE가 있으나 authority-state 및 idempotency 참조가 없다. 명명된 scoped-containment 테이블은 0건이고, `security_audit_log`는 `601902` §1.10이 요구하는 명명 항목 전건을 강제하지 않는다(`601904` §2 C1, §3, §4, §5, §6 C5).

## Findings

| # | 축 | 지점 | 내용 | blocking | rule 근거 |
|---:|---|---|---|---|---|
| 1 | A2 · A4 | `601902` §1.10 (TI-10); `601905` §5 Q-1·Q-2 및 §8 TI-10 | `601902`는 `isolation_state` 변경이 `010004` §19의 “new scope if changed” 사건 자체라고 선언한다. 그러나 원천의 scope는 tenant/store 등 접근 범위이고, `isolation_state`의 `NONE ↔ ISOLATED`는 같은 tenant scope 안의 containment 상태 전이다. 원천은 audit에 previous/new scope를 **scope가 바뀐 경우** 기록하라고 했지 isolation state를 scope로 재분류하지 않았다(`010004` §4·§19; `010640` §4~§6). 이 의미 변경을 `601905`가 Q-1(상태 전이)과 Q-2(previous/new scope)를 필수 연결로 전달하므로, 그대로 Stage 4를 진행하면 state와 scope가 혼동된 감사 계약을 만들 수 있다. 상태 전이 전후값의 감사 필요 자체는 타당하지만, 그것을 previous/new **scope**로 강제하는 근거는 없다. | 예 | acceptance 3 — `601902` TI-N이 원천 8건과 어긋남; acceptance 4 — 모델대로 구현해도 선언된 scope/audit 의미가 정확히 강제되지 않음 |
| 2 | A1 | `601905` §8 말미 | 추적표에는 `TI-1`~`TI-12` 12행이 있으나 말미가 “11건 전건 기록”이라고 적혀 있다. 표 자체는 12건을 채웠으므로 bookkeeping 오기다. | 아니오 — informational | 표현/계수 명료화이며 모델 의미나 강제 가능성을 바꾸지 않음 |
| 3 | A1 | `601905` §0·§0.1·§9 | 개정 이력과 §1·§8은 TI-12를 반영했지만, 본문 범위와 입력·근거 표 일부는 여전히 `TI-1~TI-11`, `HD-...-1~9`라고 적는다. 실제 TI-12 표현은 존재하므로 누락 모델이 아니라 갱신되지 않은 범위 표기다. | 아니오 — informational | 표현을 더 명료하게 할 수 있는 경우; acceptance의 non-blocking 항목 |

## TI-N 추적표

| `TI-N` | 601901 근거 | 601905 표현 | 완결 |
|---|---|---|---|
| `TI-1` | 원천 5건과 발견 직접원천 3건의 지위 및 A1/A1' 구분(`601901` §3.1·§3.1', §12 Q-P6·Q-P12) | 정책 채택은 상태모델 요소가 아니어서 §6·§7.3 D-1·§8에 비도식 기록 | 예 — 비도식 사유 명시 |
| `TI-2` | tenant 2값 CHECK와 scoped containment family의 분리 필요(`601901` §4, §7.2, §12 Q-P10; `010650` §4·§35·§36) | §1 두 축과 별도 점선 scoped containment, 자동 승격 없음; §5 Q-9 | 예 |
| `TI-3` | authority state와 자동 authority 경계(`601901` §8.2·§12 Q-P9; `010630` §6·§27~§30; `010650` §35) | §2 발동 주체/전제, §3 gate, §5 Q-4 | 예 |
| `TI-4` | release stronger authority와 동일 actor 단독 해제 anti-pattern(`601901` §8.3·§12 Q-P9; `010650` §30·§35·§38; `010630` §18) | §2 해제 요건 및 Q-7 승인 분리 | 예 |
| `TI-5` | containment 자동화와 release의 stronger authority 비대칭(`601901` §8.3; `010650` §35) | §2 비대칭 다이어그램 | 예 |
| `TI-6` | one business action key, scope binding, 현 isolation 함수의 idempotency 미참조(`601901` §9.2·§18.2·§12 Q-P11; `010660` §4·§5·§37~§38) | §4 신뢰경계 안 검증/6항 파생, §5 Q-5·Q-6 | 예 |
| `TI-7` | provider merchant와 SaaS Merchant Account 어휘 차이(`601901` §6.2·§10.2·§12 Q-P4; `010640` §4; `000170` §3~§6) | §5 Q-10 점선 mapping | 예 — 물리 구조 유보를 보존 |
| `TI-8` | applicable scope만 필수이나 필요한 scope 누락 시 처리 금지(`601901` §6.2·§12 Q-P5; `010640` §2·§5·§42) | §5 Q-2·Q-3; §6 간극 | 예 |
| `TI-9` | cross-tenant contamination trigger와 작은 containment action(`601901` §5.2·§12; `010004` §20) | §5 Q-8→Q-1, Q-8···Q-9 점선 | 예 |
| `TI-10` | audit context 채록 및 현재 audit 자산 결측(`601901` §5.2·§17.2·§20.2; `010004` §19) | §5 Q-1·Q-2와 연결, §6 간극 | **아니오 — Finding 1** |
| `TI-11` | runtime deferral와 authorization packet 11항(`601901` §5.2; `010004` §24·§26·§29) | 상태모델 요소가 아니어서 §6·§7.2 P-10·§7.3 D-1·§8에 게이트로 기록 | 예 — 비도식 사유 명시 |
| `TI-12` | 계층 상태 6축과 상위 상태 대체 금지(`601901` §10.2; `601702` §1.27·§1.28) | §1 계층 상태 분리 경고와 §8 추적행 | 예 |

## 실행 쿼리 전문

아래 쿼리는 모두 `PGOPTIONS="-c default_transaction_read_only=on"`으로 실행했다. 금지 함수 및 추가 금지 함수는 호출하지 않았다. 관측 시각은 `2026-09-04 13:28:39.445232+00`, 서버는 PostgreSQL 17.6, `default_transaction_read_only = on`이었다. 재측정 범위와 비교 기준은 `601901` §17~§21 및 `601904` §7이다.

```sql
\pset pager off
SHOW default_transaction_read_only;
SELECT current_timestamp, version();

SELECT column_name,is_nullable,data_type,column_default
FROM information_schema.columns
WHERE table_schema='catchmenu_hq'
  AND table_name='tenants'
  AND column_name IN ('tenant_status','isolation_state')
ORDER BY column_name;

SELECT conname,pg_get_constraintdef(oid,true)
FROM pg_constraint
WHERE conrelid='catchmenu_hq.tenants'::regclass
  AND (pg_get_constraintdef(oid,true) ILIKE '%tenant_status%'
       OR pg_get_constraintdef(oid,true) ILIKE '%isolation_state%')
ORDER BY conname;

SELECT p.oid::regprocedure,p.prosecdef,p.proconfig,p.proacl,
       p.prosrc ILIKE '%AUTHORITY_ALLOWED%' AS allowed_ref,
       p.prosrc ILIKE '%idempotency_keys%' AS idem_ref,
       p.prosrc ILIKE '%security_audit_log%' AS audit_ref
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='catchmenu_common'
  AND p.proname='isolate_tenant';

SELECT column_name,data_type,is_nullable
FROM information_schema.columns
WHERE table_schema='catchmenu_common'
  AND table_name='security_audit_log'
ORDER BY ordinal_position;

SELECT conname,pg_get_constraintdef(oid,true)
FROM pg_constraint
WHERE conrelid='catchmenu_common.security_audit_log'::regclass
ORDER BY conname;

SELECT table_schema,table_name
FROM information_schema.tables
WHERE table_schema LIKE 'catchmenu%'
  AND (table_name ILIKE '%isolat%'
       OR table_name ILIKE '%contain%'
       OR table_name ILIKE '%circuit%'
       OR table_name ILIKE '%quarant%')
ORDER BY 1,2;

SELECT
 count(*) FILTER (WHERE p.prosrc ILIKE '%AUTHORITY_ALLOWED%') AS authority_allowed_refs,
 count(*) FILTER (WHERE p.prosrc ILIKE '%AUTHORITY_REVIEW_REQUIRED%') AS review_refs,
 count(*) FILTER (WHERE p.prosrc ILIKE '%AUTHORITY_MULTI_PARTY_REQUIRED%') AS multi_refs,
 count(*) FILTER (WHERE p.prosrc ILIKE '%stable_action_identity%') AS stable_action_refs
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname LIKE 'catchmenu%';
```

주요 결과는 다음과 같다(`601904` §2 C1·§3~§6과 일치).

```text
default_transaction_read_only = on
isolation_state  NOT NULL text DEFAULT 'NONE'; CHECK IN ('NONE','ISOLATED')
tenant_status    NOT NULL text DEFAULT 'TRIAL'; CHECK IN ('ACTIVE','TRIAL','SUSPENDED','CANCELLED','TERMINATED')
isolate_tenant   SECURITY DEFINER; authenticated EXECUTE;
                 AUTHORITY_ALLOWED ref=false; idempotency_keys ref=false; security_audit_log ref=true
named isolation/containment/circuit/quarantine tables = 0
AUTHORITY_ALLOWED refs=0; REVIEW_REQUIRED refs=0; MULTI_PARTY_REQUIRED refs=0; stable_action_identity refs=0
security_audit_log = 16 columns; actor role/surface/device/previous scope/new scope/
                     authority reference/policy reference/evidence reference named columns absent;
                     JSON key CHECK absent
```

`NO CONCERNS FOUND` 조건에는 해당하지 않는다. blocking 1건과 informational 2건을 위에 명시했다.
