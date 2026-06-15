# 10809_Index_Store_Onboarding_And_Sales_Setup_Axis

## 1. Purpose

This document opens the Store Onboarding and Sales Setup Axis for Catch Menu.

The previous Legal Notice sequence from `10716` through `10736` established a legally controlled SaaS foundation for notices, consent, evidence, support, emergency locks, regulatory watchlists, onboarding checks, and implementation authorization boundaries.

This document starts the next axis.

The focus now shifts from legal notice registry governance to practical SaaS onboarding:

- how sales receives store information
- how menu materials are collected
- how AI parses store menus
- how owner/admin review is performed
- how legal notices are attached
- how service modes are selected
- how POS/KDS/payment readiness is checked
- how store launch readiness is determined
- how SaaS onboarding becomes repeatable and auditable

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Catch Menu onboarding is not a simple form.

The correct rule is:

Sales setup is the beginning of legal, operational, menu, payment, support, and runtime readiness.  
Menu upload is not launch readiness.  
AI parsing is not owner approval.  
Owner approval is not legal approval.  
Legal approval is not runtime deployment.  
POS/payment connection is not customer launch.  
Customer launch requires readiness across store identity, menu, options, notices, payment, KDS, support, i18n, evidence, and fallback.  

A SaaS product becomes scalable only when onboarding is structured.

---

## 3. Axis Scope

This Store Onboarding and Sales Setup Axis covers:

- store sales intake
- store profile setup
- business registration and contact intake
- service mode selection
- menu photo/PDF/text/POS import intake
- AI menu parsing and correction
- category and taxonomy review
- option/set/combo/course review
- allergen/alcohol/raw food/market price detection
- legal notice readiness handoff
- store-specific variables
- POS/payment/KDS setup readiness
- table/QR/device setup readiness
- i18n and customer language setup
- support route setup
- owner confirmation
- HQ/franchise confirmation
- launch readiness gate
- sales rep boundary
- onboarding evidence
- onboarding audit events
- implementation deferral

This axis defines SaaS onboarding governance only.

---

## 4. Axis Documents

Recommended documents in this axis:

| Document | Focus |
|---|---|
| `10800` | Store Onboarding and Sales Setup Axis Index |
| `10801` | Store Sales Intake And Tenant Store Profile Setup Policy |
| `10802` | Menu Material Intake Photo PDF Text And POS Export Policy |
| `10803` | AI Menu Parsing Correction And Owner Review Workflow Policy |
| `10804` | Menu Category Option Set Combo Course Review Policy |
| `10805` | Allergen Alcohol Raw Food Market Price Detection Handoff Policy |
| `10806` | Store Service Mode Selection And Feature Readiness Policy |
| `10807` | POS Payment KDS Integration Readiness Intake Policy |
| `10808` | Store Legal Notice Variable Setup And Owner Confirmation Policy |
| `10809` | Store i18n Language Customer Surface Readiness Policy |
| `10810` | Table QR Mini Kiosk Device Setup Readiness Policy |
| `10811` | Store Support Route Escalation And Case Readiness Policy |
| `10812` | Sales Rep Authority Boundary And Onboarding Evidence Policy |
| `10813` | Owner HQ Legal Approval Gate And Launch Readiness Policy |
| `10814` | Store Onboarding Readiness Dashboard Static Specification Policy |
| `10815` | Store Onboarding Axis Closure And Runtime Deferral Policy |

This list may be extended if needed.

---

## 5. Store Onboarding Pipeline

Recommended onboarding pipeline:

1. Sales intake starts.
2. Tenant/store profile is created as draft.
3. Store service modes are selected.
4. Menu materials are collected.
5. AI parses menu materials.
6. AI classification is reviewed by human.
7. Owner corrects menu/category/option/price data.
8. Risk candidates are flagged.
9. Legal notice requirements are generated as draft.
10. Payment/POS/KDS readiness is checked.
11. Device/table/QR readiness is checked.
12. i18n/customer language readiness is checked.
13. Support route is assigned.
14. Owner confirmation is captured.
15. HQ/legal review occurs where required.
16. Launch readiness state is determined.
17. Runtime remains deferred until explicit authorization.

Pipeline state must be auditable.

---

## 6. Onboarding State Registry

Recommended states:

