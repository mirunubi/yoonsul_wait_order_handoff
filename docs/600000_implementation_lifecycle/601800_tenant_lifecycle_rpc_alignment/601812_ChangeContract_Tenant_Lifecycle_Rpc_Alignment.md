# 601812_ChangeContract_Tenant_Lifecycle_Rpc_Alignment.md

Status: Active
Lifecycle: ChangeContract
Last Updated: 2026-08-29

## §0 성격과 범위

`000701` §47.1 의 **4단계 설계문서 정합화** 산출물이다.

**허용 파일과 금지 조작을 정한다.**

```text
Stage 8 구현자가 무엇을 할 수 있고 무엇을 못 하는가
구현자가 선택할 여지가 남지 않아야 한다
```

> ⚠️ **`0-A` 에서 물리 객체명 3건이 어디에도 없어 구현자가 지어내야 했다**(`R3-F2`).
> **이 계약은 테이블 · 컬럼 · 제약 · 인덱스 · 함수명 · 함수 인자명을 §2 에서 전부 확정한다.**

> ⚠️ **`0-A` 에서 계약이 허용한 형태를 TestPlan 이 FAIL 시켰다**(`C4-B1`).
> **각 `D-N` 이 `601811` 의 어느 Test 와 짝인지 §2.7 이 표로 명시한다.**

**검증 등급 — A**(`HD-0-A-2-1`).

### §0.2 착수 전 게이트 — 6건 전부 닫혔다

**하나라도 열려 있으면 이 계약이 Human 결정을 대신 채우게 된다.**

| # | 게이트 | 닫은 것 | 상태 |
|---|---|---|---|
| ① | `manage_subscription` 절단 | `HD-0-A-2-7` | ✅ |
| ② | `HG-A-9.1` ~ `HG-A-9.8` 식별자 부여 | `HD-0-A-2-8` | ✅ |
| ③ | `Q-4` 귀책 최종 판정 주체 | `HG-A-15` · `HD-0-A-2-9` | ✅ |
| ④ | YS-OS 별도 제품 · 별도 DB | `601801` §1.13 · `000221` §3 | ✅ |
| ⑤ | `HG-A-13` · `HG-A-14` 의 성격 구분 | 아래 | ✅ |
| ⑥ | `Q-1` 두 축 독립 조건 AND | `601810` `I-13` | ✅ |

**⑤ 의 확정 내용 — 둘의 성격이 다르다**

```text
HG-A-13   601809 §2 A-8 — 구현 대상
          격리 시 무엇을 차단하고 무엇을 차단하지 않는지가 코드에 들어간다
          이 계약은 D-28 이 그 판정을 수행하도록 정한다

HG-A-14   601809 §3 — Out of Scope
          포인트 provider 전환은 후속 워크패킷
          이 계약이 구현하지 않는다 — X-7 · FO-16
```

> ⚠️ **`HG-A-13` 은 `D-N` 을 낳고 `HG-A-14` 는 `FO-N` 을 낳는다.**
> **같은 1단계 선언이라도 이 나선에서의 지위가 다르다.**

### §0.1 식별자 규칙

```text
D-N     허용 DDL
M-N     허용 DML
X-N     범위에서 제외한 대상
FO-N    금지 조작
V-N     착수 직전 검증 게이트
R-N     rollback 정책
```

> ⚠️ **식별자 namespace 주의.**
>
> ```text
> 이 문서의 M-N     허용 DML
> 601809 §4.3 M-1 · M-2   Overview 가 이월한 미결 — 다른 계열
> 이 문서의 X-N     범위 제외 대상
> 601810 §7 X-1 ~ X-8      Logic 의 예외 상황 — 다른 계열
> ```
>
> **교차 인용할 때는 문서 번호를 함께 적는다.**

## §1 허용 파일

| # | 파일 | 성격 |
|---|---|---|
| A-1 | `sql/migrations/0172_tenant_isolation_axis_alignment.sql` | 신규. 이 나선의 유일한 migration |

**그 외 파일은 이 계약이 허용하지 않는다.**

> ⚠️ **`000701` §14.5 — 적용된 migration 은 불변이다.**
> **`0170` · `0171` 을 수정하지 않는다** — `FO-1`.

