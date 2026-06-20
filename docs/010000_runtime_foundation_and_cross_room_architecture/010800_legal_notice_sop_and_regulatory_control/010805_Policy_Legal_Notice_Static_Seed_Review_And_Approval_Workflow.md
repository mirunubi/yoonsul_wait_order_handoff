# 010805_Policy_Legal_Notice_Static_Seed_Review_And_Approval_Workflow.md

## Purpose

This document defines the Legal Notice Static Seed Review, Approval, Version Promotion, Legal Validation, i18n Validation, Tenant Scope Validation, Store Readiness, and Controlled Release Workflow Policy for Catch Menu.

The previous document `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy` defined legal notice toggle authority, permission boundaries, HQ lock, platform lock, high-risk review, variable editing, rollback, and deployment governance.

This document focuses on how the initial legal notice master pool is seeded, reviewed, approved, promoted, and prepared for controlled future runtime use.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Static seed data is not production approval.

The correct rule is:

Seeded notice text is draft master data until reviewed.  
A notice row in DB is not a legally approved notice.  
A notice version must pass review before customer display.  
High-risk legal families require legal/HQ review.  
i18n text requires controlled translation review.  
Trigger rules require surface and evidence review.  
Store toggle defaults require policy review.  
Mandatory locks require authority review.  
Seed promotion must be auditable.  
Rollback must be possible.  
Deprecated or rejected notices must not be activated.  

Static seed is inventory.

Approval is governance.

---

## 3. Scope

This policy applies to:

- initial 200 legal notice pool
- future legal notice additions
- legal notice family taxonomy
- notice code assignment
- initial Korean reference text
- localized text seed
- trigger rule seed
- surface mapping seed
- retention class seed
- default toggle seed
- platform mandatory lock seed
- franchise/HQ policy seed
- legal review workflow
- i18n review workflow
- privacy review workflow
- payment/refund review workflow
- alcohol review workflow
- support evidence review
- release readiness
- deprecation and rollback

This policy defines workflow governance only.

---

## 4. Static Seed Lifecycle

Recommended lifecycle:

| Stage | Meaning |
|---|---|
| `SEED_DRAFT` | Notice captured as seed draft |
| `STRUCTURE_VALIDATED` | Code/family/version fields validated |
| `LEGAL_REVIEW_PENDING` | Awaiting legal review |
| `DOMAIN_REVIEW_PENDING` | Food/privacy/payment/alcohol review pending |
| `I18N_REVIEW_PENDING` | Translation review pending |
| `TRIGGER_REVIEW_PENDING` | Trigger/surface review pending |
| `EVIDENCE_REVIEW_PENDING` | Evidence capture review pending |
| `APPROVED_FOR_STATIC_MASTER` | Approved as master data |
| `APPROVED_FOR_CUSTOMER_DISPLAY` | Approved for customer-facing use |
| `APPROVED_FOR_STORE_TOGGLE` | Approved for store admin toggle |
| `ACTIVE_READY` | Ready for runtime activation later |
| `REJECTED` | Rejected |
| `DEPRECATED` | Retired |
| `BLOCKED` | Must not be used |

Seed lifecycle must be visible.

---

## 5. Seed Intake Requirements

Each seed notice must include:

| Field | Requirement |
|---|---|
| Notice code | Stable and unique |
| Notice family | Required |
| Notice title | Required |
| Korean reference text | Required |
| Risk class | Required |
| Enforcement class | Required |
| Required acknowledgement flag | Required |
| Suggested surface | Required |
| Suggested trigger | Required |
| Legal basis reference | Optional but recommended |
| Retention class | Required |
| Owner domain | Required |
| Review requirement | Required |
| Initial state | `SEED_DRAFT` |
| Audit reference | Required |

Seed intake must reject unclassified free text.

---

## 6. Notice Code Review

Notice codes must be stable.

Recommended review checks:

1. Code is unique.
2. Code follows naming pattern.
3. Code family prefix is correct.
4. Code sequence does not collide.
5. Code does not contain store-specific data.
6. Code does not change when wording changes.
7. Code remains stable across versions.
8. Deprecated codes remain reserved.

