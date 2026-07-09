-- 0145_widen_error_domain_constraint_membership_security_ai.sql
-- Purpose: Widen catchmenu_common.error_codes.chk_error_domain again to
--          allow 3 more error_domain values discovered continuing the
--          SQL migration verification pass (2026-07-10): MEMBERSHIP,
--          SECURITY, AI. Same situation as 0140 (which added MENU,
--          STORE, AUDIT): these error_key rows (0108 membership
--          pipeline, 0121 security pipeline, 0123/0127 AI customer
--          center + embedding) have zero prior DB precedent under any
--          existing domain and were confirmed as genuinely distinct
--          business domains, not redundant with the 20 already allowed
--          (the original 17 + 0140's MENU/STORE/AUDIT).
-- Depends on: 0140_widen_error_domain_constraint.sql,
--             0108_create_membership_pipeline_rpc.sql (consumer),
--             0121_create_security_pipeline.sql (consumer),
--             0123_create_ai_customer_center_v2.sql (consumer),
--             0127_create_multilingual_embedding_guide.sql (consumer)
-- Note: numbered 0145 (next free slot after 0144), but must be applied
--       before 0108 to satisfy 0108's INSERT. No integer exists between
--       0107 and 0108, so this file requires an out-of-band apply ahead
--       of its number -- flagged for explicit confirmation per session
--       process note before executing (same as 0140).

alter table catchmenu_common.error_codes
  drop constraint if exists chk_error_domain;

alter table catchmenu_common.error_codes
  add constraint chk_error_domain check (
    error_domain in (
      'AUTH','SESSION','ORDER','PAYMENT','KDS','INVENTORY','STAFF',
      'DEVICE','AGENT','KNOWLEDGE','DELIVERY','CUSTOMER','FRANCHISE',
      'SYSTEM','GATEWAY','INTEGRATION','VALIDATION',
      'MENU','STORE','AUDIT',
      'MEMBERSHIP','SECURITY','AI'
    )
  );