> ⚠️ **애플리케이션 코드 · `tools/**` · 문서는 이 계약의 허용 파일이 아니다.**
> **Stage 10 문서화는 별도 slice 다.**

## §2 허용 조작 (`D-N`)

**`601809` §4.2 가 `isolate_tenant` 수리를 판정했다.**

### §2.1 신규 테이블 3건 — 물리명 확정

| # | 조작 | 근거 |
|---|---|---|
| D-1 | `CREATE TABLE catchmenu_common.tenant_isolation_events` | `I-22` · `I-54` · `I-55` · `I-56` · `HG-A-8` · `HG-A-15` |
| D-2 | `CREATE TABLE catchmenu_common.tenant_isolation_queue` | `I-33` ~ `I-41` · `HG-A-7` |
| D-3 | `CREATE TABLE catchmenu_common.tenant_billing_reviews` | `I-49` ~ `I-53` · `HG-A-5` · `HG-A-9.4` |

**`D-1` 컬럼**

```text
id                        uuid    NOT NULL DEFAULT gen_random_uuid()
tenant_id                 uuid    NOT NULL
event_type                text    NOT NULL          ISOLATE / RELEASE
isolation_reason          text    NOT NULL
provisional_attribution   text    NOT NULL          HG-A-15 임시 분류 4값
confirmed_attribution     text    NULL              최종 확정. NULL = 미확정
confirmed_by              uuid    NULL
confirmed_at              timestamptz NULL
requested_by              uuid    NOT NULL
cause_resolved            boolean NOT NULL DEFAULT false
human_approved            boolean NOT NULL DEFAULT false
idempotency_key           text    NOT NULL
created_at                timestamptz NOT NULL DEFAULT now()
```

**`D-2` 컬럼**

```text
id                  uuid    NOT NULL DEFAULT gen_random_uuid()
tenant_id           uuid    NOT NULL
provider_kind       text    NOT NULL          TRANSACTION / EXECUTION — 601702 §1.43
provider_code       text    NOT NULL
provider_event_id   text    NOT NULL
raw_payload         jsonb   NOT NULL
signature_verified  boolean NOT NULL
hold_reason         text    NOT NULL          ISOLATION / NETWORK — I-41
hold_state          text    NOT NULL          QUARANTINE / PENDING_REVIEW / REPLAYED
replay_key          text    NOT NULL          I-39
replayed_at         timestamptz NULL
usage_counted       boolean NOT NULL DEFAULT false   I-45
received_at         timestamptz NOT NULL DEFAULT now()
```

**`D-3` 컬럼**

```text
id                    uuid    NOT NULL DEFAULT gen_random_uuid()
tenant_id             uuid    NOT NULL
isolation_event_id    uuid    NOT NULL
review_kind           text    NOT NULL        BILLING / TRIAL_EXTENSION — I-52 · I-53
review_state          text    NOT NULL        OPEN / CLOSED
human_decision        text    NULL            I-48
decided_by            uuid    NULL
decided_at            timestamptz NULL
created_at            timestamptz NOT NULL DEFAULT now()
```

> ⚠️ **`D-1` ~ `D-3` 은 금액 컬럼을 갖지 않는다.**
> **과금 금액 계산 · 정산은 이 나선 밖이다** — `X-6`.

### §2.2 제약 · 인덱스 — 물리명 확정

