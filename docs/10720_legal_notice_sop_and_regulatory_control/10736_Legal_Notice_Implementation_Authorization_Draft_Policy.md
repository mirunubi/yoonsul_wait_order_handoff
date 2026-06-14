# 10736_Legal_Notice_Implementation_Authorization_Draft_Policy

## 1. Purpose

This document defines the Legal Notice Implementation Authorization Draft Policy for Catch Menu.

The previous document `10735 Legal Notice Static Registry Readiness Check Policy` confirmed that the Legal Notice Static Registry is ready as a planning package, while runtime implementation remains deferred.

This document defines what a future implementation authorization packet must contain before any coding begins.

This document does not authorize coding.

It defines the authorization format only.

---

## 2. Core Position

Implementation authorization must be narrow, explicit, and bounded.

The correct rule is:

Planning complete does not mean coding approved.  
Readiness complete does not mean SQL approved.  
A large legal notice system must not be implemented in one uncontrolled wave.  
Each implementation wave must define exact scope, files, tables, fields, policies, RPCs, events, tests, rollback, and non-goals.  
Any missing scope must remain out of implementation.  
If a feature is not explicitly listed, it is not authorized.  
AI may help draft implementation packets.  
AI cannot self-authorize implementation.  

Legal notice implementation must proceed by controlled packets.

---

## 3. Scope

This policy applies to future implementation authorization for:

- legal notice master tables
- notice version tables
- i18n text tables
- trigger rule tables
- surface mapping tables
- store notice setting tables
- franchise/HQ lock tables
- evidence packet tables
- acknowledgement evidence tables
- privacy consent evidence tables
- alcohol verification evidence tables
- refund/no-show evidence tables
- support dispute packet tables
- review queue tables
- admin read-only surfaces
- customer Notice Center read-only surfaces
- legal notice seed files
- RLS policies
- RPC functions
- audit event emission
- test fixtures
- rollback scripts

This document defines authorization governance only.

---

## 4. Authorization Packet Principle

Every future coding request must be expressed as an implementation authorization packet.

The packet must answer:

1. What exact scope is authorized?
2. What exact scope is excluded?
3. Which tables are created?
4. Which columns are created?
5. Which RLS rules are created?
6. Which RPCs are created?
7. Which audit events are emitted?
8. Which seed data is inserted?
9. Which UI surfaces are touched?
10. Which tests must pass?
11. Which rollback path exists?
12. Which high-risk functions remain deferred?
13. Which documents authorize this packet?
14. Who approved the packet?
15. What must not be implemented?

If the packet cannot answer these, coding must not begin.

---

## 5. Implementation Packet Required Sections

A valid packet must include:

| Section | Required |
|---|---:|
| Packet ID | Yes |
| Packet title | Yes |
| Purpose | Yes |
| Authorized scope | Yes |
| Explicit non-goals | Yes |
| Target files | Yes |
| Tables | Required if database change |
| Columns | Required if database change |
| Indexes | Required if database change |
| RLS policies | Required if database change |
| RPC functions | Required if RPC change |
| Audit events | Required |
| Seed data | Required if seed change |
| UI surfaces | Required if UI change |
| Tenant isolation plan | Yes |
| Security review | Yes |
| Test plan | Yes |
| Rollback plan | Yes |
| Runtime deferral carry-over | Yes |
| Approval statement | Yes |

No section may be left vague.

---

## 6. Implementation Packet State Registry

Recommended packet states:

| State | Meaning |
|---|---|
| `DRAFT` | Authorization draft only |
| `REVIEW_REQUIRED` | Needs review |
| `APPROVAL_PENDING` | Awaiting approval |
| `APPROVED_FOR_STATIC_ONLY` | Static implementation allowed only |
| `APPROVED_FOR_READ_ONLY_RUNTIME` | Read-only runtime allowed only |
| `APPROVED_FOR_LIMITED_WRITE_RUNTIME` | Limited write allowed |
| `BLOCKED` | Cannot implement |
| `SUPERSEDED` | Replaced by later packet |
| `EXPIRED` | Approval no longer valid |
| `COMPLETED` | Implemented and verified |
| `ROLLED_BACK` | Rolled back |

