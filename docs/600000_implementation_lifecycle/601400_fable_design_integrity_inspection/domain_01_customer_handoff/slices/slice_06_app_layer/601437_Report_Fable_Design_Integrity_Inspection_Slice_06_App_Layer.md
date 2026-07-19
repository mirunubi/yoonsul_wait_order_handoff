Reviewer: Opus 4.8

# 9.1 — Master Inspection Summary

**Slice:** `slice_06_app_layer` — Customer Handoff / Flutter client (`catchmenu_app`) + 600200 workpackets.
**Files inspected:** 18 workpacket MD (600200 series — Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit for 600210 + 600220, plus Readme/ChangeHistory/NavigationMap/DecisionLog) + real Dart source (2 screens, `rpc_caller.dart`, `app_constants.dart`, `guest_session_storage.dart`, `router.dart`, `main.dart`, `supabase_client.dart`, `app_error.dart`) + 4 feature READMEs + app README + `impact_scope.md` + 3 migrations (0081, 0116, 0149).

**What this layer actually is (§6.2):** a **thin MVP scaffold**. Only the *waiting* feature has real Dart (2 screens); *kds/payment/staff* are README-only stubs marked "Scope D 통과 후 구현" (implement after server-guard scope passes). The app README is stock `flutter create` boilerplate. Live wired paths: **register-waiting** (real RPC calls) and **waiting-status** (a SharedPreferences-only display stub). All RPC traffic funnels through one `RpcCaller` wrapper enforcing `INV-004` (client-forbidden server RPCs).

**Four carried cross-references — resolved against real code:**

**#1 — which customer-app RPCs the Dart client actually calls, and with what params.**
- **Real callers (2):** `bootstrap_customer_app_v2` (params `p_tenant_id`, `p_store_id`, `p_customer_id: null`, `p_phone_hash`) and `register_waiting` (full param set, notably `p_source: 'CUSTOMER'`, `p_customer_id: <guest id>`, `p_guest_locale: 'ko'`).
- **Zero callers:** `bootstrap_customer_app` (v1/0081), `place_takeout_order`, `track_takeout_order`, `get_customer_home`, `register_customer_push_token` (all 0081), `qr_scan_action`, `get_order_tracking`, `get_customer_history` (all 0116). **The "0 real callers" pattern is re-confirmed** for exactly the phantom-column-bearing takeout RPCs — the takeout-order feature has no Dart whatsoever.
- **Critical subtlety:** the **live** body of `bootstrap_customer_app_v2` is **0149's** (`CREATE OR REPLACE`), not the 0116 body shown in the slice concat. The concat's 0116 `bootstrap_customer_app_v2` returns `customer: null` for a guest — reading only the concat would (and initially did) suggest the client's `_ensureGuestCustomerId()` always throws `StateError`. **0149 refutes this**: it fills the guest via `get_or_create_guest_customer()` and returns `data.customer.id`. **The flow works; the concat is misleading.** (→ APP-F01.)

**#2 — WAIT-F09 (`waiting_status_screen` reads SharedPreferences, not `get_waiting_status`).** **Confirmed, and it is intentional.** The screen calls **no RPC** — it reads only `guest_customer_id`/`guest_waiting_session_id` from `GuestSessionStorage`. The code carries an explicit intent comment: *"Status lookup RPC integration is intentionally not invented in this change. This screen verifies the persisted ids used by the waiting status flow boundary."* So it is a deliberate MVP-slice scaffold (register first, live status later), not an accidental omission. Consequence: the customer has **no live queue-position view** — the server's `get_waiting_status` exists but is unwired. (→ APP-F05, LOW.)

**#3 — CH-F09 (TTL nowhere specified), checked in client code.** **Confirmed and extended.** The client has **no hardcoded TTL** anywhere (`app_constants.dart`, `guest_session_storage.dart`); guest identity is stored in `SharedPreferences` with **no expiry** (persists indefinitely on-device). The only concrete TTL in the whole stack is the server's `interval '30 days'` magic number in 0081 (`customer_app_sessions.expires_at`, undocumented) — and that table is orphaned in the live path (see #1/APP-F04). Meanwhile `get_or_create_guest_customer` (0149) creates a **new `customers` row on every anonymous (no-phone) bootstrap** with no retention/cleanup design. (→ APP-F03.)

