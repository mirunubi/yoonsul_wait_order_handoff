# Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스03 (노쇼/유예)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** slice_03_no_show_grace_input_package.md, slice_03_no_show_grace_migrations_concat.sql (3개 migration 원본 기반)

> 범위: 호출에 응답하지 않은 손님의 노쇼 처리 5개 RPC(`apply_no_show_transition`(공유 코어), `mark_no_show`(수동 래퍼), `process_expired_no_shows`(자동 배치), `expire_no_show_kds_hold`(KDS 유예 만료), `recover_no_show_grace_ticket`(지각 복구))에 집중. 공유 테이블·세션 상태정의는 슬라이스05, 호출/도착은 슬라이스02 관할로 참조만. `catchmenu_kds.kds_tickets`는 이 슬라이스의 연결점으로 스키마가 함께 제공됨.

## 1. Reconstructed Domain Purpose

이 슬라이스는 **"호출했으나 손님이 안 온 경우"** 를 처리한다. 재구성한 책임:
- **노쇼 확정**(공유 코어 `apply_no_show_transition`): `ARRIVAL_PENDING` 세션을 `NO_SHOW`로 전이하고 `arrival_reliability_score`를 20점 감점(하한 0). 수동(`mark_no_show`, STAFF)과 자동(`process_expired_no_shows`, SYSTEM 배치)의 두 진입점이 이 코어에 수렴한다.
- **사전주문 KDS 유예**: 노쇼된 세션에 사전주문(pre_order)이 있으면, 그 HOLD 상태 KDS 티켓을 즉시 취소하지 않고 `hold_reason='NO_SHOW_GRACE'` + `hold_expires_at = now()+유예분(기본15)`으로 표시해 **유예 기간 동안 살려 둔다**.
- **유예 만료**(`expire_no_show_kds_hold`, 배치): 유예 시간이 지난 NO_SHOW_GRACE HOLD 티켓을 `CANCELLED`(`hold_reason='NO_SHOW_GRACE_EXPIRED'`)로.
- **지각 복구**(`recover_no_show_grace_ticket`, 직원): 유예 만료 전이면 그 티켓을 정상 HOLD로 되돌려(hold_reason/expires_at 클리어) 늦게 온 손님의 주문을 회복.

즉 "노쇼 = 즉시 폐기"가 아니라, **사전주문 손님에 한해 유예 창을 주고 지각 복구를 허용하는** 설계다. 마이그레이션 주석에 드러난 **0161 "overload_and_redesign"** 이 이 슬라이스의 재설계 사건이다(구 0050 mark_no_show 오버로드 제거 + phantom 컬럼 참조하던 0118 cron 교체).

## 2. Reconstructed State Machines

### 2.1 세션 노쇼 전이 (order_sessions)
- `ARRIVAL_PENDING` → `NO_SHOW` (`apply_no_show_transition`). UPDATE 가드:
  - `session_status = 'ARRIVAL_PENDING'` AND
  - (`trigger_source='STAFF'`) OR (`trigger_source='SYSTEM'` AND `expires_at <= now()`).
  - 즉 **직원은 만료 여부 무관 즉시 노쇼 가능, 시스템 배치는 만료된 것만**.
- 부수효과: `arrival_reliability_score = greatest(0, coalesce(score,100) - 20)`, `cancelled_at = now()`.
- 멱등: 이미 `NO_SHOW`면 `no_show_already_applied`(success, idempotent=true) 반환. 상태가 그 외면 `session_not_markable`.

### 2.2 KDS 유예 상태 (kds_tickets, chk_kds_status 9종: HOLD/CAPACITY_CHECKING/COMMITTED/COOKING/READY/SERVED/COMPLETED/CANCELLED/MANUAL_FALLBACK)
- 노쇼+사전주문 시: `HOLD` 티켓 → `HOLD` 유지하되 `hold_reason='NO_SHOW_GRACE'`, `hold_expires_at=now()+grace`.
- `expire_no_show_kds_hold`: `HOLD & hold_reason='NO_SHOW_GRACE' & hold_expires_at<=now()` → `CANCELLED`(`hold_reason='NO_SHOW_GRACE_EXPIRED'`, `cancelled_at=now()`).
- `recover_no_show_grace_ticket`: `HOLD & hold_reason='NO_SHOW_GRACE' & hold_expires_at>now()` → `HOLD`(`hold_reason=null`, `hold_expires_at=null`).
- 유예/만료/복구는 `kds_status` 값 자체는 HOLD로 유지하고 `hold_reason`/`hold_expires_at`으로만 구분(만료 시에만 CANCELLED).

