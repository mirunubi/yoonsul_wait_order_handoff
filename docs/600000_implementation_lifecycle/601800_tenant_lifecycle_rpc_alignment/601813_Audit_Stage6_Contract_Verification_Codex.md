# 601813_Audit_Stage6_Contract_Verification_Codex.md

Status: Complete
Lifecycle: Audit
DocumentType: Audit
Last Updated: 2026-08-29

## §0 검증 조건

`000701` §9.16·§37·§47.1에 따른 Stage 6 Critical tier 독립 검증이다. `601809`·`601810`·`601811`·`601812` 네 문서를 동등한 직접 검증 대상으로 삼고, `601801`·`601802`·`601803`·`601807`·`601808` 및 라이브 PostgreSQL catalog·`prosrc`를 대조했다.

DB 접속에서 `SHOW default_transaction_read_only;`는 `on`이었다(Q-DB1·Q-DB2). 금지 함수는 호출하지 않았다. `601814`·`601815`는 읽지 않았다.

## 종합

| 축 | 발견 | blocking | informational |
|---|---:|---:|---:|
| 내부 정합성 | 5 | 3 | 2 |
| 수직 추적성 | 3 | 2 | 1 |
| 실제 PostgreSQL 가능성 | 4 | 4 | 0 |
| 외부 타당성 | 2 | 1 | 1 |
| **합계** | **14** | **10** | **4** |

## Findings

