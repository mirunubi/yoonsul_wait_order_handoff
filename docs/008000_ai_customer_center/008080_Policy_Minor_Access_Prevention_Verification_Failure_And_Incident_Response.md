# 008080_Policy_Minor_Access_Prevention_Verification_Failure_And_Incident_Response

## 1. Purpose

This document defines the minor access prevention, adult verification failure, suspected underage access, verification bypass attempt, staff intervention, service refusal, incident response, evidence, customer recovery, support escalation, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined alcohol payment, refund, dispute, chargeback, customer recovery, POS reconciliation, KDS reconciliation, and payment evidence boundary policy.

This document focuses on preventing alcohol access by minors or unverified recipients and responding safely when adult verification fails or underage risk is suspected.

This document does not provide legal advice and does not implement identity verification, ID scanning, law enforcement reporting, staff scripts, POS/KDS logic, or incident automation.

It defines minor access prevention and verification failure incident response boundary policy only.

---

## 2. Scope

This document covers:

- minor access prevention
- verification failure handling
- suspected underage access
- verification bypass attempt
- shared table risk
- pickup/delivery recipient risk placeholder
- staff intervention
- service refusal
- incident creation
- evidence capture
- support escalation
- customer recovery
- no-implementation boundary

This document does not cover:

- final legal alcohol sale rule
- final ID verification vendor
- final CI/DI implementation
- final government reporting
- final police/security procedure
- final staff legal script
- final delivery alcohol rule
- final POS implementation
- final KDS implementation
- final payment implementation

---

## 3. Core Principle

Minor access prevention must block alcohol fulfillment before payment, KDS release, service, or recovery becomes unsafe.

The project must follow this rule:

> If adult verification fails, is uncertain, is bypassed, or underage access is suspected, alcohol-related order, payment, KDS release, service, delivery handoff, and staff fulfillment must enter hold, refusal, review, or incident response rather than continue as ordinary order flow.

Minor access risk is not an ordinary validation error.

Verification failure must default to prevention.

---

## 4. Minor Access Prevention Meaning

Minor access prevention means preventing alcohol sale, fulfillment, service, pickup, or delivery to a person who is not verified as legally eligible.

It includes:

- blocking alcohol order completion
- blocking KDS release
- blocking service
- blocking delivery handoff if applicable
- blocking pickup handoff if applicable
- preventing staff bypass
- preventing shared-table misuse
- preventing repeated attempts
- recording safe evidence
- escalating incidents if needed

Prevention must occur before service, not only after dispute.

---

## 5. Verification Failure Meaning

Verification failure means the adult verification process did not establish eligibility.

Failure may occur because:

- person is not eligible
- identity document invalid
- verification declined
- manual review failed
- verification expired
- recipient mismatch
- account holder and recipient mismatch
- staff cannot verify
- provider rejects verification
- legal condition not satisfied

Failure should be treated as alcohol block, not technical delay.

---

## 6. Verification Failure Status Values

Recommended verification failure status values:

- `VERIFY_FAILURE_NONE`
- `VERIFY_FAILURE_UNDERAGE_OR_NOT_ELIGIBLE`
- `VERIFY_FAILURE_DOCUMENT_INVALID`
- `VERIFY_FAILURE_PROVIDER_REJECTED`
- `VERIFY_FAILURE_USER_CANCELLED`
- `VERIFY_FAILURE_RECIPIENT_MISMATCH`
- `VERIFY_FAILURE_MANUAL_REVIEW_FAILED`
- `VERIFY_FAILURE_EXPIRED`
- `VERIFY_FAILURE_BYPASS_ATTEMPT`
- `VERIFY_FAILURE_STAFF_ESCALATION_REQUIRED`
- `VERIFY_FAILURE_INCIDENT_OPEN`

Final values may be normalized later.

---

## 7. Verification Uncertainty Is Not Pass

Verification uncertainty must not be treated as success.

Uncertainty may include:

- provider timeout
- network error
- unclear document
- staff unable to confirm
- recipient mismatch
- device/session mismatch
- table participant ambiguity
- delivery/pickup recipient unclear
- identity provider degraded
- customer refuses verification

Uncertainty must lead to hold, manual review, or refusal according to policy.

---

## 8. Suspected Underage Access Meaning

