# 10732_Regulatory_Change_Watchlist_And_Legal_Notice_Review_Queue_Policy

## 1. Current Position

The Legal Notice axis has reached:

- `10716` through `10729`: legal notice master registry, usage, table model, trigger/surface, privacy, alcohol, refund/no-show, i18n, admin lock, seed approval, evidence export, UX, emergency lock, and closure
- `10730`: legal notice evidence packet static field map
- `10731`: customer Notice Center UX static surface index

This document continues the supplemental legal notice governance sequence with:

    10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy

This document defines how regulatory changes, policy changes, legal review needs, store disputes, support trends, translation risks, and external compliance updates are collected into a controlled review queue.

This document is planning-only.

It does not authorize coding.

---

## 2. Purpose

This document defines the Regulatory Change Watchlist and Legal Notice Review Queue Policy for Catch Menu.

Legal notices are not static forever.

They may need review when:

- law or regulation changes
- privacy policy changes
- alcohol rules change
- refund/no-show dispute patterns increase
- payment provider rules change
- consumer protection guidance changes
- tax/receipt rules change
- food safety guidance changes
- franchise policy changes
- store operation policy changes
- translation errors are found
- support cases reveal confusion
- emergency locks are applied
- platform features change

This document defines how those review needs are collected, classified, prioritized, assigned, approved, and closed.

---

## 3. Core Position

Legal notice review must be a queue, not a memory task.

The correct rule is:

Regulatory change must create a review item.  
Support dispute patterns must create review items.  
Translation errors must create review items.  
Emergency locks must create review items.  
Store requests must create review items.  
AI may suggest review items.  
AI cannot approve review closure.  
Review items must have owner, priority, scope, deadline, status, evidence, and audit.  
Unreviewed legal change must not silently modify customer text.  
Closed review must preserve history.  

A legal notice system without a review queue becomes stale.

---

## 4. Scope

This policy applies to:

- legal notice master text
- legal notice versions
- trigger rules
- surface mappings
- i18n translations
- privacy consent text
- alcohol age-gate text
- refund/cancellation text
- no-show/deposit text
- food safety/allergen text
- coupon/event terms
- review/content policy
- tax/receipt notices
- hardware/system notices
- disaster/force majeure notices
- franchise HQ policy
- store-specific variables
- support dispute trends
- emergency lock recovery
- regulatory change tracking
- legal/compliance review queue

This policy defines governance only.

---

## 5. Watchlist Sources

Regulatory and policy watchlist items may come from:

| Source | Example |
|---|---|
| Legal/regulatory update | Privacy, alcohol, refund, tax |
| Government notice | Food safety, consumer protection |
| Payment provider change | PG/VAN refund or receipt policy |
| Franchise HQ policy | Brand-wide cancellation/no-show rule |
| Platform feature change | New reservation deposit flow |
| Support trend | Repeated refund dispute |
| Store owner request | New no-kids notice request |
| Sales setup feedback | Stores confused by template |
| Translation review | Meaning mismatch found |
| Emergency lock | Notice suspended due to risk |
| Audit finding | Missing version/evidence |
| Incident report | Alcohol verification failure |
| AI risk scan | Notice mismatch candidate |
| Customer complaint | Confusing or unfair notice |
| Legal counsel review | Wording update required |

Every source must be traceable.

---

## 6. Watchlist Item Types

Recommended watchlist item types:

| Type | Meaning |
|---|---|
| `REGULATORY_CHANGE` | External law/regulation/policy change |
| `LEGAL_TEXT_REVIEW` | Notice wording review |
| `PRIVACY_REVIEW` | Privacy/consent review |
| `ALCOHOL_REVIEW` | Alcohol/youth protection review |
| `PAYMENT_REFUND_REVIEW` | Payment/refund/cancel review |
| `FOOD_SAFETY_REVIEW` | Food/allergen/raw food review |
| `I18N_TRANSLATION_REVIEW` | Translation review |
| `TRIGGER_MAPPING_REVIEW` | Trigger rule review |
| `SURFACE_UX_REVIEW` | UI surface review |
| `EVIDENCE_GAP_REVIEW` | Missing/weak evidence review |
| `STORE_POLICY_REVIEW` | Store-specific notice review |
| `FRANCHISE_POLICY_REVIEW` | HQ/brand policy review |
| `EMERGENCY_LOCK_REVIEW` | Emergency lock follow-up |
| `SUPPORT_TREND_REVIEW` | Support pattern review |
| `FEATURE_CHANGE_REVIEW` | Feature requires notice update |
| `DEPRECATION_REVIEW` | Notice should be retired |
| `RELEASE_READINESS_REVIEW` | Notice ready for controlled release |

