# 601718_Evidence_Stores_Write_Path_Scan_Cursor.md

> ⚠️ **`stores` write-path 실측 · 판정이 아니다**
>
> `601717` 3판이 남긴 blocker **C-1**(`stores.merchant_account_id` NOT NULL 승격 가부)의
> **직접 근거**다.
>
> NOT NULL 은 값을 공급하지 않는 INSERT 를 전부 깨뜨린다.
> `601701` §4.5 D-3 이 `stores` 참조 함수 개수만 기록했고
> **write path 의 형태는 측정되지 않았다.**
>
> **이 문서는 NOT NULL 승격 가부를 판정하지 않는다.** 사실만 제공한다.
>
> **같은 작업을 Codex 도 독립 수행했다 — `601719`**(`000701` §35).
> **두 조사가 상대 결과를 참조하지 않고 동일한 수치에 도달했다.**
>
> 수행: Cursor, 2026-08-22. 환경 `postgres:17.6.1.140`, migration `0169`.

**Performing agent:** Cursor  
**Basis:** `000701` §34.1 / §35 dual verification  
**Scope:** Investigation only. Facts only. No NOT NULL promotion judgment.

---

## Environment (live)

| Item | Value |
|---|---|
| Container ID | `fb5b03ea152e` |
| Postgres image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| PostgreSQL version | `PostgreSQL 17.6 on x86_64-pc-linux-gnu` |
| Query timestamp (KST) | `2026-08-22 19:57:35` |
| Latest `catchmenu_meta.migration_history` | `0169_authority_owner_role_and_sole_representative_uniqueness.sql` — applied `2026-08-09 17:26:43+00` |
| `catchmenu_hq.stores` row count | **1** |
| `catchmenu_hq.tenants` row count | **1** |
| Connection | `docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres` |

---

## S-1. Functions referencing `stores` (live)

