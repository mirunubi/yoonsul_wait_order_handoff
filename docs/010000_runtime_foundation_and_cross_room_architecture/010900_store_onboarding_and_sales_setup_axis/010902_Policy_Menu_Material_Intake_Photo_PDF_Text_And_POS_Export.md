# 010902_Policy_Menu_Material_Intake_Photo_PDF_Text_And_POS_Export.md

## Purpose

This document defines the Menu Material Intake Photo, PDF, Text, and POS Export Policy for Catch Menu.

The previous document `10801 Store Sales Intake And Tenant Store Profile Setup Policy` defined sales lead intake, tenant/store profile draft setup, owner/admin contact capture, franchise/HQ relationship intake, service mode pre-selection, provider intake, support route intake, and sales authority boundaries.

This document focuses on collecting menu materials from the store.

Menu materials may arrive as:

- menu board photos
- printed menu photos
- PDF files
- spreadsheets
- website text
- delivery app screenshots
- POS export files
- handwritten menu lists
- franchise master menu files
- seasonal menu materials
- drink and alcohol menus
- owner-entered text

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Menu material intake is evidence intake, not final menu registration.

The correct rule is:

Uploaded menu material is source evidence.  
AI parsing output is draft.  
Owner correction is required.  
POS export is not automatically truth.  
Delivery app screenshots may be stale.  
Printed menus may contain old prices.  
Handwritten specials require confirmation.  
Alcohol and allergen candidates must be flagged.  
Every menu material must keep source, uploader, timestamp, scope, and review state.  

Menu intake must preserve source evidence before structured menu data is created.

---

## 3. Scope

This policy applies to:

- menu image upload
- menu board photography
- printed menu scanning
- PDF menu upload
- spreadsheet menu upload
- POS export intake
- delivery app menu capture
- website menu capture
- owner text entry
- franchise master menu file intake
- seasonal menu intake
- alcohol menu intake
- drink menu intake
- dessert menu intake
- option/add-on list intake
- set/combo/course menu intake
- menu price evidence
- menu source versioning
- AI parse handoff
- owner review handoff
- menu risk flag handoff

This policy defines intake governance only.

---

## 4. Menu Material Object Types

Recommended object types:

| Object Type | Meaning |
|---|---|
| `MENU_PHOTO` | Photo of menu board or printed menu |
| `MENU_PDF` | PDF menu file |
| `MENU_SPREADSHEET` | Spreadsheet menu data |
| `MENU_TEXT` | Owner-entered or copied text |
| `POS_EXPORT` | POS menu export |
| `DELIVERY_APP_CAPTURE` | Delivery platform menu screenshot/text |
| `WEBSITE_CAPTURE` | Website menu text or screenshot |
| `FRANCHISE_MASTER_MENU` | HQ-provided master menu |
| `SEASONAL_MENU` | Seasonal or limited menu |
| `HANDWRITTEN_SPECIAL` | Handwritten daily special |
| `ALCOHOL_MENU` | Alcohol-specific menu |
| `DRINK_MENU` | Beverage menu |
| `OPTION_LIST` | Option/add-on list |
| `SET_COMBO_MENU` | Set/combo/course menu material |
| `PRICE_NOTICE_SOURCE` | Price or market-price reference |
| `ALLERGEN_NOTICE_SOURCE` | Allergen/origin/source document |

Each object type requires review state.

---

## 5. Menu Material Intake Header

Every uploaded or captured material should include:

| Field | Required | Meaning |
|---|---:|---|
| `material_id` | yes | Unique material identity |
| `tenant_id` | yes | Tenant scope |
| `store_id` | conditional | Store scope |
| `onboarding_case_id` | yes | Onboarding case |
| `material_type` | yes | Object type |
| `source_channel` | yes | Owner, sales, HQ, POS, delivery app, web |
| `uploaded_by_actor_type` | yes | Sales, owner, HQ, staff, system |
| `uploaded_by_actor_id` | conditional | Actor identity |
| `uploaded_at` | yes | Upload/capture time |
| `source_date_claim` | optional | Claimed menu effective date |
| `file_ref` | conditional | File storage reference |
| `text_snapshot_ref` | conditional | Text snapshot reference |
| `language` | optional | Detected or selected language |
| `review_state` | yes | Draft/review/confirmed/rejected |
| `audit_ref` | yes | Audit correlation |

Material identity must be preserved even after parsing.

---

## 6. Material Review States

Recommended review states:

| State | Meaning |
|---|---|
| `UPLOADED` | Material uploaded |
| `SOURCE_PENDING_REVIEW` | Source needs review |
| `IMAGE_QUALITY_REVIEW_REQUIRED` | Image quality insufficient |
| `TEXT_EXTRACTION_PENDING` | Text extraction not complete |
| `AI_PARSE_PENDING` | Waiting for AI parse |
| `AI_PARSE_COMPLETED` | AI draft produced |
| `OWNER_REVIEW_PENDING` | Owner review required |
| `OWNER_CONFIRMED` | Owner confirmed source meaning |
| `HQ_REVIEW_PENDING` | HQ review required |
| `LEGAL_RISK_REVIEW_PENDING` | Risk review required |
| `SUPERSEDED` | Replaced by newer material |
| `REJECTED` | Not usable |
| `ARCHIVED` | Kept as evidence only |

Material review state must be separate from menu item approval.

---

## 7. Source Channel Rules

Source channel rules:

| Source Channel | Reliability Notes |
|---|---|
| Owner upload | Strong but still requires review |
| Sales upload | Requires owner confirmation |
| HQ upload | Strong for franchise template |
| POS export | Strong for current POS, but mapping review needed |
| Delivery app capture | May be stale or platform-specific |
| Website capture | May be stale |
| Customer photo | Not authoritative |
| Staff upload | Requires owner/manager confirmation |
| AI-generated material | Not authoritative |
| External crawler | Requires review |
| Legacy database | Requires migration review |

No source is automatically launch-ready.

---

## 8. Photo Intake Policy

Photo intake should capture:

- original image file
- upload actor
- upload timestamp
- store context
- photo source description
- image quality state
- orientation
- visible menu sections
- price visibility
- glare/blur issue
- cropped text issue
- language detected
- duplicate photo candidate
- menu board location if relevant
- staff/people privacy risk if visible
- background sensitive data risk if visible

Photo must not be parsed silently if quality is poor.

---

## 9. Photo Quality Review

Photo quality states:

| State | Meaning |
|---|---|
| `QUALITY_GOOD` | Parse likely reliable |
| `QUALITY_ACCEPTABLE` | Parse possible with review |
| `BLUR_DETECTED` | Blurry |
| `GLARE_DETECTED` | Glare |
| `CROPPED_TEXT` | Missing edges |
| `LOW_RESOLUTION` | Low quality |
| `ANGLE_DISTORTED` | Perspective issue |
| `PRICE_UNREADABLE` | Price unclear |
| `MENU_NAME_UNREADABLE` | Item names unclear |
| `DUPLICATE_PHOTO` | Duplicate |
| `PRIVACY_REVIEW_REQUIRED` | People/personal info visible |
| `REUPLOAD_REQUIRED` | Cannot use |

Poor quality must create re-upload request.

---

## 10. PDF Intake Policy

PDF intake should capture:

- PDF file reference
- page count
- detected text layer
- image-only pages
- menu sections
- price columns
- language
- effective date if present
- footer policy text
- franchise branding if present
- allergens/origin information if present
- alcohol pages if present
- optional menu pages
- print date if present
- owner/HQ source

PDF pages must be tracked for source traceability.

---

## 11. Spreadsheet Intake Policy

Spreadsheet intake should capture:

- file reference
- sheet names
- column headers
- menu item rows
- category columns
- price columns
- option columns
- tax columns if present
- sold-out flags if present
- POS codes if present
- allergens if present
- alcohol flags if present
- effective dates if present
- formula presence
- hidden sheets
- owner/HQ review state

Spreadsheet data must be normalized only after review.

---

## 12. POS Export Intake Policy

POS export intake should capture:

| Field | Meaning |
|---|---|
| POS provider | Provider name |
| Export format | CSV, Excel, JSON, XML, proprietary |
| Exported at | Claimed export timestamp |
| Imported at | Intake timestamp |
| Exported by | Store/POS/vendor actor if known |
| Menu item code | POS item code |
| Category code | POS category |
| Price | POS price |
| Tax flag | Tax/VAT behavior |
| Option/modifier code | POS option |
| Sold-out state | If included |
| Active state | If included |
| Alcohol category | If included |
| KDS route | If included |
| Kitchen print group | If included |
| Payment category | If included |

POS export is operationally strong but still needs owner/POS mapping review.

---

## 13. Delivery App Capture Policy

Delivery app capture should capture:

- platform name
- store page URL or reference if available
- capture time
- screenshot/text source
- delivery-only price possibility
- delivery packaging option
- delivery menu differences
- platform promotion differences
- sold-out state
- platform category mapping
- customer-facing description
- delivery restriction
- alcohol delivery restriction
- platform review/legal text if relevant

Delivery app menu must not overwrite store dine-in menu without review.

---

## 14. Website Capture Policy

Website capture should capture:

- website URL/reference
- capture time
- page title
- menu sections
- text snapshot
- image snapshot
- outdated notice possibility
- event/seasonal menu markers
- price presence
- online-only descriptions
- brand story text separated from menu items
- contact/store info
- privacy/cookie notice if captured

