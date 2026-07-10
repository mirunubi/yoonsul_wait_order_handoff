-- 0148_add_order_sessions_customer_id_and_guest_flag.sql
-- Purpose: Add the canonical customer linkage needed by waiting/order sessions
--          and guest promotion: catchmenu_store.customers.is_guest,
--          catchmenu_pos.order_sessions.customer_id, and
--          catchmenu_pos.order_sessions.phone_hash.
-- Depends on: 0147_widen_plan_tier_constraint.sql
-- Creates:
--   catchmenu_store.customers.is_guest
--   catchmenu_pos.order_sessions.customer_id
--   catchmenu_pos.order_sessions.phone_hash
--   catchmenu_pos.order_sessions_customer_id_fkey
--   idx_order_sessions_customer
--
-- Background:
--   The local database had an out-of-band partial application of
--   order_sessions.customer_id, its FK, and idx_order_sessions_customer
--   without a recorded migration_history row. That local FK used
--   ON DELETE NO ACTION, while the approved design requires
--   ON DELETE SET NULL so historical order_sessions rows survive customer
--   deletion/anonymization with only the customer_id pointer cleared.
--   This migration therefore first removes the out-of-band customer_id
--   column/FK/index safely, then recreates the approved specification.
--
-- Human Decision summary from 600112_Logic.md:
--   - Guest sessions are linked to catchmenu_store.customers through
--     order_sessions.customer_id.
--   - Guest promotion is represented by updating the same customers row
--     from is_guest = true to is_guest = false; this is not a separate
--     merge/rewrite flow.
--   - order_sessions.customer_id must use ON DELETE SET NULL.
--   - phone_hash is added because 0115 already assumes it exists on
--     order_sessions, although the 0012 base table did not create it.
--
-- Open Items intentionally not solved by this migration:
--   1. 005015 policy remains unrevised; in-place promotion vs. true merge
--      wording is deferred to a separate documentation decision.
--   2. Anonymous guest dedupe remains absent; device-fingerprint or other
--      dedupe policy is deferred.
--   3. The duplicate 604500 workpacket/folder issue remains deferred; this
--      migration only implements the approved DB forward fix.

alter table catchmenu_pos.order_sessions
  drop constraint if exists order_sessions_customer_id_fkey;

drop index if exists catchmenu_pos.idx_order_sessions_customer;

alter table catchmenu_pos.order_sessions
  drop column if exists customer_id;

alter table catchmenu_store.customers
  add column if not exists is_guest boolean not null default false;

alter table catchmenu_pos.order_sessions
  add column customer_id uuid
    references catchmenu_store.customers(id)
    on delete set null;

alter table catchmenu_pos.order_sessions
  add column if not exists phone_hash text;

create index idx_order_sessions_customer
  on catchmenu_pos.order_sessions(customer_id)
  where customer_id is not null;

comment on column catchmenu_store.customers.is_guest is
  'Flags a customer identity row as a guest-created identity pending in-place promotion to a member/customer account.';

comment on column catchmenu_pos.order_sessions.customer_id is
  'Optional FK linking a wait/order session to catchmenu_store.customers; ON DELETE SET NULL preserves session history when customer identity is removed.';

comment on column catchmenu_pos.order_sessions.phone_hash is
  'Hashed phone identifier used by the waiting pipeline and guest customer promotion flow; nullable for anonymous guests.';
