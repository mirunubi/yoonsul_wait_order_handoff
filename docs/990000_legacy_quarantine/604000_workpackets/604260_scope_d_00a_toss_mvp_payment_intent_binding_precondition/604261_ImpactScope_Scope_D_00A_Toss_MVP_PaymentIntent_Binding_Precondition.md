# 604261_ImpactScope_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Draft
Lifecycle: ImpactScope
Gate Classification: Scope D Sub-Workpacket 00A — Stage 1 Boundary Scan
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-02

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation slice may proceed while Owner remains TBD.

This ImpactScope does not authorize implementation.
It only records discovered files, binding risks, and candidate future change boundaries.
Codex must not implement from this ImpactScope.
A slice-specific Overview, Logic, TestPlan, ChangeContract, and Human Approval are required before implementation.

604260 does not authorize 604250 implementation.
604260 exists because 604250 implementation stopped under 604256 due to unresolved payment_intent binding.
604250 may resume only after this precondition is closed and audited.

Historical migration files are read-only for this slice.
Do not modify `0014_create_payment_ledger.sql`, `0098_create_payment_confirm_pipeline_rpc.sql`, `0103_create_toss_payments_pipeline_rpc.sql`, or `0027_create_payment_intent_rpc.sql` in place.
If implementation is later approved, it must use new append-only patch migrations.

**Note on filename:** User task references `0103_create_toss_payment_integration.sql`; repo actual file is `0103_create_toss_payments_pipeline_rpc.sql`.

---

## 0. Purpose

Scope D **604260** (`Toss MVP payment_intent binding precondition`)의 Stage 1 영향 범위 조사.

`604256` Human Approval 하에 `604250` schema drift alignment 구현이 시도되었으나, **Toss MVP 경로(`0103` → `0098`)가 `payment_intents`를 생성·연결하지 않아** `payment_ledger.intent_id NOT NULL` ( `0014` L160 ) 및 `604256` §3 intent binding rule을 충족할 수 없어 **구현이 중단**되었다.

본 문서는 해당 blocker의 **repo 근거, binding gap, 최소 수정 후보, 금지 경계**만 기록한다.

---

## 1. Scope Boundary

### 1.1 In scope (604260 investigation)

| Area | Boundary |
| --- | --- |
| `payment_intents` DDL | `0014` |
| `toss_payment_requests` DDL + RPCs | `0103` |
| `confirm_payment` binding surface | `0098` (read-only — what it accepts today) |
| Existing intent creation | `0027` `create_payment_intent` (reference only) |
| Upstream approval policy | `604256` §3–§4 Toss MVP lifecycle |
| Blocked downstream | `604250` patch resume gate |

### 1.2 Out of scope

| Area | Owner / note |
| --- | --- |
| `payment_ledger` column drift alignment (provider_payment_key, fee_amount removal) | `604250` — **blocked until 604260 closes** |
| Idempotency same-success / TC-102 | `604310` |
| `confirm_payment_from_provider` / `0038` webhook legacy | Future consolidation; `0027` read-only |
| Flutter / Edge Function source | Not in repo or separate slices |
| **`604250` Codex implementation** | Not authorized by this document |

### 1.3 Relationship to 604256 allowed files

`604256` §11 **Allowed Files** lists only:

```text
sql/migrations/<next>_patch_payment_ledger_confirm_payment_schema_alignment.sql
604257_Module_...
```

**`0103` is not in 604256 allowed files** (§12 forbidden in-place).
Therefore **Toss upstream intent binding cannot be closed inside the 604250 patch alone** — it requires this **604260** slice (or expanded Human Approval).

---

## 2. Upstream Blocker Context From 604250

### 2.1 Codex stop condition (reported)

```text
0103 → confirm_payment path does not create or link payment_intent.
payment_ledger.intent_id is NOT NULL.
604256: APPROVED ledger write prohibited unless intent_id resolved exactly once.
604250 implementation cannot proceed until Toss MVP payment_intent binding closes.
```

### 2.2 604256 binding rules (approved)

