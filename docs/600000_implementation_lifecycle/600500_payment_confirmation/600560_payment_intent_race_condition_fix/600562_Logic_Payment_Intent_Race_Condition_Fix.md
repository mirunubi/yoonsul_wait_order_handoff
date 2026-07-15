# 600562_Logic_Payment_Intent_Race_Condition_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`payment_intent_race_condition_fix`

## §0 전제

`600561_Overview.md`가 확인한 사실을 전제로 한다: `resolve_or_create_payment_intent()`(`0158`)의 "신규 생성" 분기는 `count(*)` 확인 후 락 없이 `insert`하는 TOCTOU 레이스이며(§1), 이 레이스는 이미 실제로 재현되어 라이브 DB에 중복 행이 남아있다(§2, 오염 상태 그대로 보존 — 이 문서도 정리하지 않는다). PAY-CON-001(`confirm_payment()` 이중 호출)은 범위 밖으로 재확인됐다(`orders FOR UPDATE` 존재만 spot-check).

## §1 확정: 옵션 (a) 채택 (Human 결정, 2026-07-15, 재논의 금지)

**번호 안내**: 이번 지시문은 이 섹션을 "§2"로, 마이그레이션 설계를 "§3"으로 지칭했으나, 이 문서의 실제 구조는 옵션 비교가 §1, 라이브 오염 Open Item이 §2, Open Items 목록이 §3이다. 내용을 기준으로 지시문의 의도(옵션 비교 확정 + 마이그레이션 설계 추가)를 그대로 반영하되, 섹션 번호는 이 문서의 기존 구조를 유지한다 — §2(라이브 오염 Open Item)는 지시대로 그대로 둔다.

**확정**: 옵션 (a) — `payment_intents.idempotency_key`에 `UNIQUE` 제약을 추가하고, `resolve_or_create_payment_intent()`의 INSERT를 `INSERT ... ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`로 전환한다. `§1.1`(구 안, 아래 유지)이 검토했던 `DO NOTHING` + 재조회 방식 대신 `DO UPDATE ... RETURNING`을 채택 — 두 세션 모두 대칭적으로 승자 행의 `id`를 받으므로 별도 재-`SELECT` 로직이 불필요해진다.

**라이브 오염 데이터(§2) 처리 방침**: 그대로 둔다. Stage 4에서 `UNIQUE` 제약을 먼저 시도해 이 기존 중복이 실제로 제약 위반을 일으키는지 확인하는 것 자체가 "이 제약이 의도한 중복을 정확히 잡아내는가"의 자연스러운 실증 검증이 된다(§1.2 순서 1). 이후 정리(§1.2 순서 2)→제약 확정(순서 3)→헬퍼 함수 전환(순서 4) 순으로 진행한다.

## §1.2 정확한 마이그레이션 설계 (Stage 4 대상, 이번 턴 미실행)

이번 문서 작성 시점(2026-07-15)에 라이브로 재확인한 실제 데이터를 근거로 설계한다 — Stage 4 착수 시점에 다시 재확인해야 한다(아래 값은 예시가 아니라 현재 실제 값이다).

### 순서 1 — 기존 중복 재현 확인 (제약을 먼저 걸어서 실패를 확인)

