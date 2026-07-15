# 600571_Overview_Cancel_Payment_Phantom_Column_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 2 — 옵션 B 채택 확정, `refund_payment()`/`request_refund()` 관계 확인(§7.5 신규), 범위를 Workpacket 1(이번)/Workpacket 2(이월)로 명확히 분리.

## Change ID

`cancel_payment_phantom_column_fix`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510`/`600540`/`600550`/`600560` 4개다(재확인, `ls`). 10단위 관례상 `600560` 다음 빈 번호는 `600570` — 지시문의 가칭과 일치한다.

## §1 배경 재확인 — `payment_ledger` 컬럼 개수 정정, `updated_at` 부재 재확인

지시문은 "삼중검증 완료... 재확인 불필요"라고 명시했으나, 이번 세션 원칙(§43/§44)에 따라 직접 재확인했다. **정정 필요**: 배경은 "payment_ledger 실제 컬럼 24개(오늘 이미 확인)"라고 했으나, `information_schema.columns` 라이브 재조회 결과 **28개**다(`600550`/`600560` 워크패킷에서 이미 확인된 것과 동일한 수 — 이번 문서에서 재확인). `updated_at` 컬럼은 이 28개 중에 **없다**(재확인, 0건) — 이 핵심 주장 자체는 정확하다.

## §2 `cancel_payment()`(`0037:13-238`) 전수 감사

**함수가 접점을 갖는 테이블 전부**를 `payment_ledger` 외에도 개별적으로 재확인했다(지시문의 "confirm_payment()에서 5개나 나왔던 전례가 있으니 안심하지 말 것" 원칙 적용).

| 테이블 | 참조 컬럼 | 결과 |
|---|---|---|
| `catchmenu_payment.payment_ledger`(SELECT, L43-49) | `id,order_id,session_id,intent_id,ledger_status,approved_amount,kds_release_authorized,provider_type,provider_payment_key,provider_approval_number,business_day,business_timezone` | 전부 실존 |
| `catchmenu_agent.evidence_packets`(INSERT, L73-96) | `tenant_id,store_id,packet_type,packet_status,risk_level,subject_type,subject_id,payment_ledger_id,prior_state,staff_visible_explanation,actor_type,actor_id,correlation_id,business_day,business_timezone` | 전부 실존(라이브 39개 컬럼 전체 대조) |
| `catchmenu_payment.payment_ledger`(UPDATE, L101-108) | `ledger_status,cancelled_amount,net_amount,kds_release_authorized,evidence_packet_id,updated_at` | **`updated_at` 1건만 phantom** — 나머지 5개는 실존 |
| `catchmenu_kds.kds_tickets`(UPDATE, L112-117) | `kds_status,cancelled_at,hold_reason,updated_at` | 전부 실존 |
| `catchmenu_pos.orders`(UPDATE, L124-128) | `order_status,cancelled_at,updated_at` | 전부 실존 |
| `catchmenu_pos.order_sessions`(UPDATE, L133-137) | `session_status,cancelled_at,updated_at` | 전부 실존 |
| `catchmenu_payment.payment_events`(INSERT, L142-148) | `tenant_id,store_id,order_id,ledger_id,event_type,from_status,to_status,caused_by_type,caused_by_id,amount_at_event,event_payload,correlation_id,occurred_at` | 전부 실존 |
| `catchmenu_ledger.events`(INSERT, L165-174) | `tenant_id,store_id,event_domain,event_type,event_version,subject_type,subject_id,from_state,to_state,caused_by_type,caused_by_id,event_payload,order_id,payment_id,correlation_id,business_day,business_timezone,occurred_at` | 전부 실존 |
| `catchmenu_audit.append_audit_record(...)` | 함수 호출(파라미터), 테이블 스키마 문제 아님 | 별도 검토 대상 아님 |

**결론**: `cancel_payment()`는 배경이 지목한 `payment_ledger.updated_at`(L108) **딱 1건**만 phantom이다 — 다른 7개 접점 테이블 전체를 개별 대조했으나 추가 phantom은 발견되지 않았다. `ledger_status`에 세팅하는 값(`'CANCELLED'`)도 `chk_ledger_status` 허용값에 있음을 재확인했다.

## §3 `partial_cancel_payment()`(`0037:241-479`) 전수 감사 — 신규 발견, 동일 결함

지시문이 "같은 파일 안에 있다면 함께 확인"이라 요청한 대로 확인한 결과, **이 함수도 존재하며, `cancel_payment()`와 정확히 동일한 phantom 컬럼 결함을 갖고 있다.**

`payment_ledger` UPDATE(`0037:352-361`):
```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case when v_new_net_amount = 0 then 'CANCELLED' else 'PARTIAL_CANCELLED' end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()   -- ← phantom, cancel_payment()와 동일한 컬럼
where id = p_ledger_id;
```
`ledger_status`에 세팅하는 두 값(`'CANCELLED'`/`'PARTIAL_CANCELLED'`) 모두 CHECK 허용값 안에 있다. 나머지 접점(`evidence_packets`/`payment_events`/`catchmenu_ledger.events`/`append_audit_record`)도 `cancel_payment()`와 동일한 컬럼 구성이며 전부 실존을 재확인했다. **`updated_at` 1건만 phantom** — `cancel_payment()`와 동일한 패턴.

## §4 `refund_payment()`(`0037:482-737`) 전수 감사 — 지시문에 없었으나 같은 파일, 동일 결함 발견

지시문은 이 함수를 명시적으로 지목하지 않았으나, 같은 파일(`0037`)에 정의되어 있고(`grep`으로 재확인) `payment_ledger`를 직접 수정하는 세 번째 함수이므로 전수 확인 범위에 포함했다.

`payment_ledger` UPDATE(`0037:603-610`):
```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,   -- 'REFUNDED' 또는 'PARTIAL_REFUNDED', 둘 다 CHECK 허용값
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()   -- ← phantom, 세 번째 동일 발생
where id = p_ledger_id;
```
`catchmenu_pos.orders` UPDATE(`0037:613-620`)의 `updated_at`은 `orders` 테이블에는 실제로 존재하므로 문제 없음 — **`payment_ledger.updated_at`만** phantom이다. 나머지 접점(`evidence_packets`/`payment_events`/`catchmenu_ledger.events`/`append_audit_record`) 전부 실존 확인.

**§2-§4 종합**: `0037` 파일의 세 함수(`cancel_payment`/`partial_cancel_payment`/`refund_payment`) 전부가 **동일한 단일 원인**(`payment_ledger.updated_at` phantom, 총 3회 반복)으로 100% 크래시한다 — 이 테이블은 애초에 범용 `updated_at` 갱신 관례를 쓰지 않고 목적별 개별 타임스탬프 컬럼(`approved_at`/`kds_release_authorized_at`/`reconciliation_checked_at`)만 갖는 설계인데, `0037`의 세 함수 모두 이 관례를 잘못 가정하고 작성된 것으로 보인다.

## §5 `request_refund()`(`0098:859-1095`) 전수 감사 — 대규모 신규 발견, 배경이 파악한 것보다 훨씬 심각

배경은 `ledger_status='REFUND_PENDING'`이 `chk_ledger_status` 허용값에 없다는 **한 가지**만 지목했다. 전수 감사 결과 **같은 INSERT 문 안에 phantom 컬럼 6개가 추가로 있고, NOT NULL 컬럼 2개가 누락됐으며, phantom CHECK 값도 하나 더 있다.**

`payment_ledger` INSERT(`0098:950-982`) 컬럼 대조:

| INSERT가 쓰는 컬럼 | 라이브 실존 여부 |
|---|---|
| `tenant_id`/`store_id`/`order_id`/`session_id` | 실존 |
| `provider_type` | 실존 |
| `payment_method` | **phantom**(`confirm_payment()` 원래 결함과 동일) |
| `provider_tx_id` | **phantom**(→ `provider_payment_key`여야 함) |
| `provider_approval_number` | 실존 |
| `approved_amount` | 실존 |
| `fee_amount` | **phantom**(대응 컬럼 없음) |
| `net_amount` | 실존 |
| `ledger_status`(값: `'REFUND_PENDING'`) | 컬럼은 실존하나 **값이 `chk_ledger_status` 허용 목록(`APPROVED`/`CANCELLED`/`REFUNDED`/`PARTIAL_CANCELLED`/`PARTIAL_REFUNDED`/`UNCERTAIN`/`DISPUTED`/`UNDER_REVIEW`)에 없음**(배경이 지목한 항목, 재확인) |
| `refund_reason` | **phantom, 신규 발견**(대응 컬럼 없음) |
| `is_partial_refund` | **phantom, 신규 발견**(대응 컬럼 없음) |
| `original_ledger_id` | **phantom, 신규 발견**(대응 컬럼 없음) |
| `business_day`/`business_timezone` | 실존 |
| (컬럼 목록에 없음) `intent_id` | **NOT NULL 컬럼 누락**(`confirm_payment()` 원래 결함과 동일 패턴) |
| (컬럼 목록에 없음) `ledger_entry_type` | **NOT NULL 컬럼 누락**(동일) |

추가로, `append_audit_record(p_decision := 'REFUND_PENDING', ...)`(`0098:1015`) — **`catchmenu_ledger.audit_records`의 `chk_audit_decision` CHECK 제약(허용값: `APPROVED`/`REJECTED`/`OVERRIDDEN`/`DELEGATED`/`ESCALATED`/`CANCELLED`/`COMPLETED`/`FAILED`/`NOTED`/`SUSPENDED`/`REVOKED`)에도 `'REFUND_PENDING'`이 없다** — 라이브 재확인, 신규 발견. 다만 이 함수는 `payment_ledger` INSERT(위 표)에서 먼저 크래시하므로 이 지점까지 실행이 도달하지도 못한다.

`catchmenu_pos.orders`/`catchmenu_kds.kds_tickets` UPDATE, `catchmenu_ledger.events` INSERT는 전부 실존 컬럼만 사용(재확인). `notify_channel()` 호출은 함수 호출이라 별도.

**요약**: `request_refund()`는 `payment_ledger` INSERT 하나에 phantom 컬럼 **6개**(`payment_method`/`provider_tx_id`/`fee_amount`/`refund_reason`/`is_partial_refund`/`original_ledger_id`) + NOT NULL 누락 **2개**(`intent_id`/`ledger_entry_type`) + phantom CHECK 값 **2개**(`ledger_status='REFUND_PENDING'`, `audit_records.decision='REFUND_PENDING'`)를 동시에 갖는다 — `confirm_payment()`의 원래 결함(5개)보다 많다.

## §6 `confirm_refund()`(`0098:1101-1288`) 전수 감사 — 추가 대규모 신규 발견

`request_refund()`가 만든(만들려고 시도하는) 환불 원장을 나중에 확정하는 함수. `request_refund()`가 이미 크래시하므로 이 함수는 현재 **실제로 호출될 데이터 자체가 만들어지지 않는다** — 그러나 이 함수 자신의 코드도 독립적으로 phantom 결함을 갖고 있어, 별도로 기록한다.

`payment_ledger` SELECT(`0098:1137-1145`): `refund_reason`/`original_ledger_id`(둘 다 phantom, §5와 동일 컬럼) 조회 시도, `where ledger_status = 'REFUND_PENDING'`(phantom 값, §5와 동일).

`payment_ledger` UPDATE 1(`0098:1164-1176`, 환불 원장 자체):
```sql
set
  ledger_status = v_new_status,        -- 'REFUNDED' 또는 'REFUND_FAILED'
  provider_tx_id = p_provider_cancel_tx_id,   -- phantom
  provider_response = coalesce(...),          -- phantom(→ provider_response_id여야 함)
  refunded_at = case ... end,                 -- phantom(신규 발견, 대응 컬럼 없음 — refunded_amount는 있으나 refunded_at은 없음)
  updated_at = now()                          -- phantom
