# 10733_Policy_Legal_Notice_Admin_Checklist_And_Store_Onboarding_Review

## 1. Purpose

This document defines the Legal Notice Admin Checklist and Store Onboarding Review Policy for Catch Menu.

The previous document `10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy` defined the regulatory watchlist, review queue, priority, ownership, support trend review, translation review, evidence gap review, and feature-change review governance.

This document focuses on how legal notice readiness is checked during store onboarding.

Because Catch Menu is a SaaS product, each store must be activated through a legally controlled onboarding checklist before customer-facing ordering, payment, reservation, alcohol, coupon, review, or privacy flows are enabled.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Store onboarding must not be only menu registration.

The correct rule is:

A store is not ready just because menu items are uploaded.  
A store is not ready just because payment is connected.  
A store is not ready just because table QR works.  
A store is not ready just because AI parsed the menu.  
A store is ready only when legal notices, consent, refund policy, store settings, trigger rules, i18n, evidence capture, support route, and owner confirmation are reviewed.  

SaaS onboarding must create operational readiness and legal readiness together.

---

## 3. Scope

This policy applies to:

- new store onboarding
- franchise store onboarding
- single-store SaaS onboarding
- trial store onboarding
- menu photo intake onboarding
- AI menu classification onboarding
- store legal notice setup
- privacy consent setup
- refund/cancellation setup
- reservation/no-show setup
- alcohol setup
- coupon/event setup
- review setup
- hardware/tablet/kiosk setup
- payment/POS/KDS readiness review
- i18n readiness review
- support readiness review
- owner confirmation
- HQ approval
- activation gate

This policy defines onboarding governance only.

---

## 4. Onboarding Readiness Concept

Store onboarding readiness must be evaluated across multiple layers.

Recommended readiness layers:

| Layer | Meaning |
|---|---|
| Store Identity | Store profile and tenant/store scope |
| Menu Structure | Menu/category/option/set review |
| Legal Notice | Required and optional notices |
| Privacy Consent | Terms, privacy, marketing, location |
| Payment Refund | Payment/refund/cancel/no-show |
| Alcohol | Age-gate and staff verification |
| Food Safety | Allergy/raw food/freshness |
| Device | Table tablet/kiosk/device notice |
| Support | Dispute and inquiry route |
| i18n | Customer language readiness |
| Evidence | Notice/acknowledgement evidence |
| Admin Authority | Owner/HQ approval |
| Runtime Gate | Activation allowed or blocked |

Each layer must be explicitly checked.

---

## 5. Store Onboarding States

Recommended onboarding states:

| State | Meaning |
|---|---|
| `ONBOARDING_NOT_STARTED` | No onboarding |
| `STORE_PROFILE_DRAFT` | Store identity entered |
| `MENU_INTAKE_PENDING` | Menu photo/data not complete |
| `AI_PARSE_REVIEW_PENDING` | AI parsing requires review |
| `LEGAL_NOTICE_REVIEW_PENDING` | Legal notice setup incomplete |
| `OWNER_CONFIRMATION_PENDING` | Owner must confirm settings |
| `HQ_REVIEW_PENDING` | Franchise/HQ review needed |
| `LEGAL_REVIEW_PENDING` | Legal/compliance review needed |
| `I18N_REVIEW_PENDING` | Translation review needed |
| `SUPPORT_ROUTE_PENDING` | Support path incomplete |
| `EVIDENCE_RULE_PENDING` | Evidence capture plan incomplete |
| `READY_WITH_WARNINGS` | Can launch with non-blocking warnings |
| `READY_FOR_ACTIVATION` | Ready for future runtime activation |
| `BLOCKED` | Cannot activate |
| `ACTIVE` | Runtime active later |
| `SUSPENDED` | Suspended after activation |

This document does not activate runtime.

---

## 6. Store Identity Checklist

Store identity checklist:

| Check | Requirement |
|---|---|
| Tenant ID assigned | Required |
| Store ID assigned | Required |
| Store business name | Required |
| Business registration info | Required if applicable |
| Store address | Required |
| Store phone | Required |
| Owner/admin account | Required |
| Franchise/HQ relationship | Required if franchise |
| Operating group | Required if applicable |
| Store category | Required |
| Store service modes | Required |
| Business hours | Required |
| Break time | Required if applicable |
| Last order time | Required if applicable |
| Support contact | Required |

Store identity must be tenant-scoped.

---

## 7. Service Mode Checklist

Service mode determines legal notice requirements.

Recommended service mode checklist:

