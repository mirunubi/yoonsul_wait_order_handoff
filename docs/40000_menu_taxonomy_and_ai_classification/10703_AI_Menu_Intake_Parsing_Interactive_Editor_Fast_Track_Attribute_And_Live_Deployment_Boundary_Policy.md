# 10703_AI_Menu_Intake_Parsing_Interactive_Editor_Fast_Track_Attribute_And_Live_Deployment_Boundary_Policy

## 1. Purpose

This document defines the AI Menu Intake, Menu Board Parsing, Interactive Menu Editor, Fast Track Attribute Setup, Validation, and Live Deployment Boundary Policy.

The previous artifact `10702 Fast Track Admin Console Control Tower KDS Load Penalty Governance And Store Operations Policy` expanded the Fast Track Admin Console into a central control tower for KDS load, valve controls, penalty review, loss analytics, and admin security.

This document adds a missing first-mile admin module:

- initial menu setup
- seasonal menu registration
- paper menu/photo/menu board ingestion
- AI-based OCR and multimodal parsing
- structured menu draft creation
- human review and correction
- menu category classification
- price extraction
- menu description extraction
- cooking time recommendation
- fast track eligibility toggle
- KDS/menu/POS/customer app deployment
- live synchronization
- audit and rollback

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Menu intake is not simple data entry.

It is a controlled source-to-runtime publishing workflow.

The correct rule is:

AI may draft menu data.  
AI may not publish menu data by itself.  
OCR confidence is not source truth.  
Uploaded menu image is evidence, not confirmed catalog.  
Manager confirmation is required before live deployment.  
Menu price must be validated before customer exposure.  
Cooking time recommendation is advisory.  
Fast track eligibility must be explicitly approved.  
Menu deployment affects customer app, KDS, POS, inventory, tax, allergy, i18n, and financial flows.  
Live sync must be versioned, reversible, audited, and tenant/store scoped.  

The system must reduce typing burden without allowing AI recognition errors to become customer-facing truth.

---

## 3. Menu Intake Scope

This policy applies to:

- paper menu board image upload
- chalkboard image upload
- printed menu PDF upload
- handwritten menu image upload
- text menu paste
- spreadsheet menu import
- seasonal menu import
- store-specific menu update
- franchise template menu update
- AI OCR parsing
- multimodal menu classification
- LLM-assisted category/tag/description extraction
- price parsing
- cooking time recommendation
- fast track attribute assignment
- menu validation
- human correction
- approval
- live deployment
- rollback
- audit and evidence preservation

This module belongs to Admin Console, CMS/Menu Governance, Store Runtime, KDS, POS Handoff, Data Governance, and Security Foundation.

---

## 4. Menu Intake Source Types

Supported source candidates:

| Source Type | Description |
|---|---|
| `IMAGE_MENU_BOARD` | Photo of menu board |
| `IMAGE_CHALKBOARD` | Chalkboard or handwritten board |
| `IMAGE_PAPER_MENU` | Printed menu photo |
| `PDF_MENU` | Uploaded menu PDF |
| `TEXT_MENU_LIST` | Pasted menu text |
| `SPREADSHEET_MENU` | Spreadsheet import |
| `POS_EXPORT_MENU` | Existing POS export |
| `FRANCHISE_TEMPLATE_MENU` | HQ-approved template |
| `SEASONAL_MENU_PACKET` | Seasonal menu bundle |
| `MANUAL_ENTRY` | Direct admin entry |

Each source type requires validation and audit.

---

## 5. Upload Security Boundary

Uploaded menu files must be handled safely.

Upload controls:

- tenant/store scope required
- admin session required
- file type validation
- file size limit
- malware scan
- content-type validation
- storage path not exposed to client
- signed short-lived upload URL if used
- raw file access restricted
- audit record created
- retention policy applied
- AI processing permission checked
- PII/secrets detection if applicable

Uploaded file path must not become public URL.

---

## 6. AI Parsing Boundary

AI parsing may extract candidate fields.

Candidate extracted fields:

