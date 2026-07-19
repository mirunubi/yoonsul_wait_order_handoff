# Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스02 (호출/도착확인)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** slice_02_customer_call_arrival_input_package.md, slice_02_customer_call_arrival_migrations_concat.sql (5개 migration 원본 기반)

> 범위: 대기 손님 호출/도착확인 5개 RPC(`_record_waiting_call`(내부 헬퍼), `call_next_waiting_customer`, `call_waiting_customer`, `confirm_arrival`, `mark_session_arrived`)에 집중. 공유 테이블 상태정의는 슬라이스05, 대기 등록/조회는 슬라이스01 관할이므로 참조만 표시. 마이그레이션 5개(0160/0164/0167/0115/0050) 중 타 슬라이스 함수(get_waiting_*/cancel_waiting/seat_* 등)는 표시만 하고 판단하지 않는다.

## 1. Reconstructed Domain Purpose

이 슬라이스는 대기 파이프라인의 **"호출 → 도착확인"** 구간이다. 재구성한 책임:
- **호출**: 직원이 (a) 큐의 다음 손님을 자동 호출(`call_next_waiting_customer`) 또는 (b) 특정 세션을 지목 호출(`call_waiting_customer`)한다. 두 함수 모두 세션 데이터를 조회·검증한 뒤 **내부 공유 헬퍼 `_record_waiting_call`** 에 위임한다.
- **_record_waiting_call**: `order_sessions.session_status`를 `ARRIVAL_PENDING`으로 전이 + `expires_at` 스냅샷 저장, `session_events('customer_called')` 기록, `call_count`를 session_events에서 **파생 집계**, 알림 3종(WAITING_QUEUE Realtime / DID_DISPLAY / 전화번호 있으면 푸시), `ledger.events` 기록, i18n 호출 메시지 반환.
- **도착확인**: 손님/시스템이 `confirm_arrival` → 내부적으로 `mark_session_arrived` 호출로 `arrived_at` 기록.

이 슬라이스는 마이그레이션 주석에 드러난 **"contract recovery"(0160)** 의 핵심 무대다: 과거 `order_sessions`에 저장하던 phantom 컬럼(`called_at`/`call_count`/`table_number`/`pre_order_amount`)을 제거하고, 호출 이력을 `session_events`에서 파생하도록 재설계한 흔적이 명확히 보인다.

## 2. Reconstructed State Machines

- **호출 전이** (`_record_waiting_call`): `{WAITING | ARRIVAL_PENDING}` → `ARRIVAL_PENDING`. 무조건 UPDATE(내부 헬퍼 자체엔 상태 게이트 없음). `expires_at = now() + wait_call_expire_minutes(기본 5분)`. session_events `customer_called`(from=원상태, to=ARRIVAL_PENDING).
- **자동 호출 게이트** (`call_next_waiting_customer`): `session_status = 'WAITING'` 세션만 대상, `coalesce(queue_position, wait_number)` 오름차순 1건 `for update skip locked` 선택. **재호출(ARRIVAL_PENDING) 불가**.
- **지목 호출 게이트** (`call_waiting_customer`): `session_status in ('WAITING','ARRIVAL_PENDING')` 허용 → **재호출 지원**. SEATED면 `waiting_already_seated`, 그 외는 `waiting_not_callable`.
- **도착확인 전이** (`mark_session_arrived`): `{WAITING | ARRIVAL_PENDING}` → `ARRIVAL_PENDING`(+`arrived_at=now()`). session_events `customer_arrived`. 상태값 자체는 호출과 동일한 `ARRIVAL_PENDING`(§4-4).
- **confirm_arrival**: `mark_session_arrived` 위임 성공 시, 추가로 Realtime 알림 + 자체 `ledger.events('arrival_confirmed')` 기록. 예외 시 `append_audit_record(decision='FAILED')` 후 에러 반환.
- 상태값 정의(chk_session_status 등)는 슬라이스05 관할.

## 3. Reconstructed Authorization/Boundary Model

- 5개 전부 SECURITY DEFINER.
- **proacl 3분화**(§D.1):
  - `_record_waiting_call` → **owner-only(`postgres=X`)**: client 롤 전부 차단. 내부 헬퍼로서 직접 호출 불가(0167이 명시적으로 `revoke ... from public`).
  - `call_next_waiting_customer` → **authenticated 전용**(0167이 revoke public + grant authenticated).
  - `mark_session_arrived` → authenticated 전용.
  - `call_waiting_customer` → **PUBLIC(anon 포함, `=X`)**.
  - `confirm_arrival` → **PUBLIC(anon 포함, `=X`)**.