| Rule | Source |
| --- | --- |
| `payment_intent` created **before** provider confirm when flow supports it | `604256` §3 |
| `confirm_payment` should receive `p_intent_id` when available | `604256` §3 |
| **Synthetic intent at confirm prohibited by default** | `604256` §3 |
| 0 intent → `INTENT_BINDING_REQUIRED` | `604256` §3 |
| >1 intent → `INTENT_BINDING_CONFLICT` | `604256` §3 |
| Weak guesswork forbidden (order_id-only, most recent pending, session guess) | `604256` §3 |
| Toss MVP target lifecycle | `604256` §4 L128–136 |

### 2.3 Approved Toss MVP target lifecycle (`604256` §4)

```text
Order checkout begins
→ payment_intent created
→ toss_payment_request created and linked to payment_intent
→ Toss approval / confirm returns paymentKey
→ confirm_payment binds to existing payment_intent
→ payment_ledger APPROVED row inserted
```

**Current repo:** steps 2–4 **not implemented** on Toss path.

---

## 3. Source Files Inspected

| File | Role |
| --- | --- |
| `sql/migrations/0014_create_payment_ledger.sql` | `payment_intents`, `payment_ledger.intent_id NOT NULL` |
| `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | `toss_payment_requests`, `initiate_toss_payment`, `confirm_toss_payment`, `process_toss_webhook` |
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | `confirm_payment` — no intent param/lookup |
| `sql/migrations/0027_create_payment_intent_rpc.sql` | `create_payment_intent`, `confirm_payment_from_provider` (reference) |
| `sql/migrations/0012_create_pos_order_sessions.sql` | `order_sessions.toss_order_id` L58 |
| `sql/migrations/0052_create_kiosk_session_rpc.sql` | **Counterexample:** calls `create_payment_intent` before payment L271–283 |
| `docs/.../604256_Approval_…` | Blocker policy authority |
| `docs/.../604251_ImpactScope_…` | §7 intent binding gap on Toss path |
| `docs/.../604310_Index_…` | 604310 blocked on schema drift + binding |

---

## 4. payment_intents DDL Findings

**Source:** `0014` L14–151 (`payment_intents`), L154–239 (`payment_ledger`)

### 4.1 Table: `catchmenu_payment.payment_intents`

| Column | Constraint | Line |
| --- | --- | --- |
| `id` | PK uuid | L15 |
| `tenant_id`, `store_id`, `order_id` | NOT NULL FK | L16–18 |
| `session_id` | nullable FK | L19 |
| `intent_status` | NOT NULL default CREATED | L22 |
| `payment_method` | NOT NULL | L23 |
| `payment_channel` | NOT NULL | L24 |
| `requested_amount` | NOT NULL, > 0 | L27, L105 |
| `currency` | NOT NULL default KRW | L28 |
| `provider_type` | NOT NULL | L31 |
| `provider_order_id` | unique nullable | L32 |
| `payment_token` | unique nullable | L35 |
| **`idempotency_key`** | **NOT NULL** | **L40** |
| `business_day`, `business_timezone` | NOT NULL | L51–52 |

### 4.2 Relationship to orders

- FK `order_id` → `catchmenu_pos.orders(id)` L18
- Index `idx_payment_intents_order` L108–109
- Comment L135: **One order may have multiple intents (retry after failure)**

### 4.3 Relationship to payment_ledger

- `payment_ledger.intent_id uuid **not null**` FK → `payment_intents(id)` **L160**

---

## 5. toss_payment_requests Findings

**Source:** `0103` L92–221

### 5.1 Table: `catchmenu_integrations.toss_payment_requests`

| Column | Notes | Line |
| --- | --- | --- |
| `id` | PK | L94 |
| `tenant_id`, `store_id` | NOT NULL | L95–98 |
| `order_id` | nullable FK → orders | L101–102 |
| `payment_key` | Toss paymentKey; nullable until confirm | L105, index L174–177 |
| `order_id_toss` | NOT NULL **unique** — Toss-facing order id | L106 |
| `idempotency_key` | NOT NULL **unique** | L107 |
| `payment_method`, `amount`, `order_name` | payment info | L110–112 |
| `request_status` | READY … EXPIRED | L119–163 |
| `toss_response` | jsonb | L123 |
| `approved_amount`, … | post-confirm | L137+ |

### 5.2 Link to payment_intents

| Question | Answer |
| --- | --- |
| FK `payment_intent_id` / `intent_id` column? | **No** — not in DDL |
| FK to `payment_intents`? | **No** |
| Shared unique key with `payment_intents.idempotency_key`? | **Separate namespaces** — toss generates its own hash L419–427; not coordinated with `create_payment_intent` |

### 5.3 Relationship to orders

- `order_id` nullable FK L101–102
- Index `idx_toss_requests_order` L166–169

---

## 6. 0103 confirm_toss_payment Flow Findings

### 6.1 `initiate_toss_payment` (L315–517)

| Step | Behavior | Lines |
| --- | --- | --- |
| Load order | `orders` + optional `order_sessions` | L372–382 |
| Duplicate guard | `toss_payment_requests.request_status = 'DONE'` | L395–408 |
| Build `order_id_toss` | `CATCH-{YYYYMMDD}-{order_number}-{epoch}` | L412–417 |
| Build `idempotency_key` | SHA256(`order_id` + `final_amount` + `order_id_toss`) | L419–427 |
| **Insert** | `toss_payment_requests` only | L442–460 |
| Notify Edge | `toss_payment_initiate_requested` | L464–488 |

**Does not:** call `create_payment_intent`; does not insert `payment_intents`; does not set `order_sessions.toss_order_id`.

### 6.2 `confirm_toss_payment` (L522–731)

| Step | Behavior | Lines |
| --- | --- | --- |
| Lookup request | `toss_payment_requests` by `order_id_toss` | L550–557 |
| Idempotency | `request_status = 'DONE'` → error | L569–577 |
| Amount check | strict `p_amount` vs `v_request.amount` | L591–637 |
| Update request | set `payment_key`, `DONE`, etc. | L673–691 |
| **Call** | `catchmenu_payment.confirm_payment(...)` | **L695–710** |

### 6.3 `confirm_payment` arguments from Toss (L695–710)

```text
p_order_id          := v_request.order_id
p_provider_type     := 'TOSS_PAYMENTS'
p_provider_approval_number := v_approval_number
p_provider_tx_id    := p_payment_key          -- Toss paymentKey
p_approved_amount   := p_amount
p_payment_method    := v_payment_method
p_provider_response := p_toss_response
p_actor_type        := 'PG_WEBHOOK'
p_correlation_id    := p_correlation_id
```

**Missing:** `p_intent_id`, any `payment_intents` lookup, intent linkage.

### 6.4 Webhook path

`process_toss_webhook` (L1018+) on `DONE` → `confirm_toss_payment` (L1020–1034) — **same binding gap**.

### 6.5 Answers to core questions (6–8)

| # | Question | Answer |
| --- | --- | --- |
| 6 | Creates `payment_intents`? | **No** |
| 7 | Links `toss_payment_requests` ↔ `payment_intents`? | **No** — no column, no join in RPC |
| 8 | `confirm_payment` args? | See §6.3 — no intent |

---

## 7. 0098 confirm_payment Binding Findings

**Source:** `0098` L145–457 (read-only)

| # | Question | Answer | Lines |
| --- | --- | --- | --- |
| 9 | Accepts `p_intent_id`? | **No** — not in signature L145–158 | |
| 10 | `payment_intents` lookup inside function? | **No** — grep: zero matches for `payment_intent` / `intent_id` in `0098` | |
| INSERT | Includes `intent_id`? | **No** — drift INSERT L306–317 (604251) | |
| Idempotency SELECT | Uses `provider_tx_id` on ledger | L192–199 — separate drift issue (604250) | |

**Implication:** Even after `604250` patch adds `p_intent_id` + 0014-aligned INSERT, **Toss path must supply exactly-one `intent_id`** or confirm must fail with `INTENT_BINDING_REQUIRED` per `604256`.

---

## 8. Toss paymentKey / provider_payment_key Findings

| Item | Finding |
| --- | --- |
| Toss `paymentKey` in confirm | Passed as `p_provider_tx_id := p_payment_key` (`0103` L702) |
| `604256` naming policy | `provider_payment_key` authoritative; `provider_tx_id` legacy alias only (`604256` §5) |
| `0014` ledger column | `provider_payment_key` L174 — **not** `provider_tx_id` |
| `payment_intents` | No `payment_key` column; has `provider_order_id` (provider-facing order id, not Toss paymentKey) |
| Can paymentKey alone resolve intent? | **No** — no stored mapping from `payment_key` → `payment_intents.id` before/without new linkage |
| Post-confirm | `toss_payment_requests.payment_key` indexed L174–177 — strong for **request row**, not for **intent** |

**Mapping conclusion:** Toss `paymentKey` maps to **`provider_payment_key` semantics** on ledger (per 604256), but **does not substitute for `intent_id`**.

---

## 9. Existing PaymentIntent Creation Path Findings

### 9.1 `catchmenu_payment.create_payment_intent` (`0027` L15–187)

| Item | Detail |
| --- | --- |
| Location | `0027_create_payment_intent_rpc.sql` |
| Creates | Row in `payment_intents` L113–128 |
| Required inputs | `p_session_id`, `p_payment_method`, `p_payment_channel`, `p_provider_type`, `p_requested_amount`, **`p_idempotency_key`** L19–24 |
| Active intent guard | Blocks if non-terminal intent exists for same order L44–56 |
| Side effects | Updates `order_sessions` to PAYMENT_PENDING; sets `toss_order_id` when provider TOSS L135–138 |
| `provider_order_id` format | `CM-{store8}-{epoch}-{random6}` L107–110 — **≠** Toss `order_id_toss` format `CATCH-...` |

### 9.2 Who calls `create_payment_intent` today?

| Caller | File | Toss MVP? |
| --- | --- | --- |
| Kiosk flow | `0052_create_kiosk_session_rpc.sql` L271–283 | No |
| **`initiate_toss_payment`** | `0103` | **Does not call** |
| **`confirm_toss_payment`** | `0103` | **Does not call** |

### 9.3 `#12–13` Pre-confirm creation candidates