| # | 축 | 지점 | 내용 | blocking | rule 근거 |
|---|---|---|---|---|---|
| F-1 | 실제 PostgreSQL 가능성 | `601812` §2.5~§2.6, D-26·D-27; `601811` §4 TP-P-4~P-5·§5 | D-26은 기존 `isolate_tenant(..., p_isolate boolean, ...)` 시그니처와 EXECUTE ACL을 보존하면서 `p_isolate=false`일 때 `isolation_state='NONE'`을 쓰도록 요구한다(`601812` §2.5 L204-L214, §2.6 L216-L226). 라이브 함수는 `authenticated`가 EXECUTE할 수 있는 SECURITY DEFINER이고 `p_isolate` 기본값까지 가진다(Q-DB1·Q-DB2; `601802` §5.1·§9.2). 따라서 D-27의 원인 해소·Human 승인·감사 3요건 경로를 거치지 않고 D-26으로 직접 해제할 경로가 남는다. TestPlan은 D-27의 3요건만 검사하고 D-26의 `false` 우회를 거부하는 검사가 없다(`601811` §4 L122-L131, §5 L137-L154). `HG-A-8`의 세 요건(`601801` §1.8 L220-L230)이 PostgreSQL에서 강제되지 않는다. | **예** | **rule 1·4·5** |
| F-2 | 실제 PostgreSQL 가능성 | `601812` §2.5 D-27~D-29·FO-7; §8; `601809` §4.2 | 계약은 신규 D-27~D-29에 GRANT를 하지 않으면 “소유자 외에는 도달하지 못한다”고 단정한다(`601812` §2.5 L212-L214). 그러나 PostgreSQL의 postgres 소유 신규 함수 기본 ACL은 `{=X/postgres,postgres=X/postgres}`로 PUBLIC EXECUTE다(Q-DB2). 라이브 `authenticated`는 `catchmenu_common` USAGE를 가진다(Q-DB2). FO-7이 GRANT·REVOKE를 모두 금지하므로(`601812` §4.2 L270-L289), 계약대로 생성한 신규 해제·접근판정·귀책확정 함수는 owner-only가 되지 않는다. 특히 D-29의 “승인된 Human 역할” 경계(`601801` §1.15 L576-L601)를 권한으로 강제하지 못한다. | **예** | **rule 3·4·5** |
| F-3 | 내부 정합성 | `601812` §2.5 D-26~D-29; `601811` §4·§9·§10 | 네 함수 조작은 입력 인자명만 정하고 RETURNS, LANGUAGE, SECURITY DEFINER/INVOKER, `SET search_path`, 기본 인자, 오류·성공 반환 계약을 확정하지 않았다(`601812` §2.5 L200-L214). 라이브 D-26은 `RETURNS jsonb`, PL/pgSQL, SECURITY DEFINER, 고정 search_path, 뒤 3개 인자 기본값을 갖는다(Q-DB1·Q-DB2). Stage 8 구현자는 이 속성을 보존할지, 신규 함수가 어떤 속성과 반환형을 가질지 선택해야 한다. TP-P는 “호출 성공”만 요구하고 구체 반환·보안 속성 기대값을 주지 않는다(`601811` §4 L115-L131); TP-R-10은 D-26 ACL 불변만 본다(`601811` §9 L218-L238). | **예** | **rule 1·3** |
| F-4 | 외부 타당성 | `601809` §2 A-5·A-8; `601810` I-12~I-18; `601812` D-28·§7 | D-28은 `p_operation text`를 받는 판정 함수를 생성할 뿐 허용 operation 어휘와 tenant_status별 결과를 확정하지 않았고, 기존 runtime RPC·세션·외부 전달 경로가 D-28을 호출하도록 하는 허용 조작도 없다(`601812` §2.5 L200-L207, §7 L338-L356). Overview는 일반 접근과 CatchMenu 통제 경로 차단을 구현 대상으로 삼고(`601809` §2 L52-L68), Logic은 ISOLATED에서 모든 일반 runtime을 거부해야 한다고 선언한다(`601810` §2 L73-L103). 독립 helper의 존재만으로 기존 호출 경로에 대한 fail-closed가 강제되지 않으며, Stage 8 구현자는 operation 분류와 연결 지점을 스스로 선택할 수 없다/선택해야 한다. | **예** | **rule 3·4·5** |
| F-5 | 수직 추적성 | `601809` §2 A-9; `601810` I-33~I-41; `601811` TP-E; `601812` D-2·D-10~D-16 | `HG-A-7`은 격리 중 수신·검증·불변 보존·side effect 보류·해제 후 idempotent 재처리를 요구한다(`601801` §1.7 L190-L218). Logic과 TestPlan은 이를 I-33~I-41과 TP-E-1~E-9로 옮겼다(`601810` §5 L139-L155; `601811` §8 L201-L216). 그러나 계약의 허용 조작은 queue 테이블·제약·인덱스만 만들고, 외부 event 수신자가 삽입하거나 side effect를 보류·재처리하는 함수/트리거/기존 호출자 변경을 허용하지 않는다(`601812` §2.1 L120-L136, §2.2 L165-L171, §2.5 L200-L207). D-1~D-29만 구현하면 TP-E 동작은 생기지 않는다. | **예** | **rule 1·4·5** |
| F-6 | 수직 추적성 | `601809` §2 A-10; `601810` I-48~I-53; `601811` §12.1; `601812` D-3·D-17~D-22 | `HG-A-5`·`HG-A-9.4`는 플랫폼 귀책/장기 격리 review 자동 생성, 미처리 review 청구 전 경고, trial extension review를 요구한다(`601801` §1.5 L143-L167, §1.9 L271-L278). 계약은 `tenant_billing_reviews` 테이블만 만들며 D-26·D-27 본문 요구나 별도 함수에 review 생성·경고 생성이 없다(`601812` §2.1 L138-L150, §2.2 L172-L177, §2.5~§2.6 L200-L226). TestPlan은 I-49~I-53을 미검증/물리 확정 전 SKIP으로 남겼고(`601811` §12.1 L277-L290), `601812` 확정 뒤에도 대응 Test를 추가하지 않았다. 계약대로 구현해도 자동 review와 경고가 강제되지 않는다. | **예** | **rule 1·4·5** |
| F-7 | 실제 PostgreSQL 가능성 | `601810` I-29~I-31; `601811` TP-C; `601812` §5 D-6·§2.5 | D-6은 `(tenant_id,event_type,idempotency_key)` UNIQUE지만 요청 내용의 동일/상이 여부를 비교할 물리 hash/snapshot을 정하지 않았다(`601812` §2.2 L159-L164, §5 L291-L311). D-27은 idempotency key를 받지 않고, 오래된 요청 방지를 위한 version·expected-state·순서 token도 D-1~D-29에 없다(`601812` §2.1 L102-L150, §2.5 L200-L207). 따라서 같은 키·다른 내용 거부, 해제 재실행, 오래된 요청의 최신 상태 되돌림 방지에 둘 이상의 합리적 구현 선택이 남고 TP-C-1~C-3 기대를 계약만으로 보장하지 못한다(`601811` §7 L184-L199). | **예** | **rule 1·3·4** |
| F-8 | 내부 정합성 | `601812` §6·D-1~D-29; `601810` Q-3 | §6은 한 트랜잭션 안에 `isolation_state`, 사건, “세션 차단용 DB 기록”, “후속 작업 outbox”를 요구한다(`601812` §6 L313-L336). 그러나 D-1~D-29에는 세션 차단 기록이나 송신 outbox 테이블·행 조작이 없고 D-26 본문 의무도 상태와 사건까지만 적는다(`601812` §2.1~§2.6 L94-L226). 라이브 catalog에도 계약 대상 이름의 outbox/세션 차단 객체가 관측되지 않았다(Q-DB1). §6은 outbox 물리 표현을 범위 밖으로 돌려 같은 절의 “한 트랜잭션 안” 요구와 충돌한다. | **예** | **rule 1·3·4** |
| F-9 | 실제 PostgreSQL 가능성 | `601812` D-1·D-27; `601811` TP-P-4~P-6 | D-1은 ISOLATE/RELEASE 사건, `cause_resolved`, `human_approved`를 두고 D-27은 `p_event_id`를 받지만, D-27이 기존 ISOLATE 행을 갱신하는지 RELEASE 행을 추가하는지, 어느 행이 감사 기록인지, 세 요건 확인과 상태 변경을 어떤 단일 조건으로 묶는지 정하지 않았다(`601812` §2.1 L102-L118, §2.5 L204-L207). TP-P-4~P-6은 세 요건과 감사 행 생성을 기대한다(`601811` §4 L122-L126). 서로 다른 합리적 구현이 가능하고 일부는 TP-P-6 기대와 달라질 수 있다. | **예** | **rule 1·3·4** |
| F-10 | 내부 정합성 | `601811` BL-13·PRE-3; `601802` 범위 | PRE-3은 BL-1~BL-13 재측정이 `601802` 기록과 일치해야 한다고 요구한다(`601811` §3 L99-L110). 그러나 BL-13의 `merchant_accounts` 행 수와 `stores.merchant_account_id` 연결은 `601802`의 측정 대상 5군과 실행 쿼리에 포함되지 않았다(`601802` §4 L58-L66, §7 L139-L183, §11 L266-L382). 따라서 PRE-3의 비교 기준이 없으며, 계약대로 구현하기 전 gate 자체가 문서 기대대로 판정될 수 없다. | **예** | **rule 1·3** |
| I-1 | 내부 정합성 | `601811` BL-14 | BL-14의 함수 수 기대 `before + 3`은 결과적으로 D-27~D-29 신규 3건과 맞지만, 근거 문구는 “D-26·D-27·D-29가 신규 3건”이라고 써서 기존 D-26을 신규로 세고 D-28을 누락했다(`601811` §2 L91-L94; `601812` §2.5 L204-L207). 수치 기대는 맞으므로 informational이다. | 아니오 | informational |
| I-2 | 수직 추적성 | `601811` PRE-4·AC-12 | 원작자 배제 gate와 AC가 `601809`~`601811`만 열거하고 `601812` 원작자를 빠뜨렸다(`601811` §3 L103-L110, §11 L258-L270). 이번 검증은 실제로 네 문서 원작자를 배제했으므로 본 결과의 독립성에는 영향이 없지만, 문서화된 후속 gate 범위는 §37 요구보다 좁다. | 아니오 | informational |
| I-3 | 내부 정합성 | `601812` D-25 | D-25는 허용 조작 식별자 안에 있으나 실제 조작이 아니라 “트리거를 만들지 않는다”는 비생성 선언이다(`601812` §2.4 L190-L198). D-1~D-29 실행 목록을 기계적으로 세는 경우 주의가 필요하지만 구현 선택지를 만들지는 않는다. | 아니오 | informational |
| I-4 | 외부 타당성 | 라이브 catalog; `601812` D-1~D-24 | 신규 테이블 3건, 제약명 16건, 인덱스명 3건, 신규 함수 시그니처 3건은 라이브에 존재하지 않아 이름 충돌이 관측되지 않았다(Q-DB1). `tenants.id`는 uuid PK이고 두 상태 컬럼은 text NOT NULL이므로(`601802` §6.1 L98-L105; Q-DB1), D-1~D-24의 기본 DDL 형태 자체는 PostgreSQL 17.6에서 성립 가능한 구조다. 의미 강제 결함은 별도 blocking findings에 기록했다. | 아니오 | informational |