- 즉 0167은 헬퍼와 자동호출의 권한만 교정했고, `call_waiting_customer`·`confirm_arrival`의 PUBLIC은 남겨 두었다(§4-6).
- 함수 내부 역할 검증 없음. 호출 함수들은 `p_actor_type := 'STAFF'`를 **하드코딩**하고 `p_actor_id`만 파라미터로 받아 이벤트/감사 라벨로 소비(§4-7).
- 테이블 RLS는 슬라이스05 관할(정책 텍스트 불명).

## 4. Anomalies / Suspicious Patterns

**4-1. (요청된 신호) 레거시 `call_next_waiting` DROP + 계약 축소.**
0160이 `catchmenu_pos.call_next_waiting(uuid,uuid,text,uuid,uuid,text)`를 `drop function if exists`로 제거하고 이름이 다른 `call_next_waiting_customer(uuid,uuid,uuid,text,text)`로 대체했다. 신 함수는 구 함수의 파라미터 중 **`p_actor_type`과 `p_specific_session_id`를 잃었다**. 결과로 (a) 자동호출 경로에서 actor_type을 지정할 수 없고 'STAFF'로 고정, (b) 자동호출로 "특정 세션 지목"이 불가능해져 그 역할이 `call_waiting_customer`로 완전히 분리됐다. 구 시그니처를 호출하던 코드는 전부 깨진다(이름·인자 모두 변경).

**4-2. 자동호출과 지목호출의 상태 게이트 불일치(재호출 비대칭).**
`call_waiting_customer`는 `WAITING`과 `ARRIVAL_PENDING` 둘 다 허용(재호출 가능)하는데, `call_next_waiting_customer`는 `WAITING`만 대상으로 한다(이미 호출된 손님은 자동호출 대상에서 제외). 같은 "호출" 행위인데 진입 경로에 따라 재호출 가능 여부가 다르다. (0160 원문 주석 스스로 "0050의 WAITING-only보다 call_waiting_customer의 재호출이 설계와 정합"이라 적어, 두 경로의 의도가 갈렸음을 시사.)

**4-3. `_record_waiting_call`에 상태 게이트 부재 — 헬퍼 단독 오용 시 위험.**
헬퍼는 넘겨받은 `p_session_id`의 상태를 검사하지 않고 무조건 `ARRIVAL_PENDING`으로 UPDATE한다. 게이트는 전적으로 두 호출자에 의존한다. 현재는 owner-only proacl(0167)로 직접 호출이 막혀 실제 위험은 낮으나, 향후 SEATED/COMPLETED 세션에 대해 이 헬퍼가 호출되면 상태를 잘못 되돌린다. 방어가 호출자 규율에만 의존하는 설계.

**4-4. `ARRIVAL_PENDING` 상태의 과부하 — "호출됨"과 "도착함"이 같은 상태값.**
`_record_waiting_call`(호출)과 `mark_session_arrived`(도착) **둘 다** 세션을 `ARRIVAL_PENDING`으로 만든다. 따라서 `session_status`만으로는 "호출했으나 아직 안 옴"과 "도착 확인됨"을 구별할 수 없고, 오직 `expires_at`(호출 시 세팅) vs `arrived_at`(도착 시 세팅) 타임스탬프와 session_events로만 구분된다. 상태머신상 두 생애주기 지점이 하나의 상태로 뭉개졌다.

**4-5. 도착 1건이 이벤트 2개(도메인 상이)로 이중 기록.**
`confirm_arrival` → `mark_session_arrived`가 `ledger.events('customer_arrived', event_domain='session')`를 남기고, 이어서 `confirm_arrival` 자신이 `ledger.events('arrival_confirmed', event_domain='waiting')`를 또 남긴다. 한 번의 도착이 서로 다른 event_domain('session' vs 'waiting')으로 두 번 기록된다. 더 넓게 보면 이 슬라이스의 event_domain 태깅이 일관되지 않다: 호출은 `_record_waiting_call`이 `'session'`, 도착확인은 `'waiting'`, 도착표시는 `'session'`.

**4-6. PUBLIC 노출 — `call_waiting_customer`가 anon 호출 가능.**
`confirm_arrival`의 PUBLIC은 손님 QR 자가 도착확인으로 설명 가능하나, **`call_waiting_customer`(직원이 손님을 호출)가 anon(비인증)에게 열려 있다.** 인증 없이 임의 `p_session_id`로 호출을 트리거해 DID/푸시 알림을 발생시킬 수 있다. 0167이 `_record_waiting_call`/`call_next_waiting_customer` 권한은 교정했지만 이 둘의 PUBLIC은 남겨, 권한 회수가 절반만 적용됐다(도메인 전반의 반복 패턴).

