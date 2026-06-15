# 14005_Report_13000_Wave_4A_POS_Provider_Strategy_Preapply_Dedupe

<< docs-only · Wave 4-A pre-apply verification · dedupe planning only · no moves performed >>

**Project root:** `D:\workspace\yoonsul_wait_order_handoff`
**Verification date:** 2026-06-09
**Source plan:** `docs/00006_Plan_Top_Level_Folder_Consolidation.md` (Band D / Wave 4)
**Git status at verification:** `## main...origin/main [ahead 17]` (clean working tree)

> **Path correction (2026-06-09):** `13000_security_runtime_test_catalog` was later moved to `04900_security_runtime_test_catalog`; archive subfolder renamed to `04999_archive_duplicate_review`. Historical tables below retain pre-move paths.

---

## 1 Executive Summary

Wave 4-A confirms a **split ownership model** on disk versus a **partially deduped index**:

| Axis | Canonical home (index + content) | On-disk duplicate copies |
| --- | --- | --- |
| Near-term readiness (`05100`~`05250`) | `05000` band (`05100`, `05200`) | `13000_security_runtime_test_catalog` (5), `14000_pos_provider_integration_strategy` (11) |
| Long-term POS provider strategy (`05255`~`05410`) | `14000_pos_provider_integration_strategy` | None |
| Security/runtime test catalog (`04970`~`05095`) | `13000_security_runtime_test_catalog` | None |
| App/API projection (`13010`~`13130`) | `13000_app_api_projection` | None |

**Key findings:**

- **16 duplicate basenames** across inspected folders; **0 identical hashes** (all pairs differ in content/size).
- Canonical copies under `05100`/`05200` use **normalized `# NNNNN_Filename` titles**; duplicates in `13000_security`/`14000` retain **older plain-text titles**.
- `00005` already points canonical paths at `05000` band for duplicates; `14000` index lists only `05255`~`05410`.
- `00007` still lists on-disk duplicate files under `13000_security_runtime_test_catalog` and `14000_pos_provider_integration_strategy` (tree/index drift).
- `14000` has **no package README** (numbered or plain).
- `05255` and `05260` exist **only** under `14000` on disk.

**Recommendation:** **Option C first** (dedupe before any parent-folder move), then a limited **Option A** consolidation scope in Wave 4-B. **Do not** apply Option B (13000 parent absorbing `14000`) until duplicates are archived and `13000_app_api_projection` placement is decided.

**Risk rating:** **HIGH** for folder-move-first; **MODERATE** for dedupe-only Wave 4-B.

---

## 2 Current Folder Inventory

| Folder | Exists | Direct `.md` | Subfolders | Doc number range (on disk) |
| --- | --- | ---: | ---: | --- |
| `docs/13000_app_api_projection/` | Yes | 14 | 0 | `13000`, `13010`~`13130` |
| `docs/13000_security_runtime_test_catalog/` | Yes | 20 | 0 | `04970`~`05095`, `05100`~`05140` (dupes), `13000` readme |
| `docs/14000_pos_provider_integration_strategy/` | Yes | 27 | 0 | `05150`~`05250` (dupes), `05255`~`05410` (unique) |
| `docs/05000_customer_handoff_and_implementation_readiness/05100_implementation_readiness_and_provider_verification/` | Yes | 12 | 0 | `05100`~`05190`, plan archive |
| `docs/05000_customer_handoff_and_implementation_readiness/05200_pos_payment_provider_and_kiosk_reuse/` | Yes | 7 | 0 | `05200`~`05250` |

**Folders inspected:** 5
**Total markdown files inspected:** 80

---

## 3 README Status Table

| Folder | Numbered README | Plain `README.md` | Issue |
| --- | --- | --- | --- |
| `13000_app_api_projection` | `13000_Readme_App_Api_Projection.md` | No | OK (title uses spaces: `# 13000 App Api Projection Readme`) |
| `13000_security_runtime_test_catalog` | `13000_Security_Runtime_Test_Catalog_Readme.md` | No | OK |
| `14000_pos_provider_integration_strategy` | **Missing** | No | **Violation — no package README** |
| `05100_implementation_readiness_and_provider_verification` | `05100_Implementation_Readiness_And_Provider_Verification_Readme.md` | No | OK |
| `05200_pos_payment_provider_and_kiosk_reuse` | `05200_Readme_POS_Payment_Provider_And_Kiosk_Reuse.md` | No | OK |

