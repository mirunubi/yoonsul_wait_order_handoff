# 604251_ImpactScope_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md

Status: Draft
Lifecycle: ImpactScope
Gate Classification: Scope D Sub-Workpacket 00 ??Schema Drift Alignment (Stage 1 Boundary Scan)
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation slice may proceed while Owner remains TBD.

This ImpactScope does not authorize implementation.
It only records discovered files, schema drift risks, binding risks, and candidate future change boundaries.
Codex must not implement from this ImpactScope.
A slice-specific Overview, Logic, TestPlan, ChangeContract, and Human Approval are required before implementation.

Historical migration files are read-only for this slice.
Do not modify `0014_create_payment_ledger.sql`.
Do not modify `0098_create_payment_confirm_pipeline_rpc.sql`.
Do not modify `0027_create_payment_intent_rpc.sql`.
If implementation is later approved, it must use new append-only patch migrations.

**Precondition relationship:** `604310` Payment Confirm Idempotency implementation remains **blocked** until this slice's alignment is verified and closed (`604310_Index` L8??1, `604315` §11).

---

## 0. Purpose

Scope D **604250** (`payment_ledger` / `confirm_payment` **schema drift alignment**)??Stage 1 ?�향 범위 조사.

`604310` 구현 ???�행조건?�로, repo ??**물리??DDL** (`0014`)�?**`0098` `confirm_payment` INSERT/WHERE** �?관??downstream RPC가 **?�일??`payment_ledger` 컬럼 계약**??공유?�는지 ?�인?�고, drift·binding·compile/runtime ?�험??기록?�다.

**�??�계:** 조사·기록�? SQL/migration/구현/Codex 지??금�?.

---

## 1. Scope Boundary

### 1.1 In scope (604250)

| Area | Boundary |
| --- | --- |
| DDL authority | `0014` `catchmenu_payment.payment_ledger`, `payment_intents` |
| Primary RPC drift | `0098` `catchmenu_payment.confirm_payment` INSERT + idempotency SELECT |
| Reference RPC | `0027` `confirm_payment_from_provider` ??**comparison only, not edit target** |
| Downstream drift samples | `0098` refund/cancel paths; `0109`, `0130` ledger INSERT patterns referencing same column names |
| Intent binding | `payment_intents` resolution paths for `confirm_payment` (no `p_intent_id` today) |
| Migration numbering | Next append-only patch candidate under `sql/migrations/` |
| Upstream policy | `604310_Index`, `604311` §9 item 4, `604315` §5 item 5 |

### 1.2 Out of scope

| Area | Owner / note |
| --- | --- |
| Idempotency same-success / TC-102 behavior | `604310` (blocked until 604250 closes) |
| Amount mismatch hard block (TC-110) | `604310` |
| `release_kds_after_payment` guard | `604320` |
| RLS REVOKE on release | `604350` |
| Edge Function Toss verify | `604360` |
| **`0027` modification** | Explicitly excluded ??read-only reference |
| **`0014` / `0098` in-place edit** | Forbidden ??append-only patch only if later approved |

---

## 2. Required Upstream Policy Context

| Document | Relevant policy |
| --- | --- |
| `604404_Index_Scope_D_01_Payment_Confirm_Idempotency.md` | Implementation blocked until schema drift alignment closes (L8??1); item 5 = required precondition |
| `604311_ImpactScope_?? | §9 item 4: `0014` vs `0098` DDL/RPC mismatch recorded |
| `604315_ChangeContract_?? | §5 item 5: schema drift must reconcile before `604316`; §11 next work = schema drift alignment |
| `604301`??604304` | Scope D master pack; D-before-C sequence |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | Stage 1 ImpactScope only; no Codex at this step |

---

## 3. Source Files Inspected

| File | Inspection focus |
| --- | --- |
| `sql/migrations/0014_create_payment_ledger.sql` | `payment_ledger` / `payment_intents` DDL (full file read) |
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | `confirm_payment` L145??57; idempotency L190??28; INSERT L306??31; refund SELECT L774??85 |
| `sql/migrations/0027_create_payment_intent_rpc.sql` | `create_payment_intent`, `confirm_payment_from_provider` L202??89 (reference) |
| `sql/migrations/0021_enable_rls.sql` | Only `ALTER TABLE payment_ledger` found (RLS enable) L131??34 |
| `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | `confirm_toss_payment` ??`confirm_payment` L695??10; no `payment_intents` usage |
| `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` | Manual ledger INSERT L916??27 (same column names as `0098`) |
| `sql/migrations/0130_create_van_handler_extension.sql` | VAN ledger INSERT L396??26 (same drift pattern) |
| `sql/migrations/0073_final_verification.sql` | Table + `confirm_payment_from_provider` existence; **no** `confirm_payment` assert |
| Repo-wide grep | `alter table catchmenu_payment.payment_ledger` ??**only** `0021` RLS alters; **no** `ADD COLUMN` for `provider_tx_id` / `fee_amount` |