---

## 7. Review Queue Object

Each review queue item should include:

| Field | Meaning |
|---|---|
| `review_item_id` | Unique review item |
| `review_type` | Watchlist item type |
| `priority` | Severity/urgency |
| `notice_id` | Related notice if applicable |
| `notice_version_id` | Related version if applicable |
| `notice_family` | Notice family |
| `tenant_id` | Tenant scope if applicable |
| `store_id` | Store scope if applicable |
| `brand_id` | Franchise/brand scope if applicable |
| `source_type` | Source of review item |
| `source_ref` | Support case, incident, regulation, audit |
| `summary` | Short issue summary |
| `risk_description` | Why this matters |
| `recommended_action` | Review, rewrite, suspend, approve, deprecate |
| `assigned_owner` | Responsible owner |
| `reviewer_role` | Legal, privacy, i18n, payment, HQ |
| `due_at` | Target date |
| `status` | Queue status |
| `decision` | Approved/rejected/changes requested |
| `decision_reason` | Reason |
| `audit_ref` | Audit correlation |

Review queue must be queryable and auditable.

---

## 8. Priority Levels

Recommended priority levels:

| Priority | Meaning | Example |
|---|---|---|
| `P0_CRITICAL` | Immediate compliance/safety exposure | Alcohol minor sale risk |
| `P1_HIGH` | High-risk customer/legal impact | Privacy consent wording issue |
| `P2_MEDIUM` | Repeated dispute or policy mismatch | Refund notice confusion |
| `P3_LOW` | Improvement or clarity issue | Better store guide wording |
| `P4_BACKLOG` | Future enhancement | New language expansion |

Priority determines SLA and authority.

---

## 9. Review Status Registry

Recommended statuses:

| Status | Meaning |
|---|---|
| `OPEN` | Item created |
| `TRIAGE_PENDING` | Waiting for classification |
| `ASSIGNED` | Owner assigned |
| `IN_REVIEW` | Review in progress |
| `NEEDS_EXTERNAL_LEGAL` | External legal review needed |
| `NEEDS_HQ_REVIEW` | Franchise/HQ review needed |
| `NEEDS_I18N_REVIEW` | Translation review needed |
| `NEEDS_TECH_REVIEW` | POS/payment/runtime consistency review |
| `CHANGES_REQUESTED` | Revision required |
| `APPROVED` | Approved |
| `REJECTED` | Rejected |
| `DEPRECATED_DECIDED` | Deprecation decided |
| `EMERGENCY_LOCK_REQUIRED` | Emergency lock required |
| `RELEASE_READY` | Ready for future release |
| `CLOSED` | Closed |
| `BLOCKED` | Blocked by dependency |

Closed does not mean history deleted.

---

## 10. Review Ownership

Recommended ownership:

| Review Area | Owner |
|---|---|
| Privacy consent | Privacy/legal owner |
| Alcohol/youth | Legal/compliance/HQ |
| Refund/cancellation | Payment/legal/operations |
| No-show/deposit | Operations/legal/HQ |
| Food safety/allergen | Food safety/QC/legal |
| i18n translation | i18n reviewer/legal if high-risk |
| Tax/receipt | Finance/tax/legal |
| Review/content/IP | Legal/support/community |
| Coupon/event | Marketing/legal/finance |
| Device/hardware | Operations/legal/support |
| Disaster/exception | Operations/legal/security |
| Trigger/surface | Product/compliance/legal |
| Evidence gaps | Audit/security/support |
| Franchise policy | HQ/legal/platform |

