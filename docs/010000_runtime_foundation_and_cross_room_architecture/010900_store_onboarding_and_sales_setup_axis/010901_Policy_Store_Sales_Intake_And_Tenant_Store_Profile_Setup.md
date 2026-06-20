# 010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md

## Purpose

This document defines the Store Sales Intake and Tenant Store Profile Setup Policy for Catch Menu.

The previous document `10800 Store Onboarding And Sales Setup Axis Index` opened the Store Onboarding and Sales Setup Axis and defined the SaaS onboarding control-plane pipeline.

This document focuses on the first operational step:

- sales lead intake
- tenant/store draft creation
- store identity capture
- owner/admin contact capture
- franchise/HQ relationship capture
- service-mode pre-selection
- store operational profile
- business registration intake
- onboarding ownership
- scope separation between sales, owner, HQ, legal, support, and platform admin

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Store sales intake is not just CRM data.

The correct rule is:

Sales intake creates the first SaaS control-plane record.  
Sales intake must be tenant-scoped from the beginning.  
A store profile draft is not an active store.  
A sales lead is not an onboarded tenant.  
A tenant draft is not legally ready.  
A store draft is not customer-facing.  
Sales may collect and prepare information.  
Sales may not approve legal readiness, payment readiness, alcohol readiness, launch readiness, or production activation.  

Store profile setup is the root of onboarding authority.

---

## 3. Scope

This policy applies to:

- inbound store lead
- outbound sales lead
- franchise/HQ-provided store list
- single-store SaaS prospect
- trial store
- pilot store
- future franchise store
- store profile draft
- tenant draft
- owner/admin account intake
- business registration information
- store contact information
- location/address information
- operating hours
- service mode preference
- POS/payment/KDS provider info
- alcohol/pickup/delivery/reservation flags
- language/customer profile intake
- onboarding assignment
- launch target tracking

This document defines intake governance only.

---

## 4. Intake Object Hierarchy

Sales intake should separate these objects:

| Object | Meaning |
|---|---|
| `sales_lead` | Potential store/customer before tenant creation |
| `tenant_candidate` | Potential SaaS customer entity |
| `tenant` | Approved SaaS customer container |
| `brand_candidate` | Franchise/brand candidate if applicable |
| `store_candidate` | Store not yet approved |
| `store_profile_draft` | Store profile under onboarding |
| `owner_contact` | Owner/admin contact candidate |
| `hq_contact` | Franchise/HQ contact candidate |
| `onboarding_case` | Controlled onboarding workflow |
| `activation_candidate` | Future runtime launch candidate |

These objects must not be collapsed into one uncontrolled record.

---

## 5. Sales Lead Intake Fields

Recommended sales lead fields:

| Field | Required | Meaning |
|---|---:|---|
| `lead_id` | yes | Sales lead identity |
| `lead_source` | yes | Inbound, outbound, referral, HQ, event |
| `lead_status` | yes | Current lead state |
| `business_name` | conditional | Store or company name |
| `contact_name` | conditional | Main contact |
| `contact_phone` | conditional | Phone |
| `contact_email` | optional | Email |
| `store_address_text` | optional | Address candidate |
| `store_category` | optional | Restaurant/cafe/pub/etc. |
| `franchise_flag` | optional | Franchise candidate |
| `target_open_date` | optional | Launch target |
| `sales_owner_id` | yes | Sales responsible actor |
| `created_at` | yes | Created time |
| `audit_ref` | yes | Audit reference |

Lead data is pre-onboarding and must not be treated as verified store data.

---

## 6. Tenant Candidate Fields

Tenant candidate fields:

| Field | Required | Meaning |
|---|---:|---|
| `tenant_candidate_id` | yes | Tenant candidate identity |
| `tenant_name` | yes | Candidate tenant name |
| `tenant_type` | yes | Single store, franchise, pilot, partner |
| `legal_entity_name` | conditional | Legal entity candidate |
| `business_registration_no` | conditional | Business registration number |
| `representative_name` | conditional | Representative name |
| `hq_relationship_flag` | optional | HQ/franchise relation |
| `billing_contact` | optional | Billing contact |
| `contract_status` | optional | Contract intake state |
| `data_region` | conditional | Data/storage region if needed |
| `created_from_lead_id` | yes | Source lead |
| `review_state` | yes | Draft/review/approved/rejected |
| `audit_ref` | yes | Audit reference |

