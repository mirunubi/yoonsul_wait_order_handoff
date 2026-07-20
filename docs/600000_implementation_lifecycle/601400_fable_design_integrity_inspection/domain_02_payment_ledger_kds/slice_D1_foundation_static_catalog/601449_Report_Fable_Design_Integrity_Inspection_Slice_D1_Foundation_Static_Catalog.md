Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `slice_D1_foundation_static_catalog` — domain_02, "Foundation Static Catalog Package" (010100).
**Files inspected:** 24 policy MD (all read in full via 3 passes). **No SQL in slice**; cross-checked against real migrations (0013/0014/0016/0052/0114) and the Flutter client to test the planning-vs-reality claims.

**Layer character (§6.2):** all 24 dated **2026-06-21**. This is the project's **product-line definition + coding-authorization gate** package: a static catalog of product lines (Catch Menu → Catch & Order → Mini Kiosk → Full Kiosk → Store Runtime → Admin Surface → Franchise OS → SaaS Platform), a capability/permission matrix, an implementation-priority ranking, and a five-step authorization chain (010153 spec packet → 010154 target map → 010155 authorization draft → 010156 approval gate → 010157 closure). Unusually, this folder **does** carry some lifecycle metadata (010106 and 010110 have real Catalog Header blocks) — but **zero date stamps anywhere** (repo-wide grep for `20\d\d-\d\d-\d\d` across all 24 returns nothing).

**Four cross-references — resolved:**

**#1 — is 010141 really unrelated to the cited "10141 SaaS Tenant Isolation"?** **Yes, entirely unrelated in content — but the citation itself is correct.** 010141 is purely a *Windows Installer Option Package and Local Runtime Configuration* policy (installer options, POS/KDS bridge services, printers, local cache, offline mode, update channels, firewall, secrets, device suspension). Its tenant mentions are incidental device-registration fields (`tenant_id`, "tenant plan", "tenant entitlement") — there is **no** cross-tenant containment design, no isolation beam. **The mechanism behind CRP-F04 is now fully resolved:** this folder's internal IDs run `0101NN → 100NN`, so physical `010141`'s own internal ID is **`10041`** (proved twice: 010141 cites predecessor `10040` = 010140 Domain Capability Control Plane; and 010142 cites predecessor `10041` = 010141). Meanwhile `010004_Policy_SaaS_Tenant_Isolation…` cites predecessor `10140`, making **its** internal ID **`10141`**. So the 010600 folder's *"10141 SaaS Tenant Isolation"* citation is **internally accurate** — it merely collides with a physically-named `010141` that is a different document. This is a **false-positive resolution**, not a dead link. (→ FSC-F03)

**#2 — how does 010110 define coding authorization, and is this the "trigger unclear" pattern?** **The trigger is defined with unusual precision — the pattern here is the opposite: the gate was never operative.** 010110 §3 requires authorization be *"explicit, narrow, and revocable"*; §26 sets `Default: CODING_NOT_AUTHORIZED` and closes *"This document itself does not set any package to allowed"*; §16 defines a 12-role reviewer matrix; §9/§10 require both allowed **and** prohibited operations; §18 expiration; §19 no-scope-drift. The chain then ends in **explicit non-approval**: 010155 §16 *"is not approved… `CODING_NOT_AUTHORIZED`"*; 010156 §14 *"Default: `APPROVAL_NOT_GIVEN`… This document sets no approval"*; 010157 §2 `Coding Status: CODING_NOT_AUTHORIZED` / `Runtime Status: RUNTIME_ENTRY_NOT_AUTHORIZED`, with **six deliberately open blockers**. 010156 §15 "No Silent Authorization Rule" even pre-empts inference from *"existence of this document · existence of target paths · existence of draft authorization · repeated 'next' commands"*, and §9 lists Korean phrases explicitly **insufficient** as approval (`다음`, `진행`, `시작`, `구현`, `키오스크 만들기`, `전체 진행`). **Yet the implementation had already shipped** — `0013`/`0014`/`0016` (orders, payment_ledger, kds_tickets) and `0052` (kiosk RPCs) on **2026-06-20**, `0114` (mini-kiosk pipeline) on **06-21** — the same days these prohibitions were authored. 010156 §8 even bans SQL as a permitted format (*"| SQL | Database mutation not authorized |"*, only Markdown/JSON allowed); 50+ migrations exist. (→ FSC-F01)