---

## 4. payment_ledger DDL Findings

**Source:** `0014_create_payment_ledger.sql` L154??39

### 4.1 Core columns (0014)

| Column | Definition | Notes |
| --- | --- | --- |
| `id` | uuid PK | |
| `tenant_id`, `store_id`, `order_id` | NOT NULL FK | |
| `session_id` | uuid nullable FK | |
| **`intent_id`** | **uuid NOT NULL** FK ??`payment_intents(id)` | **L160** |
| **`ledger_entry_type`** | **text NOT NULL** | APPROVAL, REFUND, ??**L163??10** |
| **`ledger_status`** | **text NOT NULL** | APPROVED, CANCELLED, ??**L212??22** |
| `approved_amount` | int NOT NULL | **L167** |
| `cancelled_amount`, `refunded_amount` | int NOT NULL default 0 | |
| `net_amount` | int NOT NULL | constraint: `net = approved - cancelled - refunded` **L224??28** |
| `provider_type` | text NOT NULL | **L173** |
| **`provider_payment_key`** | **text nullable** | **L174** ??index L253??55 |
| `provider_approval_number` | text nullable | **L175** |
| `provider_approved_at` | timestamptz nullable | |
| **`provider_response_id`** | uuid FK ??`provider_raw_events` | **L177** ??not jsonb |
| `reconciliation_status` | text NOT NULL default PENDING | |
| `kds_release_authorized` | boolean NOT NULL default false | **L187** |
| `business_day`, `business_timezone` | NOT NULL | |
| `approved_at`, `created_at` | timestamptz NOT NULL | |

### 4.2 Absent in 0014 DDL (grep + full read)

| Column name used elsewhere | In 0014? |
| --- | --- |
| **`provider_tx_id`** | **No** |
| **`fee_amount`** | **No** |
| **`payment_method`** | **No** (exists on `payment_intents` L23, not on `payment_ledger`) |
| **`provider_response`** (jsonb) | **No** (only `provider_response_id`) |

### 4.3 payment_intents (intent binding context)

| Column | Notes |
| --- | --- |
| `idempotency_key` | NOT NULL **L40** |
| `provider_order_id` | unique nullable **L32** |
| `intent_status` | CREATED ??EXPIRED **L54??3** |
| Comment L135 | **One order may have multiple intents (retry after failure)** |

---

## 5. 0098 confirm_payment INSERT Findings

**Source:** `0098_create_payment_confirm_pipeline_rpc.sql`

### 5.1 Function signature (L145??58)

```text
confirm_payment(
  p_tenant_id, p_store_id, p_order_id,
  p_provider_type, p_provider_approval_number, p_provider_tx_id,
  p_approved_amount, p_payment_method,
  p_provider_response jsonb, ...
  p_correlation_id text default null
)
```

**No `p_intent_id` parameter.**

### 5.2 INSERT column list (L306??17)

```text
tenant_id, store_id, order_id, session_id,
provider_type, payment_method,
provider_tx_id,
provider_approval_number,
approved_amount, fee_amount, net_amount,
ledger_status,
approved_at,
provider_response,
reconciliation_status,
business_day, business_timezone
```

### 5.3 INSERT values (L318??29)

- `ledger_status = 'APPROVED'` ??**no `ledger_entry_type`**
- `fee_amount = v_fee_amount` (computed L293??03)
- `provider_response = coalesce(p_provider_response, '{}')`
- **`intent_id` omitted entirely**

### 5.4 Idempotency SELECT also assumes drift columns (L192??99)

```sql
WHERE ... AND provider_tx_id = p_provider_tx_id
  AND provider_type = p_provider_type
  AND ledger_status = 'APPROVED'
```