| State | Meaning |
|---|---|
| `SALES_LEAD_CREATED` | Sales lead created |
| `STORE_PROFILE_DRAFT` | Store profile draft started |
| `STORE_PROFILE_REVIEW_PENDING` | Store profile needs review |
| `SERVICE_MODE_SELECTION_PENDING` | Store service modes not selected |
| `MENU_MATERIAL_PENDING` | Menu materials missing |
| `MENU_AI_PARSE_PENDING` | AI parsing not complete |
| `MENU_OWNER_REVIEW_PENDING` | Owner review required |
| `MENU_RISK_REVIEW_PENDING` | Allergen/alcohol/raw/price review needed |
| `LEGAL_NOTICE_SETUP_PENDING` | Legal notice setup required |
| `PAYMENT_SETUP_PENDING` | Payment readiness pending |
| `POS_KDS_SETUP_PENDING` | POS/KDS readiness pending |
| `DEVICE_SETUP_PENDING` | QR/tablet/kiosk readiness pending |
| `I18N_SETUP_PENDING` | Language readiness pending |
| `SUPPORT_ROUTE_PENDING` | Support route missing |
| `OWNER_CONFIRMATION_PENDING` | Owner confirmation missing |
| `HQ_REVIEW_PENDING` | HQ review needed |
| `LEGAL_REVIEW_PENDING` | Legal review needed |
| `READY_WITH_WARNINGS` | Non-blocking warnings remain |
| `READY_FOR_LAUNCH_REVIEW` | Ready for launch review |
| `BLOCKED` | Launch blocked |
| `LAUNCH_APPROVED_FOR_FUTURE_RUNTIME` | Launch approved when runtime exists |

This state registry is planning-only.

---

## 7. Sales Intake Boundary

Sales intake may collect:

- store name
- business registration info
- address
- owner/admin contact
- service mode preferences
- menu photos/files
- POS provider info
- payment provider preference
- table count
- QR/table device requirements
- language needs
- alcohol sale status
- reservation/waiting need
- coupon/event plan
- delivery/pickup plan
- franchise/HQ relationship
- opening target date

Sales intake must not approve legal readiness.

---

## 8. Sales Rep Authority Boundary

Sales representatives may:

- collect store information
- upload menu materials
- guide owner through setup
- explain feature options
- request review
- flag missing information
- help prepare onboarding packet
- schedule owner/HQ review
- request legal/support escalation

Sales representatives must not:

- approve legal notice wording
- activate high-risk notices
- approve refund/no-show penalty
- approve alcohol flow
- approve privacy consent
- approve payment settlement
- bypass owner confirmation
- bypass HQ/legal review
- mark blocked store as launch-ready
- mutate evidence
- promise legal immunity
- promise unsupported POS/payment behavior

Sales is intake and coordination, not authority.

---

## 9. AI Onboarding Assistant Boundary

AI may assist by:

- parsing menu images
- extracting menu names
- extracting prices
- grouping categories
- detecting options
- detecting set/combo/course patterns
- detecting alcohol candidates
- detecting allergen candidates
- detecting raw food candidates
- detecting market price candidates
- suggesting legal notice families
- suggesting support routes
- finding missing onboarding fields
- summarizing owner corrections
- comparing POS export and menu image
- generating review checklist drafts

AI must not:

- approve parsed menu as final
- approve prices
- approve allergen facts
- approve alcohol sale
- approve legal notices
- approve privacy consent
- approve refund/no-show policy
- approve customer launch
- suppress risk candidates
- fabricate missing store information

AI output remains draft until reviewed.

---

## 10. Store Profile Setup Boundary

Store profile setup should define:

| Area | Requirement |
|---|---|
| Tenant scope | Required |
| Store identity | Required |
| Owner/admin identity | Required |
| Business registration | Required where applicable |
| Store address | Required |
| Business hours | Required |
| Service modes | Required |
| Table count | Conditional |
| POS provider | Conditional |
| Payment mode | Conditional |
| KDS availability | Conditional |
| Alcohol flag | Required |
| Pickup/delivery flag | Required |
| Reservation/waiting flag | Required |
| Membership flag | Conditional |
| Coupon/event flag | Conditional |
| Support contact | Required |

Store profile is the onboarding anchor.

---

## 11. Menu Material Intake Boundary

Menu material intake may accept:

- menu board photos
- printed menu photos
- PDF menus
- image files
- website menu text
- delivery app menu text
- POS export
- spreadsheet menu
- owner-entered text
- franchise menu template
- seasonal menu list
- handwritten specials
- drink menu
- alcohol menu

Each material must record source, uploaded time, actor, and review state.

---

## 12. AI Menu Parsing Boundary

AI menu parsing should produce draft outputs:

- menu name candidates
- category candidates
- price candidates
- option candidates
- set/combo/course candidates
- item description candidates
- spice/raw/alcohol/allergen candidate flags
- market price candidate flags
- unclear text candidates
- duplicate item candidates
- missing price candidates
- confidence scores
- review questions

AI parsing must never directly create launch-ready menu data.

---

