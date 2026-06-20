# 010724_Policy_Legal_Notice_Admin_Toggle_Permission_And_HQ_Lock

## 1. Purpose

This document defines the Legal Notice Admin Toggle, Permission, HQ Lock, Franchise Mandate, Store Override, High-Risk Notice Control, Approval, Audit, Rollback, and Deployment Governance Policy for Catch Menu.

The previous document `10723 Legal Notice i18n Review And Controlled Translation Policy` defined legal notice translation, locale fallback, Korean controlling text, i18n review, evidence snapshots, and controlled multilingual customer display.

This document focuses on who may turn legal notices on or off, who may lock them, who may approve changes, and how Catch Menu prevents unsafe legal notice weakening by store-level users.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Legal notice toggle is a governance action, not a simple UI preference.

The correct rule is:

Store owner may configure local notices only within authority.  
Mandatory notices cannot be disabled by ordinary store users.  
Franchise HQ may require stronger notices across stores.  
Platform legal/admin may lock notices globally.  
High-risk notice activation or deactivation requires audit and review.  
Toggle state must be versioned.  
Toggle OFF does not erase past evidence.  
Store-specific variables may be edited only within allowed range.  
AI may recommend toggles, but AI cannot activate or deactivate legal notices.  
Support may view toggle history but cannot modify legal settings from dispute screens.  

Legal notice configuration is compliance-sensitive configuration.

---

## 3. Scope

This policy applies to:

- legal notice admin toggle page
- owner admin console
- franchise HQ console
- platform admin console
- legal/compliance console
- sales representative setup flow
- support case view
- legal notice recommendation acceptance
- mandatory notice lock
- optional notice activation
- store-specific notice variables
- franchise template enforcement
- high-risk notice approval
- toggle audit
- rollback
- deployment readiness

This policy defines governance only.

---

## 4. Role Model

Recommended role groups:

| Role | Meaning |
|---|---|
| `PLATFORM_LEGAL_ADMIN` | Platform-level legal notice authority |
| `PLATFORM_COMPLIANCE_ADMIN` | Platform compliance operator |
| `PLATFORM_SUPER_ADMIN` | Platform technical/admin authority |
| `FRANCHISE_HQ_ADMIN` | Franchise HQ notice policy authority |
| `FRANCHISE_HQ_LEGAL_REVIEWER` | Franchise legal reviewer |
| `STORE_OWNER` | Store owner |
| `STORE_MANAGER` | Store manager with limited settings authority |
| `SALES_REP` | Setup assistant/sales representative |
| `SUPPORT_AGENT` | Customer support case viewer |
| `LEGAL_AUDITOR` | Audit/read-only legal reviewer |
| `AI_SYSTEM` | Recommendation-only system actor |

Roles must be mapped to explicit permissions.

---

## 5. Authority Principles

Authority principles:

1. Visibility is not authority.
2. Recommendation is not activation.
3. Store toggle is not legal approval.
4. HQ lock overrides store preference.
5. Platform mandatory notice overrides HQ and store.
6. Legal review is required for high-risk wording changes.
7. Support case access does not allow configuration changes.
8. Sales setup assistance does not equal final approval.
9. AI has no authority to activate legal settings.
10. Every legal notice setting change must be audited.

---

## 6. Notice Control Classes

Recommended control classes:

| Control Class | Meaning |
|---|---|
| `PLATFORM_LOCKED_ON` | Always ON, cannot be disabled |
| `PLATFORM_LOCKED_TEXT` | Text cannot be edited |
| `HQ_LOCKED_ON` | Franchise HQ requires ON |
| `HQ_LOCKED_TEXT` | HQ-approved text required |
| `STORE_OPTIONAL` | Store may toggle |
| `STORE_REQUIRED_BY_FEATURE` | Required if feature is enabled |
| `LEGAL_REVIEW_REQUIRED` | Cannot activate/deactivate without review |
| `VARIABLE_ALLOWED` | Store may edit approved variables only |
| `ADMIN_GUIDANCE_ONLY` | Not customer-facing |
| `DEPRECATED_BLOCKED` | Cannot be used |

Control class determines toggle behavior.

---

## 7. Permission Matrix

Recommended permission matrix:

| Action | Platform Legal | Franchise HQ | Store Owner | Store Manager | Sales Rep | Support |
|---|---:|---:|---:|---:|---:|---:|
| Create master notice | Yes | No | No | No | No | No |
| Approve legal text | Yes | Limited | No | No | No | No |
| Lock platform notice | Yes | No | No | No | No | No |
| Lock franchise notice | Yes | Yes | No | No | No | No |
| Enable optional store notice | Yes | Yes | Yes | Limited | Assisted | No |
| Disable optional store notice | Yes | Yes | Yes | Limited | Assisted | No |
| Disable mandatory notice | No except supersede | No | No | No | No | No |
| Edit store variable | Yes | Yes | Yes | Limited | Assisted | No |
| Accept AI recommendation | Yes | Yes | Yes | Limited | Assisted | No |
| View evidence | Yes | Yes scoped | Yes scoped | Limited | No | Case scoped |
| Export evidence | Yes | Limited | No | No | No | No |
| Rollback setting | Yes | Yes scoped | Yes scoped | Limited | No | No |

Actual permission names are deferred.

---

## 8. Store Owner Toggle Boundary

Store owner may toggle:

- no-kids-zone notice if store policy supports it
- pet-friendly notice
- parking notice
- break-time notice
- self-bar notice
- time-limit notice
- corkage notice if feature enabled
- coupon/event notice if promotion enabled
- store-specific facility notices
- optional allergy/cross-contact enhancement notices
- pickup freshness notice if takeout enabled
- reservation/no-show notice if reservation enabled

Store owner may not disable:

- platform privacy terms
- required privacy consent
- required refund/cancellation notice for enabled order flow
- alcohol age-gate notice for alcohol sales
- mandatory allergen notice where required
- payment/PG notice where required
- legal notice evidence capture
- franchise locked notice

---

## 9. Store Manager Boundary

Store manager may have limited authority.

Allowed examples:

- enable operational notice from approved template
- edit safe variables such as break-time display
- configure waiting grace minutes within approved range
- configure parking free-time notice
- activate daily sold-out notice
- preview customer display
- request owner/HQ approval

Restricted examples:

- disabling legal mandatory notices
- editing legal text
- changing refund penalty structure beyond limit
- changing deposit forfeiture policy
- changing alcohol ID policy
- changing privacy consent
- exporting evidence
- approving high-risk notice

Manager permissions should be store-configurable but bounded.

---

## 10. Sales Representative Boundary

Sales representatives may assist setup.

Allowed examples:

- upload menu photo
- review AI recommendations with owner
- suggest legal notice templates
- prefill store-specific variables
- mark notices as owner-review-needed
- create setup checklist
- request HQ/legal review

Not allowed:

- approve legal text
- force-enable high-risk notice without owner/HQ authority
- disable mandatory notice
- approve alcohol policy
- approve refund/no-show penalty wording
- export consent or dispute evidence
- act as store owner without delegated authority

Sales setup must preserve owner confirmation.

---

## 11. Support Agent Boundary

Support agents may view case-scoped evidence.

Allowed:

- view notice shown event
- view notice version
- view acknowledgement time
- view store toggle state at order time
- view refund/no-show/alcohol evidence
- attach evidence to support case
- escalate missing notice issue

Not allowed:

- edit notice text
- edit toggle state
- delete evidence
- change acknowledgement
- approve legal wording
- retroactively activate notice
- export bulk evidence without authority

Support is evidence viewer, not policy editor.

---

## 12. Franchise HQ Lock Boundary

Franchise HQ may enforce:

- brand-wide refund policy
- brand-wide allergen notice
- brand-wide menu safety notice
- review event policy
- coupon abuse policy
- alcohol policy for brand stores
- no-show reservation rule
- customer recovery notice
- i18n approved template
- store display surface rules

HQ lock states:

| State | Meaning |
|---|---|
| `HQ_RECOMMENDED` | Suggested to stores |
| `HQ_REQUIRED_ON` | Must be ON |
| `HQ_TEXT_LOCKED` | Text must use HQ version |
| `HQ_VARIABLE_RANGE_LOCKED` | Variables limited |
| `HQ_REVIEW_REQUIRED` | Store change needs HQ review |
| `HQ_OVERRIDE_DENIED` | Store cannot override |

HQ policy must remain tenant-scoped.

---

## 13. Platform Lock Boundary

Platform may lock notices for:

- privacy terms
- required personal data consent
- third-party provision consent
- payment/refund baseline notice
- alcohol age-gate baseline notice
- legal notice evidence capture
- customer rights notices
- business information footer
- app permission notices
- service terms
- security/breach notices
- platform intermediary notice