| Candidate | File / function | Notes |
| --- | --- | --- |
| **P0** | Patch `CREATE OR REPLACE initiate_toss_payment` | Call `create_payment_intent` before toss request insert; store returned `intent_id` |
| P1 | New wrapper RPC e.g. `initiate_toss_payment_with_intent` | Avoids editing 0103 in-place if Human Approval prefers new function name |
| P2 | Patch `confirm_toss_payment` only | **Insufficient alone** — violates 604256 pre-create policy; synthetic-at-confirm prohibited |
| Reference | `0052` kiosk pattern | Pre-create intent before payment window |

### 9.4 `#14` Strong exactly-one resolver at confirm time (without upstream link)

| Identifier | Exactly-one? | Notes |
| --- | --- | --- |
| `order_id` only | **No** — multiple intents possible (`0014` L135) | **604256 forbidden** |
| `toss_payment_requests.idempotency_key` | One per request row | **Not on `payment_intents`** unless pre-coordinated |
| `order_id_toss` | Unique on toss table | Maps to **request**, not **intent** |
| `payment_key` | Unique per Toss payment after confirm | Available at confirm; **no intent FK** |
| `payment_intents.idempotency_key` | Unique not enforced on intents table | Could duplicate if not coordinated |
| `payment_intents.provider_order_id` | Unique | **Different value** from `order_id_toss` unless explicitly aligned |

