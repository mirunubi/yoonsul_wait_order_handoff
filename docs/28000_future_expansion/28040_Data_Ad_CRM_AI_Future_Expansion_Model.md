# 28040 Data Ad CRM AI Future Expansion Model

## 1 Purpose

This document reserves future expansion around data, advertising, CRM, analytics, and AI.

These areas may become important after the MVP proves waiting/order handoff and Mini Kiosk adoption.

They are not active MVP runtime.

This document is conceptual only.
It does not define implementation, SQL, migrations, ad serving, AI model, CRM automation, membership ledger, or personal data processing policy.

## 2 Future Expansion Areas

Future areas:

- store analytics.
- menu performance analytics.
- waiting-to-order conversion analytics.
- Mini Kiosk language and visitor analytics.
- ad placement or promoted menu surfaces.
- CRM segmentation.
- revisit campaign support.
- AI recommendation.
- AI menu translation assistance.
- AI operational insight.

## 3 Data Boundary

Future data use must distinguish:

- operational data.
- customer session data.
- order candidate data.
- store runtime data.
- menu interaction data.
- audit/recovery data.
- future CRM or loyalty data.

Active MVP data must be collected for operational handoff first.

Future ad/CRM/AI use requires separate policy, consent, privacy, tenant agreement, and governance review.

## 4 Ad / Promotion Future Model

Possible future ad or promotion surfaces:

- promoted menu item.
- recommended set menu.
- tourist-friendly menu highlight.
- waiting-time offer.
- Mini Kiosk first-use campaign.
- store-local promotion.
- tenant-wide promotion.

Forbidden early assumption:

- paid ad serving is not active MVP.
- personalized ad targeting is not active MVP.
- coupon/point application is not active MVP.
- promotion visibility does not imply discount settlement.

## 5 CRM Future Model

Possible future CRM directions:

- revisit encouragement.
- language-based service improvement.
- order candidate abandonment follow-up.
- store-local customer preference support.
- tenant-level campaign support.

CRM must not be confused with active membership/point ledger.

Membership, loyalty, coupon, stamp, and point models remain reserved in `28020_Membership_Loyalty_Point_Future_Model.md`.

## 6 AI Future Model

Possible future AI directions:

- menu explanation assistance.
- multilingual content generation assistance.
- order candidate recommendation.
- staff-side operational insight.
- waiting/order delay prediction.
- store package optimization insight.

AI must not become the active MVP decision maker.

AI recommendation is future-reserved and must preserve staff/store confirmation and audit boundaries.

## 7 Privacy And Consent Boundary

Future data/ad/CRM/AI use requires:

- privacy policy review.
- consent design.
- data minimization.
- tenant/store agreement.
- customer-facing disclosure where needed.
- audit and opt-out model where applicable.

No future data product should silently reuse MVP operational data beyond approved purpose.

## 8 Relationship To MVP

Active MVP focuses on:

- waiting.
- Mini Kiosk.
- order candidate.
- staff confirmation.
- Store Agent/printer option.
- POS API boundary.
- store POS payment default.

Future data/ad/CRM/AI expansion must not change MVP wording from order candidate/preorder request into guaranteed order, payment, membership, or AI-personalized service.

## 9 Relationship To 26000 and MVP Non-Goals

- `docs/26000_analytics_reporting_bi/` controls analytics/reporting/BI boundary.
- `docs/26000_analytics_reporting_bi/26050_Analytics_To_Action_Governance.md` controls analytics-to-action governance.
- `docs/22000_implementation_planning/22060_Mvp_Implementation_Non_Goals.md` keeps AI recommendation, CRM automation, and ad targeting out of MVP.
- This `28040` document remains long-term market/future reference only.
- Data/Ad/CRM/AI must not become active runtime from this document.

This project may observe broader F&B SaaS/AI platform trends, but it does not implement group-level Franchise OS, ERP, manufacturing/logistics, or AI platform capabilities here.

## 10 Governance Cross-References

SaaS data capture governance is defined in `docs/20000_validation_security_audit/20010_SaaS_Data_Capture_And_Governance_Principle.md`.

Cross-entity privacy and data-sharing boundary is defined in `docs/20000_validation_security_audit/20020_Cross_Entity_Data_Sharing_And_Privacy_Boundary.md`.

Franchise OS data handoff future boundary is defined in `docs/28000_future_expansion/28050_Franchise_OS_Data_Handoff_Future_Boundary.md`.

Franchise intelligence feedback loop is defined in `docs/28000_future_expansion/28060_Franchise_Intelligence_Feedback_Loop_Model.md`.

This `9040` document remains future-reserved and must not imply active MVP ad, CRM, analytics automation, AI recommendation, or Franchise OS runtime.

## 11 Open Decisions

- whether analytics should enter before CRM.
- whether ad/promotion surfaces are store-local only or platform-wide.
- whether AI translation assistance is admin-only or customer-facing.
- what consent model applies to foreign visitor sessions.
- whether menu performance analytics can be aggregated across tenants.
- whether ad/CRM features require separate package plan.

## 12 Current Status

Status: future-reserved long-term market/future reference. Active analytics boundary is in `26000`.