| Service Mode | Required Review |
|---|---|
| Table order | Refund/cancel, device, table session |
| Mobile web order | Privacy, refund, payment |
| Mini kiosk | Device, payment, refund |
| Full kiosk | Device, payment, refund, receipt |
| Waiting | Waiting call/no-show notice |
| Reservation | Deposit/no-show/cancel notice |
| Pickup | Freshness/pickup hold notice |
| Delivery | Delivery policy, third-party data |
| Alcohol | Age-gate, ID verification |
| Coupon/event | Event/coupon terms |
| Review | Review/content/IP notice |
| Membership | Terms/privacy/marketing |

If a mode is enabled, its notice requirements must be checked.

---

## 8. Menu Intake Checklist

Menu intake checklist:

| Check | Requirement |
|---|---|
| Menu source uploaded | Photo, PDF, text, POS export |
| AI parsing complete | Draft only |
| Menu names reviewed | Owner/admin confirmation |
| Prices reviewed | Owner/admin confirmation |
| Category classification reviewed | AI recommendation confirmed |
| Option groups reviewed | Size/spice/sauce/add-on |
| Set/combo/course reviewed | Components verified |
| Market price items flagged | Required |
| Alcohol candidates flagged | Required |
| Raw food candidates flagged | Required |
| Allergen candidates flagged | Required |
| Health claim candidates flagged | Required |
| Sold-out behavior planned | Required |
| POS/KDS mapping reviewed | Required if integrated |

AI parsing is not owner confirmation.

---

## 9. Food Safety Notice Checklist

Food safety notice checklist:

| Check | Requirement |
|---|---|
| Allergen master reviewed | Required |
| Allergen candidate review complete | Required for high-risk |
| Raw food items confirmed | Required |
| Cross-contact notice available | Recommended |
| Takeout freshness notice | Required if pickup/delivery |
| Storage/reheating notice | Required if applicable |
| Spicy warning notice | Required if spicy options |
| Bone/shell warning | Required if applicable |
| Ingredient exclusion policy | Required if options allow exclusion |
| Health/nutrition claim review | Required if claims exist |
| Origin notice link | Required if applicable |
| Evidence rule | Defined for high-risk |

Food safety notices must not be purely AI-inferred.

---

## 10. Refund Cancellation Checklist

Refund/cancellation checklist:

| Check | Requirement |
|---|---|
| Immediate cooking policy | Required if table/order active |
| Cancel-before-KDS rule | Required |
| Cancel-after-KDS rule | Required |
| Prep-start lock rule | Required |
| Store mistake refund route | Required |
| Customer mistake handling | Required |
| Sold-out refund route | Required |
| Substitution consent rule | Required |
| Payment provider refund path | Required if prepaid |
| Partial refund support | Required if item-level refund |
| Coupon/point reversal | Required if benefits active |
| Receipt refund display | Required |
| Support dispute route | Required |
| Notice version | Approved before runtime |

Refund notice must match actual POS/payment/KDS behavior.

---

## 11. Reservation And No-Show Checklist

Reservation/no-show checklist:

| Check | Requirement |
|---|---|
| Reservation enabled | Determines notice requirement |
| Deposit enabled | Requires deposit notice |
| Cancellation cutoff | Required |
| Refund tier | Required if deposit |
| No-show grace period | Required |
| Late arrival rule | Required |
| Group reservation rule | Required if group booking |
| Pickup no-show rule | Required if pickup |
| Waiting call expiry | Required if waiting |
| Notification channel | Required |
| Evidence timestamps | Required |
| Owner confirmation | Required |
| HQ/legal review | Required if penalty/high-risk |

No-show penalty must not be enabled without notice evidence plan.

---

## 12. Alcohol Checklist

Alcohol checklist:

| Check | Requirement |
|---|---|
| Alcohol sale enabled | Explicit flag |
| Alcohol items confirmed | Required |
| Alcohol set menus confirmed | Required |
| Corkage enabled | Review required |
| Adult confirmation notice | Required |
| Staff ID verification policy | Required if alcohol |
| Acceptable ID guide | Required |
| Foreign customer ID guide | Recommended |
| Proxy purchase warning | Required |
| Delivery alcohol disabled by default | Required |
| Pickup verification policy | Required if pickup alcohol |
| Refund on ID failure | Required |
| POS alcohol category mapping | Required |
| Staff training notice | Required |
| Evidence packet | Required |

Alcohol must fail closed if readiness is incomplete.

---

## 13. Privacy Consent Checklist

Privacy consent checklist:

| Check | Requirement |
|---|---|
| Service terms | Required |
| Privacy collection/use | Required |
| Third-party provision | Required if applicable |
| Processing outsourcing notice | Required if applicable |
| Marketing consent | Optional and separated |
| Push/SMS/email consent | Channel-specific |
| Location consent | Feature-specific |
| Non-member order privacy | Required if non-member order |
| Withdrawal method | Required |
| Retention class | Required |
| i18n review | Required for customer-facing |
| Evidence versioning | Required |
| Support privacy inquiry route | Required |

Optional consent must not block core service.

---

## 14. Payment And Receipt Checklist

Payment/receipt checklist:

| Check | Requirement |
|---|---|
| Payment mode selected | Prepaid/postpaid/split/deposit |
| PG/VAN/provider configured | Required if payment active |
| Payment notice available | Required |
| Refund provider path | Required |
| Receipt format | Required |
| VAT/tax notice | Required if applicable |
| PG name notice | Required if applicable |
| Split payment notice | Required if split payment |
| Deposit payment notice | Required if deposit |
| Provider callback evidence | Required |
| Reconciliation route | Required |
| Support payment escalation | Required |

Payment notice must reflect provider behavior.

---

## 15. Coupon Event Checklist

Coupon/event checklist:

| Check | Requirement |
|---|---|
| Coupon enabled | Determines notice |
| Event enabled | Determines notice |
| Expiry rule | Required |
| Stacking rule | Required |
| First-order rule | Required if applicable |
| Screenshot invalid rule | Required if applicable |
| Gift exchange/refund rule | Required if gift |
| Abuse restriction | Required if promotion |
| Store/franchise scope | Required |
| Coupon reversal on refund | Required |
| Customer display surface | Required |
| Support dispute route | Required |

Coupon notice must match coupon engine rules.

---

## 16. Review Content Checklist

Review/content checklist:

| Check | Requirement |
|---|---|
| Review feature enabled | Determines notice |
| Review eligibility | Required |
| Photo upload notice | Required if photo |
| Copyright/portrait notice | Required if media |
| Profanity/moderation notice | Required |
| Review event abuse notice | Required if event |
| Deletion/non-restoration notice | Required |
| Rights infringement route | Required |
| Store reply policy | Required if replies |
| Support moderation route | Required |

Review notice must protect rights without suppressing fair criticism.

---

## 17. Device And Hardware Checklist

Device/hardware checklist:

| Check | Requirement |
|---|---|
| Table tablet enabled | Device notice |
| Kiosk enabled | Kiosk notice |
| QR link enabled | External link notice if needed |
| Timeout configured | Timeout notice |
| Network fallback plan | System notice |
| Printer/receipt plan | Receipt notice |
| Device damage policy | Device notice |
| Staff incident report route | Required |
| Evidence attachment | Required if incident |
| Accessibility on device | Required |

Device notice should be lightweight but available.

---

## 18. i18n Checklist

i18n checklist:

| Check | Requirement |
|---|---|
| Korean reference text | Required |
| Customer locale list | Defined |
| Critical translations | Reviewed |
| Machine draft separated | Required |
| Korean controlling text | Defined if applicable |
| Fallback behavior | Required |
| Store variable formatting | Required |
| Accessibility text | Required for key notices |
| Locale evidence | Required |
| Translation review queue | Required if missing |

High-risk notices must not rely on unreviewed translation.

---

## 19. Evidence Checklist

Evidence checklist:

| Check | Requirement |
|---|---|
| Notice shown event | Required for high-risk |
| Notice version ID | Required |
| Locale | Required |
| Surface ID | Required |
| Trigger reason | Required where triggered |
| Text hash | Required for critical |
| Ack evidence | Required if ack required |
| Store setting snapshot | Required |
| Order/payment link | Required if order/payment |
| KDS/POS link | Required if refund/cancel |
| Support case link | Required if dispute |
| Export/masking profile | Required |
| Retention class | Required |
| Legal hold handling | Required |

Evidence readiness is part of onboarding readiness.

---

## 20. Support Route Checklist

Support route checklist:

| Check | Requirement |
|---|---|
| Refund dispute route | Required |
| Privacy inquiry route | Required |
| Alcohol dispute route | Required if alcohol |
| Allergy/food safety route | Required |
| No-show dispute route | Required if reservation/waiting |
| Coupon dispute route | Required if coupon |
| Review dispute route | Required if review |
| Device incident route | Required if device |
| Payment error route | Required if payment |
| Escalation to HQ/legal | Required for high-risk |
| Case reason codes | Required |
| Evidence packet access | Required |

