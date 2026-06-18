# 010803_Policy_AI_Menu_Parsing_Correction_And_Owner_Review_Workflow

## 1. Purpose

This document defines the AI Menu Parsing, Correction, and Owner Review Workflow Policy for Catch Menu.

The previous document `10802 Menu Material Intake Photo PDF Text And POS Export Policy` defined how menu materials are collected, source-tracked, reviewed, and handed off for AI parsing and owner review.

This document focuses on the next step:

- AI extraction from menu materials
- draft menu structuring
- confidence and uncertainty handling
- human correction workflow
- owner confirmation
- HQ/franchise review where applicable
- risk candidate review handoff
- legal notice handoff
- audit and evidence preservation

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

AI parsing is a draft-generation step, not menu approval.

The correct rule is:

AI may read menu materials.  
AI may extract menu names, categories, prices, options, sets, and descriptions.  
AI may flag uncertainty.  
AI may suggest corrections.  
AI may propose legal notice candidates.  
AI may not finalize menus.  
AI may not approve prices.  
AI may not approve allergens.  
AI may not approve alcohol classification.  
AI may not approve market price.  
AI may not approve launch readiness.  
Owner review is mandatory.  

AI output must remain reviewable, explainable, reversible, and source-linked.

---

## 3. Scope

This policy applies to:

- AI OCR/text extraction
- menu name extraction
- category extraction
- price extraction
- option extraction
- add-on extraction
- set/combo/course extraction
- menu description extraction
- POS code matching suggestions
- delivery/dine-in price comparison
- duplicate detection
- unclear text detection
- alcohol candidate detection
- allergen candidate detection
- raw food candidate detection
- market price candidate detection
- health claim candidate detection
- owner correction workflow
- HQ review workflow
- legal notice handoff
- onboarding evidence
- audit events

This document defines workflow governance only.

---

## 4. AI Parsing Output Types

AI parsing may generate these draft outputs:

| Output Type | Meaning |
|---|---|
| `DRAFT_MENU_ITEM` | Candidate menu item |
| `DRAFT_CATEGORY` | Candidate category |
| `DRAFT_PRICE` | Candidate price |
| `DRAFT_OPTION_GROUP` | Candidate option group |
| `DRAFT_OPTION_VALUE` | Candidate option value |
| `DRAFT_ADD_ON` | Candidate add-on |
| `DRAFT_SET_COMBO` | Candidate set/combo |
| `DRAFT_COURSE` | Candidate course structure |
| `DRAFT_DESCRIPTION` | Candidate description |
| `DRAFT_TRANSLATION` | Candidate translation |
| `DRAFT_POS_MATCH` | Candidate POS item match |
| `DRAFT_KDS_ROUTE` | Candidate kitchen route |
| `DRAFT_RISK_FLAG` | Candidate legal/food/alcohol risk |
| `DRAFT_REVIEW_QUESTION` | Question requiring human answer |

Draft output is not approved data.

---

## 5. Parsing Job Header

Every AI parsing job should include:

| Field | Required | Meaning |
|---|---:|---|
| `parse_job_id` | yes | Parsing job identity |
| `tenant_id` | yes | Tenant scope |
| `store_id` | conditional | Store scope |
| `onboarding_case_id` | yes | Onboarding workflow |
| `material_ids` | yes | Source materials parsed |
| `parse_scope` | yes | Menu, price, option, risk, POS match |
| `requested_by_actor_type` | yes | Sales, owner, HQ, system |
| `requested_by_actor_id` | conditional | Actor ID |
| `requested_at` | yes | Request time |
| `ai_model_ref` | conditional | AI model/version reference |
| `prompt_profile_ref` | conditional | Prompt/profile reference |
| `parse_language_hint` | optional | Language hint |
| `store_category_hint` | optional | Store category |
| `confidence_policy` | yes | Confidence threshold policy |
| `review_required` | yes | Always true for structured menu |
| `audit_ref` | yes | Audit correlation |

Parsing job must be traceable to source material.

---

## 6. Draft Item Fields

Each draft menu item should include:

| Field | Meaning |
|---|---|
| `draft_item_id` | Draft item identity |
| `source_material_id` | Source material |
| `source_location_ref` | Page/image region/row if available |
| `raw_text` | Extracted raw text |
| `normalized_name` | Proposed item name |
| `category_candidate` | Proposed category |
| `description_candidate` | Proposed description |
| `price_candidate` | Proposed price |
| `currency_candidate` | Currency |
| `tax_inclusion_candidate` | Tax included/unknown |
| `option_candidates` | Option candidates |
| `set_combo_candidate` | Set/combo relation |
| `risk_flags` | Alcohol/allergen/raw/market/etc. |
| `confidence_score` | AI confidence |
| `uncertainty_reasons` | Why uncertain |
| `review_state` | Draft/review/confirmed/rejected |
| `audit_ref` | Audit reference |

