-- 0147_widen_plan_tier_constraint.sql
-- Purpose: Widen catchmenu_common.subscription_plans' chk_plan_tier
--          constraint to allow BASIC and FRANCHISE, used by
--          0133_create_final_validation_package.sql's 5-tier pricing
--          seed (TRIAL/STARTER/BASIC/PRO/FRANCHISE at 0/19900/39900/
--          79900/199900 KRW). Same rationale as 0140/0145/0146: a
--          genuinely distinct pricing tier with zero DB precedent,
--          not redundant with the existing 4 tiers -- BASIC sits
--          between STARTER and PRO, FRANCHISE is a distinct top tier
--          from ENTERPRISE (multi-store/franchise-specific), not
--          merged into it to preserve the original business intent.
-- Depends on: 0058_create_membership_rpc.sql (original chk_plan_tier),
--             0133_create_final_validation_package.sql (consumer)
-- Note: numbered 0147 (next free slot), but must be applied before
--       0133 to satisfy 0133's INSERT. Requires an out-of-band apply
--       ahead of its number, same established pattern as 0140/0145/
--       0146.

alter table catchmenu_common.subscription_plans
  drop constraint if exists chk_plan_tier;

alter table catchmenu_common.subscription_plans
  add constraint chk_plan_tier check (
    plan_tier in (
      'TRIAL','STARTER','PRO','ENTERPRISE',
      'BASIC','FRANCHISE'
    )
  );