Uses **`provider_tx_id`** on `payment_ledger` ??column **not in 0014**.

### 5.5 Related 0098 reads/writes same drift names

| Location | Usage |
| --- | --- |
| `request_refund` SELECT L774??77 | `provider_tx_id` from `payment_ledger` |
| Refund INSERT L823??41 | `payment_method`, `provider_tx_id`, `fee_amount` |
| `get_payment_status` L1214??219 | Returns `payment_method`, `provider_tx_id`, `fee_amount` |

---

## 6. Schema Drift Findings

### 6.1 Drift matrix: 0014 DDL vs 0098 INSERT

| Field / rule | 0014 DDL | 0098 INSERT | Drift |
| --- | --- | --- | --- |
| `intent_id` | **NOT NULL required** | **Omitted** | **CRITICAL** |
| `ledger_entry_type` | **NOT NULL required** | **Omitted** | **CRITICAL** |
| Provider key column | `provider_payment_key` | `provider_tx_id` | **NAME + existence** |
| `fee_amount` | Absent | Inserted | **CRITICAL** |
| `payment_method` | Absent on ledger | Inserted | **CRITICAL** |
| Provider payload | `provider_response_id` (uuid) | `provider_response` (jsonb) | **TYPE + name** |
| `net_amount` constraint | `approved - cancelled - refunded` | Sets `approved - fee` only | **Semantic** (cancelled/refunded default 0 may satisfy if fee treated separately ??but fee column itself invalid) |
| `kds_release_authorized` | NOT NULL default false | Not set (relies on default) | OK if INSERT succeeds |

### 6.2 Reconciling migration search result

Repo-wide search for `ALTER TABLE catchmenu_payment.payment_ledger` **ADD COLUMN** or equivalent: **none found** (only RLS in `0021`).

**Conclusion:** As committed migrations, **`0014` + `0098` are internally inconsistent**. Drift is **unreconciled** in repo.

### 6.3 Systemic drift (not isolated to 0098)

Other RPCs INSERT into `payment_ledger` with the same non-0014 column set:

| File | Lines | Pattern |
| --- | --- | --- |
| `0109_create_network_handoff_fallback_rpc.sql` | L916??27 | `payment_method`, `provider_tx_id`, `fee_amount` ??no `intent_id` |
| `0130_create_van_handler_extension.sql` | L396??05 | same + `tax_amount` (also not in 0014) |

604250 alignment must decide whether patch **extends DDL** to match widespread RPC usage, or **rewrites RPCs** to match 0014 ??that decision is **not** made in this ImpactScope.

---

## 7. intent_id Binding Findings

### 7.1 Current `confirm_payment` inputs

`0098` receives: `p_order_id`, `p_provider_tx_id`, `p_correlation_id` ??**not** `intent_id`, **not** `idempotency_key`.

### 7.2 Possible resolution paths (investigation ??not approved design)

| Path | Mechanism | Single intent? | Evidence in repo |
| --- | --- | --- | --- |
| **A. Direct param** | Add `p_intent_id` to RPC | Yes if caller supplies | `0027` pattern L205 |
| **B. order_id lookup** | `payment_intents WHERE order_id = p_order_id AND intent_status NOT IN (FAILED,CANCELLED,EXPIRED)` | **No** ??multiple intents possible per `0014` comment L135; `create_payment_intent` blocks only one *active* non-terminal intent L44??6 | `0027` L44??6 |
| **C. provider key match** | Map `p_provider_tx_id` ??`payment_intents.provider_order_id` or ledger `provider_payment_key` | Uncertain | No join in `0098` |
| **D. idempotency_key** | Match `payment_intents.idempotency_key` | Needs key on confirm path | `0014` L40; **not passed** to `confirm_payment` |
| **E. Toss request row** | `toss_payment_requests WHERE order_id AND payment_key` | One row per `idempotency_key` unique L107 | `0103` L105??07 ??**separate table, no FK to `payment_intents`** |
| **F. correlation_id** | Trace only | Does not identify intent | `0098` L158 |

### 7.3 MVP handoff path gap

`0103` `confirm_toss_payment` (L695??10) calls `confirm_payment` **without creating or linking `payment_intents`**.
Therefore **`intent_id` NOT NULL** cannot be satisfied on Toss MVP path **without** either:

- creating/linking intents upstream, or
- DDL change (nullable `intent_id` / synthetic intent row / backfill policy), or
- append-only alignment patch with explicit binding rule.

### 7.4 no intent / multiple intent discrimination

| Situation | Detectable today? |
| --- | --- |
| **No intent** for order (Toss path) | Yes ??zero rows in `payment_intents` for `order_id` |
| **Multiple intents** (retries) | Possible per DDL comment; `create_payment_intent` prevents multiple *active* non-terminal intents but not historical CONFIRMED + new CREATED after failure |
| **No intent_id on confirm** | `0098` does not query `payment_intents` at all |

---

## 8. provider_payment_key / provider_tx_id Findings

| Aspect | 0014 | 0098 | 0027 |
| --- | --- | --- | --- |
| Column name on ledger | `provider_payment_key` L174 | `provider_tx_id` INSERT L310 | `provider_payment_key` INSERT L267 |
| RPC parameter name | N/A | `p_provider_tx_id` L151 | `p_provider_payment_key` L206 |
| Idempotency lookup | Index on `provider_payment_key` L253??55 | WHERE `provider_tx_id` L197 | Uses param as ledger value L281 |
| Toss mapping | N/A | `p_payment_key` ??`p_provider_tx_id` (`0103` L702) | N/A |

**State:** **One logical field, two names.** 0014 authoritative name is `provider_payment_key`. `0098`+ downstream use `provider_tx_id` **without DDL column**.

**Both columns do not coexist** in 0014 ??only `provider_payment_key` exists in DDL.

---

## 9. fee_amount Findings

| Location | Behavior |
| --- | --- |
| **0014 DDL** | **No `fee_amount` column** on `payment_ledger` |
| **0098 confirm_payment** | Computes `v_fee_amount` L293??03; INSERT L312, L324 |
| **0098 net_amount** | `v_net_amount := p_approved_amount - v_fee_amount` L303 ??differs from 0014 constraint semantics (fee not in cancelled/refunded model) |
| **0027 confirm_payment_from_provider** | Sets `net_amount = p_approved_amount` L280 ??**no fee** |
| **0109 manual payment** | `fee_amount = 0` L937 |
| **0130 VAN** | `fee_amount = 0` L419 |
| **Downstream reads** | `0111`, `0100`, `0120`, `0084` SQL grep references `pl.fee_amount` ??assumes column exists |

**State:** `fee_amount` is **widely assumed** in post-0098 SQL but **absent from 0014 DDL** and **no ADD COLUMN migration** found.

---

## 10. 0027 confirm_payment_from_provider Comparison

**Reference only ??excluded from 604250 edit scope.**

| Dimension | `0027` `confirm_payment_from_provider` | `0098` `confirm_payment` |
| --- | --- | --- |
| **Intent** | Requires `p_intent_id uuid` L205 | No intent param |
| **Ledger INSERT alignment** | Matches 0014: `intent_id`, `ledger_entry_type='APPROVAL'`, `provider_payment_key` L263??88 | Drift columns (§6) |
| **Amount check** | Strict `requested_amount <> p_approved_amount` ??**return error** L244??51 | ±10 log only L267??90 |
| **KDS release** | Updates `conditions_met`; **no** `release_kds_after_payment` L299??09 | Calls `release_kds_after_payment` L348??56 |
| **Payment events** | Inserts `catchmenu_payment.payment_events` L334+ | Uses `catchmenu_ledger.events` L386+ |
| **Webhook usage** | `0038` L294 calls this function | `0098` webhook calls `confirm_payment` L697+ |
| **MVP Toss path** | **Not used** (`0103` ??`0098`) | **Primary** |

### 10.1 Why 0027 is excluded from this slice

1. **604310_Index** L29: `confirm_payment_from_provider` recorded as future split-brain concern; **excluded from 604310**.
2. **604315** scopes 604310 patch to `0098` confirm path ??not `0027`.
3. **0027 is useful as read-only reference** for 0014-aligned INSERT shape, not as edit target.
4. Modifying `0027` would expand blast radius (VAN/webhook `0038`, intent pipeline) without closing primary MVP drift in `0098`.

### 10.2 Historical read-only policy

