# 14030_Policy_Early_SaaS_Renewal_Exit_Governance

## 1. Purpose

This document defines the renewal, upgrade, downgrade, pause, cancellation, exit, data retention, provider disconnect, module deactivation, support transition, and customer learning governance policy for early SaaS customers in the Yoonsul Wait/Order Handoff project.

The previous document defined early SaaS customer success, support tiers, retention signals, churn risks, expansion signals, and Franchise OS signals.

This document defines how customer lifecycle decisions must be controlled after early SaaS adoption.

This document does not implement billing, subscription management, data export, provider disconnect, or contract termination.

It defines governance policy only.

---

## 2. Scope

This document covers:

- renewal governance
- upgrade governance
- downgrade governance
- pause governance
- cancellation governance
- exit evidence
- data retention boundary
- data export boundary
- provider disconnect boundary
- module deactivation boundary
- support transition boundary
- hardware return or ownership boundary
- Franchise OS signal preservation
- no-implementation boundary

This document does not cover:

- final billing system
- final invoice logic
- final tax policy
- final legal agreement
- final subscription implementation
- final data export implementation
- final provider adapter disable code
- final hardware logistics process
- final customer success software

---

## 3. Core Principle

Customer lifecycle changes are runtime events, not only billing events.

The project must follow this rule:

> Renewal, upgrade, downgrade, pause, cancellation, and exit must protect operational continuity, audit evidence, payment truth, provider state, customer data, and support responsibility.

A billing change must not silently break store operation.

---

## 4. Lifecycle Decision Types

Recommended lifecycle decision types:

| Decision Type | Meaning |
| ------------- | ------- |
| Renewal | customer continues same package |
| Upgrade | customer adds package/module/support level |
| Downgrade | customer removes package/module/support level |
| Pause | temporary suspension with planned review |
| Cancellation | customer ends paid service |
| Exit | full offboarding from SaaS relationship |
| Reversal | cancellation/pause reversed before final exit |
| Reactivation | former customer returns later |

Each decision must be recorded.

---

## 5. Lifecycle Decision ID Format

Recommended ID format:

    LIFECYCLE-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Examples:

    LIFECYCLE-PSTORE-001-20260612-001
    LIFECYCLE-PSTORE-002-20260612-002

Alternative short format:

    LCD-001

Final naming may be normalized later during PC import.

---

## 6. Lifecycle Decision Record Fields

Each lifecycle decision record should include:

- lifecycle decision id
- customer/store id
- owner/HQ id where applicable
- current package
- current modules
- current provider stack
- current support tier
- decision type
- requested change
- reason
- effective date
- billing impact
- runtime impact
- data impact
- provider impact
- hardware impact
- support impact
- unresolved incidents
- unresolved blockers
- evidence retention rule
- export/deletion request
- reviewer
- approval status
- next review date

Lifecycle decisions must be auditable.

---

## 7. Lifecycle Decision Status Values

Recommended status values:

- `DRAFT`
- `UNDER_REVIEW`
- `NEEDS_CUSTOMER_CONFIRMATION`
- `NEEDS_OWNER_CONFIRMATION`
- `NEEDS_HQ_CONFIRMATION`
- `NEEDS_PROVIDER_REVIEW`
- `NEEDS_DATA_REVIEW`
- `NEEDS_HARDWARE_REVIEW`
- `NEEDS_SUPPORT_REVIEW`
- `APPROVED`
- `SCHEDULED`
- `COMPLETED`
- `PAUSED`
- `BLOCKED`
- `REJECTED`
- `SUPERSEDED`

Status must reflect actual readiness.

---

## 8. Renewal Governance

Renewal should confirm:

- customer still sees value
- package remains appropriate
- support tier remains appropriate
- provider stack remains supported
- unresolved incidents are reviewed
- pricing remains understood
- billing responsibility remains clear
- data responsibility remains clear
- customer health status is acceptable
- expansion or downgrade need is considered

Renewal should not be automatic during early SaaS stage without review.