Example:

    FOOD_ALLERGEN_001
    ALCOHOL_ID_011
    PAYMENT_CANCEL_036
    DEVICE_DAMAGE_142

Notice code is identity, not wording.

---

## 7. Family Classification Review

Each notice must be classified into one family.

Recommended family review:

| Review Question | Purpose |
|---|---|
| Is this food safety? | Allergy, hygiene, raw food |
| Is this alcohol/youth protection? | ID, adult, proxy order |
| Is this privacy? | Personal data, marketing, location |
| Is this payment/refund? | Cancellation, deposit, PG |
| Is this store facility? | CCTV, child, pet, safety |
| Is this review/IP? | Review, content, copyright |
| Is this hardware/system? | Tablet, POS, outage |
| Is this coupon/event? | Promotion abuse |
| Is this tax/receipt? | VAT, invoice |
| Is this staff protection? | Abuse, harassment |
| Is this disaster/exception? | Force majeure |

Ambiguous notices require domain review.

---

## 8. Risk Class Review

Risk class must be assigned before approval.

Recommended risk classes:

| Risk Class | Meaning |
|---|---|
| `LOW_INFORMATIONAL` | Simple information |
| `MEDIUM_OPERATIONAL` | Operational notice |
| `HIGH_CUSTOMER_DISPUTE` | Likely dispute impact |
| `FOOD_SAFETY_HIGH` | Allergy/health/safety |
| `ALCOHOL_LEGAL_HIGH` | Alcohol/youth/legal |
| `PRIVACY_LEGAL_HIGH` | Privacy/consent |
| `PAYMENT_FINANCIAL_HIGH` | Payment/refund/tax |
| `STAFF_SAFETY_HIGH` | Staff protection |
| `DISASTER_EXCEPTION_HIGH` | Force majeure/evacuation |
| `COMPLIANCE_CRITICAL` | Must be legally reviewed |

Risk class affects approval path.

---

## 9. Legal Text Review

Legal text review must check:

1. No absolute immunity claim.
2. No unlawful waiver of customer rights.
3. No misleading legal basis.
4. No over-threatening wording.
5. No unsupported penalty claim.
6. No conflict with consumer protection duties.
7. No conflict with refund/payment behavior.
8. No conflict with privacy law.
9. No conflict with youth/alcohol rules.
10. No conflict with food safety obligations.
11. No ambiguous party responsibility.
12. No missing customer inquiry route where needed.
13. No unfair mandatory consent.
14. No hidden optional consent.
15. No obsolete legal reference.

Legal text review must be documented.

---

## 10. Domain Review Tracks

Different notices require different domain review.

| Domain | Review Focus |
|---|---|
| Food Safety | Allergy, raw food, storage, origin, hygiene |
| Alcohol | Age gate, ID, proxy order, delivery restriction |
| Privacy | Consent, purpose, retention, third-party, withdrawal |
| Payment | Cancel, refund, deposit, PG, receipt |
| Tax | VAT, invoice, settlement evidence |
| Store Ops | Facility, safety, waiting, no-show |
| Hardware | Tablet/POS/kiosk incident |
| Review/IP | User content, moderation, copyright |
| Coupon/Event | Benefit rules, abuse, expiry |
| Staff Protection | Abuse, recording, incident escalation |
| Disaster | Force majeure, cancellation, evacuation |

A notice may require multiple tracks.

---

## 11. Trigger Review

Trigger review must verify:

- trigger condition is clear
- trigger source is available
- trigger does not overfire
- trigger does not underfire
- trigger respects tenant/store scope
- trigger has effective date
- trigger priority is correct
- trigger conflict behavior is defined
- trigger fallback exists
- trigger is auditable

Example:

    Alcohol item added to cart -> Adult confirmation popup.

The trigger must be deterministic.

---

## 12. Surface Review

Surface review must verify:

- notice appears before risk point
- surface is visible enough
- popup is not overused
- high-risk notice is not footer-only
- full text is accessible
- short text is not misleading
- checkbox text is clear
- receipt text is compact
- staff guidance is separated
- support summary is accurate