Suspected underage access means there is a reasonable operational signal that alcohol may be ordered, paid, received, or consumed by an unverified or underage person.

Signals may include:

- verification failure
- customer appears underage
- customer refuses verification
- verified account holder absent
- another person attempts pickup
- table participant ambiguity
- late-joining unverified participant
- customer attempts repeated reorder after failure
- staff observation
- support report
- delivery recipient mismatch
- device shared by group

Suspicion is not final legal conclusion.

It is a safety trigger.

---

## 9. Suspected Underage Risk Status Values

Recommended values:

- `UNDERAGE_RISK_NONE`
- `UNDERAGE_RISK_WATCH`
- `UNDERAGE_RISK_VERIFICATION_REQUIRED`
- `UNDERAGE_RISK_STAFF_REVIEW_REQUIRED`
- `UNDERAGE_RISK_SERVICE_HOLD`
- `UNDERAGE_RISK_SERVICE_REFUSAL_REVIEW`
- `UNDERAGE_RISK_SERVICE_REFUSED`
- `UNDERAGE_RISK_INCIDENT_OPEN`
- `UNDERAGE_RISK_ESCALATED`
- `UNDERAGE_RISK_CLOSED`

Risk status must be visible to authorized staff.

---

## 10. Order Block Rule

Alcohol order must be blocked when:

- adult verification failed
- adult verification uncertain and no fallback allowed
- customer refuses verification
- recipient mismatch exists
- underage risk is active
- bypass attempt detected
- staff confirmation rejected
- service refusal confirmed
- legal restriction applies
- delivery/pickup recipient cannot be verified

Blocking alcohol should not necessarily block non-alcohol items.

---

## 11. Payment Block Or Recovery Rule

Payment should be blocked before capture if verification failure is known.

If payment already occurred:

- refund/reversal path must be reviewed
- KDS status must be checked
- service status must be checked
- customer communication must be respectful
- evidence must link verification failure and payment
- manager or support escalation may be required
- non-alcohol portion may continue if safe

Payment must not pressure staff into illegal or unsafe service.

---

## 12. KDS Block Rule

KDS must not receive executable alcohol ticket when:

- verification failed
- verification uncertain
- underage risk active
- bypass attempt active
- staff confirmation rejected
- service refusal review active
- payment state unresolved after failure
- provider mapping uncertain

KDS may receive hold/cancel status only if needed.

Kitchen must not resolve legal eligibility.

---

## 13. Service Refusal Rule

Service refusal should be required when:

- verification failed
- customer refuses verification
- customer appears underage and cannot verify
- recipient mismatch cannot be resolved
- bypass attempt detected
- manual verification failed
- staff cannot safely confirm eligibility
- legal restriction applies
- manager confirms refusal

Service refusal should be calm and evidence-linked.

---

## 14. Customer Communication Rule

Customer communication should be respectful and non-accusatory.

Recommended safe wording:

    주류 주문은 성인 확인이 완료되어야 진행할 수 있습니다. 확인이 완료되지 않아 해당 주류 주문은 진행이 어렵습니다. 직원이 가능한 범위에서 도와드리겠습니다.

Avoid:

    미성년자로 확인되었습니다.
    신분증이 가짜입니다.
    법적으로 문제라서 안 됩니다.
    술 못 팝니다.
    시스템에 미성년자로 뜹니다.

Customer-facing message should avoid unnecessary sensitive detail.

---

## 15. Staff Communication Rule

Staff screen should show:

- verification failed or uncertain
- safe failure category
- underage risk status
- alcohol order hold
- payment recovery status
- KDS hold/cancel status
- service refusal recommendation
- manager escalation need
- safe customer wording
- evidence requirement

Staff screen must not show raw CI/DI or full identity document data.

---

## 16. Bypass Attempt Meaning

Bypass attempt means behavior that appears to avoid or defeat adult verification.

Examples:

- repeated order after failed verification
- switching account/device after failure
- using another verified customer’s session
- asking staff to skip verification
- attempting payment before verification
- changing recipient after verification
- scanning another table object
- delivery/pickup recipient mismatch
- manual staff override without evidence
- repeated provider retry after rejection

Bypass attempt must be handled as risk signal, not automatic accusation.

---

## 17. Bypass Attempt Status Values

Recommended values:

- `BYPASS_NONE`
- `BYPASS_SUSPECTED`
- `BYPASS_REVIEW_REQUIRED`
- `BYPASS_STAFF_INTERVENTION_REQUIRED`
- `BYPASS_MANAGER_REVIEW_REQUIRED`
- `BYPASS_SERVICE_REFUSAL_RECOMMENDED`
- `BYPASS_INCIDENT_OPEN`
- `BYPASS_ESCALATED`
- `BYPASS_CLOSED`

Bypass status should not appear as accusatory customer label.

---

## 18. Shared Table Minor Risk Rule

Shared table creates special minor risk.

Risk cases:

- one verified adult orders for table
- unverified person consumes alcohol
- late-joining minor sits at table
- verified person leaves table
- group changes seat/table
- split payment by unverified participant
- staff cannot identify actual recipient
- alcohol add-on made by different person

Table-level verification must not imply all participants are eligible.

---

## 19. Late Joining Participant Rule

If a late participant joins during alcohol service:

- do not assume verified status
- staff may need visual confirmation
- additional alcohol order may require review
- table status may become verification review required
- service refusal may apply if eligibility unclear
- evidence may need staff note

Late participant risk is especially relevant in night operation.

---

## 20. Pickup Recipient Placeholder

Pickup alcohol sale requires separate review.

Until defined:

- alcohol pickup mode should remain disabled or restricted
- recipient verification at pickup must be defined
- account holder and recipient mismatch must be handled
- staff handoff evidence must be defined
- refund/cancel path must be defined
- legal review must be completed

This document does not approve alcohol pickup.

---

## 21. Delivery Recipient Placeholder

Delivery alcohol sale requires separate review.

Until defined:

- alcohol delivery mode should remain disabled
- delivery recipient verification must be defined
- platform policy must be reviewed
- rider responsibility must be defined
- store responsibility must be defined
- recipient mismatch must be handled
- refund/cancel path must be defined
- evidence must be defined

This document does not approve alcohol delivery.

---

## 22. Staff Manual Override Restriction

Staff manual override of verification failure must be prohibited by default.

If any manual fallback is allowed later, it must require:

- trained staff
- accepted ID inspection
- reason code
- manager approval if required
- scope-limited confirmation
- timestamp
- staff actor
- evidence packet
- audit
- no raw ID storage unless separately approved

Manual override must not become bypass.

---

## 23. Manager Escalation Rule

Manager escalation is required when:

- customer disputes verification failure
- bypass attempt suspected
- underage risk remains unclear
- staff feels pressured to serve
- customer becomes abusive
- payment occurred before failure
- KDS already prepared item
- table group conflict occurs
- service refusal may escalate
- legal/compliance concern exists

Manager escalation must be recorded.

---

## 24. Incident Creation Rule

Incident should be created when:

- underage access suspected
- verification failure leads to dispute
- bypass attempt suspected
- staff manual override attempted
- payment occurred before verification failure
- KDS released despite failure
- alcohol was served despite unresolved verification
- customer became abusive
- service refusal escalated
- delivery/pickup recipient mismatch involved alcohol

Incident must be evidence-linked.

---

## 25. Minor Access Incident Status Values

Recommended values:

- `MINOR_ACCESS_INCIDENT_NOT_OPEN`
- `MINOR_ACCESS_INCIDENT_OPEN`
- `MINOR_ACCESS_INCIDENT_EVIDENCE_REQUIRED`
- `MINOR_ACCESS_INCIDENT_STAFF_REVIEW`
- `MINOR_ACCESS_INCIDENT_MANAGER_REVIEW`
- `MINOR_ACCESS_INCIDENT_SERVICE_REFUSED`
- `MINOR_ACCESS_INCIDENT_PAYMENT_REVIEW`
- `MINOR_ACCESS_INCIDENT_KDS_REVIEW`
- `MINOR_ACCESS_INCIDENT_SUPPORT_ESCALATED`
- `MINOR_ACCESS_INCIDENT_LEGAL_REVIEW_REQUIRED`
- `MINOR_ACCESS_INCIDENT_RESOLVED`
- `MINOR_ACCESS_INCIDENT_CLOSED`

Incident status must not be hidden in notes.

---

## 26. Incident Evidence Fields

