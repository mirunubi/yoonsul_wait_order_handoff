# 604280_Index_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

## 604280 Cross-Scope 0042 Delivery Order Intake Baseline Replay Blocker

Status:
- 604281 ImpactScope: Draft (Stage 1 investigation complete)
- Implementation: Not approved
- Human Approval: Not approved
- Codex implementation: Not authorized

Workpacket name:
- **604280 Cross-Scope 0042 Delivery Order Intake Baseline Replay Blocker**

Workpacket type:
- **Cross-Scope Baseline Migration Replay Blocker** (investigation / design-prep only)

Triggered by:
- **604279** Audit — `PASS_WITH_NEW_BASELINE_BLOCKER`; 0035/0038 resolved; **0042** newly exposed
- **604278** Supabase local clean replay — failed at `0042_create_delivery_order_intake_rpc.sql` after `0041` applied

Scope:
- **Investigation only** — no SQL, migration, or runtime edits in this workpacket stage

Implementation status:
- **Not approved**

Approval status:
- **Not approved** (604285 Human Approval not created)

---

## Affected Baseline File Under Investigation

| File | Role |
| --- | --- |
| `sql/migrations/0042_create_delivery_order_intake_rpc.sql` | Delivery order intake RPC — replay failed at apply (syntax `:=` in UPDATE SET) |

Out of **604260** implementation scope. Out of **604276** / **604277** Approval boundary. Out of **604270** originally approved file set.

---

## Downstream Blocked

| Consumer | Blocked effect |
| --- | --- |
| **Full clean sequential replay to 0142** | Replay halts at **0042**; migrations **0043–0142** not applied on clean DB |
| **604260 runtime closeout** | `604268` / `604269` remain blocked; 0142 runtime evidence still unavailable |
| **604250 resume** | Must not resume automatically (`604256`, `604306`, `604279`) |
| **Future CI / new developer DB bootstrap** | Sequential apply through baseline chain stops at 0042 |
| **Delivery order intake runtime** | `intake_delivery_order` never created when 0042 fails; downstream callers (`0057`, `0074`) would reference missing function at runtime |

---

## Document Map

| # | Document | Status |
| --- | --- | --- |
| 604280 | `604280_Index_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md` (this file) | Active |
| 604281 | `604281_ImpactScope_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md` | Draft |

Future documents (not created):
- 604282 Overview
- 604283 Logic
- 604284 TestPlan
- 604285 ChangeContract
- 604286 Human Approval
- 604287 Module
- 604288 Verification
- 604289 Audit

---

## Preliminary Classification (604281 detail)

| Blocker | Classification | Summary |
| --- | --- | --- |
| 0042 | **A** (preliminary) | Single-line SQL syntax blocker — `result_payload :=` in UPDATE SET; same defect class as pre-fix **0038** |

---

## Relationship to Prior Workpackets

| Workpacket | State relevant to 604280 |
| --- | --- |
| **604270** | 0035/0038 blockers resolved under 604276/604277; full replay-to-0142 goal not achieved |
| **604279** | Audit confirms 0042 as new separately-scoped blocker |
| **604260** | Not ready for closeout; 604278 does not close it |
| **604250** | Resume not allowed |
| **604310** | Not implemented; 604316 not created |

---

## Final Rule

604280 records investigation only. It does not authorize implementation, does not close **604260**, and does not authorize **604250** resume. **604289 Audit** will be required after future implementation and verification.
