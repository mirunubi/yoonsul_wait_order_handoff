# 001060_MVP_Store_Type_Adoption_Sequence

## 1 Purpose

Different stores adopt different levels of handoff.

MVP should avoid forcing all stores into full integration.

This document aligns store types with realistic adoption phases.

This document does not approve implementation.

## 2 Store Type Sequence

| store type | description |
| --- | --- |
| Type 0 | No POS / system-resistant store. |
| Type 1 | POS exists, no API. |
| Type 1B | POS no API + Store Agent/printer option. |
| Type 2 | POS API available. |
| Type 3 | Platform payment. |
| Type 4 | Full OS controlled store. |

Aligns with `docs/01000_mvp_scope/001020_Store_Type_And_Product_Package_Strategy.md` store type classification.

## 3 MVP Adoption Priority

- Type 1 and Mini Kiosk Only are realistic early targets.
- Type 1 waiting + staff review is early target.
- Type 1B Store Agent/printer is optional and higher-risk.
- Type 2 POS API is later integration path.
- Type 3 platform payment is not default MVP.
- Type 4 Full OS is not generic SaaS MVP.

## 4 Adoption Risk Rules

- POS API absent means no POS auto-order claim.
- printer option does not create POS sale.
- staff review remains required unless proper authority exists.
- platform payment requires separate legal/payment/settlement review.
- Full OS assumptions must not leak into generic SaaS package.

## 5 Cross-References

- `docs/01000_mvp_scope/001020_Store_Type_And_Product_Package_Strategy.md`
- `docs/01000_mvp_scope/001050_Boundary_MVP_Package_And_Feature_Flag.md`
- `docs/11000_integration_boundary/011010_Boundary_POS_Payment_Printer_Integration.md`
- `docs/22000_implementation_planning/022060_Boundary_Mvp_Implementation_Non_Goals.md`

## 6 Open Decisions

- initial beachhead store type.
- whether Type 0 is served by Mini Kiosk only.
- whether Type 1B is included in MVP.
- whether Type 2 pilot requires partner POS.
- whether Type 4 is Yoonsul-only future path.

## 7 Current Status

Status: active MVP store-type adoption sequence. Not implementation approval.