**#3 — did 010151 actually become the first implementation target?** **In name only; in substance it was inverted.** 010151 selected `CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001` as a **static/contract-only** candidate whose §7 explicitly excludes payment flow, payment verification, POS/KDS provider calls, provider webhooks, **"Android app implementation"**, and **"production database mutation"**; §2 sets `Payment Runtime: NOT_AUTHORIZED`, `KDS Runtime: NOT_AUTHORIZED`; §19 default-disables `payment.kiosk.enabled`, `kds.ticket_create.enabled`. 010149 §7 ranked priorities 1–6 as Static Registry → i18n Registry → Safe Projection Contract → Catch Menu Foundation → Mini Kiosk Surface → Device Profile, with §33 stating the first candidate *"should not be … payment, provider integration"*. **What actually shipped is rows 11–12** (POS/KDS adapter, payment mode) **while rows 1–6 were never produced**. Zero of the ten product-line docs mention Flutter, and "waiting" — the one shipped client feature — appears only as a *third-party provider category*. The kiosk half did get server code, but as **two overlapping, caller-less implementations**: `0052` (`catchmenu_pos`: `create_kiosk_session`/`submit_kiosk_order`/`get_kiosk_state`) and `0114` (`catchmenu_store`: `kiosk_configs`+`kiosk_sessions` tables, `bootstrap_kiosk`/`get_kiosk_menu`/`place_kiosk_order`/`get_kiosk_order_status`/`get_kiosk_dashboard`) — **neither has a single caller**, and MINI_KIOSK was later declared out-of-MVP (2026-07-13, slice_A 600220 §0-3). (→ FSC-F02, FSC-F05)

**#4 — Batch-7 clone pattern?** **No — with one recurring exception.** 23 of 24 are distinct-bodied documents on a shared house skeleton, forming a **genuine sequential chain** (21 of 24 cite a specific numbered predecessor, and those links resolve internally). **The exception: `010100_Readme` is a template shell** — 20 of its 24 role rows use the identical formula *"Defines the governed policy scope for {Title With Underscores Removed}"*, carrying zero information beyond the filename. This is the **same generated-Readme pattern found at `010600_Readme` in slice_C** — a recurring artifact class, not a one-off. (→ FSC-F06)

**Finding totals:** 6 findings — **0 CRITICAL, 2 HIGH, 3 MEDIUM, 1 LOW**. No runtime risk in the slice itself.
**Confidence:** HIGH (all 24 read in full + migration/client cross-check + git dates).

---

# 9.2 — Structural Defect Register

**FSC-F03 — Folder-wide 5-digit↔6-digit numbering drift producing false-positive resolutions.** `STRUCTURAL DEFECT` · **MEDIUM**
All 24 filenames are 6-digit (`010153`); **all internal IDs, blocker IDs, and cross-references are 5-digit** (`10053`, `BLOCKER-10053-*`, `09990`). **Not one internal reference in this folder resolves to a current filename.** The hazard is not dead links but **plausible-but-wrong resolution**: naive zero-padding sends `10141`→`010141` (Windows Installer, actual target `010004`), and `10020`/`10030`/`10040`→`010020`/`010030`/`010040`, which are **real but unrelated** files in `010010_store_runtime_room_framing/` (Store Room Framing Index, Order Intake Room Boundary, POS Handoff Room Boundary). Any automated link resolution binds silently to the wrong document. The `100xx→0101xx` rule also breaks at both ends (`10000`→`010106`, not `010100`; `10010`→`010110`). **Confidence:** HIGH.

**FSC-F06 — Template-shell Readme, no date stamps, title/body mismatch, foreign candidate path.** `STRUCTURAL DEFECT` · **LOW**
`010100_Readme` is a mechanically-generated filename→role table (20/24 formulaic rows) — the same class as slice_C's `010600_Readme`. **Zero date stamps** in any of the 24 files; only 010106 and 010110 carry real lifecycle header rows. `010154_Policy_Catch_Menu_Static_Target_Map.md` has a **title/body mismatch** — the filename was truncated during renumbering while the body still declares itself the *"Static Artifact Target File Map and Coding Authorization Draft Policy"*, and every sibling still cites it by the long name. All four authorization docs target a top-level `catalogs/product_line/…` tree that does not exist (correctly labelled candidate-only). **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

