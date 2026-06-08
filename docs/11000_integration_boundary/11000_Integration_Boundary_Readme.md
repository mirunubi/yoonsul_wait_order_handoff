# 11000 Integration Boundary Readme

## 1 Purpose

This folder defines the high-level boundary for POS, KDS, payment, printer, tablet order, and external systems.

This wave consolidates integration boundary governance after MVP scope, SaaS runtime, Admin Console, and Data/State consolidation waves.

## 2 In Scope

- Integration boundary principles.
- POS API integration truth boundary.
- Printer and Store Agent boundary.
- Payment and financial truth boundary.
- Manual POS input and reconciliation boundary.
- Integration failure, retry, and recovery boundary.
- Manual POS entry allowance.
- Future external system connection references.
- POS, payment, printer, Store Agent, and Full OS adoption boundaries.

## 3 Document List

| document | description |
| --- | --- |
| `11010_POS_Payment_Printer_Integration_Boundary.md` | Defines high-level boundaries for no-POS-API stores, POS API stores, Store Agent/printer option, payment separation, Full OS adoption, and forbidden assumptions. |
| `11020_POS_API_Integration_Truth_Boundary.md` | POS API availability, attempt, success, failure, and mapping truth rules. |
| `11030_Printer_And_Store_Agent_Boundary.md` | Store Agent and printer output boundary; print does not equal POS sales. |
| `11040_Payment_And_Financial_Truth_Boundary.md` | Store POS payment default, platform payment future, and financial truth separation. |
| `11050_Manual_POS_Input_And_Reconciliation_Boundary.md` | Manual POS input and reconciliation candidate boundary for stores without POS API. |
| `11060_Integration_Failure_Retry_And_Recovery_Boundary.md` | Failure families, retry/recovery rules, and recovery actions with audit lineage. |

`11010` remains the initial POS/payment/printer boundary.

`11020`~`11060` refine truth boundaries, failure/retry/recovery, and financial authority separation.

This domain does not implement integrations.

## 4 Out Of Scope

- Full POS API integration, payment processing, KDS automation, printer protocol, and external SDK implementation.
- Retry jobs, reconciliation engines, alerting, and incident automation.

## 5 Current Status

Status: integration boundary consolidation wave complete. High-level and refined truth boundaries only. Not implementation approval.