Tenant candidate approval is not launch approval.

---

## 7. Store Profile Draft Fields

Store profile draft fields:

| Field | Required | Meaning |
|---|---:|---|
| `store_profile_draft_id` | yes | Draft identity |
| `tenant_candidate_id` | yes | Tenant scope candidate |
| `store_name` | yes | Store display name |
| `store_legal_name` | conditional | Legal name if different |
| `store_address` | yes | Address |
| `store_phone` | yes | Customer-facing phone |
| `owner_contact_id` | yes | Owner/admin candidate |
| `store_category` | yes | Food category |
| `business_hours` | yes | Operating hours |
| `break_time` | conditional | Break time |
| `last_order_time` | conditional | Last order |
| `table_count` | conditional | Table count |
| `service_modes` | yes | Intended service modes |
| `pos_provider` | optional | POS provider |
| `payment_provider` | optional | Payment provider |
| `kds_flag` | optional | KDS use |
| `alcohol_flag` | yes | Alcohol sale candidate |
| `pickup_flag` | yes | Pickup candidate |
| `delivery_flag` | yes | Delivery candidate |
| `reservation_flag` | yes | Reservation candidate |
| `waiting_flag` | yes | Waiting candidate |
| `membership_flag` | optional | Membership candidate |
| `coupon_event_flag` | optional | Coupon/event candidate |
| `review_feature_flag` | optional | Review feature candidate |
| `customer_languages` | optional | Target languages |
| `support_route_state` | conditional | Support route readiness |
| `profile_review_state` | yes | Draft/review/confirmed |
| `audit_ref` | yes | Audit reference |

Store profile draft must be versioned or review-tracked.

---

## 8. Store Profile State Registry

Recommended states:

| State | Meaning |
|---|---|
| `DRAFT_CREATED` | Draft exists |
| `SALES_INPUT_IN_PROGRESS` | Sales entering data |
| `OWNER_INPUT_REQUIRED` | Owner must provide data |
| `OWNER_REVIEW_REQUIRED` | Owner must review |
| `ADDRESS_REVIEW_REQUIRED` | Address incomplete |
| `BUSINESS_INFO_REVIEW_REQUIRED` | Business info incomplete |
| `SERVICE_MODE_REVIEW_REQUIRED` | Service mode incomplete |
| `PAYMENT_INFO_REVIEW_REQUIRED` | Payment info incomplete |
| `POS_INFO_REVIEW_REQUIRED` | POS info incomplete |
| `LEGAL_FLAG_REVIEW_REQUIRED` | Alcohol/privacy/refund flags require review |
| `PROFILE_READY_FOR_OWNER_CONFIRMATION` | Ready for owner confirmation |
| `OWNER_CONFIRMED` | Owner confirmed |
| `HQ_REVIEW_REQUIRED` | HQ review needed |
| `PROFILE_APPROVED_FOR_ONBOARDING` | Profile ready for next onboarding step |
| `PROFILE_BLOCKED` | Cannot proceed |
| `PROFILE_REJECTED` | Rejected |
| `PROFILE_SUPERSEDED` | Replaced by newer draft |

Profile approved for onboarding is not launch approval.

---

## 9. Owner And Admin Contact Intake

Owner/admin contact intake should capture:

| Field | Required | Meaning |
|---|---:|---|
| `contact_id` | yes | Contact identity |
| `contact_role` | yes | Owner, manager, HQ, accountant |
| `name` | yes | Contact name |
| `phone` | yes | Phone |
| `email` | optional | Email |
| `identity_verified_flag` | conditional | Verification state |
| `authority_claim` | conditional | Claimed authority |
| `authority_verified_state` | yes | Draft, verified, rejected |
| `preferred_contact_channel` | optional | Phone, email, Kakao, app |
| `language_preference` | optional | Language |
| `consent_to_contact` | conditional | Contact consent if required |
| `audit_ref` | yes | Audit reference |