```sql
-- 예상: unique_violation 에러로 실패해야 한다.
-- 이 실패 자체가 "제약이 의도한 중복을 정확히 잡아낸다"는 증거다.
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

**라이브 재확인(이번 문서 작성 턴)**: 현재 중복 쌍은 `order_id = '33333333-3333-3333-3333-333333333333'`, `idempotency_key = 'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391'`로 완전히 동일한 2행이다:

| id | idempotency_key | created_at |
|---|---|---|
| `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf` | `OBS-33333333-...-POS_SYNTHESIZED-924f18176391` | `2026-07-15 15:57:55.728129+00`(더 이른 시각) |
| `283f3973-d547-4ea9-b4ad-b83b1c62b8cc` | `OBS-33333333-...-POS_SYNTHESIZED-924f18176391`(동일) | `2026-07-15 15:57:55.789718+00`(61ms 늦음) |

위 `ALTER TABLE`을 이 상태에서 그대로 실행하면 `ERROR: could not create unique index "uq_payment_intents_idempotency_key" ... DETAIL: Key (idempotency_key)=(OBS-33333333-...-POS_SYNTHESIZED-924f18176391) is duplicated.` 형태로 실패할 것으로 예상된다 — Stage 4는 이 정확한 에러 발생을 먼저 확인해야 한다.

### 순서 2 — 기존 중복 정리 (가장 이른 `created_at`을 승자로, 나머지 삭제)

**정리 전 안전 확인(필수, 이번 문서에서 이미 재확인)**: 삭제 대상 행(패자, `created_at`이 더 늦은 쪽)이 다른 테이블에서 FK로 참조되고 있지 않은지 먼저 확인한다. `payment_intents.id`를 참조하는 FK는 5개(`payment_ledger.intent_id`, `payment_events.intent_id`, `reconciliation_cases.intent_id`, `catchmenu_integrations.toss_payments.intent_id`, `catchmenu_integrations.toss_payment_requests.payment_intent_id`) — 이번 문서에서 위 중복 쌍(`17f67f52`/`283f3973`)의 5개 테이블 전체를 직접 조회해 **참조 0건**임을 확인했다. 정리 SQL(설계):

```sql
with ranked as (
  select id,
         row_number() over (
           partition by idempotency_key
           order by created_at asc
         ) as rn
  from catchmenu_payment.payment_intents
)
delete from catchmenu_payment.payment_intents
where id in (select id from ranked where rn > 1);
```

`row_number() ... order by created_at asc`이므로 가장 이른 행(`rn=1`)이 승자로 남고, 나머지(`rn>1`, 이번 케이스에서는 `283f3973-...` 1건)가 삭제된다. **Stage 4는 이 DELETE 직전에 위와 동일한 FK 참조 0건 확인을 다시 실행해야 한다**(이번 문서 작성 시점과 Stage 4 착수 시점 사이에 상태가 바뀌었을 수 있으므로) — 참조가 하나라도 있으면 그 행은 승자로 재선정하거나 별도 정책이 필요하다(이번 문서는 이 예외 케이스가 실제로 발생하지 않았음만 확인했다).

### 순서 3 — `UNIQUE` 제약 최종 적용

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

순서 2 이후 재실행 — 이번에는 성공해야 한다(중복이 제거됐으므로).

### 순서 4 — `resolve_or_create_payment_intent()` INSERT 전환

```sql
-- 변경 전(0158:219-255, 현재)
insert into catchmenu_payment.payment_intents (...)
values (...)
returning id into v_intent_id;

-- 변경 후 설계안
insert into catchmenu_payment.payment_intents (...)
values (...)
on conflict (idempotency_key) do update
  set updated_at = now()
