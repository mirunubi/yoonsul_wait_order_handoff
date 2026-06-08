# 11010 POS Payment Printer Integration Boundary

## 1 Purpose

This document defines high-level integration boundaries for POS, payment, printer, Store Agent, and Full OS adoption.

It is documentation-only and does not define SQL, migrations, app code, Supabase functions, SDK integration, printer protocol, payment implementation, or POS API implementation.

## 2 POS API ?놁쓬: No External POS API

When a store has POS but no usable external API:

- no automatic POS order creation.
- staff confirmation and manual POS input are required.
- customer-facing and staff-facing wording must remain "order candidate" or "preorder request".
- the system must not claim POS sales completion.
- the existing POS remains responsible for payment, receipt, and kitchen printer where applicable.

Correct wording:

- order candidate.
- preorder request.
- staff-confirmed order candidate.
- confirmed after staff review.

## 3 POS API ?덉쓬: External POS API Available

When a store has a reliable external POS order API:

- Store Order Gateway may create POS order.
- POS handles kitchen printer or KDS when supported.
- POS order number mapping is possible.
- POS response and failure handling must be visible.
- Store Agent may remain optional for fallback, audit, or local backup.

This mode is store-specific and must not be assumed for every store.

## 4 Store Agent / Printer

Store Agent or printer gateway is optional.

It may:

- receive order candidate data.
- print order tickets.
- support staff handoff visibility.
- support fallback or audit flows.

It does not automatically create POS sales.

Required safeguards:

- duplicate order guard.
- missing order guard.
- failed print visibility.
- manual recovery path.
- daily/monthly reconciliation report.

Printer is optional, not mandatory.
Printer connection must not be assumed to work for every store.

## 5 Payment

Store POS payment is the early default.

Our payment-performing mode is an advanced option only.

Our payment mode requires:

- legal design.
- tax design.
- settlement design.
- receipt issuer decision.
- refund policy.
- seller-of-record decision.
- VAT reporting data.
- platform fee tax invoice design.
- POS reflection method.

Payment must remain separate from waiting and order handoff in the early MVP.

## 6 Full OS

Full OS adoption applies only to stores where we control or deeply coordinate:

- POS.
- KDS.
- membership.
- CMS.
- Agent.
- Audit.

Full OS can support tighter waiting, preorder, payment, temporary KDS order, table matching, membership, CMS, Agent, Audit, and AI analysis.

It is not the default adoption path for the first MVP.

## 7 Forbidden Assumptions

- POS API exists everywhere.
- printer can always connect.
- our system can guarantee POS sales sync without integration.
- payment is default.
- no-POS-API stores auto-reflect into POS.
- Store Agent exists in every store.
- KDS automation is available in early MVP.

## 8 Current Status

Status: active integration boundary design.

This document keeps integration high-level until store-specific technical capability is approved.

## 9 Runtime Model Cross-Reference

Integration levels must align with `docs/03000_saas_runtime/03010_Tenant_Store_Runtime_And_Package_Model.md`.

Payment profile is independent from integration profile.

POS API enabled does not automatically mean platform payment enabled.

Store Agent/printer enabled does not automatically mean POS sales sync.

## 10 Membership / Point Future Boundary

Membership/point bridge is not part of the `6010` active integration boundary.

Future point bridge is reserved under `docs/28000_future_expansion/`.

Payment integration does not imply point integration.

POS API integration does not imply membership integration.

## 11 Integration Boundary Consolidation Cross-Reference

- POS API truth boundary is refined in `docs/11000_integration_boundary/11020_POS_API_Integration_Truth_Boundary.md`.
- Printer/Store Agent boundary is refined in `docs/11000_integration_boundary/11030_Printer_And_Store_Agent_Boundary.md`.
- Payment/financial truth boundary is refined in `docs/11000_integration_boundary/11040_Payment_And_Financial_Truth_Boundary.md`.
- Manual POS input/reconciliation boundary is refined in `docs/11000_integration_boundary/11050_Manual_POS_Input_And_Reconciliation_Boundary.md`.
- Failure/retry/recovery boundary is refined in `docs/11000_integration_boundary/11060_Integration_Failure_Retry_And_Recovery_Boundary.md`.