This document remains in draft-governance mode.

It does not mark any packet approved.

---

## 7. Authorization Scope Levels

Recommended scope levels:

| Scope Level | Meaning |
|---|---|
| `STATIC_DOC_ONLY` | Documentation only |
| `STATIC_SCHEMA_ONLY` | Tables/columns only, no runtime |
| `STATIC_SEED_ONLY` | Seed data only |
| `READ_ONLY_ADMIN_VIEW` | Admin can view, not change |
| `READ_ONLY_CUSTOMER_VIEW` | Customer can view current approved notices |
| `LIMITED_ADMIN_TOGGLE` | Store toggle for optional notices only |
| `LIMITED_ACK_CAPTURE` | Capture acknowledgement for a narrow flow |
| `LIMITED_SUPPORT_VIEW` | Case-scoped support evidence view |
| `NO_PAYMENT_EFFECT` | No payment/refund mutation |
| `NO_POS_KDS_EFFECT` | No POS/KDS mutation |
| `NO_LEGAL_DECISION` | No automated legal decision |
| `FULL_RUNTIME` | Not allowed unless separately reviewed |

Initial implementation should start at static or read-only scope.

---

## 8. Recommended First Safe Implementation Packet

The first future implementation packet should be narrow.

Recommended first packet:

    Legal Notice Static Master Schema Only

Allowed:

- create legal notice master table
- create legal notice version table
- create legal notice i18n text table
- create review state fields
- create tenant/global scope fields
- create audit reference fields
- create indexes
- create deny-by-default RLS skeleton
- no customer runtime
- no admin toggle runtime
- no acknowledgement runtime
- no support export runtime
- no seed approval runtime

This is only a recommendation.

It is not authorization.

---

## 9. Packet Example: Static Schema Only

A future static schema packet may include:

| Item | Example |
|---|---|
| Packet ID | `LN_IMPL_001` |
| Scope | Static schema only |
| Tables | `legal_notice_master`, `legal_notice_version`, `legal_notice_i18n_text` |
| Runtime | None |
| UI | None |
| Seed | None or test-only |
| RLS | Deny by default |
| Audit | Schema change audit only |
| Tests | Table exists, columns exist, RLS enabled |
| Non-goals | No customer display, no admin toggle, no evidence capture |
| Rollback | Drop created tables if empty |

This example is not approved by this document.

---

## 10. Packet Example: Static Seed Only

A future static seed packet may include:

| Item | Example |
|---|---|
| Packet ID | `LN_IMPL_002` |
| Scope | Static seed only |
| Tables used | Existing legal notice master tables |
| Seed data | Reviewed seed subset only |
| Seed state | `SEED_DRAFT` or `REVIEW_REQUIRED` |
| Runtime | None |
| Customer display | None |
| Admin display | Optional read-only after separate packet |
| Legal approval | Not implied by insert |
| Tests | Seed count, unique codes, valid family |
| Rollback | Delete seed rows by batch ID if unused |

Seed inserted does not mean active.

---

## 11. Packet Example: Read-Only Admin Preview

A future read-only admin preview packet may include:

| Item | Example |
|---|---|
| Packet ID | `LN_IMPL_003` |
| Scope | Admin read-only preview |
| UI | Owner/HQ admin preview page |
| Data | Approved or draft notices by role |
| Writes | None |
| Toggle | None |
| Evidence | None |
| Customer display | None |
| RLS | Tenant/store scoped read |
| Support | None |
| Tests | Store A cannot see Store B notice settings |
| Non-goals | No activation, no customer popup, no evidence capture |

Read-only admin preview is safer than toggle runtime.

---

## 12. Packet Example: Customer Notice Center Read-Only

A future customer Notice Center packet may include:

| Item | Example |
|---|---|
| Packet ID | `LN_IMPL_004` |
| Scope | Customer read-only Notice Center |
| Data | Current approved notices only |
| Writes | None |
| Consent | None |
| Ack capture | None |
| Payment effect | None |
| POS/KDS effect | None |
| Historical evidence | None |
| i18n | Approved texts only |
| Fallback | Controlled fallback |
| Tests | Current notices only, no internal notes exposed |
| Non-goals | No required popup, no checkout block, no legal decision |

