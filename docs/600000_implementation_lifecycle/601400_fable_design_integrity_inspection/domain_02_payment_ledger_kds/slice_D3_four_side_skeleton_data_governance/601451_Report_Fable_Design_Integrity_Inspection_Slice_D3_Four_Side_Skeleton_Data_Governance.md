Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `slice_D3` — domain_02: 010300 Four-Side Platform Skeleton (7 docs) + 010500 Data Governance Room (14 docs) = **21 docs, no SQL**.
**Cross-checked against:** `chk_ledger_status` (0014), `chk_kds_status` (0016), refund RPCs (0037/0098), `current_actor_id()` (0022), and the 010400/010600 sibling rooms.

**Layer character (§6.2):** two structurally different artifacts. **010300 is the genuine upper skeleton** — an unbroken chain `10100→10110→10120→10130→10140→10150` in which each document cites its predecessor and names its successors, partitioning the platform into four "sides" (B = Store Runtime/POS/KDS, C = Payment/Settlement/Refund, D = CMS/i18n/AI/Data Governance) and deferring detail to later "rooms." **010500 is one of those rooms** (internal IDs map 1:1 to filenames, `010530` = `10530`; its index cites `10480`, the tail of the Financial Trust range).

**Five cross-references — resolved:**

**#1 — are 010310/010320 the upper skeleton of slices A and B?** **Yes, definitively — and the descent is documented from both ends.** 010405 (Financial Trust Room Index) names **`10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`** and `10150` as its ancestors; 010505 (Data Governance Index) names `10100`/`10130`/`10150`. Going forward, 010350 §12 lays out a room-decomposition roadmap and §13/§14 **pre-name the exact rooms** — "KDS Ticket Room", "**Refund Review Room**", "**Refund Execution Room**", "Payment Verification Room". **Correction to my D1/D2 reports:** git commit dates here are *bulk-import* dates, not authoring dates — 010300 shows commit 06-21 yet is provably upstream of 010400 (commit 06-18). My earlier "authored the same day as the implementation" phrasing overstated what commit dates prove; the accurate claim is *first committed*. The D1/D2 findings' substance is unaffected (those gates still terminate in `CODING_NOT_AUTHORIZED`), but the concurrency inference is weaker than I stated. (→ FSD-F03)

**#2 — how does 010320 relate to the refund crash?** **A third distinct pattern: vocabulary drift across a superseded layer.** Three-layer trace:

| Layer | Vocabulary | `REFUND_PENDING` | `REFUND_FAILED` |
|---|---|---|---|
| **Skeleton** 010320 §8 (`10120`) | 11 `REFUND_*` states; 5-stage separation (request→review→approval→execution→reconciliation); self-declared *"skeleton states only"*, and 010350 §3: **"State name is not database schema"** | No (`REFUND_EXECUTION_PENDING`) | **Yes — exact literal** |
| **Room** 010412 (`10430`, the mandated successor) | 19 **`REVERSAL_*`** states — vocabulary deliberately renamed | **0** | **0** |
| **Shipped** 0098 | writes both into `ledger_status` | **Yes** | **Yes** |

`REFUND_FAILED` is conventional design vocabulary across six policy docs (004015, 004016, 005221, 008070, 010320, 010452); **`REFUND_PENDING` appears in no design document anywhere in the repo.** So the implementation **skipped the room-level `REVERSAL_*` design that superseded the skeleton**, lifted `REFUND_FAILED` from a layer that explicitly disclaimed schema status, **invented `REFUND_PENDING`**, collapsed the mandated five stages into two calls, and bound the result to a CHECK constraint that admits neither. Neither "policy right / implementation wrong" nor "wholly unrelated." (→ FSD-F02)

