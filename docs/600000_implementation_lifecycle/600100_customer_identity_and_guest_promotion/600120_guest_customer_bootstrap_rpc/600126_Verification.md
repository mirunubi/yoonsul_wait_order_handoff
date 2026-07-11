# 600126_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Codex
Date: 2026-07-11

## Verification Result

Final result: PASS.

The `600123_TestPlan.md` scenarios were run against the local Docker database. The first `register_waiting()` retry used `p_source := 'LOCAL_VERIFICATION'` and failed because that value is not allowed by `chk_event_caused_by_type`. Diagnosis confirmed that this was a test-parameter error: `register_waiting()` writes `p_source` into `caused_by_type`, and the constraint allows `STAFF`.

The final retry used `p_source := 'STAFF'` and passed.

## Constraint Check

Command:

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname = 'chk_event_caused_by_type';"
```

Output:

```text
CHECK ((caused_by_type = ANY (ARRAY['SYSTEM'::text, 'AGENT'::text, 'STAFF'::text, 'MANAGER'::text, 'CUSTOMER'::text, 'PROVIDER'::text, 'SCHEDULER'::text, 'REPLAY'::text])))
```

## Final register_waiting() Execution

Command:

```sql
select catchmenu_pos.register_waiting(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_session_type := 'WAITING',
  p_guest_count := 2,
  p_guest_locale := 'ko',
  p_phone_hash := 'test_600123_final_' || extract(epoch from now())::text,
  p_customer_id := null,
  p_memo := null,
  p_source := 'STAFF',
  p_locale := 'ko',
  p_correlation_id := 'verify-600123-final'
);
```

Output:

```text
{"data": {"session_id": "d099c815-ebd8-4ef6-bbf7-c51f56711dcf", "guest_count": 2, "wait_number": 2, "guest_locale": "ko", "queue_position": 2, "est_time_message": "?덉긽 ?湲??쒓컙: ??10遺?, "est_wait_minutes": 10, "position_message": "?꾩옱 2踰덉㎏ ?湲?以묒엯?덈떎", "pre_order_enabled": false, "registered_message": "2踰덉쑝濡??湲??깅줉?섏뿀?듬땲??}, "meta": {"locale": "ko", "occurred_at": "2026-07-11T02:58:29.817134+00:00", "correlation_id": "verify-600123-final"}, "message": "2踰덉쑝濡??湲??깅줉?섏뿀?듬땲??, "success": true, "message_key": "waiting_registered"}
```

## bootstrap_customer_app_v2() Result

The prior `bootstrap_customer_app_v2()` run completed successfully after the total-column follow-up audit:

- `success = true`
- guest customer was auto-created
- returned customer payload contained `total_points: 0`
- no `get_customer_membership(...)` total-column blocker remained

## pg_get_functiondef() Reconfirmation

Raw verification output:

```text
catchmenu_common.customer_login(p_tenant_id uuid, p_store_id uuid, p_phone_hash text, p_code_hash text, p_device_fingerprint text, p_locale text, p_app_version text, p_os_type text, p_push_token text, p_login_ip text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=false
catchmenu_common.get_auth_context(p_tenant_id uuid, p_session_token_hash text, p_locale text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=false
catchmenu_pos.register_waiting(p_tenant_id uuid, p_store_id uuid, p_guest_count integer, p_session_type text, p_guest_locale text, p_phone_hash text, p_customer_id uuid, p_memo text, p_source text, p_locale text, p_correlation_id text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=false | uses_lifetime_spend=false
catchmenu_store.bootstrap_customer_app(p_tenant_id uuid, p_store_id uuid, p_phone_hash text, p_locale text, p_app_version text, p_os_type text, p_push_token text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=false
catchmenu_store.bootstrap_customer_app_v2(p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_phone_hash text, p_locale text, p_app_version text, p_push_token text, p_os_type text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=false
catchmenu_store.earn_points_after_order(p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_order_id uuid, p_order_amount integer, p_locale text, p_correlation_id text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=true
catchmenu_store.get_customer_home(p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_locale text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=false
catchmenu_store.get_customer_membership(p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_locale text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=true
catchmenu_store.get_membership_dashboard(p_tenant_id uuid, p_store_id uuid, p_locale text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=true
catchmenu_store.get_or_create_guest_customer(p_tenant_id uuid, p_phone_hash text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=false | uses_lifetime_spend=false
catchmenu_store.place_takeout_order(p_tenant_id uuid, p_store_id uuid, p_items jsonb, p_customer_id uuid, p_phone_hash text, p_locale text, p_request_memo text, p_coupon_issue_id uuid, p_use_points integer, p_requested_pickup_at timestamp with time zone, p_correlation_id text) | stale_total_points=false | stale_total_spent_amount=false | uses_point_balance=true | uses_lifetime_spend=false
```

## Scenario Summary

| Scenario | Result |
|---|---|
| New `phone_hash` guest helper creates row | PASS |
| Same `phone_hash` returns same customer | PASS |
| Promoted `is_guest=false` customer remains non-guest | PASS |
| Anonymous no-phone calls create distinct customers | PASS |
| `register_waiting()` without `p_customer_id` auto-fills guest customer when `p_source := 'STAFF'` | PASS |
| `bootstrap_customer_app_v2()` without `p_customer_id` auto-fills guest customer | PASS |
| `order_sessions.customer_id` FK remains `ON DELETE SET NULL` | PASS |
