Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `slice_03_kds_did` — Customer Handoff / KDS + DID layer.
**Files inspected:** 45 workpacket Markdown (KDS 36, DID 9 — read in full via 3 parallel read-only passes) + 16 SQL migrations (DDL 0016; RPCs 0028/0029/0039/0043/0070/0079/0080/0107/0117; corrections 0143/0151/0155/0156/0157/0166). JSON: none.

**Domain reconstruction (§6.2):** KDS is a **mature, well-corrected** stack (0016 `kds_tickets` → capacity/commit 0028/0039/0151 → cooking 0029/0157 → no-payment pilot 0143 → canonical orchestration 0166), fronted by a **reorganized-but-under-indexed** workpacket set (600410/600420/600440/600520/601020). **DID is thin and partly broken**: only an overload-cleanup workpacket (600820→0155) is complete; the event-reactive workpacket (600810) is an **empty placeholder**, so **no DID state machine exists in any doc**, and the patent's event-based kiosk/DID auto-control (900160/900161) is unbuilt/unreferenced.

**Four carried-forward cross-references — resolved:**
- **#1 (three payment→KDS paths):** the **KDS gate functions are correct** — `commit_kds_ticket`/`bulk_commit` require `payment_ledger.kds_release_authorized=true`, and `start_cooking` (0157) is fail-closed on a null ledger. The asymmetry (PAY-F02) lives on the **payment** side (`release_kds_after_payment` force-commits via direct UPDATE instead of calling the gate). The KDS **docs** only partially represent this: 601020 documents staff-vs-provider as two parallel pipelines but frames it as "staff commits / **provider incomplete** (stuck at HOLD)," not "staff bypasses the gate / provider is gated"; 600410 doesn't engage the paths.
- **#2 (no-show grace):** **consistent** at the state-machine level — `chk_kds_status` has no `NO_SHOW_GRACE` state (grace = `hold_reason`, ticket stays HOLD), and the grace functions live in 0161 (waiting slice). But **no-show is entirely absent from the KDS docs** — the KDS-ticket no-show behavior is documented only in the waiting layer (600630), a cross-domain doc gap even though 0161 mutates `kds_tickets`.
- **#3 (audit_decision):** **clean.** The KDS layer uses only `APPROVED/COMPLETED/FAILED/CANCELLED`, all in `chk_audit_decision`'s 11-value set. The PAY-F01 pattern is **not** present.
- **#4 (0143 exception):** the KDS docs reference 0143 (601020, as a null-ledger source + forbidden-edit file) but its **policy flags remain undocumented** — and 0157's fail-closed `start_cooking` means **0143-released tickets can reach COMMITTED but never COOK** (`kds_release_ledger_missing`); the no-payment pilot is neutered downstream.

**Cross-slice closures observed:** the "confirm_payment inert / 4 phantom `payment_ledger` columns" URGENT item (601027) was subsequently fixed by **0158** (600550); WAIT-F14 (`orders.requested_pickup_at` missing) was fixed by **0152** (600720).

**Finding totals:** 9 findings — **1 CRITICAL, 4 HIGH, 3 MEDIUM, 1 LOW** (+ verified-clean: audit_decision, no-show state-machine consistency, KDS gate correctness).
**Confidence & limits:** MD/SQL HIGH; crash items are CANDIDATES (Fable cannot execute). Verification rigor across these workpackets is itself inconsistent (Claude-only vs dual vs triple) — see KDS-F08.

---

# 9.2 — Structural Defect Register

**KDS-F03 — Systemic index gaps, including the reorg workpacket that failed to index itself.** `STRUCTURAL DEFECT` · **HIGH**
600520 and 601020 physically exist in `600400_kds_did_implementation/` but are **missing from both `600400_Readme` Subfolder Map and `600402_NavigationMap`** (601020 also missing from `600401_ChangeHistory`), despite both being Stage-6 ACCEPT. The `domain_folder_reorganization` workpacket (600520) — created specifically to fix index integrity — **never added itself** to the indexes: the exact "silent index gap" failure it existed to close, now recurring. On the DID side, both `600800_Readme`/`600802_NavigationMap` are stale post-ACCEPT: NavigationMap lists **neither** 600810 nor 600820 ("No accepted DID implementation workpacket is currently listed") while the Readme still labels 600820 "Stage 2" (it is Stage 6 ACCEPT). Same class as PAY-F04/WAIT-F02 — the domain navigation cannot be trusted. **Confidence:** HIGH.