| # | 조작 | 근거 |
|---|---|---|
| D-4 | `tenant_isolation_events_pkey` PRIMARY KEY (`id`) | `D-1` |
| D-5 | `fk_tenant_isolation_events_tenant_id` FOREIGN KEY (`tenant_id`) REFERENCES `catchmenu_hq.tenants(id)` ON DELETE NO ACTION ON UPDATE NO ACTION | `I-9` |
| D-6 | `uq_tenant_isolation_events_idem` UNIQUE (`tenant_id`, `event_type`, `idempotency_key`) | `I-29` · §5 |
| D-7 | `chk_tenant_isolation_events_type` CHECK (`event_type` IN (`ISOLATE`,`RELEASE`)) | `I-22` |
| D-8 | `chk_tenant_isolation_events_prov_attr` CHECK (`provisional_attribution` IN (`PROVISIONAL_PLATFORM`,`PROVISIONAL_TENANT`,`PROVISIONAL_PROVIDER`,`UNKNOWN`)) | `HG-A-15` · `I-54` |
| D-9 | `idx_tenant_isolation_events_tenant` ON (`tenant_id`, `created_at`) | `I-56` 확정 이력 조회 |
| D-10 | `tenant_isolation_queue_pkey` PRIMARY KEY (`id`) | `D-2` |
| D-11 | `fk_tenant_isolation_queue_tenant_id` FOREIGN KEY (`tenant_id`) REFERENCES `catchmenu_hq.tenants(id)` ON DELETE NO ACTION ON UPDATE NO ACTION | `I-9` |
| D-12 | `uq_tenant_isolation_queue_event` UNIQUE (`tenant_id`, `provider_code`, `provider_event_id`) | `I-34` · `I-39` |
| D-13 | `chk_tenant_isolation_queue_provider_kind` CHECK (`provider_kind` IN (`TRANSACTION`,`EXECUTION`)) | `601702` §1.43 |
| D-14 | `chk_tenant_isolation_queue_hold_reason` CHECK (`hold_reason` IN (`ISOLATION`,`NETWORK`)) | `I-41` |
| D-15 | `chk_tenant_isolation_queue_hold_state` CHECK (`hold_state` IN (`QUARANTINE`,`PENDING_REVIEW`,`REPLAYED`)) | `I-37` |
| D-16 | `idx_tenant_isolation_queue_hold` ON (`tenant_id`, `hold_state`) | `I-37` 보류분 조회 · `I-39` 재처리 |
| D-17 | `tenant_billing_reviews_pkey` PRIMARY KEY (`id`) | `D-3` |
| D-18 | `fk_tenant_billing_reviews_tenant_id` FOREIGN KEY (`tenant_id`) REFERENCES `catchmenu_hq.tenants(id)` ON DELETE NO ACTION ON UPDATE NO ACTION | `I-9` |
| D-19 | `fk_tenant_billing_reviews_event_id` FOREIGN KEY (`isolation_event_id`) REFERENCES `catchmenu_common.tenant_isolation_events(id)` ON DELETE NO ACTION ON UPDATE NO ACTION | `I-49` |
| D-20 | `chk_tenant_billing_reviews_kind` CHECK (`review_kind` IN (`BILLING`,`TRIAL_EXTENSION`)) | `I-52` · `I-53` |
| D-21 | `chk_tenant_billing_reviews_state` CHECK (`review_state` IN (`OPEN`,`CLOSED`)) | `I-50` |
| D-22 | `idx_tenant_billing_reviews_open` ON (`tenant_id`, `review_state`) | `I-50` |

### §2.3 RLS — fail-closed baseline

| # | 조작 | 근거 |
|---|---|---|
| D-23 | 3테이블 각각 `ENABLE ROW LEVEL SECURITY` | `601702` §1.45 fail-closed |
| D-24 | 3테이블 각각 `FORCE ROW LEVEL SECURITY` | `601702` §1.45 fail-closed |

> ⚠️ **policy 는 만들지 않는다** — `FO-6`.
> **`0-C` 가 접근 정책을 정한다**(`000221` §4.4).
> **`601811` `TP-N-5` · `TP-R-3` 의 「policy 수 불변」과 일치한다.**

### §2.4 트리거

| # | 조작 | 근거 |
|---|---|---|
| D-25 | `trg_tenant_isolation_events_updated_at` — **만들지 않는다.** `D-1` 에 `updated_at` 이 없다 | `0-A` `BL-33` 트리거 총계 사고 회피 |

> ⚠️ **세 테이블 모두 `updated_at` 을 두지 않았다.**
> **격리 사건 · 보류 이벤트 · review 는 append 와 상태 전이만 하며 `0-A` 의 `updated_at` 트리거 패턴을 따르지 않는다.**
> **`601811` `TP-R-1` 이 함수 · 트리거 증감을 실측하므로 여기서 예고한다.**

### §2.5 함수 — 물리명 확정