**README violations found:** 1 (`14000` missing numbered README)

---

## 4 Canonical Ownership Analysis

### Q1–Q2: Which folder is canonical POS Provider Integration Strategy home?

**`docs/14000_pos_provider_integration_strategy/`** is the canonical **long-term POS provider integration strategy** home for documents **`05255` through `05410`** (16 unique strategy/extension files on disk).

It is **not** the canonical home for near-term readiness docs `05150`~`05250` — those exist as **stale duplicate copies** on disk; canonical copies live under the `05000` band.

### Q3: Does `13000_security_runtime_test_catalog` belong under POS provider strategy parent?

**No.** It is a **security/runtime test catalog axis** (`04970`~`05095`). It overlaps with readiness only because **five `05100`~`05140` duplicate files** were left on disk after the `05100-10807` packaging wave. After dedupe it should remain a **standalone security test catalog package**, not a POS strategy subfolder.

### Q4: Does `13000_app_api_projection` belong to POS provider strategy?

**No.** It is an **app surface / API projection architecture** package (`13010`~`13130`). It should **remain separate** from POS provider strategy (Option A or future `13100` band), not under a `13000_pos_provider_integration_strategy` parent.

### Q13: Are `05100`/`05200` near-term readiness docs correctly under `05000` band?

**Yes.** Index (`00005` sections 13–14) and normalized titles confirm `05100`/`05200` under `05000_customer_handoff_and_implementation_readiness` are canonical.

### Q14: Does `14000` contain long-term strategy docs that should not move into `05000`?

**Yes.** `05255`~`05410` are long-term provider strategy, pilot, franchise/SaaS pricing, and ecosystem expansion documents. They should **stay in `14000`** (or a future strategy parent), not merge into `05000`.

---

## 5 Duplicate Basename Table (`05100`/`05200` vs `13000`/`14000`)

**Duplicate basename count:** **16**
**Identical hash pairs:** **0** (all 16 pairs differ)