Minor access incident evidence should include:

- incident id
- order/session reference
- table reference if any
- alcohol item reference
- verification status
- failure category
- uncertainty category if any
- underage risk status
- bypass attempt status
- staff actor
- manager actor if any
- payment status
- KDS status
- service status
- service refusal status
- customer communication status
- support case reference
- timestamps
- masking status
- notes

Evidence should avoid raw identity data and accusatory language.

---

## 27. Incident ID Format

Recommended format:

    MINOR-ACCESS-INCIDENT-[YYYYMMDD]-[NUMBER]

Example:

    MINOR-ACCESS-INCIDENT-20260612-001

Final format may be normalized later.

---

## 28. Evidence Language Rule

Evidence language should describe observable operational facts.

Use:

- verification failed
- verification could not be completed
- recipient mismatch
- staff review required
- customer declined verification
- service refused under policy
- payment review required

Avoid:

- fake ID
- underage customer
- drunk minor
- illegal attempt
- customer lied
- fraud

Evidence must not overstate legal conclusion.

---

## 29. Privacy And Masking Rule

Minor access evidence must not expose:

- raw CI/DI
- full ID document data
- full birthdate
- full name unless required and approved
- raw provider payload
- payment secrets
- unnecessary staff private data
- customer accusation labels

Evidence should use safe categories and references.

---

## 30. Payment Recovery Rule

If payment occurred before minor access prevention blocked service:

- refund or reversal review must start
- alcohol item must remain unserved
- KDS status must be checked
- customer communication must be calm
- support escalation may be needed
- evidence must preserve payment timeline
- non-alcohol portion may continue if safe
- manager review may be required

Payment recovery must not force alcohol service.

---

## 31. KDS Recovery Rule

If KDS was released despite failure:

- preparation status must be checked
- service status must be checked
- item must not be served if eligibility unresolved
- waste handling may be needed
- manager review required
- incident created
- KDS evidence preserved
- root cause review required

KDS error in minor access context is serious.

---

## 32. Service Recovery Rule

If alcohol was served despite unresolved verification:

- incident must be escalated
- evidence must preserve timeline
- staff/manager review required
- legal/compliance review may be required
- payment/refund handling must be reviewed
- staff training gap should be checked
- system blocker gap should be checked
- support/security escalation may be required

This is a critical incident class.

---

## 33. Support Boundary

Support may assist when:

- customer disputes verification failure
- payment recovery needed
- evidence incomplete
- provider verification status unclear
- staff needs guidance
- incident escalation required
- KDS/payment mismatch exists
- customer recovery required

Support must remain masked and case-scoped.

Support must not approve alcohol service after verification failure.

---

## 34. Admin Console Boundary

Future Admin Console may show:

- verification failure count
- underage risk review count
- bypass review count
- minor access incident count
- service refusal count
- payment recovery count
- KDS recovery count
- evidence completeness

Admin Console must not display raw identity data or accusatory labels.

Admin Console must not provide direct alcohol approval after failure.

---

## 35. Provider Boundary

Provider verification event must be mapped safely.

Rules:

- provider failure must not auto-pass
- provider uncertainty must hold
- provider rejection must block alcohol
- raw provider payload must not be exposed
- provider outage may create incident if repeated
- provider result must be mapped to safe category
- provider mismatch must not be ignored

Provider result is evidence input, not visible identity display.

---

## 36. Training Boundary

Staff training must cover:

- adult verification failure handling
- calm refusal wording
- not accusing customer
- not storing raw ID
- when to call manager
- how to handle payment already made
- how to hold KDS
- how to record evidence
- how to handle group/table ambiguity
- how to de-escalate pressure

Minor access prevention cannot rely only on software.

---

## 37. Store Safety Boundary

Store safety may be affected when:

- customer is angry about refusal
- group pressures staff
- staff is alone at night
- payment already occurred
- delivery rider/customer pressures handoff
- customer attempts repeated order
- abusive behavior occurs

Safety escalation must be available.

Sales must not override staff safety.

---

## 38. Commercial Boundary

Minor access prevention may affect:

- high-risk operation package
- compliance setup
- identity verification provider cost
- staff training cost
- support tier
- incident handling cost
- legal/compliance review cost
- night operation support
- alcohol mode eligibility