| # | 조작 | 근거 |
|---|---|---|
| D-26 | `CREATE OR REPLACE FUNCTION catchmenu_common.isolate_tenant(p_tenant_id uuid, p_isolation_reason text, p_isolate boolean, p_actor_id uuid, p_locale text)` — 본문을 `isolation_state` 를 쓰도록 정합화 | `601809` §4.2 수리 판정 · `I-26` · `X-1`(`601810`) |
| D-27 | `CREATE FUNCTION catchmenu_common.release_tenant_isolation(p_tenant_id uuid, p_event_id uuid, p_actor_id uuid, p_locale text)` — 해제 3요건 경로 | `HG-A-8` · `I-22` · `I-23` |
| D-28 | `CREATE FUNCTION catchmenu_common.is_tenant_access_allowed(p_tenant_id uuid, p_operation text)` — 두 축 각각 검사 | `I-13` · `HG-A-9.2` |
| D-29 | `CREATE FUNCTION catchmenu_common.confirm_isolation_attribution(p_event_id uuid, p_attribution text, p_actor_id uuid)` — 최종 귀책 확정 기록 | `HG-A-15` · `I-55` · `I-56` |

> ⚠️ **`D-26` 은 시그니처를 바꾸지 않는다** — §8 `M-1` 판정.
> **`CREATE OR REPLACE` 는 EXECUTE ACL 을 보존한다** — `601811` `TP-R-10`.

> ⚠️ **`D-27` ~ `D-29` 는 `GRANT` 를 동반하지 않는다** — `FO-7`.
> **소유자 외에는 도달하지 못하며 접근 부여는 `0-C` 소관이다.**
> **`0-A` 의 `merchant_accounts` 와 같은 fail-closed 상태다**(`601744` `F-7`).

### §2.6 `D-26` 본문이 지켜야 할 것

```text
isolation_state 를 'ISOLATED' 또는 'NONE' 으로 쓴다
tenant_status 를 읽기만 한다 — 쓰지 않는다
subscription · 청구 관련 테이블을 쓰지 않는다
tenant_isolation_events 에 사건을 남긴다
같은 트랜잭션에서 상태 변경과 사건 기록이 함께 commit / rollback 된다
```

**근거** — `I-9` · `I-26` · `I-31` · `HG-A-3`.

### §2.7 `D-N` ↔ `601811` Test 대응

| `D-N` | 짝이 되는 Test |
|---|---|
| D-1 · D-4~D-9 | `TP-P-6` · `TP-P-7` · `TP-P-8` · `TP-C-1` · `TP-C-2` |
| D-2 · D-10~D-16 | `TP-E-1` ~ `TP-E-7` |
| D-3 · D-17~D-22 | `TP-P-7` · `TP-N-12` · `TP-N-13` |
| D-23 · D-24 | `TP-N-5` · `TP-R-3` |
| D-25 (비생성) | `TP-R-1` |
| D-26 | `TP-P-2` · `TP-P-3` · `TP-N-1` · `TP-N-2` · `TP-N-6` · `TP-RB-1` |
| D-27 | `TP-P-4` · `TP-P-5` · `TP-N-7` · `TP-N-8` |
| D-28 | `TP-P-1` · `TP-P-9` · `TP-S-1` ~ `TP-S-12` · `BL-5` |
| D-29 | `TP-P-8` · `TP-N-12` |

> ⚠️ **허용 조작과 검사 기대값이 서로를 가리킨다.**
> **`0-A` `C4-B1`(계약이 허용한 형태를 TestPlan 이 FAIL 시킴)을 이 표로 막는다.**

## §3 허용 DML (`M-N`)

| # | 조작 | 근거 |
|---|---|---|
| M-1 | **없음** — 이 migration 은 기존 행을 삽입 · 수정 · 삭제하지 않는다 | `I-9` · `601811` `BL-8` · `BL-9` · `BL-10` |

> ⚠️ **backfill 이 없다.**
> **세 신규 테이블은 빈 상태로 시작하며 runtime 이 채운다.**
> **`0-A` 의 `M-1` · `M-2` backfill 이 `stores.updated_at` 을 비가역으로 바꾼 사례를 반복하지 않는다**(`601717` `N-4′`).

## §4 범위에서 제외한 대상 (`X-N`) · 금지 조작 (`FO-N`)

### §4.1 범위 제외 (`X-N`)