`0014`, `0098`, `0027` remain **immutable** in repo history. Alignment must use **append-only** patch migration(s) if approved later.

---

## 11. Compile / Runtime Risk Assessment

### 11.1 Fresh sequential migration apply (0014 ??0098)

PostgreSQL validates SQL inside `CREATE OR REPLACE FUNCTION` at function creation time.

**Expected failure modes** if `0014` DDL is applied unchanged before `0098`:

| Error class | Example |
| --- | --- |
| INSERT undefined column | `column "provider_tx_id" of relation "payment_ledger" does not exist` |
| INSERT undefined column | `column "fee_amount" ?? |
| INSERT NOT NULL violation | `intent_id` / `ledger_entry_type` null if INSERT somehow partial |
| SELECT in idempotency block | `provider_tx_id` reference L197 |

**Risk level: HIGH** ??`0098` `confirm_payment` likely **cannot be created** on strict 0014 schema.

### 11.2 Runtime if function exists despite drift (e.g. manual schema)

If production DB was altered out-of-band:

| Risk | Detail |
| --- | --- |
| Orphan ledger rows | Rows without valid `intent_id` break 0014 FK intent |
| Reconciliation queries | Mixed column names break grep-based audits |
| 604310 idempotency | Duplicate checks on `provider_tx_id` depend on undeclared column |

### 11.3 Verification gap

| Check | Status |
| --- | --- |
| `0073_final_verification.sql` asserts `confirm_payment_from_provider` | L566??69 |
| Asserts `confirm_payment` | **Not found** |
| `tests/` directory | **No** confirm_payment / schema drift tests |
| `604314` precondition 0.1 / 0.2 | Documented manual checks ??**not automated** |

---

## 12. Candidate Future Change Files

**Candidate only ??not authorized.**

| Priority | Path | Likely role |
| --- | --- | --- |
| P0 | **New** `sql/migrations/0140_patch_payment_ledger_schema_alignment.sql` (or next free number) | `ALTER TABLE payment_ledger ADD ?? and/or view/compatibility layer ??**human decision required** |
| P0 | **New** patch replacing or wrapping `confirm_payment` | INSERT/WHERE aligned to reconciled DDL |
| P1 | `0103`, `0109`, `0130` | Downstream INSERT alignment if single column contract chosen |
| Reference | `0027` `confirm_payment_from_provider` INSERT L263??88 | 0014-aligned pattern template |
| Reference | `604311`, `604314` §0 | Precondition tests 0.1, 0.2 |
| Blocked downstream | `604310` patch (`0140+` idempotency) | **Must not proceed until 604250 closes** |

**Alignment strategy options (record only ??not decided):**

```text
Option A: Extend payment_ledger DDL (ADD provider_tx_id OR rename mapping, fee_amount, payment_method, provider_response jsonb) + binding rule for intent_id
Option B: Rewrite 0098 INSERT to 0014 columns (intent_id required, provider_payment_key, ledger_entry_type, provider_response_id)
Option C: Hybrid ??DDL extension + 0098 INSERT fix + intent backfill/synthetic intent policy
```

---

## 13. Forbidden Files

Unless a **future approved** ChangeContract explicitly allows:

```text
sql/migrations/0014_create_payment_ledger.sql          (in-place edit forbidden)
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql  (in-place edit forbidden)
sql/migrations/0027_create_payment_intent_rpc.sql      (in-place edit forbidden)
All other existing migration files (in-place edit forbidden)
604252 Overview, 604253 Logic, 604254 TestPlan, 604255 ChangeContract, 604256 Approval
604310 implementation artifacts (604316+) until 604250 closes
catchmenu_app/**, supabase/functions/**, tests/**, python/**, config/package/lockfile
implementation_module, verification_result, audit packets
Codex implementation instructions
```

---

## 14. Migration Numbering Status

Verified `sql/migrations/` (2026-07-01):

| Number | File | Status |
| --- | --- | --- |
| 0136 | `0136_create_dev_audit_log.sql` | Taken |
| 0137 | `0137_patch_missing_functions.sql` | Taken |
| 0138 | `0138_patch_integration_functions.sql` | Taken (single file on disk) |
| 0139 | `0139_create_ai_inference_log.sql` | Taken |
| 0140+ | ??| **No file present** ??next candidate |

**0138 duplication:** Only one `0138_*.sql` on filesystem. No active duplicate number conflict.