Notice Center read-only does not replace contextual notices.

---

## 13. Packet Example: Limited Acknowledgement Capture

A future acknowledgement packet must be extremely narrow.

Example:

| Item | Example |
|---|---|
| Packet ID | `LN_IMPL_005` |
| Scope | Acknowledgement capture for one notice family |
| Notice family | Privacy required consent only |
| Surfaces | Signup only |
| Evidence | Version, locale, surface, timestamp, session/customer |
| Runtime effect | Signup may require consent |
| Exclusions | No alcohol, no refund, no payment, no no-show |
| Tests | Ack required, refused state, withdrawal if applicable |
| Legal review | Required before approval |
| Rollback | Disable specific signup consent runtime |

This requires a stronger review than static schema.

---

## 14. Packet Example: Limited Store Toggle

A future store toggle packet must exclude high-risk notices by default.

Allowed candidate:

- low-risk store facility notices
- parking notice
- pet policy notice
- self-bar notice
- break time notice
- store contact notice

Excluded by default:

- privacy consent
- alcohol age-gate
- refund/cancellation
- no-show/deposit
- payment/PG
- allergen/raw food
- tax/receipt
- staff protection
- emergency lock

Store toggle must not begin with high-risk notices.

---

## 15. Required Non-Goals Section

Every implementation packet must include non-goals.

Example non-goals:

- Does not implement customer popup runtime.
- Does not implement acknowledgement capture.
- Does not implement refund decision.
- Does not implement alcohol verification.
- Does not implement payment mutation.
- Does not implement POS/KDS mutation.
- Does not implement support export.
- Does not implement emergency lock.
- Does not implement legal approval workflow.
- Does not make seed data active.
- Does not authorize production deployment.

Non-goals protect scope.

---

## 16. Target File Declaration

Every implementation packet must list target files.

Required file categories:

| Category | Example |
|---|---|
| SQL migration | Migration file path |
| Seed file | Seed file path |
| RLS file | Policy file path |
| RPC file | Function file path |
| Test file | Test path |
| Admin UI file | UI route/component path |
| Customer UI file | UI route/component path |
| Service file | Service path |
| Type file | Type/model path |
| Docs update | Documentation path |

No target file means no implementation.

---

## 17. Table And Column Declaration

Database packets must declare:

- table name
- schema name
- purpose
- columns
- column types
- nullability
- default values
- foreign keys
- indexes
- check constraints
- unique constraints
- timestamps
- audit reference fields
- tenant/store fields
- soft delete or status fields
- retention fields

Vague table creation is not allowed.

---

## 18. RLS Declaration

Any table implementation must declare RLS.

RLS packet must define:

| Item | Requirement |
|---|---|
| RLS enabled | Required |
| Default deny | Required |
| Platform admin access | Defined |
| HQ access | Tenant/franchise scoped |
| Store owner access | Store scoped |
| Support access | Case scoped if applicable |
| Customer access | Only own/session/current approved notices |
| Insert authority | Restricted |
| Update authority | Restricted |
| Delete authority | Usually denied |
| Service role | Controlled |
| Test coverage | Required |

No RLS means no multi-tenant SaaS readiness.

---

## 19. Audit Event Declaration

Any implementation packet must declare audit events.

Examples:

- `LEGAL_NOTICE_MASTER_CREATED`
- `LEGAL_NOTICE_VERSION_CREATED`
- `LEGAL_NOTICE_I18N_TEXT_CREATED`
- `LEGAL_NOTICE_SEED_IMPORTED`
- `LEGAL_NOTICE_ADMIN_VIEWED`
- `LEGAL_NOTICE_CUSTOMER_VIEWED`
- `LEGAL_NOTICE_ACK_CAPTURED`
- `LEGAL_NOTICE_SETTING_CHANGED`
- `LEGAL_NOTICE_EVIDENCE_CREATED`
- `LEGAL_NOTICE_EXPORT_REQUESTED`
- `LEGAL_NOTICE_EMERGENCY_LOCK_APPLIED`

Only events in packet scope may be implemented.