| # | 제외 대상 | 소관 |
|---|---|---|
| X-1 | `manage_subscription` 과 `tenant_status` 전이 | 별도 Subscription Lifecycle 워크패킷 — `HD-0-A-2-7` |
| X-2 | provisioning RPC 재설계 · `C-3` · `NOT NULL` 승격 | `0-A-3` |
| X-3 | RLS policy · 역할 · 권한 · 승인권자 배정 | `0-C` |
| X-4 | `detect_threat` 및 나머지 호출 금지 5함수 | 각 소관 나선 |
| X-5 | `601702` §1.28 의 나머지 4축 | 각 축 소관 |
| X-6 | 과금 금액 계산 · 정산 · 청구 확정 경고 소비자 | 별도 |
| X-7 | 포인트 provider 전환 | 후속 포인트 워크패킷 — `HG-A-14` |
| X-8 | UI | Phase 0 Exit Demo |

### §4.2 금지 조작 (`FO-N`)

| # | 금지 | 근거 |
|---|---|---|
| FO-1 | `0170` · `0171` 수정 | `000701` §14.5 |
| FO-2 | `manage_subscription` 수정 | `HD-0-A-2-7` |
| FO-3 | `provision_tenant` · `create_franchise_store` · `onboard_tenant` 수정 | `0-A-3` |
| FO-4 | `detect_threat` · `verify_security_token` · `gateway_audit_entry` · `record_van_transaction` · `check_staff_permission` 수정 | `601505` §4 · `600010` §1.1 |
| FO-5 | `tenant_status` 값 변경 — DDL · DML 어느 쪽도 | `I-9` · `HD-0-A-2-7` |
| FO-6 | `CREATE POLICY` | `0-C` — `000221` §4.4 |
| FO-7 | `GRANT` · `REVOKE` | `0-C` |
| FO-8 | `601702` §1.28 의 나머지 4축 객체 조작 | `HG-A-11` |
| FO-9 | `merchant_accounts` 생성 · 삭제 · 교체 · `stores.merchant_account_id` 변경 | `HG-A-12` · `HD-0-A-2-4` |
| FO-10 | `CASCADE` | 연쇄 삭제 방지 |
| FO-11 | `DROP TABLE` · `TRUNCATE` | 데이터 보호 |
| FO-12 | `DROP FUNCTION` | ACL 소실 방지 — §8 |
| FO-13 | `IF EXISTS` · `IF NOT EXISTS` · `DO $$` · dynamic `EXECUTE` · `EXCEPTION` | 방어 코드가 baseline drift 를 감춘다 — `601717` §6 |
| FO-14 | 기존 테이블에 `ADD COLUMN` · `ALTER COLUMN` | 이 나선은 신규 테이블만 만든다 |
| FO-15 | 두 축 조합을 제한하는 CHECK 신설 | §9 `X-7` 판정 |
| FO-16 | 포인트 provider 관련 객체 생성 · 조작 — `point_provider` · `provider_tenant_ref` · `provider_transaction_ref` 계열 | `HG-A-14` · `X-7` — 후속 포인트 워크패킷 |

## §5 `Q-2` 판정 — 멱등성 단위

**두 수준으로 나눈다.**

```text
요청 멱등성
  scope = tenant_id + event_type + idempotency_key
  물리 표현 = D-6 uq_tenant_isolation_events_idem
  같은 키 · 같은 내용   기존 결과를 반환한다
  같은 키 · 다른 내용   거부한다

목표 상태 멱등성
  이미 ISOLATED 인 tenant 에 ISOLATE 재요청   성공으로 처리한다
  상태 전이와 side effect 를 중복 생성하지 않는다
  다만 새 보안사건이면 감사 사건은 별도로 남을 수 있다
```

**근거** — `HG-A-10` · `I-29` ~ `I-32`.

> ⚠️ **`601810` `Q-2` 를 이 항이 닫는다.**
> **`601811` `TP-C-1` · `TP-C-2` 의 판정 기준은 `D-6` 이다.**

## §6 `Q-3` 판정 — 원자성 경계

```text
한 트랜잭션 안
  isolation_state 변경
  tenant_isolation_events 기록 — 사유 · 임시 귀책 · 요청자
  세션 차단용 DB 기록
  후속 작업 outbox 생성

트랜잭션 밖
  알림 발송
  외부 API 호출
  provider 전달
  호출자(detect_threat 등)의 전체 처리
```

