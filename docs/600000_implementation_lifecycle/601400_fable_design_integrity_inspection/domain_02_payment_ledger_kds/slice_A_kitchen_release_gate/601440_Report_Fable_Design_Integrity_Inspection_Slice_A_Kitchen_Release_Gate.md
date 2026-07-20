Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `slice_A_kitchen_release_gate` — domain_02 Payment-Ledger-KDS authorization, "결제-KDS-주방릴리즈 정책" layer.
**Files inspected:** 22 policy MD (004010 group ×13, 004200 group ×9 — read in full via 3 passes) + 9 SQL migrations (0015/0036/0120/0084 reconciliation; 0056/0130 VAN; 0105 cash-receipt; 0018 agent-approvals; 0152 pickup/ready timing). JSON: none.

**Layer character (§6.2):** these 22 files are a **pre-implementation "정책/의도" planning layer**, authored **mid-June 2026**, and are **decoupled from runtime naming** — every state/event token is an abstract candidate (`KDS_ON_HOLD`, `PAYMENT_AUTHORIZED`, `ALCOHOL_KDS_HOLD_*`), explicitly "may be normalized later," and every file carries a "no-code boundary." The 9 SQL files in this slice are the **reconciliation/VAN/settlement** plumbing — **not** the KDS-release gate functions (those live in domain_01's already-inspected KDS SQL: 0028/0039/0151/0157/0166). So this slice pairs a June *policy* layer with July *settlement* SQL, and the release-gate implementation it describes sits in a third place.

**Four cross-references — resolved:**

**#1 — do 004016 / 004260 know the three real release paths (staff force-commit / provider capacity-gated / 0143 no-payment)?** **Partially — two of three, and the capacity axis is entirely missing.** The policy layer *does* branch release authority: 004270 names `MANUAL_RELEASE_UNDER_PAYMENT_UNCERTAINTY` (≈ staff/manager force) and `POSTPAID_POLICY_REQUIRED` (≈ 0143 no-payment opt-out; 004260 line 67 "unless the store policy explicitly allows postpaid operation"); 004020 §6.2 lists paid/postpaid/house-account/manager-approved variants. **But the provider capacity-gated path (`check_kds_capacity`/`bulk_commit`, 0166/601030) — the safety-critical gate the implementation centers on — appears in none of the 22 docs**, and the discovered force-commit-vs-capacity **asymmetry** (PAY-F02/KDS-F02) is not anticipated. 004016 §27 frames release as a single "when KDS release is allowed" question; 004260 §9/§23 as "verified webhook → automatic release." **Verdict on your either/or:** policy-first (June), implementation diverged (July) — *not* "정책이 나중에 이상화." Because the policy was explicitly abstract/candidate, implementation didn't violate a binding contract; it concretized the gate differently (capacity + dual-pipeline) and **the policy was never reconciled back**. (→ PKDS-F01)

**#2 — do the policies know the two confirm pipelines (`confirm_payment` vs `confirm_payment_from_provider`) — PAY-F02?** **No.** Zero of 22 docs name either function; all collapse to a single abstract "Payment Runtime / verified payment authority." They distinguish **automated(webhook) vs manual(fallback)** confirmation, but never two *programmatic* entry points (POS/staff vs provider/webhook/VAN). So PAY-F02's dual uncoordinated pipelines are **implementation drift with no policy sanction** — the design layer assumed one payment authority. (→ PKDS-F02)

**#3 — is 004013's alcohol KDS-hold implemented?** **No — doc-only, and self-declared deferred.** 004013 fully specifies an alcohol state machine (`ALCOHOL_KDS_HOLD_VERIFICATION/PAYMENT/STAFF_CONFIRMATION/MANAGER_APPROVAL/SERVICE_REFUSAL_REVIEW/CUSTOMER_INTENT/PROVIDER_MAPPING`, staff+manager approval, service-refusal, cancel-before/after-prep). **No `주류`/`alcohol`/age-verification exists in any migration** (repo-wide grep = 0); none of these states are in `chk_kds_status` (HOLD/CAPACITY_CHECKING/COMMITTED/COOKING/READY/SERVED/COMPLETED/CANCELLED/MANUAL_FALLBACK). 004013 §1/§2 self-declares "does not implement … no-implementation boundary," and 004016 §30 marks high-risk/alcohol "deferred unless explicitly approved." Definitively **미구현/문서만 존재**, and consistently self-marked so. (→ PKDS-F04)

**#4 — Batch-7 template-clone pattern?** **No.** The 004000 band is **not** part of the Batch-7 empty-clone mass. Each file carries genuinely distinct, file-specific content; there are shared *authoring-style skeletons* (a house style: Purpose → Scope → Core Principle → … → Readiness Check → Non-goals) but not identical bodies with only titles swapped. One intentional near-sibling pair (004240/004250 = recovery *operation* vs *evidence-packet* split, self-noted). Verified-clean. (Distinct from the runtime-flow bundle finding RUN-F01.)

**Finding totals:** 6 findings — **0 CRITICAL, 2 HIGH, 3 MEDIUM, 1 LOW**. No runtime risk in this slice itself (policies are inert; the settlement SQL is well-formed).
**Confidence:** HIGH (full reads + git-date + repo-wide SQL cross-check).

---

# 9.2 — Structural Defect Register

**PKDS-F05 — Stale cross-references + internal index number-mismap across the 004010 group.** `STRUCTURAL DEFECT` · **MEDIUM**
- 004010 "Related folders" points to legacy/placeholder paths (`03500_…`, `03800_…`, `03900_…`, `03400_provider_adapter_runtime/`) and two malformed `.md/`-trailing-slash paths.
- 004011 §26 references an old 5-digit POS-Gateway band (`05310…05400`); 004012 references **three** different numbering schemes for the same POS-gateway work (`014153–014159`, `06305/06310…`, `06010/06020…`) plus a "move to 06700 band" note.
- 004090 §12 / 004099 §3 index sibling docs as `04010/04020/…` (4-digit) while real files are `004010/004020/…`, and **mismap** them: 004099 says "04010 = KDS Handoff Candidate," but actual 004010 = Readme and 004020 = Handoff Candidate. The folder's own index cannot be trusted for navigation.
- Number-band reuse: `004010`/`004200` prefixes also exist under `990000_legacy_quarantine/605000_pos_gateway_package` (different "POS GW Runtime Flow" docs). **Confidence:** HIGH.

**PKDS-F06 — No lifecycle metadata on any of the 22 docs.** `STRUCTURAL DEFECT` / `CANONICAL AMBIGUITY` · **LOW**
None of the 22 files carry a Status / Stage / Owner / date / version header (unlike the 600000-series). Governance state is only implicit (Readiness Check, unchecked `[ ]` boxes). A reader cannot tell current-vs-historical-vs-draft from the documents themselves — only via git. Combined with zero SQL-object traceability (every identifier is a candidate pseudo-state), the policy layer cannot be validated against implementation by name. **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

**PKDS-F02 — The dual payment-confirmation pipeline (PAY-F02) has no policy sanction.** `DESIGN CONTRADICTION` / `MISSING DESIGN CONTRACT` · **HIGH**
Implementation exposes two uncoordinated confirmation RPCs (`confirm_payment` for POS/staff, `confirm_payment_from_provider` for webhook/VAN — PAY-F02 from domain_01). **All 22 policy docs assume a single "Payment Runtime authority"** and never name or anticipate two parallel programmatic entry points. Evidence: 004016 §4/§8–§10 (single provider-callback-centric authority); 004260 §4.2 "Payment Runtime" as the lone authority; 004270 §15 "verified payment authority" (singular). **Implication:** PAY-F02 is not a designed decision but undesigned drift — the two-pipeline coexistence was never authorized by, and conflicts with, the single-authority policy intent. **Owner decision required:** ratify one canonical confirmation entry (or an explicitly-designed two-pipeline contract) and update the policy layer. **Confidence:** HIGH.

---

# 9.4 — Canonical Ambiguity Register

**PKDS-F01 — June policy layer vs July implementation: divergent vocabulary, absent capacity-gate, never reconciled.** `CANONICAL AMBIGUITY` / `MISSING DESIGN CONTRACT` · **HIGH**
The policy layer (004016/004260/004013/004020…, mid-June) uses release/state vocabulary — `KDS_ON_HOLD → KDS_RELEASE_PENDING → KDS_RELEASED → KDS_IN_PREPARATION`, `PAYMENT_AUTHORIZED/PAYMENT_CAPTURED` — that matches **no** shipped object; the implementation (July) uses `HOLD → CAPACITY_CHECKING → COMMITTED → COOKING` and `payment_ledger.ledger_status ∈ {APPROVED,…}`. More importantly, the implementation's **capacity-gated release** (`check_kds_capacity`/`bulk_commit`, 0166/601030) — the actual safety mechanism — has **no policy contract anywhere in this layer**; the policies model paid/manual/postpaid branches but never the capacity axis. Because the policy predates and was never updated, a reader treating it as current design builds the wrong state machine. **This is the direct answer to cross-reference #1: policy-first, implementation diverged, policy stale.** **Owner decision required:** either update the 004000 policy layer to the shipped three-path + capacity-gated model, or mark it explicitly as superseded planning. **Confidence:** HIGH.

---

# 9.5 — MD–SQL–JSON Drift Register

*No name-level MD↔SQL drift is assertable here — the policy layer references zero real SQL objects (full decoupling, PKDS-F06). The substantive drift is conceptual (PKDS-F01/F02): the shipped capacity gate and dual pipeline are absent from the design intent. The slice's own SQL (0015/0036/0120/0084/0056/0105/0130/0018/0152) is well-formed reconciliation/VAN/settlement DDL+RPC with no observed defect; `confirm_payment_from_provider` is invoked from the VAN path (0056), and 0018 carries `KDS_CAPACITY_EVALUATED`/`KDS_RELEASE_OVERRIDE` agent-action types — the only place the capacity concept surfaces in this slice's SQL, and it is unreferenced by the policy layer.*

---

# 9.6 — Historical / Superseded Candidate Register

**PKDS-F04 — Alcohol KDS-hold: a complete paper state machine with zero implementation.** `MISSING DESIGN CONTRACT` / `OUT-OF-SCOPE OR FUTURE` · **MEDIUM**
004013 specifies a full alcohol hold/staff-approval/manager-approval/service-refusal lifecycle (§6 seven `ALCOHOL_KDS_HOLD_*` states, §11–§16 approval flows, §21–§24 service-refusal, §25–§29 cancel rules) that exists in **no** migration. It is self-declared deferred (§1/§2 no-implementation; 004016 §30 "remain deferred unless explicitly approved"). **Risk:** the richness could lead a future reader (or a patent/BM reviewer) to treat it as a buildable spec or an implemented capability. **Recommend:** keep tagged as FUTURE/deferred; if alcohol handling enters MVP, this becomes a design-ready input but needs schema reconciliation against the real `kds_tickets` (likely a `hold_reason` extension, not seven new states). **Confidence:** HIGH.

Also historical-adjacent: the entire June policy vocabulary (PKDS-F01) and the legacy-quarantine number-twins (PKDS-F05) are superseded-planning candidates, not current design.

---

# 9.7 — Runtime Risk Register

**None in this slice.** The 22 policy docs are inert (no-code boundary), and the 9 settlement/VAN/reconciliation migrations are well-formed with no observed phantom-column/constraint/permission defect. The runtime-adjacent concerns (capacity-gate absence, dual-pipeline) are design-layer gaps (PKDS-F01/F02), and the live release-gate risk was assessed in domain_01 (KDS-F02, PAY-F02). *(Verified-clean positives: no Batch-7 clones; alcohol correctly self-marked deferred; 004270 defines first-class payment-failure states + idempotent-webhook duplicate protection, consistent with the implementation's idempotency.)*

---

# 9.8 — Owner Decision Queue

1. **Reconcile or retire the June policy layer** — update 004000 policies to the shipped three-path + capacity-gated release and real state vocabulary, or stamp them "superseded planning." [PKDS-F01]
2. **Canonicalize payment confirmation** — decide one confirmation entry, or author an explicit two-pipeline (`confirm_payment` / `confirm_payment_from_provider`) design contract; retro-fit the policy. [PKDS-F02]
3. **Alcohol handling scope** — confirm deferred; if in-scope later, reconcile 004013's seven states against real `kds_tickets`. [PKDS-F04]
4. **Fix 004010-group navigation** — correct 004099/004090 index number-mismap and stale related-folder paths; add lifecycle metadata (Status/Owner) to the 22 docs. [PKDS-F05/F06]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (HIGH):** Author a *current* "Payment→KDS release" design doc that matches the shipped three-path + capacity-gate model and supersedes the June 004016/004260 intent. [PKDS-F01]
- **WP-2 (HIGH):** Payment-confirmation canonicalization / two-pipeline design contract (folds in PAY-F02). [PKDS-F02]
- **WP-3 (MEDIUM):** 004010-group structural remediation — index number-mismap, stale cross-refs, lifecycle metadata. [PKDS-F05/F06]
- **WP-4 (MEDIUM/FUTURE):** Alcohol KDS-hold reconciliation against real schema, if/when scoped. [PKDS-F04]