## 13. Owner Review Boundary

Owner review must confirm:

- menu names
- prices
- categories
- descriptions
- options
- set/combo/course components
- alcohol items
- raw food items
- allergen-sensitive items
- market price items
- unavailable/sold-out behavior
- refund/cancel policy variables
- pickup/delivery behavior
- no-show/deposit settings
- store contact/support route

Owner review must be authenticated and auditable.

---

## 14. Legal Notice Handoff Boundary

Onboarding must hand off to legal notice readiness when:

- alcohol is enabled
- reservation deposit is enabled
- waiting no-show penalty is enabled
- pickup no-show policy is enabled
- prepaid payment is enabled
- refund/cancellation limits exist
- coupon/event is enabled
- membership/privacy is enabled
- marketing consent is enabled
- review/photo upload is enabled
- raw food/allergen risk exists
- device/tablet/kiosk is deployed
- delivery/pickup is enabled

Legal notice handoff must reference `10716` through `10736`.

---

## 15. POS Payment KDS Readiness Boundary

Onboarding must check:

| Area | Readiness Question |
|---|---|
| POS | Is POS integrated, manual, or deferred? |
| Payment | Is payment prepaid, postpaid, split, deposit? |
| KDS | Is kitchen ticket integration active or manual? |
| Refund | Can actual refund behavior match notice? |
| Cancellation | Can cancellation state be enforced? |
| Sold-out | Can sold-out be handled safely? |
| Printer | Is receipt/kitchen print fallback available? |
| Manual fallback | Is staff fallback documented? |
| Reconciliation | Is payment/order mismatch route defined? |

Notice cannot promise behavior integration does not support.

---

## 16. Device And Table Setup Boundary

Device/table setup should check:

- table count
- table identifiers
- QR placement
- table tablet availability
- mini kiosk availability
- full kiosk availability
- device ownership
- device damage notice
- timeout behavior
- network fallback
- charger/power setup
- printer connection
- staff assistance route
- accessibility on device
- language selector availability

Device readiness is operational and legal.

---

## 17. i18n Readiness Boundary

i18n onboarding should check:

- default store language
- customer target languages
- menu translation availability
- legal notice translation readiness
- allergen translation readiness
- alcohol notice translation readiness
- refund/no-show translation readiness
- staff phrase guide
- fallback language
- Korean controlling text where applicable
- owner/HQ review of translations
- customer support language route

Multilingual readiness is a SaaS strength and legal safeguard.

---

## 18. Support Readiness Boundary

Support readiness should define:

- store support owner
- platform support route
- HQ support route if franchise
- refund escalation
- payment error escalation
- privacy request escalation
- alcohol dispute escalation
- food safety complaint escalation
- no-show dispute escalation
- device incident escalation
- customer response templates
- reason code family availability
- evidence packet lookup plan

Support must be ready before customer launch.

---

## 19. Launch Readiness Principle

A store can be considered launch-ready only if:

1. Store profile is complete.
2. Service modes are selected.
3. Menu data is reviewed by owner.
4. Risk candidates are reviewed.
5. Legal notice requirements are satisfied or deferred with block.
6. Payment/POS/KDS behavior matches notice promises.
7. Device/table setup is ready.
8. i18n critical path is ready.
9. Support routes are ready.
10. Owner confirmation is captured.
11. HQ/legal review is completed where required.
12. Blocking gaps are resolved.
13. Runtime authorization separately exists.

Launch readiness is not automatic activation.

---

## 20. Warning Versus Blocking

Suggested warning/blocking rules:

| Gap | Result |
|---|---|
| Store phone missing | Block |
| Menu prices unreviewed | Block |
| Alcohol candidate unreviewed | Block |
| Allergen high-risk item unreviewed | Block |
| Refund notice missing for prepaid | Block |
| Payment provider unknown for prepaid | Block |
| POS/KDS mismatch with cancellation policy | Block |
| Support route missing for high-risk flow | Block |
| Optional parking notice missing | Warning |
| Low-risk translation missing | Warning |
| Device damage policy missing for no device | Not applicable |
| Coupon notice missing when coupon disabled | Not applicable |
| Review policy missing when reviews disabled | Not applicable |

Blocking rules must be deterministic.

---

## 21. Onboarding Evidence

Onboarding evidence should preserve:

- who uploaded menu material
- what material was uploaded
- AI parse output
- confidence and uncertainty
- owner corrections
- owner confirmations
- legal notice checklist state
- HQ/legal review decisions
- service modes selected
- POS/payment/KDS readiness notes
- support route setup
- i18n review state
- launch readiness result
- warnings
- blocks
- audit references

Onboarding evidence protects both platform and store.

---