> ⚠️ **외부 시스템을 한 DB 트랜잭션에 묶을 수 없다.**
> **outbox 와 재시도로 보장한다.**

**근거** — `HG-A-10` · `I-31` · `HG-A-7`.

> ⚠️ **outbox 의 물리 표현은 이 계약이 만들지 않는다.**
> **`tenant_isolation_queue`(`D-2`)가 수신 측 보류를 담당하며,
> 송신 측 outbox 는 기존 provider 전달 경로 소관이다** — `X-6`.

## §7 `Q-5` 판정 — fail-closed 계층

```text
API 계층    빠른 거부 · 명확한 오류코드 · 불필요한 DB 작업 방지
DB / RPC    최종 권위 검사 · API 우회 방어

둘 다에서 막는다
```

> ⚠️ **RLS 만으로 상태 전이와 업무별 허용조건을 표현하기 어렵다.**
> **mutation RPC 가 tenant 상태와 격리를 다시 확인한다** — `D-28` 이 그 검사 함수다.
>
> **다만 RLS policy 자체는 `0-C` 소관이며 이 계약이 만들지 않는다** — `FO-6`.

**근거** — `HG-A-2` · `HG-A-13` · `I-17`.

> ⚠️ **이 나선이 구현하는 것은 DB / RPC 계층뿐이다.**
> **API 계층 적용은 애플리케이션 코드이며 허용 파일이 아니다**(§1).
> **`601811` `TP-S` 는 DB / RPC 계층에서 판정한다.**

## §8 `M-1` 판정 — 파라미터명 불일치

**`601809` §4.3 `M-1` 을 여기서 닫는다.**

### §8.1 실측과 선택지

```text
601802 §5.2 · §9.1
  isolate_tenant 의 필수 인자는 p_isolation_reason
  manage_subscription 2곳과 detect_threat 1곳이 p_reason := 으로 호출한다
```

| 선택지 | 결과 |
|---|---|
| A — 시그니처를 호출부에 맞춘다 | `CREATE OR REPLACE` 로 **입력 파라미터명을 바꿀 수 없다.** `DROP FUNCTION` + `CREATE` 가 필요하고 그때 EXECUTE ACL 이 소실된다. 복원하려면 `GRANT` 가 필요한데 `FO-7` 이 금지한다 |
| B — 호출부를 고친다 | `manage_subscription` 수정이며 `HD-0-A-2-7` · `FO-2` 위반 |
| C — 고치지 않는다 | 두 호출자가 이미 호출 금지 상태다. 신규 경로는 실제 인자명으로 호출하므로 성립한다 |

### §8.2 판정 — **C 를 택한다**

```text
이 나선은 isolate_tenant 의 시그니처를 바꾸지 않는다
호출부도 고치지 않는다
불일치를 기록하고 각 호출자의 소관 나선으로 이월한다
```

**근거 3건**

```text
1  A 는 DROP FUNCTION 을 요구하고 그것은 FO-12 · FO-7 과 충돌한다
2  B 는 FO-2 위반이다
3  두 호출자 모두 601505 §4 호출 금지 상태이므로 운영 영향이 없다
   신규 해제 · 판정 경로는 실제 인자명 p_isolation_reason 으로 호출한다
```

> ⚠️ **`601811` `TP-P-3` 「호출이 실행 가능하다 — 파라미터명 일치」는
> **신규 호출 경로**에 대해 판정한다.**
> **`manage_subscription` · `detect_threat` 로부터의 호출은 검사 대상이 아니다**(`X-1` · `X-4`).

> ⚠️ **`601505` §4 금지 조항의 주소가 바뀌지 않는다.**
> **함수명 · 시그니처가 그대로이므로 `601809` §4.2 근거 2 가 유지된다.**

## §9 `X-7` 판정 — 두 축 조합 제약

**`601810` §7 `X-7` 을 여기서 닫는다.**

```text
601802 · 601804 F-4 실측   두 축 조합을 제한하는 제약이 없다
HG-A-9.1                    10 조합이 모두 표현 가능하다
```

### §9.1 판정 — **제약을 신설하지 않는다**

