Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `domain_03 / slice_B_store_legal_boundary` — 2 MD (004120 limited-quantity/waiting-preorder, 010802 refund/no-show legal SOP) + 2 SQL (0162 dining-table admin, 0048 table management). All read in full; cross-checked against 0010 (`dining_tables` DDL), 0014 (`chk_ledger_status`), 0025 (`bind_table_to_session`), 0098 (refund pipeline), 0115 (`seat_waiting_customer`, `pre_order_while_waiting`), 0161.

**⚠️ Correction to my slice_D3 report (FSD-F02).** I stated there that *"`REFUND_PENDING` appears in no design document anywhere in the repo."* **That was wrong** — it was an over-generalization from checking only 010412 and 010320. `REFUND_PENDING` appears in **at least 10 design documents**: 005410, 008070, 010451, 010452, 010602, **010802 §4 (this slice)**, 010814, 010907, 012051, 014035. This materially reframes the refund diagnosis (→ SLB-F01).

**Four cross-references — resolved:**

**#1 — how does 010802's legal no-show SOP connect to the broken refund pipeline?** **Two distinct answers, and the exposure is narrower than feared but real.** First, the vocabulary: 010802 §4's *Refund And Cancellation State Registry* contains `REFUND_PENDING` verbatim, alongside `REFUND_APPROVED`/`REFUND_REJECTED`/`PARTIAL_REFUND_PENDING`/`REFUND_PROVIDER_PENDING`/`REFUND_COMPLETED`/`RECONCILIATION_REQUIRED`. So the shipped `0098` tokens are **consistent with the dominant design vocabulary**, not inventions. Second, the legal exposure: 010802 §14 states *"Waiting no-show usually should not involve payment unless deposit exists"* — so **plain waiting no-show (this domain) does not depend on the refund pipeline at all**. The exposure is confined to **deposit-bearing flows** (§12 reservation deposit, §15 pickup, §16 group reservation) and to `NO_SHOW_REVERSED` / `NO_SHOW_RECOVERY_GRANTED`, which require a refund to reverse a forfeiture — and that path raises **23514** and can never reach `confirm_refund`. Separately, 010802's evidence machinery (§23's 19-field packet, §33's 24 audit events) is unimplemented regardless of the crash. (→ SLB-F01, SLB-F04)

**#2 — does 004120's "waiting preorder" concept match `pre_order_while_waiting()`?** **No — 004120's central control is entirely absent from the implementation.** There are **zero** `limited_quantity_*` tables in any migration, and `pre_order_while_waiting` (0115) contains **no quantity, sold-out, `menu_status`, remaining-count, or hold check whatsoever** (grep returns nothing). 004120 §11's core rule — *"Waiting preorder for limited item requires hold or store confirmation"* — and §15's *"Exhausted limited item must behave like sold-out for commitment"* (block POS handoff, block KDS handoff) have no counterpart. The waiting-preorder path can therefore over-promise limited items with no control, which is precisely the risk 004120 §34 enumerates. Compounding it, the function that would host the check is itself defective (600680 phantom columns, undeployed). (→ SLB-F03)

**#3 — how do 0162/0048 connect to `seat_waiting_customer()`/`bind_table_to_session()`?** **They don't — and that is the finding.** `seat_waiting_customer` (0115) touches `dining_tables` **zero times**; it updates only `order_sessions` (`seated_at`). The **only** writer of `dining_tables.current_session_id` is `bind_table_to_session` (0025:427); 0048 and 0162 merely *read* it as a guard. Consequently, when a waiting party is seated via `seat_waiting_customer` alone, `current_session_id` stays **NULL**, and **all four occupancy guards silently fail open**:
- `get_table_floor_map` (0048) reports the table as **unoccupied** with a party seated;
- `update_table_status` can mark an occupied table **AVAILABLE** (its "session_still_active" guard never fires);
- `set_dining_table_active` (0162) can **deactivate** an occupied table;
- `capacity_reduction_blocked_active_session` (0162) never fires.