returning id into v_intent_id;
```

`on conflict (idempotency_key) do update set updated_at = now()`는 항상 행을 반환한다(승자든 패자든 동일한 `id`) — `§1.4`(구 §1.1)가 지적했던 "DO NOTHING 시 패자가 빈 행을 받는" 비대칭 문제가 이 방식으로 근본적으로 해소된다. `do update`가 실제로 갱신하는 컬럼(`updated_at`)은 부작용이 없는 값이므로, 두 세션 중 나중에 도착한 쪽이 불필요하게 이 컬럼을 한 번 더 갱신하는 것 외에는 데이터 정합성에 영향이 없다.

### §1.3 결정 이전 이력 — 옵션 비교표 원문 (참고용, 위 §1 확정으로 대체됨)

| | 옵션 (a) — `idempotency_key` UNIQUE + `ON CONFLICT` | 옵션 (b) — Advisory Lock(`0142` 패턴 이식) | 옵션 (c) — `orders FOR UPDATE`(PAY-CON-001 패턴 재사용) |
|---|---|---|---|
| 핵심 메커니즘 | `payment_intents.idempotency_key`에 `UNIQUE` 제약 추가, INSERT 문에 `ON CONFLICT (idempotency_key) DO NOTHING` 또는 `DO UPDATE ... RETURNING id`로 전환 | 함수 진입 시 `pg_advisory_xact_lock(hashtextextended(tenant+store+order, <신규 namespace>))`로 같은 order_id에 대한 호출을 직렬화, 이어서 `for share`(orders)/`for update`(intent 후보) | 함수 진입 시 대상 `orders` 행을 `for update`로 잠가 같은 주문에 대한 모든 동시 호출을 직렬화 |
| 이미 존재하는 자산 재사용 | `idempotency_key`는 이미 결정론적으로 생성되고 있음(`600561_Overview.md` §3) — 컬럼 자체는 이미 있고 제약만 없음 | `0142`의 `bind_toss_payment_intent()`가 이미 정확히 이 패턴으로 프로덕션에 존재(`600561_Overview.md` §4) | `confirm_payment()`가 이미 이 패턴으로 PAY-CON-001을 막고 있음(`600561_Overview.md` §5) |
| DB 스키마 변경 필요 | **있음** — `alter table payment_intents add constraint uq_payment_intents_idempotency_key unique (idempotency_key)` | 없음(함수 본문만 수정) | 없음(함수 본문만 수정) |
| 레이스 윈도우 차단 방식 | **DB 자체가 물리적으로 중복을 거부** — 애플리케이션 로직의 정확성과 무관하게 최종 방어선 역할 | 애플리케이션 레벨 직렬화 — 잠금 순서/범위를 실수하면 여전히 레이스가 남을 수 있음 | 애플리케이션 레벨 직렬화, 잠금 대상이 `orders`(이 헬퍼가 직접 소유하지 않는 테이블)라는 점이 특이 |
| `PREAUTHORIZED` 분기(`p_intent_id is not null`)와의 관계 | 영향 없음 — 그 분기는 이미 존재하는 intent를 `UPDATE`할 뿐 `INSERT`하지 않으므로 이 UNIQUE 제약과 무관 | 잠금을 함수 전체(진입 시점)에 걸면 `PREAUTHORIZED` 분기도 함께 직렬화됨(약간의 불필요한 대기 발생 가능, `0142`가 이미 이 트레이드오프를 감수 중) | 동일 — 함수 전체를 감싸면 `PREAUTHORIZED` 분기도 영향받음 |
| 이 헬퍼의 3개 호출자(`0098`/`0109`/`0130`)에 미치는 영향 | 없음 — 호출자는 헬퍼의 반환값만 받으므로 무변경. 다만 `ON CONFLICT DO NOTHING`을 쓸 경우 "내가 이겼는지 졌는지"를 구분해 기존 행을 다시 조회하는 후속 로직이 필요(§1.1 참고) | `0098`은 이미 `orders`에 `for update`를 걸고 있어 이 헬퍼가 다시 `orders`를 `for share`로 잠그면 **같은 트랜잭션 내 재진입 락**이 되어 문제없이 통과하지만(PostgreSQL은 동일 트랜잭션 내 락 업그레이드/재획득 허용), `0109`/`0130`은 `orders`를 미리 잠그지 않으므로 이 헬퍼의 `for share`가 그 시점에 처음 걸림 — 세 호출자 모두 안전하게 동작 가능 | `0098`은 이미 자체적으로 `orders FOR UPDATE`를 갖고 있어 이 옵션을 헬퍼에도 넣으면 **중복 락 획득**(같은 트랜잭션 내에서는 무해하지만 로직 중복). `0109`/`0130`은 원래 `orders`를 잠그지 않는 흐름이었으므로 이 옵션을 넣으면 그 두 함수의 락 사용 패턴이 새로 생김 |
| 놓칠 수 있는 경우 | `idempotency_key` 생성 로직 자체에 버그가 있으면(예: `origin_reference` 정규화가 불완전) 보호가 무력화됨 — 그러나 DB 제약이므로 애플리케이션 버그와 무관하게 최소한 "완전히 같은 해시"에 대해서는 항상 보호됨 | advisory lock의 namespace/키 구성을 다른 워크패킷이 실수로 재사용하면 의도치 않은 직렬화나 충돌 가능(`600561_Overview.md` §7 (b) Open Item) | 헬퍼가 `orders`가 아닌 다른 스코프(예: 향후 order 없는 intent)로 호출될 경우 이 옵션은 애초에 적용 불가 |

### §1.4 옵션 (a) 채택 시 필요한 추가 설계 — `ON CONFLICT` 이후 반환값 처리 (해소됨, 이력 보존)

`ON CONFLICT (idempotency_key) DO NOTHING`만 쓰면 충돌 시 `INSERT`가 아무 행도 반환하지 않는다(`RETURNING id`가 비게 됨) — 이 경우 함수는 반드시 **충돌한 기존 행을 다시 `SELECT`해서 그 `id`를 반환**해야 한다(그렇지 않으면 두 번째 호출자가 `null`을 받아 §3.1의 `payment_intent_resolution_failed` 에러 경로로 빠짐 — 첫 번째 성공 호출자와 다른 결과를 받게 되어 사실상 "레이스는 막았지만 응답이 비대칭"인 상태가 됨). 대안으로 `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`를 쓰면 항상 행을 반환하지만, 승자가 아닌 호출도 불필요한 `UPDATE`를 하게 된다. 이 구체 설계는 이번 문서에서 결정하지 않고 TestPlan/ChangeContract 단계로 이월한다.

## §2 Open Item — 오늘 발견된 라이브 오염 사고, 향후 재현 테스트 격리 절차 제안

**사고 기록(사실)**: `600561_Overview.md` §2에서 확인한 대로, 오늘 세션 중 진행된 동시성 재현 테스트(안티+Codex, `pg_sleep`으로 레이스 윈도우 강제 확대)의 산출물이 **정리되지 않고 라이브 DB에 그대로 남아있다** — `catchmenu_payment.payment_intents`에 합성 `order_id`(`22222222.../33333333.../44444444...`류)를 쓴 테스트 행 5건이 남아있고, 그중 2건은 실제로 재현된 중복 쌍이다. 이번 워크패킷(Overview/Logic, `.sql` 생성 금지)은 이 데이터를 정리하지 않았다 — **Human 확인 후 별도로 정리 여부를 결정해야 한다.**

**재발 방지를 위한 향후 가이드라인 제안(권고, 이 문서가 강제하지 않음)**:

1. **격리된 스키마/네임스페이스 사용**: 동시성 재현 테스트처럼 의도적으로 레이스를 유발하는 테스트는 실제 스키마(`catchmenu_payment` 등)에 직접 쓰지 말고, 별도 테스트 전용 함수명 접두사(예: `__test_`)나 별도 스키마(예: `catchmenu_test`)를 통해서만 실행하도록 권고한다.
2. **트랜잭션 격리 우선 원칙**: 이번 세션의 다른 검증 작업들(`601020`/`600550` 워크패킷)이 반복적으로 써온 `BEGIN ... ROLLBACK` 패턴이 이 재현 테스트에는 구조적으로 적용되지 않는다 — 동시성 재현 자체가 "두 개의 독립된 트랜잭션이 실제로 커밋 경합을 벌이는 것"을 요구하므로, 단일 트랜잭션 롤백으로는 레이스를 재현할 수 없다. 이 근본적 제약 때문에 이런 테스트는 태생적으로 "정리가 필요한 흔적을 남긴다"는 점을 명시하고, **테스트 종료 직후 자동/수동 정리(해당 합성 `order_id`/`tenant_id` 패턴에 대한 즉시 `DELETE`)를 절차의 필수 마지막 단계로 명문화**할 것을 제안한다.
3. **합성 식별자 명명 규칙**: 이번 사고에서도 합성 UUID(`22222222...`류)가 쓰였으나, 이런 패턴 자체가 이미 이 세션의 여러 검증 작업에서 재사용되고 있어(`33333333...`/`44444444...` 등) 서로 다른 워크패킷의 테스트 데이터가 뒤섞일 위험이 있다 — 워크패킷별로 구분되는 접두사(예: `Risk ID` 또는 워크패킷 번호를 UUID 일부에 인코딩)를 쓰는 것을 권고한다.

이 제안 자체를 채택할지, 어떤 형태의 공식 가이드라인 문서(`000701` 추가 조항 또는 별도 문서)로 만들지는 이 워크패킷이 결정하지 않는다 — Open Item으로만 기록한다.

## §3 Open Items

(a) ~~§1.1의 `ON CONFLICT` 이후 반환값 처리 구체 설계~~ — **해소됨**: §1에서 옵션 (a) 확정, §1.2 순서 4에서 `DO UPDATE ... RETURNING`으로 확정.
(b) `600561_Overview.md` §7 (a) — `idempotency_key` UNIQUE 추가 시 다른 경로(`0027` 등)가 만드는 intent와의 형식 충돌 여부 전수 확인 필요 — 여전히 미해결, TestPlan 단계로 이월.
(c) ~~advisory lock namespace 중앙 레지스트리~~ — 옵션 (a) 확정으로 옵션 (b)(advisory lock) 자체가 채택되지 않았으므로 **더 이상 관련 없음(moot)**.
(d) **§2의 라이브 오염 데이터(5건) 정리 여부 — Human 결정으로 확정: 정리하지 않고 그대로 둔다(§1 "라이브 오염 데이터 처리 방침" 참고), Stage 4의 UNIQUE 제약 실증 검증 자료로 활용한다.**
(e) §2의 재현 테스트 격리 가이드라인 제안을 공식 문서화할지 여부 — 여전히 Human 결정 필요(이번 지시문은 "그대로 유지"만 요구, 채택 여부는 미결정).
(f) ~~옵션 (b)/(c) 채택 시 락 상호작용 검증~~ — 옵션 (a) 확정으로 **더 이상 관련 없음(moot)**.
(g) **신규** — §1.2 순서 1(제약 실패 재현)과 순서 3(제약 성공 적용) 사이에 순서 2(정리)가 반드시 끼어들어야 하는 순서 의존성을 TestPlan이 명시적인 단계 순서로 강제해야 한다 — 순서가 뒤바뀌면 순서 3이 항상 순서 1과 같은 이유로 실패한다.
(h) **신규** — §1.2 순서 2의 FK 참조 0건 확인은 이번 문서 작성 시점 기준이며, Stage 4 착수 시점에 재확인이 필수다(§1.2 순서 2 본문에 이미 명시).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600561_Overview_Payment_Intent_Race_Condition_Fix.md`(이 문서의 직접 전제)
- `000056_Register_Concurrency_Risk.md` §3(PAY-CON-002)/§7(공통 해법 카탈로그) — 이 워크패킷이 참조하는 도구 목록.