**#4 — do 600210/600220 carry the phantom / doc-vs-impl mismatch pattern?** **No — the opposite.** These workpacket docs are accurate and *self-correcting*: 600211 §0.3 explicitly caught the exact call-order subtlety (`register_waiting` returns no `customer_id`; `bootstrap_customer_app_v2` does) and retro-corrected the design — and the shipped Dart implements precisely that order. 600216 Verification carries genuine `flutter analyze`/`flutter test` output and a real hang root-cause investigation. The phantom columns live in the **SQL RPCs (0081)**, which these Flutter docs do not touch. This is a **positive** contrast to the runtime-flow bundle and the customer-app SQL. (Minor issues → APP-F05.)

**Finding totals:** 5 findings — **0 CRITICAL, 0 HIGH, 3 MEDIUM, 2 LOW** — plus one **refuted would-be-CRITICAL** (guest-bootstrap null) and several verified-clean positives.
**Confidence:** HIGH (direct source reads + migration cross-check).

---

# 9.2 — Structural Defect Register

**APP-F05 — Overview status-drift + stock README + one-guarded-RPC.** `STRUCTURAL DEFECT` · **LOW**
`600211_Overview` and `600221_Overview` remain `Status: Draft` / `Owner: TBD` / `Stage 1.5` even though their sibling `600216`/`600226` are `Stage 5 · Verified · PASS` and `600217`/`600227` Audits exist — the Overview was never promoted after the change shipped (same approval-vs-Draft drift class as the KDS/payment slices). The app-level `catchmenu_app/README.md` is untouched `flutter create` boilerplate ("A new Flutter project"). `RpcCaller.forbiddenClientRpcs` guards only `release_kds_after_payment` — correct as far as it goes, but other server-only RPCs (`bulk_commit_kds_tickets`, `request_kds_release_after_payment`, `confirm_payment_from_provider`) are not enumerated (defense-in-depth gap; RLS/`SECURITY DEFINER` are the real gate). **Confidence:** HIGH.

---

# 9.3 — Design Conflict Register

*(No new intra-layer design contradictions. The genuine conflicts are pre-existing and honestly logged by 600220 as deferred Open Items — see 9.4.)*

---

# 9.4 — Canonical Ambiguity Register

**APP-F06 — Unresolved channel/platform identity for `catchmenu_app`.** `CANONICAL AMBIGUITY` · **LOW**
600220 documents three live ambiguities, all Human-deferred: (a) **kiosk platform conflict** — `900161` says kiosk = Flutter Web, `900171` says kiosk = Android/Windows (MINI_KIOSK, out of MVP scope); (b) **Channel identity** — `catchmenu_app` is mapped to Channel 2 (`900120`: native, OTP, membership), yet it currently performs only anonymous no-install guest waiting (Channel 1 territory, `900110`); whether Channel-1-web and Channel-2-native are one multi-target codebase or two implementations is undecided; (c) **"same binary or flavor TBD"** (`604101` §8.2) for staff vs customer builds. These are appropriately parked, not defects — recorded so the Owner tracks them. **Confidence:** HIGH (from the docs' own Open Items).

---

# 9.5 — MD–SQL–JSON Drift Register

**APP-F01 — The slice's own migration concat presents superseded RPC bodies as live.** `DOCUMENT–SQL DRIFT` / `CANONICAL AMBIGUITY` · **MEDIUM**
`slice_06_app_layer_migrations_concat.sql` includes 0116's `bootstrap_customer_app_v2` (and 0081's v1/takeout RPCs) whose bodies are **dead** — 0149 `CREATE OR REPLACE`s `bootstrap_customer_app_v2` and `register_waiting` later in the same file, and 0148 adds the `order_sessions.customer_id` column that 0081's `DEFERRED` comments say does not exist. A reviewer reading top-to-bottom sees the stale guest-returns-null body first; nothing in the concat marks 0116's bodies as superseded. This nearly produced a false CRITICAL in this very inspection. Live contract = **0149**. Same source-vs-migration residue class as WAIT-F04, now surfacing inside the inspection bundle. **Owner note:** when auditing app-layer RPCs, treat 0149 as canonical for `bootstrap_customer_app_v2`/`register_waiting`; 0081's `DEFERRED order_sessions.customer_id` comments are stale post-0148. **Confidence:** HIGH.