**4-7. actor_type 하드코딩 'STAFF' — 호출 주체 출처 소실.**
`call_waiting_customer`/`call_next_waiting_customer` 모두 `_record_waiting_call(p_actor_type := 'STAFF')`를 고정 전달한다. 실제 호출 주체가 매니저·에이전트·시스템이어도 session_events/ledger에 'STAFF'로 기록된다. `mark_session_arrived`/`confirm_arrival`은 반대로 `'CUSTOMER'` 고정. 주체가 항상 상수라 감사 추적성이 약하다.

**4-8. 만료 기준 설정 필드 교체(5분으로 반감) + 사용처 없는 컬럼 잔존.**
신 호출 함수들은 `wait_call_expire_minutes(기본 5)`로 만료를 계산한다. 반면 DROP된 구 `call_next_waiting`(0050)은 `no_show_auto_expire_minutes(기본 10)`를 썼다. 0160은 `no_show_auto_expire_minutes`를 **COMMENT로만 DEPRECATED 표기하고 DROP하지 않았다**(주석: "wait_call_expire_minutes로 대체됨, 사용처 없음"). 결과로 (a) 호출→노쇼 만료창이 10분→5분으로 절반이 됐고, (b) 사장된 설정 컬럼이 스키마에 남아 있다.

**4-9. `confirm_arrival`의 from_state 스냅샷 시점 문제.**
`confirm_arrival`은 `mark_session_arrived`(이미 상태를 ARRIVAL_PENDING으로 전이)를 먼저 호출한 뒤, 자신의 'arrival_confirmed' 이벤트에 `from_state = v_session.session_status`(전이 **이전** 스냅샷)를 쓴다. 세션이 이미 ARRIVAL_PENDING(호출된 상태)에서 도착확인되면 from==to==ARRIVAL_PENDING의 무의미한 전이가 기록된다.

**4-10. `confirm_arrival` 예외 핸들러의 search_path에 catchmenu_audit 없음.**
`confirm_arrival`의 `SET search_path`에는 `catchmenu_audit`가 없는데 예외 블록은 `catchmenu_audit.append_audit_record(...)`를 명시 스키마로 호출한다. 명시 스키마 호출이라 실행 자체는 되지만, 헬퍼/도착표시 함수들과 search_path 구성이 제각각(`mark_session_arrived`는 audit 포함하나 호출 안 함)이라 일관성이 없다.

**4-11. 라이브 작동 증거 없음.**
호출/도착으로 생성될 `session_events`(customer_called/customer_arrived)가 라이브 0행(슬라이스05 §C). 이 슬라이스의 모든 전이는 이론 설계이며 실제 실행 이력이 없다.

## 5. Confidence Notes

- **4-1/4-8(레거시 DROP·설정 교체)**: 0160 마이그레이션 주석과 DROP 문으로 직접 확인된 사실(추정 아님). 단 구 `call_next_waiting`을 호출하던 상위(엣지/앱) 코드가 실제로 있었는지, 있었다면 신 이름으로 갱신됐는지는 이 자료 밖.
- **4-6(PUBLIC)**: `call_waiting_customer`/`confirm_arrival`의 PUBLIC은 §D.1 proacl 요약에서 확정. 0115/0164에서 이들 grant를 어떻게 설정했는지 원문 grant 문은 이 패키지에서 완전히 보이지 않아, PUBLIC이 의도인지 누락인지는 불명(0167이 이 둘을 건드리지 않은 것은 확인).
- **4-4(ARRIVAL_PENDING 과부하)**: 상태값 전체 의미는 슬라이스05 chk_session_status 소관. 여기선 두 함수가 같은 값을 세팅한다는 사실만 확정. 후속 착석(SEATED) 전이는 슬라이스04 관할.
- **4-9**: from_state가 pre-mark 스냅샷인 점은 코드로 확정. 실제로 이 무의미 전이가 문제를 일으키는지는 소비 측(이벤트 리플레이/프로젝션) 로직에 달림.
- 형제 함수(get_waiting_status/admin_view/cancel_waiting, 0164)와 seat_waiting_customer(0163)는 슬라이스 01/04 관할로 여기서 판단하지 않음.
- RLS 정책 텍스트 없음. 민감 컬럼(phone_hash) redacted — 존재/용도만 판단.