Website text may include marketing language and must be separated from menu data.

---

## 15. Owner Text Entry Policy

Owner-entered text should capture:

- actor
- entry timestamp
- language
- menu section
- item name
- price
- description
- option notes
- handwritten style ambiguity
- owner confirmation state
- correction history
- audit reference

Owner-entered text is strong but still must pass structural review.

---

## 16. Franchise Master Menu Intake

Franchise master menu intake should capture:

- HQ tenant scope
- brand scope
- applicable stores
- master menu version
- effective date
- approved categories
- approved item names
- approved descriptions
- approved prices or price bands
- optional regional variation
- required legal notices
- allergen/origin master
- alcohol rule if applicable
- store override rules
- HQ approval actor
- audit reference

Franchise master menu must not leak across tenants.

---

## 17. Seasonal And Limited Menu Intake

Seasonal/limited menu intake should capture:

- start date
- end date
- limited quantity flag
- seasonal ingredient flag
- market price flag
- allergen risk
- promotion linkage
- coupon/event linkage
- store/HQ approval
- auto-expiry behavior
- sold-out behavior
- support notice requirement

Seasonal menus require expiry and availability review.

---

## 18. Alcohol Menu Intake

Alcohol menu intake should capture:

- item name
- alcohol type
- ABV if available
- serving size
- bottle/glass/unit
- set/combo inclusion
- corkage fee if applicable
- age-gate requirement
- staff ID check requirement
- delivery disabled flag
- pickup verification rule
- refund rule on ID failure
- POS alcohol category mapping
- legal review state

Alcohol menu intake must fail closed if uncertain.

---

## 19. Option And Add-On List Intake

Option/add-on material should capture:

- option group name
- option values
- required/optional flag
- single/multiple selection
- default option
- price adjustment
- spicy level
- size level
- sauce selection
- add-on ingredient
- allergen implications
- alcohol implication
- KDS routing effect
- sold-out effect
- substitution rule

Options can change legal and operational risk.

---

## 20. Set Combo Course Menu Intake

Set/combo/course material should capture:

- set name
- components
- selectable components
- fixed components
- component prices
- total price
- discount logic
- alcohol component
- allergen component
- raw food component
- refund/cancel implications
- KDS routing
- substitution rule
- coupon applicability

Set/combo/course menus must not hide regulated components.

---

## 21. Price Evidence Policy

Price evidence should capture:

- source material
- price text
- parsed price
- currency
- tax inclusion if stated
- dine-in price
- pickup price
- delivery price
- option price
- set price
- market price flag
- temporary price flag
- event price flag
- owner confirmation
- effective date

Price disputes require source traceability.

---

## 22. Risk Candidate Handoff

Menu material intake must flag candidates for later review:

| Risk Candidate | Examples |
|---|---|
| `ALCOHOL_CANDIDATE` | Beer, soju, wine, cocktail |
| `ALLERGEN_CANDIDATE` | Peanut, shrimp, egg, milk |
| `RAW_FOOD_CANDIDATE` | Yukhoe, sashimi, raw egg |
| `MARKET_PRICE_CANDIDATE` | Market price, seasonal price |
| `HEALTH_CLAIM_CANDIDATE` | Diet, detox, immune |
| `SPICY_HIGH_CANDIDATE` | Very spicy, challenge |
| `BONE_SHELL_CANDIDATE` | Bone, shell, crab |
| `SET_COMPONENT_RISK` | Alcohol/allergen hidden in set |
| `PRICE_UNCLEAR_CANDIDATE` | Blurred or ambiguous price |
| `OPTION_RISK_CANDIDATE` | Add-on affects allergen/alcohol |

Candidate flag is not final classification.

---

## 23. Duplicate And Conflict Handling

Duplicate/conflict cases:

| Conflict | Handling |
|---|---|
| Same item different price | Owner review required |
| POS export price differs from photo | POS/menu reconciliation required |
| Delivery price differs from dine-in | Separate channel price |
| HQ master differs from store photo | HQ/store override review |
| Old seasonal menu uploaded | Effective date review |
| Alcohol item hidden in drink list | Alcohol review |
| Menu name duplicated | Merge or distinguish |
| Option list reused across items | Confirm applicability |
| Image unclear but POS export clear | Owner review still required |

Conflict must not be silently resolved by AI.

---

## 24. Intake To AI Parse Handoff

AI parse handoff should include:

- material ID
- material type
- source channel
- file/text reference
- quality state
- language
- known store category
- service mode context
- POS/provider context if available
- franchise/HQ template context
- risk detection request
- extraction target fields
- uncertainty capture requirement
- no-finalization rule

AI parse handoff must preserve source links.

---

## 25. Intake To Owner Review Handoff

Owner review handoff should include:

- source materials
- AI draft extraction
- uncertain fields
- conflicts
- missing prices
- risk candidates
- duplicate candidates
- POS/menu mismatches
- proposed categories
- proposed options
- proposed set/combo/course structure
- owner questions
- required confirmations
- audit reference

Owner review must be actionable, not raw AI output only.

---

## 26. Intake Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `MENU_MATERIAL_UPLOADED` | Material uploaded |
| `MENU_MATERIAL_TEXT_CAPTURED` | Text captured |
| `MENU_MATERIAL_POS_EXPORT_IMPORTED` | POS export imported |
| `MENU_MATERIAL_QUALITY_REVIEWED` | Quality reviewed |
| `MENU_MATERIAL_REUPLOAD_REQUESTED` | Re-upload requested |
| `MENU_MATERIAL_SOURCE_CLASSIFIED` | Source classified |
| `MENU_MATERIAL_DUPLICATE_DETECTED` | Duplicate detected |
| `MENU_MATERIAL_CONFLICT_DETECTED` | Conflict detected |
| `MENU_RISK_CANDIDATE_FLAGGED` | Risk candidate flagged |
| `MENU_AI_PARSE_HANDOFF_CREATED` | Handoff to AI parse |
| `MENU_OWNER_REVIEW_HANDOFF_CREATED` | Handoff to owner review |
| `MENU_MATERIAL_REJECTED` | Material rejected |
| `MENU_MATERIAL_ARCHIVED` | Material archived |

Events must route through `10610` if implemented later.

---

## 27. Security And Privacy Boundary

Menu material intake security rules:

- tenant/store scope mandatory
- file upload must be access-controlled
- cross-tenant material access prohibited
- owner and sales access must be scoped
- HQ access must be tenant/franchise-scoped
- photos with people/personal data require privacy caution
- business pricing data is sensitive
- POS export may contain operational codes
- alcohol data is regulated feature data
- AI processing must not leak menu data across tenants
- rejected material remains auditable if retained
- deletion/retention must follow policy

Menu material is business evidence.

---

## 28. Anti-Patterns

Avoid:

- treating uploaded photo as final menu
- treating AI extraction as owner approval
- treating POS export as legally complete menu
- ignoring delivery/dine-in price differences
- overwriting source material after correction
- deleting old material without audit
- resolving price conflict silently
- ignoring alcohol candidate in drink menu
- ignoring allergen candidate in options
- ignoring set/combo hidden components
- using low-quality image without re-upload request
- letting sales finalize menu risk classification
- using customer-captured photo as authoritative
- exposing one tenant menu material to another tenant
- parsing without preserving source reference

These anti-patterns must remain prohibited.

---

## 29. Runtime Deferral

This document defines menu material intake governance only.

It does not authorize:

- file upload implementation
- OCR implementation
- AI parsing implementation
- POS export parser
- delivery app scraper
- website crawler
- owner review UI
- menu database schema
- risk detection runtime
- audit runtime
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 30. Validation Checklist

Validation must confirm:

1. Menu material object types are defined.
2. Menu material intake header is defined.
3. Material review states are defined.
4. Source channel rules are defined.
5. Photo intake policy is defined.
6. Photo quality review is defined.
7. PDF intake policy is defined.
8. Spreadsheet intake policy is defined.
9. POS export intake policy is defined.
10. Delivery app capture policy is defined.
11. Website capture policy is defined.
12. Owner text entry policy is defined.
13. Franchise master menu intake is defined.
14. Seasonal and limited menu intake is defined.
15. Alcohol menu intake is defined.
16. Option and add-on list intake is defined.
17. Set/combo/course menu intake is defined.
18. Price evidence policy is defined.
19. Risk candidate handoff is defined.
20. Duplicate and conflict handling is defined.
21. Intake to AI parse handoff is defined.
22. Intake to owner review handoff is defined.
23. Intake audit events are defined.
24. Security and privacy boundary is defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 31. Relationship To Previous Documents

This document follows:

- `10800 Store Onboarding And Sales Setup Axis Index`
- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705` through `10714` AI Menu Taxonomy Seed Registry policies
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10800 Store Onboarding And Sales Setup Axis Index`
- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`

It prepares:

- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`
- `10806 Store Service Mode Selection And Feature Readiness Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 32. Final Rule

Catch Menu menu material intake must preserve source evidence before structured menu data is created.

Photos, PDFs, spreadsheets, POS exports, delivery app captures, website text, owner text, franchise master files, seasonal menus, alcohol menus, option lists, and set/combo/course materials must be tenant-scoped, source-tracked, timestamped, review-stated, and auditable.

AI may parse and flag risk candidates.

AI cannot finalize menu data, resolve conflicts silently, approve prices, approve alcohol classification, approve allergen facts, or approve launch readiness.

Owner/HQ review remains required.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