Support readiness prevents legal notice from becoming dead text.

---

## 21. Admin Owner Confirmation Checklist

Owner confirmation should capture:

| Item | Confirmation |
|---|---|
| Store information accurate | Required |
| Menu and prices accurate | Required |
| Order modes accurate | Required |
| Refund/cancel policy understood | Required |
| No-show/deposit policy understood | If applicable |
| Alcohol policy understood | If applicable |
| Privacy/marketing settings understood | Required if member/marketing |
| Coupon/event rules understood | If applicable |
| Store-specific variables confirmed | Required |
| Customer preview reviewed | Required |
| Mandatory locked notices acknowledged | Required |
| Support route understood | Required |

Owner confirmation must be evidence-backed.

---

## 22. HQ Review Checklist

Franchise/HQ review should check:

| Item | Requirement |
|---|---|
| Brand policy compliance | Required |
| Store legal notice coverage | Required |
| Menu category risk | Required |
| Alcohol policy | Required if alcohol |
| Refund/no-show consistency | Required |
| Coupon/event rules | Required if franchise coupon |
| i18n readiness | Required if multilingual |
| Store variable ranges | Required |
| Mandatory HQ locks | Required |
| Store override requests | Reviewed |
| Launch readiness state | Approved or blocked |

HQ review must be tenant/franchise-scoped.

---

## 23. Legal Review Checklist

Legal/compliance review should check:

- privacy terms
- refund/cancel wording
- deposit/no-show penalty
- alcohol age-gate
- allergen/raw food wording
- store conduct/staff protection
- review/content terms
- coupon/event terms
- tax/receipt wording
- force majeure wording
- translation of high-risk notices
- emergency lock readiness
- evidence retention policy

Legal review must record decision and scope.

---

## 24. Activation Gate

Store activation must require gate checks.

Recommended gate states:

| Gate | Meaning |
|---|---|
| `PROFILE_GATE` | Store profile complete |
| `MENU_GATE` | Menu reviewed |
| `LEGAL_NOTICE_GATE` | Notices ready |
| `PRIVACY_GATE` | Consent ready |
| `PAYMENT_GATE` | Payment/refund ready |
| `ALCOHOL_GATE` | Alcohol ready or disabled |
| `RESERVATION_GATE` | Reservation/no-show ready or disabled |
| `I18N_GATE` | Critical translations ready |
| `SUPPORT_GATE` | Support route ready |
| `EVIDENCE_GATE` | Evidence rules ready |
| `OWNER_CONFIRM_GATE` | Owner confirmed |
| `HQ_LEGAL_GATE` | HQ/legal approved if needed |
| `ACTIVATION_GATE` | Final future runtime gate |

Failure in a mandatory gate blocks activation.

---

## 25. Warning Versus Blocking

Not all gaps block activation.

Recommended classification:

| Gap | Behavior |
|---|---|
| Privacy required consent missing | Block |
| Refund notice missing for prepaid order | Block |
| Alcohol age-gate missing | Block |
| Deposit/no-show notice missing | Block if deposit enabled |
| Evidence capture missing for high-risk | Block |
| Low-risk parking notice missing | Warning |
| Optional event notice missing while event disabled | No block |
| Translation missing for low-risk notice | Warning |
| Translation missing for high-risk consent | Block or fallback review |
| Support route missing for high-risk flow | Block |
| Owner confirmation missing | Block |

Blocking criteria must be deterministic.

---

## 26. Onboarding Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `STORE_ONBOARDING_STARTED` | Onboarding started |
| `STORE_PROFILE_REVIEWED` | Profile reviewed |
| `MENU_AI_PARSE_REVIEWED` | AI menu parse reviewed |
| `LEGAL_NOTICE_CHECKLIST_STARTED` | Legal checklist started |
| `LEGAL_NOTICE_CHECKLIST_COMPLETED` | Legal checklist completed |
| `PRIVACY_CHECKLIST_COMPLETED` | Privacy checklist completed |
| `ALCOHOL_CHECKLIST_COMPLETED` | Alcohol checklist completed |
| `REFUND_CHECKLIST_COMPLETED` | Refund checklist completed |
| `I18N_CHECKLIST_COMPLETED` | i18n checklist completed |
| `SUPPORT_ROUTE_CONFIRMED` | Support route confirmed |
| `OWNER_CONFIRMATION_CAPTURED` | Owner confirmed |
| `HQ_REVIEW_APPROVED` | HQ approved |
| `LEGAL_REVIEW_APPROVED` | Legal approved |
| `ACTIVATION_GATE_BLOCKED` | Activation blocked |
| `ACTIVATION_GATE_READY` | Activation ready |
| `ONBOARDING_REVIEW_REOPENED` | Review reopened |