Blocker 10건이 있으므로 `NO CONCERNS FOUND`는 해당하지 않는다.

## 수직 추적 확인

| `HG-A-N` | Logic | TestPlan | ChangeContract | 완결 |
|---|---|---|---|---|
| `HG-A-1` | `I-1`·`I-4`·`I-5`·`I-13` | `BL-12`, `TP-S-1`~`TP-S-12` | `D-28`, `FO-15` | **아니오** — D-28 판정 어휘·연결 미확정(F-4) |
| `HG-A-2` | `I-12`·`I-14`·`I-19`·`I-40` | `TP-P-9`·`TP-P-10`, `TP-E-6`; 기능별 9행은 이월 | `D-28`, `FO-6` | **아니오** — helper가 runtime 경로에 연결되지 않음(F-4) |
| `HG-A-3` | `I-9`·`I-26` | `TP-P-2`, `TP-N-1`·`TP-N-2` | `D-26`, `FO-5` | 예 |
| `HG-A-4` | `I-42`~`I-45` | `TP-E-8`·`TP-E-9`, `TP-R-9`; `I-42`·`I-43` 미검증 | `D-2.usage_counted`, `X-6` | **아니오** — 산정 runtime 부재(F-5) |
| `HG-A-5` | `I-48`~`I-51` | `TP-N-12`·`TP-N-13`; `I-49`~`I-51` 미검증 | `D-3`, `D-17`~`D-22`, `X-6` | **아니오** — 자동 review·경고 경로 부재(F-6) |
| `HG-A-6` | 경계 유지, `HD-0-A-2-7`에 따라 직접 invariant 없음 | `TP-N-3`, `AC-7`·`AC-8` | `X-1`, `FO-2` | 예 — 후속 워크패킷 이월이 명시됨(`601801` §1.6 L169-L188) |
| `HG-A-7` | `I-33`~`I-41` | `TP-E-1`~`TP-E-9`, `TP-N-14`·`TP-N-15`·`TP-N-18` | `D-2`, `D-10`~`D-16` | **아니오** — queue 동작 경로 부재(F-5) |
| `HG-A-8` | `I-22`·`I-23`·`I-56` | `TP-P-4`~`TP-P-6`, `TP-N-7`·`TP-N-8` | `D-1`, `D-27` | **아니오** — D-26 직접 해제 우회·D-27 의미 미확정(F-1·F-9) |
| `HG-A-9` | `I-2`·`I-5`·`I-12`~`I-14`·`I-24`·`I-25`·`I-46`·`I-52`·`I-53` | `TP-S`, `TP-N-7`·`TP-N-8`, `TP-R-7` | `D-27`·`D-28`, `FO-15`, `D-3` | **아니오** — 접근·trial review 강제 부재(F-4·F-6) |
| `HG-A-10` | `I-21`·`I-27`~`I-32` | `BL-9`, `TP-C-1`~`TP-C-5`, `TP-R-10` | `D-6`, §5·§6 | **아니오** — 오래된 요청·해제 멱등성·outbox 경계 미확정(F-7·F-8) |
| `HG-A-11` | `I-6`~`I-9` | `TP-N-3`~`TP-N-5`·`TP-N-10` | `X-1`·`X-5`, `FO-2`·`FO-5`·`FO-8` | 예 |
| `HG-A-12` | `I-10`·`I-11` | `BL-13`, `TP-N-9`, `TP-R-8` | `FO-9`, `X-2` | 예 — BL-13 baseline 출처 문제는 F-10 |
| `HG-A-13` | `I-15`~`I-18` | `TP-P-10`, `TP-N-16` | `D-28`, §7 | **아니오** — fail-closed 연결 부재(F-4) |
| `HG-A-14` | 직접 invariant 없음; 후속 포인트 워크패킷 이월 | `TP-N-10`, `AC-9` | `X-7`, `FO-16` | 예 — 명시적 후속 이월(`601801` §1.14 L513-L564) |
| `HG-A-15` | `I-54`~`I-56` | `TP-P-7`·`TP-P-8`, `TP-N-12` | `D-1`, `D-8`, `D-29` | **아니오** — 신규 D-29 기본 PUBLIC EXECUTE(F-2) |