---

## 9. Renewal Evidence

Renewal evidence should include:

- module usage
- owner satisfaction
- staff adoption
- support burden
- provider reliability
- payment recovery record
- KDS value
- Mini Kiosk value
- pricing acceptance
- unresolved issues
- customer health status
- next period plan

Renewal is strongest when value evidence is clear.

---

## 10. Renewal Outcome Values

Recommended renewal outcomes:

- `RENEW_SAME_PACKAGE`
- `RENEW_WITH_UPGRADE`
- `RENEW_WITH_DOWNGRADE`
- `RENEW_WITH_SUPPORT_CHANGE`
- `RENEW_WITH_PROVIDER_REVIEW`
- `RENEW_WITH_PRICING_REVIEW`
- `EXTEND_EARLY_SAAS`
- `MOVE_TO_STANDARD_SAAS`
- `PAUSE_BEFORE_RENEWAL`
- `DO_NOT_RENEW`

Outcome must be recorded.

---

## 11. Upgrade Governance

Upgrade may include:

- higher Store OS tier
- Mini Kiosk add-on
- KDS add-on
- Provider Gateway add-on
- Analytics add-on
- Support tier upgrade
- Multi-store dashboard
- Franchise OS discovery
- additional device
- additional store

Upgrade should proceed only when:

- current package is stable
- customer value is proven
- support burden is manageable
- provider stack can support upgrade
- payment/KDS risks are controlled
- owner understands fee change
- staff can be trained
- rollout plan exists
- rollback path exists

Do not upgrade unstable customers.

---

## 12. Upgrade Risk Review

Upgrade risk review should check:

- new module dependency
- provider dependency
- hardware dependency
- support increase
- training need
- billing complexity
- data access change
- customer expectation risk
- rollback complexity
- potential payment/KDS impact

Upgrade is a product expansion, not only a sales success.

---

## 13. Upgrade Evidence Required

Upgrade should require:

- expansion signal
- current health review
- module fit rationale
- support capacity review
- pricing confirmation
- provider compatibility review
- hardware readiness if applicable
- training plan
- rollback plan
- decision record

Upgrade without evidence can create churn.

---

## 14. Downgrade Governance

Downgrade may include:

- lower Store OS tier
- removing Mini Kiosk
- removing KDS
- removing Analytics
- reducing support tier
- disabling Provider Gateway add-on
- removing additional device
- removing HQ/multi-store view

Downgrade must protect operational continuity.

Downgrade must not corrupt:

- historical audit
- payment records
- order records
- KDS history
- incident records
- provider evidence
- support history
- legally required data

---

## 15. Downgrade Runtime Impact Review

Before downgrade, review:

- active orders
- active payments
- pending refunds
- unresolved incidents
- active KDS tickets
- active Mini Kiosk sessions
- active provider events
- pending reconciliation
- support cases
- hardware dependency
- staff workflow dependency

Downgrade should not occur mid-critical flow without safe plan.

---

## 16. Downgrade Feature Deactivation Rule

When deactivating a feature:

- stop new usage first
- preserve historical records
- finish active sessions where possible
- mark deactivation time
- notify responsible user
- record reason
- disable provider route safely
- preserve evidence
- update support scope
- update billing scope

Feature deactivation is controlled runtime change.

---

## 17. Pause Governance

Pause may be used when:

- customer is unsure about value
- provider issue blocks normal use
- store renovation or closure occurs
- support blocker needs resolution
- hardware replacement is pending
- pricing dispute is under review
- staff training must be redone
- pilot needs additional evidence

Pause should define:

- pause start date
- pause end or review date
- billing treatment
- active module status
- support treatment
- data retention
- provider connection status
- reactivation condition

Pause is not cancellation.

---

## 18. Cancellation Governance

Cancellation begins when customer requests service termination or project decides not to continue.

Cancellation must confirm:

- cancellation reason
- effective date
- billing stop date
- active modules
- active provider connections
- active hardware
- unresolved incidents
- data retention/export request
- support end date
- legal/contract requirement
- reactivation possibility
- exit evidence

