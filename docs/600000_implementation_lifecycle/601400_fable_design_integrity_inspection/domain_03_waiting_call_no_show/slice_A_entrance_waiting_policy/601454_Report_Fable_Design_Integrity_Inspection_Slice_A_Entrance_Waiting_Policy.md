Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `domain_03 / slice_A_entrance_waiting_policy` — 4 MD (006410, 006510, 006520, 006530) + 1 SQL (0150). All read in full.

**Layer character (§6.2) — and a notable contrast:** all four docs are dated **2026-07-10**; `0150` is **07-11** and `0161` (no-show grace) is **07-16**. So unlike the mid-June planning corpora of D1/D2/D3, **this policy layer genuinely precedes its implementation by days** — a real design-then-build sequence. Its **referential integrity is also clean**: all five declared baseline dependencies (`014161`, `014162`, `014163`, `005011`, `006410`) resolve to real files, in sharp contrast to the 010xxx folders' dangling citations. The actual dependency chain is `014161 → 006410 → 006510 → 006520 → 006530` (note: 006410 is the **base**, not the tail — the ordering in the request is inverted).

**Five cross-references — resolved:**

**#1 — does 006520 describe the implemented HOLD→NO_SHOW_GRACE→auto-cancel path?** **No — it describes a *different* two-stage model, and the chain contradicts itself. Three incompatible models exist:**
- **006410 §7** (the base WorkPackage): a **single-stage** `No-Show`. No grace stage at all.
- **006520 §8/§11** (the policy): two-stage — `No-Show Pending` *("Party missed response window and **staff must confirm**")* → `No-Show`, with §11 requiring *"Staff reviewed or confirmed condition where required."* The grace sits on the **waiting session** and is **staff-gated**.
- **Implementation 0161**: the waiting session goes to `NO_SHOW` **immediately** (line 234); the grace lives on the **KDS ticket** (`hold_reason='NO_SHOW_GRACE'` + `hold_expires_at`, line 190) and expires **automatically** via `process_expired_no_shows` with `p_actor_type := 'SYSTEM', p_actor_id := null`.

The superficial "two stages ≈ three stages" resemblance masks a total model difference — **different object** (session vs KDS ticket), **different actor** (staff vs system), **different trigger** (confirmation vs timeout). Partial alignment does exist: `mark_no_show` is staff-attributed (`p_actor_type := 'STAFF'`), matching §11, and `no_show_grace_recovered` matches §12's reversal requirement. And 006520 is **closer to the implementation than patent 900101's immediate-cancel** — the patent remains the outlier. (→ EWP-F01)

**#2 — how does 006510 describe client↔server for waiting status?** **It states the exact rule the shipped client violates.** 006510 §8: *"web app and native app must share the same Store Runtime truth"* and — decisively — *"**The native app must not create a separate order state model, waiting model, or payment state model.**"* §12 then specifies a 12-row customer-facing status mapping (Waiting Created → Manual Review Required). The shipped `waiting_status_screen.dart` reads **only SharedPreferences**, calls **no RPC**, and displays **none** of those twelve states — a client-local waiting model, precisely what §8 forbids. This is a clean **"policy correct, implementation violates"** case, confirming WAIT-F09 at the policy level. Mitigating: the client carries an explicit intentional-deferral comment, so it is a known incomplete rather than an oversight — but the deferral leaves the app in a state the policy prohibits. (→ EWP-F02)

**#3 — is 0150 consistent with what these four docs require?** **Directionally yes, in coverage no — and it was not derived from them.** 0150 adds `'waiting'` to `chk_event_domain` per Human Decision A (2026-07-11). 006520 §21 demands ~**21** distinct waiting evidence events, which independently justifies a distinct domain. But the implementation records only **7**: `waiting_registered`, `waiting_called`, `waiting_cancelled`, `arrival_confirmed`, `customer_seated`, `no_show_marked`, `pre_order_registered` — roughly **one third**. Missing: queue reorder, notification attempt, customer response, no-show pending, no-show reversal, table assignment/correction, duplicate detection, merge/split, recovery, staff correction, manager approval, status display, incident linkage, daily closeout summary. Also **none of the four docs mentions `event_domain` or `chk_event_domain`** — 0150 was driven by `register_waiting`'s runtime need, not by this policy layer. (→ EWP-F04)