Ownership must be explicit.

---

## 11. Regulatory Change Intake Flow

Recommended flow:

1. Regulatory change is detected.
2. Watchlist item is created.
3. Affected legal notice families are mapped.
4. Affected notices are listed.
5. Affected surfaces are listed.
6. Affected tenants/stores/features are scoped.
7. Priority is assigned.
8. Owner is assigned.
9. Review path is selected.
10. Draft change is created if needed.
11. Legal/domain/i18n review is completed.
12. New notice version or rule is approved.
13. Rollout plan is created.
14. Stores/support are notified if needed.
15. Item is closed with audit.

Regulatory change must not be handled by silent text edit.

---

## 12. Support Trend Review Flow

Support trend review should occur when:

- refund disputes increase
- no-show complaints increase
- alcohol refusal complaints increase
- allergy questions increase
- customers misunderstand popup
- translation confusion appears
- store owners report repeated disputes
- coupon abuse increases
- review moderation complaints increase
- device damage claims increase

Flow:

1. Support trend signal is detected.
2. Review queue item is created.
3. Related notice and surface are identified.
4. Evidence packets are sampled.
5. Cause is classified:
   - wording issue
   - surface issue
   - trigger issue
   - missing notice
   - runtime behavior mismatch
   - store training issue
6. Action is assigned.
7. Result is reviewed and closed.

Support trend is a governance signal.

---

## 13. Emergency Lock Review Flow

Every emergency lock must create a follow-up review item.

Review must answer:

1. Why was lock applied?
2. Which notices were affected?
3. Which tenants/stores were affected?
4. Which customers/orders were affected?
5. Was evidence captured correctly?
6. Is corrected notice needed?
7. Is translation review needed?
8. Is trigger/surface review needed?
9. Can lock be released?
10. Is postmortem required?

Emergency lock cannot stay open forever without review.

---

## 14. Translation Review Queue

Translation review queue should track:

- missing translation
- machine draft awaiting review
- high-risk translation pending
- customer complaint about translation
- fallback usage spike
- Korean controlling text mismatch
- variable formatting error
- material meaning change
- unsupported locale expansion
- emergency translation suspension

Translation review must preserve notice version linkage.

---

## 15. Evidence Gap Review Queue

Evidence gap review should track:

- notice shown but no version
- ack required but no ack
- locale missing
- text hash missing
- surface missing
- trigger reason missing
- order/payment link missing
- KDS/POS state missing
- store setting snapshot missing
- support packet incomplete
- export masking issue
- tenant scope missing

Evidence gap must not be hidden.

Critical gaps may block future release.

---

## 16. POS Payment Consistency Review

Legal notices must match actual runtime behavior.

Review examples:

| Notice Claim | Required Review |
|---|---|
| No cancellation after kitchen accept | KDS state available? |
| Auto refund on sold-out | Refund integration available? |
| Coupon restored after cancel | Coupon engine supports restore? |
| Deposit forfeited on no-show | Payment/deposit state supports? |
| Alcohol delivery blocked | POS/app blocks delivery? |
| Receipt tax notice | Receipt/tax behavior matches? |
| Market price confirmed | Price confirmation event exists? |

If behavior does not match notice, review must block release or require correction.

---

## 17. Store Policy Review Queue

Store policy review may be needed for:

- no-kids notice
- pet policy
- parking policy
- corkage fee
- dining time limit
- pickup hold time
- waiting grace time
- deposit amount
- no-show penalty
- store-specific event rules
- alcohol policy
- facility safety notice

Store policy review must validate variable values and approved templates.

---

## 18. Franchise Policy Review Queue

Franchise HQ review may be needed for:

- brand-wide refund standard
- brand-wide customer recovery policy
- brand-wide allergen policy
- brand-wide coupon terms
- brand review event policy
- brand alcohol sale policy
- brand no-show policy
- brand store conduct policy
- brand i18n wording
- franchise regulatory response