## D-1 ~ D-29 실행 가능성

| `D-N` | PostgreSQL 실행 가능 | 근거 |
|---|---|---|
| D-1 | 예 — 구조 생성 가능 | 대상명 부재, uuid/text/boolean/timestamptz·`gen_random_uuid()` 사용 가능(Q-DB1); `601812` §2.1 L98-L118 |
| D-2 | 예 — 구조 생성 가능 | 대상명 부재, jsonb 포함 타입 사용 가능(Q-DB1); `601812` §2.1 L120-L136. 동작 완결성은 F-5 |
| D-3 | 예 — 구조 생성 가능 | 대상명 부재(Q-DB1); `601812` §2.1 L138-L150. 자동 생성 동작은 F-6 |
| D-4 | 예 | D-1 PK 이름 충돌 없음(Q-DB1); `601812` §2.2 L159 |
| D-5 | 예 | `catchmenu_hq.tenants(id)`는 uuid PK(`601802` §6.1; Q-DB1); `601812` L160 |
| D-6 | 예 — UNIQUE 생성 가능 | 이름 충돌 없음(Q-DB1); `601812` L161. 요청 내용 판별 부족은 F-7 |
| D-7 | 예 | text CHECK 생성 가능; `601812` L162 |
| D-8 | 예 | text CHECK 생성 가능; `601812` L163 |
| D-9 | 예 | schema 내 index명 충돌 없음(Q-DB1); `601812` L164 |
| D-10 | 예 | D-2 PK 이름 충돌 없음(Q-DB1); `601812` L165 |
| D-11 | 예 | tenants uuid FK 성립; `601812` L166 |
| D-12 | 예 — UNIQUE 생성 가능 | 이름 충돌 없음(Q-DB1); `601812` L167 |
| D-13 | 예 | text CHECK 생성 가능; `601812` L168 |
| D-14 | 예 | text CHECK 생성 가능; `601812` L169 |
| D-15 | 예 | text CHECK 생성 가능; `601812` L170 |
| D-16 | 예 | index명 충돌 없음(Q-DB1); `601812` L171 |
| D-17 | 예 | D-3 PK 이름 충돌 없음(Q-DB1); `601812` L172 |
| D-18 | 예 | tenants uuid FK 성립; `601812` L173 |
| D-19 | 예 | D-1 선행 생성 시 uuid FK 성립; `601812` L174 |
| D-20 | 예 | text CHECK 생성 가능; `601812` L175 |
| D-21 | 예 | text CHECK 생성 가능; `601812` L176 |
| D-22 | 예 | index명 충돌 없음(Q-DB1); `601812` L177 |
| D-23 | 예 | 신규 3테이블에 ENABLE RLS 가능; `601812` §2.3 L179-L188 |
| D-24 | 예 | 신규 3테이블에 FORCE RLS 가능; owner postgres는 BYPASSRLS임(Q-DB1); `601812` L184 |
| D-25 | 해당 없음 — 비생성 선언 | 실행 SQL이 아니라 트리거를 만들지 않는다는 항목(`601812` §2.4 L190-L198) |
| D-26 | **조건부/계약만으로 불충분** | 동일 identity signature의 CREATE OR REPLACE 자체는 가능하나 라이브 RETURNS·SECURITY·search_path·defaults를 계약이 확정하지 않음(Q-DB1·Q-DB2; F-1·F-3) |
| D-27 | **아니오 — 실행 의미 미확정** | 함수 생성에 필요한 RETURNS/LANGUAGE/SECURITY/search_path/body가 없고, release 사건·3요건 원자화가 미확정(`601812` L205; F-2·F-3·F-9) |
| D-28 | **아니오 — 실행 의미 미확정** | RETURNS·보안 속성·operation 어휘·상태별 판정·호출 연결이 미확정(`601812` L206, §7; F-2~F-4) |
| D-29 | **아니오 — 권한/실행 의미 미확정** | RETURNS·보안 속성·본문 미확정이며 GRANT/REVOKE 금지 시 기본 PUBLIC EXECUTE(Q-DB2; `601812` L207·FO-7; F-2·F-3) |