### 2.3 배치 경로
- `process_expired_no_shows`: `ARRIVAL_PENDING & expires_at<=now()` 세션을 `expires_at asc`, `limit batch_size`, `for update skip locked`로 잡아 각각 `apply_no_show_transition(SYSTEM)` 호출. 세션별 예외는 잡아서 계속(failed_ids 누적).
- 두 배치(`process_expired_no_shows`, `expire_no_show_kds_hold`)는 0161이 재작성한 `pg_cron_jobs.WAITING_SESSION_EXPIRE` cron이 distinct tenant/store별로 호출.

## 3. Reconstructed Authorization/Boundary Model

- 5개 전부 SECURITY DEFINER, plpgsql volatile.
- **proacl**(§D.1): `mark_no_show`만 명시 PUBLIC(`=X`, 0115 유래). 나머지 4개(`apply_no_show_transition`, `process_expired_no_shows`, `expire_no_show_kds_hold`, `recover_no_show_grace_ticket`)는 **`NULL`**(스키마 기본 = PUBLIC EXECUTE 유지, 명시적 revoke/grant 없음).
- 따라서 0161은 자신이 만든 5개 함수 어디에도 `revoke ... from public; grant ... to authenticated` 하드닝을 적용하지 않았다. 이는 형제 마이그레이션 0160/0167이 헬퍼를 owner-only로 잠그고 자동호출을 authenticated로 명시 부여한 것과 대비된다(§4-4).
- 실제 도달성: `catchmenu_pos`/`catchmenu_kds` 스키마 USAGE는 공통기반(0022)에서 `authenticated`에만 부여됐으므로, NULL proacl의 PUBLIC-execute는 실무상 authenticated가 실행 가능함을 의미(anon은 스키마 USAGE 부재로 차단). 단 "명시적 잠금 부재"라는 태세 차이는 존재.
- 함수 내부 역할 검증 없음. `apply_no_show_transition`은 `p_trigger_source`(STAFF/SYSTEM)만 검증하고, `p_actor_type`/`p_actor_id`는 감사 라벨로만 소비.

## 4. Anomalies / Suspicious Patterns

**4-1. (요청 신호와 연결) 레거시 mark_no_show 오버로드 DROP + phantom cron 교체.**
0161이 `catchmenu_pos.mark_no_show(uuid,uuid,uuid,text,uuid,text)`(0050판)를 `drop function if exists`로 제거했다. 주석은 "0050 mark_no_show 오버로드가 현행 0115 시그니처와 충돌"했고, "0118 WAITING_SESSION_EXPIRE cron이 여전히 phantom 컬럼 `called_at`/`no_show_at`/`cancel_reason`을 참조"했다고 자백한다. 즉 (a) 동일 이름의 두 mark_no_show가 공존하던 오버로드 모호성, (b) 존재하지 않는 컬럼을 참조하던 cron이 실제로 있었고, 이 슬라이스가 그 정리다.

**4-2. 노쇼 적용 대상이 ARRIVAL_PENDING으로 좁혀짐(계약 축소).**
`apply_no_show_transition`은 `session_status='ARRIVAL_PENDING'`만 노쇼로 전이한다. 그런데 구 0050/0115의 `mark_no_show`는 `WAITING` 또는 `ARRIVAL_PENDING` 둘 다 허용했다(슬라이스01 관측). 재설계로 "호출되지 않은 WAITING 손님을 노쇼 처리"하는 경로가 사라졌다 — 직원이 아직 부르지도 않은 대기 손님을 노쇼로 못 만든다(그런 경우는 cancel_waiting을 써야 할 것으로 보이나 그건 슬라이스04 관할). 행위 범위가 좁아진 계약 변경.

**4-3. 존재가 보장되지 않는 설정 컬럼을 런타임 introspection으로 방어.**
`apply_no_show_transition`은 `information_schema.columns`를 조회해 `store_settings.no_show_kds_grace_minutes` 컬럼이 **있는지 실행 시점에 확인**한 뒤에야 동적 `execute`로 값을 읽고, 없으면 15로 기본. 그런데 이 컬럼은 슬라이스05의 `store_settings` 스키마 덤프에 **없다**. 즉 이 코드는 "아직 추가되지 않았을 수 있는 컬럼"을 방어적으로 다룬다 — 스키마와 코드가 완전히 동기화되지 않았다는 신호(현재로선 항상 15분 fallback).

**4-4. 재설계 함수에 grant 하드닝 미적용(형제 마이그레이션과 불일치).**
0161은 새 함수 5개에 어떤 `revoke public`/`grant authenticated`도 넣지 않았다(4개 NULL, mark_no_show는 0115의 =X 상속). 형제 0160/0167이 `_record_waiting_call`을 owner-only로, `call_next_waiting_customer`를 authenticated로 명시 잠근 것과 대조적이다. 특히 `apply_no_show_transition`은 사실상 "공유 내부 코어"인데 owner-only로 잠기지 않아, 슬라이스02의 `_record_waiting_call`(owner-only)과 내부헬퍼 취급이 서로 다르다. 배치/복구 함수(cron·직원용)도 명시 권한 경계가 없다.

