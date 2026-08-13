# 601706_Audit_Stage3_Adjacent_Domain_Cursor.md

> ⚠️ **3단계 인접 도메인 대조 · 검증 결과이며 판정이 아니다**
>
> `000701` §47.1의 **3단계(인접 도메인 대조)** 산출물이다.
> `601705` ERD 를 인접 ACTIVE 문서와 대조해 충돌을 기록한 것이며,
> 어느 쪽이 옳은지 판정하지 않았다. 판정은 `601702` §1.25~§1.26 이 했다.
>
> **원작자 배제**(`000701` §37): `601705` 는 Claude Code 가 작성했으므로
> 검증자에서 제외했다. 이 검증은 Cursor 가 수행했다.
>
> **같은 작업을 Codex 도 독립 수행했다 — `601707`.**
> 두 결과의 발견이 갈렸다(`000701` §35).
> Cursor 는 외부 어휘 충돌과 누락(`Merchant Company` 부재, store 상태축)을,
> Codex 는 ERD 내부 정합성(미정 관계를 확정 기호로 표기)을 잡았다.
>
> 수행: Cursor, 2026-08-13. 필수 인접 문서 11개 전수 대조.

**Subject**: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md`  
**Method**: `000701` §47.1 step 3 — vocabulary · FK · boundary verification against 11 ACTIVE adjacent docs  
**Verifier**: Cursor (Claude Code excluded per `000701` §37)  
**Date**: 2026-08-13  
**Output path**: `tools/_c_stage_review_cursor.md` *(mandatory; do not use `_c_stage_adjacent_domain_review.md`)*

**Constraints applied**: read-only verification; no ERD defense; no right/wrong adjudication; `601500`/`601501` not used as alignment proof; SQL ≠ ground truth.

---

## V1. Vocabulary Conflicts

| # | `601705` notation | Adjacent doc notation | Source | Character |
|---:|---|---|---|---|
| 1 | `MERCHANT_ACCOUNT` | `merchant account` / Merchant Account | `000170` L100, L115–L126 | 동일 |
| 2 | `MERCHANT_ACCOUNT` | *(entity absent; root axis is `tenant` only)* | `003020` L20, L79 | `601705`에만 있음 |
| 3 | `TENANT` | `tenant` | `003020` L20; `009030` L17; `007010` L20, L28; `010004` L78 | 동일 |
| 4 | `TENANT` | *(policy §4–§7 names Merchant Account as top-level; `tenant` appears in implementation-drift block only)* | `000170` L100 vs L411–L413 | `000170` 정책 본문 축에 없음 |
| 5 | `LEGAL_ENTITY` | `legal_entity` | `003020` L22; `009030` L19; `009070` L20; `007010` L22, L30; `010640` L95, L222–L241 | 동일 |
| 6 | `LEGAL_ENTITY` | `Merchant Company` (business/owner-side operating company; billing/tax/contract reference) | `000170` L169–L197, L1015 | 의미다름 — `000170` uses Merchant Company for legal/billing grouping; no `legal_entity` term in policy body |
| 7 | `PERSON` | `owners` (natural person; not account owner) | `009030` L47–L58 | 이름다름 |
| 8 | `PERSON` | *(no named natural-person entity in ACTIVE conceptual table body)* | `009030` L15–L21 | `601705`에만 `PERSON` 개념명 |
| 9 | `STORE` | `merchant store` / Merchant Store | `000170` L199–L214 | 이름다름 |
| 10 | `STORE` | `store` | `003020` L24; `009030` L21; `007010` L24, L32 | 동일 |
| 11 | `STORE` | `stores` (SQL table in drift tables) | `000170` L413; `010004` L141 | 이름다름 |
| 12 | `Company` (Candidate §6 L254) | `company` = operating company or brand entity **within tenant scope** | `003020` L21; `009030` L18; `009070` L19; `007010` L29 | 의미다름 |
| 13 | `Company` (Candidate §6 L254) | `company` = CatchMenu platform operator / SaaS operating boundary | `000150` L149–L177, L255–L263 | 동일 *(with `601705` Candidate definition)* |
| 14 | `BusinessUnit` (Candidate §6 L255) | `business_unit` = CatchMenu internal operational responsibility | `000150` L256–L263 | 동일 *(Candidate)* |
| 15 | `BusinessUnit` (Candidate §6) | `COMPANY` / `BUSINESS_UNIT` scope types (authorization taxonomy) | `020320` L241–L264 | 의미다름 |
| 16 | `OperatingGroup` (Candidate §6 L256) | `operating_group` | `003020` L23; `009070` L21; `007010` L31 | 동일 |
| 17 | *(absent)* | `Merchant Company` | `000170` L169–L197, L240–L244, L256–L262 | `601705`에 없음 |
| 18 | *(absent from Core/Candidate)* | `company` → `franchise_brands` (tenant-scoped brand axis) | `003020` L50, L63 | `601705`에 없음 |
| 19 | *(absent)* | `brand_id` / brand scope dimension | `010004` L80; `010640` L93, L128 | `601705`에 없음 *(Brand Core exclusion L61)* |
| 20 | `MERCHANT_ACCOUNT` | `merchant_id` = provider-side merchant account | `010640` L103 | 이름다름 / 의미다름 |
| 21 | `Representative` / `PersonRole` | `legal_entity_representatives` / `legal_entity_person_roles` | `009030` L48–L49 | 이름다름 |
| 22 | *(User — External §7.2)* | `primary_owner_user_id`, merchant user account | `000170` L120; `020310` L454–L471 | `601705` §4.4 L201, §10 O9 — 미정 only |
| 23 | `Owner` (forbidden per §1.2) | `Owner(사람)` / `owners` | `010004` L138; `009030` L54–L56 | `601705` avoids bare `Owner`; adjacent docs use `owners` table name or Owner(사람) in suspended/explanatory blocks |
| 24 | `company` homonym across doc set | Same English token, two incompatible ACTIVE definitions (rows 12 vs 13) | `003020` L21 vs `000150` L149–L155 vs `601705` L254 | 의미다름 — cross-document homonym |

---

## V2. Relationship · Cardinality Conflicts

| # | Relationship | `601705` | Adjacent doc | Source | Conflict? |
|---:|---|---|---|---|---|
| 1 | Tenant ↔ MerchantAccount | **1:1** (§3 L135; §5.1 R1 L220) | No MerchantAccount entity; `tenant` is sole SaaS root | `003020` L20, L79 | **어긋남** — relationship absent in adjacent doc |
| 2 | Tenant ↔ MerchantAccount | **1:1** | Merchant Account = top-level customer relationship; no parallel Tenant entity in policy body | `000170` L100, L128 | **어긋남** — dual top-level vs single top-level |
| 3 | Tenant ↔ MerchantAccount 1:N (or denial of 1:1) | **1:1 asserted** | No ACTIVE statement affirming or denying 1:1 or 1:N | All 11 required | **인접문서 침묵** — neither support nor deny |
| 4 | MerchantAccount → Store | **1:N** (§3 L137; R2 L221) | Merchant account may have one or more merchant stores | `000170` L203; `020320` L991–L1000 | 일치 |
| 5 | Tenant → Store | **1:N** (§3 L138; R4 L223) | Store belongs to tenant | `003020` L24; `009070` L22 | 일치 |
| 6 | Store parent paths | **Both** `TENANT→STORE` **and** `MERCHANT_ACCOUNT→STORE` (§2 L103; §3 L137–L138) | Tenant path: store belongs to tenant. Store fields: `merchant_account_id`, optional `merchant_company_id` — no tenant FK in recommended fields | `003020` L24; `000170` L207–L209 | **어긋남** — dual parent edges; adjacent docs each specify one path |
| 7 | MerchantAccount → MerchantCompany → Store | **Not modeled** | Account → optional/required Company → Store | `000170` L240–L244, L256–L262, L207–L209 | **어긋남** — intermediate layer missing |
| 8 | LegalEntity → MerchantAccount | **1:N allowed** (§3 L136; R3 L222) | No LE↔MA relationship in adjacent ACTIVE docs | `000170`, `003020`, `009030` | **인접문서 침묵** |
| 9 | LegalEntity → Store | **1:N** (§3 L139; R5 L224) | Store may link to legal context; LE→Store direction not cardinality-fixed in ACTIVE body | `003020` L22–L24, L84 | 부분 일치 |
| 10 | Store → LegalEntity (reverse count) | **미정** (U1 L232) | Store should have legal operator; MVP LE required (suspended open-decision block only cites impl) | `003020` L24 *may link*; suspended block L69 | **부분 어긋남** — “must be explicit” partially reflected; count open on both sides in ACTIVE body |
| 11 | LegalEntity ↔ Tenant direct edge | **None** (§4.3 L189) | No direct relationship; indirect via stores; may span tenants | `003020` suspended block L59–L60; `010004` L138–L143 | 일치 |
| 12 | Store ↔ company / operating_group | **No Formal ERD edges** (OperatingGroup Candidate §6 only) | Store may belong to operating_group and company/legal context; parallel axes | `003020` L24, L83–L84; `009070` L19–L22, L33 | **어긋남** — parallel-axis links absent on STORE |
| 13 | Person ↔ LegalEntity (Representative / PersonRole) | Axis exists; cardinality **미정** (§3 L140–L141; U3/U4 L234–L235) | Junction tables in suspended impl notes; no ACTIVE cardinality rule | `009030` L47–L49 | **인접문서 침묵** |

---

## V3. Boundary Intrusion

| Check | `601705` location | Intrusion? | Adjacent reference |
|---|---|---|---|
| Staff / User / Session / Role / Permission in Core Formal ERD | §7.2 L293–L304 only; not in §3 | **No** | `020310` L452+; `020320` L84+ |
| Franchise OS / FranchiseAgreement as internal entities | §7.1 L272–L291 external box | **No** | `000150` §11 (cited L286) |
| Ownership / equity modeled in Core | U5 L236 — **미모델링**; §8 L341 | **No** | `000150` suspended warning on ownership_percent |
| Company / BusinessUnit promoted to Core physical entities | §6 L242–L266 Candidate only; §0.1 L24 | **No persistence intrusion** | `000150` L261; `601702` §1.21 |
| `Representative` / `PersonRole` in Core Formal ERD | §3 L140–L141 | **Borderline** — not Role/Permission; named distinct from 0-C | `020320` scope/role separate |
| Dual customer root (`TENANT` + `MERCHANT_ACCOUNT`) | §2 L100; §3 L135 | **Domain-layer tension**, not 0-B/0-C leakage | V2 #1–2 |
| Provider `merchant_id` | Not in Core | **No** | `010640` L103 |
| Admin / support context axes | Not modeled | **No intrusion** (omission — V4) | `009070` L23–L25 |

**V3 conclusion**: No structural 0-B/0-C/Franchise-OS entity import into §3 Formal ERD. Primary issue is **cross-document vocabulary/domain layering**, not foreign-spiral entity import.

---

## V4. Omissions

| # | Adjacent rule / concept | Source | `601705` reflection | If missing — plausible reason |
|---:|---|---|---|---|
| 1 | `tenant_id` required on tenant-owned objects | `010004` L78, L102 | **Partial** — §4.2 L177 cites rule; §3 has no context-field layer | Attributes deferred by design §3 L130–L131 |
| 2 | Mandatory context field matrix (`store_id`, `legal_entity_id`, `brand_id`, `operating_group_id`, …) | `010004` L76–L88 | **Partial** — LE in §4.3; no `brand_id` / `operating_group_id` on STORE | Brand excluded L61; OG in Candidate only |
| 3 | Legal entity scope required for financial finality | `010640` L222–L241 | **Yes** — §4.3 L187 | — |
| 4 | Operating group ≠ financial authority | `010640` L247–L264 | **Partial** — OperatingGroup meaning §6 L256; no store↔OG edge | Candidate / persistence OPEN |
| 5 | Store **service** status vocabulary (independent from account status) | `000170` L451–L474 | **No** — §4.5 silent; §4.2 L179 tenant status 미정 | Deferred / not in ERD scope |
| 6 | Store **operating** status (physical operation vs service) | `000170` L476+ | **No** | Same |
| 7 | **Trial** status (merchant and store) | `000170` L498+ | **No** — §4.4 L201 lists fields as 미정 O9 | Deferred to step 4 |
| 8 | `company` ≠ `operating_group` ≠ `legal_entity` as parallel axes | `009070` L19–L22, L30–L33; `003020` L83 | **Partial** — LE Core; OG/company Candidate; **company Candidate ≠ SaaS-runtime `company`** | §6 L254 homonym unresolved |
| 9 | **Merchant Company** layer | `000170` L169–L197, L240–L262 | **No** — not Core, Candidate, or External | Structural gap vs `000170` |
| 10 | Store recommended fields: `merchant_company_id`, `service_status`, `trial_status` | `000170` L207–L216 | **No** in §4.5 | O9 / 미정 |
| 11 | Admin five-axis navigation (tenant, company, legal_entity, operating_group, store) | `007010` L20–L32; `007040` L39–L43 | **Partial** — 3/5 in Core or Candidate; no admin_context entity | UI scope, not 0-A persistence |
| 12 | Merchant user ↔ `merchant_account_id` | `020310` L454–L471 | **No** (§7.2 boundary) | By design — 0-B |
| 13 | MERCHANT_ACCOUNT / MERCHANT_STORE scope types | `020320` L989–L1011 | **No** (§7.2) | By design — 0-C |
| 14 | Store may link to **company** and **operating_group** | `003020` L24, L84 | **No** Formal edges | Candidate §6; O4 |
| 15 | Tenant subscription vs isolation orthogonal states | `000170` L411–L418 | **No** — §4.2 L179 미정 | Upstream drift; not ERD-modeled |
| 16 | `brand_id` when brand context matters | `010640` L93; `010004` L80 | **No** | Brand excluded from Core L61 |
| 17 | Natural person in conceptual master ACTIVE body | `009030` L15–L21 | **Partial** — `PERSON` in `601705` §4.1; absent from 009030 table | Naming added in 0-A wave |

---

## V5. Similarity to `601501` (AUTHORITY SUSPENDED — independent-derivation check)

| # | Item | `601705` | `601501` | Same? | Notes |
|---:|---|---|---|:---:|---|
| 1 | Natural person label | `PERSON` (§4.1) | `OWNERS` / Owner(사람) (§0.1 L42) | Partial | Intent aligned; labels differ |
| 2 | Core entity set | PERSON, TENANT, MERCHANT_ACCOUNT, LEGAL_ENTITY, STORE | OWNERS, TENANTS, LEGAL_ENTITIES, STORES (+ junctions) | Partial | `601705` adds MERCHANT_ACCOUNT |
| 3 | Tenant → Store 1:N | §3 L138; R4 | §1 Mermaid L147 | **Yes** | |
| 4 | LegalEntity → Store 1:N | §3 L139; R5 | §0.1 L42; §1 L146 | Partial | Same LE→Store direction |
| 5 | Store → LegalEntity count | **미정** U1 L232 | **Exactly 1** (§0.1 L49) | **No** | Strongest structural divergence |
| 6 | Tenant ↔ MerchantAccount | **1:1** L135 | *(no MerchantAccount)* | **No** | |
| 7 | LegalEntity → MerchantAccount | 1:N allowed L136 | Not modeled | **No** | |
| 8 | MerchantAccount → Store | 1:N L137 | Not modeled | **No** | |
| 9 | Person ↔ LE Representative | Axis; cardinality 미정 | N:M via `legal_entity_representatives` (§1 L144–L145) | Partial | |
| 10 | Person ↔ LE PersonRole | Axis; cardinality 미정 | N:M via `legal_entity_person_roles` (§1 L142–L143) | Partial | |
| 11 | Ownership modeling | U5 미모델링 L236 | Not modeled (§0.6) | **Yes** | |
| 12 | LE global; no direct Tenant FK | §4.3 L189 | §0.1 L62; §0.3 | **Yes** | |
| 13 | Operating group persistence | OperatingGroup Candidate §6 | `store_groups` in Formal ERD §1 | Partial | `601501` persists; `601705` defers |
| 14 | Company / brand axis | Company Candidate (platform operator L254) | `franchise_brands` as `003020` company (§0.3 L79) | **No** | Different meaning and placement |
| 15 | Franchise OS internals | §7.1 external | External | **Yes** | |
| 16 | User / Staff / Session / Role | §7.2 boundary L301–L303 | Not in Core | **Yes** | |
| 17 | Anti–dual-FK doctrine | Dual TENANT+MA paths to STORE L103, L137–L138 | §0.1 L49–L53 rejects split truth for store legal operator | **No** | `601501` warns one fact / two FKs; `601705` draws two store parent edges |

---

## Summary

| Item | Findings | Of which **severe** |
|---|---:|---:|
| V1 Vocabulary | 24 | **6** (#4, #6, #12–#13 homonym pair, #17, #24) |
| V2 Relationship · cardinality | 13 | **4** (#1–2, #6 dual store parents, #7 Merchant Company layer) |
| V3 Boundary intrusion | 8 checks | **0** structural cross-spiral intrusions |
| V4 Omissions | 17 | **5** (#5–7 store status axes; #9 Merchant Company; #8/#14 company/OG parallel links) |
| V5 `601501` similarity | 17 | **3** notable divergences (#5, #6–7, #17) |

**Severe** = documented mismatch that blocks step 4 harmonization until Human resolves (not “ERD is wrong”).

---

## Blocker List (step 4 entry)

Each item cites **`601705` line(s)** and **adjacent doc section/line(s)**.

### B1. `company` homonym — platform operator vs tenant-scoped brand entity

| Side | Location |
|---|---|
| `601705` | L254 — Candidate `Company` = “CatchMenu platform operator 경계” |
| `601705` | L110 — Candidate box groups `Company` with internal org axes (§1.21) |
| `000150` | L149–L155 — company = who operates CatchMenu as a **platform** |
| `003020` | L21 — company = operating company or brand entity **within tenant scope** |
| `007010` | L29 — company = operating company or brand operating entity |
| `009070` | L19 — company = operating company or brand entity |
| `007040` | L40 — “Do not treat company as legal entity automatically” *(tenant-scoped admin company)* |

**Conflict fact**: Same token `company`; incompatible ACTIVE definitions. Step 4 vocabulary merge blocked until disambiguation rule exists.

---

### B2. `Merchant Company` absent — `000170` three-layer hierarchy vs `601705` two-layer

| Side | Location |
|---|---|
| `601705` | *(no Merchant Company in §3, §4, §6, §7)* |
| `601705` | L137 — `MERCHANT_ACCOUNT \|\|--o{ STORE` direct |
| `601705` | §11 L407 — cites `000170` §4, §7 only (not §6–§9) |
| `000170` | L82–L94 — three concepts: Merchant Account / Merchant Company / Merchant Store |
| `000170` | L169–L197 — Merchant Company definition |
| `000170` | L207–L209 — store carries `merchant_company_id` |
| `000170` | L240–L244 — single-store: account → optional company → store |
| `000170` | L256–L262 — multi-store: account → company → multiple stores |

**Conflict fact**: Adjacent merchant-context policy prescribes an intermediate **Merchant Company** layer; `601705` routes Account→Store directly and uses **LEGAL_ENTITY** for legal operator (§4.5 L209) without bridging to Merchant Company vocabulary.

---

### B3. Dual root customer axes (`TENANT` + `MERCHANT_ACCOUNT` 1:1) — not in adjacent ACTIVE set

| Side | Location |
|---|---|
| `601705` | L100, L135 — `TENANT ═══1:1═══ MERCHANT_ACCOUNT` |
| `601705` | L220 — R1 cardinality 1:1 |
| `601705` | L197 — cites `000170` §4 “최상위 SaaS 고객 관계” for MA while also modeling separate TENANT |
| `003020` | L20 — `tenant` = root SaaS boundary; no MerchantAccount axis |
| `000170` | L100, L128 — Merchant Account = **top-level** customer relationship; no Tenant entity in policy §4 |

**Conflict fact**: Adjacent docs each nominate a **single** top-level customer axis; `601705` pairs two with 1:1. No adjacent ACTIVE doc states this relationship (support or deny).

---

### B4. Dual store parent paths (`TENANT→STORE` and `MERCHANT_ACCOUNT→STORE`)

| Side | Location |
|---|---|
| `601705` | L103 — conceptual diagram: both paths into STORE |
| `601705` | L137–L138 — Formal ERD: `MERCHANT_ACCOUNT \|\|--o{ STORE` and `TENANT \|\|--o{ STORE` |
| `601705` | L208 — §4.5 “tenant에 속한다” |
| `601705` | L199 — §4.4 MA includes multiple stores |
| `003020` | L24 — store belongs to **tenant** |
| `000170` | L207–L208 — store recommended field `merchant_account_id` (no tenant_id in §7 field list) |

**Conflict fact**: Two parent edges to STORE; adjacent docs each document one attachment path. Consistency / drift rules for two FK truths not defined in adjacent set (cf. `601501` §0.1 L49–L53 single-FK doctrine — V5 #17, authority suspended).

---

### B5. Store lifecycle status axes (`000170` §14–§16) not reflected

| Side | Location |
|---|---|
| `601705` | §4.5 L203–L212 — no service/operating/trial status attributes |
| `601705` | §4.2 L179 — tenant status “미정” |
| `601705` | §10 O9 L396 — `primary_owner_user_id` etc. deferred |
| `000170` | L451–L474 — §14 Store Service Status (independent from account status) |
| `000170` | L476+ — §15 Store Operating Status |
| `000170` | L498+ — §16 Trial Status |

**Conflict fact**: Policy-defined store status vocabulary and separation rules absent from `601705` entity definitions; step 4 alignment with merchant-context policy incomplete.

---

### B6. SaaS-runtime `company` / `operating_group` parallel axes not on STORE in Formal ERD

| Side | Location |
|---|---|
| `601705` | §3 L133–L141 — STORE linked only to TENANT, MERCHANT_ACCOUNT, LEGAL_ENTITY |
| `601705` | §6 L246–L256 — OperatingGroup Candidate only; no store edges |
| `601705` | L254 — Company Candidate = platform operator (not `003020` company) |
| `003020` | L24 — store may link to operating_group and company/legal context |
| `003020` | L83–L84 — parallel axes; store may belong to OG and company/legal context |
| `009070` | L19–L22, L33 — company and operating_group parallel to legal_entity; store belongs to tenant |

**Conflict fact**: Adjacent SaaS-runtime alignment docs require store linkage to **company** and **operating_group** context axes; Formal ERD omits both edges. Candidate `OperatingGroup` does not substitute for `003020`/`009070` company axis (`franchise_brands` mapping L50).

---

## Additional Documents Reviewed

| Document | Reason |
|---|---|
| `docs/001000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md` | Referenced by `003020` L100 — confirms tenant/store as Active MVP runtime context; does not introduce MerchantAccount or Tenant↔MA cardinality |

**Excluded per task rules**: `docs/990000_legacy_quarantine/**`, `docs/_migration_history/**`, `**/archive_duplicate_review/**`, `**/*_duplicate_review/**`, `docs/implementation_evidence/**`, `*_KO.md`.

**Not added** (referenced but non–Core-5 or redundant): `601502`/`601503`/`601510` (suspended `601500` path); `000190` (franchise boundary covered via `000150` + `601705` §7.1).

---

## Method Notes

- All **11 required** documents read in full or targeted sections for Core-5 axes, tenant isolation, admin context, merchant/store policy, auth boundaries.  
- `601702` §1.22–§1.24 noted as **provenance inside `601705`**, not adjacent-domain authority for this step.  
- Suspended blocks in adjacent docs (`601500` implementation notes) used only where they carry **valid concept warnings** (`600020` §1.1); not as alignment proof.  
- SQL cited only as drift reference (`601705` §8); not ERD ground truth.  
- No ERD modification proposals. No right/wrong adjudication.