## DB 실측 쿼리

### Q-DB1 — catalog·prosrc·충돌·RLS

```sql
SHOW default_transaction_read_only;
SELECT current_database(), current_setting('server_version'), clock_timestamp();

SELECT n.nspname, p.proname, p.oid::regprocedure AS signature,
       pg_get_function_result(p.oid) AS result_type,
       l.lanname AS language, p.prosecdef, p.proleakproof, p.provolatile,
       p.proparallel, p.proconfig, r.rolname AS owner, p.proacl,
       has_function_privilege('public', p.oid, 'EXECUTE') AS public_execute,
       md5(p.prosrc) AS prosrc_md5
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
JOIN pg_language l ON l.oid=p.prolang
JOIN pg_roles r ON r.oid=p.proowner
WHERE n.nspname='catchmenu_common'
  AND p.proname IN ('isolate_tenant','release_tenant_isolation',
                    'is_tenant_access_allowed','confirm_isolation_attribution')
ORDER BY 2,3;

SELECT pg_get_functiondef(p.oid)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='catchmenu_common' AND p.proname='isolate_tenant';

SELECT d.defaclrole::regrole, d.defaclnamespace::regnamespace,
       d.defaclobjtype, d.defaclacl
FROM pg_default_acl d WHERE d.defaclobjtype='f' ORDER BY 1,2;

SELECT n.nspname, c.relname, c.relkind, c.relrowsecurity,
       c.relforcerowsecurity, r.rolname AS owner
FROM pg_class c
JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN pg_roles r ON r.oid=c.relowner
WHERE (n.nspname='catchmenu_common' AND
       c.relname IN ('tenant_isolation_events','tenant_isolation_queue',
                     'tenant_billing_reviews'))
   OR c.relname ~* '(outbox|session.*block|block.*session|isolation)'
ORDER BY 1,2;

SELECT n.nspname, c.relname, con.conname,
       pg_get_constraintdef(con.oid,true)
FROM pg_constraint con
JOIN pg_class c ON c.oid=con.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE con.conname IN (
 'tenant_isolation_events_pkey','fk_tenant_isolation_events_tenant_id',
 'uq_tenant_isolation_events_idem','chk_tenant_isolation_events_type',
 'chk_tenant_isolation_events_prov_attr','tenant_isolation_queue_pkey',
 'fk_tenant_isolation_queue_tenant_id','uq_tenant_isolation_queue_event',
 'chk_tenant_isolation_queue_provider_kind','chk_tenant_isolation_queue_hold_reason',
 'chk_tenant_isolation_queue_hold_state','tenant_billing_reviews_pkey',
 'fk_tenant_billing_reviews_tenant_id','fk_tenant_billing_reviews_event_id',
 'chk_tenant_billing_reviews_kind','chk_tenant_billing_reviews_state');

SELECT schemaname,indexname,tablename,indexdef FROM pg_indexes
WHERE indexname IN ('idx_tenant_isolation_events_tenant',
                    'idx_tenant_isolation_queue_hold',
                    'idx_tenant_billing_reviews_open');

SELECT n.nspname, p.proname, p.oid::regprocedure,
       p.prosrc ILIKE '%isolation_state%' AS isolation_ref,
       p.prosrc ILIKE '%tenant_status%' AS tenant_ref,
       p.prosrc ILIKE '%outbox%' AS outbox_ref,
       p.prosrc ~* '(session.*block|block.*session)' AS session_block_ref
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ~* '(isolation_state|tenant_status|outbox|session.*block|block.*session)'
ORDER BY 1,2,3;

SELECT table_schema, table_name, column_name, data_type,
       is_nullable, column_default
FROM information_schema.columns
WHERE (table_schema='catchmenu_hq' AND table_name='tenants'
       AND column_name IN ('id','tenant_status','isolation_state'))
   OR column_name ~* '(outbox|isolation|session.*block|block.*session)'
ORDER BY 1,2,3;

SELECT rolname, rolsuper, rolbypassrls, rolcanlogin
FROM pg_roles
WHERE rolname IN ('postgres','anon','authenticated','service_role',
                  'catchmenu_authority_owner')
ORDER BY 1;
```