Draft item must retain source location when possible.

---

## 7. Confidence Bands

Recommended confidence bands:

| Band | Score Range | Meaning |
|---|---:|---|
| `HIGH_CONFIDENCE` | 0.90–1.00 | Likely correct, still needs review |
| `MEDIUM_CONFIDENCE` | 0.70–0.89 | Review required |
| `LOW_CONFIDENCE` | 0.40–0.69 | Human correction required |
| `VERY_LOW_CONFIDENCE` | 0.00–0.39 | Likely unreliable |
| `CONFLICT_CONFIDENCE` | any | Conflicting sources exist |
| `RISK_CONFIDENCE` | any | Risk candidate requires domain review |

High confidence does not equal approval.

---

## 8. Uncertainty Reason Codes

Recommended uncertainty reason codes:

| Code | Meaning |
|---|---|
| `TEXT_BLURRY` | Source text blurry |
| `TEXT_CROPPED` | Text cropped |
| `PRICE_UNREADABLE` | Price unclear |
| `CATEGORY_AMBIGUOUS` | Category unclear |
| `OPTION_AMBIGUOUS` | Option relation unclear |
| `SET_COMPONENT_UNCLEAR` | Set components unclear |
| `DUPLICATE_ITEM_CANDIDATE` | Duplicate possible |
| `MULTIPLE_PRICE_CANDIDATE` | Multiple prices |
| `CHANNEL_PRICE_CONFLICT` | Dine-in/delivery/POS price conflict |
| `POS_MATCH_CONFLICT` | POS item mismatch |
| `ALCOHOL_CANDIDATE_UNCERTAIN` | Alcohol candidate uncertain |
| `ALLERGEN_CANDIDATE_UNCERTAIN` | Allergen candidate uncertain |
| `RAW_FOOD_CANDIDATE_UNCERTAIN` | Raw food candidate uncertain |
| `MARKET_PRICE_CANDIDATE_UNCERTAIN` | Market price uncertain |
| `TRANSLATION_UNCERTAIN` | Translation uncertain |

Uncertainty must be surfaced to reviewer.

---

## 9. AI Correction Workflow

Correction workflow:

1. AI produces draft extraction.
2. Draft is grouped by source material.
3. Confidence and uncertainty are displayed.
4. Owner or authorized reviewer reviews each item.
5. Reviewer confirms, edits, rejects, or asks for re-upload.
6. Conflicts are resolved by human decision.
7. Risk candidates are sent to domain review.
8. Confirmed items move to structured menu draft.
9. Structured menu draft remains launch-blocked until readiness gates pass.
10. Audit records all changes.

Correction is human review, not AI self-repair.

---

## 10. Owner Review Actions

Owner may perform:

| Action | Meaning |
|---|---|
| `CONFIRM_ITEM` | Confirm item name/price/category |
| `EDIT_ITEM` | Edit extracted data |
| `REJECT_ITEM` | Reject false extraction |
| `MERGE_ITEMS` | Merge duplicates |
| `SPLIT_ITEM` | Split incorrectly merged item |
| `CONFIRM_PRICE` | Confirm price |
| `EDIT_PRICE` | Correct price |
| `MARK_MARKET_PRICE` | Mark as market price |
| `CONFIRM_OPTION` | Confirm option group/value |
| `EDIT_OPTION` | Correct option |
| `CONFIRM_SET_COMPONENT` | Confirm set/combo component |
| `FLAG_RISK_REVIEW` | Request risk review |
| `REQUEST_REUPLOAD` | Request better source |
| `ADD_MISSING_ITEM` | Add item not extracted |

Owner action must be authenticated and audited.

---

## 11. Owner Review Restrictions

Owner may not directly approve:

- privacy legal wording
- alcohol legal compliance
- allergen truth without domain basis
- refund/no-show penalty legal validity
- platform mandatory notices
- HQ locked brand policy
- payment provider behavior
- POS/KDS integration behavior
- evidence retention policy
- customer launch readiness by menu review alone

Owner review confirms store menu facts.

It does not approve all compliance gates.

---

## 12. Sales Review Boundary

Sales may assist by:

- organizing draft menu items
- requesting re-upload
- asking owner questions
- helping identify missing fields
- preparing owner review session
- explaining system fields
- marking owner response received
- escalating unclear risk

Sales may not:

- confirm menu prices without owner
- approve alcohol classification
- approve allergen facts
- approve legal notice requirements
- approve refund/no-show policy
- approve POS/payment behavior
- override owner review
- mark launch-ready