HQ policy must remain tenant-scoped.

---

## 19. Feature Change Review

New features may require legal notice review.

Examples:

| Feature | Possible Notice Review |
|---|---|
| Reservation deposit | No-show, refund, privacy |
| Split payment | Payment/refund responsibility |
| Wallet/points | Stored value, benefit expiry |
| Alcohol ordering | Age-gate, ID, delivery block |
| Review event | Review/IP/event abuse |
| AI menu import | Allergen/health claim review |
| Kiosk payment | Payment/refund/device notice |
| Delivery integration | Third-party provision/delivery policy |
| Location recommendation | Location consent |
| Workforce/public hiring interface | Privacy/terms/job posting policy |

Feature change must not go live without notice review.

---

## 20. Review SLA Policy

Suggested SLA candidates:

| Priority | Suggested Review Target |
|---|---|
| `P0_CRITICAL` | Immediate triage, same-day decision |
| `P1_HIGH` | 1–3 business days |
| `P2_MEDIUM` | 5–10 business days |
| `P3_LOW` | Next review cycle |
| `P4_BACKLOG` | Backlog planning |

Final SLA requires operational approval.

SLA missed must be visible.

---

## 21. Review Decision Types

Recommended decision types:

| Decision | Meaning |
|---|---|
| `NO_CHANGE_REQUIRED` | Existing notice remains valid |
| `TEXT_REVISION_REQUIRED` | Wording must change |
| `TRIGGER_REVISION_REQUIRED` | Trigger rule must change |
| `SURFACE_REVISION_REQUIRED` | Display surface must change |
| `ACK_REQUIREMENT_CHANGE` | Ack requirement changes |
| `I18N_REVISION_REQUIRED` | Translation must change |
| `FEATURE_BLOCK_REQUIRED` | Feature must be blocked |
| `EMERGENCY_LOCK_REQUIRED` | Emergency lock required |
| `NOTICE_DEPRECATION_REQUIRED` | Notice should be retired |
| `NEW_NOTICE_REQUIRED` | New notice needed |
| `SUPPORT_GUIDANCE_REQUIRED` | Support guidance update needed |
| `STORE_NOTIFICATION_REQUIRED` | Stores must be notified |
| `LEGAL_EXTERNAL_REVIEW_REQUIRED` | External legal needed |

Decision must be recorded with reason.

---

## 22. Review Closure Requirements

A review item can close only when:

- decision is recorded
- reviewer identity is recorded
- affected notice IDs are recorded
- affected versions are recorded
- affected surfaces are recorded
- affected stores/tenants are scoped
- follow-up actions are created or completed
- support guidance impact is determined
- customer notification need is determined
- audit is recorded

Closure without decision reason is not valid.

---

## 23. Watchlist Dashboard Requirements

Future admin/HQ dashboard should show:

- open review count
- high-risk open items
- overdue items
- items by notice family
- items by tenant/store
- emergency lock follow-ups
- translation pending items
- evidence gap items
- regulatory change items
- support trend items
- release-blocking items
- owner/assignee workload
- SLA status

Dashboard is governance visibility, not runtime approval.

---

## 24. AI Assistance Boundary

AI may assist by:

- scanning support trends
- suggesting affected notice families
- detecting translation mismatch candidates
- detecting evidence gaps
- clustering dispute reasons
- recommending review priority
- drafting review summaries
- comparing notice text versions
- suggesting trigger/surface mismatch candidates

AI must not:

- approve legal review
- close review item
- apply emergency lock
- release notice
- decide regulatory compliance
- rewrite customer legal text without review
- downgrade priority without human review
- suppress review items

AI is advisory only.

---