```text
조합 제약을 신설하면 10 조합 중 일부가 저장 불가가 된다
그것은 HG-A-9.1 을 위반한다
```

**`FO-15` 가 이를 금지 조작으로 못박는다.**

> ⚠️ **「제약이 없다」가 결함이 아니다.**
> **`HG-A-9.1` 이 전 조합 표현 가능을 선언했으므로 현재 상태가 선언과 일치한다.**
> **`601811` `TP-S-11`(10 조합 전부 저장 가능)이 이를 검사한다.**

> ⚠️ **접근 판정은 제약이 아니라 `D-28` 이 한다.**
> **저장 가능성과 접근 허용은 다른 층이다**(`601803` §3.4).

## §10 Required Verification (`V-N`)

**착수 직전 게이트. 하나라도 미충족이면 착수하지 않는다.**

| # | 검증 | 근거 |
|---|---|---|
| V-1 | Stage 7 Human 승인이 기록돼 있다 | `601811` `PRE-1` |
| V-2 | 환경이 최신 migration 까지 적용돼 있다 | `PRE-2` |
| V-3 | `601811` `BL-1` ~ `BL-13` 재측정이 `601802` 기록과 일치한다 | `PRE-3` |
| V-4 | 구현자가 `601809` · `601810` · `601811` · `601812` 의 원작자가 아니다 | `000701` §37 |
| V-5 | 허용 파일이 `A-1` 1건뿐임을 확인했다 | §1 |
| V-6 | `FO-1` ~ `FO-15` 를 구현자가 확인했다 | §4.2 |
| V-7 | canonical DB 는 read-only 로만 접속한다. 쓰기는 disposable 환경 | `PRE-8` |
| V-8 | `git ls-files --eol` 이 `w/lf` 를 보고한다 — EOL drift 없음 | `601717` §10.9 `V-24` 승계 |
| V-9 | `D-1` ~ `D-29` 물리명이 이 문서와 문자 단위로 일치한다 | §2 |
| V-10 | `D-25` 가 「만들지 않는다」임을 확인했다 — 트리거 0건 | §2.4 |

## §11 Rollback Policy (`R-N`)

| # | 정책 |
|---|---|
| R-1 | rollback 은 역방향 migration 을 새로 작성해 수행한다. `0172` 를 수정하거나 삭제하지 않는다 |
| R-2 | 역방향 대상은 `D-1` ~ `D-29` 의 역순이다. 신규 테이블 3건과 신규 함수 3건을 제거하고 `isolate_tenant` 를 `601811` `BL-1` before 값으로 되돌린다 |
| R-3 | `M-N` 이 없으므로 되돌릴 데이터가 없다 |
| R-4 | 신규 테이블에 runtime 데이터가 쌓인 뒤의 rollback 은 이 정책이 다루지 않는다. 별도 Human 판단이 필요하다 |
| R-5 | rollback 검증은 disposable 환경에서 수행한다. canonical DB 전후 실측이 동일해야 한다 |
| R-6 | rollback 후 migration ledger 상태를 문서화한다 — `601746` §2.7 이 지적한 결함을 반복하지 않는다 |
| R-7 | rollback 실행 여부는 Human 이 판단한다. 이 계약은 방식만 정한다 |

> ⚠️ **`R-4` 가 `0-A` `601746` §2.7 의 「운영 후 rollback 은 안전하지 않다」를 승계한 것이다.**
> **적용 직후 rollback 과 운영 후 rollback 을 구분한다.**

## §12 Approval State

| Stage | 상태 |
|---|---|
| Stage 6 (Contract Verification) | **NOT STARTED** |
| Stage 7 (Human Approval) | **NOT EFFECTIVE** — 승인 기록 없음 |
| Stage 8 (Implementation) | **MUST NOT START** |

> ⚠️ **이 계약은 구현을 승인하지 않는다.**
> **Stage 6 이중 검증과 Stage 7 Human 승인을 거쳐야 한다.**
> **A급이므로 blind design review · fault injection · 독립 감사를 생략하지 않는다**(`HD-0-A-2-1`).

## §13 근거 문서 목록 (`000701` §46)

### §13.1 인용한 문서