Sales support is coordination, not authority.

---

## 13. HQ Review Boundary

HQ review may be required when:

- franchise master menu applies
- store price deviates from brand rule
- item name deviates from brand rule
- menu category deviates from brand taxonomy
- alcohol policy is brand-controlled
- coupon/event is brand-controlled
- allergen/origin master is HQ-controlled
- legal notice template is HQ-controlled
- store override is requested

HQ review is tenant/franchise-scoped.

---

## 14. Legal And Domain Review Handoff

AI/owner review must hand off for specialized review when:

| Risk | Review Required |
|---|---|
| Alcohol candidate | Alcohol/legal/HQ review |
| Allergen candidate | Food safety/QC review |
| Raw food candidate | Food safety/legal review |
| Health claim | Legal/marketing review |
| Market price | Owner/payment/customer notice review |
| Refund restriction | Legal/payment/KDS review |
| No-show penalty | Legal/operations review |
| Coupon/event | Marketing/legal/finance review |
| Review/photo upload | Legal/content review |
| Delivery/pickup freshness | Operations/legal review |

Risk candidate cannot be silently treated as safe.

---

## 15. Conflict Resolution Workflow

When sources conflict:

1. Identify conflicting sources.
2. Show conflicting values.
3. Assign conflict type.
4. Require owner or HQ decision.
5. Record decision reason.
6. Preserve all source materials.
7. Update structured draft.
8. Create risk review if conflict affects legal/payment/alcohol/price.
9. Audit the resolution.

Conflict examples:

| Conflict | Required Reviewer |
|---|---|
| Photo price vs POS price | Owner/POS admin |
| HQ menu vs store menu | HQ/store owner |
| Delivery price vs dine-in price | Owner |
| Alcohol flag conflict | Owner + legal/HQ |
| Allergen source conflict | Owner + food safety |
| Option price conflict | Owner |
| Set component conflict | Owner/HQ |
| Market price ambiguity | Owner |

AI must not resolve conflicts silently.

---

## 16. Structured Menu Draft Promotion

Draft extraction may be promoted to structured menu draft only when:

- source material exists
- draft item is reviewed
- owner confirms or edits
- price is confirmed or marked market price
- category is confirmed or pending taxonomy review
- options are confirmed or marked incomplete
- set/combo/course components are reviewed
- risk candidates are flagged
- unresolved conflicts are recorded
- audit trail exists

Structured menu draft is not customer-active menu.

---

## 17. Re-Upload Workflow

Re-upload is required when:

- image is blurry
- price unreadable
- item names unclear
- menu section cropped
- PDF unreadable
- spreadsheet corrupted
- POS export incomplete
- source is outdated
- alcohol page missing
- option list missing
- HQ template missing
- owner says source is wrong

Re-upload request must state reason and target material.

---

## 18. Correction History

Correction history must preserve:

- original AI draft
- edited value
- editor actor
- edit timestamp
- edit reason
- source material reference
- previous value
- new value
- conflict reference if applicable
- risk review reference if applicable
- audit reference

Corrections must not overwrite draft history without trace.

---

## 19. Review Question Queue

AI may generate review questions such as:

- Is this price dine-in or delivery?
- Is this drink alcoholic?
- Does this set include alcohol?
- Is this sauce optional or default?
- Is this price for small or large size?
- Is this item seasonal?
- Is this menu still available?
- Is this market price?
- Does this item contain shrimp, egg, milk, peanut, or wheat?
- Should this category be shown to customers?
- Does this item route to kitchen or bar?
- Is cancellation restricted after order acceptance?

Questions should be answerable and source-linked.

---

## 20. Owner Confirmation Packet

Owner confirmation packet should include:

| Section | Meaning |
|---|---|
| Confirmed menu items | Items confirmed |
| Edited items | Owner corrections |
| Rejected items | False extraction |
| Missing items added | Owner-added |
| Price confirmations | Prices confirmed |
| Market price items | Marked market price |
| Alcohol candidates | Confirmed or review-pending |
| Allergen candidates | Confirmed or review-pending |
| Raw food candidates | Confirmed or review-pending |
| Options/sets | Confirmed or review-pending |
| Conflicts resolved | Decisions |
| Remaining warnings | Non-blocking issues |
| Blocking gaps | Must resolve |
| Owner signature/ack | Authentication evidence |
| Audit reference | Audit |

Owner confirmation packet becomes onboarding evidence.

---

## 21. AI Parse Evaluation Metrics

Future runtime may track:

- extraction accuracy
- owner edit rate
- price correction rate
- category correction rate
- option correction rate
- alcohol candidate precision
- allergen candidate recall
- market price detection accuracy
- low-quality image rate
- re-upload rate
- conflict rate
- owner review completion time
- HQ escalation rate
- legal risk handoff rate