A correct notice on the wrong surface is weak.

---

## 13. Evidence Review

Evidence review must verify:

| Evidence Aspect | Requirement |
|---|---|
| Notice shown event | Captured where needed |
| Notice version | Captured |
| Locale | Captured |
| Surface | Captured |
| Trigger reason | Captured |
| Acknowledgement | Captured if required |
| Actor/session | Captured |
| Order/payment reference | Captured if applicable |
| Text hash | Captured for critical notice |
| Retention class | Assigned |
| Support retrieval | Available case-scoped |
| Audit | Linked |

Evidence requirements must be defined before customer use.

---

## 14. i18n Review

i18n review must verify:

- Korean reference text exists
- controlling language flag is set
- translation state is correct
- high-risk translation is reviewed
- variable interpolation works
- surface variant is appropriate
- fallback rule exists
- text hash can be generated
- accessibility variant exists where needed
- translation does not change legal meaning

Machine translation remains draft.

---

## 15. Variable Review

Notices with variables require variable review.

Examples:

- `{grace_minutes}`
- `{deposit_amount}`
- `{refund_cutoff_hours}`
- `{corkage_fee}`
- `{parking_free_minutes}`
- `{child_age_limit}`
- `{last_order_time}`
- `{support_phone}`

Variable review checks:

1. Variable type is defined.
2. Variable range is defined.
3. Unsafe values are blocked.
4. Store owner can edit only allowed variables.
5. High-risk variable changes require review.
6. Rendered text is snapshot for evidence.
7. i18n formatting is correct.

Variables must not mutate master text.

---

## 16. Default Toggle Review

Default toggle review determines whether notice starts ON or OFF.

Default states:

| State | Meaning |
|---|---|
| `DEFAULT_ON_PLATFORM` | Platform mandatory |
| `DEFAULT_ON_BY_STORE_TYPE` | Auto ON when store type matches |
| `DEFAULT_ON_BY_FEATURE` | Auto ON when feature enabled |
| `DEFAULT_OFF_RECOMMENDED` | Suggested but off |
| `DEFAULT_OFF_OPTIONAL` | Store may enable |
| `LOCKED_ON` | Cannot disable |
| `BLOCKED_UNTIL_REVIEW` | Cannot enable yet |

Default ON must be justified.

---

## 17. Mandatory Lock Review

Mandatory lock review is required for:

- privacy required consent
- service terms
- payment/refund baseline notice
- alcohol age-gate notice
- legal notice evidence capture
- required business information footer
- required third-party provision notice
- required app permission notice where applicable
- platform security incident notice
- legally required customer rights notice

Mandatory lock must have authority and audit.

---

## 18. Store Toggle Readiness Review

A notice may become store-toggle-ready only if:

1. Text is approved.
2. Surface mapping is approved.
3. Trigger mapping is approved.
4. Evidence requirement is defined.
5. i18n fallback is defined.
6. Store authority is defined.
7. Variable ranges are defined.
8. Conflict behavior is defined.
9. Deactivation behavior is defined.
10. Rollback is defined.

Store-toggle-ready does not mean every store must enable it.

---

## 19. Customer Display Approval

A notice may be customer-display-approved only if:

- legal/domain review completed
- i18n review completed where needed
- surface mapping completed
- text variant completed
- evidence rule completed
- accessibility considered
- tone reviewed
- store/tenant scope reviewed
- fallback rule reviewed
- support visibility reviewed

Customer display approval is stronger than master data approval.

---

## 20. Seed Promotion Flow

Recommended promotion flow:

1. Create seed draft.
2. Validate structure.
3. Assign family and risk.
4. Assign review tracks.
5. Review legal text.
6. Review domain behavior.
7. Review trigger mapping.
8. Review surface mapping.
9. Review evidence requirements.
10. Review i18n.
11. Review default toggle and lock.
12. Approve static master.
13. Approve customer display if ready.
14. Mark active-ready for future runtime.
15. Record audit.

Each stage must be visible.

---

## 21. Rejection Flow

A seed notice may be rejected if:

- wording is legally unsafe
- meaning is unclear
- notice duplicates another notice
- legal basis is wrong
- customer rights are weakened
- trigger cannot be defined
- surface cannot be safely mapped
- evidence cannot be captured
- translation is unsafe
- store variable is dangerous
- notice is obsolete
- notice conflicts with POS/payment behavior

Rejected seed remains in history but cannot activate.

---

## 22. Deprecation Flow

A notice may be deprecated when:

- law changes
- policy changes
- better notice replaces it
- wording is unsafe
- duplicate is consolidated
- feature is removed
- translation problem is found
- customer complaint pattern emerges
- support evidence shows poor clarity

Deprecation rules:

- do not delete historical notice
- prevent new activation
- keep evidence readable
- link replacement notice if any
- audit deprecation reason

---

## 23. Version Upgrade Flow

When a notice changes:

1. Create new version.
2. Link previous version.
3. Record change reason.
4. Run review tracks again.
5. Approve new version.
6. Set effective date.
7. Future displays use new version.
8. Historical evidence keeps old version.
9. Re-notice or re-consent may be required for material change.

Version upgrade is not text overwrite.

---

## 24. Material Change Review

Material change examples:

- refund eligibility changed
- deposit forfeiture condition changed
- privacy purpose changed
- data recipient changed
- marketing channel scope changed
- alcohol verification condition changed
- allergen warning narrowed
- customer liability increased
- store liability reduced
- evidence capture changed
- retention period changed

Material changes require stronger review.

---

## 25. Static Seed Batch Approval

For initial 200 notices, batch review may be used.

Batch approval must still preserve:

- individual notice code
- individual family
- individual risk class
- individual review state
- individual trigger/surface plan
- individual i18n state
- individual effective date
- individual deprecation path

Batch approval cannot hide high-risk individual review gaps.

---

## 26. Sample Seed Approval Checklist

For each notice:

| Check | Pass/Fail |
|---|---|
| Code unique |
| Family assigned |
| Risk class assigned |
| Korean text exists |
| Legal basis reviewed |
| Text tone reviewed |
| Trigger defined |
| Surface defined |
| Ack required defined |
| Evidence required defined |
| Retention class assigned |
| i18n state assigned |
| Store toggle rule defined |
| HQ/platform lock defined |
| Variable fields validated |
| Support visibility defined |
| Approved by authority |
| Audit recorded |

A failed high-risk check blocks customer display.

---

## 27. Release Readiness States

Recommended release states:

| State | Meaning |
|---|---|
| `SEED_ONLY` | Stored but not usable |
| `MASTER_APPROVED` | Master approved |
| `DISPLAY_APPROVED` | Customer display approved |
| `TOGGLE_APPROVED` | Store toggle approved |
| `TRIGGER_APPROVED` | Trigger rule approved |
| `SURFACE_APPROVED` | Surface mapping approved |
| `EVIDENCE_APPROVED` | Evidence requirement approved |
| `I18N_APPROVED` | Translation approved |
| `ACTIVE_READY` | Ready for future runtime |
| `RELEASE_BLOCKED` | Cannot release |
| `RELEASED` | Runtime release later allowed |

This document does not mark runtime released.

---

## 28. Support Readiness Review

Support readiness must confirm:

- support can retrieve notice version
- support can retrieve acknowledgement evidence
- support can retrieve store toggle state at order time
- support can view Korean controlling text
- support can view translated text shown
- support can view trigger reason
- support can view related order/payment state
- support cannot mutate evidence
- escalation route exists

If support cannot interpret evidence, notice deployment is incomplete.

---