Events must route through `10610`.

---

## 27. AI Assistance Boundary

AI may assist onboarding by:

- parsing menu
- detecting categories
- detecting alcohol candidates
- detecting allergen candidates
- detecting market price
- suggesting legal notices
- suggesting refund/no-show templates
- flagging missing checklist items
- summarizing owner review
- detecting i18n gaps
- suggesting support reason codes

AI must not:

- approve owner confirmation
- approve legal wording
- approve alcohol sales
- approve privacy consent
- approve refund/no-show penalty
- approve store launch
- suppress checklist failures
- mark activation ready without authorized review

AI is setup assistant only.

---

## 28. Security Boundary

Onboarding checklist is compliance-sensitive.

Rules:

- tenant/store scope mandatory
- owner confirmation requires authenticated actor
- HQ review requires scoped authority
- legal review requires authorized reviewer
- high-risk gate changes require audit
- sales rep cannot approve high-risk items alone
- support cannot modify onboarding readiness
- AI cannot approve gates
- checklist history must remain readable
- activation gate cannot be bypassed silently

Onboarding readiness is not casual setup state.

---

## 29. Anti-Patterns

Avoid:

- launching store after menu upload only
- launching payment without refund notice
- enabling alcohol without age-gate
- enabling reservation deposit without no-show notice
- enabling marketing without optional consent separation
- relying only on AI menu parse
- ignoring i18n for foreign customer flow
- ignoring support route
- ignoring evidence capture
- letting sales rep approve legal readiness
- letting store owner disable mandatory notice
- treating owner verbal confirmation as enough
- not recording onboarding gate failures
- activating runtime despite blocked gate
- using the same checklist for every store without service-mode logic

These anti-patterns must be blocked in future runtime design.

---

## 30. Runtime Deferral

This document defines legal notice admin checklist and store onboarding review governance only.

It does not authorize:

- onboarding UI implementation
- checklist database implementation
- activation gate implementation
- AI menu intake runtime
- owner confirmation runtime
- HQ/legal review runtime
- support route runtime
- evidence capture runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 31. Validation Checklist

Validation must confirm:

1. Onboarding readiness concept is defined.
2. Store onboarding states are defined.
3. Store identity checklist is defined.
4. Service mode checklist is defined.
5. Menu intake checklist is defined.
6. Food safety notice checklist is defined.
7. Refund/cancellation checklist is defined.
8. Reservation/no-show checklist is defined.
9. Alcohol checklist is defined.
10. Privacy consent checklist is defined.
11. Payment/receipt checklist is defined.
12. Coupon/event checklist is defined.
13. Review/content checklist is defined.
14. Device/hardware checklist is defined.
15. i18n checklist is defined.
16. Evidence checklist is defined.
17. Support route checklist is defined.
18. Admin owner confirmation checklist is defined.
19. HQ review checklist is defined.
20. Legal review checklist is defined.
21. Activation gate is defined.
22. Warning versus blocking is defined.
23. Onboarding audit events are defined.
24. AI assistance boundary is defined.
25. Security boundary is defined.
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

It also references:

- `10053 Catch Menu Mini Kiosk Foundation Static Specification Packet Policy`
- `10054 Catch Menu Mini Kiosk Foundation Static Artifact Target File Map And Coding Authorization Draft Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10734 Legal Notice Support Playbook And Case Reason Code Policy`
- `10735 Legal Notice Static Registry Readiness Check Policy`
- `10736 Legal Notice Implementation Authorization Draft Policy`
- `10800 Store Onboarding And Sales Setup Axis Index`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 33. Final Rule

Catch Menu store onboarding must include legal notice readiness, not only menu and payment setup.

A store may not be considered ready unless store identity, service modes, menu intake, food safety, refund/cancellation, reservation/no-show, alcohol, privacy, payment, coupon/event, review, device, i18n, evidence, support route, owner confirmation, HQ/legal review, and activation gates are evaluated according to enabled features.

Mandatory legal gaps must block activation.

Optional or low-risk gaps may produce warnings.

AI may assist setup and checklist detection.

AI cannot approve legal readiness, owner confirmation, HQ approval, legal review, alcohol policy, privacy consent, refund/no-show penalty, or runtime activation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.