Metrics are for improvement, not automatic approval.

---

## 22. Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `MENU_AI_PARSE_JOB_CREATED` | Parse job created |
| `MENU_AI_PARSE_COMPLETED` | Parse completed |
| `MENU_AI_DRAFT_ITEM_CREATED` | Draft item created |
| `MENU_AI_CONFIDENCE_ASSIGNED` | Confidence assigned |
| `MENU_AI_UNCERTAINTY_FLAGGED` | Uncertainty flagged |
| `MENU_OWNER_REVIEW_STARTED` | Owner review started |
| `MENU_OWNER_ITEM_CONFIRMED` | Item confirmed |
| `MENU_OWNER_ITEM_EDITED` | Item edited |
| `MENU_OWNER_ITEM_REJECTED` | Item rejected |
| `MENU_OWNER_PRICE_CONFIRMED` | Price confirmed |
| `MENU_OWNER_OPTION_CONFIRMED` | Option confirmed |
| `MENU_CONFLICT_DETECTED` | Conflict detected |
| `MENU_CONFLICT_RESOLVED` | Conflict resolved |
| `MENU_RISK_REVIEW_HANDOFF_CREATED` | Risk review handoff created |
| `MENU_REUPLOAD_REQUESTED` | Re-upload requested |
| `MENU_STRUCTURED_DRAFT_PROMOTED` | Promoted to structured draft |
| `MENU_OWNER_CONFIRMATION_PACKET_CREATED` | Confirmation packet created |

Events must route through `10610` if implemented later.

---

## 23. Security Boundary

AI menu parsing and correction security rules:

- tenant/store scope mandatory
- AI parsing output must not leak across tenants
- source materials must remain access-controlled
- owner review must be authenticated
- sales cannot impersonate owner confirmation
- HQ review must be tenant/franchise-scoped
- risk flags must not be hidden
- correction history must be immutable/auditable
- AI prompts and outputs may contain business-sensitive data
- POS codes and prices are operationally sensitive
- personal data in images must be minimized
- rejected outputs must remain auditable if retained

AI parsing is part of SaaS control-plane security.

---

## 24. Anti-Patterns

Avoid:

- treating AI parsed menu as final
- auto-activating menu from OCR
- hiding low-confidence items
- hiding AI uncertainty
- silently resolving source conflicts
- letting sales approve owner corrections
- letting AI approve alcohol items
- letting AI approve allergen facts
- treating POS match as final without review
- overwriting original AI draft without history
- deleting source material after correction
- launching menu with unresolved blocking gaps
- using owner confirmation to bypass legal/HQ review
- training staff on unconfirmed draft menu
- ignoring set/combo hidden components

These anti-patterns must remain prohibited.

---

## 25. Runtime Deferral

This document defines AI menu parsing, correction, and owner review workflow governance only.

It does not authorize:

- OCR implementation
- AI parsing implementation
- owner review UI
- correction editor implementation
- structured menu database implementation
- POS matching implementation
- risk detection runtime
- HQ review runtime
- legal review runtime
- audit runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 26. Validation Checklist

Validation must confirm:

1. AI parsing output types are defined.
2. Parsing job header is defined.
3. Draft item fields are defined.
4. Confidence bands are defined.
5. Uncertainty reason codes are defined.
6. AI correction workflow is defined.
7. Owner review actions are defined.
8. Owner review restrictions are defined.
9. Sales review boundary is defined.
10. HQ review boundary is defined.
11. Legal/domain review handoff is defined.
12. Conflict resolution workflow is defined.
13. Structured menu draft promotion is defined.
14. Re-upload workflow is defined.
15. Correction history is defined.
16. Review question queue is defined.
17. Owner confirmation packet is defined.
18. AI parse evaluation metrics are defined.
19. Audit events are defined.
20. Security boundary is defined.
21. Anti-patterns are listed.
22. Coding remains unauthorized.
23. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document follows:

- `10800 Store Onboarding And Sales Setup Axis Index`
- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`

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
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`

It prepares:

- `10804 Menu Category Option Set Combo Course Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`
- `10806 Store Service Mode Selection And Feature Readiness Policy`
- `10807 POS Payment KDS Integration Readiness Intake Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 28. Final Rule

Catch Menu AI menu parsing must remain a draft-generation and review-assistance workflow.

AI may extract, structure, suggest, flag, and ask questions.

AI cannot finalize menu data, approve prices, approve alcohol classification, approve allergen facts, resolve conflicts silently, approve legal notices, or approve launch readiness.

Owner/HQ/legal/domain review must remain separate, authenticated, and auditable.

Structured menu drafts may only progress after source-linked human correction and confirmation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.