### Query

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%stores%'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2;
```

### Result

| Total count | **158** |
| `601701` §4.5 D-3 recorded count | **151** |
| Difference (live − documented) | **+7** |

| # | Schema | Function | Args |
|---:|---|---|---|
| 1 | `catchmenu_agent` | `activate_manual_fallback` | `p_tenant_id uuid, p_store_id uuid, p_fallback_type text, p_fallback_reason text, p_bypassed_system text, p_activated_by_type text, p_activated_by_id uuid, p_triggered_by_exception_id uuid, p_triggered_by_device_id uuid, p_sop_applied_id uuid, p_affected_order_ids jsonb, p_affected_session_ids jsonb, p_affected_kds_ticket_ids jsonb, p_correlation_id text` |
| 2 | `catchmenu_agent` | `create_agent_action` | `p_tenant_id uuid, p_store_id uuid, p_agent_id uuid, p_action_type text, p_action_domain text, p_recommendation_type text, p_recommendation_summary text, p_observation_summary text, p_observation_payload jsonb, p_recommendation_payload jsonb, p_confidence_score integer, p_confidence_basis text, p_subject_type text, p_subject_id uuid, p_exception_id uuid, p_task_id uuid, p_session_id uuid, p_order_id uuid, p_kds_ticket_id uuid, p_recommended_sop_id uuid, p_requires_approval boolean, p_correlation_id text` |
| 3 | `catchmenu_agent` | `request_approval` | `p_tenant_id uuid, p_store_id uuid, p_action_id uuid, p_approval_type text, p_action_summary text, p_notified_to_type text, p_notified_to_id uuid, p_urgency_level text, p_risk_summary text, p_recommended_decision text, p_notification_channel text, p_auto_escalate_after_minutes integer, p_sop_reference_id uuid, p_correlation_id text` |
| 4 | `catchmenu_audit` | `run_isolation_audit` | `p_tenant_id uuid, p_store_id uuid, p_scanned_by_type text, p_scanned_by_id uuid` |
| 5 | `catchmenu_audit` | `scan_cross_tenant_risk` | `p_tenant_id uuid` |
| 6 | `catchmenu_common` | `activate_subscription` | `p_tenant_id uuid, p_plan_code text, p_payment_method text, p_payment_reference text, p_white_label_partner_code text, p_actor_id uuid, p_correlation_id text` |
| 7 | `catchmenu_common` | `bootstrap_app` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_device_type text, p_app_version text, p_locale text, p_os_type text, p_ip_address text, p_correlation_id text` |
| 8 | `catchmenu_common` | `bootstrap_kds_app` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_kitchen_zone text, p_app_version text, p_locale text, p_correlation_id text` |
| 9 | `catchmenu_common` | `bootstrap_staff_app` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_device_id uuid, p_device_type text, p_locale text, p_correlation_id text` |
| 10 | `catchmenu_common` | `check_saas_readiness` | `p_tenant_id uuid` |
| 11 | `catchmenu_common` | `get_auth_context` | `p_tenant_id uuid, p_session_token_hash text, p_locale text` |
| 12 | `catchmenu_common` | `get_daily_report` | `p_tenant_id uuid, p_store_id uuid, p_business_day date, p_locale text` |
| 13 | `catchmenu_common` | `get_realtime_config` | `p_tenant_id uuid, p_store_id uuid, p_device_type text` |
| 14 | `catchmenu_common` | `get_saas_dashboard` | `p_tenant_id uuid, p_period_months integer` |
| 15 | `catchmenu_common` | `get_store_bootstrap` | `p_tenant_id uuid, p_store_id uuid` |
| 16 | `catchmenu_common` | `get_tenant_health` | `p_tenant_id uuid, p_locale text` |
| 17 | `catchmenu_common` | `get_tenant_list` | `p_tenant_status text, p_plan_tier text, p_search_keyword text, p_limit integer, p_offset integer, p_locale text` |
| 18 | `catchmenu_common` | `get_tenant_plan` | `p_tenant_id uuid` |
| 19 | `catchmenu_common` | `heartbeat` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_app_version text, p_locale text` |
| 20 | `catchmenu_common` | `onboard_tenant` | `p_company_name text, p_business_number text, p_ceo_name text, p_ceo_phone_hash text, p_plan_tier text, p_store_name text, p_store_timezone text, p_brand_name text, p_actor_id uuid, p_locale text` |
| 21 | `catchmenu_common` | `provision_tenant` | `p_tenant_code text, p_tenant_name text, p_owner_name text, p_owner_email text, p_owner_phone text, p_plan_code text, p_store_name text, p_store_timezone text, p_sales_channel text, p_white_label_partner_code text, p_correlation_id text` |
| 22 | `catchmenu_common` | `run_daily_close_batch` | `p_tenant_id uuid, p_store_id uuid, p_force boolean` |
| 23 | `catchmenu_common` | `run_integration_test` | `p_tenant_id uuid, p_store_id uuid, p_scenario text` |
| 24 | `catchmenu_common` | `run_opening_checklist` | `p_tenant_id uuid, p_store_id uuid, p_locale text` |
| 25 | `catchmenu_common` | `run_security_audit` | `p_tenant_id uuid, p_store_id uuid, p_audit_depth text, p_locale text` |
| 26 | `catchmenu_common` | `seed_tenant_quotas` | `p_tenant_id uuid, p_plan_tier text` |
| 27 | `catchmenu_hq` | `apply_policy_to_stores` | `p_tenant_id uuid, p_policy_id uuid, p_locale text, p_correlation_id text` |
| 28 | `catchmenu_hq` | `broadcast_brand_cms` | `p_tenant_id uuid, p_brand_id uuid, p_event_type text, p_title_ko text, p_body_ko text, p_title_en text, p_thumbnail_url text, p_valid_from timestamp with time zone, p_valid_until timestamp with time zone, p_linked_coupon_id uuid, p_target_store_ids jsonb, p_actor_id uuid, p_locale text` |
| 29 | `catchmenu_hq` | `broadcast_hq_notice` | `p_tenant_id uuid, p_notice_type text, p_title text, p_body text, p_priority text, p_target_store_ids jsonb, p_valid_until timestamp with time zone, p_read_required boolean, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 30 | `catchmenu_hq` | `bulk_policy_distribution` | `p_tenant_id uuid, p_brand_id uuid, p_policy_type text, p_force_reapply boolean, p_locale text, p_actor_id uuid, p_correlation_id text` |
| 31 | `catchmenu_hq` | `compare_store_performance` | `p_tenant_id uuid, p_group_id uuid, p_period_start date, p_period_end date, p_metric text` |
| 32 | `catchmenu_hq` | `compare_store_revenue` | `p_tenant_id uuid, p_brand_id uuid, p_from_date date, p_to_date date, p_compare_period text, p_locale text` |
| 33 | `catchmenu_hq` | `create_franchise_store` | `p_tenant_id uuid, p_store_code text, p_store_name text, p_store_type text, p_address text, p_phone text, p_timezone text, p_opened_on date, p_franchisee_name text, p_franchisee_phone text, p_business_hours jsonb, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 34 | `catchmenu_hq` | `detect_policy_violations` | `p_tenant_id uuid, p_brand_id uuid, p_store_id uuid, p_policy_type text, p_locale text` |
| 35 | `catchmenu_hq` | `distribute_menu_template` | `p_tenant_id uuid, p_brand_id uuid, p_template_id uuid, p_target_store_ids jsonb, p_override_existing boolean, p_actor_id uuid, p_locale text` |
| 36 | `catchmenu_hq` | `distribute_menu_to_stores` | `p_tenant_id uuid, p_template_id uuid, p_target_store_ids jsonb, p_distribution_type text, p_locale text, p_actor_id uuid, p_correlation_id text` |
| 37 | `catchmenu_hq` | `get_brand_store_overview` | `p_tenant_id uuid, p_brand_id uuid, p_locale text` |
| 38 | `catchmenu_hq` | `get_franchise_admin_dashboard` | `p_tenant_id uuid, p_brand_id uuid, p_locale text` |
| 39 | `catchmenu_hq` | `get_franchise_compliance_report` | `p_tenant_id uuid, p_brand_id uuid, p_from_date date, p_to_date date, p_locale text` |
| 40 | `catchmenu_hq` | `get_franchise_dashboard` | `p_tenant_id uuid, p_target_date date` |
| 41 | `catchmenu_hq` | `get_franchise_dashboard` | `p_tenant_id uuid, p_brand_id uuid, p_business_day date, p_locale text` |
| 42 | `catchmenu_hq` | `get_franchise_os_dashboard` | `p_tenant_id uuid, p_brand_id uuid, p_locale text` |
| 43 | `catchmenu_hq` | `get_franchise_settlement_report` | `p_tenant_id uuid, p_brand_id uuid, p_from_date date, p_to_date date, p_locale text` |
| 44 | `catchmenu_hq` | `get_menu_compliance_report` | `p_tenant_id uuid, p_brand_id uuid, p_template_id uuid` |
| 45 | `catchmenu_hq` | `get_policy_compliance_summary` | `p_tenant_id uuid, p_brand_id uuid, p_period_start date, p_period_end date, p_locale text` |
| 46 | `catchmenu_hq` | `get_store_group_dashboard` | `p_tenant_id uuid, p_group_id uuid, p_business_day date` |
| 47 | `catchmenu_hq` | `process_hq_approval` | `p_tenant_id uuid, p_request_id uuid, p_decision text, p_decision_reason text, p_decision_data jsonb, p_locale text, p_approved_by uuid, p_correlation_id text` |
| 48 | `catchmenu_hq` | `rollback_policy` | `p_tenant_id uuid, p_policy_id uuid, p_rollback_reason text, p_locale text, p_actor_id uuid, p_correlation_id text` |
| 49 | `catchmenu_hq` | `run_compliance_check` | `p_tenant_id uuid, p_brand_id uuid, p_store_id uuid, p_locale text` |
| 50 | `catchmenu_hq` | `send_hq_notice` | `p_tenant_id uuid, p_brand_id uuid, p_notice_type text, p_notice_title text, p_notice_body text, p_notice_severity text, p_target_store_ids jsonb, p_requires_confirmation boolean, p_actor_id uuid, p_locale text` |
| 51 | `catchmenu_hq` | `sync_hq_menu_template` | `p_tenant_id uuid, p_template_id uuid, p_target_store_ids jsonb, p_sync_mode text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 52 | `catchmenu_integrations` | `accept_delivery_order` | `p_tenant_id uuid, p_store_id uuid, p_intake_id uuid, p_estimated_minutes integer, p_actor_id uuid, p_locale text, p_correlation_id text` |
| 53 | `catchmenu_integrations` | `auto_reject_overloaded` | `p_tenant_id uuid, p_store_id uuid, p_platform_code text, p_platform_order_id text, p_raw_payload jsonb, p_correlation_id text` |
| 54 | `catchmenu_integrations` | `cancel_cash_receipt` | `p_tenant_id uuid, p_store_id uuid, p_receipt_id uuid, p_cancel_reason text, p_actor_id uuid, p_locale text, p_correlation_id text` |
| 55 | `catchmenu_integrations` | `confirm_cash_receipt` | `p_tenant_id uuid, p_store_id uuid, p_receipt_id uuid, p_nts_approval_number text, p_issue_result text, p_nts_response jsonb, p_error_detail text, p_locale text, p_correlation_id text` |
| 56 | `catchmenu_integrations` | `initiate_toss_payment_legacy_604260` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_payment_method text, p_customer_id_hash text, p_locale text, p_correlation_id text` |
| 57 | `catchmenu_integrations` | `intake_delivery_order` | `p_tenant_id uuid, p_store_id uuid, p_provider_type text, p_provider_order_id text, p_provider_raw_payload jsonb, p_gateway_session_id uuid, p_correlation_id text` |
| 58 | `catchmenu_integrations` | `issue_cash_receipt` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_receipt_type text, p_identifier_type text, p_identifier_hash text, p_issue_amount integer, p_is_anonymous boolean, p_locale text, p_correlation_id text` |
| 59 | `catchmenu_integrations` | `poll_pending_delivery_orders` | `p_tenant_id uuid, p_store_id uuid, p_platform_code text, p_max_age_minutes integer` |
| 60 | `catchmenu_integrations` | `process_okpos_order` | `p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_correlation_id text` |
| 61 | `catchmenu_integrations` | `process_toss_pos_order` | `p_tenant_id uuid, p_store_id uuid, p_raw_payload jsonb, p_correlation_id text` |
| 62 | `catchmenu_integrations` | `process_toss_webhook` | `p_tenant_id uuid, p_store_id uuid, p_raw_headers jsonb, p_raw_body jsonb, p_signature_header text, p_webhook_secret text, p_correlation_id text` |
| 63 | `catchmenu_integrations` | `process_van_approval` | `p_tenant_id uuid, p_store_id uuid, p_van_provider text, p_van_terminal_id text, p_van_merchant_id text, p_intent_id uuid, p_ledger_id uuid, p_order_id uuid, p_requested_amount integer, p_card_type text, p_installment_months integer, p_raw_request jsonb, p_raw_response jsonb, p_van_approval_number text, p_van_trace_number text, p_response_code text, p_correlation_id text` |
| 64 | `catchmenu_integrations` | `process_van_cancel` | `p_tenant_id uuid, p_store_id uuid, p_van_tx_id uuid, p_cancel_amount integer, p_cancel_reason text, p_raw_request jsonb, p_raw_response jsonb, p_van_cancel_number text, p_response_code text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 65 | `catchmenu_integrations` | `receive_delivery_order` | `p_tenant_id uuid, p_store_id uuid, p_platform_code text, p_platform_order_id text, p_raw_payload jsonb, p_locale text, p_correlation_id text` |
| 66 | `catchmenu_integrations` | `register_pos_provider` | `p_tenant_id uuid, p_store_id uuid, p_provider_code text, p_merchant_id text, p_terminal_id text, p_store_code_at_pos text, p_order_push_enabled boolean, p_payment_confirm_enabled boolean, p_menu_sync_enabled boolean, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 67 | `catchmenu_integrations` | `reject_delivery_order` | `p_tenant_id uuid, p_store_id uuid, p_provider_type text, p_provider_order_id text, p_reject_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 68 | `catchmenu_integrations` | `sync_delivery_order_status` | `p_tenant_id uuid, p_store_id uuid, p_platform_code text, p_platform_order_id text, p_platform_status text, p_raw_payload jsonb, p_correlation_id text` |
| 69 | `catchmenu_integrations` | `sync_pos_menu_item` | `p_tenant_id uuid, p_store_id uuid, p_provider_code text, p_pos_item_code text, p_menu_name text, p_price integer, p_category_code text, p_category_name text, p_is_available boolean, p_is_sold_out boolean, p_options jsonb, p_correlation_id text` |
| 70 | `catchmenu_integrations` | `sync_van_settlement` | `p_tenant_id uuid, p_store_id uuid, p_van_provider text, p_van_terminal_id text, p_van_merchant_id text, p_settlement_date date, p_settlement_data jsonb, p_correlation_id text` |
| 71 | `catchmenu_integrations` | `update_delivery_status` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_new_delivery_status text, p_actor_type text, p_actor_id uuid, p_delivery_note text, p_locale text, p_correlation_id text` |
| 72 | `catchmenu_kds` | `get_kds_performance` | `p_tenant_id uuid, p_store_id uuid, p_business_day date, p_kitchen_zone text` |
| 73 | `catchmenu_kds` | `get_kds_realtime_state` | `p_tenant_id uuid, p_store_id uuid, p_locale text` |
| 74 | `catchmenu_knowledge` | `build_operational_context` | `p_tenant_id uuid, p_store_id uuid, p_context_depth text, p_include_kds boolean, p_include_payment boolean, p_include_inventory boolean, p_correlation_id text` |
| 75 | `catchmenu_knowledge` | `build_sop_recommendation_context` | `p_tenant_id uuid, p_store_id uuid, p_recommendation_domain text, p_trigger_event_type text, p_correlation_id text` |
| 76 | `catchmenu_knowledge` | `detect_knowledge_gap` | `p_tenant_id uuid, p_store_id uuid, p_gap_type text, p_domain text, p_gap_summary text, p_triggering_exception_type text, p_triggering_exception_ids jsonb, p_gap_context jsonb, p_existing_document_id uuid, p_existing_document_inadequacy text, p_detection_threshold integer, p_correlation_id text` |
| 77 | `catchmenu_knowledge` | `record_ai_resolution_outcome` | `p_tenant_id uuid, p_store_id uuid, p_exception_id uuid, p_context_id uuid, p_sop_document_id uuid, p_resolution_outcome text, p_resolution_time_minutes integer, p_staff_feedback text, p_ai_recommendation_used boolean, p_correlation_id text` |
| 78 | `catchmenu_ledger` | `create_exception` | `p_tenant_id uuid, p_store_id uuid, p_exception_domain text, p_exception_type text, p_exception_severity text, p_subject_type text, p_subject_id uuid, p_error_message text, p_error_code text, p_exception_payload jsonb, p_triggered_by_event_id uuid, p_triggered_by_task_id uuid, p_triggered_by_device_id uuid, p_triggered_by_agent_id uuid, p_recommended_sop_id uuid, p_requires_human_approval boolean, p_correlation_id text` |
| 79 | `catchmenu_ledger` | `reconcile_ledger_gaps` | `p_tenant_id uuid, p_store_id uuid, p_business_day date` |
| 80 | `catchmenu_ledger` | `replay_local_ledger` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_max_entries integer, p_correlation_id text` |
| 81 | `catchmenu_ledger` | `resolve_replay_conflict` | `p_tenant_id uuid, p_store_id uuid, p_entry_id uuid, p_resolution text, p_resolved_by_type text, p_resolved_by_id uuid, p_resolution_note text, p_correlation_id text` |
| 82 | `catchmenu_ledger` | `run_state_projection_check` | `p_tenant_id uuid, p_store_id uuid, p_business_day date` |
| 83 | `catchmenu_ledger` | `verify_audit_chain` | `p_tenant_id uuid, p_store_id uuid, p_business_day date` |
| 84 | `catchmenu_ledger` | `verify_event_ledger_integrity` | `p_tenant_id uuid, p_store_id uuid, p_business_day date, p_event_domain text` |
| 85 | `catchmenu_payment` | `confirm_payment` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_provider_type text, p_provider_approval_number text, p_provider_tx_id text, p_approved_amount integer, p_payment_method text, p_provider_response jsonb, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text, p_intent_id uuid` |
| 86 | `catchmenu_payment` | `confirm_refund` | `p_tenant_id uuid, p_store_id uuid, p_refund_ledger_id uuid, p_provider_cancel_tx_id text, p_cancel_result text, p_provider_response jsonb, p_locale text, p_correlation_id text` |
| 87 | `catchmenu_payment` | `create_payment_intent` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_session_id uuid, p_payment_method text, p_payment_channel text, p_provider_type text, p_requested_amount integer, p_idempotency_key text, p_correlation_id text` |
| 88 | `catchmenu_payment` | `create_reconciliation_case` | `p_tenant_id uuid, p_store_id uuid, p_case_type text, p_reconciliation_layer text, p_severity text, p_order_id uuid, p_ledger_id uuid, p_intent_id uuid, p_internal_amount integer, p_provider_amount integer, p_internal_status text, p_provider_status text, p_provider_type text, p_provider_payment_key text, p_provider_approval_number text, p_provider_raw_event_id uuid, p_detection_method text, p_correlation_id text` |
| 89 | `catchmenu_payment` | `get_payment_summary` | `p_tenant_id uuid, p_store_id uuid, p_business_day date` |
| 90 | `catchmenu_payment` | `request_refund` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_refund_amount integer, p_refund_reason text, p_is_partial boolean, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text` |
| 91 | `catchmenu_payment` | `resolve_or_create_payment_intent` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_requested_amount integer, p_payment_method text, p_payment_channel text, p_provider_type text, p_intent_origin text, p_origin_reference jsonb, p_intent_id uuid, p_session_id uuid, p_locale text` |
| 92 | `catchmenu_payment` | `run_layer2_reconciliation` | `p_tenant_id uuid, p_store_id uuid, p_recon_date date, p_pos_provider_code text, p_correlation_id text` |
| 93 | `catchmenu_payment` | `run_layer3_reconciliation` | `p_tenant_id uuid, p_store_id uuid, p_recon_date date, p_provider_type text, p_correlation_id text` |
| 94 | `catchmenu_pos` | `create_kiosk_session` | `p_tenant_id uuid, p_store_id uuid, p_kiosk_device_id uuid, p_order_type text, p_guest_count integer, p_guest_locale text, p_correlation_id text` |
| 95 | `catchmenu_pos` | `create_order` | `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_order_type text, p_order_channel text, p_items jsonb, p_memo text, p_special_requests text, p_correlation_id text` |
| 96 | `catchmenu_pos` | `create_order_session` | `p_tenant_id uuid, p_store_id uuid, p_session_type text, p_guest_count integer, p_guest_locale text, p_wait_number integer, p_table_id uuid, p_expires_minutes integer, p_correlation_id text` |
| 97 | `catchmenu_pos` | `create_order_session` | `p_tenant_id uuid, p_store_id uuid, p_session_type text, p_guest_count integer, p_guest_locale text, p_wait_number integer, p_queue_position integer, p_pre_order_expires_at timestamp with time zone, p_correlation_id text` |
| 98 | `catchmenu_pos` | `create_pre_order` | `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_items jsonb, p_memo text, p_correlation_id text` |
| 99 | `catchmenu_pos` | `estimate_wait_time` | `p_tenant_id uuid, p_store_id uuid, p_guest_count integer` |
| 100 | `catchmenu_pos` | `get_daily_summary` | `p_tenant_id uuid, p_store_id uuid, p_business_day date` |
| 101 | `catchmenu_pos` | `get_kiosk_state` | `p_tenant_id uuid, p_store_id uuid, p_kiosk_device_id uuid` |
| 102 | `catchmenu_pos` | `get_menu_catalog` | `p_tenant_id uuid, p_store_id uuid, p_locale text, p_include_hidden boolean, p_include_sold_out boolean` |
| 103 | `catchmenu_pos` | `get_menu_catalog_i18n` | `p_tenant_id uuid, p_store_id uuid, p_locale text, p_include_hidden boolean, p_include_sold_out boolean, p_include_allergens boolean, p_customer_allergen_profile jsonb` |
| 104 | `catchmenu_pos` | `get_menu_performance` | `p_tenant_id uuid, p_store_id uuid, p_from_date date, p_to_date date, p_category_id uuid, p_limit integer` |
| 105 | `catchmenu_pos` | `get_sales_report` | `p_tenant_id uuid, p_store_id uuid, p_from_date date, p_to_date date, p_group_by text` |
| 106 | `catchmenu_pos` | `get_waiting_queue` | `p_tenant_id uuid, p_store_id uuid, p_include_arrived boolean` |
| 107 | `catchmenu_pos` | `get_waiting_realtime_state` | `p_tenant_id uuid, p_store_id uuid, p_locale text` |
| 108 | `catchmenu_pos` | `pre_order_while_waiting` | `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_cart_items jsonb, p_locale text, p_correlation_id text` |
| 109 | `catchmenu_pos` | `record_allergen_display_evidence` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_menu_ids jsonb, p_display_locale text, p_displayed_allergens jsonb, p_customer_confirmed boolean, p_display_channel text, p_correlation_id text` |
| 110 | `catchmenu_pos` | `register_waiting` | `p_tenant_id uuid, p_store_id uuid, p_guest_count integer, p_session_type text, p_guest_locale text, p_phone_hash text, p_customer_id uuid, p_memo text, p_source text, p_locale text, p_correlation_id text` |
| 111 | `catchmenu_pos` | `update_menu_status` | `p_tenant_id uuid, p_store_id uuid, p_menu_id uuid, p_new_status text, p_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 112 | `catchmenu_pos` | `update_queue_position` | `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_new_position integer, p_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 113 | `catchmenu_store` | `approve_stock_transfer` | `p_tenant_id uuid, p_transfer_id uuid, p_approved_by uuid, p_approved_by_type text, p_item_adjustments jsonb, p_rejected_reason text, p_approve boolean, p_correlation_id text` |
| 114 | `catchmenu_store` | `bootstrap_customer_app` | `p_tenant_id uuid, p_store_id uuid, p_phone_hash text, p_locale text, p_app_version text, p_os_type text, p_push_token text` |
| 115 | `catchmenu_store` | `bootstrap_customer_app_v2` | `p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_phone_hash text, p_locale text, p_app_version text, p_push_token text, p_os_type text` |
| 116 | `catchmenu_store` | `bootstrap_did_app` | `p_tenant_id uuid, p_store_id uuid, p_did_code text, p_locale text` |
| 117 | `catchmenu_store` | `bootstrap_kiosk` | `p_tenant_id uuid, p_store_id uuid, p_kiosk_code text, p_device_id uuid, p_locale text` |
| 118 | `catchmenu_store` | `calculate_work_hours` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_period_start date, p_period_end date, p_pay_period_type text, p_actor_id uuid, p_correlation_id text` |
| 119 | `catchmenu_store` | `call_customer_pickup` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_queue_type text, p_target_zone text, p_locale text, p_correlation_id text` |
| 120 | `catchmenu_store` | `change_store_mode` | `p_tenant_id uuid, p_store_id uuid, p_new_mode text, p_changed_by uuid, p_reason text, p_locale text, p_correlation_id text` |
| 121 | `catchmenu_store` | `close_shift` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_break_minutes integer, p_shift_note text, p_locale text, p_correlation_id text` |
| 122 | `catchmenu_store` | `close_store` | `p_tenant_id uuid, p_store_id uuid, p_closed_by uuid, p_closing_memo text, p_force boolean, p_locale text, p_correlation_id text` |
| 123 | `catchmenu_store` | `create_staff_schedule` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_week_start date, p_schedule_grid jsonb, p_actor_type text, p_actor_id uuid, p_schedule_note text, p_correlation_id text` |
| 124 | `catchmenu_store` | `deduct_points` | `p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_order_id uuid, p_points_to_deduct integer, p_order_amount integer, p_correlation_id text` |
| 125 | `catchmenu_store` | `earn_points` | `p_tenant_id uuid, p_store_id uuid, p_customer_id uuid, p_order_id uuid, p_order_amount integer, p_is_bonus boolean, p_bonus_points integer, p_correlation_id text` |
| 126 | `catchmenu_store` | `get_did_waiting_display` | `p_tenant_id uuid, p_store_id uuid, p_did_code text, p_locale text` |
| 127 | `catchmenu_store` | `get_food_cost_report` | `p_tenant_id uuid, p_store_id uuid, p_from_date date, p_to_date date` |
| 128 | `catchmenu_store` | `get_multistore_inventory` | `p_tenant_id uuid, p_group_id uuid, p_low_stock_only boolean` |
| 129 | `catchmenu_store` | `get_staff_schedule` | `p_tenant_id uuid, p_store_id uuid, p_target_date date` |
| 130 | `catchmenu_store` | `get_store_admin_dashboard` | `p_tenant_id uuid, p_store_id uuid, p_locale text` |
| 131 | `catchmenu_store` | `get_store_cms_bundle` | `p_tenant_id uuid, p_store_id uuid, p_channel text, p_locale text` |
| 132 | `catchmenu_store` | `get_store_dashboard` | `p_tenant_id uuid, p_store_id uuid, p_locale text` |
| 133 | `catchmenu_store` | `get_store_devices` | `p_tenant_id uuid, p_store_id uuid, p_device_type text, p_include_inactive boolean` |
| 134 | `catchmenu_store` | `get_store_settings` | `p_tenant_id uuid, p_store_id uuid` |
| 135 | `catchmenu_store` | `get_table_floor_map` | `p_tenant_id uuid, p_store_id uuid, p_floor_zone text` |
| 136 | `catchmenu_store` | `notify_customer_ready` | `p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_notification_type text, p_display_message text, p_sound_alert boolean, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 137 | `catchmenu_store` | `open_shift` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_shift_date date, p_locale text, p_correlation_id text` |
| 138 | `catchmenu_store` | `open_store` | `p_tenant_id uuid, p_store_id uuid, p_opened_by uuid, p_opening_memo text, p_locale text, p_correlation_id text` |
| 139 | `catchmenu_store` | `place_kiosk_order` | `p_tenant_id uuid, p_store_id uuid, p_kiosk_id uuid, p_kiosk_session_id uuid, p_cart_items jsonb, p_order_type text, p_table_number text, p_locale text, p_correlation_id text` |
| 140 | `catchmenu_store` | `place_takeout_order` | `p_tenant_id uuid, p_store_id uuid, p_items jsonb, p_customer_id uuid, p_phone_hash text, p_locale text, p_memo text, p_coupon_issue_id uuid, p_use_points integer, p_requested_pickup_at timestamp with time zone, p_correlation_id text` |
| 141 | `catchmenu_store` | `record_inventory_movement` | `p_tenant_id uuid, p_store_id uuid, p_ingredient_id uuid, p_movement_type text, p_quantity_change numeric, p_unit_cost numeric, p_reference_type text, p_reference_id uuid, p_order_id uuid, p_movement_note text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 142 | `catchmenu_store` | `record_staff_attendance` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_action text, p_attendance_date date, p_scheduled_start_at timestamp with time zone, p_scheduled_end_at timestamp with time zone, p_note text, p_correlation_id text` |
| 143 | `catchmenu_store` | `redeem_coupon` | `p_tenant_id uuid, p_store_id uuid, p_issue_code text, p_customer_id uuid, p_order_id uuid, p_order_amount integer, p_correlation_id text` |
| 144 | `catchmenu_store` | `register_customer` | `p_tenant_id uuid, p_store_id uuid, p_phone_hash text, p_phone_masked text, p_display_name text, p_preferred_locale text, p_acquisition_channel text, p_allergen_profile jsonb, p_correlation_id text` |
| 145 | `catchmenu_store` | `register_device` | `p_tenant_id uuid, p_store_id uuid, p_device_code text, p_device_name text, p_device_type text, p_device_role text, p_os_type text, p_os_version text, p_app_version text, p_ip_address text, p_mac_address text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 146 | `catchmenu_store` | `register_ingredient` | `p_tenant_id uuid, p_store_id uuid, p_ingredient_code text, p_ingredient_name text, p_unit text, p_storage_type text, p_ingredient_category text, p_min_quantity numeric, p_warning_quantity numeric, p_reorder_quantity numeric, p_unit_cost numeric, p_supplier_name text, p_linked_menu_ids jsonb, p_initial_quantity numeric, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 147 | `catchmenu_store` | `register_staff` | `p_tenant_id uuid, p_store_id uuid, p_staff_code text, p_display_name text, p_staff_role text, p_employment_type text, p_phone text, p_email text, p_legal_name text, p_hired_on date, p_hourly_wage numeric, p_scheduled_hours_per_week numeric, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 148 | `catchmenu_store` | `register_table_qr` | `p_tenant_id uuid, p_store_id uuid, p_table_id uuid, p_qr_code text, p_nfc_tag_id text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 149 | `catchmenu_store` | `release_table` | `p_tenant_id uuid, p_store_id uuid, p_table_id uuid, p_release_reason text, p_set_cleaning boolean, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 150 | `catchmenu_store` | `request_stock_transfer` | `p_tenant_id uuid, p_from_store_id uuid, p_to_store_id uuid, p_transfer_reason text, p_items jsonb, p_priority text, p_transfer_note text, p_requested_by uuid, p_correlation_id text` |
| 151 | `catchmenu_store` | `toggle_store_mode` | `p_tenant_id uuid, p_store_id uuid, p_new_mode text, p_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 152 | `catchmenu_store` | `trust_device` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_new_trust_level text, p_trust_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 153 | `catchmenu_store` | `update_business_hours` | `p_tenant_id uuid, p_store_id uuid, p_business_hours jsonb, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 154 | `catchmenu_store` | `update_device_status` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_new_status text, p_reason text, p_app_version text, p_ip_address text, p_correlation_id text` |
| 155 | `catchmenu_store` | `update_did_display` | `p_tenant_id uuid, p_store_id uuid, p_device_id uuid, p_display_mode text, p_display_content jsonb, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 156 | `catchmenu_store` | `update_kds_capacity_threshold` | `p_tenant_id uuid, p_store_id uuid, p_threshold_per_zone integer, p_threshold_total integer, p_peak_time_threshold integer, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 157 | `catchmenu_store` | `update_staff_role` | `p_tenant_id uuid, p_store_id uuid, p_staff_id uuid, p_new_role text, p_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |
| 158 | `catchmenu_store` | `update_table_status` | `p_tenant_id uuid, p_store_id uuid, p_table_id uuid, p_new_status text, p_reason text, p_actor_type text, p_actor_id uuid, p_correlation_id text` |

---

## S-2. Functions that INSERT into `catchmenu_hq.stores` (live)

### Detection query

```sql
SELECT n.nspname, p.proname
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%insert into catchmenu_hq.stores%'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2;
```

### Result: **2건**

| # | Schema | Function | INSERT form | Column list explicit? |
|---:|---|---|---|---|
| 1 | `catchmenu_common` | `provision_tenant` | `COLUMN_LIST` | **Yes** — `(tenant_id, store_code, store_name, store_type, store_status, timezone)` |
| 2 | `catchmenu_hq` | `create_franchise_store` | `COLUMN_LIST` | **Yes** — `(tenant_id, store_code, store_name, store_type, store_status, address, phone, timezone, business_hours, opened_on, is_active, extra_metadata)` |

### `NO_COLUMN_LIST` / `ROW_TYPE`

| Category | Count |
|---|---:|
| `NO_COLUMN_LIST` | **0건** |
| `ROW_TYPE` | **0건** |
| `UNKNOWN` | **0건** |

### INSERT statement text (live `prosrc` extract)

#### 1. `catchmenu_common.provision_tenant`

```sql
insert into catchmenu_hq.stores (
    tenant_id,
    store_code, store_name,
    store_type, store_status,
    timezone
  ) values (
    v_tenant_id,
    p_tenant_code || '_S01',
    p_store_name,
    'RESTAURANT', 'ACTIVE',
    p_store_timezone
  )
  returning id into v_store_id