| Basename | File A (canonical) | File B (duplicate) | Size A | Size B | Hash A (prefix) | Hash B (prefix) | Identical | Title A | Title B | Recommendation |
| --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- |
| `05100_Test_Catalog_..._Policy.md` | `05100/...` | `13000_security/...` | 22519 | 21097 | `295bd8bde3a1172a` | `dbce0b0387ed6870` | No | `# 05100_Test_Catalog_...` | `05100 Test Catalog...` (plain) | **canonicalize to 05100**; archive `13000_sec` copy |
| `05110_Implementation_Readiness_..._Policy.md` | `05100/...` | `13000_security/...` | 22762 | 21254 | `e32c217630faaa83` | `dd20931a79d47c66` | No | `# 05110_...` | `05110 Implementation...` (plain) | **canonicalize to 05100**; archive `13000_sec` copy |
| `05120_Runtime_Owner_Registry_..._Policy.md` | `05100/...` | `13000_security/...` | 20899 | 19797 | `b40f3e5fa83a94f7` | `227cc34c21ba679a` | No | `# 05120_...` | `05120 Runtime Owner...` (plain) | **canonicalize to 05100**; archive `13000_sec` copy |
| `05130_Evidence_Packet_Template_..._Policy.md` | `05100/...` | `13000_security/...` | 24704 | 22909 | `b9c75b48d4d78b89` | `3d63450652f5a87f` | No | `# 05130_...` | `05130 Evidence Packet...` (plain) | **canonicalize to 05100**; archive `13000_sec` copy |
| `05140_Blocker_Register_..._Policy.md` | `05100/...` | `13000_security/...` | 26033 | 24348 | `5e84fc86e4f02d27` | `f643f62e52cb4021` | No | `# 05140_...` | `05140 Blocker Register...` (plain) | **canonicalize to 05100**; archive `13000_sec` copy |
| `05150_Toss_POS_Official_..._Policy.md` | `05100/...` | `14000/...` | 25459 | 24010 | `70a55d5f65bf35d1` | `64cdbfdd56d9a3d4` | No | `# 05150_...` | `05150 Toss POS...` (plain) | **canonicalize to 05100**; archive `14000` copy |
| `05160_Controlled_Implementation_Entry_..._Policy.md` | `05100/...` | `14000/...` | 25435 | 23662 | `9686afa25bef168c` | `e6b0d8a75a1ac793` | No | `# 05160_...` | `05160 Controlled...` (plain) | **canonicalize to 05100**; archive `14000` copy |
| `05170_PAYCO_POS_Integration_..._Policy.md` | `05100/...` | `14000/...` | 35748 | 33911 | `3d51f43123221834` | `91058bd86b180b30` | No | `# 05170_...` | `05170 PAYCO POS...` (plain) | **canonicalize to 05100**; archive `14000` copy |
| `05180_POS_Payment_Provider_Integration_..._Policy.md` | `05100/...` | `14000/...` | 20409 | 19224 | `f91c27ba56640e25` | `58133c48fdd146e6` | No | `# 05180_...` | `05180 POS Payment...` (plain) | **canonicalize to 05100**; archive `14000` copy |
| `05190_MVP_Provider_Cutline_..._Policy.md` | `05100/...` | `14000/...` | 17851 | 16669 | `05e725539299e789` | `479f9dc5958227f4` | No | `# 05190_...` | `05190 MVP Provider...` (plain) | **canonicalize to 05100**; archive `14000` copy |
| `05200_POS_Payment_Provider_Document_..._Policy.md` | `05200/...` | `14000/...` | 14828 | 13969 | `3c0e74805599effa` | `6c0a5ee504b2d917` | No | `# 05200_...` | `05200 POS Payment...` (plain) | **canonicalize to 05200**; archive `14000` copy |
| `05210_Mini_Kiosk_And_Kiosk_Provider_..._Policy.md` | `05200/...` | `14000/...` | 19430 | 18218 | `8da07898034f61b1` | `93fa7d6bde006dc8` | No | `# 05210_...` | `05210 Mini Kiosk...` (plain) | **canonicalize to 05200**; archive `14000` copy |
| `05220_Mini_Kiosk_Payment_Flow_..._Policy.md` | `05200/...` | `14000/...` | 20579 | 19307 | `8551b5e7fa2f4c4f` | `4c8d5b8f0a5f5065` | No | `# 05220_...` | `05220 Mini Kiosk Payment...` (plain) | **canonicalize to 05200**; archive `14000` copy |
| `05230_Mini_Kiosk_Session_Identity_..._Policy.md` | `05200/...` | `14000/...` | 22466 | 20987 | `17225b854b1eccaf` | `7fd7c239ab3490ed` | No | `# 05230_...` | `05230 Mini Kiosk Session...` (plain) | **canonicalize to 05200**; archive `14000` copy |
| `05240_MVP_Provider_Cutline_Revision_..._Policy.md` | `05200/...` | `14000/...` | 19596 | 18540 | `a9114c485f9ed479` | `66c7b5983400f0a4` | No | `# 05240_...` | `05240 MVP Provider Cutline...` (plain) | **canonicalize to 05200**; archive `14000` copy |
| `05250_OKPOS_OKDC_Integration_..._Policy.md` | `05200/...` | `14000/...` | 22445 | 20997 | `164c2f9e7d0063be` | `dabf0520a5aec866` | No | `# 05250_...` | `05250 OKPOS OKDC...` (plain) | **canonicalize to 05200**; archive `14000` copy |

### Cross-pair duplicate basename summary

| Pair | Duplicate basenames |
| --- | ---: |
| `05100` vs `13000_security_runtime_test_catalog` | 5 |
| `05100` vs `14000_pos_provider_integration_strategy` | 5 |
| `05200` vs `14000_pos_provider_integration_strategy` | 6 |
| `05200` vs `13000_security_runtime_test_catalog` | 0 |
| `13000_security` vs `14000` | 0 |

---

## 6 Duplicate Document Number Table