This capability should not be bundled casually into ordinary ordering.

---

## 39. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- acceptable verification method
- manual verification fallback
- refusal wording
- incident retention
- staff training record
- privacy notice
- ID data handling
- payment recovery after refusal
- delivery/pickup alcohol restriction
- local jurisdiction requirements

This document does not provide legal conclusion.

---

## 40. Implementation Deferral Boundary

This document does not authorize:

- alcohol sale activation
- identity verification implementation
- CI/DI collection
- ID image storage
- minor detection automation
- bypass scoring
- automatic customer blocking
- law enforcement reporting
- delivery alcohol workflow
- Admin Console minor access controls
- payment refund automation

Implementation requires separate legal, privacy, security, runtime, and build authorization.

---

## 41. Registers Recommendation

Recommended future files:

    docs/_index/
      Verification_Failure_Status_Register.md
      Underage_Risk_Status_Register.md
      Bypass_Attempt_Register.md
      Minor_Access_Incident_Register.md
      Minor_Access_Evidence_Register.md
      Minor_Access_Payment_Recovery_Register.md
      Minor_Access_KDS_Recovery_Register.md
      Minor_Access_Service_Recovery_Register.md

This document only recommends these files.

It does not create them.

---

## 42. Anti-Patterns

The following are prohibited:

- treating verification failure as minor UI error
- allowing alcohol order after failed verification
- sending alcohol to KDS after verification failure
- allowing staff to override failure casually
- assuming table representative verifies everyone
- using accusatory labels in UI or evidence
- exposing raw CI/DI or ID data
- charging customer then forcing alcohol service
- ignoring payment recovery after refusal
- ignoring KDS release after failure
- allowing delivery alcohol without recipient rule
- burying minor access incident in notes
- using provider uncertainty as pass
- blaming customer without evidence

---

## 43. Non-Goals

This document does not define:

- final legal compliance rule
- final acceptable ID method
- final identity provider
- final CI/DI storage
- final staff refusal script
- final incident reporting law
- final payment refund rule
- final KDS implementation
- final delivery alcohol procedure
- final Admin Console UI

Those belong to later legal, privacy, security, runtime, provider, and implementation planning.

---

## 44. Readiness Check

This document is ready when the project can answer:

1. What does minor access prevention mean?
2. What does verification failure mean?
3. What verification failure statuses exist?
4. Why is verification uncertainty not pass?
5. What does suspected underage access mean?
6. What underage risk statuses exist?
7. When must alcohol order be blocked?
8. What payment block or recovery rule applies?
9. What KDS block rule applies?
10. What service refusal rule applies?
11. What customer communication rule applies?
12. What staff communication rule applies?
13. What does bypass attempt mean?
14. What bypass attempt statuses exist?
15. What shared table minor risk applies?
16. What late joining participant rule applies?
17. What pickup recipient placeholder applies?
18. What delivery recipient placeholder applies?
19. What staff manual override restriction applies?
20. When is manager escalation required?
21. When should incident be created?
22. What minor access incident statuses exist?
23. What incident evidence fields are needed?
24. What evidence language rule applies?
25. What privacy and masking rule applies?
26. What payment recovery rule applies?
27. What KDS recovery rule applies?
28. What service recovery rule applies?
29. What support boundary applies?
30. What Admin Console boundary applies?
31. What provider boundary applies?
32. What training boundary applies?
33. What store safety boundary applies?
34. What commercial boundary applies?
35. What legal/compliance handoff is needed?
36. What implementation deferral boundary applies?
37. What anti-patterns are prohibited?

If these questions cannot be answered, minor access prevention, verification failure, and incident response planning is incomplete.

---

## 45. Conclusion

Minor access prevention is a hard stop foundation requirement for alcohol mode.

The safe prevention flow is:

    alcohol access attempt
        -> adult verification
        -> failure, uncertainty, or bypass review
        -> order/payment/KDS/service hold
        -> staff or manager intervention
        -> service refusal if required
        -> payment/KDS recovery if needed
        -> incident evidence
        -> support/legal/compliance handoff if needed

This document ensures that verification failure, suspected underage access, bypass attempts, shared table ambiguity, pickup/delivery recipient risk, payment recovery, KDS recovery, and service refusal are handled as high-risk foundation states before alcohol mode is enabled.