Owner contact must not automatically become authenticated admin.

---

## 10. Franchise And HQ Relationship Intake

Franchise/HQ intake should capture:

| Field | Required | Meaning |
|---|---:|---|
| `franchise_flag` | yes | Franchise candidate |
| `hq_tenant_candidate_id` | conditional | HQ candidate |
| `brand_name` | conditional | Brand |
| `store_operator_type` | conditional | Direct, franchisee, agency |
| `hq_contact_id` | conditional | HQ contact |
| `store_owner_contact_id` | conditional | Store owner |
| `brand_policy_applicability` | conditional | HQ policy applies |
| `hq_approval_required` | conditional | HQ review required |
| `store_override_allowed` | conditional | Whether store can override |
| `contract_relationship_state` | conditional | Draft/verified |
| `audit_ref` | yes | Audit reference |

Franchise scope must be explicit before HQ locks or brand templates apply.

---

## 11. Business Registration Intake

Business registration intake should capture:

- business registration number
- legal entity name
- representative name
- business address
- business category
- tax invoice email if applicable
- settlement/billing owner
- contract signer
- document upload reference if needed
- verification state
- review actor
- audit reference

Business registration data is sensitive and must be access-controlled.

---

## 12. Store Operating Profile Intake

Operating profile should capture:

| Area | Examples |
|---|---|
| Business hours | Open/close by day |
| Break time | Midday break |
| Last order | Dine-in, pickup, delivery |
| Holiday schedule | Regular closures |
| Table count | Total tables |
| Seat count | Optional |
| Kitchen capacity | Optional |
| Peak hours | Optional |
| Staff count | Optional |
| Prep time baseline | Optional |
| Pickup hold time | Required if pickup |
| Waiting grace time | Required if waiting |
| Reservation grace time | Required if reservation |
| Delivery radius | Optional |
| Alcohol service hours | Required if alcohol |

Operating profile feeds service readiness.

---

## 13. Service Mode Pre-Selection

Service mode pre-selection should identify intended services.

Candidate service modes:

| Service Mode | Intake Question |
|---|---|
| Table order | Will customers order at table? |
| QR menu only | Menu view without order? |
| Mini kiosk | Will device act as simple kiosk? |
| Full kiosk | Will payment/kiosk CMS be used? |
| Pickup | Will pickup orders be accepted? |
| Delivery | Will delivery be connected? |
| Waiting | Will waiting/queue be used? |
| Reservation | Will reservations be used? |
| Deposit | Will deposits be charged? |
| Prepaid order | Will customer pay before order acceptance? |
| Postpaid order | Will customer pay after dining? |
| Split payment | Will split payment be supported? |
| Membership | Will customer account/points be used? |
| Coupon/event | Will promotions be used? |
| Review | Will review/photo upload be used? |
| Alcohol | Will alcohol be sold? |

Each selected mode creates later readiness requirements.

---

## 14. POS Payment KDS Provider Intake

Provider intake should capture:

| Provider Area | Examples |
|---|---|
| POS provider | OKPOS, POSBANK, FoodTech, custom |
| POS integration mode | API, agent, manual, none |
| Payment provider | PG/VAN/provider |
| Payment mode | Prepaid, postpaid, deposit, split |
| KDS system | Existing, new, manual kitchen note |
| Printer | Kitchen printer, receipt printer |
| Network | Store LAN, Wi-Fi, LTE fallback |
| Device OS | Android, Windows, web |
| Agent need | Local agent required or not |
| Existing table order | Current provider |
| Integration risk | Unknown, manual, API candidate |

Provider intake is not integration approval.

---

## 15. Alcohol And Regulated Feature Intake

Alcohol/regulatory intake should capture:

- alcohol sale candidate
- alcohol menu availability
- dine-in alcohol only
- pickup alcohol candidate
- delivery alcohol candidate
- corkage candidate
- adult-only seating area if any
- staff ID check capability
- staff training need
- alcohol service hours
- local policy/legal review required
- owner confirmation required
- HQ/legal approval required