**4-5. 노쇼 ≠ 즉시 티켓 취소(사전주문 유예) — 설계상 의도로 보이나 부작용 주의.**
사전주문 손님이 노쇼여도 그 음식 티켓은 즉시 CANCELLED가 아니라 15분 유예 HOLD로 남는다. 유예 동안 `recover_no_show_grace_ticket`으로 지각 손님 복구 가능. 이는 의도된 "지각 회복" 기능이나, 노쇼된 세션의 티켓이 주방에 HOLD로 계속 보이는 상태가 되어(용량 계산·표시에 포함될 수 있음), 노쇼-유예-만료의 3단계 배치가 제때 안 돌면 유령 HOLD가 누적될 소지.

**4-6. 유예 부여가 `pre_order_created_at`에만 결속.**
`apply_no_show_transition`은 `pre_order_created_at is not null`일 때만 KDS 유예 블록을 실행한다. 사전주문 없이 노쇼면 어떤 HOLD 티켓도 건드리지 않는다(정상적으로 그런 세션엔 티켓이 없겠지만, 만약 다른 경로로 HOLD 티켓이 붙어 있으면 방치됨).

**4-7. 복구 시 원래 hold_reason 소실.**
`recover_no_show_grace_ticket`은 티켓을 `HOLD` + `hold_reason=null`로 복구한다. 그런데 최초 HOLD 티켓은 `confirm_order`(슬라이스05)에서 `hold_reason='AWAITING_CONDITIONS'`로 생성됐다. 유예가 이를 `NO_SHOW_GRACE`로 덮었고, 복구는 `null`로 만든다 — 복구된 티켓의 `hold_reason`이 "한 번도 유예 안 된 티켓"과 달라진다(AWAITING_CONDITIONS 정보 소실). 조건 판정 로직이 hold_reason에 의존하면 미묘한 차이를 낳을 수 있음.

**4-8. 배치의 조용한 실패(진단 로그 부재).**
`process_expired_no_shows`와 `expire_no_show_kds_hold`는 루프 내 `exception when others`로 개별 실패를 삼키고 failed_ids만 누적할 뿐, 실패 사유를 `log_diagnostic`이나 감사원장에 남기지 않는다. cron으로 무인 실행되는 함수인데 실패 원인 추적 수단이 반환 JSON의 id 목록뿐이라 관측성이 약하다.

**4-9. 라이브 작동 증거 없음.**
`kds_tickets` 0행. 노쇼/유예/만료/복구 어느 것도 실제 실행된 적 없다 — 전부 이론 설계.

## 5. Confidence Notes

- **4-1/4-2(오버로드 DROP·계약 축소)**: 0161 주석·DROP문으로 확정. 구 mark_no_show를 호출하던 상위 코드나 "WAITING 노쇼"를 쓰던 흐름이 실제 있었는지는 이 자료 밖.
- **4-4(proacl)**: NULL proacl이 PUBLIC-execute 기본을 뜻한다는 것은 PostgreSQL 일반 규칙에 근거한 해석이다. anon 실제 도달 여부는 스키마 USAGE(0022에서 authenticated에만 부여)에 달려 있어, 실무 노출은 authenticated 수준으로 보이나 "명시 하드닝 부재"는 사실로 확정. 데이터베이스 차원의 `ALTER DEFAULT PRIVILEGES` 적용 여부는 이 자료로 확인 불가.
- **4-3(설정 컬럼)**: `no_show_kds_grace_minutes`가 슬라이스05 store_settings 덤프에 없음은 확인. 이 패키지 밖 후속 마이그레이션이 추가했을 가능성은 배제 불가(그 경우 introspection 분기가 실효). 현 자료 기준 항상 15 fallback.
- **4-7(hold_reason 소실)**: 최초 hold_reason='AWAITING_CONDITIONS'는 슬라이스05 confirm_order 근거. 이 값에 의존하는 조건 판정 로직(bulk_commit_kds_tickets 등)은 슬라이스04(KDS) 관할이라 실제 영향은 거기서 확인 필요.
- **4-5(유령 HOLD)**: 용량 계산에 NO_SHOW_GRACE HOLD가 포함되는지는 KDS 용량 함수(슬라이스04) 소관 — 여기선 티켓이 HOLD로 남는다는 사실만 확정.
- RLS 정책 텍스트 없음(pg_policy 추출 실패). kds_tickets RLS 활성 여부만 알 수 있고 정책 내용 불명. 민감 컬럼 redacted.
