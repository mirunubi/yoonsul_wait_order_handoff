# 004511_Policy_CI_DI_Identity_Linkage_Data_Protection_And_Leakage_Response

## 1. Purpose

This document defines the protection, access, masking, storage, logging, audit, and leakage response policy for CI, DI, and identity linkage data in the Yoonsul Wait/Order Handoff project.

CI, DI, phone number, membership identity, waiting session, order session, payment reference, and customer account linkage are not ordinary operational fields.

They can connect a customer across services, stores, orders, payments, visits, and recovery cases.

Therefore, identity linkage data must be treated as sensitive security and privacy data.

---

## 2. Scope

This policy applies to:

- CI
- DI
- phone number
- email address
- customer account id
- membership id
- waiting session id
- order session id
- table session id
- payment reference
- refund reference
- customer recovery case id
- customer support case id
- coupon or wallet identity
- loyalty identity
- device identity where linked to customer
- cross-service identity mapping
- tenant-specific customer identity mapping
- store-specific visit history linkage

This document does not define the final CI/DI provider integration.

It defines the mandatory protection rules that later identity, membership, waiting, order, payment, CRM, support, and audit documents must follow.

---

## 3. Core Principle

Identity linkage data must be minimized, separated, masked, and audited.

The project must follow this rule:

> A customer identity value may be used to verify continuity, but it must not be casually exposed as operational content.

Identity linkage must support service continuity.

It must not become unnecessary staff visibility, log content, screenshot content, or cross-tenant leakage.

---

## 4. Identity Linkage Data Classification

### 4.1 Critical Identity Linkage Data

Critical identity linkage data includes:

- CI
- DI
- payment identity reference
- verified identity provider reference
- legal identity verification reference
- unmasked customer phone number where linked to CI/DI
- cross-service account linkage key

Critical identity linkage data must be strongly restricted.

---

### 4.2 High-Risk Identity Linkage Data

High-risk identity linkage data includes:

- customer account id
- membership id
- order session id linked to account
- waiting session id linked to account
- table session id linked to account
- refund reference
- recovery case reference
- customer support case reference
- wallet identity
- coupon issuance identity
- loyalty identity
- device identity linked to customer

High-risk identity linkage data may be used for operational continuity but must be masked or scoped where possible.

---

### 4.3 Operational Session Data

Operational session data includes:

- anonymous waiting token
- temporary table participation token
- temporary cart token
- temporary pickup order token
- kitchen ticket reference without identity
- store visit reference without direct identity

Operational session data may become sensitive if it can be joined with customer identity.

Therefore, session data must be protected according to its linkage risk.

---

## 5. Data Minimization Policy

The system must collect only the identity data required for the specific purpose.

The system must not collect CI/DI unless a verified identity linkage purpose exists.

Acceptable purposes may include:

- verified membership continuity
- duplicate account prevention
- payment-related verification where legally or commercially required
- refund or dispute handling
- legally required customer verification
- cross-device account recovery
- high-risk abuse prevention
- consented cross-service identity continuity

Unacceptable purposes include:

- convenience logging
- staff display
- analytics shortcut
- debugging without masking
- kitchen display
- casual CRM exploration
- broad data export
- unnecessary cross-tenant comparison

Identity collection must have purpose.

---

## 6. Separation Of Identity And Operation

Customer identity and operational state must be separated.

The system should separate:

- customer identity
- waiting session
- order session
- table session
- payment reference
- kitchen ticket
- recovery case
- support case
- audit event

A kitchen ticket does not need CI/DI.

A KDS screen does not need CI/DI.

A staff order view usually does not need CI/DI.

A customer support case may need masked identity reference and only reveal more under approved scope.

Operational continuity must be possible without exposing raw identity linkage values broadly.

---

## 7. Display And Masking Policy

Raw identity linkage values must not be displayed by default.

### 7.1 Staff View

Staff view may show:

- customer nickname where applicable
- masked phone number
- order number
- waiting number
- pickup code
- table participation label
- membership tier where operationally needed

Staff view must not show by default:

- CI
- DI
- full phone number
- full email address
- identity provider reference
- raw payment identity
- cross-service linkage key

---

### 7.2 Kitchen View

Kitchen view must be identity-minimized.

Kitchen view may show:

- ticket number
- menu items
- allergy or safety note where needed
- delay note
- remake note
- pickup or table marker

Kitchen view must not show:

- CI
- DI
- full phone number
- payment identity
- customer account id
- membership id unless necessary
- unnecessary personal identifiers

Kitchen execution does not require raw customer identity.

---

### 7.3 Owner And Store Admin View

Owner and store admin view may show operationally necessary customer information.

However, identity display must be scoped.

Owner and store admin view should prefer:

- masked phone number
- customer grade
- visit count within the store
- coupon eligibility
- order history summary
- support status summary

Owner and store admin view must not expose CI/DI by default.

---

### 7.4 HQ And Support View

HQ and support view may require deeper identity lookup for legitimate support or recovery cases.

However, access must be:

- case-based
- purpose-based
- role-based
- time-limited where possible
- masked by default
- audited when unmasked