**Conclusion:** **No existing strong resolver** from Toss confirm inputs alone → **`payment_intent_id` must be linked upstream** (604256 §4).

---

## 10. Binding Strategy Candidates

**Design options only — not approved.**

| Strategy | Description | Aligns with 604256? |
| --- | --- | --- |
| **A. Upstream pre-create (recommended)** | `initiate_toss_payment` (or wrapper) calls `create_payment_intent`; persist `payment_intent_id` on `toss_payment_requests`; `confirm_toss_payment` passes `p_intent_id` to patched `confirm_payment` | **Yes** — matches §4 lifecycle |
| **B. Shared idempotency_key** | Use same key in `payment_intents` and `toss_payment_requests`; confirm resolves intent by key | Possible if **exactly-one** index/constraint guaranteed; needs DDL + coordination |
| **C. provider_order_id = order_id_toss** | Align `create_payment_intent.provider_order_id` to Toss `order_id_toss` | Requires changing intent creation order/format; fragile |
| **D. Synthetic intent at confirm** | Create intent inside `confirm_toss_payment` | **Prohibited by default** (`604256` §3) |
| **E. order_id lookup** | Pick pending intent by order | **Forbidden** weak guesswork (`604256` §3) |

### 10.1 `#15–16` Multiple intent / synthetic vs upstream

