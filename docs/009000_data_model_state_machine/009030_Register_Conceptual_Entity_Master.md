# 009030_Register_Conceptual_Entity_Master.md

## Purpose

This is a conceptual entity master, not a physical schema.

It consolidates entity candidates currently scattered across `5010` and other docs.

It must not define SQL, columns, migrations, RLS, or RPC.

This document is documentation-only and does not approve database, API, UI, Supabase, POS, payment, printer, Franchise OS, AI, CRM, or ad implementation.

## 2 Entity Group: SaaS Context

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `tenant` | SaaS customer or contract boundary. | Platform and tenant governance context. | Not always a store or legal seller. | Owns stores, users, package context, policies. | Whether every MVP store requires tenant object. |
| `company` | Operating company or brand-level entity. | Tenant or group governance context. | Not automatically legal entity. | May group stores and operating groups. | Whether required for single-store tenants. |
| `legal_entity` | Tax, contract, settlement, or payment-relevant entity. | Legal/tax/payment review context. | Not operational runtime owner by default. | May relate to company, tenant, stores, payment profile. | Whether required before platform payment exists. |
| `operating_group` | Operational grouping such as region, franchise group, or tourist zone. | Store operations and reporting context. | Not necessarily legal or billing entity. | Groups stores and managers. | Whether needed in early MVP. |
| `store` | Actual operating location where waiting, Mini Kiosk, and handoff occur. | Store runtime context. | Not the same as tenant or company. | Belongs to tenant; uses runtime/config/menu/integration. | Whether standalone MVP store can skip full hierarchy. |

### ⚠️ 2026-08-11 개정 — 구현 대응 (0-A `601500`)

위 §2 개념 엔터티가 실제로 구현된 결과는 다음과 같다(마이그레이션 `0168`/`0169`, 2026-08-11 완료).

| 개념 엔터티 | 실제 구현 | 상태 |
|---|---|---|
| `legal_entity` | **`catchmenu_hq.legal_entities`** (신규) | 구현됨 — 사업자등록번호 보유 |
| `company` | 기존 `catchmenu_hq.franchise_brands` | **신규 테이블 없음** — 브랜드 축이 담당 |
| `operating_group` | 기존 `catchmenu_hq.store_groups` (`group_type='REGION'`만) | 부분 사용 |
| `tenant` / `store` | 기존 `catchmenu_hq.tenants` / `stores` | 기존 유지 + `stores.legal_entity_id` FK 신규 |
| **(신규) 자연인** | **`catchmenu_hq.owners`** | 본 문서에 대응 개념 없음 — 아래 주의 |
| **(신규) 대표권** | **`catchmenu_hq.legal_entity_representatives`** | 동상 |
| **(신규) 조직 역할** | **`catchmenu_hq.legal_entity_person_roles`** | 동상 |

본 문서의 **`company` = "Not automatically legal entity"** 원칙은 구현에서 지켜졌다 —
두 축이 서로 다른 테이블(`franchise_brands` / `legal_entities`)로 분리돼 있다.

> **⚠️ `owners` 명칭 주의** (`601501` §2.4.1): `catchmenu_hq.owners`는
> **"법적 사업주체와 관계를 맺는 자연인(natural person)"** 을 뜻한다.
> **SaaS 계정 소유자(tenant admin)도 아니고, 지분 보유자도 아니다.**
> 로그인·세션·권한 주체는 0-B(staff identity)/0-C(authorization) 소관이며,
> `owners` 행을 계정으로 재활용해서는 안 된다.

> **⚠️ 4개 개념 분리** (`601501` §0.6): 소유권(지분) · 대표권 · 조직역할 · 사업자등록 식별자는
> **서로 독립된 개념**이며 하나에서 다른 하나를 추론할 수 없다.
> 이 중 **소유권(지분)만 아직 모델링되지 않았다.**

> **전역 테이블 주의**: 위 신규 4개 테이블에는 **`tenant_id` 컬럼이 없다.**
> Owner/LegalEntity가 여러 tenant에 걸칠 수 있는 전역 개념이기 때문이며,
> 판별 기준과 요건은 `010004` §4.1 참조.

근거: `601501_ERD_Tenant_Company_HQ_Store.md` §0.6/§2.4.1, `sql/migrations/0168`.

