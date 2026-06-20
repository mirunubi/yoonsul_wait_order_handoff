# 000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md

## 1. Purpose

Defines responsibility and authority boundaries for POS Gateway, order/payment runtime, and provider adapters.

## 2. Our System Owns

| Domain | Authority |
| --- | --- |
| Order authority model | What constitutes an accepted order |
| Payment authority model | Authorization, capture, void, refund semantics |
| Cancellation authority | When and how cancel is valid |
| Refund authority | Policy and approval paths |
| Source of truth decision | Per-state ownership across surfaces |
| State machine | Normalized lifecycle (`000803`) |
| Retry policy | When and how retry is allowed |
| Idempotency policy | Key generation and scope |
| Reconciliation policy | Ledger vs provider matching |
| Recovery policy | Unknown state and manual paths |
| Manual operation policy | Staff actions during failure |
| Evidence and audit rules | Required logs and retention |
| Tenant and permission boundary | HQ/franchisee/store isolation |
| Customer-facing finality wording | What customers may be told |

## 3. Provider Adapter Owns

| Domain | Scope |
| --- | --- |
| Provider-specific API mapping | Request/response to `000802` contract |
| Request/response translation | Field-level mapping |
| Provider-specific error normalization | `AdapterError` mapping |
| Provider-specific health check | Connectivity and credential validity |
| Provider-specific retry feasibility | What provider API allows |
| Provider-specific capability reporting | Matrix rows in `000804` |
| Provider-specific evidence capture | Payload refs per `000808` |

## 4. Provider Does Not Own

- Our business policy
- Our refund policy
- Our operational source of truth
- Our customer notice policy
- Our manual recovery policy
- Our production deployment decision

## 5. Runtime Boundary

```text
[Kiosk/KDS/DID/CMS/Staff] → [POS Gateway + state machine] → [Provider adapter] → [Provider API]
```

Gateway orchestration and authority stay **above** the adapter layer.

## 6. Final Rule

Adapters translate; we decide authority, state, and recovery.
