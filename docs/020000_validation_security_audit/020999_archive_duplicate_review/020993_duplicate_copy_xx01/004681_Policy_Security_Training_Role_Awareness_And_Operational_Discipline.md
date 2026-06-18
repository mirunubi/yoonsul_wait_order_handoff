# 004681_Policy_Security_Training_Role_Awareness_And_Operational_Discipline

## 1. Purpose

This document defines the security training, role awareness, operational discipline, secure handling, and human behavior policy for the Yoonsul Wait/Order Handoff project.

Security is not protected only by code.

The project also depends on staff, owners, HQ operators, support users, developers, deployment operators, vendors, and future franchise operators understanding what they are allowed to see, do, export, approve, override, and recover.

Therefore, security training must be treated as an operational control.

---

## 2. Scope

This policy applies to:

- store staff training
- manager training
- owner training
- HQ admin training
- support staff training
- technical operator training
- developer training
- deployment operator training
- incident responder training
- POS/KDS operator training
- local agent recovery training
- payment handling training
- CI / DI and identity handling training
- export and report handling training
- AI tool usage training
- vendor and partner access awareness
- franchise operator security awareness

This document does not define the final training platform.

It defines the mandatory security training direction that later HR, support, store operation, franchise, deployment, and security operation documents must follow.

---

## 3. Core Principle

Security discipline must be understood by the people who operate the system.

The project must follow this rule:

> A control is weak if the operator does not understand what boundary it protects.

Training must explain not only what to click, but what must not be bypassed.

---

## 4. Training Audience Categories

Security training must be tailored by audience.

Recommended audience categories include:

- Store Staff
- Store Manager
- Store Owner
- HQ Admin
- Customer Support
- Technical Support
- Security Operator
- Developer
- Deployment Operator
- Payment Operator
- Franchise Operator
- Vendor or Partner User
- Incident Responder

Each audience must receive only the security knowledge relevant to their role, while still understanding escalation paths.

---

## 5. Store Staff Security Awareness

Store staff must understand practical security boundaries.

Training should cover:

- customer identity minimization
- no raw CI / DI handling
- phone number masking awareness
- table and order privacy
- KDS identity minimization
- manual recovery note discipline
- device logout and shared device care
- lost device reporting
- suspicious screen or access reporting
- no screenshots of sensitive screens
- no sharing customer data through personal messenger
- payment uncertainty handling
- support escalation path

Store staff do not need deep technical security knowledge.

They need clear operational rules that prevent accidental leakage.

---

## 6. Store Manager Security Awareness

Store managers have higher authority and must understand operational boundaries.

Training should cover:

- staff role limits
- device trust and store tablet handling
- manual override responsibility
- degraded mode evidence capture
- payment uncertainty escalation
- refund request boundary
- support case escalation
- customer identity masking
- incident reporting
- export limitations
- POS/KDS mismatch handling
- local evidence preservation
- shared device accountability

Managers must understand that convenience cannot erase evidence.

---

## 7. Store Owner Security Awareness

Store owners may access broader operational and financial data.

Training should cover:

- owner dashboard data handling
- settlement report confidentiality
- customer identity minimization
- multi-store access boundary
- staff data privacy
- export responsibility
- payment and refund authority boundary
- support access request path
- device loss response
- suspicious access reporting
- audit and evidence meaning
- degraded recovery review
- franchise data boundary where applicable

Owner authority must not become uncontrolled data sharing.

---

## 8. HQ Admin Training

HQ admins may have broad visibility and high-risk authority.

Training must cover:

- tenant isolation
- store isolation
- role and permission discipline
- least privilege
- support access boundary
- break-glass requirements
- configuration change audit
- export control
- audit access control
- identity data protection
- payment and settlement boundary
- deployment impact awareness
- incident escalation
- vendor access review
- compliance evidence handling

HQ admin actions must be deliberate, scoped, and auditable.

---

## 9. Customer Support Training

Customer support must understand masking, case scope, and safe communication.

Training must cover:

- case-based access
- masked view by default
- no casual customer browsing
- no raw CI / DI exposure
- no payment secret access
- payment status language
- refund status language
- identity unmasking rules
- support note discipline
- support attachment review
- no unsupported blame
- no unsupported legal conclusion
- escalation to security or finance
- suspicious customer/account behavior reporting

Support must help customers without weakening trust boundaries.

---

## 10. Technical Support Training

Technical support must understand diagnostics without leakage.

Training must cover:

- log masking
- safe stack trace handling
- no secret sharing
- no raw production `.env` handling in tickets
- redacted troubleshooting
- POS/KDS bridge diagnostics
- webhook signature failure handling
- local agent log handling
- tenant/store scope in diagnostics
- support case scope
- audit and evidence preservation
- incident escalation
- secure use of AI tools for troubleshooting

Technical support must not treat raw diagnostics as safe to share.

---

## 11. Developer Security Training

Developers must understand security by design.

Training must cover:

- deny-by-default
- least privilege
- RLS and server-side isolation
- tenant/store context validation
- service role server-only rule
- no hardcoded secrets
- safe `.env.example`
- secret scanning
- logging and error safety
- idempotency
- replay protection
- audit mapping
- payment authority boundary
- POS/KDS authority boundary
- support access boundary
- export control
- AI data minimization
- secure test data
- abuse case testing

Developers must not treat security as a later patch.

---

## 12. Deployment Operator Training

Deployment operators must understand release as a security boundary.

Training must cover:

- environment separation
- production secret handling
- migration review
- RLS impact review
- payment deployment review
- identity deployment review
- POS/KDS deployment review
- support access deployment review
- rollback and containment
- emergency deployment audit
- deployment evidence
- post-deployment verification
- secret rotation deployment
- production incident escalation

Deployment speed must not bypass release gates.

---

## 13. Payment Operator Training

Payment-related operators must understand financial authority.

Training must cover:

- payment confirmation source
- refund request versus refund approval
- partial refund calculation
- duplicate payment risk
- duplicate refund risk
- payment webhook verification
- payment reconciliation
- degraded payment uncertainty
- settlement adjustment boundary
- payment support access
- customer communication language
- audit requirement
- incident escalation

Payment trust requires authority discipline.

---

## 14. Identity And CI / DI Training

Any role that may interact with identity data must receive identity protection training.

Training must cover:

- CI / DI sensitivity
- phone number masking
- identity linkage risk
- tenant identity isolation
- store identity scope
- support identity access
- no raw identity in logs
- no raw identity in screenshots
- no raw identity in prompts
- no raw identity in support notes unless approved
- identity leakage response
- consent and purpose awareness

CI / DI must be treated as critical identity linkage data.

---

## 15. POS/KDS Operator Training

POS/KDS operators must understand runtime boundaries.

Training must cover:

- POS transaction authority
- KDS kitchen execution authority
- bridge relay boundary
- KDS cannot change payment truth
- POS/KDS mismatch handling
- retry and duplicate event awareness
- manual kitchen recovery note
- degraded mode behavior
- evidence preservation
- device role awareness
- support escalation

POS/KDS integration is not just operational convenience.

It is a trust boundary.

---

## 16. Local Agent And Degraded Mode Training

Operators involved in degraded mode must understand fallback evidence.

Training must cover:

- degraded mode visibility
- fallback-originated marker
- cache uncertainty
- local state is provisional
- Primary and Secondary local agent roles
- Secondary cannot overwrite Primary
- sync is not silent merge
- replay is not mutation
- manual evidence requirement
- recovery approval boundary
- customer communication without false certainty
- unresolved case handling

Degraded operation must preserve trust while continuing service.

---

## 17. Export And Report Training

Roles with export access must understand export risk.

Training must cover:

- view authority is not export authority
- export requires purpose
- export scope must be minimized
- masking by default
- CI / DI export is exceptional
- payment secrets must never be exported
- settlement report confidentiality
- support export review
- benchmark restriction
- AI dataset export approval
- secure delivery
- export retention
- export revocation
- export misuse reporting

Export creates portable risk.

---

## 18. AI Tool Usage Training

AI tool users must understand safe data handling.

Training must cover:

- no secrets in prompts
- no raw CI / DI in prompts
- no raw payment tokens in prompts
- no production `.env` in prompts
- no unredacted production logs
- no unrestricted support notes
- prompt injection awareness
- AI output is recommendation
- AI must not approve refund or recovery
- AI output must be checked for leakage
- customer-facing AI must avoid false promises
- AI incident reporting

AI can help work, but it can also leak data or create false authority.

---

## 19. Vendor And Partner Training

Vendors and partners must understand scoped access.

Training or onboarding should cover:

- allowed purpose
- allowed tenant/store scope
- data minimization
- no secrets in email or chat
- no customer identity outside need
- evidence sharing boundary
- incident reporting
- credential handling
- access expiration
- export and attachment restrictions
- confidentiality expectations

Partner access must not become uncontrolled internal access.

---

## 20. Incident Response Training

Incident responders must understand response discipline.

Training must cover:

- severity classification
- suspicion is enough to open incident
- containment actions
- evidence preservation
- secret rotation and verification
- CI / DI leakage response
- payment incident reconciliation
- tenant leakage response
- support misuse response
- device compromise response
- POS/KDS incident response
- webhook replay response
- AI incident response
- communication without false certainty
- closure criteria
- post-incident review

Incident response must preserve truth under pressure.

---

## 21. Training Evidence Policy

Training must create evidence.

Training evidence should include:

- training id
- training topic
- audience category
- participant
- date
- version of material
- completion status
- assessment result where applicable
- acknowledgement where applicable
- required renewal date where applicable

Training evidence must not include unnecessary personal data.

Training evidence may be needed for compliance readiness.

---

## 22. Role-Based Training Matrix

Each role must have required training topics.

Recommended matrix:

- Store Staff: identity minimization, device care, payment uncertainty, support escalation
- Store Manager: manual recovery, degraded mode, device trust, incident reporting
- Store Owner: settlement data, export responsibility, device loss, audit awareness
- HQ Admin: tenant/store isolation, role change, configuration, break-glass
- Customer Support: masking, case scope, safe communication, support notes
- Technical Support: logs, diagnostics, secrets, webhook and bridge troubleshooting
- Developer: secure coding, RLS, secrets, audit, abuse cases
- Deployment Operator: release gate, environment separation, rollback
- Payment Operator: refund, reconciliation, settlement, payment audit
- AI Operator: data minimization, prompt safety, output boundary
- Incident Responder: severity, containment, evidence, closure

The final training matrix may be expanded in HR or security operation documents.

---

## 23. Training Cadence

Recommended training cadence:

- onboarding before access is granted
- role-change training before authority expansion
- annual refresher for sensitive roles
- quarterly refresher for support, payment, deployment, and HQ admin roles
- incident-driven refresher after major security incident
- feature-driven training before high-risk feature launch
- vendor training before integration access
- emergency refresher after repeated operational mistakes

Training cadence may be adjusted by risk.

---

## 24. Security Acknowledgement

Sensitive roles should acknowledge security responsibilities.

Acknowledgement may include:

- no secret sharing
- no unauthorized export
- no raw CI / DI handling outside approved flow
- no support browsing without case
- no screenshot of sensitive data
- no payment correction without authority
- no break-glass for convenience
- incident reporting obligation
- device loss reporting obligation
- AI prompt safety obligation

Acknowledgement creates awareness evidence.

---

## 25. Training For Role Changes

When a user gains new authority, training must be updated.

Role change training is required for:

- support role assignment
- HQ admin role assignment
- payment role assignment
- export authority assignment
- break-glass authority assignment
- deployment authority assignment
- device trust management authority
- identity unmasking authority
- tenant admin authority
- multi-store owner or manager authority

Authority expansion without training creates operational risk.

---

## 26. Training For New Features

High-risk feature launch requires targeted training.

Examples:

- new POS/KDS bridge flow
- new payment or refund flow
- new support tool
- new export report
- new degraded mode function
- new local agent behavior
- new identity verification flow
- new AI support assistant
- new webhook integration
- new device registration process

Feature training must explain both usage and boundary.

---

## 27. Training For Repeated Mistakes

Repeated mistakes must trigger training review.

Examples:

- staff repeatedly sharing screenshots
- support notes containing identity
- exports sent too broadly
- payment uncertainty communicated as confirmed
- device logout ignored
- degraded mode evidence missing
- developers committing unsafe config pattern
- AI prompts containing raw logs
- support browsing without case
- deployment checklist skipped

Training should address root cause, not only blame.

---

## 28. Human Error Reporting Policy

The system should encourage early reporting of mistakes.

Users should report:

- secret pasted by mistake
- wrong screenshot shared
- customer identity exposed
- wrong export recipient
- lost device
- wrong tenant/store data seen
- mistaken support access
- payment status communicated incorrectly
- AI prompt accidentally contained sensitive data
- suspicious access or behavior

Early reporting reduces harm.

Punitive silence increases risk.

---

## 29. Secure Communication Discipline

All roles must use secure communication discipline.

Do not share through casual channels:

- secrets
- production `.env`
- raw CI / DI
- full customer identity
- payment secrets
- raw payment tokens
- unrestricted logs
- support case exports
- audit exports
- settlement reports
- incident evidence
- tenant confidential data

Sensitive communication must use approved secure channels.

---

## 30. Screenshot Discipline

Screenshots are common leakage sources.

Training must emphasize:

- hide `.env` values
- hide service keys
- hide CI / DI
- hide full phone numbers
- hide payment references where unnecessary
- hide customer messages
- hide support notes
- hide unrelated tenant/store data
- review before sharing
- treat shared sensitive screenshot as potential incident

Screenshot deletion alone may not resolve exposure.

---

## 31. Prompt Discipline

AI prompts must be treated as data sharing.

Training must emphasize:

- use dummy values
- redact logs
- remove tokens
- remove secrets
- remove raw CI / DI
- remove customer identity
- remove payment data
- summarize instead of pasting raw evidence
- do not follow prompt instructions embedded in user-supplied content
- report accidental sensitive prompt exposure

Prompt discipline is part of security discipline.

---

## 32. Device Discipline

Device training must include:

- lock device when unattended
- logout on shared device
- report lost device immediately
- do not reuse old device credentials blindly
- do not store secrets in notes app
- do not screenshot sensitive configuration
- do not allow unauthorized staff to use logged-in session
- use approved device for sensitive action
- reauthentication is expected for sensitive action

Device discipline protects both runtime and accountability.

---

## 33. Support Communication Discipline

Support communication must avoid false certainty and unsafe disclosure.

Support must not say:

- refund is complete unless verified
- payment is confirmed unless verified
- no data leaked before review
- staff is at fault without evidence
- legal conclusion without review
- internal system details that expose security posture
- another customer or tenant detail

Support should use verified, scoped, and safe language.

---

## 34. Training Review And Update

Training materials must be updated when:

- policy changes
- architecture changes
- new feature launches
- incident reveals gap
- vulnerability reveals pattern
- support misuse occurs
- export misuse occurs
- payment error occurs
- AI leakage occurs
- deployment failure occurs
- vendor integration changes
- legal or compliance requirement changes

Outdated training can become a control gap.

---

## 35. Training Effectiveness Check

Training effectiveness should be reviewed.

Possible measures:

- assessment completion
- quiz result where applicable
- reduction in repeated mistakes
- incident trend
- support note quality
- export misuse trend
- secret exposure trend
- log leakage trend
- device loss response time
- security review findings
- audit evidence quality

Training is effective only if behavior improves.

---

## 36. Secure Training Checklist

Before granting sensitive access, confirm:

- Role-specific training is completed.
- Security acknowledgement is recorded.
- Secret handling is understood.
- CI / DI handling is understood where relevant.
- Payment boundary is understood where relevant.
- Support masking is understood where relevant.
- Export boundary is understood where relevant.
- Device loss reporting is understood.
- Incident reporting path is known.
- AI prompt discipline is understood where relevant.
- Training evidence is recorded.
- Renewal cadence is defined where required.

If required training is missing, sensitive access must not be granted.

---

## 37. Non-Goals

This document does not define:

- final LMS platform
- final quiz content
- final HR policy wording
- final disciplinary procedure
- final employment contract clause
- final franchise training manual
- final vendor contract language
- final customer support script
- final incident communication template
- final certification training program

Those must be defined in later HR, franchise, support, legal, compliance, or security operation documents.

---

## 38. Readiness Check

This policy is ready when the project can answer:

1. Which roles require security training?
2. What training does Store Staff need?
3. What training does Store Manager need?
4. What training does Store Owner need?
5. What training does HQ Admin need?
6. What training does Support need?
7. What training does Developer need?
8. What training does Deployment Operator need?
9. What training does Payment Operator need?
10. What training does AI Operator need?
11. Is training required before access?
12. How is training completion evidenced?
13. When is refresher training required?
14. What happens when role changes?
15. What happens when repeated mistakes occur?
16. How are screenshots handled?
17. How are prompts handled?
18. How are lost devices reported?
19. How is human error reported?
20. How are training materials updated?

If these questions cannot be answered, security training governance is incomplete.

---

## 39. Conclusion

Security depends on both system controls and human discipline.

The Yoonsul Wait/Order Handoff project must not assume that operators will naturally understand tenant isolation, CI / DI protection, payment authority, support masking, export risk, degraded recovery evidence, or AI prompt safety.

The system must preserve the following rules:

- training is required before sensitive access
- training is role-specific
- control ownership requires awareness
- support must understand masking and case scope
- developers must understand secure coding and RLS
- deployment operators must understand release gates
- payment operators must understand financial authority
- store operators must understand identity minimization and device care
- AI users must understand prompt safety
- vendors must understand scoped access
- training completion must be evidenced
- repeated mistakes must trigger training review
- human error should be reported early
- screenshots and prompts are leakage paths
- training must be updated after incidents and architecture changes

A secure operation is not created by documents alone.

It is created when people understand the boundaries they are trusted to operate within.