If alcohol is uncertain, mark as review required and fail closed.

---

## 16. Customer Language Intake

Customer language intake should capture:

| Field | Meaning |
|---|---|
| `default_locale` | Store default language |
| `customer_target_locales` | Expected customer languages |
| `menu_translation_needed` | Menu translation required |
| `legal_translation_needed` | Notice translation required |
| `staff_language_support` | Staff language capability |
| `foreign_customer_ratio_estimate` | Optional planning |
| `fallback_locale` | Fallback |
| `korean_controlling_text_flag` | If applicable |
| `translation_review_required` | Review state |

Language intake is part of legal and operational readiness.

---

## 17. Support Route Intake

Support route intake should capture:

- store support contact
- owner escalation contact
- HQ escalation contact if franchise
- platform support route
- refund dispute owner
- payment error owner
- privacy inquiry owner
- alcohol dispute owner
- allergy/food safety owner
- device incident owner
- emergency contact
- operating support hours
- customer-facing support text

Support route must exist before high-risk customer launch.

---

## 18. Data Classification

Sales intake data classification:

| Data | Classification |
|---|---|
| Store name/address | Business profile |
| Owner phone/email | Personal/business contact |
| Business registration number | Sensitive business/legal |
| POS provider info | Operational sensitive |
| Payment provider info | Financial operational |
| Menu materials | Business content |
| Alcohol flag | Regulated feature |
| Language needs | Operational |
| Support contact | Business/contact |
| Contract status | Confidential |
| Onboarding notes | Internal operational |

Access must be role-scoped.

---

## 19. Sales To Onboarding Handoff

Sales handoff occurs when:

1. Lead is qualified.
2. Tenant candidate is created.
3. Store profile draft exists.
4. Owner/admin contact is captured.
5. Service modes are pre-selected.
6. Menu material request is sent.
7. POS/payment/KDS provider info is captured if available.
8. Legal flags are marked.
9. Support route candidate is identified.
10. Onboarding case is created.

Handoff must create audit event.

---

## 20. Blocking Conditions

Sales intake cannot proceed to onboarding if:

- no tenant/store scope exists
- no responsible owner/admin contact exists
- store identity is unknown
- business category is unclear
- service modes are entirely unknown
- alcohol is enabled but unconfirmed
- payment mode is prepaid but provider unknown
- franchise/HQ relationship is claimed but not scoped
- business registration data is required but missing
- support contact is missing for high-risk flows
- sales rep attempts to approve restricted legal settings

Blocking must be visible.

---

## 21. Warning Conditions

Warnings may include:

- menu material not yet uploaded
- POS provider unknown for manual-only early review
- low-risk optional service modes undecided
- customer language estimate missing
- parking/pet policy undecided
- table count approximate
- opening target date tentative
- coupon/event plan undecided
- review feature undecided

Warnings do not equal readiness.

---

## 22. Sales Intake Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `SALES_LEAD_CREATED` | Lead created |
| `SALES_LEAD_UPDATED` | Lead updated |
| `TENANT_CANDIDATE_CREATED` | Tenant candidate created |
| `STORE_PROFILE_DRAFT_CREATED` | Store draft created |
| `OWNER_CONTACT_CAPTURED` | Owner contact captured |
| `HQ_CONTACT_CAPTURED` | HQ contact captured |
| `BUSINESS_INFO_CAPTURED` | Business info captured |
| `SERVICE_MODE_PRESELECTED` | Service mode selected |
| `POS_PROVIDER_INFO_CAPTURED` | POS info captured |
| `PAYMENT_PROVIDER_INFO_CAPTURED` | Payment info captured |
| `ALCOHOL_FLAG_CAPTURED` | Alcohol flag captured |
| `LANGUAGE_NEED_CAPTURED` | Language need captured |
| `SUPPORT_ROUTE_CANDIDATE_CAPTURED` | Support candidate captured |
| `SALES_HANDOFF_TO_ONBOARDING_CREATED` | Handoff created |
| `SALES_INTAKE_BLOCKED` | Intake blocked |
| `SALES_INTAKE_WARNING_RECORDED` | Warning recorded |