| Question | Answer |
| --- | --- |
| order_id-only lookup risk? | **Yes** — historical + retry intents (`0014` L135) |
| Synthetic needed? | **Not by default** — upstream pre-create is approved path (`604256` §3–§4) |
| Upstream pre-created intent feasible? | **Yes** — `create_payment_intent` exists; `initiate_toss_payment` is natural hook |

---

## 11. Minimal Future Change Candidates

**Candidate only — not authorized.**

### 11.1 Minimum to unblock 604250 (investigation estimate)

| # | Change | Rationale |
| --- | --- | --- |
| 1 | **Link column** | `ALTER TABLE toss_payment_requests ADD payment_intent_id uuid REFERENCES payment_intents(id)` (in new patch) |
| 2 | **Pre-create intent** | Patch `initiate_toss_payment` (CREATE OR REPLACE in **new** migration) → call `create_payment_intent` with `p_provider_type='TOSS_PAYMENTS'`, coordinated `p_idempotency_key`, session from order |
| 3 | **Store link** | Insert/update toss row with `payment_intent_id` |
| 4 | **Confirm pass-through** | Patch `confirm_toss_payment` → resolve `payment_intent_id` from request row → pass to patched `confirm_payment(p_intent_id := …)` (604250 patch dependency) |
| 5 | **604250 resume** | After 604260 closes, `604250` patch can enforce intent_id NOT NULL on ledger INSERT |

### 11.2 `#18–19` Patch vs in-place / wrapper

| Question | Answer |
| --- | --- |
| In-place edit 0103 forbidden? | **Yes** — policy + 604256 §12 |
| New patch migration possible? | **Yes** — `CREATE OR REPLACE FUNCTION` for `initiate_toss_payment` / `confirm_toss_payment` |
| Must patch 0103 functions directly? | **Behavior must change** — either replace functions via patch **or** introduce new RPC names and migrate callers (Flutter/Edge not in repo — caller migration risk lower for server-only patch) |
| Wrapper-only without touching initiate? | **Insufficient** — initiate must create/link intent |

### 11.3 `#17` vs 604256 single-file constraint

604260 is a **separate slice** from 604256's single allowed migration. Expected:

```text
604260 patch: Toss intent binding (0103 function replacements + optional toss_payment_requests DDL)
604250 patch: confirm_payment schema alignment (0098 function replacement) — resumes after 604260
```

---

## 12. Forbidden Files

Unless a **future 604265 ChangeContract + 604266 Human Approval** explicitly allows:

```text
sql/migrations/0014_create_payment_ledger.sql           (in-place)
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql (in-place)
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql  (in-place)
sql/migrations/0027_create_payment_intent_rpc.sql         (in-place)
604250 implementation / 604257 Module (until 604260 closes — separate authorization)
604262 Overview, 604263 Logic, 604264 TestPlan, 604265 ChangeContract, 604266 Approval
604267 Module, 604268 Verification, 604269 Audit
catchmenu_app/**, supabase/functions/**, tests/**, python/**, config/**, package/lockfile
Codex implementation instructions
```

**604260 may not be used to bypass 604256** — closing 604260 enables 604250 **resume**, not automatic 604250 execution.

---

## 13. Migration Numbering Status

Verified `sql/migrations/` (2026-07-02):

| Number | File | Status |
| --- | --- | --- |
| 0136–0139 | various | Taken |
| 0140+ | — | **No file present** — 604250 patch not merged (blocked) |
| 0138 | `0138_patch_integration_functions.sql` | Single file on disk |

**604260 patch candidate:** `0140` or next free prefix — **re-verify immediately before implementation** (604256 §10).

---

## 14. Risk Assessment