---

## 20. Test Plan Declaration

A valid packet must include tests.

Test categories:

| Category | Example |
|---|---|
| Schema test | Tables and columns exist |
| Constraint test | Unique notice code |
| RLS test | Cross-tenant denied |
| Role test | Store owner cannot edit platform lock |
| i18n test | Locale fallback controlled |
| Evidence test | Version required |
| Negative test | Unapproved notice not customer-visible |
| Audit test | Change creates audit |
| Rollback test | Rollback works |
| Seed test | Seed status remains draft |

No test plan means no implementation.

---

## 21. Rollback Declaration

Every packet must define rollback.

Rollback must include:

- what can be rolled back
- what cannot be rolled back
- data safety condition
- migration rollback plan
- seed rollback plan
- UI disable plan
- feature flag disable plan
- evidence preservation rule
- audit preservation rule
- customer impact
- support impact

Rollback must not delete evidence history.

---

## 22. Feature Flag Boundary

Future implementation should use feature flags.

Candidate flags:

| Feature Flag | Meaning |
|---|---|
| `legal_notice_master_enabled` | Master registry visible |
| `legal_notice_admin_readonly_enabled` | Admin read-only preview |
| `legal_notice_customer_center_enabled` | Customer Notice Center |
| `legal_notice_seed_import_enabled` | Seed import |
| `legal_notice_ack_capture_enabled` | Ack capture |
| `legal_notice_store_toggle_enabled` | Store toggle |
| `legal_notice_support_packet_enabled` | Support packet |
| `legal_notice_i18n_fallback_enabled` | i18n fallback |
| `legal_notice_emergency_lock_enabled` | Emergency lock |

Flags do not replace authority checks.

---

## 23. Legal Review Requirement

Implementation packets require legal review when they touch:

- privacy consent
- marketing consent
- third-party provision
- alcohol age-gate
- refund/cancellation
- no-show/deposit
- allergen/raw food
- payment/PG notices
- tax/receipt notices
- staff protection
- emergency lock
- evidence export
- customer-facing high-risk notices

Static schema may not require legal wording approval, but still requires security review.

---

## 24. Security Review Requirement

Every implementation packet requires security review for:

- tenant isolation
- role authority
- RLS
- support access
- customer access
- masking
- export
- audit
- evidence immutability
- service role usage
- secret handling
- feature flags
- logging
- rollback

Legal notice system is compliance-sensitive infrastructure.

---

## 25. AI Assistance Boundary

AI may assist by:

- drafting implementation packets
- checking scope consistency
- identifying missing non-goals
- generating test checklist
- suggesting table/field names
- identifying RLS risks
- comparing implementation to policy docs
- generating review summaries

AI must not:

- approve implementation
- expand scope during coding
- infer missing authorization
- implement unlisted features
- skip RLS
- skip tests
- treat planning docs as approval
- activate runtime
- deploy to production

AI must stay inside the packet.

---

## 26. Authorization Failure Conditions

Implementation must be blocked if:

- packet has no explicit approval
- target files are missing
- RLS is undefined
- tenant scope is undefined
- non-goals are missing
- test plan is missing
- rollback plan is missing
- high-risk legal review is missing
- scope includes broad runtime
- customer-facing display is authorized without i18n/fallback plan
- evidence capture is authorized without retention plan
- support export is authorized without masking plan
- payment/refund notice is authorized without payment/KDS/POS review
- alcohol notice is authorized without staff verification review

Failure condition must stop coding.

---

## 27. Authorization Review Checklist

Before approving implementation, review:

1. Is scope narrow?
2. Are non-goals explicit?
3. Are target files listed?
4. Are tables and columns listed?
5. Is tenant/store scope defined?
6. Is RLS defined?
7. Is audit defined?
8. Is i18n defined if customer-facing?
9. Is evidence defined if acknowledgement-related?
10. Is support access defined if dispute-related?
11. Is masking defined if export-related?
12. Is rollback defined?
13. Are tests defined?
14. Are high-risk legal reviews defined?
15. Are AI boundaries preserved?
16. Is runtime deferral updated correctly?
17. Is production deployment excluded unless explicitly approved?