Raw CI/DI access must be exceptional.

---

## 8. Logging Policy

Logs must not contain raw identity linkage values.

The following must be masked, hashed, tokenized, or excluded:

- CI
- DI
- full phone number
- full email address
- customer account id where not needed
- payment reference where sensitive
- identity provider reference
- cross-service linkage key
- raw authorization data
- recovery case identity details

Logs may include:

- masked customer reference
- internal correlation id
- order id
- ticket id
- tenant id
- store id
- audit event id
- non-reversible hash where approved

Logs are not identity storage.

---

## 9. Audit Policy

Access to sensitive identity linkage data must be audited.

Audit events are required for:

- CI/DI access
- raw phone number access
- identity unmasking
- customer account merge
- cross-service identity linking
- identity verification result handling
- customer data export
- support access to identity details
- recovery case identity lookup
- payment identity reference lookup
- suspected identity leakage
- identity deletion or anonymization request
- consent change

Audit records must include:

- actor
- role
- tenant context
- store context if applicable
- customer reference
- action
- purpose
- masking status
- timestamp
- case reference if applicable
- approval reference if applicable

Audit must not store raw CI/DI values.

---

## 10. Tenant And Store Leakage Prevention

Identity linkage data must not leak across tenants or stores.

### 10.1 Tenant Boundary

A customer identity in one tenant must not be visible to another tenant unless a formally supported cross-tenant identity model exists.

By default:

- tenant customer identity is isolated
- tenant membership is isolated
- tenant coupon history is isolated
- tenant support history is isolated
- tenant order history is isolated

Cross-tenant identity linkage must be explicit, consented where required, and audited.

---

### 10.2 Store Boundary

A store may access only the customer information needed for that store operation.

Store-level access should not automatically reveal:

- full multi-store customer profile
- full cross-store visit history
- full identity verification data
- raw CI/DI
- other tenant activity
- unrelated support cases

Store access must follow purpose and scope.

---

## 11. Customer Consent And Purpose Boundary

Identity linkage must respect consent and purpose.

Consent-related records must distinguish:

- service terms agreement
- marketing consent
- push notification consent
- SMS consent
- email consent
- identity verification consent
- cross-service linkage consent
- third-party sharing consent
- loyalty program consent

Consent for one purpose must not be reused for another unrelated purpose.

Marketing consent does not automatically permit broad identity linkage.

Identity verification does not automatically permit marketing use.

Order completion does not automatically permit unrelated profiling.

---

## 12. Payment Identity Boundary

Payment identity must be separated from customer identity where possible.

The system must distinguish:

- customer account
- payment method token
- payment provider reference
- transaction reference
- refund reference
- settlement reference
- receipt reference

Staff and kitchen views do not need raw payment identity.

Payment correction and refund handling must use controlled server-side workflows.

Payment identity exposure must be treated as a security incident.

---

## 13. Waiting Order Table Session Boundary

Waiting, order, and table sessions are operational continuity tools.

They must not expose more identity than required.

### 13.1 Waiting Session

Waiting session may use:

- waiting number
- temporary token
- masked phone number for notification
- party size
- arrival estimate

Waiting session must not expose CI/DI.

---

### 13.2 Order Session

Order session may use:

- order id
- customer display marker
- cart id
- table or pickup context
- payment status marker

Order session must not expose raw identity linkage values to unnecessary runtime.

---

### 13.3 Table Session

Table session may include multiple customers.

The system must not assume:

- one table equals one customer
- one table equals one payment identity
- one order equals one customer identity

Shared table and split settlement must preserve identity separation.

---

## 14. Support Access Boundary

Support access to identity linkage data must be controlled.

Support access requires:

- case reference
- purpose
- role authority
- masking by default
- audit event
- time-bound scope where possible
- approval for raw identity access where required

Support must not use broad search to browse customer identity casually.

Support access must not become a hidden identity export path.

---

## 15. Data Export Policy

Customer identity export is security-sensitive.

Exports containing identity linkage data require:

- purpose
- actor
- approval where needed
- tenant scope
- store scope if applicable
- masking rule
- retention rule
- audit event
- secure delivery method

Exports must not include raw CI/DI unless legally and operationally justified.

Export files must not become uncontrolled copies of sensitive identity data.

---

## 16. Retention And Deletion Direction

Identity linkage data must not be retained forever without purpose.

Retention must consider:

- legal requirement
- payment dispute period
- refund period
- customer support period
- accounting requirement
- membership continuity
- fraud prevention
- audit requirement
- customer deletion request

Deletion or anonymization must preserve required audit and legal evidence without keeping unnecessary raw identity values.

Final retention periods must be defined in later compliance documents.

---

## 17. Identity Leakage Definition

Identity leakage occurs when sensitive identity linkage data is exposed outside its intended scope.

Examples:

- CI appears in logs
- DI appears in screenshot
- full phone number appears in kitchen view
- customer account id appears in public page
- payment reference appears in customer-inappropriate context
- tenant A customer identity appears to tenant B
- store A sees store B customer identity without authority
- raw identity data is pasted into prompt
- identity export is shared through unsafe channel
- support user accesses identity without case purpose
- KDS receives unnecessary identity linkage values