Events must route through `10610` if implemented later.

---

## 23. Sales Rep AI Assistant Boundary

AI may help sales by:

- summarizing lead notes
- extracting store name/address from uploaded material
- identifying missing intake fields
- suggesting service mode questions
- detecting alcohol mention in menu materials
- detecting POS provider mention
- detecting language needs
- drafting owner follow-up messages
- creating onboarding handoff summary
- flagging likely legal notice requirements

AI must not:

- verify owner authority
- approve business registration
- approve alcohol status
- approve payment readiness
- approve franchise scope
- mark profile as owner-confirmed
- mark store as launch-ready
- suppress missing critical fields
- fabricate data from ambiguous material

AI assists intake only.

---

## 24. Security Boundary

Sales intake security rules:

- sales access is limited to assigned leads and authorized scopes
- tenant/store candidate data must be scoped
- business registration data must be protected
- owner contact data must be protected
- POS/payment provider data must be protected
- uploaded menu materials must be access-controlled
- franchise/HQ relationship data must not leak
- AI summaries must not expose other tenants
- sales notes must not override controlled fields
- audit required for handoff and state changes
- deletion must respect retention and audit policy

Sales intake is not casual spreadsheet data.

---

## 25. Anti-Patterns

Avoid:

- creating store without tenant scope
- treating lead as active tenant
- treating tenant candidate as active tenant
- treating store profile draft as launch-ready
- letting sales approve legal notice setup
- letting sales approve alcohol readiness
- letting sales approve payment readiness
- letting sales approve owner confirmation
- storing business registration in free-text notes only
- mixing franchise HQ and store owner authority
- hiding unknown service modes
- marking unclear alcohol state as disabled without review
- importing POS/payment assumptions without verification
- allowing AI to fabricate missing store data
- cross-tenant sales data exposure

These anti-patterns must remain prohibited.

---

## 26. Runtime Deferral

This document defines sales intake and tenant/store profile setup governance only.

It does not authorize:

- sales CRM implementation
- tenant table implementation
- store profile table implementation
- onboarding case implementation
- contact verification implementation
- file upload implementation
- AI intake runtime
- POS/payment provider integration
- admin UI
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 27. Validation Checklist

Validation must confirm:

1. Intake object hierarchy is defined.
2. Sales lead intake fields are defined.
3. Tenant candidate fields are defined.
4. Store profile draft fields are defined.
5. Store profile state registry is defined.
6. Owner/admin contact intake is defined.
7. Franchise/HQ relationship intake is defined.
8. Business registration intake is defined.
9. Store operating profile intake is defined.
10. Service mode pre-selection is defined.
11. POS/payment/KDS provider intake is defined.
12. Alcohol and regulated feature intake is defined.
13. Customer language intake is defined.
14. Support route intake is defined.
15. Data classification is defined.
16. Sales-to-onboarding handoff is defined.
17. Blocking conditions are defined.
18. Warning conditions are defined.
19. Sales intake audit events are defined.
20. Sales rep AI assistant boundary is defined.
21. Security boundary is defined.
22. Anti-patterns are listed.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 28. Relationship To Previous Documents

This document follows:

- `10800 Store Onboarding And Sales Setup Axis Index`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10736 Legal Notice Implementation Authorization Draft Policy`
- `10800 Store Onboarding And Sales Setup Axis Index`

It prepares:

- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 29. Final Rule

Catch Menu sales intake must create a controlled, scoped, auditable onboarding foundation.

A sales lead is not a tenant.

A tenant candidate is not an active tenant.

A store profile draft is not a launched store.

Sales may collect, prepare, and coordinate onboarding information.

Sales may not approve legal readiness, alcohol readiness, payment readiness, owner confirmation, franchise scope, or customer launch.

AI may assist intake but cannot verify authority, fabricate missing data, or approve readiness.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