No checklist pass means no implementation.

---

## 28. Implementation Wave Ordering

Recommended future wave order:

| Wave | Scope |
|---|---|
| Wave 1 | Static schema only |
| Wave 2 | Static seed draft only |
| Wave 3 | Admin read-only preview |
| Wave 4 | Customer Notice Center read-only |
| Wave 5 | Store onboarding readiness read-only |
| Wave 6 | Support evidence read-only skeleton |
| Wave 7 | Limited acknowledgement capture for privacy only |
| Wave 8 | Optional low-risk store toggle |
| Wave 9 | High-risk flows after legal/payment/POS/KDS review |
| Wave 10 | Emergency lock after authority model is proven |

High-risk runtime comes late.

---

## 29. Anti-Patterns

Avoid:

- treating this document as coding approval
- implementing all legal notice tables at once without packet
- creating tables without RLS
- inserting 200 notices as active
- creating customer popups before Notice Center read-only
- implementing store toggle before locks and permissions
- implementing evidence before audit and retention
- implementing support export before masking
- implementing alcohol runtime before staff verification
- implementing refund runtime before payment/KDS/POS contracts
- letting AI expand scope from planning docs
- skipping tests because documents are detailed
- using feature flags as substitute for authorization
- leaving non-goals vague
- deploying to production from draft authorization

These anti-patterns must remain prohibited.

---

## 30. Runtime Deferral

This document defines future implementation authorization format only.

It does not authorize:

- database implementation
- SQL migration
- seed insertion
- RLS implementation
- RPC implementation
- admin UI implementation
- customer UI implementation
- consent runtime
- evidence runtime
- support runtime
- emergency lock runtime
- production deployment

All runtime remains deferred.

---

## 31. Validation Checklist

Validation must confirm:

1. Authorization packet principle is defined.
2. Required packet sections are defined.
3. Packet state registry is defined.
4. Authorization scope levels are defined.
5. Recommended first safe packet is defined.
6. Static schema example is defined.
7. Static seed example is defined.
8. Read-only admin preview example is defined.
9. Customer Notice Center read-only example is defined.
10. Limited acknowledgement example is defined.
11. Limited store toggle boundary is defined.
12. Required non-goals section is defined.
13. Target file declaration is defined.
14. Table and column declaration is defined.
15. RLS declaration is defined.
16. Audit event declaration is defined.
17. Test plan declaration is defined.
18. Rollback declaration is defined.
19. Feature flag boundary is defined.
20. Legal review requirement is defined.
21. Security review requirement is defined.
22. AI assistance boundary is defined.
23. Authorization failure conditions are defined.
24. Authorization review checklist is defined.
25. Implementation wave ordering is defined.
26. Anti-patterns are listed.
27. Coding remains unauthorized.
28. Runtime remains deferred.

---

## 32. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Legal Notice Static Seed Review And Approval Workflow Policy`
- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10731 Customer Notice Center UX Static Surface Index Policy`
- `10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10734 Legal Notice Support Playbook And Case Reason Code Policy`
- `10735 Legal Notice Static Registry Readiness Check Policy`

It also references:

- `10053 Catch Menu Mini Kiosk Foundation Static Specification Packet Policy`
- `10054 Catch Menu Mini Kiosk Foundation Static Artifact Target File Map And Coding Authorization Draft Policy`
- `10055 Catch Menu Mini Kiosk Foundation Explicit Static Coding Authorization Packet Draft Policy`
- `10056 Static Artifact Authorization Readiness Review And User Approval Gate Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`

It prepares:

- `10800 Store Onboarding And Sales Setup Axis Index`
- future explicit implementation authorization packets

This document is architecture boundary planning only.

It does not authorize coding.

---

## 33. Final Rule

Catch Menu legal notice implementation may only begin through a separate, narrow, explicit implementation authorization packet.

That packet must define scope, non-goals, target files, tables, columns, RLS, RPCs, audit events, seed data, UI surfaces, tenant isolation, tests, rollback, legal review, security review, and approval.

Nothing in the Legal Notice Static Registry sequence authorizes broad coding.

Static planning is complete enough to support future authorization.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.