Platform lock cannot be weakened by tenant or store.

---

## 14. High-Risk Notice Classes

High-risk notices include:

| Class | Examples |
|---|---|
| `PRIVACY_HIGH_RISK` | 개인정보 수집, 제3자 제공, 마케팅 수신 |
| `ALCOHOL_HIGH_RISK` | 주류, 신분증, 미성년자, 대리 주문 |
| `PAYMENT_HIGH_RISK` | 환불, 취소, 선결제, 보증금 |
| `FOOD_SAFETY_HIGH_RISK` | 알레르기, 날것, 교차오염 |
| `NO_SHOW_HIGH_RISK` | 예약금 몰수, 패널티 |
| `TAX_HIGH_RISK` | 영수증, 세금계산서, 봉사료 |
| `STAFF_PROTECTION_HIGH_RISK` | 폭언, 퇴점, 녹음 |
| `DISASTER_HIGH_RISK` | 강제취소, 면책, 대피 |
| `I18N_HIGH_RISK` | 번역 오역, controlling text |
| `EVIDENCE_HIGH_RISK` | 동의/고지 증거 보존 |

High-risk changes require review.

---

## 15. Toggle State Registry

Recommended toggle states:

| State | Meaning |
|---|---|
| `OFF_AVAILABLE` | Can be enabled |
| `ON_ACTIVE` | Active |
| `ON_PENDING_REVIEW` | Requested but pending review |
| `OFF_PENDING_REVIEW` | Disable requested but pending review |
| `LOCKED_ON_PLATFORM` | Platform locked |
| `LOCKED_ON_HQ` | HQ locked |
| `LOCKED_TEXT` | Text locked |
| `DISABLED_BY_POLICY` | Disabled by policy |
| `DEPRECATED_BLOCKED` | Cannot activate |
| `SUSPENDED` | Temporarily suspended |
| `ERROR_REVIEW_REQUIRED` | Configuration issue |

Toggle state must be visible in admin.

---

## 16. Toggle Change Flow

Recommended flow:

1. Actor opens legal notice admin page.
2. System verifies role and scope.
3. Actor selects notice.
4. System displays current control class.
5. If allowed, actor toggles ON/OFF.
6. System displays affected surfaces and risk.
7. Actor confirms reason.
8. If review needed, request enters pending state.
9. If no review needed, setting becomes active.
10. Audit event is recorded.
11. Future retrieval uses updated setting.
12. Historical evidence remains unchanged.

Toggle change must not rewrite past orders.

---

## 17. High-Risk Toggle Approval Flow

High-risk toggle flow:

1. Actor requests change.
2. System marks `ON_PENDING_REVIEW` or `OFF_PENDING_REVIEW`.
3. Legal/HQ reviewer is assigned.
4. Reviewer checks wording, trigger, surface, evidence, i18n, POS/payment consistency.
5. Reviewer approves, rejects, or requests changes.
6. Approved change becomes effective.
7. Rejected change remains inactive.
8. Audit records decision and reason.

High-risk notice change must not be immediate unless pre-approved policy allows it.

---

## 18. Variable Editing Boundary

Some notices allow variables.

Examples:

- `{grace_minutes}`
- `{deposit_amount}`
- `{refund_cutoff_hours}`
- `{parking_free_minutes}`
- `{corkage_fee}`
- `{child_age_limit}`
- `{dining_time_limit}`
- `{last_order_time}`
- `{support_phone}`

Variable rules:

| Rule | Meaning |
|---|---|
| Type validation | Number, money, time, text |
| Range validation | Allowed minimum/maximum |
| Review required | High-risk variables need review |
| Snapshot required | Rendered value stored in evidence |
| No text mutation | Variable edit does not edit master text |
| Audit required | Every change logged |

Unsafe variable values must be blocked.

---

## 19. Variable Risk Examples

Examples:

| Variable | Risk |
|---|---|
| No-show grace 0 minutes | Customer fairness risk |
| Deposit refund cutoff too strict | Dispute risk |
| Corkage fee excessive | Consumer complaint risk |
| Child age limit ambiguous | Store dispute risk |
| Alcohol sale time wrong | Legal risk |
| Parking free time wrong | Customer complaint risk |
| Last order time wrong | Operational dispute |

Variables are operational policy, not plain text.

---

## 20. Recommendation Acceptance Flow

AI/system recommendation flow:

1. AI or rule engine recommends notice.
2. Recommendation appears in admin card.
3. Admin sees reason and confidence.
4. Admin accepts, rejects, or requests review.
5. If accepted and notice is optional, toggle may activate.
6. If high-risk, review is required.
7. If rejected, reason is recorded.
8. Recommendation history remains visible.

AI recommendation does not bypass permission.

---

## 21. Store Setup Checklist

Legal setup checklist should include:

- required platform notices active
- required privacy notices active
- store type notices reviewed
- alcohol notices active if alcohol enabled
- refund/cancel notices active if ordering enabled
- no-show notices active if reservation/waiting deposit enabled
- food safety notices active by menu category
- i18n readiness checked
- high-risk variables reviewed
- customer surfaces previewed
- support evidence enabled
- audit enabled
- owner confirmation captured

Setup should not be marked complete if mandatory notice is missing.

---

## 22. Deployment Readiness

A store legal notice configuration may have readiness states:

| State | Meaning |
|---|---|
| `NOT_STARTED` | No setup |
| `AI_RECOMMENDED` | Recommendations generated |
| `OWNER_REVIEW_REQUIRED` | Owner must review |
| `HQ_REVIEW_REQUIRED` | HQ review needed |
| `LEGAL_REVIEW_REQUIRED` | Legal review needed |
| `I18N_REVIEW_REQUIRED` | Translation review needed |
| `CONFIG_READY` | Ready for activation |
| `ACTIVE` | Active |
| `ACTIVE_WITH_WARNINGS` | Active but non-blocking warnings |
| `BLOCKED` | Cannot deploy |
| `SUSPENDED` | Temporarily suspended |

Readiness must be clear before opening ordering.

---

## 23. Rollback Policy

Legal notice setting rollback must preserve history.

Rollback rules:

- rollback creates new setting event
- old setting remains in history
- past evidence remains unchanged
- rollback cannot disable mandatory notice
- rollback of high-risk notice may require review
- rollback reason required
- effective time recorded
- support can view previous setting at order time

Rollback is not deletion.

---

## 24. Emergency Lock Policy

Platform or HQ may emergency-lock notices when:

- law/regulation changes
- privacy incident occurs
- alcohol compliance risk arises
- refund dispute pattern emerges
- misleading notice text found
- translation error found
- payment behavior mismatch found
- coupon abuse exploit found
- system bug causes missing notice
- safety incident occurs

Emergency lock actions:

- lock notice ON
- disable unsafe notice
- force fallback text
- block feature
- create incident
- notify stores
- require re-review

Emergency lock must be audited.

---

## 25. Notice Deactivation Policy

Notice deactivation must check:

- mandatory status
- active order dependency
- active reservation dependency
- coupon/event dependency
- alcohol sales dependency
- privacy consent dependency
- franchise lock
- legal review state
- pending disputes
- historical evidence

Deactivation must not affect already captured evidence.

---

## 26. Admin UI Requirements

Admin UI should show:

- notice title
- notice family
- risk class
- control class
- toggle state
- lock owner
- trigger summary
- surface summary
- acknowledgement requirement
- evidence requirement
- i18n status
- legal review status
- effective date
- variable fields
- preview
- recommendation reason
- audit history
- rollback action if allowed

Admin should understand why a toggle is locked.

---

## 27. HQ UI Requirements

HQ UI should support:

- brand-level policy view
- store compliance status
- missing mandatory notice list
- high-risk pending review queue
- i18n readiness dashboard
- store override requests
- bulk policy rollout
- emergency lock
- version comparison
- audit export
- dispute trend by notice
- recommendation acceptance rate

HQ must manage consistency without breaking tenant isolation.

---

## 28. Legal Reviewer UI Requirements

Legal reviewer UI should show:

- notice text version
- Korean controlling text
- translation status
- trigger mapping
- surface mapping
- acknowledgement behavior
- store/franchise scope
- variable values and ranges
- POS/payment consistency notes
- risk class
- previous versions
- change reason
- approve/reject/request change action
- audit trail

Legal review is a workflow, not an email side process.

---