## 3 Entity Group: Runtime Configuration

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `store_runtime` | Current operating mode and visibility for a store. | Store-level runtime governance. | Not POS/payment truth. | Uses package, feature flags, integration, payment, language, menu profile. | Whether it is versioned. |
| `store_package_plan` | Commercial and product adoption mode. | Tenant/store contract context. | Not automatic enablement of high-risk features. | Controls available feature flag candidates. | Downgrade and upgrade behavior. |
| `store_feature_flags` | Explicit runtime switches. | Admin configuration context. | Not approval by itself. | Tied to package and approval workflow. | Feature flag granularity. |
| `store_integration_profile` | Store integration level for staff screen, Store Agent, printer, POS API, or Full OS. | Integration boundary context. | Not proof that integration works everywhere. | Relates to Store Agent, printer, POS API attempts. | Store-specific validation depth. |
| `store_payment_profile` | Payment authority mode. | Legal/tax/payment context. | Not order handoff by default. | May relate to legal entity, POS, platform payment future. | When platform payment becomes eligible. |
| `store_language_profile` | Languages exposed to customer surfaces. | Store/menu/customer experience context. | Not AI translation approval. | Relates to menu profile and customer sessions. | Initial language set. |
| `store_menu_profile` | Menu content readiness and source context. | Store content context. | Not menu snapshot by itself. | Produces or governs menu snapshots. | Internal management vs import. |
| `store_agent_profile` | Store Agent or local support capability context. | Integration/support context. | Not staff confirmation or POS truth. | Relates to Store Agent events and recovery. | Support policy and runtime validation. |

## 4 Entity Group: Customer / Session Runtime

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `customer_session` | Customer-facing session from QR, NFC, link, or Mini Kiosk entry. | Customer surface context. | Not membership account by default. | Links to waiting, handoff, Mini Kiosk, language. | Anonymous, phone-based, or member-linked. |
| `waiting_session` | Customer or party waiting lifecycle. | Store waiting context. | Not table assignment by itself. | Links to customer session, store, handoff. | No-show timing and duplicate handling. |
| `handoff_session` | Bridge between customer order intent and store confirmation. | Store/customer handoff context. | Not POS transaction. | Links to waiting, order candidate, table/pickup context. | Whether pickup and dine-in share one model. |
| `mini_kiosk_session` | Lightweight ordering session without waiting requirement. | Mini Kiosk customer/store-assisted context. | Not physical kiosk implementation. | Links to customer session, menu, order candidate. | Separate session vs customer session reuse. |

## 5 Entity Group: Menu / Order Intent

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `menu_snapshot` | Menu state shown when customer creates intent. | Store menu/profile context. | Not live menu editor schema. | Contains menu item snapshots and option context. | Internal management vs import. |
| `menu_item_snapshot` | Stable item/options display at time of intent. | Order candidate review context. | Not live menu item definition. | Belongs to menu snapshot and cart/order candidate. | Snapshot depth for translations/options. |
| `cart_snapshot` | Customer selections before or at submission. | Customer/order intent context. | Not confirmed order. | Links customer session, menu snapshots, order candidate. | Whether carts remain editable after submit. |
| `order_candidate` | Customer-submitted candidate for staff review. | Customer intent and store review context. | Not confirmed order, POS sale, or payment. | Links cart, handoff, waiting, staff action. | Expiry and duplicate strategy. |
| `preorder_request` | Pre-seating or pre-pickup request for staff review. | Handoff/operational timing context. | Not paid preorder by default. | Links waiting or handoff and order candidate. | Whether it is separate from order candidate. |
| `order_intent` | Broad conceptual customer intent before store execution. | Customer intent truth context. | Not POS or payment truth. | May be represented by cart/order candidate/preorder request. | Whether to keep as abstract concept only. |

## 6 Entity Group: Store Operation / Handoff

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `staff_action` | Staff action changing waiting, handoff, confirmation, cancellation, or recovery. | Store operational authority. | Not automatically POS or payment truth. | Links sessions, order candidate, recovery, audit. | Staff authority tiers. |
| `store_console_action` | Action performed through store console projection. | Store console context. | Not necessarily admin approval. | Links staff role, target state, audit. | Whether separate from staff_action. |
| `store_agent_event` | Store Agent delivery/status event. | Integration observation context. | Not staff confirmation. | Links Store Agent profile, order candidate, recovery. | Delivery receipt semantics. |
| `printer_event` | Printer attempt/result event. | Printer integration context. | Not POS transaction. | Links order candidate, recovery, audit. | Retry and duplicate prevention. |
| `pos_api_attempt` | Attempt to create or update order through POS API. | POS integration boundary context. | Not POS success unless success response exists. | Links integration profile, order candidate, audit, recovery. | Idempotency ownership. |
| `manual_pos_input_marker` | Staff marker that manual POS input is needed or completed. | Store operational context. | Not invented POS transaction ID. | Links staff action, order candidate, recovery. | Proof required for completion. |

## 7 Entity Group: Admin / Governance

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `admin_user` | Admin-side person or account. | Platform/tenant/store/admin context. | Not customer identity. | Has role assignments and support sessions. | Identity provider choice. |
| `admin_role_assignment` | Role granted to user within a context. | Access governance context. | Not universal authority. | Links admin user, context, role. | Review cadence. |
| `admin_context_scope` | Tenant/company/legal/store scope for admin access. | Access boundary context. | Not data export permission by itself. | Links role assignment and visible surfaces. | Context hierarchy details. |
| `admin_change_request` | Requested runtime, package, feature, payment, or integration change. | Approval workflow context. | Not activation. | Links requester, approver, validation, audit. | Workflow depth. |
| `admin_approval` | Approval or rejection of governed action. | Authority and audit context. | Not evidence alone. | Links change request, actor, audit. | Approval chain by risk. |
| `runtime_config_change` | Actual conceptual runtime config change event. | Configuration lineage context. | Not hidden mutation. | Links approval, before/after, audit. | Versioning strategy. |
| `support_access_session` | Scoped, time-bounded support access. | Support governance context. | Not standing access or approval. | Links requester, approver, support action, audit. | Dual approval for sensitive actions. |

