-- 0140_widen_error_domain_constraint.sql
-- Purpose: Widen catchmenu_common.error_codes.chk_error_domain to
--          allow 3 additional error_domain values discovered during
--          the SQL migration verification pass (2026-07-09): MENU,
--          STORE, AUDIT. These 19 error_key rows (0093's 5xxx/7xxx/
--          10xxx sections) have zero prior DB precedent under any
--          existing domain and were confirmed as genuinely distinct
--          business domains, not redundant with the original 17
--          (AUTH/SESSION/ORDER/PAYMENT/KDS/INVENTORY/STAFF/DEVICE/
--          AGENT/KNOWLEDGE/DELIVERY/CUSTOMER/FRANCHISE/SYSTEM/
--          GATEWAY/INTEGRATION/VALIDATION).
-- Depends on: 0062_create_i18n_error_diagnostics.sql (original
--             chk_error_domain), 0093_create_message_catalog_complete.sql
--             (consumer of the widened domains)
-- Note: numbered 0140 (a pre-existing free gap in the sequence), but
--       must be applied before 0093 to satisfy 0093's INSERT. No
--       integer exists between 0092 and 0093, so this file cannot be
--       numbered to run before 0093 in the normal sequential pass --
--       it requires an out-of-band apply ahead of its number, flagged
--       for explicit confirmation per session process note before
--       executing.

alter table catchmenu_common.error_codes
  drop constraint if exists chk_error_domain;

alter table catchmenu_common.error_codes
  add constraint chk_error_domain check (
    error_domain in (
      'AUTH','SESSION','ORDER','PAYMENT','KDS','INVENTORY','STAFF',
      'DEVICE','AGENT','KNOWLEDGE','DELIVERY','CUSTOMER','FRANCHISE',
      'SYSTEM','GATEWAY','INTEGRATION','VALIDATION',
      'MENU','STORE','AUDIT'
    )
  );
