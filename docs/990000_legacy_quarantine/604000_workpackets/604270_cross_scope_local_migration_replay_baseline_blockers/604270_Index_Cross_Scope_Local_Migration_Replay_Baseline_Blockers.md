# 604270_Index_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

## 604270 Cross-Scope Local Migration Replay Baseline Blockers

Status:
- 604271 ImpactScope: Draft (Stage 1 investigation complete)
- Implementation: Not approved
- Human Approval: Not approved
- Codex implementation: Not authorized

Workpacket name:
- **604270 Cross-Scope Local Migration Replay Baseline Blockers**

Workpacket type:
- **Cross-Scope Baseline Migration Replay Blocker** (investigation / design-prep only)

Triggered by:
- **604260** Supabase local migration replay attempt (`604268` Addendum — Supabase Local Migration Replay Attempt)
- **604269** Audit Required Fix: runtime evidence blocked by pre-existing baseline migrations

Scope:
- **Investigation only** — no SQL, migration, or runtime edits in this workpacket stage

Implementation status:
- **Not approved**

Approval status:
- **Not approved** (604276 Human Approval not created)

---

## Affected Baseline Files Under Investigation

| File | Role |
| --- | --- |
| `sql/migrations/0035_verify_schema.sql` | Schema verification DO block — replay failed at apply |
| `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` | Toss webhook processor RPC — replay failed at apply |

Out of 604260 implementation scope. Out of 604266 Approval boundary.

---

## Downstream Blocked

| Consumer | Blocked effect |
| --- | --- |
| **604260 runtime closeout** | `604268` remains `PARTIAL — BLOCKED_BY_BASELINE_MIGRATION_REPLAY`; `604269` Not Ready |
| **604250 resume** | Must not resume automatically (`604256`, `604306`) |
| **0142 runtime verification** | Full valid sequential replay did not reach `0142_patch_toss_mvp_payment_intent_binding.sql` |
| **Clean Supabase local replay** | Stops at 0035 (first); 0038 confirmed on continued inspection |
| **Future CI / new developer DB bootstrap** | Sequential apply through baseline chain unreliable until blockers resolved |

---

## Document Map

| # | Document | Status |
| --- | --- | --- |
| 604270 | `604270_Index_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md` (this file) | Active |
| 604271 | `604271_ImpactScope_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md` | Draft |

Future documents (not created):
- 604272 Overview
- 604273 Logic
- 604274 TestPlan
- 604275 ChangeContract
- 604276 Human Approval
- 604277 Module
- 604278 Verification
- 604279 Audit

---

## Preliminary Classifications (604271 detail)

| Blocker | Classification | Summary |
| --- | --- | --- |
| 0035 | **B** | Verification-only; must be rewritten/fixed for clean sequential replay |
| 0038 | **A** | One-line SQL syntax blocker; minimal fix candidate (policy: edit vs forward patch TBD) |

---

## Authorization Boundary

```text
This index does not authorize implementation.
604270 does not authorize 604250 resume, 604260 closeout, 604310, or 0142 edits.
0035/0038 fixes require separate 604275 ChangeContract and 604276 Human Approval.
```

Next allowed step:
- Claude drafting **604272 Overview / 604273 Logic / 604274 TestPlan / 604275 ChangeContract**