## 8 Entity Group: Recovery / Audit / Compliance

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `manual_recovery_item` | Operational item requiring human review or repair. | Recovery queue context. | Not original event itself. | Links original event, recovery actions, staff/support. | SLA and assignment ownership. |
| `recovery_action` | Append-only action taken to resolve or progress recovery. | Recovery lineage context. | Not overwrite of original event. | Links recovery item, actor, reason, audit. | Closure reason taxonomy. |
| `audit_event` | Audit-visible event for important state or authority changes. | Audit truth context. | Not mutation by itself. | Links actor, target, before/after summary. | Retention and immutability. |
| `audit_evidence_record` | Evidence packet or record supporting review. | Compliance/support/legal context. | Not approval. | Links audit events, export, support, recovery. | Evidence packet shape. |
| `compliance_review_record` | Review record for dispute, access, export, legal, or future handoff. | Compliance governance context. | Not runtime state mutation. | Links evidence, reviewer, decision. | Review authority. |

## 9 Entity Group: Data Governance / Future Intelligence

| entity | meaning | ownership/context | what it is not | likely relationships | open questions |
| --- | --- | --- | --- | --- | --- |
| `data_capture_category` | Category describing why a signal is captured. | Data governance context. | Not raw data itself. | Links classification, retention, analytics. | Category taxonomy. |
| `data_classification` | Sensitivity and usage classification. | Security/privacy context. | Not permission by itself. | Links export, retention, sharing policy. | Classification labels. |
| `data_export_event` | Audit event for data/report export. | Export governance context. | Not export approval by itself. | Links export request, recipient, evidence. | Export evidence retention. |
| `data_sharing_policy` | Boundary for tenant/store/external sharing. | Privacy and contract context. | Not automatic sharing. | Links classification, export, future Franchise OS. | Contract model. |
| `data_sanitization_job` | Conceptual process for aggregate/anonymized/pseudonymized data. | Analytics governance context. | Not implemented pipeline. | Links analytics dataset and source categories. | Minimum aggregation threshold. |
| `analytics_dataset` | Governed dataset for approved analytics. | Analytics/reporting context. | Not ad targeting permission. | Links sanitization, classification, export. | Opt-in/out and retention. |
| `franchise_intelligence_export` | Future permitted intelligence material export. | Future Franchise OS boundary. | Not raw runtime transfer. | Links analytics dataset, contract, audit. | Export contract and aggregation level. |
| `franchise_recommendation` | Future recommendation created from intelligence. | Future intelligence context. | Not execution. | Links export, review, application event. | Recommendation authority. |
| `recommendation_review` | Admin review of future recommendation. | Approval governance context. | Not automatic application. | Links recommendation, approval, audit. | Reviewer role. |
| `recommendation_application_event` | Controlled application of approved recommendation. | Future runtime governance context. | Not direct Franchise OS mutation. | Links review, runtime config change, audit. | Rollback model. |

## 10 Non-Entity Clarifications

- customer wording rule is not a transaction.
- feature flag is not approval.
- printer event is not POS transaction.
- POS API attempt is not POS API success.
- recommendation is not execution.
- evidence is not approval.

## 11 SaaS Runtime Cross-Reference

SaaS context axes and runtime profiles are governed by `docs/03000_saas_runtime/003020_Tenant_Company_Legal_Operating_Group_Context_Model.md` and `docs/03000_saas_runtime/003030_Store_Runtime_Profile_Model.md`.

Physical schema must not be inferred directly from `03000` docs.

## 11.1 Conceptual Model Consolidation Cross-Reference

- Context entity alignment is defined in `docs/09000_data_model_state_machine/009070_Context_Entity_Alignment_Model.md`.
- Runtime profile/change request conceptual entities are defined in `docs/09000_data_model_state_machine/009080_Runtime_Profile_And_Change_Request_Entity_Model.md`.
- Admin/support/audit lineage is defined in `docs/09000_data_model_state_machine/009100_Admin_Support_Audit_Entity_Lineage_Model.md`.
- Future profile/analytics state boundaries are defined in `docs/009000_data_model_state_machine/009110_Boundary_Future_Profile_And_Analytics_State.md`.
- Physical schema must not be inferred directly.

## 12 Open Decisions

- whether customer identity is anonymous, phone-based, or member-linked in early MVP.
- whether company/legal_entity are required for all tenant types in MVP.
- whether store_runtime is versioned.
- whether menu_snapshot is managed internally or imported.
- whether support_access_session requires dual approval.

## 13 Current Status

Status: active conceptual entity master. No physical schema.