Cancellation must not silently erase learning.

---

## 19. Exit Governance

Exit is final offboarding.

Exit should occur after:

- cancellation confirmed
- active sessions closed
- provider routes disabled
- hardware ownership/return resolved
- data retention/export handled
- support responsibilities ended or transferred
- unresolved incidents documented
- exit retrospective completed
- churn reason recorded
- future reactivation status recorded

Exit is complete only when operational, data, support, and billing boundaries are closed.

---

## 20. Data Retention Boundary

Data retention must distinguish:

- operational history
- payment evidence
- audit evidence
- support records
- customer identity
- store configuration
- provider event logs
- analytics data
- exported reports
- Franchise OS governance data
- billing records

Rules:

- legally required records must be preserved
- unnecessary personal data should be minimized
- sensitive data should remain masked
- audit evidence should not be deleted casually
- customer export/deletion rights must be handled through policy
- provider secrets must not be retained unnecessarily

---

## 21. Data Export Boundary

Customer may request export of:

- store configuration
- menu data
- order summaries
- payment summaries where allowed
- support case summaries
- reports
- historical operational data
- billing data

Export must not include:

- provider secrets
- payment secrets
- raw card data
- CI/DI
- other tenant data
- internal security logs beyond approved scope
- masked data in unmasked form
- confidential provider documents beyond allowed scope

Export authority must be reviewed.

---

## 22. Data Deletion Boundary

Deletion must be controlled.

Deletion should consider:

- legal retention
- payment dispute window
- tax/accounting retention
- support history
- audit integrity
- contractual requirement
- customer request
- tenant/store isolation
- backup retention
- anonymization option

Deletion is not immediate erasure of all operational evidence.

---

## 23. Provider Disconnect Boundary

Provider disconnect must be handled carefully.

Provider disconnect may involve:

- Toss connection
- OKPOS/OKDC route
- PAYCO payment channel
- VAN/PG setting
- local daemon
- kiosk vendor integration
- API hub route
- hardware terminal

Before disconnect:

1. stop new provider events if needed
2. resolve active orders
3. resolve active payments
4. resolve pending refunds
5. finish reconciliation
6. preserve provider evidence
7. remove credentials safely
8. notify customer
9. update support scope
10. record disconnect time

Provider disconnect is not only billing cancellation.

---

## 24. Mini Kiosk Deactivation Boundary

Before Mini Kiosk deactivation:

- stop new sessions
- complete active carts where possible
- block payment start if deactivation pending
- preserve order/payment session evidence
- show customer-safe message if active
- remove device trust where needed
- update store staff
- update billing
- update support scope

Never deactivate Mini Kiosk in a way that leaves customer payment status unclear.

---

## 25. KDS Deactivation Boundary

Before KDS deactivation:

- identify active tickets
- complete or hand off active kitchen work
- preserve ticket history
- prevent duplicate external kitchen output
- notify kitchen staff
- switch to manual or POS kitchen path
- record transition
- update support scope
- update billing

KDS deactivation must not interrupt kitchen execution unsafely.

---

## 26. Analytics Deactivation Boundary

Analytics deactivation may remove:

- advanced dashboards
- benchmark reports
- export functions
- cross-store comparison
- advanced trends

Analytics deactivation must preserve:

- operational audit
- payment/order records
- support records
- legally required history
- evidence needed for unresolved incidents

Analytics is optional display, not operational truth.

---

## 27. Support Tier Change Boundary

Support tier change must define:

- new support scope
- response expectation
- included categories
- excluded categories
- provider coordination change
- emergency handling change
- customer notification
- billing impact
- effective date

Lower support tier must not leave unresolved critical incidents abandoned.

---

## 28. Hardware Return Or Ownership Boundary

Hardware lifecycle must be clarified.

Hardware may be:

- customer-owned
- Yoonsul-owned
- leased
- vendor-owned
- financed
- bundled
- temporary pilot equipment

