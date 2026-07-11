-- 0150_widen_event_domain_constraint.sql
-- Purpose: Widen catchmenu_ledger.events' chk_event_domain constraint
--          to allow the WAITING audit domain used by
--          catchmenu_pos.register_waiting(...). The 0115/0149 live
--          register_waiting() body records waiting_registered events
--          with event_domain = 'waiting', but the existing constraint
--          only allowed session/order/payment/kds/delivery/inventory/
--          staff/device/agent/recovery/knowledge/gateway/system.
--          Human Decision A (2026-07-11) approved adding 'waiting' as
--          a distinct event domain rather than remapping those events
--          into an existing domain.
-- Depends on: 0006_create_ledger_event.sql (original chk_event_domain),
--             0149_create_guest_customer_bootstrap_rpc.sql (consumer
--             path that re-exposes register_waiting through the guest
--             customer bootstrap verification flow)
-- Note: numbered 0150 (next free slot after 0149). This is a normal
--       forward migration, following the same DROP CONSTRAINT / ADD
--       CONSTRAINT widening pattern as 0140/0145/0146/0147.

alter table catchmenu_ledger.events
  drop constraint if exists chk_event_domain;

alter table catchmenu_ledger.events
  add constraint chk_event_domain check (
    event_domain in (
      'session','order','payment','kds','delivery','inventory','staff',
      'device','agent','recovery','knowledge','gateway','system',
      'waiting'
    )
  );