**Cross-folder duplicate 5-digit document numbers (policy/readme collisions):** **15**
(Excludes within-folder families like multiple `05100_*` files in `05100` package.)

| Doc # | Locations | Cross-folder duplicate? | Notes |
| --- | --- | --- | --- |
| `05100` | `05100` (readme, plan, policy), `13000_sec` (policy dupe) | Yes (policy file) | Canonical policy: `05100/05100_Test_Catalog_...` |
| `05110`~`05140` | `05100`, `13000_sec` | Yes | 5 readiness dupes in `13000_sec` |
| `05150`~`05190` | `05100`, `14000` | Yes | 5 verification dupes in `14000` |
| `05200` | `05200` (readme + policy), `14000` (policy dupe) | Yes (policy file) | Canonical policy under `05200` |
| `05210`~`05250` | `05200`, `14000` | Yes | 6 kiosk/provider dupes in `14000` |
| `05255`~`05410` | `14000` only | No | Unique long-term strategy lane |
| `04970`~`05095` | `13000_sec` only | No | Native test-catalog lane |
| `13010`~`13130` | `13000_app` only | No | Native projection lane |

---

## 7 05255 / 05260 Location Confirmation

| File | On-disk location | In `00005` | In `00007` tree |
| --- | --- | --- | --- |
| `05255_Assessment_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination.md` | `14000` only | Yes (section 34) | Yes |
| `05260_Policy_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface.md` | `14000` only | Yes (section 34) | Yes |

**Status:** **Confirmed** — `05255` and `05260` exist only under `docs/14000_pos_provider_integration_strategy/` (not under `05000` band).

---

## 8 `13000_app_api_projection` Decision Analysis

- **Role:** Customer/store/admin/support surface projection and API contract boundary (`13010`~`13130`).
- **Overlap with POS provider strategy:** Minimal — `13120_Boundary_Integration_Status_Projection.md` references integration status conceptually but is not a provider strategy document.
- **Overlap with `05100`/`05200`/`14000`:** **No duplicate basenames.**
- **Recommendation:** **Keep separate** as `docs/13000_app_api_projection/` (Option A). Do not move under a POS provider strategy parent in Wave 4.

---

## 9 `13000_security_runtime_test_catalog` Decision Analysis

- **Role:** Security/runtime **test catalog** lane (`04970`~`05095`) plus readme.
- **Problem:** Contains **5 stale duplicates** (`05100`~`05140`) from pre-`05100-10807` root cleanup.
- **Overlap with `14000`:** No shared basenames; complementary (test evidence vs long-term strategy).
- **Recommendation:** Remain a **standalone security test catalog axis**. After dedupe, folder should contain **15 native files** (`04970`~`05095` + readme). Optional future parent: security/validation band — **not** POS provider strategy.

---

## 10 `14000_pos_provider_integration_strategy` Decision Analysis

- **Role:** Long-term POS provider integration strategy and pilot/franchise expansion (`05255`~`05410`).
- **Problem:** Contains **11 stale duplicates** (`05150`~`05250` policies) alongside **16 unique** strategy files.
- **After dedupe:** Should contain **16 unique strategy files** + **new numbered README** (recommended `14000_Readme_POS_Provider_Integration_Strategy.md`).
- **Recommendation:** **Canonical long-term POS provider strategy home** (Option A). Do not absorb `05100`/`05200` near-term readiness content.

---

## 11 Proposed Target Tree Options

### Option A — Keep axes separate (post-dedupe)

```text
docs/
  05000_customer_handoff_and_implementation_readiness/
    05100_implementation_readiness_and_provider_verification/   [canonical 05100~05190]
    05200_pos_payment_provider_and_kiosk_reuse/                 [canonical 05200~05250]
  13000_app_api_projection/                                   [unchanged · separate]
  13000_security_runtime_test_catalog/                        [deduped · 04970~05095 only]
  14000_pos_provider_integration_strategy/                    [deduped · 05255~05410 only]
```

### Option B — Create `13000_pos_provider_integration_strategy` parent (defer)

```text
docs/13000_pos_provider_integration_strategy/
  13000_security_runtime_test_catalog/          [move — NOT recommended pre-dedupe]
  14000_pos_provider_integration_strategy/      [move]
docs/13000_app_api_projection/                  [separate or needs_review]
```