- menu category
- menu name
- menu description
- price
- option group
- option item
- set/combo relationship
- serving size
- spicy level
- temperature
- ingredient hints
- allergen candidates
- dietary tags
- cooking time estimate
- fast track suitability
- KDS station candidate
- menu image crop reference
- confidence score
- source bounding box

AI extraction result is draft.

It must not become live menu without human confirmation.

---

## 7. OCR And LLM Confidence Boundary

AI parsing must include confidence markers.

Recommended confidence levels:

| Level | Meaning |
|---|---|
| `HIGH_CONFIDENCE` | Likely correct |
| `MEDIUM_CONFIDENCE` | Needs quick review |
| `LOW_CONFIDENCE` | Requires manual confirmation |
| `CONFLICT_DETECTED` | Conflicting extraction |
| `PRICE_UNCERTAIN` | Price unclear |
| `CATEGORY_UNCERTAIN` | Category unclear |
| `DUPLICATE_CANDIDATE` | Possible duplicate menu |
| `HUMAN_REVIEW_REQUIRED` | Must be reviewed |

Low-confidence price or menu name must block deployment.

---

## 8. Structured Menu Draft Boundary

AI parsing creates structured draft.

Recommended draft fields:

| Field | Meaning |
|---|---|
| `menu_draft_id` | Draft id |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope |
| `source_file_id` | Uploaded source |
| `source_type` | Source type |
| `category_candidate` | AI category |
| `menu_name_candidate` | AI menu name |
| `description_candidate` | AI description |
| `price_candidate` | AI price |
| `currency` | Currency |
| `option_group_candidates` | Options |
| `tag_candidates` | Tags |
| `allergen_candidates` | Allergens |
| `cooking_time_candidate` | Estimated cooking time |
| `fasttrack_candidate` | Fast track suitability |
| `kds_station_candidate` | KDS station |
| `confidence_summary` | Confidence |
| `review_state` | Review status |
| `policy_version` | Parsing policy |
| `created_by` | Admin actor |
| `audit_ref` | Audit reference |

Draft is editable.

Draft is not live.

---

## 9. Interactive Editor Boundary

Interactive editor should support split-view correction.

Recommended UI pattern:

- left: original image/PDF preview
- right: structured editable menu draft
- bounding box highlight
- menu row navigation
- confidence indicator
- inline validation
- duplicate warning
- category dropdown
- price field
- description field
- cooking time field
- fast track toggle
- KDS station selector
- allergen/tag fields
- save draft
- validate
- approve
- deploy
- rollback preview

Editor must preserve original AI output and human edits.

---

## 10. Split View Evidence Boundary

Split view must preserve evidence link.

Each extracted menu row may link to:

- source image id
- page number
- bounding box coordinates
- OCR text
- AI normalized text
- confidence score
- human-corrected value
- reviewer id
- timestamp
- audit reference

Evidence link helps resolve disputes and correction history.

---

## 11. Menu Category Classification Boundary

AI may classify categories.

Candidate categories:

- kimbap
- rice bowl
- noodle
- salad/poke
- protein cup
- soup/stew
- side
- beverage
- seasonal
- set/combo
- add-on
- topping
- sauce
- dessert
- retail/PB
- limited item

Category must be editable by admin.

Category affects customer browsing, KDS routing, prep time, inventory, and fast track suitability.

---

## 12. Category Governance Boundary

Category is not merely label.

Category may affect:

- customer app menu grouping
- KDS station routing
- preparation time default
- inventory deduction rule
- tax/VAT treatment if applicable
- allergy visibility
- fast track eligibility
- display order
- sales analytics
- menu availability
- franchise template mapping

Wrong category can create operational errors.

Category change must be audited.

---

## 13. Price Parsing Boundary

Price parsing is high-risk.

Price validation must detect:

- missing price
- non-numeric price
- ambiguous comma/decimal
- old/new price conflict
- set price vs single item price
- option price
- discount label mistaken as price
- Korean won marker
- tax inclusion marker
- crossed-out price
- handwritten unclear price
- OCR digit confusion

Price with low confidence must block live deployment.

Customer-facing price requires human confirmation.

---