## 29. Audit Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `LEGAL_NOTICE_TOGGLE_REQUESTED` | Toggle requested |
| `LEGAL_NOTICE_TOGGLE_ENABLED` | Notice enabled |
| `LEGAL_NOTICE_TOGGLE_DISABLED` | Notice disabled |
| `LEGAL_NOTICE_TOGGLE_BLOCKED` | Toggle blocked |
| `LEGAL_NOTICE_HQ_LOCK_APPLIED` | HQ lock applied |
| `LEGAL_NOTICE_PLATFORM_LOCK_APPLIED` | Platform lock applied |
| `LEGAL_NOTICE_VARIABLE_CHANGED` | Variable changed |
| `LEGAL_NOTICE_REVIEW_REQUESTED` | Review requested |
| `LEGAL_NOTICE_REVIEW_APPROVED` | Review approved |
| `LEGAL_NOTICE_REVIEW_REJECTED` | Review rejected |
| `LEGAL_NOTICE_REVIEW_CHANGES_REQUESTED` | Changes requested |
| `LEGAL_NOTICE_ROLLBACK_REQUESTED` | Rollback requested |
| `LEGAL_NOTICE_ROLLBACK_APPLIED` | Rollback applied |
| `LEGAL_NOTICE_EMERGENCY_LOCK_APPLIED` | Emergency lock applied |
| `LEGAL_NOTICE_RECOMMENDATION_ACCEPTED` | Recommendation accepted |
| `LEGAL_NOTICE_RECOMMENDATION_REJECTED` | Recommendation rejected |
| `LEGAL_NOTICE_DEPLOYMENT_BLOCKED` | Deployment blocked due to notice issue |

Events must route through `10610`.

---

## 30. Security Boundary

Legal notice settings are compliance-critical.

Rules:

- high-risk toggle requires reauthentication
- bulk changes require stronger authority
- support cannot edit settings
- AI cannot activate settings
- store owner cannot disable locked notices
- tenant/store scope mandatory
- review approvals are audited
- rollback is audited
- emergency lock is audited
- evidence is immutable
- old settings remain queryable
- variable changes are versioned
- export is restricted

Legal notice configuration must be protected like policy configuration.

---

## 31. Anti-Patterns

Avoid:

- giving every store user full legal notice edit rights
- allowing store owner to rewrite legal text freely
- allowing mandatory notice OFF
- letting AI recommendations auto-enable high-risk notices
- allowing sales rep to approve legal policy
- allowing support to change settings during dispute
- hiding why a notice is locked
- not logging toggle changes
- not preserving old settings
- allowing unsafe variable values
- changing refund/no-show notice without payment behavior review
- enabling alcohol notice without staff verification policy
- disabling notice while active disputes depend on it
- using HQ lock across wrong tenant
- treating toggle UI as simple preference setting

These anti-patterns must be blocked in future runtime design.

---

## 32. Runtime Deferral

This document defines legal notice admin toggle, permission, HQ lock, approval, rollback, and deployment governance only.

It does not authorize:

- admin UI implementation
- HQ lock implementation
- permission implementation
- legal review workflow implementation
- toggle runtime
- variable validation runtime
- emergency lock runtime
- audit implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. Role model is defined.
2. Authority principles are defined.
3. Notice control classes are defined.
4. Permission matrix is defined.
5. Store owner toggle boundary is defined.
6. Store manager boundary is defined.
7. Sales representative boundary is defined.
8. Support agent boundary is defined.
9. Franchise HQ lock boundary is defined.
10. Platform lock boundary is defined.
11. High-risk notice classes are defined.
12. Toggle state registry is defined.
13. Toggle change flow is defined.
14. High-risk toggle approval flow is defined.
15. Variable editing boundary is defined.
16. Variable risk examples are defined.
17. Recommendation acceptance flow is defined.
18. Store setup checklist is defined.
19. Deployment readiness is defined.
20. Rollback policy is defined.
21. Emergency lock policy is defined.
22. Notice deactivation policy is defined.
23. Admin UI requirements are defined.
24. HQ UI requirements are defined.
25. Legal reviewer UI requirements are defined.
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

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10725 Legal Notice Static Seed Review And Approval Workflow Policy`
- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

Catch Menu legal notice toggles must be governed by role, authority, control class, risk class, tenant/store scope, HQ lock, platform lock, review state, i18n state, variable validation, audit, and rollback.

Store owners may configure approved optional notices.

Mandatory notices, privacy notices, alcohol notices, refund/cancellation notices, no-show deposit notices, and other high-risk notices must not be weakened by ordinary store settings.

Franchise HQ may lock brand policy within tenant scope.

Platform legal/admin may lock global mandatory notices.

AI may recommend notice activation, but AI cannot activate, deactivate, approve, or weaken legal notice settings.

Toggle history and historical customer evidence must never be rewritten.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.