**KDS-F09 — Minor structural drift.** `STRUCTURAL DEFECT` · **LOW**
Number-band vs folder mismatch (`600400_Readme` claims band `600400–600499` while housing 600520/601020, self-acknowledged for 601020); `600621_Overview` describes the 0043/0117 overloads **backwards** and is left uncorrected (traceability hazard flagged by 600821); migration 0156 (`did_device_edid_mapping`) is unreferenced in any DID doc; a stray "51 vs 47" backfill-count inconsistency inside `600524_ChangeContract`; 600510 lacks Module/Verification/Audit (documented lifecycle gap). **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

**KDS-F02 — 0143 no-payment pilot is neutered by 0157's fail-closed `start_cooking`; the multi-path model is under-documented in the KDS layer.** `DESIGN CONTRADICTION` · **HIGH**
0143 releases a ticket HOLD→COMMITTED **without** payment (leaving `payment_ledger_id` null), but 0157 made `start_cooking` fail-closed on a null `payment_ledger_id` (`kds_release_ledger_missing`) — so a no-payment ticket can be COMMITTED yet **never reach COOKING**. 601022 §2.3 records this as a "known, Human-approved trade-off," but it means the no-payment feature is functionally dead downstream, and neither the trade-off nor the governing policy (`payment_required_for_kds_release`, `can_override_kds`) is documented in the KDS index. Combined with the payment-vs-KDS framing mismatch (#1), the KDS layer does **not** carry a coherent account of the three-path release model. **Owner decision required:** decide whether the no-payment pilot should also bypass `start_cooking`, and document the policy. **Confidence:** HIGH.

**KDS-F07 — Patent-label / canonical-source ambiguity.** `CANONICAL AMBIGUITY` / `MISSING DESIGN CONTRACT` · **MEDIUM**
SQL comments carry "특허1: 결제 승인 ≠ KDS 자동 릴리즈" and "특허2" labels that appear in **no** 900xxx doc (601021 §7/§8: 0 grep hits) — an internal design concept spanning multiple functions with no design-authority source (echoes CH-F11/PAY-F10: the capacity/late-binding mechanism is undocumented in the patent package). Separately, `READY_TO_COMMIT` vs `COMMITTED` was a live two-name ambiguity across 13 files/46 occurrences (resolved by 600440), and a field-name drift persists between design authority and schema (`900161` uses `estimated_minutes`; real column is `estimated_minutes_snapshot`). **Confidence:** HIGH.

---

# 9.4 — Canonical Ambiguity Register

*(The primary canonical-ambiguity items are folded into KDS-F07 (patent labels / READY_TO_COMMIT) and KDS-F03 (which index is authoritative when Readme, NavigationMap, ChangeHistory, and the filesystem disagree). The `confirm_payment` vs `confirm_payment_from_provider` dual-pipeline ambiguity is PAY-F03, cross-referenced by 601020 §10.)*

---

# 9.5 — MD–SQL–JSON Drift Register

**KDS-F06 — Phantom-column pattern recurs across KDS/takeout; some fixed, some tracked-open.** `DOCUMENT–SQL DRIFT` · **MEDIUM**
Confirmed instances: **kds_tickets** `is_late`/`priority_score` (fixed by 600420 → inline computation + real `priority`); `store_settings.kds_capacity_threshold_per_station` → `_per_zone`; `orders.request_memo` → `memo` and `reconciliation_cases.case_severity`/`'INVESTIGATING'` → `severity`/`'UNDER_INVESTIGATION'` (out-of-scope in 600420, later fixed by 600910). The **600404 roadmap** tracks three still-**OPEN** clusters: `point_ledger` (`point_type`/`point_amount`→`transaction_type`/`points_change`), `coupons.discount_pct` phantom, and `order_items` (`unit_price`→`unit_price_snapshot`, `subtotal`→`item_amount`, `is_kds_required`→`is_kds_required_snapshot`, **`display_order`→no replacement**). This is the same layer-wide phantom class as WAIT-F05/CH-F01/PAY-F06 — reinforcing the recommendation for a **single repo-wide phantom-column audit**. **Confidence:** HIGH.

---

# 9.6 — Historical / Superseded Candidate Register

**KDS-F05 — DID event-reactive layer is unbuilt; the patent's event-based DID auto-control is not implemented.** `MISSING DESIGN CONTRACT` / `OUT-OF-SCOPE OR FUTURE` · **HIGH**
600810 (`kds_did_event_reactive_implementation`) contains only `.gitkeep` — zero content. No DID state machine, event-trigger model, or realtime-channel definition exists in any workpacket doc; the only DID logic is `get_did_display_state` (0117) + a broken `bootstrap_did_app` (KDS-F01). The patent docs 900160/900161 (event-based kiosk/DID auto-control, slice_04 CH-F14 vision cluster) are unreferenced and unbuilt. **Impact:** the DID "auto-control" capability the patent describes has no implementation contract — a reader must not treat 900160/900161 as current. **Confidence:** HIGH.

Also historical: the dropped legacy overloads (`get_did_display_state` 3-param 0043; and the payment/waiting siblings) are correctly retired — all independently non-functional — but their **source bodies remain in the older migrations** (the WAIT-F04 source-vs-migration residue extends here).

---

# 9.7 — Runtime Risk Register

**KDS-F01 — `bootstrap_did_app` (0117) selects phantom `did_devices` columns → real DID hardware bootstrap crashes.** `RUNTIME BLOCKER CANDIDATE` · **CRITICAL**
`bootstrap_did_app()` SELECTs `show_waiting_count`, `show_cms_content`, `supported_locales`, `default_locale` — **none exist** in the live `catchmenu_store.did_devices` (23 real columns). Surfaced at 600820's E2E Verification (`ERROR: column "show_waiting_count" does not exist`), cross-referenced to `601010_cms_device_content_routing_architecture` but **not fixed**. **Runtime impact:** any real DID device booting via `bootstrap_did_app` raises `42703` — the DID hardware path is broken. Mitigant: pre-operation (no live DID hardware yet). **Recommend:** prioritize a `did_devices` column-reconciliation workpacket. **Confidence:** HIGH (schema mismatch, observed at Verification).

**Cross-refs (resolved, recorded for closure):** the `confirm_payment` (0098) 4-phantom-column crash that made 601020's Slice-1 fix "unreachable in production" (601027 URGENT) was **subsequently fixed by 0158** (600550); `orders.requested_pickup_at` (WAIT-F14) was **fixed by 0152** (600720). The KDS/DID no-payment interaction (KDS-F02) and the DID event-reactive gap (KDS-F05) are the remaining KDS-layer runtime-adjacent concerns.

---

# 9.8 — Owner Decision Queue

1. **DID `did_devices` phantom columns** — approve a reconciliation workpacket; decide the `601010` CMS-device-routing dependency. [KDS-F01]
2. **No-payment pilot vs fail-closed cooking** — decide whether 0143-released tickets should bypass `start_cooking`'s ledger check, and document the 0143 policy in the KDS index. [KDS-F02]
3. **DID event-reactive scope** — decide whether 600810 / the patent event-based DID auto-control (900160/900161) is MVP or future; if future, mark it so. [KDS-F05]
4. **Index integrity** — back-index 600520/601020 (KDS) and 600810/600820 (DID); reconcile the number-band claim. [KDS-F03]
5. **Migration-number authorization** — ratify the 0154→0155 substitution that bypassed the ChangeContract stop-and-report guard (see 9.4/KDS-F04 below), and set a rule for number-conflict re-approval. [KDS-F04]
6. **Verification-rigor standard** — set a uniform independent-verification requirement (Claude-only workpackets accepted here as LOW-risk exceptions). [KDS-F08]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (CRITICAL):** `did_devices` phantom-column reconciliation (unblock `bootstrap_did_app`). [KDS-F01]
- **WP-2 (HIGH):** 0143 no-payment ↔ 0157 fail-closed reconciliation + document the no-payment policy. [KDS-F02]
- **WP-3 (HIGH):** Index/NavigationMap/ChangeHistory back-index for KDS (600520/601020) and DID (600810/600820). [KDS-F03]
- **WP-4 (HIGH):** Governance remediation — record the 0154→0155 number-change re-approval; correct 600820 ChangeContract/TestPlan/token. [KDS-F04]
- **WP-5 (HIGH/scope):** Decide + document DID event-reactive layer (600810) and patent 900160/900161 status. [KDS-F05]
- **WP-6 (MEDIUM):** The single repo-wide phantom-column audit (order_items/point_ledger/coupons/did_devices/customer-app/refund) spanning KDS-F06 + WAIT-F05 + CH-F01 + PAY-F06. [KDS-F06]
- **WP-7 (MEDIUM):** Patent-authority reconciliation — document 특허1/특허2 (payment≠KDS-release, capacity late-binding) in 900xxx. [KDS-F07]

---

# 9.4 — Canonical Ambiguity Register *(governance addendum)*

**KDS-F04 — DID 600820 migration-number authorization gate was bypassed.** `CANONICAL AMBIGUITY` / governance · **HIGH**
`600824_ChangeContract` §1 authorized **only** `0154_drop_get_did_display_state_legacy_overload.sql` and mandated: if 0154 is occupied, implementation "must stop and report … Do not silently choose another number without explicit confirmation." 0154 **was** occupied (by `0154_drop_mark_payment_uncertain…`); the work shipped as **0155** — but no Module/Verification/Audit records the mandated stop-and-report or fresh Human confirmation, and the ChangeContract §1/§8, TestPlan §6, and the signed approval token (`…_FOR_0154_…`) still reference the wrong migration. **Impact:** the artifact that Human "approved" (0154) is not the artifact that shipped (0155); the explicit authorization guard was not honored. **Owner decision required:** ratify retroactively and correct the docs. **Confidence:** HIGH.

*(KDS-F08 — verification-rigor inconsistency + approval-vs-Draft status drift + doc-vs-code shipped `0151` + self-verify/audit chains — is a MEDIUM governance cluster spanning 600410/600520/601020/600820; recorded here and in the Owner queue rather than as a separate register entry.)*

---

## §6.4 baseline update (KDS/DID layer)

- **KDS gate (correct, enforce-side):** `commit_kds_ticket`/`bulk_commit_kds_tickets` require `payment_ledger.kds_release_authorized=true` (which itself requires ledger `APPROVED`); `start_cooking` is fail-closed on null `payment_ledger_id`. The payment→KDS asymmetry is a **payment-side** issue (`release_kds_after_payment` force-commit), not a KDS-gate defect.
- **KDS state machine:** `HOLD/CAPACITY_CHECKING/COMMITTED/COOKING/READY/SERVED/COMPLETED/CANCELLED/MANUAL_FALLBACK` (canonical after 600440's `READY_TO_COMMIT→COMMITTED` unification). No-show = `hold_reason='NO_SHOW_GRACE'` on a HOLD ticket (no new state).
- **No-payment exception (KDS-F02):** 0143 can COMMIT without payment but 0157 blocks COOKING → the pilot is downstream-neutered; treat the payment→KDS coupling as three-pathed **and** partially self-blocking.
- **Known still-broken:** DID `bootstrap_did_app` phantom `did_devices` columns; DID event-reactive layer unbuilt. `kds_tickets` phantom columns (`is_late`/`priority_score`) already fixed; `order_items`/`point_ledger`/`coupons` phantoms tracked OPEN in 600404.
- **Doc-authority caution:** 특허1/특허2 and the capacity late-binding flow are undocumented in 900xxx; the KDS no-show behavior is documented only in the waiting layer; DID indexes are stale — cross-check the live DB / latest migration, not the KDS/DID indexes, for canonical state.

*(Read-only inspection complete — no repository files created, modified, moved, or deleted; no SQL executed; no git action, per operational-plan §4/§5/§13.)*