**#4 — how does 006530 relate to the WAIT-F01 preorder state-gate contradiction?** **It cannot adjudicate it — the contract is missing.** 006530 §10 lists seven preconditions for preorder→table linkage but **no order-state whitelist**; its nearest conditions are the abstract *"Order has not expired"* and *"Payment state allows continuation."* Meanwhile 006410 §8's 13-state preorder lifecycle contains **no `ORDER_CONFIRMED`** (nearest: `POS Accepted`, `Converted To Order`). So the shipped contradiction — `create_pre_order` writing `ORDER_CONFIRMED` while `bind_table_to_session` rejects it — has **no policy basis to resolve it**, and the implementation's token has no ancestor in this layer. (→ EWP-F03)

**#5 — Batch-7 clones?** **No.** Four genuinely distinct documents; 006410 is structurally a *WorkPackage* (§11 State Authority Matrix, §14 Merge/Split, §18 Integrated Pilot Requirements) versus three *Policies*. They share a house skeleton (Purpose → Scope → Baseline Dependency → Core Principle → … → Evidence → Acceptance → Out of Scope → Related → Final Rule) with real per-document content. The redundancy here is **conceptual, not cloning** — four overlapping customer-facing status tables (→ EWP-F05).

**Finding totals:** 6 findings — **0 CRITICAL, 2 HIGH, 3 MEDIUM, 1 LOW**.
**Confidence:** HIGH (all 4 docs + SQL read in full; implementation verified in 0150/0161).

---

# 9.2 — Structural Defect Register

**EWP-F06 — No lifecycle metadata; no SQL traceability (with a notable positive).** `STRUCTURAL DEFECT` · **LOW**
None of the four carries Status / Stage / Owner / date / version headers, and none references any real SQL object. **Positive, and worth recording:** every declared baseline dependency resolves to a real file — the first inspected policy set in this program with **clean referential integrity**. Minor: 005011 sits under `005010_customer_handoff_flow/` while cited bare, and the slice's stated dependency order inverts the real chain (006410 is the base). **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

**EWP-F01 — Three incompatible no-show models across the dependency chain and the implementation.** `DESIGN CONTRADICTION` · **HIGH**
006410 §7 (single-stage, no grace) vs 006520 §8/§11 (two-stage, **staff-confirmed**, grace on the **waiting session**) vs 0161 (session → `NO_SHOW` immediately; grace on the **KDS ticket**, expiring **automatically** by `SYSTEM` with a null actor). The base WorkPackage and the policy that depends on it disagree *before* the implementation is even considered. **Operational impact:** a staff member reading 006520 expects a confirmable "No-Show Pending" gate on the waiting queue; the system provides no such gate — it marks NO_SHOW at once and silently expires a kitchen-side hold. **Owner decision required:** designate the canonical no-show model, and decide whether grace belongs to the waiting session (policy) or the KDS ticket (implementation). **Confidence:** HIGH.

**EWP-F05 — Four overlapping customer-facing status tables with mutually inconsistent vocabularies.** `DESIGN CONTRADICTION` / `CANONICAL AMBIGUITY` · **MEDIUM**
006510 §12 (12 rows), 006520 §18 (13 rows), 006530 §18 (11 rows, table-scoped), 006410 §12 (11 rows). Three of them map the *same* waiting states under *different names* — "Waiting Created"/"Waiting Active" (006510) vs "Draft"/"Waiting" (006520) vs "Waiting" (006410). Compounding it, two waiting-lifecycle tables disagree outright: 006520 §8 lists **16** states, 006410 §7 lists **10**. There is no single canonical customer-facing vocabulary for a UI to implement — which is a plausible contributing cause of the client showing none of them (EWP-F02). **Confidence:** HIGH.

---

# 9.4 — Canonical Ambiguity Register

*(Folded into EWP-F01 — which no-show model governs — and EWP-F05 — which of four status vocabularies a client should render. Both are decidable only by Owner ruling; neither is resolvable from the documents.)*

---

# 9.5 — MD–SQL–JSON Drift Register

**EWP-F02 — The shipped waiting-status client violates 006510 §8's explicit prohibition.** `DOCUMENT–SQL DRIFT` / `IMPLEMENTATION DEFECT CANDIDATE` · **HIGH**
006510 §8 forbids a client-side waiting model and requires shared Store Runtime truth; `waiting_status_screen.dart` implements exactly a client-side model (SharedPreferences only, zero RPC), while the server's `get_waiting_status` sits unused. §12's 12-state customer-facing contract is entirely unimplemented. **Runtime impact:** the customer sees stale cached identifiers rather than live queue state — the "overpromising / misinformation" failure 006510 §19 and 006520 §19 both require incident linkage for. **Recommended next action:** wire `get_waiting_status` and render §12's mapping; the design contract already exists and needs no new authoring. **Confidence:** HIGH.