## 22. Onboarding Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `ONBOARDING_AXIS_STARTED` | Onboarding axis started |
| `SALES_LEAD_CREATED` | Sales lead created |
| `STORE_PROFILE_DRAFT_CREATED` | Store draft created |
| `STORE_SERVICE_MODE_SELECTED` | Service mode selected |
| `MENU_MATERIAL_UPLOADED` | Menu material uploaded |
| `MENU_AI_PARSE_COMPLETED` | AI parse completed |
| `MENU_OWNER_REVIEW_COMPLETED` | Owner review completed |
| `MENU_RISK_CANDIDATE_FLAGGED` | Risk candidate flagged |
| `LEGAL_NOTICE_HANDOFF_CREATED` | Handoff to legal notice |
| `PAYMENT_READINESS_CHECKED` | Payment readiness checked |
| `POS_KDS_READINESS_CHECKED` | POS/KDS readiness checked |
| `DEVICE_READINESS_CHECKED` | Device readiness checked |
| `I18N_READINESS_CHECKED` | i18n readiness checked |
| `SUPPORT_ROUTE_CONFIRMED` | Support route confirmed |
| `OWNER_CONFIRMATION_CAPTURED` | Owner confirmed |
| `HQ_LEGAL_REVIEW_REQUESTED` | HQ/legal review requested |
| `LAUNCH_READINESS_BLOCKED` | Launch blocked |
| `LAUNCH_READINESS_READY` | Launch ready for future runtime |

Events must route through `10610` if implemented later.

---

## 23. Security Boundary

Onboarding is sensitive.

Rules:

- tenant/store scope mandatory
- sales rep access must be limited
- owner confirmation requires authentication
- uploaded menu material may contain sensitive business data
- business registration info must be protected
- payment/POS provider info must be protected
- support contact info must be protected
- AI outputs must be marked draft
- risk flags must not be hidden
- cross-tenant access prohibited
- launch readiness changes audited
- activation cannot bypass gate

Onboarding data is SaaS control-plane data.

---

## 24. Anti-Patterns

Avoid:

- launching from menu photo only
- treating AI parse as final menu
- letting sales approve legal readiness
- enabling alcohol without review
- enabling prepaid payment without refund policy
- enabling reservation deposit without no-show notice
- enabling pickup without freshness/no-show policy
- enabling customer language without legal translation plan
- promising POS/KDS behavior before integration check
- ignoring support route
- hiding AI uncertainty
- skipping owner confirmation
- skipping HQ/legal review when required
- using onboarding checklist as runtime activation by itself
- implementing broad onboarding runtime without authorization

These anti-patterns must remain prohibited.

---

## 25. Runtime Deferral

This document defines Store Onboarding and Sales Setup Axis planning only.

It does not authorize:

- onboarding database implementation
- sales CRM implementation
- menu upload implementation
- AI parsing runtime
- owner review UI
- legal notice handoff runtime
- POS/payment/KDS readiness runtime
- device setup runtime
- support route runtime
- launch readiness dashboard
- activation runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 26. Validation Checklist

Validation must confirm:

1. Axis scope is defined.
2. Axis documents are listed.
3. Store onboarding pipeline is defined.
4. Onboarding state registry is defined.
5. Sales intake boundary is defined.
6. Sales rep authority boundary is defined.
7. AI onboarding assistant boundary is defined.
8. Store profile setup boundary is defined.
9. Menu material intake boundary is defined.
10. AI menu parsing boundary is defined.
11. Owner review boundary is defined.
12. Legal notice handoff boundary is defined.
13. POS/payment/KDS readiness boundary is defined.
14. Device/table setup boundary is defined.
15. i18n readiness boundary is defined.
16. Support readiness boundary is defined.
17. Launch readiness principle is defined.
18. Warning versus blocking is defined.
19. Onboarding evidence is defined.
20. Audit events are defined.
21. Security boundary is defined.
22. Anti-patterns are listed.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document follows:

- `10716` through `10736` Legal Notice Static Registry and SaaS Legal Readiness sequence

It references:

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
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10736 Legal Notice Implementation Authorization Draft Policy`

It prepares:

- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 28. Final Rule

Catch Menu Store Onboarding and Sales Setup must be treated as a SaaS control-plane pipeline, not a simple menu upload task.

Sales intake, AI menu parsing, owner correction, legal notice handoff, service mode readiness, POS/payment/KDS readiness, device readiness, i18n readiness, support readiness, owner confirmation, HQ/legal approval, and launch readiness must be separated and auditable.

AI may assist setup and detection.

Sales may assist onboarding.

Only authorized owner/HQ/legal/platform roles may approve the relevant readiness gates.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.