```

#### 2. `catchmenu_hq.create_franchise_store`

```sql
insert into catchmenu_hq.stores (
    tenant_id,
    store_code, store_name, store_type,
    store_status, address, phone, timezone,
    business_hours, opened_on, is_active,
    extra_metadata
  ) values (
    p_tenant_id,
    p_store_code, p_store_name, p_store_type,
    'ACTIVE', p_address, p_phone,
    coalesce(p_timezone, 'Asia/Seoul'),
    p_business_hours,
    coalesce(p_opened_on, current_date),
    true,
    jsonb_build_object(
      'franchisee_name', p_franchisee_name,
      'franchisee_phone', p_franchisee_phone
    )
  )
  returning id into v_store_id
```

**Note:** `catchmenu_common.onboard_tenant` does not INSERT into `stores`; it calls `provision_tenant`.

---

## S-3. Functions reading `catchmenu_hq.stores` via `SELECT *` or row type (live)

### Queries

```sql
SELECT n.nspname, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ~* 'select[[:space:]]+\*[[:space:]]+from[[:space:]]+catchmenu_hq\.stores\b'
  AND n.nspname NOT IN ('pg_catalog','information_schema') ORDER BY 1,2;

SELECT n.nspname, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ~* 'select[[:space:]]+\*[[:space:]]+into[[:space:]]+[[:alpha:]_][[:alnum:]_]*[[:space:]]+from[[:space:]]+catchmenu_hq\.stores\b'
  AND n.nspname NOT IN ('pg_catalog','information_schema') ORDER BY 1,2;