**APP-F02 — `place_takeout_order`/`track_takeout_order` phantom `order_items` columns (latent — zero callers).** `IMPLEMENTATION DEFECT CANDIDATE` / `RUNTIME BLOCKER CANDIDATE` · **MEDIUM**
`place_takeout_order` (0081, live, `GRANT`ed to `authenticated`) inserts `order_items(unit_price, subtotal, is_kds_required, display_order)` — all **phantom** (real: `unit_price_snapshot`/`item_amount`/`is_kds_required_snapshot`) — and omits `NOT NULL menu_code_snapshot` → would raise `42703`/`23502` on any call. `track_takeout_order` reads the same phantoms. **No Dart caller exists** (the takeout feature has no client), so this is latent — but the function is `authenticated`-executable, so a direct PostgREST call fails. This is exactly 600404 roadmap **OPEN cluster #5**, re-confirmed from the client side: the phantom-bearing RPCs are precisely the ones with zero callers. **Confidence:** HIGH.

---

# 9.6 — Historical / Superseded Candidate Register

- **0116 `bootstrap_customer_app_v2` body** and **0081 `bootstrap_customer_app` (v1) / `place_takeout_order` / `track_takeout_order` / `register_customer_push_token`** are historical/superseded or caller-less (APP-F01/APP-F02/APP-F04). The `customer_order_history` view and its dependent queries remain **commented-out `DEFERRED`** blocks in 0081 (undesigned `orders.customer_id`; note `order_sessions.customer_id` was since added by 0148, so those specific `DEFERRED` comments are now half-stale).
- **Refuted candidate (recorded to prevent re-flagging):** "guest bootstrap returns null `customer.id` → client always throws" is **NOT a defect** — 0149's patched `bootstrap_customer_app_v2` creates the guest and returns `data.customer.id`. Verified clean.

---

# 9.7 — Runtime Risk Register

