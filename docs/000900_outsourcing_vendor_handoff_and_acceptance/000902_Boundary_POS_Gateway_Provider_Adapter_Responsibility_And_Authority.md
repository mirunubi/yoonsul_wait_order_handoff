# 000902_Boundary_POS_Gateway_Provider_Adapter_Responsibility_And_Authority.md

## 1. Purpose

This document defines responsibility boundaries between our system and an outsourced POS integration vendor.

## 2. Our System Owns

| Domain | Authority |
| --- | --- |
| Order authority model | What constitutes an accepted order |
| Payment authority model | What constitutes authorized, captured, or refunded payment |
| Cancellation and refund policy | Business rules and approval paths |
| Source of truth decision | Which system owns each state |
| State machine | Normalized order/payment lifecycle |
| Audit and evidence rules | What must be logged and retained |
| Recovery policy | Unknown state, manual recovery, reconciliation |
| Manual operation policy | Staff actions when automation fails |
| Customer-facing finality wording | What customers may be told |
| Tenant and permission boundary | HQ/franchisee/store data isolation |

## 3. Vendor May Own

| Domain | Deliverable |
| --- | --- |
| Provider-specific adapter implementation | Code within approved repository paths only |
| Provider API mapping | Request/response translation to `000554` contract |
| Provider capability investigation | Matrix rows in `000553` with evidence |
| Provider-specific error mapping | Normalized error codes and messages |
| Provider-specific test results | Test reports and evidence samples |
| Provider-specific evidence samples | Completed `000558` packets |

## 4. Vendor Must Not Own

| Prohibited | Reason |
| --- | --- |
| Production credential storage | Security and compliance |
| Production DB access | Data protection |
| Supabase admin access | Platform security |
| RLS modification | Tenant isolation authority |
| Business policy decision | Internal product ownership |
| Payment/refund policy | Financial authority |
| Deployment approval | Human release gate |
| Customer data extraction | Privacy |
| Undocumented provider workaround | Support and audit risk |

## 5. POS Gateway Boundary

```text
[Store surfaces] → [Our POS Gateway / state machine] → [Vendor adapter] → [Provider API]
```

Vendor code lives **only** in the adapter layer. Gateway orchestration, source of truth, and recovery remain internal.

## 6. Handoff Boundary

Vendor delivers:

- adapter source in approved paths
- interface compliance proof
- capability matrix updates
- evidence samples
- known limitation document

Internal team owns merge, security review, staging validation, and production release.

## 7. Final Rule

Vendor implements provider adapters.
We retain order, payment, recovery, audit, and source-of-truth authority.