Identity leakage must be treated as a security and privacy incident.

---

## 18. Identity Leakage Response

If identity leakage is suspected:

1. Stop further exposure.
2. Identify exposed identity type.
3. Identify affected customer scope.
4. Identify tenant and store scope.
5. Identify exposure location.
6. Restrict access to exposed material.
7. Remove or quarantine exposed material where possible.
8. Check logs, screenshots, exports, prompts, and documents.
9. Determine whether raw CI/DI was exposed.
10. Determine whether payment identity was exposed.
11. Create security incident record.
12. Record recovery evidence.
13. Notify responsible owner.
14. Review legal or compliance notification requirement.
15. Update masking or access rule.
16. Verify prevention update.

Deletion alone is not sufficient.

The project must understand what was exposed, where, to whom, and whether further action is required.

---

## 19. CI / DI Specific Policy

CI and DI must receive the highest identity linkage protection.

CI/DI must not be:

- displayed to ordinary staff
- displayed to kitchen
- logged raw
- exported casually
- stored in markdown
- pasted into prompts
- included in screenshots
- exposed through support UI by default
- used as ordinary primary lookup in visible UI
- shared across tenants without approved model

CI/DI access must be:

- purpose-based
- role-based
- audited
- masked or tokenized where possible
- minimized
- server-side controlled

CI/DI leakage must be escalated as a serious incident.

---

## 20. Analytics And AI Use Boundary

Identity linkage data must be minimized before analytics or AI use.

AI and analytics should use:

- aggregated data
- anonymized data
- pseudonymized reference
- tenant-scoped statistics
- store-scoped statistics
- non-identifying operational patterns

AI and analytics must not receive:

- raw CI
- raw DI
- unnecessary full phone number
- unnecessary full email
- raw payment identity
- raw cross-service linkage key
- raw customer support identity detail

AI recommendation does not require raw identity unless explicitly justified and controlled.

---

## 21. Development And Test Data Policy

Development and test environments must not use real identity linkage data by default.

Test data must use:

- dummy CI
- dummy DI
- dummy phone numbers
- dummy emails
- dummy customer ids
- dummy payment references
- synthetic order history
- synthetic membership history

Production customer identity must not be copied into development or staging without masking and approval.

Sample SQL, markdown documents, screenshots, and prompts must use dummy values only.

---

## 22. Secure Coding Checklist

Before implementation, confirm:

- CI/DI is not exposed to frontend unnecessarily.
- CI/DI is not logged raw.
- CI/DI is not shown in staff or kitchen views.
- Phone numbers are masked by default.
- Identity access is role-scoped.
- Identity unmasking is audited.
- Tenant boundary is enforced.
- Store boundary is enforced.
- Support access is case-based.
- Exports are controlled and audited.
- AI and analytics use minimized data.
- Test data is synthetic.
- Screenshots do not expose raw identity.
- Prompts do not include raw identity.
- Payment identity is separated from customer identity.
- Waiting, order, and table sessions do not leak raw identity.
- Shared table and split settlement preserve identity separation.

If any item fails, implementation must not proceed.

---

## 23. Non-Goals

This document does not define:

- final CI/DI provider
- final identity verification API
- final consent UI
- final privacy policy text
- final legal retention period
- final data deletion workflow
- final customer data export UI
- final anonymization algorithm
- final AI training data pipeline

Those must be defined in later identity, privacy, legal, compliance, or implementation documents.

---

## 24. Readiness Check

This policy is ready when the project can answer:

1. Where is CI stored?
2. Where is DI stored?
3. Who can access raw CI/DI?
4. Is CI/DI shown to staff?
5. Is CI/DI shown to kitchen?
6. Are phone numbers masked?
7. Is identity unmasking audited?
8. Can one tenant see another tenant customer identity?
9. Can one store see another store customer identity?
10. How is support access scoped?
11. How are identity exports controlled?
12. How is identity leakage detected?
13. What happens if CI appears in logs?
14. What happens if DI appears in screenshots?
15. How is payment identity separated from customer identity?
16. How is table session identity separated in split settlement?
17. How is AI prevented from receiving raw identity unnecessarily?
18. Is development data synthetic?

If these questions cannot be answered, implementation must not proceed.

---

## 25. Conclusion

Identity linkage data is one of the highest-risk data categories in the Yoonsul Wait/Order Handoff project.

CI, DI, phone number, account identity, payment reference, waiting session, order session, and table session can connect a customer across operational flows.

Therefore, the system must preserve the following rules:

- collect only what is needed
- separate identity from operation
- mask by default
- audit unmasking
- prevent tenant leakage
- prevent store leakage
- protect CI/DI as critical identity linkage data
- keep kitchen views identity-minimized
- keep support access case-based
- prevent logs, screenshots, prompts, and exports from leaking identity
- treat identity leakage as a security incident

Customer trust depends on operational convenience without unnecessary identity exposure.