**APP-F03 — Guest-identity lifecycle has no TTL and unbounded row growth.** `MISSING DESIGN CONTRACT` · **MEDIUM**
The client stores `guest_customer_id`/`guest_waiting_session_id` in `SharedPreferences` with **no expiry**, and `get_or_create_guest_customer` (0149) inserts a **new `customers` row per anonymous bootstrap** ("완전 익명: 매번 신규 row", Human 결정 #4). On-device caching mitigates repeat calls from the *same* device, but every new device / cleared storage / web session mints another guest `customers` row with **no documented TTL, retention, or promotion/cleanup path**. The only TTL in the stack (server `interval '30 days'`, undocumented) governs `customer_app_sessions`, which the live path never writes (APP-F04). Confirms and extends CH-F09 at the code level. **Owner decision:** define guest-customer TTL / dedup / cleanup policy. **Confidence:** HIGH.

**APP-F04 — `customer_app_sessions` (and the push-token pipeline) are orphaned in the live path.** `MISSING DESIGN CONTRACT` · **MEDIUM**
`customer_app_sessions` is written only by `bootstrap_customer_app` (v1/0081) and `register_customer_push_token` (0081) — **both caller-less**. The live client uses `bootstrap_customer_app_v2`, which never creates a session row and never passes `p_push_token`. Consequently: (a) the "app session" concept + its 30-day TTL are dead in production; (b) `register_waiting` queues a `push_notification_queued` event for phone-hash guests, but **no client path ever stores a push token**, so the push-notification pipeline has no token source. Designed-but-unwired. **Confidence:** HIGH.

*(No live CRITICAL/HIGH runtime risk: the broken takeout RPCs and dead session table have no client caller; the wired paths — guest bootstrap + register_waiting — are correct under 0149.)*

---

# 9.8 — Owner Decision Queue

1. **Guest-customer lifecycle** — define TTL / dedup (anonymous rows) / retention / promotion cleanup. [APP-F03]
2. **App-session & push pipeline** — decide whether the live path should write `customer_app_sessions` and capture push tokens, or retire v1/`register_customer_push_token`. [APP-F04]
3. **Takeout feature** — before wiring any client to `place_takeout_order`, fix its phantom `order_items` columns (600404 cluster #5). [APP-F02]
4. **Channel/platform identity** — resolve Channel-1-web vs Channel-2-native for `catchmenu_app`; kiosk platform (`900161` vs `900171`); same-binary-vs-flavor. [APP-F06]
5. **Concat/source canonicalization** — mark superseded RPC bodies (0116/0081) as dead so audits don't mis-read them. [APP-F01]

---

# 9.9 — Regular Workpacket Recommendation Queue (candidates — Owner-gated per §10)

- **WP-1 (MEDIUM):** Guest-identity TTL & cleanup design (client SharedPreferences expiry + server anonymous-`customers` retention). [APP-F03]
- **WP-2 (MEDIUM):** Reconcile the live bootstrap path with `customer_app_sessions` + push-token capture, or retire the caller-less v1/push RPCs. [APP-F04]
- **WP-3 (MEDIUM):** Fold `place_takeout_order`/`track_takeout_order` phantom-column fixes into the single repo-wide phantom audit (order_items cluster). [APP-F02 + prior KDS-F06/WAIT-F05/CH-F01/PAY-F06]
- **WP-4 (LOW):** Promote 600211/600221 out of Draft; enumerate additional server-only RPCs in `forbiddenClientRpcs`; replace stock app README. [APP-F05]
- **WP-5 (LOW):** Resolve the channel/platform Open Items (kiosk, Channel 1 vs 2, binary-vs-flavor). [APP-F06]

---

## §6.4 baseline (app layer) + domain_01 closing note

- **Live client → server contract:** app boots → `bootstrap_customer_app_v2(p_customer_id=null)` (0149) mints/returns a guest `customer_id` → stored in SharedPreferences → `register_waiting(p_customer_id=<guest>, p_source='CUSTOMER')` (0149) creates the `order_sessions` row (now with real `customer_id`, per 0148). This closes **CH-F01** (customer↔session linkage is mechanized for the waiting path) at the client level.
- **Caller-less / latent server code:** v1 `bootstrap_customer_app`, `place_takeout_order` (phantom), `track_takeout_order` (phantom), `get_customer_home`, `register_customer_push_token`, `qr_scan_action`, `get_order_tracking`, `get_customer_history`. Treat as unshipped until a client wires them.
- **Canonical bodies:** 0149 > 0116 > 0081 for `bootstrap_customer_app_v2` and `register_waiting`. 0081's `DEFERRED order_sessions.customer_id` comments are stale post-0148 (orders.customer_id still absent).
- **TTL:** none client-side; the only server TTL (30 days, `customer_app_sessions`) is undocumented and orphaned. CH-F09 stands.
- **Domain_01 Customer Handoff — inspection complete** across policy (slice_04), waiting (01), payment (02), KDS/DID (03), runtime-flow (05), app-layer (06). Recurring cross-slice themes for the Owner: the **phantom-column class** (order_items/point_ledger/coupons/did_devices/customer-app — one repo-wide audit recommended), **index/NavigationMap drift**, **CREATE-OR-REPLACE source-vs-migration residue**, **undocumented TTL/patent mechanisms**, and **verification-rigor inconsistency** — against a genuinely sound core (여전법 held, KDS payment-gate correct, INV-004 client guard, 0148/0149 guest linkage, self-correcting 600210 docs).

*(Read-only inspection complete — no repository files created, modified, moved, or deleted; no SQL executed; no git action, per operational-plan §4/§5/§13.)*