**EWP-F04 — Waiting evidence coverage is ~⅓ of the policy requirement, and one evidence path has a null actor.** `DOCUMENT–SQL DRIFT` / `MISSING DESIGN CONTRACT` · **MEDIUM**
7 of ~21 required evidence events are emitted (list above). Additionally, 006520 §21 requires *"Actor ID where applicable"* on every evidence record, but `process_expired_no_shows` writes with `p_actor_id := null` under `SYSTEM` — producing evidence rows with no actor for a customer-affecting state change, and giving 006520 §12's reversal-review requirement nothing to attribute. 0150 itself is **sound and correctly scoped** (a clean DROP/ADD widening consistent with 0140/0145/0146/0147, with the Human Decision recorded in-header); the gap is downstream coverage, not the migration. **Confidence:** HIGH.

---

# 9.6 — Historical / Superseded Candidate Register

Nothing superseded in this slice. 006410's single-stage no-show (§7) is the weakest link and is a **correction candidate** rather than a historical artifact — it is an active baseline dependency of 006510, so its disagreement with 006520 propagates forward.

---

# 9.7 — Runtime Risk Register

**EWP-F03 — The preorder→table state gate has no design contract, leaving WAIT-F01 unresolvable from policy.** `MISSING DESIGN CONTRACT` · **MEDIUM**
006530 §10 specifies seven abstract preconditions but never enumerates which order/session states permit table binding; 006410 §8's preorder lifecycle omits `ORDER_CONFIRMED` entirely. The shipped inconsistency (`create_pre_order` → `ORDER_CONFIRMED`, rejected by `bind_table_to_session`) is therefore an implementation-side invention with **no upper contract to arbitrate it** — and 600680 is currently repairing it without one. 006530 §10's own warning is apt: *"A preorder linked to the wrong table can create serious kitchen, payment, and customer dispute risk."* **Owner decision required:** define the allowed-state whitelist for preorder→table binding as an input to 600680. **Confidence:** HIGH.

*(No new live runtime blocker originates in this slice; 0150 is correct as written.)*

---

# 9.8 — Owner Decision Queue

1. **Canonical no-show model** — session-level staff-confirmed grace (006520) vs ticket-level automatic grace (0161); reconcile 006410 §7 either way. [EWP-F01]
2. **Preorder→table state whitelist** — supply the missing contract as input to 600680. [EWP-F03]
3. **Canonical customer-facing status vocabulary** — pick one of the four tables. [EWP-F05]
4. **Waiting evidence scope** — confirm the ~21-event requirement, or reduce 006520 §21 to what is actually required; decide actor attribution for SYSTEM-triggered transitions. [EWP-F04]
5. **Client wiring** — authorize connecting `get_waiting_status` to satisfy 006510 §8/§12. [EWP-F02]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (HIGH):** No-show model reconciliation across 006410/006520/0161 (folds in WAIT-F03). [EWP-F01]
- **WP-2 (HIGH):** Waiting-status client wiring — implement 006510 §12 against `get_waiting_status` (folds in WAIT-F09). [EWP-F02]
- **WP-3 (MEDIUM):** Preorder→table allowed-state contract, feeding 600680 (folds in WAIT-F01). [EWP-F03]
- **WP-4 (MEDIUM):** Waiting evidence-coverage expansion + SYSTEM-actor attribution policy. [EWP-F04]
- **WP-5 (MEDIUM):** Consolidate the four customer-facing status tables into one canonical mapping. [EWP-F05]

---

## §6.4 baseline update (entrance waiting policy layer)

- **This is the healthiest policy layer inspected so far:** authored 07-10, days *before* its implementation (0150 on 07-11, 0161 on 07-16), with all baseline dependencies resolving to real files. Design-then-build actually happened here.
- **But the chain self-contradicts on no-show** (006410 single-stage vs 006520 two-stage staff-confirmed) *before* reaching an implementation that uses a third model (ticket-level, automatic, SYSTEM actor).
- **006510 §8 is a live, violated contract** — it forbids exactly the client-side waiting model that shipped; the fix needs no new design.
- **006530 never defines the preorder→table state whitelist**, so WAIT-F01 has no upper authority to resolve it.
- **0150 is correct**; the deficit is that only 7 of ~21 required waiting evidence events are emitted, one of them with a null actor.
- **Not Batch-7 clones**; the redundancy is four competing customer-facing status vocabularies.

*(Read-only inspection complete — no repository files created, modified, moved, or deleted; no SQL executed; no git action, per operational-plan §4/§5/§13.)*