| Risk | Severity | Detail |
| --- | --- | --- |
| **604250 blocked** | Critical | Cannot satisfy `intent_id NOT NULL` on Toss path |
| **No intent link column** | High | `toss_payment_requests` has no FK to `payment_intents` |
| **Dual idempotency namespaces** | Medium | Toss SHA256 key ≠ intent key unless coordinated in patch |
| **provider_order_id mismatch** | Medium | `CM-...` vs `CATCH-...` — cannot join without explicit link |
| **create_payment_intent active guard** | Medium | Re-initiate on same order returns `active_intent_exists` L51–56 |
| **604256 synthetic prohibition** | High | Confirm-only intent creation is default-forbidden |
| **604256 0103 not allowed** | High | 604250 approval alone cannot fix Toss upstream |
| **Order multiple intents** | High | order_id-only resolver forbidden |
| **session_id required for create_payment_intent** | Medium | `initiate_toss_payment` has `v_order.session_id` L374 — nullable on order? must handle null session |
| **Webhook + client double confirm** | Medium | Both call `confirm_toss_payment`; intent link must be stable on request row |

---

## 15. Open Questions

1. **Single vs dual migration:** One 604260 patch for DDL + both Toss RPCs, or split binding DDL vs RPC?
2. **`idempotency_key` coordination:** Reuse toss hash for `create_payment_intent.p_idempotency_key`, or separate keys with FK link only?
3. **`payment_channel` value** for handoff MVP (`CUSTOMER_APP` vs `TABLE_QR`) when calling `create_payment_intent`?
4. **Null `session_id` on order:** Block initiate or allow intent without session?
5. **Re-initiate after FAILED intent:** How does `create_payment_intent` active guard interact with Toss retry?
6. **604266 Human Approval:** Will 604260 explicitly allow `CREATE OR REPLACE` on `initiate_toss_payment` / `confirm_toss_payment`?
7. **604250 sequencing:** Must 604260 patch land **before** 604250 patch in migration order?
8. **`p_intent_id` on confirm_payment:** Owned by 604250 patch — contract interface between 604260 and 604250?
9. **Owner** assignment before 604266.
10. **Edge/Flutter callers:** When added, must they call patched initiate or new wrapper?

---

## 16. Non-Implementation Statement

```text
- No SQL, migration, Edge Function, Flutter, Python, or config changes were made.
- 0014, 0098, 0103, 0027 were read-only inspected; not modified.
- No 604262–604269 documents were created.
- No Codex implementation was instructed.
- 604250 implementation remains paused until 604260 precondition closes and is audited.
```

Next allowed step per `600179`: **604262 Overview** for 604260 slice — **not authorized in this task**.

---

## Appendix — Investigation Checklist (20 items)

| # | Question | Answer |
| --- | --- | --- |
| 1 | payment_intents DDL? | §4 — `0014` L14–151 |
| 2 | Required columns? | tenant/store/order, intent_status, payment_method/channel, requested_amount, provider_type, **idempotency_key**, business_day |
| 3 | Relation to orders? | FK order_id; multiple intents per order allowed |
| 4 | Relation toss ↔ intents? | **None** in DDL |
| 5 | toss has intent_id? | **No** |
| 6 | confirm_toss creates intents? | **No** |
| 7 | confirm_toss links tables? | **No** |
| 8 | confirm_payment args? | §6.3 |
| 9 | p_intent_id on confirm_payment? | **No** |
| 10 | payment_intents lookup in 0098? | **No** |
| 11 | paymentKey → provider_payment_key? | **Yes semantically** (604256); **not** intent_id |
| 12 | Pre-confirm create function exists? | **`create_payment_intent`** (`0027`) |
| 13 | Pre-confirm hook candidate? | **`initiate_toss_payment`** (`0103` L315+) |
| 14 | Strong exactly-one resolver at confirm? | **No** without upstream link |
| 15 | order_id-only multiple risk? | **Yes** |
| 16 | Synthetic vs upstream? | **Upstream required** (604256) |
| 17 | Minimal change set? | §11.1 |
| 18 | Append-only patch possible? | **Yes** |
| 19 | Patch 0103 vs wrapper? | **Must change initiate behavior**; CREATE OR REPLACE in new migration likely |
| 20 | 604260 candidate/forbidden files? | §11, §12 |