## 14. Menu Description Boundary

AI may draft description.

Description must be reviewed for:

- ingredient accuracy
- allergen risk
- health claim risk
- legal/advertising risk
- brand tone
- language quality
- menu identity consistency
- spicy/temperature warning
- vegetarian/vegan claim correctness
- no prohibited or misleading claim

AI-generated description must not create unverified health or nutrition claim.

---

## 15. Allergen And Dietary Tag Boundary

AI may infer allergen/dietary candidates.

But allergen data must be verified.

Potential tags:

- egg
- milk
- wheat
- soy
- peanut
- tree nut
- fish
- shellfish
- sesame
- meat
- spicy
- vegan candidate
- vegetarian candidate
- gluten-containing candidate

Allergen inference is high-risk.

Human confirmation or recipe source linkage is required before customer exposure.

---

## 16. Cooking Time Recommendation Boundary

AI may recommend cooking time.

Recommendation inputs may include:

- category
- menu name
- recipe template
- KDS historical average
- station assignment
- prep complexity
- hot/cold item
- assembly time
- equipment requirement
- batch-prep availability
- staff skill factor

Cooking time recommendation is advisory.

Manager or HQ approval is required before operational use.

---

## 17. Cooking Time Default Matrix Boundary

Cooking time default matrix may exist by category.

Example candidate defaults:

| Category | Candidate Default |
|---|---:|
| Kimbap | 2~4 minutes |
| Protein cup | 2~4 minutes |
| Salad/Poke | 3~5 minutes |
| Noodle | 4~8 minutes |
| Hot soup/stew | 5~10 minutes |
| Beverage | 1~3 minutes |
| Side | 2~6 minutes |
| Set/combo | Sum or max of components plus buffer |

Exact values must be store/menu calibrated.

Defaults must not be hardcoded as final truth.

---

## 18. Fast Track Eligibility Attribute Boundary

Each menu may have fast track eligibility.

Attributes:

- fast track enabled
- fast track disabled reason
- minimum prep time
- maximum acceptable promise time
- freshness window
- packaging suitability
- travel tolerance
- pickup shelf temperature requirement
- KDS priority allowed
- Red/Yellow zone behavior
- option complexity limit
- inventory dependency
- no-show waste risk class

Fast track eligibility must be explicitly approved.

AI may recommend, but not activate alone.

---

## 19. Fast Track Suitability Rule

Fast track suitability may consider:

- can be prepared within promise window
- holds quality for pickup grace window
- not overly temperature-sensitive
- packaging stable
- not high-risk allergy customization
- not high station bottleneck item
- inventory reliable
- KDS priority fair
- no complex manual staff explanation required

Some menus should be ineligible even if popular.

---

## 20. KDS Station Routing Boundary

Menu setup may define KDS station.

Candidate stations:

- kimbap station
- noodle station
- bowl/salad station
- beverage station
- soup station
- packing station
- cashier/pickup station
- prep station
- finishing station

KDS station affects load calculation and dynamic throttling.

Station routing must be reviewed for operational accuracy.

---

## 21. Option And Modifier Boundary

Menu parsing may identify options.

Examples:

- size
- protein add-on
- sauce choice
- spicy level
- rice/noodle option
- set combo
- beverage add-on
- topping
- no ingredient request

Option/modifier affects price, prep time, KDS routing, inventory, and allergy.

Option extraction must be reviewed.

---

## 22. Menu Validation Boundary

Before save/deploy, validation must check:

- menu name present
- category present
- price valid
- currency valid
- duplicate menu warning handled
- cooking time greater than zero
- fast track eligibility explicitly set
- KDS station set if required
- option price valid
- allergen review completed if needed
- description safe
- image/source linked
- policy version attached
- required i18n keys created or queued
- tenant/store scope valid

Validation failure must block live deployment.

---

## 23. Validation Error Projection Boundary

Validation errors must be admin-safe and actionable.

Examples:

- “Price is missing.”
- “Cooking time must be greater than 0.”
- “Fast Track status must be selected.”
- “This menu may duplicate an existing item.”
- “Allergen review is required.”
- “KDS station is missing.”
- “Menu name confidence is low. Please confirm.”

