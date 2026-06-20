# 000908_Template_POS_Provider_Integration_Evidence_Packet.md

## 1. Purpose

Template for POS provider integration evidence packets. Vendor and internal QA use this format for every significant test and production validation sample.

## 2. Evidence Packet Fields

| Field | Value |
| --- | --- |
| provider name | |
| adapter version | |
| test environment | sandbox / staging / production (production only with approval) |
| test case ID | |
| order ID | internal |
| payment ID | internal |
| POS transaction ID | provider |
| receipt ID | provider |
| request payload reference | secure storage link or redacted attachment ID |
| response payload reference | secure storage link or redacted attachment ID |
| timestamp | ISO 8601 UTC |
| retry count | |
| idempotency key | |
| operator action | system / vendor tester / store staff |
| failure type | none / timeout / duplicate / unknown / provider_error / mismatch |
| recovery step | |
| reconciliation result | matched / unmatched / pending |
| screenshot/log reference | |
| known limitation | |
| reviewer | |
| approval status | pending / approved / rejected |

## 3. Usage Rules

- One packet per test case execution that mutates order or payment state.
- Reconciliation runs produce one summary packet plus line-item references.
- Rejected packets require remediation notes before re-submission.

## 4. Final Rule

No deliverable acceptance without completed evidence packets per `000560`.
