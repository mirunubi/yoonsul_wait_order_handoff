# 600101_ChangeHistory.md

Per `000701` §30 — single running file, append-only. One row per change. Do not create a new file per event (605900 pattern explicitly forbidden).

§30: "Stage 6 must append one entry... upon ACCEPT of any change — this is part of closing the audit, not a separate task." 아래 첫 항목은 `order_sessions_customer_id_fk_and_guest_promotion`이 Stage 6에서 ACCEPT된 시점에 추가되었다.

| Date | Change Description | Reason/Evidence | Outcome | Linked Audit/Test |
|---|---|---|---|---|
| 2026-07-11 | `order_sessions.customer_id`/`phone_hash`, `customers.is_guest` 컬럼 추가 (0148, 커밋 `3978a14`) — 게스트 승격 in-place UPDATE 설계 지원 | `0012`에 없던 컬럼을 `0115`/`0116`/`0082`/`0083`이 이미 참조 중이었음, 로컬 out-of-band `NO ACTION` FK를 승인된 `SET NULL`로 재조정 | ACCEPT — `600117_Audit.md` §2. 컬럼/제약/인덱스 실제 존재 및 정합성 독립 재확인 완료. Open Items 3개(005015/익명게스트 dedupe/604500 중복)는 미해결로 이월 | `600115_Module.md`, `600116_Verification.md`, `600117_Audit.md` |
| 2026-07-11 | `600120_guest_customer_bootstrap_rpc` completed: 0149 guest-customer bootstrap helper/RPC patch, 0150 waiting event-domain widening, and Human-approved §24 stale-column fixes across 0081/0097/0108/0115/0116/0149. | 0148 created the customer/session schema bridge, but entry RPCs still needed automatic guest customer creation and first end-to-end execution exposed pre-existing stale column references (`max_waiting_count`, `min_order_amount`, `memo`, `pre_order_amount`, `thumbnail_url`, `locale`, `total_points`, `total_spent_amount`). Each §24 expansion was Human-approved before implementation. | ACCEPT — final local Docker verification passed for helper scenarios, `register_waiting()` with `p_source := 'STAFF'`, and `bootstrap_customer_app_v2()` without explicit `p_customer_id`. `pg_get_functiondef()` confirmed audited live functions no longer contain stale total-column references. | `600125_Module.md`, `600126_Verification.md`, `600127_Audit.md` |