This compounds with **WAIT-F01**: `bind_table_to_session` — the sole linker — is the very function that rejects `ORDER_CONFIRMED`, so a waiting customer holding a pre-order **cannot be linked at all**. Notably, 0162's own header documents the problem and scopes it out: *"Do not modify 0110/0115, including the **known seat_waiting_customer() crash**."* (→ SLB-F02)

**#4 — Batch-7 clones?** **No.** Only two documents, in visibly different authoring traditions: 004120 uses the escaped-number style (`1\. Purpose`) with Korean/English parallel text and a `04xxx`/`03xxx` sibling list; 010802 uses the 010xxx house skeleton (Purpose → Core Position → … → Runtime Deferral → Validation Checklist → Relationship To Previous Documents → Final Rule) with a `107xx` internal chain. Genuinely distinct content. (→ SLB-F06)

**Finding totals:** 6 findings — **0 CRITICAL, 2 HIGH, 3 MEDIUM, 1 LOW**.
**Confidence:** HIGH (all documents and SQL read in full; every claim verified against DDL/constraints).

---

# 9.2 — Structural Defect Register

**SLB-F06 — Numbering mismatch; unverified forward references; with notable SQL-quality positives.** `STRUCTURAL DEFECT` · **LOW**
010802 carries internal 5-digit IDs (predecessor `10721`; references `10410`/`10420`/`10430`/`10610`/`10620`/`10630`/`10640`/`10680`/`10701`/`10715`) against physical `010802` — the same mismatch class as CRP-F04/FSC-F03/SCP-F04/FSD-F03; it also "prepares" `10723`–`10726`, unverified. 004120 references old-band siblings (`04100`/`04110`/`04130`/`03100`/`03500`/`04000`) and closes §33 with *"Actual schema may be designed later."*
**Positives worth recording:** both SQL files are clean — 0162 and 0048 reference **only real `dining_tables` columns** (verified against 0010's DDL: `table_status`, `current_session_id`, `occupied_since`, `last_cleaned_at`, `qr_code`, `nfc_tag_id`, `kds_device_id`, `did_device_id`, …), **no phantom columns**; 0162 has explicit REVOKE/GRANT, exception handlers routing to `append_audit_record` with **valid** `p_decision` values (`COMPLETED`/`FAILED` ∈ `chk_audit_decision`), and a recorded Human approval (601124 §10, 2026-07-17). **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

**SLB-F01 — The refund-state defect is a *schema* outlier, not an implementation invention (corrects FSD-F02).** `DESIGN CONTRADICTION` / `DOCUMENT–SQL DRIFT` · **HIGH**
Corrected evidence: `REFUND_PENDING` appears in ≥10 design documents and `REFUND_FAILED` in 6 (004015, 004016, 005221, 008070, 010320, 010452). The shipped `0098` refund pipeline therefore uses **the dominant, repo-wide design vocabulary**. The genuine outliers are (a) **`chk_ledger_status` (0014)** — an 8-value CHECK that never admitted the pending/failed states the design corpus consistently prescribes, and was never widened; and (b) **010412's `REVERSAL_*`** rename, which diverged from that same corpus. **Revised diagnosis:** this is not "implementation drifted from design" but **"schema was written without reconciling the design corpus, and one room doc then renamed the vocabulary a third way."** **Owner decision required:** widen `chk_ledger_status` to admit the design-corpus states (lowest-friction, aligns schema to ≥10 documents), **or** rewrite 0098 to the 8 shipped values and retire `REFUND_PENDING` corpus-wide. **Confidence:** HIGH.

**SLB-F05 — A fourth no-show model; the legal SOP contradicts the operational policy, and the implementation followed the legal one.** `DESIGN CONTRADICTION` · **MEDIUM**
010802 §13 defines `NO_SHOW_WARNING_SENT` → `NO_SHOW_GRACE_RUNNING` → `NO_SHOW_CONFIRMED` (+ `NO_SHOW_PENALTY_APPLIED`/`NO_SHOW_REVERSED`), and §14's waiting flow is explicit: *"4. Grace timer starts. 5. Customer fails to arrive within configured time. **6. Waiting entry is auto-cancelled.**"* This **auto-cancel-after-grace** model matches the implementation (0161) but **contradicts slice_A's 006520 §8/§11**, which requires a **staff-confirmed** `No-Show Pending` transition. The corpus now holds four incompatible models: 006410 (single-stage), 006520 (staff-confirmed two-stage), **010802 (auto-cancel after grace)**, and 0161 (session-immediate `NO_SHOW` + ticket-level grace auto-expired by `SYSTEM`). **Owner decision required:** rule which governs — the legal SOP or the operational policy. **Confidence:** HIGH.

---

# 9.4 — Canonical Ambiguity Register

*(Folded into SLB-F01 — three competing refund vocabularies with the schema as a fourth constraint — and SLB-F05 — four no-show models across legal, operational, and implementation layers. Neither is resolvable from the documents; both require an Owner ruling.)*

---

# 9.5 — MD–SQL–JSON Drift Register

**SLB-F03 — 004120's limited-quantity control is wholly unimplemented on the waiting-preorder path.** `MISSING DESIGN CONTRACT` · **MEDIUM**
Zero `limited_quantity_records`/`limited_quantity_holds`/`limited_quantity_events` tables exist; `pre_order_while_waiting` performs no quantity, sold-out, `menu_status`, or hold check. Absent: §5's 8 limited states, §6's 8 quantity types, §9/§10's hold record and 8 hold statuses, §11's waiting-preorder gate, §15's exhaustion blocking (POS + KDS handoff), §26's 13 audit events, §27's 9 failure codes, §28's 10 support signals. 004120 §32 lists a modest MVP subset (manual limited state, manual remaining note, exhausted state, preorder block) — **even that is absent**. **Operational impact:** a waiting customer can pre-order a limited item with no hold and no confirmation, producing exactly §34's enumerated risks (guest disappointment, impossible POS item, impossible KDS prep ticket, refund/support burden). **Confidence:** HIGH.

**SLB-F04 — 010802's legal evidence machinery is unimplemented, and its reversal path sits on the broken refund pipeline.** `MISSING DESIGN CONTRACT` / `RUNTIME BLOCKER CANDIDATE` (scoped) · **MEDIUM**
§23's Refund Evidence Packet requires 19 fields including `notice_id`, `notice_version_id`, `notice_shown_at`, `acknowledged_at`, `refund_state`, `decision_actor` — there is no notice table, no notice versioning, and no evidence-packet structure. §33's 24 audit events (`REFUND_NOTICE_SHOWN`, `NO_SHOW_WARNING_SENT`, `NO_SHOW_PENALTY_APPLIED`, `DEPOSIT_FORFEITED`, `REFUND_DISPUTE_OPENED`…) are unemitted. §29's 14 admin settings (waiting grace time, pickup hold time, deposit tiers) have no configuration surface. **Scope limit (important):** §14 exempts ordinary waiting no-show from payment, so this domain's core flow is **not** blocked by the refund crash; the exposure is **deposit-bearing** no-show (§12/§15/§16) and any `NO_SHOW_REVERSED`/`NO_SHOW_RECOVERY_GRANTED` requiring a forfeiture reversal — which cannot execute. **Legal consequence:** deposit forfeiture without the §23 notice-version evidence would be difficult to defend in a dispute, and §35's anti-pattern *"applying no-show penalty without timestamp evidence"* is currently unavoidable. **Confidence:** HIGH.

---

# 9.6 — Historical / Superseded Candidate Register

Nothing superseded. 004120 is a **live but unimplemented** contract (correction candidate, not history). 010802 §38's "prepares" list (`10723`–`10726`, incl. *No-Show Deposit Penalty And Customer Recovery SOP*) indicates the deposit/penalty SOP that would govern SLB-F04's exposure **was never written**.

---

# 9.7 — Runtime Risk Register

**SLB-F02 — Waiting-originated seating never links the physical table, silently disabling all four occupancy guards.** `IMPLEMENTATION DEFECT CANDIDATE` / `RUNTIME BLOCKER CANDIDATE` · **HIGH**
`seat_waiting_customer` (0115) writes only `order_sessions.seated_at` and never touches `dining_tables`; the sole writer of `current_session_id` is `bind_table_to_session` (0025:427). A party seated through the waiting flow therefore leaves the table record unlinked, so 0048's floor map reports it **unoccupied**, `update_table_status` will mark it **AVAILABLE**, and 0162 will **deactivate** it or **reduce its capacity** — every guard in both migrations depends on the NULL field. **Compounding:** WAIT-F01 means `bind_table_to_session` rejects `ORDER_CONFIRMED`, so a pre-ordering waiting customer cannot be linked even if the caller tries. **Runtime impact:** double-seating, lost table-occupancy truth, and KPI/turnover data corruption — directly contradicting 006530's requirement that *"Seating must create or link a table session"* and that a seated party *"must not lose its waiting, preorder, order, payment, or customer link references."* **Known and deferred:** 0162's header names *"the known seat_waiting_customer() crash"* as an explicit non-goal. **Owner decision required:** make seating link the table (either inside `seat_waiting_customer` or by mandating a `bind_table_to_session` call), which requires WAIT-F01/600680 to land first. **Confidence:** HIGH.

---

# 9.8 — Owner Decision Queue

1. **Refund-state reconciliation** — widen `chk_ledger_status` to the design-corpus vocabulary, or rewrite 0098 to the 8 shipped values and retire `REFUND_PENDING` corpus-wide. [SLB-F01]
2. **Seating↔table linkage** — decide where the link is made; sequence behind WAIT-F01/600680. [SLB-F02]
3. **Limited-quantity MVP scope** — implement 004120 §32's minimal subset, or formally accept that waiting preorder has no quantity control. [SLB-F03]
4. **Deposit/no-show legal exposure** — decide whether deposit-bearing no-show ships before the refund path and §23 evidence packet exist; author the missing `10726` SOP. [SLB-F04]
5. **Canonical no-show model** — legal SOP (auto-cancel) vs operational policy (staff-confirmed); reconcile 006410/006520/010802/0161. [SLB-F05]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (HIGH):** Refund-state reconciliation across `chk_ledger_status`, 0098, and the ≥10 design docs (supersedes/refines the SCP-F02 and FSD-F02 recommendations). [SLB-F01]
- **WP-2 (HIGH):** Seating→table-linkage fix, sequenced after 600680. [SLB-F02]
- **WP-3 (MEDIUM):** Limited-quantity MVP for waiting preorder (folds into 600680's scope decision). [SLB-F03]
- **WP-4 (MEDIUM):** No-show notice + evidence-packet implementation; author `10726`. [SLB-F04]
- **WP-5 (MEDIUM):** Canonical no-show model ruling across four documents (extends the slice_A WP-1). [SLB-F05]

---

## §6.4 baseline update (store/legal boundary)

- **Refund vocabulary — corrected:** `REFUND_PENDING`/`REFUND_FAILED` are the **dominant design-corpus tokens** (≥10 and 6 docs). The outliers are `chk_ledger_status` (8 values, never widened) and 010412's `REVERSAL_*`. My FSD-F02 framing is superseded by SLB-F01.
- **Waiting no-show does not depend on the refund pipeline** (010802 §14); deposit-bearing no-show does, and that path is broken.
- **Seating does not link tables.** `seat_waiting_customer` never writes `dining_tables`; only `bind_table_to_session` does — and WAIT-F01 blocks it for pre-order sessions. All occupancy guards in 0048/0162 fail open.
- **Limited-quantity control does not exist** in any migration; `pre_order_while_waiting` has no quantity or sold-out check.
- **0162/0048 are clean SQL** — real columns only, proper grants, valid audit decisions, recorded Human approval. **Not Batch-7 clones.**

*(Read-only inspection complete — no repository files created, modified, moved, or deleted; no SQL executed; no git action, per operational-plan §4/§5/§13.)*