## 29. Audit Event Catalog

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `LEGAL_SEED_CREATED` | Seed notice created |
| `LEGAL_SEED_STRUCTURE_VALIDATED` | Structure validated |
| `LEGAL_SEED_FAMILY_ASSIGNED` | Family assigned |
| `LEGAL_SEED_RISK_ASSIGNED` | Risk class assigned |
| `LEGAL_SEED_REVIEW_REQUESTED` | Review requested |
| `LEGAL_SEED_LEGAL_APPROVED` | Legal approved |
| `LEGAL_SEED_DOMAIN_APPROVED` | Domain approved |
| `LEGAL_SEED_I18N_APPROVED` | i18n approved |
| `LEGAL_SEED_TRIGGER_APPROVED` | Trigger approved |
| `LEGAL_SEED_SURFACE_APPROVED` | Surface approved |
| `LEGAL_SEED_EVIDENCE_APPROVED` | Evidence approved |
| `LEGAL_SEED_MASTER_APPROVED` | Master approved |
| `LEGAL_SEED_DISPLAY_APPROVED` | Display approved |
| `LEGAL_SEED_REJECTED` | Seed rejected |
| `LEGAL_SEED_DEPRECATED` | Seed deprecated |
| `LEGAL_SEED_VERSION_UPGRADED` | Version upgraded |
| `LEGAL_SEED_RELEASE_BLOCKED` | Release blocked |

Events must route through `10610`.

---

## 30. Security Boundary

Seed review and approval is compliance-sensitive.

Rules:

- only authorized users can approve
- high-risk approval requires reauthentication
- bulk approval requires stronger authority
- AI cannot approve seed
- sales rep cannot approve high-risk seed
- support cannot approve seed
- rejected seed cannot be activated
- deprecated seed cannot be newly activated
- approval history is immutable
- tenant/store scope must be enforced
- export of seed review history requires authority

Seed approval is policy configuration.

---

## 31. Anti-Patterns

Avoid:

- treating seed insert as legal approval
- approving all 200 notices without risk classification
- skipping i18n review for customer-facing text
- activating notices without trigger mapping
- activating notices without surface mapping
- capturing acknowledgement without version
- approving high-risk notices by sales rep
- allowing AI-generated legal wording into production
- overwriting old versions
- deleting rejected notices without audit
- using mandatory lock without authority record
- ignoring support evidence readiness
- failing to define retention class
- approving translation without Korean reference
- releasing store toggles before variable ranges exist

These anti-patterns must be blocked in future runtime design.

---

## 32. Runtime Deferral

This document defines legal notice static seed review and approval workflow governance only.

It does not authorize:

- seed file creation
- database insertion
- SQL migration
- approval workflow implementation
- admin review UI
- legal review UI
- i18n review UI
- runtime activation
- customer display
- evidence capture runtime
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. Static seed lifecycle is defined.
2. Seed intake requirements are defined.
3. Notice code review is defined.
4. Family classification review is defined.
5. Risk class review is defined.
6. Legal text review is defined.
7. Domain review tracks are defined.
8. Trigger review is defined.
9. Surface review is defined.
10. Evidence review is defined.
11. i18n review is defined.
12. Variable review is defined.
13. Default toggle review is defined.
14. Mandatory lock review is defined.
15. Store toggle readiness review is defined.
16. Customer display approval is defined.
17. Seed promotion flow is defined.
18. Rejection flow is defined.
19. Deprecation flow is defined.
20. Version upgrade flow is defined.
21. Material change review is defined.
22. Static seed batch approval is defined.
23. Sample seed approval checklist is defined.
24. Release readiness states are defined.
25. Support readiness review is defined.
26. Audit event catalog is defined.
27. Security boundary is defined.
28. Anti-patterns are listed.
29. Coding remains unauthorized.
30. Runtime remains deferred.

---

## 34. Relationship To Previous Documents

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

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`

It prepares possible future documents:

- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

Catch Menu legal notice seed data must move through controlled review before any production use.

The 200-notice pool may be stored as static master data, but storage alone does not mean legal approval, customer display approval, trigger approval, store toggle approval, or runtime release.

Each notice must be reviewed for code, family, risk, text, legal basis, domain behavior, trigger, surface, evidence, i18n, variables, default toggle, lock state, support readiness, and release readiness.

High-risk notices require stronger approval.

Rejected and deprecated notices must remain auditable but unusable.

Historical versions must never be overwritten.

AI may help draft or classify seed notices.

AI cannot approve legal notice wording, activation, translation, trigger mapping, surface mapping, or customer display.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