### Q-DB2 — 기본 ACL·schema usage·함수 기본 인자

```sql
SHOW default_transaction_read_only;
SELECT acldefault('f', (SELECT oid FROM pg_roles WHERE rolname='postgres'))
  AS postgres_default_function_acl;

SELECT r.rolname,
       has_schema_privilege(r.rolname,'catchmenu_common','USAGE') AS schema_usage,
       has_function_privilege(
         r.rolname,
         'catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)',
         'EXECUTE') AS isolate_execute
FROM pg_roles r
WHERE r.rolname IN ('anon','authenticated','service_role','postgres',
                    'catchmenu_authority_owner')
ORDER BY 1;

SELECT p.proname, p.proargnames,
       pg_get_expr(p.proargdefaults,0) AS arg_defaults,
       p.pronargdefaults,
       pg_get_function_identity_arguments(p.oid) AS identity_args,
       pg_get_function_arguments(p.oid) AS full_args
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='catchmenu_common' AND p.proname='isolate_tenant';

SELECT count(*) AS policies_all FROM pg_policies;
SELECT schemaname, tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname IN ('catchmenu_common','catchmenu_hq')
  AND tablename IN ('tenants','security_audit_log')
ORDER BY 1,2,3;
```

Q-DB1·Q-DB2는 다음 read-only 접속으로 실행했다.

```powershell
$sql | docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres
```