where id = p_refund_ledger_id;
```
**`v_new_status`의 `'REFUND_FAILED'`도 `chk_ledger_status` 허용값에 없다**(신규 발견 — `REFUND_PENDING`과 별개의 두 번째 phantom 값). `'REFUNDED'`는 허용값에 있어 정상.

`payment_ledger` UPDATE 2(`0098:1180-1185`, 원결제 원장):
```sql
set
  ledger_status = 'REFUNDED',   -- 허용값, 정상
  refunded_at = now(),          -- phantom(위와 동일)
  updated_at = now()            -- phantom
where id = v_refund.original_ledger_id;
```

`append_audit_record(p_decision := v_new_status, ...)`(`0098:1235`) — `v_new_status`가 `'REFUNDED'`든 `'REFUND_FAILED'`든 **둘 다 `chk_audit_decision` 허용값에 없다**(§5에서 확인한 CHECK 목록에 `REFUNDED`/`REFUND_FAILED` 어느 쪽도 없음) — 신규 발견.

`catchmenu_ledger.events` INSERT(`0098:1247-1254`)는 전부 실존 컬럼 사용, 문제 없음. `log_diagnostic()`/`create_operation_alert()` 호출은 함수 호출이라 별도(이번 문서에서 파라미터 체크 제약까지는 확인하지 않음, §9 Open Item).

**요약**: `confirm_refund()`는 phantom 컬럼 **5개**(`provider_tx_id`/`provider_response`/`refunded_at`×2회/`updated_at`×2회, `refund_reason`/`original_ledger_id`는 SELECT에서 재사용) + phantom CHECK 값 **3개**(`ledger_status='REFUND_PENDING'` 조회 조건, `ledger_status='REFUND_FAILED'`, `audit_records.decision`에 `'REFUNDED'`/`'REFUND_FAILED'` 둘 다) 결함을 갖는다.

## §7 종합 인벤토리 — 두 파일, 다섯 함수, phantom 총계

| 함수 | 파일 | phantom 컬럼명 개수 | NOT NULL 누락 | phantom CHECK 값 | 현재 실제 호출자(§7.5에서 재확인) |
|---|---|---|---|---|---|
| `cancel_payment()` | `0037` | 1(`updated_at`) | 0 | 0 | **2건, 활성** — `0038`(Toss 웹훅), `0056`(VAN) |
| `partial_cancel_payment()` | `0037` | 1(`updated_at`) | 0 | 0 | 0건 |
| `refund_payment()` | `0037` | 1(`updated_at`) | 0 | 0 | 0건 |
| `request_refund()` | `0098` | 6 | 2(`intent_id`/`ledger_entry_type`) | 2(`ledger_status`/`audit_records.decision`, 둘 다 `'REFUND_PENDING'`) | **3건, 활성** — `0102`(OKPOS)/`0103`(Toss Payments)/`0104`(Toss POS), 셋 다 자기 자신을 "표준 환불 파이프라인"이라 주석에 명시 |
| `confirm_refund()` | `0098` | 5(중복 포함 실질 4종) | 0 | 3(`ledger_status`×2 값, `audit_records.decision`×2 값) | 0건(SQL 직접 호출 없음 — `0113` API 스펙 문서에 Edge Function 웹훅 콜백 대상으로만 문서화됨) |

**공통 원인 vs 개별 원인**: `payment_ledger.updated_at` 부재는 5개 함수 전부에 공통(`request_refund`/`confirm_refund`도 각각 갖고 있음 — 위 표의 개수에 포함됨). 나머지(phantom 컬럼명 다수, `REFUND_PENDING`/`REFUND_FAILED` 같은 미정의 상태값)는 환불 파이프라인(`request_refund`/`confirm_refund`)에만 있는 **훨씬 심각한 별개 결함군**이다 — `0037`의 세 함수가 "컬럼 이름 하나만 잘못됨"인 반면, `0098`의 환불 두 함수는 **애초에 존재하지 않는 상태 모델(별도의 "환불 대기 원장 행"을 만드는 설계) 자체가 라이브 스키마와 근본적으로 안 맞는 것**으로 보인다 — `refund_reason`/`is_partial_refund`/`original_ledger_id`/`refunded_at` 4개 모두 이 "별도 환불 원장 행" 설계에만 필요한 개념이며 `0014`의 실제 DDL에는 애초에 반영되지 않았다.

## §7.5 필수 사전 확인 — `refund_payment()`와 `request_refund()`/`confirm_refund()`의 관계 (Revision 2, Human 요청 반영)

지시문의 우려("이름은 다르지만 같은 '환불' 개념을 다루는 두 그룹이 있는데, 병렬 파이프라인인지 한쪽이 legacy인지")를 실제 호출자 재확인으로 답한다.

### §7.5.1 `refund_payment()`의 정확한 역할과 호출자

`0037:2-5`(파일 헤더, 원문): `"cancel_payment: full cancellation of approved payment. partial_cancel_payment: partial amount cancellation. refund_payment: refund after order completion."` — 즉 파일 작성자 자신의 의도는 `cancel_payment()`(승인된 결제의 완전 취소, 주문 완료 전 상황)와 `refund_payment()`(주문 완료 후 환불)을 **서로 다른 생애주기 시점**의 함수로 명확히 구분해뒀다.

**호출자 재확인**(전체 `sql/migrations/*.sql` + `catchmenu_app/`/`apps/` 재검색, 자기 자신의 정의/주석/grant/revoke 제외): `refund_payment()`는 **0건**이다 — SQL 어디에서도, 클라이언트 코드 어디에서도 호출되지 않는다.

### §7.5.2 두 그룹의 관계 — "병렬 파이프라인" 맞음, "하나는 legacy" 아님

라이브 재확인 결과, `cancel_payment()`(`0037`)와 `request_refund()`(`0098`)는 이 세션에서 이미 확인된 "`confirm_payment_from_provider()`(`0027`) vs `confirm_payment()`(`0098`)" 병렬 파이프라인 구조와 **정확히 같은 형태로 갈라져 있다**:

| | 파이프라인 1 (`0027`/`0038`/`0056`) | 파이프라인 2 (`0098`/`0102`/`0103`/`0104`) |
|---|---|---|
| 결제 확인 | `confirm_payment_from_provider()`(`0027`) | `confirm_payment()`(`0098`) |
| 취소/환불 | `cancel_payment()`(`0037`) — **활성, 호출자 2건**(`0038`/`0056`) | `request_refund()`(`0098`) — **활성, 호출자 3건**(`0102`/`0103`/`0104`) |
| 이 파이프라인만의 미사용 함수 | `partial_cancel_payment()`(`0037`, 0건)/`refund_payment()`(`0037`, 0건) | `confirm_refund()`(`0098`, 0건 — 단 Edge Function 웹훅 콜백용으로 설계된 것으로 보임, §5 인용) |

**결론(사실, 판단 아님)**: `refund_payment()`가 `request_refund()`/`confirm_refund()`의 legacy(구버전, 대체된 것)라는 근거는 **없다** — 두 그룹 다 각자의 파이프라인 파일(`0037`/`0098`) 안에서 독립적으로 정의됐고, 어느 한쪽이 다른 쪽을 대체했다는 흔적(`rename`, `_legacy` 접미사, deprecation 주석 등)이 코드에 없다. 대신 실제 패턴은: **파이프라인 1은 "취소"(`cancel_payment`)만 실제로 배선되어 있고 "완료 후 환불"(`refund_payment`)은 설계만 되고 배선되지 않은 상태**, **파이프라인 2는 "환불 요청"(`request_refund`)까지는 배선되어 있고 "환불 확정"(`confirm_refund`)은 Edge Function 콜백을 기다리는 설계**로 각각 다르게 미완성이다. 이는 이 세션에서 반복 확인된 "설계는 됐으나 배선 안 된 함수"(`start_cooking()`/`bulk_commit_kds_tickets()`/`flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT` 등) 패턴과 일치한다.

### §7.5.3 부수 발견 — `request_refund()`의 실제 호출 파라미터, 크래시 도달 여부가 호출자마다 다름

`request_refund()`는 `p_refund_amount <= 0`이면 즉시 `refund_amount_invalid` 에러로 조기 반환한다(`0098:924-938`, phantom 컬럼 INSERT 이전). 실제 호출부를 확인한 결과:
- `0103`(Toss Payments, L834): `p_refund_amount := v_refund_amount`(계산된 실제 금액) — **phantom INSERT까지 실제로 도달할 수 있다.**
- `0102`(OKPOS, L1049)/`0104`(Toss POS, L954): `p_refund_amount := 0`(하드코딩) — **항상 조기 반환하며, phantom INSERT에 도달하지 않는다.**

이는 `request_refund()` 자체의 phantom 컬럼 결함(§5)과는 별개의, **호출자 쪽의 파라미터 버그**로 보인다(0원 환불 요청 자체가 무의미) — 이번 워크패킷(Workpacket 1)의 범위 밖이며, `600098`(Workpacket 2, 환불 파이프라인 재설계)에서 다룰 사안으로 기록한다.

## §8 범위 확정 — Workpacket 1(이번, `0037` correction) / Workpacket 2(이월, `0098` 환불 파이프라인 재설계)

**Human 결정(2026-07-15, 재논의 금지)**: 옵션 B 채택. `0037`의 `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` 세 함수의 동일 phantom 컬럼(`updated_at`)을 이번 워크패킷(Workpacket 1)에서 함께 수정한다. `0098`의 `request_refund()`/`confirm_refund()`는 원장 모델 재설계가 필요한 완전히 다른 성격의 작업이므로 이번 범위에서 제외하고, 별도 워크패킷("Refund Pipeline Contract Redesign")으로 이월한다.

### Workpacket 1(이번 워크패킷) — `0037` correction 허용/금지 사항

| 구분 | 내용 |
|---|---|
| **허용** | `payment_ledger` UPDATE 문에서 `updated_at = now()` 제거(3개 함수, 총 3개소) |
| **허용** | 최소 문법 정렬(예: 제거로 인해 어긋나는 콤마/줄바꿈 등 순수 구문 정리) |
| **허용** | 검증(Stage 5) — 세 함수 각각 실제 호출/재현 |
| **금지** | 상태 전이 로직 변경(`ledger_status` 분기, `CANCELLED`/`PARTIAL_CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED` 값 자체나 그 조건) |
| **금지** | 환불 원장 구조 변경(`refunded_amount`/`cancelled_amount`/`net_amount` 계산 로직) |
| **금지** | 함수 통합·rename(`cancel_payment`/`partial_cancel_payment`/`refund_payment`를 하나로 합치거나 이름을 바꾸는 것) |
| **금지** | `0098`(`request_refund`/`confirm_refund`) 수정 — Workpacket 2 범위 |
| **금지** | 호출부 리팩토링(`0038`/`0056`이 `cancel_payment()`를 호출하는 방식 자체를 바꾸는 것 — phantom 컬럼 제거로 호출부의 파라미터 계약이 바뀌지 않으므로 애초에 손댈 필요가 없다) |

### Workpacket 2(별도 이월) — 환불 파이프라인 재설계, 이번 문서는 범위만 표시

`request_refund()`/`confirm_refund()`(`0098`) — phantom 컬럼 6+5개, NOT NULL 누락 2개, phantom CHECK 값(두 테이블에 걸쳐) 최대 5개(§5/§6), `0102`/`0104`의 `p_refund_amount:=0` 호출 버그(§7.5.3)까지 포함해 종합 재설계가 필요하다. `600550`(`confirm_payment` 정합화, `intent_origin` 신설)과 유사한 수준의 Overview/Logic 재작업이 필요하다고 판단되며, 이번 문서는 그 필요성만 기록하고 설계하지 않는다.

## §9 Open Questions

(a) ~~5개 함수 전부의 실제 라이브 호출자~~ — **해소됨(§7.5)**: `cancel_payment()`(2건, 활성)/`request_refund()`(3건, 활성)은 각자 파이프라인의 실제 사용 경로이고, `partial_cancel_payment()`/`refund_payment()`/`confirm_refund()`는 0건(잠재적, 배선 안 됨).
(b) `log_diagnostic()`/`create_operation_alert()`(`confirm_refund()`가 호출) 등 함수 호출의 파라미터 자체가 유효한지(예: `p_log_level`/`p_alert_severity`의 CHECK 허용값)는 이번 문서에서 확인하지 않았다 — Workpacket 2 범위.
(c) `chk_ledger_status`에 `REFUND_PENDING`/`REFUND_FAILED`를 신규 허용값으로 추가하는 것이 옵션인지(DDL 확장), 아니면 완전히 다른 상태 표현(예: 별도 `refund_status` 컬럼, 또는 `600550`의 `intent_origin`처럼 provenance 컬럼 추가)이 나은지는 Workpacket 2의 핵심 설계 결정이 된다 — 이번 문서는 판단하지 않는다.
(d) `original_ledger_id`(환불 원장이 원결제 원장을 가리키는 개념)를 표현할 방법 — `payment_ledger`에 자기 참조 FK 컬럼을 추가할지, 다른 방식(예: `payment_events`/`catchmenu_ledger.events`의 기존 이력 추적 메커니즘 재사용)으로 대체할지도 Workpacket 2 결정 사항.
(e) **신규(Revision 2)** — `0102`/`0104`가 `request_refund()`를 `p_refund_amount := 0`으로 호출하는 것(§7.5.3)이 의도된 설계(예: "0원 환불 = 순수 취소 신호"라는 다른 의도)인지 단순 버그인지 — Workpacket 2에서 확인 필요.
(f) **신규(Revision 2)** — `cancel_payment()`가 활성 호출자를 가진 이상(`0038`/`0056`), Workpacket 1의 `updated_at` 제거가 이 두 호출부의 기존 동작(현재는 매번 크래시하고 있었을 것)에 실질적으로 어떤 변화를 일으키는지(즉 지금까지 Toss 웹훅/VAN 경로의 결제 취소가 전부 실패해왔다는 뜻인지)는 Workpacket 1의 TestPlan/Verification 단계에서 명시적으로 확인해야 한다 — 이번 Overview는 phantom 컬럼 존재만 확인했다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` — `confirm_payment()`(0098) 원래 결함 수정 선례, 이번 워크패킷이 참고하는 패턴.
- `000056_Register_Concurrency_Risk.md` — 동시성 레지스터, 이 워크패킷은 phantom 컬럼(정합성) 문제이지 동시성 문제는 아니라는 점에서 구분됨.

### Full Rules Required

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`(L13-238)/`partial_cancel_payment()`(L241-479)/`refund_payment()`(L482-737) 전체.
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `request_refund()`(L859-1095)/`confirm_refund()`(L1101-1288) 전체.
- `sql/migrations/0014_create_payment_ledger.sql` — `payment_ledger` 실제 28개 컬럼, `chk_ledger_status` CHECK 제약.
- `catchmenu_ledger.audit_records`의 `chk_audit_decision` CHECK 제약(라이브 재확인, 이번 문서에서 처음 인용).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- `log_diagnostic()`/`create_operation_alert()` 파라미터 유효성(§9 (b)) — Workpacket 2 범위.
- `REFUND_PENDING`/`REFUND_FAILED` 상태 표현 재설계(§9 (c)/(d)) — 판단하지 않음, Workpacket 2 대상.
- `0102`/`0104`의 `p_refund_amount:=0` 호출 버그(§7.5.3/§9 (e)) — Workpacket 2 대상.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**최종 확정(Revision 2, Human 결정 반영).** §1에서 배경의 컬럼 개수(24→28) 오류를 정정했다. §2에서 `cancel_payment()`가 정확히 배경이 지목한 1건(`updated_at`)만의 결함임을 7개 접점 테이블 전수 대조로 확인했다. §3/§4에서 같은 파일의 `partial_cancel_payment()`/`refund_payment()`도 동일한 단일 결함을 갖고 있음을 신규로 확인했다. §5/§6에서 `request_refund()`/`confirm_refund()`가 훨씬 심각한 별개 결함군(phantom 컬럼 6+5개, NOT NULL 누락 2개, phantom CHECK 값 최대 5개)을 가짐을 확인했다. **§7.5(신규)에서 Human이 요청한 필수 사전 확인을 완료했다** — `cancel_payment()`(2건)/`request_refund()`(3건)는 각각 활성 파이프라인이며, `refund_payment()`는 legacy가 아니라 애초에 배선되지 않은 미완성 기능이다(호출자 0건, 대체 흔적 없음). **§8에서 Human 결정에 따라 옵션 B를 최종 채택**, Workpacket 1(이번, `0037` 세 함수의 `updated_at` correction, 정확한 허용/금지 목록 명시)과 Workpacket 2(이월, `0098` 환불 파이프라인 재설계)로 범위를 명확히 분리했다. `600572_Logic.md`(Workpacket 1)로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