**#3 — do 010551/552/553 bear on the caller-authorization gap?** **No — zero coverage, and the silence is structurally revealing.** A grep across all 14 files for `JWT`, `sub`, `auth.uid`, `SECURITY DEFINER`, `current_actor`, `staff.id`, `actor_id`, `spoof`, `impersonat` returns **no matches**. These documents address a **different layer entirely** — perimeter/network threat detection and containment orchestration (an IDS/SOAR tier *outside* the database): 010551's catalog is `SYN_FLOOD_SUSPECTED`/`SQL_INJECTION_PATTERN_SUSPECTED`/`BRUTE_FORCE_LOGIN_SUSPECTED`; 010552's eight "immune" layers are detection→correlation→containment→review→learning, with **no layer performing authorization**; 010553 is a patent-framing document ("does not replace patent attorney review"). RLS appears only as a prohibition on the AI agent and as a deferral item; 010553 §18's *"RLS must be deny-by-default"* is immediately followed by *"No schema is authorized by this document."*

**The sharpest finding is 010554.** It builds a four-layer audit mesh (DB trigger → view projection → OS log → nightly batch) that **correlates every audit row on `actor id` / `staff/actor id`** (§11/§12) — yet **never specifies how the server derives a trustworthy actor identity**. §10 treats "DB mutation occurred without audit trigger" as an incident candidate but has **no analogue for "audit row recorded an actor id the server never verified."** The entire audit design rests on precisely the assumption the shipped system cannot satisfy. (→ FSD-F01)

**#4 — governance theatre again?** **No — categorically different, and honest about it.** Neither folder has a structured gate: **no Catalog Header, no `Coding Status`/`CODING_DEFERRED` token, no approval chain, no blocker list** (contrast 010100/010200, which have all four). Governance is prose-only: *"This document is planning-only. / It does not authorize coding."* plus a `Runtime Deferral` section. 010350 §18 **describes** the schema an authorization packet must have without instantiating one. 010580 is explicit: *"This closure confirms room framing only. **It does not confirm readiness for coding**"* and *"**Room closure is not implementation readiness.**"* These are **pure reference skeletons/rooms** — D1/D2 built gates that never opened; D3 never claimed to build one. (→ FSD-F06)

**#5 — Batch-7 clones?** **No — distinct authored content on a shared skeleton**, with repeated invariant sentences that 010350 §10 *deliberately mandates* ("These invariants must be repeated in future implementation packets"). **Three exceptions:** `010520` (i18n) is a **221-byte pure template shell** whose entire body is one generic sentence; `010300_Readme` is mechanically generated (5/7 rows a fixed frame); and `010500_Readme` is mechanically generated **and broken** — its description column repeats each file's own path, and 010505's row wrongly shows the Readme's own path. (→ FSD-F05)

**Finding totals:** 6 findings — **0 CRITICAL, 2 HIGH, 2 MEDIUM, 2 LOW**.
**Confidence:** HIGH (all 21 read in full + SQL/constraint/cross-folder verification).

---

# 9.2 — Structural Defect Register

**FSD-F03 — The skeleton's own successor roadmap is wrong on every entry.** `STRUCTURAL DEFECT` · **MEDIUM**
010350 §12 forecasts the room decomposition as `10200` Store Room Framing, `10300` Financial Room Framing, `10400` **Data Governance** Room Index, `10500` **Cross-Room Plumbing** Index, `10600` Runtime Candidate Selection And Authorization Queue. **Reality:** `10400` became **Financial Trust**, `10500` became **Data Governance**, `10600` became **Cross-Room Plumbing**, and "Runtime Candidate Selection" was never written. The map is off by one room slot throughout and was never reconciled. Compounding it, 010300's internal IDs (`10100`–`10150`) don't match its filenames (`010305`–`010350`), while 010500's map 1:1 — **two different numbering conventions inside one sibling pair**. **Confidence:** HIGH.