**FSC-F01 — The most elaborate authorization gate in the repo was never operative; implementation shipped in exactly the prohibited categories, on the same days.** `DESIGN CONTRADICTION` / governance · **HIGH**
- **Gate as designed:** 010110 (packet template, 12-role reviewer matrix, `Default: CODING_NOT_AUTHORIZED`, `Blocker Status: AUTHORIZATION_PACKET_REQUIRED_BEFORE_CODING`) → 010155 (*"is not approved"*) → 010156 (*"Default: `APPROVAL_NOT_GIVEN`"*, §15 No-Silent-Authorization Rule, §8 SQL format banned) → 010157 (`CODING_NOT_AUTHORIZED`, `RUNTIME_ENTRY_NOT_AUTHORIZED`, six open blockers, final line *"Until explicit approval is given, all work remains planning-only"*).
- **Reality:** `0013`, `0014`, `0016`, `0052` committed **2026-06-20**; `0114` on **06-21** — concurrent with the gate's authoring. 50+ migrations exist against a policy that bans SQL outright.
- **Operational impact:** the gate produced **zero artifacts and zero authorizations** while the real system was built beside it. It is an unusually rigorous control that never bound anything — governance theatre, not governance failure-by-ambiguity.
- **Correction to the working hypothesis:** the "approval trigger unclear" pattern does **not** apply here. The trigger is defined more precisely than anywhere else inspected. The defect is **bypass**, not ambiguity.
- **Owner decision required:** retire the chain as historical, or re-scope it to gate future work with a realistic relationship to the existing codebase. **Confidence:** HIGH.

**FSC-F02 — 010151's first-implementation-candidate is contradicted by what was actually built first.** `DESIGN CONTRADICTION` / `CANONICAL AMBIGUITY` · **HIGH**
010151 defined a contract-only candidate excluding payment, POS/KDS calls, DB mutation, and Android app work; 010149 §7 ranked payment/POS-KDS adapters **11th–12th** and §33 warned the first candidate must not be payment or provider integration. The shipped system is precisely rows 11–12 plus a Flutter app that appears in **none** of the planning docs, while rows 1–6 (static registry, i18n registry, safe-projection contract, Catch Menu foundation, Mini Kiosk surface, device profile) were **never produced**. **Impact:** the product-line planning package has essentially **zero intersection** with the delivered system — every shipped component sits on an explicit exclusion list. A reader using 010146/010147/010149/010151 to understand the product would reconstruct a system that does not exist. **Owner decision required:** re-baseline the product-line registry against the delivered system, or mark it superseded. **Confidence:** HIGH.

---

# 9.4 — Canonical Ambiguity Register

*(Primary entries folded into FSC-F02 — which product-line model is authoritative, planned or delivered — and FSC-F03 — which numbering scheme resolves. Cross-slice: this is the fourth consecutive slice where a mid-June planning layer and the delivered system describe different systems.)*

---

# 9.5 — MD–SQL–JSON Drift Register

**FSC-F05 — Two overlapping, caller-less kiosk implementations orphaned by a later scope reversal.** `IMPLEMENTATION DEFECT CANDIDATE` / `HISTORICAL` · **MEDIUM**
`0052` (2026-06-20, `catchmenu_pos`) and `0114` (2026-06-21, `catchmenu_store`) implement **the same capability twice** — session creation (`create_kiosk_session` vs `bootstrap_kiosk`), order submission (`submit_kiosk_order` vs `place_kiosk_order`), state query (`get_kiosk_state` vs `get_kiosk_order_status`/`get_kiosk_dashboard`) — in **different schemas**, one day apart. **Neither has any caller** in SQL or the Flutter client (grep = 0). MINI_KIOSK was subsequently declared out-of-MVP (2026-07-13). This is the "duplicate engine + zero real callers" pattern seen in domain_01's takeout RPCs, now in the kiosk line. **Owner decision required:** designate one canonical kiosk implementation or retire both pending a real kiosk client. **Confidence:** HIGH.

*(No MD↔SQL name-level drift is otherwise assertable: the folder references **zero** real SQL objects — its single use of the word "SQL" is prohibitive.)*

---

# 9.6 — Historical / Superseded Candidate Register

