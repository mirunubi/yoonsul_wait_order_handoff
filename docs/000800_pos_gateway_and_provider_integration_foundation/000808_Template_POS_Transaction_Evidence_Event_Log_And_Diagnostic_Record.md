# 000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md

## 1. Purpose

Template for POS transaction evidence, event log, and diagnostic records.

## 2. Record Fields

| Field | Value |
| --- | --- |
| event ID | |
| provider name | |
| adapter version | |
| environment | sandbox / staging / production |
| test case ID | |
| order ID | internal |
| payment ID | internal |
| POS transaction ID | provider |
| receipt ID | provider |
| request payload reference | secure ref |
| response payload reference | secure ref |
| timestamp | ISO 8601 UTC |
| retry count | |
| idempotency key | |
| operator action | system / staff / vendor |
| failure type | none / timeout / duplicate / unknown / provider_error / mismatch |
| recovery step | |
| reconciliation result | matched / unmatched / pending |
| screenshot reference | |
| log reference | |
| known limitation | |
| reviewer | |
| approval status | pending / approved / rejected |

## 3. Usage

- Required for every mutating gateway operation in test and production validation.
- `000900` vendor evidence packets must align with this template.
- Rejected records require remediation notes.

## 4. Final Rule

No state change without traceable evidence.