**FSD-F05 — One empty shell, two generated Readmes (one self-referentially broken), no headers, no dates.** `STRUCTURAL DEFECT` · **LOW**
`010520_Policy_i18n_Message_Key_And_Human_Visible_Text_Boundary.md` is **221 bytes** — a single generic sentence; its actual i18n content exists only as summaries inside 010505 §6 and 010580 §8. `010500_Readme`'s Document List repeats each file's path as its own description and mis-assigns 010505's row. Neither folder carries a Catalog Header or **any date stamp**. Note also 010500_Readme §5: *"package organized by root markdown rename/move apply wave"* — which **contradicts D1's 010105 banner** (*"no apply performed"*), indicating that migration plan was partially applied after all. **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

**FSD-F02 — Refund vocabulary drifted out of a deliberately-non-schema skeleton, bypassing the room design that superseded it.** `DESIGN CONTRADICTION` / `IMPLEMENTATION DEFECT CANDIDATE` · **HIGH**
Full trace above. The skeleton (010320 §8) supplied `REFUND_FAILED` while explicitly disclaiming schema authority (010350 §3) and forbidding refund execution (010320 §26); the room (010412) superseded it with a wholly renamed `REVERSAL_*` vocabulary containing neither token; the shipped `0098` used the skeleton's token, invented `REFUND_PENDING`, collapsed five mandated stages into two calls, and stored an intermediate stage in `ledger_status` — whose CHECK (0014) admits neither value, producing **23514** on write and an unreachable `confirm_refund` branch. **Owner decision required:** adopt the room's `REVERSAL_*` model, or widen `chk_ledger_status`; either way designate one canonical refund vocabulary across skeleton/room/schema. **Confidence:** HIGH.

**FSD-F04 — The payment→KDS late-binding gate has no upper-design ancestor.** `MISSING DESIGN CONTRACT` · **MEDIUM**
010310 — the Store Runtime/POS/KDS skeleton — **never contemplates payment gating KDS**. It defines only a three-state handshake (`KDS_TICKET_PENDING`/`_ACCEPTED`/`_REJECTED`) and asserts the *reverse* direction ("KDS completed is not settled"). The shipped nine-state machine (`HOLD`/`CAPACITY_CHECKING`/`COMMITTED`/…) and `payment_ledger.kds_release_authorized` share **zero tokens** with it. So the late-binding gate — the system's most safety-critical mechanism — is a **post-skeleton invention with no upper-design ancestor**, which corroborates the domain_01 finding (KDS-F07) that 특허1/특허2 have no documented design authority. The only related invariants live in D1's 010106 §12 / D2's 010226 §13 (`POS_ACCEPTED_NOT_PAYMENT_CONFIRMED`, `KDS_COMPLETED_NOT_SETTLED`). **Confidence:** HIGH.

---

# 9.4 — Canonical Ambiguity Register

*(Folded into FSD-F02 — three competing refund vocabularies (`REFUND_*` skeleton / `REVERSAL_*` room / shipped CHECK) with no designated canonical — and FSD-F03 — two numbering conventions and a wrong successor map.)*

---

# 9.5 — MD–SQL–JSON Drift Register

Neither folder references a single real SQL object (verified by grep). All identifiers are speculative candidates explicitly disclaimed ("No schema is authorized by this document" — 010553 §18). The substantive drift is FSD-F02 (refund vocabulary) and FSD-F04 (KDS gate absent from the skeleton). Also relevant to the earlier 여전법 question: **the word "card" appears exactly once in all 14 data-governance files** — 010550 §12, listing "card/payment detail" among things to strip before embedding. 010530's masking taxonomy defines masking *classes* (`PAYMENT_REFERENCE_MASKED`, `PROVIDER_PAYLOAD_REDACTED`) but **no PAN/BIN/last-4 rule, no PCI reference, no 여전법 citation** — consistent with FTR-F02.

---

# 9.6 — Historical / Superseded Candidate Register

010320's `REFUND_*` state inventory is **superseded** by 010412's `REVERSAL_*` model and should not be used as a naming source (it already leaked once — FSD-F02). 010350's §12 successor roadmap is **stale** (FSD-F03). `010520` is an unfilled placeholder. **Worth preserving:** 010554's four-layer audit design and 010552's layered-detection architecture are substantive, implementable-in-principle work — provided the actor-identity foundation is supplied first (FSD-F01).