**FSC-F04 — 010105 is a stale, never-applied, misfiled repo-wide migration plan targeting an abandoned numbering scheme.** `HISTORICAL OR SUPERSEDED CANDIDATE` · **MEDIUM**
A 105-row mechanical rename/move plan for the whole `10000`–`10717` band, banner-marked *"no apply performed"*. Its proposed targets (`docs/10000_…/10000_foundation_static_catalog_package/`, `docs/10700_security_trust_and_menu_intelligence/`) **do not exist and cannot** — the repo moved to 6-digit folders and renamed that package to `010700_security_trust_and_smart_order_control`. Its §9 *"Recommendation: PROCEED with apply phase"* is dead. Internal defects: ceiling leakage **miscounted** (declares 4 out-of-ceiling files, table carries 5 — `10713`–`10717`); §8 contains **three competing renumbering schemes** in one 15-row table (`10609A`–`10609O` → `10609_01`–`10609_15` → `10611`–`10625`), with the real destinations elsewhere entirely (`010451`, `010605`). It also documents two malformed source filenames, one containing an embedded `## 1. Purpose` heading. **It is the artifact of the renumbering that caused FSC-F03, and it was never applied.** Also **misfiled** — its scope is the whole repo, but it sits in a folder owning `010100~010199`. **Recommend:** mark superseded, not pending. **Confidence:** HIGH.

Also historical-adjacent: the entire authorization chain (FSC-F01) and the product-line registry (FSC-F02) are superseded-planning candidates.

---

# 9.7 — Runtime Risk Register

**None originates in this slice** (inert, unauthorized planning; no SQL). The one runtime-adjacent item is the orphaned duplicate kiosk code (FSC-F05), which is dormant — no caller can invoke it.

**Valuable content worth preserving (verified-clean positives):** 010140 §11's capability-gating formula (`FeatureAllowed = ProviderCapability AND TenantFeaturePlan AND StoreRuntimeConfiguration AND PolicyGate AND RuntimeFeatureFlag AND AuthorityBoundary AND EvidenceRequirement AND AuditRequirement`) with ~80 named flag keys, and — notably — **010106 §12's twelve blocking invariants, including `POS_ACCEPTED_NOT_PAYMENT_CONFIRMED` and `KDS_COMPLETED_NOT_SETTLED`. These are the documented origin of the KDS-payment coupling constraint traced through domain_01** (the "payment 승인 ≠ KDS 릴리즈" principle whose patent-authority source was reported missing as KDS-F07). This slice supplies that missing provenance.

---

# 9.8 — Owner Decision Queue

1. **Authorization-chain disposition** — retire 010110/010153–010157 as historical, or re-scope to gate future work realistically. [FSC-F01]
2. **Product-line re-baseline** — reconcile 010146/010147/010149/010151 with the delivered system, or mark superseded. [FSC-F02]
3. **Kiosk canonicalization** — pick one of the two kiosk implementations or retire both. [FSC-F05]
4. **Numbering remediation** — resolve the 5↔6-digit drift repo-wide (this is now the third slice reporting it: CRP-F04, FTR-F04, FSC-F03); mark 010105 superseded rather than pending. [FSC-F03/F04]
5. **Preserve the invariants** — promote 010106 §12 and 010140 §11 into a current design doc before the folder is retired. [9.7]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (HIGH):** Governance reconciliation — decide the standing of the never-operative authorization gate and document the actual approval path used by the shipped system. [FSC-F01]
- **WP-2 (HIGH):** Product-line registry re-baseline against delivered reality. [FSC-F02]
- **WP-3 (MEDIUM):** Kiosk canonicalization / retirement of duplicate caller-less RPCs. [FSC-F05]
- **WP-4 (MEDIUM):** Repo-wide numbering remediation (folds in CRP-F04, FTR-F04, FSC-F03); retire 010105. [FSC-F03/F04]
- **WP-5 (LOW):** Replace generated Readmes (010100, 010600) and fix the 010154 title/body mismatch. [FSC-F06]

---

## §6.4 baseline update (foundation static catalog layer)

- **This folder authorized nothing and produced no artifact.** Its terminal state is `CODING_NOT_AUTHORIZED` / `RUNTIME_ENTRY_NOT_AUTHORIZED` with six open blockers — while the real system was built concurrently (06-20/21) in exactly the categories it prohibited. Treat it as **historical planning**, never as an approval record.
- **Do not use 010146/010147/010149/010151 as the product model** — the delivered system intersects them at ~zero points.
- **Numbering:** internal IDs are 5-digit (`0101NN → 100NN`); naive zero-padding produces **wrong-but-plausible** matches (`10141`→Windows Installer; real target `010004`). This closes the CRP-F04 mechanism.
- **Kiosk:** backend exists twice (`0052`, `0114`), has no client and no callers, and is out of MVP scope.
- **Preserve:** 010106 §12 invariants (origin of the KDS-payment coupling rule) and 010140 §11 capability formula.

*(Read-only inspection complete — no repository files created, modified, moved, or deleted; no SQL executed; no git action, per operational-plan §4/§5/§13.)*