### Full Rules Required

- `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` — 수정 대상.
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — 옵션 (b) 재사용 템플릿.
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — 옵션 (c) 참고, PAY-CON-001 대조.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- PAY-CON-001 재조사 — 범위 밖(`600561_Overview.md` §5와 동일).
- 라이브 오염 데이터 정리(DML) — Human 결정 대기, 이 문서는 수행하지 않음.
- 재현 테스트 격리 가이드라인의 공식 문서화 — 제안만, 채택은 Human 결정.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**최종 확정(Human 결정 반영).** §1에서 옵션 (a)를 최종 채택했다 — `payment_intents.idempotency_key`에 `UNIQUE` 제약 추가 + `resolve_or_create_payment_intent()`의 INSERT를 `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`로 전환. §1.2에서 정확한 4단계 마이그레이션 설계(순서 1: 제약 실패 재현 → 순서 2: FK 참조 0건 확인 후 정리 → 순서 3: 제약 성공 적용 → 순서 4: 헬퍼 함수 전환)를 라이브로 재확인한 실제 데이터(중복 쌍의 정확한 `id`/`idempotency_key`/`created_at`) 기준으로 작성했다. §1.3/§1.4에 결정 이전 이력(옵션 비교표, DO NOTHING 대안 검토)을 참고용으로 보존했다. §2(라이브 오염 사고 Open Item, 재발 방지 가이드라인 제안)는 지시대로 변경 없이 유지했다 — 처리 방침은 §1에서 확정("정리하지 않고 Stage 4 실증 검증 자료로 활용"). §3에서 옵션 (a) 확정으로 해소되거나 더 이상 무관해진 Open Item(a/c/f)을 표시하고 신규 Open Item(g/h)을 추가했다. `600563_TestPlan.md`/`600564_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았고, 라이브 DB의 오염 데이터도 정리하지 않았다(Human 결정에 따라 의도적으로 보존).