| 문서 | 인용 | 지위 |
|---|---|---|
| `601811_TestPlan_Tenant_Lifecycle_Rpc_Alignment.md` | `BL-1`~`BL-13` · `PRE-1`~`PRE-8` · `TP-*` · `AC-*` | ACTIVE |
| `601810_Logic_Tenant_Lifecycle_Rpc_Alignment.md` | `I-9`·`I-13`·`I-22`·`I-26`·`I-29`~`I-32`·`I-33`~`I-41`·`I-45`·`I-48`~`I-56` · `X-1`·`X-7` · `Q-2`·`Q-3`·`Q-5` | ACTIVE |
| `601809_Overview_Tenant_Lifecycle_Rpc_Alignment.md` | §3 · §4.2 수리 판정 · §4.3 `M-1`·`M-2` · §4.4 | ACTIVE |
| `601801_Register_Stage1_Business_Rules.md` | `HG-A-2`·`HG-A-3`·`HG-A-5`·`HG-A-7`·`HG-A-8`·`HG-A-9.1`·`HG-A-9.2`·`HG-A-9.4`·`HG-A-10`·`HG-A-11`·`HG-A-12`·`HG-A-13`·`HG-A-14`·`HG-A-15` · `HD-0-A-2-1`·`HD-0-A-2-4`·`HD-0-A-2-7`·`HD-0-A-2-8`·`HD-0-A-2-9` · §1.13 | ACTIVE |
| `601802_Register_Stage0_Evidence_Collection.md` | §5.1 · §5.2 · §5.3 · §6.1 · §9.1 · §9.2 | ACTIVE |
| `601804_Audit_Stage3_Adjacent_Domain_Codex.md` | `F-4` — 조합 제약 부재 실측. §9 판정 근거 | ACTIVE |
| `601717_ChangeContract_Operational_Authority_Foundation_V2.md` | §6 금지 조작 형식 · `N-4′` backfill 비가역 · §10.9 `V-24` EOL | ACTIVE |
| `601746_Report_Stage11C_Conflict_Analysis.md` | §2.7 rollback 미입증 — `R-4` · `R-6` | ACTIVE |
| `601744_AuditReview_Operational_Authority_Foundation_V2.md` | `F-7` — grant 없는 fail-closed 상태 선례 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | §1.28 6축 · §1.43 provider 2종 · §1.45 fail-closed | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §4.4 `0-C` 배정 · §6.1 A급 판별 | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §14.5 migration 불변 · §37 · §46 · §47.1 | ACTIVE |
| `000002_Naming_Rules.md` | §1.2 DocumentType | ACTIVE |

### §13.2 확인했으나 배제한 문서

| 문서 | 배제 사유 |
|---|---|
| `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | 2단계 모델. `601810` 이 불변조건으로, `601811` 이 검사로 옮겼다. 계약은 그 둘을 인용한다 |
| `601805` · `601806` · `601807` · `601808` | 3단계 검증자 원본 · 통합 · 대조. `601809` · `601810` 이 승계했다 |
| `601713_Logic_Operational_Authority_Foundation_V2.md` | 0-A 구조 불변조건. 이 계약의 조작 대상이 아니다 |
| `601716_TestPlan_Operational_Authority_Foundation_V2.md` | 0-A TestPlan. 형식은 `601811` 이 승계했다 |
| `601748_Evidence_Stage12_Human_Merge_Decision.md` | §8 게이트 1 은 `C-3`(`0-A-3`) 순서 조항. 이 계약은 RLS policy 를 만들지 않으므로 침범하지 않는다 — `FO-6` |
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | Foundation 축 귀속은 `000220` §4 소관 |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | `601505` §4 금지 유효성은 `601809` §4.4 가 판정했다 |
| `601502` · `601503` · `601505` · `601510` · `601511` | 권위보류 대역. 설계 결론을 승계하지 않는다 — `000221` §3.2 |
| `000001_Md_Rules.md` | 문서 규칙. 이 계약의 조작 대상이 아니다 |

## §14 다음 단계

```text
Stage 5    구현 준비
Stage 6    계약 이중 검증 — Cursor · Codex. 원작자 배제
Stage 7    Human 승인
Stage 8    Codex 구현 — 허용 파일 A-1 1건
Stage 9 ~ 12   A급 절차 전체
```

**이 계약은 구현을 승인하지 않는다.**