## 25. Audit Event Catalog

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `LEGAL_REVIEW_ITEM_CREATED` | Review item created |
| `LEGAL_REVIEW_ITEM_TRIAGED` | Triage completed |
| `LEGAL_REVIEW_ITEM_ASSIGNED` | Owner assigned |
| `LEGAL_REVIEW_PRIORITY_CHANGED` | Priority changed |
| `LEGAL_REVIEW_SCOPE_UPDATED` | Scope updated |
| `LEGAL_REVIEW_DECISION_RECORDED` | Decision recorded |
| `LEGAL_REVIEW_CHANGES_REQUESTED` | Changes requested |
| `LEGAL_REVIEW_APPROVED` | Review approved |
| `LEGAL_REVIEW_REJECTED` | Review rejected |
| `LEGAL_REVIEW_CLOSED` | Review closed |
| `LEGAL_REVIEW_OVERDUE` | Review overdue |
| `REGULATORY_WATCH_ITEM_CREATED` | Regulatory item created |
| `SUPPORT_TREND_REVIEW_CREATED` | Support trend review created |
| `EVIDENCE_GAP_REVIEW_CREATED` | Evidence gap review created |
| `I18N_REVIEW_ITEM_CREATED` | Translation review created |
| `EMERGENCY_LOCK_REVIEW_CREATED` | Emergency follow-up created |

Events must route through `10610`.

---

## 26. Security Boundary

Review queue is compliance-sensitive.

Rules:

- review items must be tenant-scoped where applicable
- legal/privacy items require restricted access
- bulk regulatory watch export requires authority
- AI cannot close or approve review
- support can create or escalate but not approve legal review
- store owners can request review but not close high-risk review
- HQ can review only within tenant/franchise scope
- review decisions are immutable once closed
- reopened items must create new event
- evidence references must be masked where needed

Review queue must not become an uncontrolled comment board.

---

## 27. Anti-Patterns

Avoid:

- tracking regulatory changes in personal notes only
- silently editing notice text after law changes
- closing review without decision
- allowing AI to approve compliance
- mixing tenant scopes in review queue
- leaving emergency locks without follow-up
- ignoring support trend signals
- ignoring translation complaints
- ignoring evidence gaps
- approving notice update without surface review
- approving refund text without payment behavior review
- approving alcohol text without age-gate review
- changing store policy without variable validation
- deleting review history
- hiding overdue legal review items

These anti-patterns must be blocked in future runtime design.

---

## 28. Runtime Deferral

This document defines regulatory change watchlist and legal notice review queue governance only.

It does not authorize:

- review queue database implementation
- watchlist crawler implementation
- dashboard implementation
- AI review scanner implementation
- legal review workflow implementation
- support trend analytics implementation
- notification runtime
- emergency lock runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 29. Validation Checklist

Validation must confirm:

1. Watchlist sources are defined.
2. Watchlist item types are defined.
3. Review queue object is defined.
4. Priority levels are defined.
5. Review status registry is defined.
6. Review ownership is defined.
7. Regulatory change intake flow is defined.
8. Support trend review flow is defined.
9. Emergency lock review flow is defined.
10. Translation review queue is defined.
11. Evidence gap review queue is defined.
12. POS/payment consistency review is defined.
13. Store policy review queue is defined.
14. Franchise policy review queue is defined.
15. Feature change review is defined.
16. Review SLA policy is defined.
17. Review decision types are defined.
18. Review closure requirements are defined.
19. Watchlist dashboard requirements are defined.
20. AI assistance boundary is defined.
21. Audit event catalog is defined.
22. Security boundary is defined.
23. Anti-patterns are listed.
24. Coding remains unauthorized.
25. Runtime remains deferred.

---

## 30. Relationship To Previous Documents

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

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`

It prepares possible future documents:

- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10734 Legal Notice Support Playbook And Case Reason Code Policy`
- `10735 Legal Notice Static Registry Readiness Check Policy`
- `10736 Legal Notice Implementation Authorization Draft Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 31. Final Rule

Catch Menu must manage legal notice changes through a controlled regulatory watchlist and review queue.

Regulatory changes, emergency locks, support dispute trends, translation errors, evidence gaps, POS/payment mismatches, store policy changes, franchise policy changes, and feature launches must create review items when they affect legal notice behavior.

Each review item must have type, priority, scope, owner, status, evidence, decision, and audit trail.

AI may assist detection and summarization.

AI cannot approve, close, suppress, or release legal review items.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.