Exit must record:

- who owns hardware
- whether return is required
- condition check
- data wipe
- device trust removal
- warranty transfer
- replacement status
- unpaid hardware balance
- disposal rule

Device trust must be revoked when hardware leaves active service.

---

## 29. Franchise OS Signal Preservation

Even if customer exits, Franchise OS signals may remain useful as anonymized learning where permitted.

Preserve:

- store type learning
- provider learning
- support burden learning
- module adoption learning
- pricing learning
- staff adoption learning
- hardware learning
- churn reason
- feature gap

Do not preserve unnecessary customer identity.

---

## 30. Reactivation Governance

Former customer may reactivate later.

Before reactivation:

- review exit reason
- review unresolved blockers
- review provider stack
- review data retention status
- review pricing change
- review support tier
- review hardware status
- review product changes since exit
- create reactivation decision record

Reactivation should not repeat previous failure blindly.

---

## 31. Lifecycle Retrospective

Each cancellation or major downgrade should produce retrospective.

Questions:

1. Why did customer leave or downgrade?
2. Was value unclear?
3. Was pricing too high?
4. Was support burden too high?
5. Did staff refuse adoption?
6. Did provider issue cause failure?
7. Did hardware fail?
8. Did scope expectation mismatch occur?
9. Did we overpromise?
10. What should change before next customer?
11. Should package be changed?
12. Should support tier be changed?
13. Should provider status be changed?
14. Should feature be deferred or removed?

Exit is a learning event.

---

## 32. Anti-Patterns

The following are prohibited:

- treating cancellation as only billing stop
- disabling provider route while active payment is unresolved
- disabling Mini Kiosk during payment uncertainty
- disabling KDS during active kitchen work without handoff
- deleting evidence after cancellation
- ignoring customer churn reason
- blaming customer without reviewing support burden
- downgrading package while leaving unsafe feature gaps
- keeping device trust active after hardware return
- exporting sensitive data without review
- hiding provider failure behind cancellation
- offering discount instead of solving core value issue
- reactivating customer without reviewing exit reason

---

## 33. Non-Goals

This document does not define:

- final subscription management system
- final billing database
- final legal retention period
- final data export tool
- final deletion automation
- final provider disconnect API
- final device return logistics
- final SLA
- final customer contract

Those belong to later implementation and legal review.

---

## 34. Readiness Check

This document is ready when the project can answer:

1. What lifecycle decision types exist?
2. What fields must lifecycle decision record include?
3. What status values exist?
4. How is renewal governed?
5. What renewal evidence is required?
6. What renewal outcomes exist?
7. How is upgrade governed?
8. What upgrade risks are reviewed?
9. What upgrade evidence is required?
10. How is downgrade governed?
11. What runtime impact is reviewed before downgrade?
12. How is feature deactivation controlled?
13. How is pause governed?
14. How is cancellation governed?
15. How is exit governed?
16. What data retention boundary applies?
17. What data export boundary applies?
18. What data deletion boundary applies?
19. How is provider disconnect handled?
20. How is Mini Kiosk deactivation handled?
21. How is KDS deactivation handled?
22. How is analytics deactivation handled?
23. How is support tier change handled?
24. How is hardware return handled?
25. How is Franchise OS signal preserved?
26. How is reactivation governed?
27. What retrospective is required?
28. What anti-patterns are prohibited?

If these questions cannot be answered, early SaaS lifecycle governance is incomplete.

---

## 35. Conclusion

Early SaaS customer lifecycle changes must be controlled.

The correct lifecycle flow is:

    Renewal / Upgrade / Downgrade / Pause / Cancellation / Exit / Reactivation

Each lifecycle decision must protect:

- operational continuity
- payment truth
- KDS state
- Mini Kiosk session state
- provider route
- audit evidence
- customer data
- support responsibility
- hardware/device trust
- billing clarity
- future learning

This document ensures that SaaS customer changes do not break store operations, lose evidence, damage trust, or erase Franchise OS learning.