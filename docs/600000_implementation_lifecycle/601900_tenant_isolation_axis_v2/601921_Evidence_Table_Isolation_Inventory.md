# 601921_Evidence_Table_Isolation_Inventory.md

Status: Active
Lifecycle: Evidence
Last Updated: 2026-09-08

## §0 성격

**`601919` 독립 감사의 부속 증거다.**

```text
원 위치   감사자 작업 디렉터리 — 저장소 밖
편입 사유  601919 tenant isolation 실측이며 저장소 밖에 두면 추적이 끊긴다
편입일    2026-09-08
```

**원문을 편집하지 않았다.**

## §1 원문 — VERBATIM

````text
# Table isolation inventory

Every local application table is included. ACL/RLS evidence is catalog-verified; per-table adversarial SELECT/INSERT/UPDATE/DELETE and every RPC path are not exhaustively verified. The full expressions, constraints, indexes, and triggers are in db-catalog-evidence.json.

| Table | tenant_id | RLS / FORCE | authenticated S/I/U/D | Policies |
|---|---|---|---|---|
| catchmenu_agent.agent_actions | True | True/True | False/False/False/False | agent_actions_store_isolation (ALL) |
| catchmenu_agent.agent_approvals | True | True/True | False/False/False/False | agent_approvals_store_isolation (ALL) |
| catchmenu_agent.evidence_packets | True | True/True | False/False/False/False | evidence_packets_store_isolation (ALL) |
| catchmenu_agent.manual_fallback_log | True | True/True | False/False/False/False | fallback_log_store_isolation (ALL) |
| catchmenu_ai.ai_inference_logs | True | False/False | True/True/False/False | NONE |
| catchmenu_ai.ai_prompt_templates | True | False/False | True/False/False/False | NONE |
| catchmenu_audit.security_scan_results | True | True/True | False/False/False/False | security_scan_isolation (ALL) |
| catchmenu_common.auth_sessions | True | True/True | False/False/False/False | auth_sessions_isolation (ALL) |
| catchmenu_common.cron_job_executions | False | False/False | True/False/False/False | NONE |
| catchmenu_common.deployment_checklist | False | False/False | True/False/False/False | NONE |
| catchmenu_common.diagnostic_logs | True | True/True | False/False/False/False | diag_logs_isolation (ALL) |
| catchmenu_common.edge_function_configs | False | True/True | False/False/False/False | edge_fn_configs_read (SELECT) |
| catchmenu_common.edge_function_registry | True | True/True | True/False/False/False | edge_function_isolation (ALL) |
| catchmenu_common.edge_function_templates | False | False/False | True/False/False/False | NONE |
| catchmenu_common.error_codes | False | False/False | True/False/False/False | NONE |
| catchmenu_common.fallback_configs | True | True/True | False/False/False/False | fallback_config_isolation (ALL) |
| catchmenu_common.feature_flags | False | False/False | True/False/False/False | NONE |
| catchmenu_common.firebase_migration_boundary | True | False/False | True/False/False/False | NONE |
| catchmenu_common.flutter_sdk_patterns | False | False/False | True/False/False/False | NONE |
| catchmenu_common.gateway_audit_log | True | True/True | False/False/False/False | gateway_log_isolation (ALL) |
| catchmenu_common.idempotency_keys | True | True/True | False/False/False/False | idempotency_keys_store_isolation (ALL) |
| catchmenu_common.integration_test_results | True | True/True | False/False/False/False | integration_tests_isolation (ALL) |
| catchmenu_common.login_attempts | True | True/True | False/False/False/False | login_attempts_isolation (ALL) |
| catchmenu_common.message_catalog | False | False/False | True/False/False/False | NONE |
| catchmenu_common.network_status_log | True | True/True | False/False/False/False | network_log_isolation (ALL) |
| catchmenu_common.offline_queue | True | True/True | False/False/False/False | offline_queue_isolation (ALL) |
| catchmenu_common.online_order_configs | True | True/True | False/False/False/False | online_order_isolation (ALL) |
| catchmenu_common.operation_alerts | True | True/True | False/False/False/False | operation_alerts_isolation (ALL) |
| catchmenu_common.operation_metrics | True | True/True | False/False/False/False | metrics_isolation (ALL) |
| catchmenu_common.pg_cron_jobs | False | False/False | True/False/False/False | NONE |
| catchmenu_common.pgcron_execution_log | True | True/True | False/False/False/False | pgcron_log_isolation (ALL) |
| catchmenu_common.phone_verify_codes | True | True/True | False/False/False/False | verify_codes_isolation (ALL) |
| catchmenu_common.realtime_channels | True | True/True | True/False/False/False | realtime_channels_isolation (ALL) |
| catchmenu_common.saas_launch_checklist | True | True/True | False/False/False/False | launch_checklist_isolation (ALL) |
| catchmenu_common.sandbox_violations | True | True/True | False/False/False/False | sandbox_violations_hq (SELECT) |
| catchmenu_common.schema_versions | False | False/False | False/False/False/False | NONE |
| catchmenu_common.security_audit_log | True | True/True | False/False/False/False | security_audit_isolation (ALL) |
| catchmenu_common.security_threats | True | True/True | False/False/False/False | threats_hq_read (SELECT) |
| catchmenu_common.security_tokens | True | True/True | False/False/False/False | security_tokens_isolation (ALL) |
| catchmenu_common.sop_runbooks | False | False/False | False/False/False/False | NONE |
| catchmenu_common.subscription_invoices | True | True/True | False/False/False/False | invoice_service_role (ALL); invoices_isolation (ALL) |
| catchmenu_common.subscription_plans | False | False/False | True/False/False/False | NONE |
| catchmenu_common.tenant_onboarding_log | True | True/True | False/False/False/False | onboarding_isolation (ALL) |
| catchmenu_common.tenant_plan_configs | True | True/True | False/False/False/False | plan_configs_service (ALL); tenant_plan_isolation (ALL) |
| catchmenu_common.tenant_quotas | True | True/True | False/False/False/False | tenant_quotas_isolation (ALL) |
| catchmenu_common.tenant_rate_limits | True | True/True | False/False/False/False | rate_limits_isolation (ALL) |
| catchmenu_common.usage_records | True | True/True | False/False/False/False | usage_records_isolation (ALL) |
| catchmenu_common.white_label_configs | True | True/True | False/False/False/False | white_label_isolation (ALL) |
| catchmenu_dev.dev_audit_log | True | False/False | False/False/False/False | NONE |
| catchmenu_dev.dev_session_trace | True | False/False | False/False/False/False | NONE |
| catchmenu_gateway.gateway_sessions | True | True/True | False/False/False/False | gateway_sessions_service_only (ALL) |
| catchmenu_gateway.provider_raw_events | True | True/True | False/False/False/False | provider_raw_events_service_only (ALL) |
| catchmenu_hq.escalation_log | True | True/True | False/False/False/False | escalation_log_isolation (ALL) |
| catchmenu_hq.franchise_approval_requests | True | True/True | False/False/False/False | approval_requests_isolation (ALL) |
| catchmenu_hq.franchise_brands | True | True/True | False/False/False/False | brands_isolation (ALL); franchise_brands_isolation (ALL) |
| catchmenu_hq.franchise_kpi_targets | True | True/True | False/False/False/False | kpi_targets_isolation (ALL) |
| catchmenu_hq.franchise_menu_templates | True | True/True | False/False/False/False | menu_template_isolation (ALL) |
| catchmenu_hq.franchise_policies | True | True/True | False/False/False/False | franchise_policies_isolation (ALL); policies_isolation (ALL) |
| catchmenu_hq.franchise_policy_assignments | True | True/True | False/False/False/False | policy_assignments_isolation (ALL) |
| catchmenu_hq.hq_notices | True | True/True | False/False/False/False | hq_notices_isolation (ALL) |
| catchmenu_hq.legal_entities | False | True/True | False/False/False/False | NONE |
| catchmenu_hq.legal_entity_person_roles | False | True/True | False/False/False/False | NONE |
| catchmenu_hq.legal_entity_representatives | False | True/True | False/False/False/False | NONE |
| catchmenu_hq.menu_distribution_log | True | True/True | False/False/False/False | dist_log_isolation (ALL) |
| catchmenu_hq.menu_templates | True | True/True | False/False/False/False | menu_templates_isolation (ALL) |
| catchmenu_hq.merchant_accounts | True | True/True | False/False/False/False | NONE |
| catchmenu_hq.persons | False | True/True | False/False/False/False | NONE |
| catchmenu_hq.policy_compliance_checks | True | True/True | False/False/False/False | compliance_checks_isolation (ALL) |
| catchmenu_hq.policy_violations | True | True/True | False/False/False/False | violations_isolation (ALL) |
| catchmenu_hq.store_group_members | True | True/True | False/False/False/False | group_members_isolation (ALL) |
| catchmenu_hq.store_groups | True | True/True | False/False/False/False | store_groups_isolation (ALL) |
| catchmenu_hq.stores | True | True/True | False/False/False/False | stores_select_own (SELECT) |
| catchmenu_hq.tenants | False | True/True | False/False/False/False | tenants_select_own (SELECT) |
| catchmenu_integrations.cash_receipt_log | True | True/True | False/False/False/False | cash_receipt_isolation (ALL) |
| catchmenu_integrations.delivery_intake_log | True | True/True | False/False/False/False | delivery_intake_isolation (ALL) |
| catchmenu_integrations.delivery_order_sync_log | True | True/True | False/False/False/False | delivery_sync_log_isolation (ALL) |
| catchmenu_integrations.delivery_platform_configs | True | True/True | False/False/False/False | delivery_config_isolation (ALL) |
| catchmenu_integrations.delivery_platform_rules | True | True/True | False/False/False/False | delivery_rules_isolation (ALL) |
| catchmenu_integrations.okpos_menu_sync_log | True | True/True | False/False/False/False | okpos_menu_sync_isolation (ALL) |
| catchmenu_integrations.okpos_order_send_log | True | True/True | False/False/False/False | okpos_order_send_isolation (ALL) |
| catchmenu_integrations.okpos_transactions | True | True/True | False/False/False/False | okpos_tx_isolation (ALL) |
| catchmenu_integrations.pos_provider_registry | False | True/True | True/False/False/False | pos_registry_read (SELECT) |
| catchmenu_integrations.pos_store_configs | True | True/True | False/False/False/False | pos_store_configs_isolation (ALL) |
| catchmenu_integrations.toss_payment_requests | True | True/True | False/False/False/False | toss_requests_isolation (ALL) |
| catchmenu_integrations.toss_payments | True | True/True | False/False/False/False | toss_payments_store_select (SELECT) |
| catchmenu_integrations.toss_pos_menu_sync_log | True | True/True | False/False/False/False | toss_pos_sync_isolation (ALL) |
| catchmenu_integrations.toss_pos_order_log | True | True/True | False/False/False/False | toss_pos_order_isolation (ALL) |
| catchmenu_integrations.toss_pos_transactions | True | True/True | False/False/False/False | toss_pos_tx_isolation (ALL) |
| catchmenu_integrations.toss_webhook_log | True | True/True | False/False/False/False | toss_webhook_isolation (ALL) |
| catchmenu_integrations.toss_webhooks | True | True/True | False/False/False/False | toss_webhooks_service_only (ALL) |
| catchmenu_integrations.van_settlements | True | True/True | False/False/False/False | van_settlement_isolation (ALL) |
| catchmenu_integrations.van_transactions | True | True/True | False/False/False/False | van_tx_isolation (ALL) |
| catchmenu_kds.kds_events | True | True/True | False/False/False/False | kds_events_insert (INSERT); kds_events_store_select (SELECT) |
| catchmenu_kds.kds_tickets | True | True/True | False/False/False/False | kds_tickets_store_isolation (ALL) |
| catchmenu_knowledge.ai_query_logs | True | True/True | False/False/False/False | ai_query_logs_isolation (ALL) |
| catchmenu_knowledge.customer_inquiries | True | True/True | False/False/False/False | customer_inquiries_isolation (ALL) |
| catchmenu_knowledge.document_embeddings_1536 | True | True/True | False/False/False/False | embeddings_isolation (ALL) |
| catchmenu_knowledge.document_embeddings_3072 | True | True/True | False/False/False/False | embeddings_isolation (ALL) |
| catchmenu_knowledge.document_embeddings_4096 | True | True/True | False/False/False/False | embeddings_isolation (ALL) |
| catchmenu_knowledge.document_versions | True | True/True | False/False/False/False | doc_versions_tenant_isolation (SELECT) |
| catchmenu_knowledge.documents | True | True/True | False/False/False/False | knowledge_docs_manager_all (ALL); knowledge_docs_tenant_isolation (SELECT) |
| catchmenu_knowledge.embedding_models | False | False/False | False/False/False/False | NONE |
| catchmenu_knowledge.inquiry_categories | True | True/True | False/False/False/False | inquiry_categories_isolation (ALL) |
| catchmenu_knowledge.knowledge_gaps | True | True/True | False/False/False/False | knowledge_gaps_store_isolation (ALL) |
| catchmenu_knowledge.menu_embeddings | True | True/True | False/False/False/False | menu_embedding_isolation (ALL) |
| catchmenu_knowledge.menu_search_logs | True | True/True | False/False/False/False | search_logs_isolation (ALL) |
| catchmenu_knowledge.sop_candidates | True | True/True | False/False/False/False | sop_candidates_isolation (ALL) |
| catchmenu_knowledge.sop_evolution_log | True | True/True | False/False/False/False | sop_evolution_isolation (ALL) |
| catchmenu_ledger.audit_records | True | True/True | False/False/False/False | audit_records_insert (INSERT); audit_records_select_manager (SELECT) |
| catchmenu_ledger.events | True | True/True | False/False/False/False | events_store_insert (INSERT); events_store_select (SELECT) |
| catchmenu_ledger.exceptions | True | True/True | False/False/False/False | exceptions_store_isolation (ALL) |
| catchmenu_ledger.integrity_check_results | True | True/True | False/False/False/False | integrity_check_isolation (ALL) |
| catchmenu_ledger.local_temporary_ledger | True | True/True | False/False/False/False | local_ledger_device_isolation (ALL) |
| catchmenu_ledger.tasks | True | True/True | False/False/False/False | tasks_store_insert (INSERT); tasks_store_select (SELECT) |
| catchmenu_meta.migration_history | False | False/False | False/False/False/False | NONE |
| catchmenu_payment.audit_evidence_packets | True | True/True | False/False/False/False | audit_packet_isolation (ALL) |
| catchmenu_payment.payment_events | True | True/True | False/False/False/False | payment_events_insert (INSERT); payment_events_store_select (SELECT) |
| catchmenu_payment.payment_intents | True | True/True | False/False/False/False | payment_intents_store_isolation (ALL) |
| catchmenu_payment.payment_ledger | True | True/True | False/False/False/False | payment_ledger_select (SELECT) |
| catchmenu_payment.pg_settlement_files | True | True/True | False/False/False/False | settlement_files_isolation (ALL) |
| catchmenu_payment.reconciliation_cases | True | True/True | False/False/False/False | recon_cases_isolation (ALL); reconciliation_select_manager (SELECT) |
| catchmenu_payment.reconciliation_daily_summary | True | True/True | False/False/False/False | recon_summary_isolation (ALL) |
| catchmenu_payment.reconciliation_layer2_results | True | True/True | False/False/False/False | l2_recon_isolation (ALL) |
| catchmenu_payment.reconciliation_layer3_results | True | True/True | False/False/False/False | l3_recon_isolation (ALL) |
| catchmenu_payment.van_settlement_daily | True | True/True | False/False/False/False | van_settlement_isolation (ALL) |
| catchmenu_payment.van_transactions | True | True/True | False/False/False/False | van_tx_isolation (ALL) |
| catchmenu_pos.allergen_codes | False | False/False | True/False/False/False | NONE |
| catchmenu_pos.menu_allergen_links | True | True/True | False/False/False/False | menu_allergen_isolation (ALL) |
| catchmenu_pos.menu_categories | True | True/True | False/False/False/False | menu_categories_store_isolation (ALL) |
| catchmenu_pos.menu_i18n | True | True/True | False/False/False/False | menu_i18n_isolation (ALL) |
| catchmenu_pos.menu_option_groups | True | True/True | False/False/False/False | menu_option_groups_store_isolation (ALL) |
| catchmenu_pos.menu_option_items | True | True/True | False/False/False/False | menu_option_items_store_isolation (ALL) |
| catchmenu_pos.menu_prices | True | True/True | False/False/False/False | menu_prices_store_isolation (ALL) |
| catchmenu_pos.menus | True | True/True | False/False/False/False | menus_store_isolation (ALL) |
| catchmenu_pos.option_item_prices | True | True/True | False/False/False/False | option_item_prices_store_isolation (ALL) |
| catchmenu_pos.order_events | True | True/True | False/False/False/False | order_events_insert (INSERT); order_events_store_select (SELECT) |
| catchmenu_pos.order_items | True | True/True | False/False/False/False | order_items_store_isolation (ALL) |
| catchmenu_pos.order_sessions | True | True/True | False/False/False/False | order_sessions_store_isolation (ALL) |
| catchmenu_pos.orders | True | True/True | False/False/False/False | orders_store_isolation (ALL) |
| catchmenu_pos.price_list_assignments | True | True/True | False/False/False/False | price_list_assignments_store_isolation (ALL) |
| catchmenu_pos.price_lists | True | True/True | False/False/False/False | price_lists_tenant_isolation (ALL) |
| catchmenu_pos.session_events | True | True/True | False/False/False/False | session_events_insert (INSERT); session_events_store_isolation (SELECT) |
| catchmenu_store.agent_registry | True | True/True | False/False/False/False | agent_registry_store_isolation (ALL) |
| catchmenu_store.cms_banners | True | True/True | False/False/False/False | cms_banners_isolation (ALL) |
| catchmenu_store.cms_content_versions | True | True/True | False/False/False/False | cms_versions_isolation (ALL) |
| catchmenu_store.cms_contents | True | True/True | False/False/False/False | cms_contents_isolation (ALL) |
| catchmenu_store.cms_events | True | True/True | False/False/False/False | cms_events_isolation (ALL) |
| catchmenu_store.cms_popups | True | True/True | False/False/False/False | cms_popups_isolation (ALL) |
| catchmenu_store.cms_publish_log | True | True/True | False/False/False/False | cms_publish_log_isolation (ALL) |
| catchmenu_store.coupon_issues | True | True/True | False/False/False/False | coupon_issues_isolation (ALL) |
| catchmenu_store.coupons | True | True/True | False/False/False/False | coupons_isolation (ALL) |
| catchmenu_store.customer_app_sessions | True | True/True | False/False/False/False | customer_sessions_isolation (ALL) |
| catchmenu_store.customers | True | True/True | False/False/False/False | customers_isolation (ALL) |
| catchmenu_store.device_commands | True | True/True | False/False/False/False | device_commands_isolation (ALL) |
| catchmenu_store.device_groups | True | True/True | False/False/False/False | device_groups_isolation (ALL) |
| catchmenu_store.device_registry | True | True/True | False/False/False/False | device_registry_store_isolation (ALL) |
| catchmenu_store.did_content_schedule | True | True/True | False/False/False/False | did_content_isolation (ALL) |
| catchmenu_store.did_devices | True | True/True | False/False/False/False | did_devices_isolation (ALL) |
| catchmenu_store.did_display_queue | True | True/True | False/False/False/False | did_queue_isolation (ALL) |
| catchmenu_store.dining_tables | True | True/True | False/False/False/False | dining_tables_store_isolation (ALL) |
| catchmenu_store.emergency_contacts | True | True/True | False/False/False/False | emergency_contacts_isolation (ALL) |
| catchmenu_store.ingredients | True | True/True | False/False/False/False | ingredients_isolation (ALL) |
| catchmenu_store.inventory_items | True | True/True | False/False/False/False | inventory_items_isolation (ALL) |
| catchmenu_store.inventory_movements | True | True/True | False/False/False/False | movements_isolation (ALL) |
| catchmenu_store.inventory_transactions | True | True/True | False/False/False/False | inv_tx_isolation (ALL) |
| catchmenu_store.kiosk_configs | True | True/True | False/False/False/False | kiosk_configs_isolation (ALL) |
| catchmenu_store.kiosk_sessions | True | True/True | False/False/False/False | kiosk_sessions_isolation (ALL) |
| catchmenu_store.membership_configs | True | True/True | False/False/False/False | membership_config_isolation (ALL) |
| catchmenu_store.membership_tiers_config | True | True/True | False/False/False/False | tiers_config_isolation (ALL) |
| catchmenu_store.menu_inventory_links | True | True/True | False/False/False/False | menu_inv_link_isolation (ALL) |
| catchmenu_store.pay_basis_records | True | True/True | False/False/False/False | pay_basis_isolation (ALL) |
| catchmenu_store.point_ledger | True | True/True | False/False/False/False | point_ledger_isolation (ALL) |
| catchmenu_store.point_rules | True | True/True | False/False/False/False | point_rules_isolation (ALL) |
| catchmenu_store.point_transfer_log | True | True/True | False/False/False/False | transfer_log_isolation (ALL) |
| catchmenu_store.promotions | True | True/True | False/False/False/False | promotions_isolation (ALL) |
| catchmenu_store.push_notification_log | True | True/True | False/False/False/False | push_log_isolation (ALL) |
| catchmenu_store.push_notification_templates | True | True/True | False/False/False/False | push_templates_isolation (ALL) |
| catchmenu_store.staff | True | True/True | False/False/False/False | staff_isolation (ALL) |
| catchmenu_store.staff_attendance | True | True/True | False/False/False/False | attendance_isolation (ALL) |
| catchmenu_store.staff_memos | True | True/True | False/False/False/False | staff_memos_isolation (ALL) |
| catchmenu_store.staff_permission_logs | True | True/True | False/False/False/False | permission_logs_isolation (ALL) |
| catchmenu_store.staff_permission_matrix | True | True/True | False/False/False/False | permission_matrix_isolation (ALL) |
| catchmenu_store.staff_schedules | True | True/True | False/False/False/False | staff_schedules_isolation (ALL) |
| catchmenu_store.staff_shifts | True | True/True | False/False/False/False | staff_shifts_isolation (ALL) |
| catchmenu_store.staff_tasks | True | True/True | False/False/False/False | staff_tasks_isolation (ALL) |
| catchmenu_store.stamp_cards | True | True/True | False/False/False/False | stamp_cards_isolation (ALL) |
| catchmenu_store.stock_transfer_items | True | True/True | False/False/False/False | transfer_items_isolation (ALL) |
| catchmenu_store.stock_transfer_requests | True | True/True | False/False/False/False | transfer_requests_isolation (ALL) |
| catchmenu_store.store_business_hours | True | True/True | False/False/False/False | store_hours_isolation (ALL) |
| catchmenu_store.store_holidays | True | True/True | False/False/False/False | store_holidays_isolation (ALL) |
| catchmenu_store.store_notices | True | True/True | False/False/False/False | store_notices_isolation (ALL) |
| catchmenu_store.store_settings | True | True/True | False/False/False/False | store_settings_isolation (ALL) |
````

## §2 Status

```text
Audit evidence only.
```