---

# 9.7 — Runtime Risk Register

**FSD-F01 — The audit mesh presupposes a trustworthy actor identity the system cannot produce; no document in the corpus owns caller authorization.** `MISSING DESIGN CONTRACT` · **HIGH**
010554 correlates every audit layer on `actor id`/`staff/actor id` (§11/§12) and requires append-only capture (§4/§13/§23), but never defines how that identity is derived or verified; its "missing audit" incident catalog (§10) has no entry for an unverified actor. Meanwhile the security suite (010551/552/553) addresses only perimeter/network detection and is silent on identity (0 matches for JWT/`sub`/`auth.uid`/`SECURITY DEFINER`). **Combined with CRP-F02** — where 010600 stated the abstract principle but never named the mechanism — **caller authorization now has no design owner anywhere in the inspected corpus**, while the shipped `current_actor_id()` returns an auth-user id with no mapping to `staff.id`. **Runtime consequence:** audit rows can record actor ids the server never verified, so the audit trail's non-repudiation property is unsound at its base. **Owner decision required:** assign ownership of the session→staff identity contract before building the audit mesh. **Confidence:** HIGH.

*(The refund breakage FSD-F02 is a live 23514 defect but remains latent — zero callers.)*

---

# 9.8 — Owner Decision Queue

1. **Actor-identity contract ownership** — assign it; it is currently unowned across 010500, 010600, and the implementation. Prerequisite for 010554's audit mesh. [FSD-F01]
2. **Canonical refund vocabulary** — `REVERSAL_*` (room) vs `REFUND_*` (skeleton) vs the shipped CHECK; then repair 0098. [FSD-F02]
3. **KDS late-binding design authority** — document the gate that has no skeleton ancestor (with KDS-F07). [FSD-F04]
4. **Skeleton roadmap reconciliation** — correct 010350 §12's room numbers, or mark superseded. [FSD-F03]
5. **Fill or retire `010520`**; repair the two generated Readmes; resolve the 010105 "no apply performed" vs 010500 "apply wave" contradiction. [FSD-F05]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (HIGH):** Caller-identity/session→staff contract workpacket — folds in CRP-F02 and unblocks 010554. [FSD-F01]
- **WP-2 (HIGH):** Refund vocabulary canonicalization + 0098 repair (folds in SCP-F02). [FSD-F02]
- **WP-3 (MEDIUM):** Document the payment→KDS late-binding gate as design authority (folds in KDS-F07). [FSD-F04]
- **WP-4 (MEDIUM):** Skeleton/room numbering reconciliation — now spanning CRP-F04, FTR-F04, FSC-F03, SCP-F04, FSD-F03; treat as one repo-wide workpacket. [FSD-F03]
- **WP-5 (LOW):** Fill 010520; regenerate 010300/010500 Readmes. [FSD-F05]

---

## §6.4 baseline update (four-side skeleton + data governance)

- **010300 is the real architectural root** — 010400 and 010500 descend from it explicitly. Use it to understand *intent*; do not use its state tokens as schema (it says so itself: "State name is not database schema").
- **Commit dates ≠ authoring dates** in this repo (bulk import). The internal-ID chain is the reliable ordering. This tempers, but does not overturn, the D1/D2 governance findings.
- **Three refund vocabularies exist**; the shipped one is the only invalid one, and it borrowed from the superseded layer.
- **The payment→KDS gate has no ancestor** in the skeleton — it is an unowned post-hoc invention.
- **Caller authorization is unowned corpus-wide**, and 010554's audit design silently depends on it.
- **Governance character:** unlike D1/D2, these folders never erected an approval gate — a cleaner, more honest posture.

*(Read-only inspection complete — no repository files created, modified, moved, or deleted; no SQL executed; no git action, per operational-plan §4/§5/§13.)*