Validation text must use i18n keys where human-visible.

---

## 24. Approval Boundary

Menu deployment requires approval.

Approval may vary by scope:

| Scope | Approval |
|---|---|
| Store-only draft menu | Store manager or owner |
| Franchise template menu | HQ menu authority |
| Financial price change | Store owner/HQ depending policy |
| Allergen-sensitive change | Recipe/QC authority |
| Fast track enable | Store manager plus policy check |
| Seasonal campaign menu | HQ campaign owner |
| Multi-store deployment | HQ approval |
| Legal/health claim | Legal/QC review |

Approval must be auditable.

---

## 25. Live Deployment Boundary

Live deployment may update:

- customer menu projection
- kiosk menu
- Mini Kiosk menu
- Full Kiosk menu
- staff order screen
- POS handoff menu mapping
- KDS menu/station mapping
- inventory/menu availability
- pricing display
- coupon/apply rules
- fast track eligibility
- analytics category mapping
- i18n message registry

Deployment must be versioned and reversible.

---

## 26. Deployment State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `MENU_DRAFT_CREATED` | Draft created |
| `AI_PARSE_COMPLETED` | AI parse completed |
| `HUMAN_REVIEW_REQUIRED` | Review required |
| `HUMAN_EDITING` | Admin editing |
| `VALIDATION_FAILED` | Validation failed |
| `VALIDATION_PASSED` | Validation passed |
| `APPROVAL_REQUIRED` | Approval required |
| `APPROVED_FOR_DEPLOYMENT` | Approved |
| `DEPLOYMENT_SCHEDULED` | Scheduled |
| `DEPLOYING` | Deploying |
| `DEPLOYED_LIVE` | Live |
| `DEPLOYMENT_PARTIAL` | Partial deployment |
| `DEPLOYMENT_FAILED` | Failed |
| `ROLLBACK_REQUIRED` | Rollback required |
| `ROLLED_BACK` | Rolled back |
| `ARCHIVED` | Archived |

Deployment failure must not leave inconsistent menu state.

---

## 27. Instant Sync Boundary

Instant sync must be controlled.

Live sync may notify:

- customer app
- kiosk
- staff web
- KDS
- POS adapter
- menu availability service
- inventory service
- analytics read model
- CMS/i18n surface
- cache/CDN
- admin projection

Instant sync must preserve version consistency.

Partial sync must be marked.

---

## 28. Menu Version Boundary

Every menu deployment must create version.

Menu version includes:

- version id
- source draft id
- tenant/store scope
- effective time
- category mapping
- price list
- fast track attributes
- cooking time defaults
- KDS routing
- option groups
- allergen tags
- i18n keys
- approval references
- audit references
- rollback reference

Menu version is source for projections.

Draft is not live version.

---

## 29. Rollback Boundary

Rollback must be available.

Rollback may be required for:

- wrong price
- wrong menu name
- wrong fast track enable
- KDS routing error
- allergen error
- POS mapping error
- customer display error
- deployment partial failure
- franchise template mistake
- seasonal menu end

Rollback must be audited.

Rollback must not erase the incorrect version history.

---

## 30. Menu Audit Boundary

Menu intake audit must capture:

- file upload
- AI parse start/end
- AI output
- confidence summary
- human edits
- validation errors
- approval
- deployment
- sync result
- rollback
- price changes
- fast track toggle changes
- cooking time changes
- allergen tag changes
- KDS station changes

Menu audit must be tenant/store scoped.

High-impact changes may require WORM reference.

---