**Blockers for Option B:** duplicate files on disk; `13000_app_api_projection` axis mismatch; `13000_security` is not provider strategy.

### Option C — Dedupe first, move later (recommended path)

1. Archive/remove 16 duplicate files from `13000_security` (5) and `14000` (11).
2. Add `14000` numbered README.
3. Sync `00007` tree with `00005` canonical paths.
4. Re-evaluate parent-folder consolidation only after dedupe validation.

---

## 12 Recommended Option

**Option C → then limited Option A**

1. **Wave 4-B dedupe only** — no folder moves.
2. Keep `13000_app_api_projection`, `13000_security_runtime_test_catalog`, and `14000_pos_provider_integration_strategy` as **separate top-level packages**.
3. Defer Option B (`13000_pos_provider_integration_strategy` parent) until user explicitly wants band consolidation **and** dedupe is complete.

---

## 13 Risk Rating

### **HIGH** (if Wave 4 applies folder moves before dedupe)

- 16 same-basename, different-content file pairs would create index/path ambiguity.
- `00007` already over-lists duplicate on-disk files.
- `14000` lacks package README.

### **MODERATE** (if Wave 4-B is dedupe-only + index/tree sync)

- Archive moves are reversible if copies preserved under `docs/_conflicts/` per governance.
- No document number renumbering required.
- Canonical copies already indexed in `00005`.

---

## 14 User Decisions Needed

| # | Decision | Recommendation |
| --- | --- | --- |
| 1 | Archive 16 duplicate files from `13000_security` (5) and `14000` (11)? | **Yes** — preserve under `docs/_conflicts/duplicate_review/` or mark `archived` in index |
| 2 | Keep `13000_app_api_projection` separate from POS strategy? | **Yes** |
| 3 | Keep `13000_security_runtime_test_catalog` as security test catalog (not POS strategy subfolder)? | **Yes** |
| 4 | Create `14000_Readme_POS_Provider_Integration_Strategy.md` during Wave 4-B? | **Yes** |
| 5 | Proceed with Option B parent `13000_pos_provider_integration_strategy` in Wave 4? | **No — defer** until post-dedupe review |
| 6 | Confirm canonical near-term readiness remains under `05000` band? | **Yes** (already indexed) |

---

## 15 Suggested Wave 4-B Apply Scope (if safe)

**In scope (dedupe + hygiene only):**

1. Move 16 duplicate files to `docs/_conflicts/duplicate_review/13000_14000_wave4b/` (or delete only after archive copy — **do not delete without archive** per governance rules).
2. Create `14000_Readme_POS_Provider_Integration_Strategy.md` in `14000`.
3. Update `00007` tree: remove duplicate entries from `13000_security` and `14000` listings; align with `00005`.
4. Add consolidation plan Wave 4-B audit note (dedupe applied).

**Out of scope for Wave 4-B:**

- Moving `13000_app_api_projection`, `13000_security_runtime_test_catalog`, or `14000` under a new parent.
- Merging `05100`/`05200` into `14000`.
- Renumbering any documents.
- Touching `05000` band canonical files.

---

## 16 Stale Reference Check (`00005` / `00007`)

| Artifact | Status |
| --- | --- |
| `00005` canonical paths for `05100`/`05200` | **Current** — points to `05000` band |
| `00005` duplicate `05100`~`05250` in `13000`/`14000` | **Absent** (removed in Wave 2 index cleanup) |
| `00005` `14000` section | Lists **`05255`~`05410` only** (correct unique strategy set) |
| `00005` `13000_security` section | Lists **`04970`~`05095` + readme** (no `05100`~`05140` rows — correct index) |
| `00007` tree | **Stale** — still lists `05100`~`05140` under `13000_security` and `05150`~`05250` under `14000` on disk |
| `00007` directory notes | Partial `05000` band notes present; no dedicated `14000` strategy note |

---

## Verification Checklist

| Item | Result |
| --- | --- |
| Report file created | Yes |
| Folders inspected | 5 |
| Folders moved | **None** |
| Files moved | **None** |
| Commit performed | **No** |