**Stale reference:** `900102` / `604311` mention `supabase/migrations/0136_patch_*` ??invalid (no `supabase/migrations/`; 0136 taken).

**604250 patch candidate:** `0140` or next free integer under `sql/migrations/` ??**re-verify at Human Approval**.

---

## 15. Test / Verification References

| Source | Content |
| --- | --- |
| `604314_TestPlan_?? §0 Preconditions | 0.1 `intent_id` binding; 0.2 `provider_payment_key` vs `provider_tx_id` |
| `604314` §1 | Amount hard block policy (604310 ??blocked) |
| `900103` TC-102, TC-110 | Downstream after alignment |
| `0073_final_verification.sql` | Table existence; **no** schema drift assert |
| `0096_schema_final_validation.sql` | Lists `payment_ledger` table name L107 only |
| `604303` §5 | Migration dry-run policy for future patches |

**No repo automated test** validates 0014??098 column compatibility today.

---

## 16. Open Questions

1. **Alignment strategy:** Option A (extend DDL), B (conform RPC to 0014), or C (hybrid)?
2. **`intent_id` on Toss path:** Synthetic intent row, nullable FK, or mandatory upstream `create_payment_intent` before Toss?
3. **Authoritative provider column:** Rename RPC to `provider_payment_key`, add `provider_tx_id` column, or single alias view?
4. **`fee_amount`:** Add column vs derive-only vs store in jsonb payload?
5. **`ledger_entry_type`:** Always `APPROVAL` on confirm ??enforce in patch?
6. **`provider_response` vs `provider_response_id`:** jsonb column vs gateway event FK?
7. **Downstream RPCs:** Align `0109`, `0130`, refund paths in same 604250 contract or separate slices?
8. **0027 / 0038 legacy path:** Leave parallel until split-brain consolidation slice?
9. **Fresh DB apply test:** Who runs sequential migration apply to confirm compile failure before patch?
10. **Owner** assignment before Human Approval.

---

## 17. Non-Implementation Statement

```text
- No SQL, migration, Edge Function, Flutter, Python, or config changes were made.
- 0014, 0098, 0027 were read-only inspected; not modified.
- No 604252??04256 documents were created.
- No Codex implementation was instructed.
- 604310 remains blocked pending 604250 alignment closeout.
```

Next allowed step per `600179`: **604252 Overview** (604250 slice) after Human review of this ImpactScope ??**not authorized in this task**.

---

## Appendix ??Investigation Checklist (20 items)

| # | Question | Answer (repo 2026-07-01) |
| --- | --- | --- |
| 1 | payment_ledger actual DDL? | `0014` L154??39 ??see §4 |
| 2 | intent_id NOT NULL? | **Yes** L160 |
| 3 | Provider identifier column? | **`provider_payment_key` only** in DDL; **`provider_tx_id` not in DDL** |
| 4 | fee_amount exists? | **No** in 0014 |
| 5 | 0098 INSERT columns? | §5.2 ??drift from 0014 |
| 6 | 0098 inserts intent_id? | **No** |
| 7 | 0098 uses provider_payment_key or provider_tx_id? | **`provider_tx_id`** L310 |
| 8 | 0098 references fee_amount? | **Yes** INSERT L312 |
| 9 | Compile/runtime failure risk? | **HIGH** on fresh apply ??§11 |
| 10 | Resolve intent_id from order? | Possible but **not unique** ??§7.2-B |
| 11 | Resolve via provider_payment_key / idempotency_key / correlation_id? | Key/idempotency possible in theory; **0098 does not**; correlation_id trace-only |
| 12 | no intent / multiple intent distinguishable? | Yes / partial ??§7.4 |
| 13 | 0027 vs 0098 differences? | §10 table |
| 14 | 0027 takes intent_id directly? | **Yes** L205 |
| 15 | 0027 uses provider_payment_key consistently? | **Yes** L267, L281 |
| 16 | 0027 excluded from slice? | **Yes** ??§10.1 |
| 17 | 0014/0098/0027 historical read-only? | **Yes** ??policy header |
| 18 | Next patch number? | **0140+** §14 |
| 19 | Highest / duplicate numbers? | Max **0139**; 0138 single file |
| 20 | Tests / verification scripts? | **Gap** ??§15 |