## 31. Security Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `MENU_SOURCE_UPLOADED` | Menu source uploaded |
| `MENU_SOURCE_SCAN_BLOCKED` | Upload blocked by security scan |
| `MENU_AI_PARSE_STARTED` | AI parsing started |
| `MENU_AI_PARSE_COMPLETED` | AI parsing completed |
| `MENU_AI_LOW_CONFIDENCE` | Low confidence detected |
| `MENU_PRICE_UNCERTAIN` | Price uncertain |
| `MENU_DUPLICATE_CANDIDATE` | Duplicate candidate detected |
| `MENU_HUMAN_EDITED` | Human edit recorded |
| `MENU_VALIDATION_FAILED` | Validation failed |
| `MENU_APPROVED` | Menu approved |
| `MENU_DEPLOYMENT_STARTED` | Deployment started |
| `MENU_DEPLOYED_LIVE` | Menu deployed |
| `MENU_DEPLOYMENT_FAILED` | Deployment failed |
| `MENU_ROLLBACK_STARTED` | Rollback started |
| `MENU_ROLLED_BACK` | Rollback completed |
| `FASTTRACK_MENU_ENABLED` | Fast track enabled for menu |
| `FASTTRACK_MENU_DISABLED` | Fast track disabled for menu |
| `MENU_ALLERGEN_REVIEW_REQUIRED` | Allergen review required |

Events must route through `10610`.

---

## 32. Admin Security Boundary

Menu admin actions must obey:

- role gate
- tenant/store scope
- device/session binding
- reauthentication for high-impact deployment
- evidence/audit
- approval workflow
- safe file upload security
- no public file path exposure
- WORM audit for critical price/allergen/fast track changes if required

Menu management is not low-risk if it affects price, allergen, KDS, POS, or fast track.

---

## 33. AI Security Boundary

AI menu parsing must obey:

- source scope
- no cross-tenant training without approval
- raw image retention policy
- prompt injection resistance
- model/version traceability
- confidence output
- human review
- no automatic deployment
- no unapproved health/legal claim generation
- audit of AI output
- redaction if uploaded file includes private data

AI assists menu setup.

AI does not publish.

---

## 34. Customer Projection Boundary

Customer app must see only deployed menu version.

Customer must not see:

- draft menu
- AI candidate
- low-confidence text
- unapproved price
- internal category tag
- KDS routing
- admin notes
- source image
- parsing confidence
- hidden fast track logic

Customer sees approved menu, price, availability, description, allergen notice, and fast track availability if approved.

---

## 35. KDS Projection Boundary

KDS must receive:

- menu name
- station routing
- prep time
- priority eligibility
- option modifiers
- allergen/kitchen warnings if approved
- fast track marker
- packaging instruction if applicable
- version id

KDS must not receive AI confidence or admin draft details.

---

## 36. POS Mapping Boundary

POS mapping may require:

- menu id
- POS item code
- price
- tax class
- option mapping
- discount eligibility
- provider mapping
- settlement category
- refund/cancel rule
- menu version id

POS mapping must be validated before payment acceptance.

Wrong POS mapping can create financial reconciliation issues.

---

## 37. Inventory And Availability Boundary

Menu deployment may affect inventory.

Potential links:

- recipe version
- ingredient list
- stock deduction rule
- sold-out state
- allergen source
- supplier item
- waste class
- no-show waste cost
- fast track inventory eligibility

If inventory linkage is missing, deployment may be allowed only as menu display draft or manual stock mode depending policy.

---

## 38. i18n Boundary

Menu fields may require i18n.

i18n candidates:

- menu name
- description
- category
- allergen notice
- option names
- fast track availability message
- sold-out message
- validation errors
- customer warnings

Machine translation may draft.

Human review may be required for high-risk allergy, health, or legal claims.

---

## 39. Batch Review Boundary

Nightly batch should review:

- AI parsed menus not reviewed
- low-confidence fields still unresolved
- deployed menus missing KDS station
- deployed menus missing POS mapping
- fast track enabled menus with long prep times
- price changes
- allergen review gaps
- duplicate menu candidates
- deployment failures
- rollback events
- customer complaints linked to menu errors

Batch review prevents menu drift.

---

## 40. Relationship To Fast Track

This module is upstream of fast track.

Fast track depends on menu attributes:

- cooking time
- fast track enabled
- packaging suitability
- freshness window
- KDS station
- option complexity
- inventory reliability
- no-show waste risk

A menu without fast track attributes is not fast track-ready.

---

## 41. Relationship To Admin Console

This module extends the admin console.

Admin console must support:

- upload
- AI parse review
- split view correction
- validation
- approval
- deployment
- rollback
- audit
- fast track attribute editing
- KDS/POS/inventory mapping status

Menu setup is a core admin onboarding workflow.

---

## 42. Anti-Patterns

Avoid:

- AI menu parse deployed without human review
- customer seeing AI draft
- low-confidence price accepted automatically
- cooking time default treated as final truth
- fast track enabled automatically by AI
- menu source file exposed as public URL
- price change without audit
- allergen tag inferred by AI without review
- POS/KDS mapping skipped
- deployment partial failure hidden
- rollback overwriting version history
- hardcoded categories without governance
- menu text hardcoded without i18n path
- menu update bypassing tenant/store scope
- AI-generated health claim shown to customer without approval

These anti-patterns must be blocked in future runtime design.

---

## 43. Runtime Deferral

This document defines AI menu intake, interactive editor, validation, fast track attributes, and deployment boundaries only.

It does not authorize:

- file upload implementation
- OCR implementation
- multimodal AI parsing
- LLM classification
- interactive editor UI
- menu validation runtime
- menu deployment runtime
- WebSocket sync
- POS/KDS mapping runtime
- inventory integration
- i18n integration
- AI model integration
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 44. Validation Checklist

Validation must confirm:

1. Menu intake scope is defined.
2. Menu intake source types are defined.
3. Upload security boundary is defined.
4. AI parsing boundary is defined.
5. OCR/LLM confidence boundary is defined.
6. Structured menu draft boundary is defined.
7. Interactive editor boundary is defined.
8. Split view evidence boundary is defined.
9. Menu category classification boundary is defined.
10. Category governance boundary is defined.
11. Price parsing boundary is defined.
12. Menu description boundary is defined.
13. Allergen/dietary tag boundary is defined.
14. Cooking time recommendation boundary is defined.
15. Cooking time default matrix boundary is defined.
16. Fast track eligibility attribute boundary is defined.
17. Fast track suitability rule is defined.
18. KDS station routing boundary is defined.
19. Option/modifier boundary is defined.
20. Menu validation boundary is defined.
21. Validation error projection boundary is defined.
22. Approval boundary is defined.
23. Live deployment boundary is defined.
24. Deployment state skeleton is defined.
25. Instant sync boundary is defined.
26. Menu version boundary is defined.
27. Rollback boundary is defined.
28. Menu audit boundary is defined.
29. Security event catalog is defined.
30. Admin security boundary is defined.
31. AI security boundary is defined.
32. Customer projection boundary is defined.
33. KDS projection boundary is defined.
34. POS mapping boundary is defined.
35. Inventory/availability boundary is defined.
36. i18n boundary is defined.
37. Batch review boundary is defined.
38. Relationships to Fast Track and Admin Console are defined.
39. Anti-patterns are listed.
40. Coding remains unauthorized.
41. Runtime remains deferred.

---

## 45. Relationship To Previous Documents

This document supplements:

- `10702 Fast Track Admin Console Control Tower KDS Load Penalty Governance And Store Operations Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10690 Cross-Room Plumbing Closure Policy`
- `10700 Security And Trust Foundation Index`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`
- `10702 Fast Track Admin Console Control Tower KDS Load Penalty Governance And Store Operations Policy`

It prepares possible future documents:

- `10704 AI Menu Category Classification And Tagging Policy`
- `10705 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `10706 Menu Validation Deployment Rollback And Versioning Policy`
- `10707 Menu POS KDS Inventory Mapping Governance Policy`
- `10708 Menu AI Parsing Evidence Audit And Human Review SOP`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 46. Final Rule

AI menu intake exists to remove typing burden, not to remove human responsibility.

Menu images, PDFs, or text lists may be uploaded and parsed into structured drafts by AI.

AI may recommend category, price, description, cooking time, tags, KDS station, and fast track suitability.

Human review, validation, approval, versioning, audit, and rollback are mandatory before live deployment.

Customer app, KDS, POS, inventory, and fast track flows may consume only approved deployed menu versions.

AI draft is not menu truth.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.