SELECT n.nspname, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ~* 'catchmenu_hq\.stores[[:space:]]*%rowtype'
  AND n.nspname NOT IN ('pg_catalog','information_schema') ORDER BY 1,2;

SELECT n.nspname, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ~* 'return[[:space:]]+setof[[:space:]]+catchmenu_hq\.stores\b'
  AND n.nspname NOT IN ('pg_catalog','information_schema') ORDER BY 1,2;
```

### Result: **0건**

| # | Schema | Function | Form | Statement |
|---:|---|---|---|---|
| — | — | — | **0건** | All four patterns returned 0 rows |

---

## S-4. Functions that UPDATE `catchmenu_hq.stores` (live)

### Query

```sql
SELECT n.nspname, p.proname
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ~* 'update[[:space:]]+catchmenu_hq\.stores[[:space:]]+set'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2;
```

### Result: **2건**

| # | Schema | Function | Updated columns |
|---:|---|---|---|
| 1 | `catchmenu_common` | `onboard_tenant` | `brand_id` |
| 2 | `catchmenu_store` | `update_business_hours` | `business_hours`, `updated_at` |

### UPDATE statement text (live `prosrc` extract)

```sql
update catchmenu_hq.stores set brand_id = v_brand_id where id = v_store_id;

update catchmenu_hq.stores set business_hours = p_business_hours, updated_at = now() where id = p_store_id and tenant_id = p_tenant_id;
```

---

## S-5. App code INSERT into `stores` (repo scan)

### Search paths

| Path / glob | Patterns |
|---|---|
| `catchmenu_app/**` | `.from('stores')`, `.from("stores")`, `INSERT INTO`, `stores` |
| Repo `*.{dart,ts,tsx,py,js,go}` | `.from('stores')`, `.from("stores")` |
| Repo `*.{dart,ts,tsx,py,js,go,sql}` | `insert into catchmenu_hq.stores` |

### Result: **0건** (application runtime code)

| Location | Matches |
|---|---|
| `catchmenu_app/**` | **0** |
| `*.{dart,ts,tsx,py,js,go}` (repo root) | **0** for `.from('stores')` |

**Factual note (not app code):** static SQL files with `insert into catchmenu_hq.stores`: `sql/migrations/0034_seed_data.sql`, `sql/migrations/0060_create_franchise_hq_rpc.sql`, `sql/migrations/0082_create_saas_billing_rpc.sql`, `cloud_backup_before_sync_2026_07_11.sql`.

---

## S-6. Triggers and views depending on `stores` (live)

### Triggers on `catchmenu_hq.stores`

```sql
SELECT t.tgname, t.tgisinternal, pg_get_triggerdef(t.oid) AS trigger_def
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'catchmenu_hq' AND c.relname = 'stores'
ORDER BY t.tgname;
```

| Category | Count |
|---|---:|
| Total triggers on `catchmenu_hq.stores` | **241** |
| Internal (`tgisinternal = true`) | **240** |
| User-visible (`tgisinternal = false`) | **1** — `trg_stores_updated_at` |

### Views / matviews whose definition contains `stores`

```sql
SELECT schemaname, viewname FROM pg_views WHERE definition ILIKE '%stores%' ORDER BY 1,2;
SELECT schemaname, matviewname FROM pg_matviews WHERE definition ILIKE '%stores%' ORDER BY 1,2;
```

| Kind | Count |
|---|---:|
| `pg_views` | **0건** |
| `pg_matviews` | **0건** |

---

## Summary

| Item | Count |
|---|---:|
| S-1 `stores`-referencing functions | 158 |
| S-2 INSERT into `catchmenu_hq.stores` functions | 2 |
| S-2 `NO_COLUMN_LIST` | 0 |
| S-2 `ROW_TYPE` | 0 |
| S-3 `SELECT *` / row type on `catchmenu_hq.stores` | 0 |
| S-4 UPDATE `catchmenu_hq.stores` functions | 2 |
| S-5 app code INSERT | 0 |
| S-6 triggers on `stores` (user-visible / total) | 1 / 241 |
| S-6 views / matviews referencing `stores` | 0 / 0 |

---

*Generated by Cursor live scan for `601717` C-1 evidence. No NOT NULL promotion judgment.*
