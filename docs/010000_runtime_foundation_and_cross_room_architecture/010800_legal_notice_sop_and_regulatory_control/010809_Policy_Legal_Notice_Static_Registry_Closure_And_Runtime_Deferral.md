# 010809_Policy_Legal_Notice_Static_Registry_Closure_And_Runtime_Deferral.md

## Purpose

This document closes the Legal Notice Static Registry planning sequence for Catch Menu.

The previous document `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy` defined emergency lock, regulatory change response, unsafe notice suspension, forced activation, feature block, translation emergency, evidence capture emergency, support guidance, rollback, and postmortem governance.

This document consolidates and closes the legal notice master planning package.

It confirms:

- legal notice master data boundary
- notice versioning boundary
- trigger and surface mapping boundary
- privacy consent boundary
- alcohol notice boundary
- refund/no-show boundary
- i18n boundary
- admin toggle and HQ lock boundary
- seed approval boundary
- evidence export boundary
- customer UX boundary
- emergency lock boundary
- runtime deferral boundary
- next implementation gate requirements

This document is planning-only.

It does not authorize coding.

---

## 2. Closure Position

The Legal Notice Static Registry is now defined as a controlled compliance subsystem.

The correct closure rule is:

Legal notices are not hardcoded screen text.  
Legal notices are not casual admin memo fields.  
Legal notices are not AI-generated production wording.  
Legal notices are not absolute immunity.  
Legal notices are controlled master data.  
Legal notices have versions, triggers, surfaces, locale, evidence, authority, review, retention, and audit.  
Legal notice display must match actual system behavior.  
Legal notice evidence must preserve historical truth.  
Legal notice activation must be governed by permission and risk.  
Legal notice runtime remains deferred until explicitly authorized.  

This registry is ready as architecture planning.

It is not ready as implementation.

---

## 3. Documents Closed In This Sequence

This closure covers the following documents:

| Document | Focus |
|---|---|
| `10716` | Legal notice master, toggle, disclosure, consent, compliance |
| `10717` | How master data is used and retrieved |
| `10718` | Static table specification planning |
| `10719` | Trigger matrix and UI surface mapping |
| `10720` | Privacy consent evidence and retention |
| `10721` | Alcohol age-gate and staff verification SOP |
| `10722` | Refund, cancellation, no-show, dispute evidence SOP |
| `10723` | i18n review and controlled translation |
| `10724` | Admin toggle, permission, HQ lock |
| `10725` | Static seed review and approval workflow |
| `10726` | Evidence export, support, dispute packet |
| `10727` | Customer display UX and popup fatigue control |
| `10728` | Emergency lock and regulatory change response |
| `10729` | Static registry closure and runtime deferral |

This sequence completes the legal notice planning axis for the current wave.

---

## 4. Registry Boundary

The Legal Notice Static Registry includes:

- notice identity
- notice family
- notice code
- notice risk class
- notice enforcement class
- legal basis reference
- notice version
- localized text
- text variant
- trigger rule
- UI surface mapping
- display mode
- display frequency
- acknowledgement requirement
- evidence requirement
- store toggle
- HQ lock
- platform lock
- variable interpolation
- review workflow
- seed approval
- support evidence
- export/masking
- emergency lock
- regulatory change case

The registry does not execute business actions.

---

## 5. What The Registry Is

The registry is:

| Registry Role | Meaning |
|---|---|
| Master data | Stores controlled notice identities and versions |
| Policy map | Maps notices to triggers and surfaces |
| Evidence anchor | Lets evidence reference exact notice version |
| Admin control surface | Allows controlled toggle and preview |
| Legal review queue | Routes high-risk text for approval |
| i18n governance unit | Controls translations and fallback |
| Support reference | Helps support reconstruct disputes |
| Compliance boundary | Separates mandatory and optional notice behavior |
| Runtime input | Provides future runtime configuration |
| Audit source | Creates traceable policy history |

The registry is foundational compliance infrastructure.

---

## 6. What The Registry Is Not

The registry is not:

- POS authority
- payment authority
- refund approval authority
- alcohol sale approval authority
- privacy law compliance by itself
- automatic immunity
- AI decision engine
- support decision engine
- customer punishment engine
- evidence mutation tool
- runtime deployment approval
- final legal advice
- replacement for legal review
- replacement for actual POS/payment behavior
- replacement for store SOP

Legal notices inform, warn, consent, and evidence.

They do not replace lawful operation.

---

## 7. Master Data Closure

Master data closure confirms:

1. Notice codes must be stable.
2. Notice families must be controlled.
3. Notice versions must be preserved.
4. Deprecated notices must remain historically readable.
5. Approved notice text must not be overwritten.
6. Store-specific values must use variables.
7. High-risk notice wording must be reviewed.
8. AI-generated wording must remain draft until approved.
9. Seeded notices are not production-approved automatically.
10. Historical evidence must reference exact version.

Master data is closed as planning.

---

## 8. Trigger And Surface Closure

Trigger and surface closure confirms:

1. A notice must appear because a defined trigger matched.
2. Trigger rules must be deterministic.
3. UI surface must match risk timing.
4. High-risk notice must appear before risky action.
5. Low-risk notice may be legal-center or inline.
6. Popup fatigue must be controlled.
7. Missing mapping must create warning or block depending risk.
8. Trigger conflict resolution must be deterministic.
9. Trigger and surface changes must be audited.
10. AI may recommend triggers but not activate high-risk mapping.

Trigger and surface design is closed as planning.

---

## 9. Privacy Consent Closure

Privacy consent closure confirms:

1. Required and optional consent must be separated.
2. Marketing consent must not block core service.
3. Channel consent must be granular.
4. Location consent must be feature-scoped.
5. Third-party provision must be specific.
6. Consent evidence must reference exact version.
7. Withdrawal must be recorded.
8. Withdrawal does not erase historical consent evidence.
9. Consent evidence is privacy-sensitive.
10. Unknown consent must not be treated as accepted.

Privacy consent design is closed as planning.

---

## 10. Alcohol Notice Closure

Alcohol notice closure confirms:

1. Alcohol is not ordinary beverage.
2. Alcohol item classification must be explicit.
3. Alcohol set menu inherits alcohol restriction.
4. Customer adult confirmation is required where applicable.
5. Staff ID verification may be required.
6. Alcohol delivery is disabled by default unless separately approved.
7. Unknown alcohol state must fail closed.
8. Staff verification evidence must avoid unnecessary raw ID storage.
9. AI may detect alcohol but cannot approve alcohol sale.
10. POS/KDS/payment must preserve alcohol state.

Alcohol notice design is closed as planning.

---

## 11. Refund Cancellation No-Show Closure

Refund/no-show closure confirms:

1. Refund policy must follow actual order state.
2. Refund notice must appear before irreversible point.
3. KDS state matters.
4. Payment provider state matters.
5. Sold-out is not customer cancellation.
6. Substitution requires customer consent.
7. Deposit/no-show penalty requires clear notice and timing evidence.
8. Market-price confirmation must be explicit.
9. AI cannot approve refund or penalty.
10. Historical refund evidence must not be rewritten.

Refund/no-show design is closed as planning.

---

## 12. i18n Closure

i18n closure confirms:

1. Legal notice translation is not ordinary UI translation.
2. Machine translation is draft only.
3. Korean controlling text may govern where policy requires.
4. High-risk translations require review.
5. Missing high-risk translation must not suppress notice.
6. Locale shown must be recorded.
7. Text hash should be preserved for critical evidence.
8. Store variables must be interpolated safely.
9. Translation changes must not rewrite history.
10. AI cannot approve legal translation.

i18n design is closed as planning.

---

## 13. Admin Toggle And HQ Lock Closure

Admin/HQ closure confirms:

1. Toggle is governance action.
2. Store owners may configure approved optional notices.
3. Store managers have limited authority.
4. Sales representatives may assist but not approve high-risk notices.
5. Support may view evidence but not edit settings.
6. HQ may lock notices within tenant/franchise scope.
7. Platform may lock mandatory notices globally.
8. High-risk toggle requires review.
9. Variable values require validation.
10. Toggle history must remain readable.

Admin/HQ design is closed as planning.

---

## 14. Seed Review Closure

Seed review closure confirms:

1. Static seed is not production approval.
2. Each notice requires code, family, risk, text, trigger, surface, evidence, i18n, and review state.
3. High-risk notice requires stronger review.
4. Customer display approval is stronger than master approval.
5. Store-toggle approval is separate.
6. Rejected notices remain auditable but unusable.
7. Deprecated notices remain historically readable.
8. Material changes require review.
9. Batch approval cannot hide individual high-risk gaps.
10. AI cannot approve seed notices.

Seed review design is closed as planning.

---

## 15. Evidence Export Closure

Evidence export closure confirms:

1. Dispute packets must reconstruct historical facts.
2. Current notice text is not historical proof.
3. Evidence export requires purpose.
4. Evidence export requires authority.
5. Masking must apply by default.
6. Support access is case-scoped.
7. Store owner access is store-scoped.
8. HQ access is tenant/franchise-scoped.
9. Legal hold must suspend deletion/anonymization where required.
10. Missing evidence must be surfaced as a compliance gap.

Evidence export design is closed as planning.

---

## 16. Customer UX Closure

Customer UX closure confirms:

1. High-risk notices must be visible at point of risk.
2. Low-risk notices should not interrupt ordering.
3. Required consent must be clear.
4. Optional consent must not be disguised as required.
5. Popup fatigue weakens comprehension.
6. Legal notice center is reference, not replacement for required popups.
7. Accessibility matters.
8. Multilingual clarity matters.
9. Notice tone must preserve customer trust.
10. Meaningful acknowledgement requires visible text.

Customer UX design is closed as planning.

---

## 17. Emergency Lock Closure

Emergency lock closure confirms:

1. Unsafe notices must be suspendable.
2. Mandatory notices may be forced ON.
3. Unsafe translations may be suspended.
4. Critical features may be blocked when notice cannot be safely shown.
5. Evidence capture failure must create incident.
6. Missing evidence must not be fabricated.
7. Regulatory change requires controlled review and rollout.
8. Emergency action must be scoped and audited.
9. Support guidance must be updated.
10. Emergency lock is not an uncontrolled superuser shortcut.

Emergency response design is closed as planning.

---

## 18. Cross-System Relationships

Legal notice registry relates to:

| System | Relationship |
|---|---|
| Menu intake | AI menu classification recommends notices |
| Menu builder | Options/sets/courses can trigger notices |
| POS | Payment/order state must match notice claims |
| KDS | Kitchen state affects cancellation/refund notices |
| Payment | Payment/refund notices require provider-backed state |
| Wallet/coupon | Benefits require clear terms and reversal evidence |
| Privacy | Consent evidence and withdrawal |
| Alcohol | Adult confirmation and staff verification |
| Support | Dispute packets and evidence |
| Admin | Toggle, preview, review |
| HQ | Franchise locks and compliance view |
| i18n | Controlled translation |
| Audit | All changes and evidence references |
| Incident | Emergency lock and regulatory change response |

Legal notice registry is a cross-room compliance beam.

---

## 19. Non-Authority Boundary

The following remain true:

- Notice displayed != customer legally bound in all situations.
- Notice acknowledged != dispute automatically resolved.
- Evidence captured != refund automatically denied.
- Store toggle ON != legal validity.
- AI recommendation != legal approval.
- Translation exists != reviewed translation.
- Footer link != required consent.
- Support view != mutation authority.
- Emergency lock != final resolution.
- Seeded data != approved runtime.

Legal notice is evidence and disclosure, not absolute authority.

---

## 20. Runtime Deferral Boundary

The following are not authorized by this closure:

- database table creation
- seed insertion
- SQL migration
- RLS implementation
- RPC implementation
- trigger engine implementation
- admin toggle UI
- customer popup UI
- legal notice center UI
- privacy consent runtime
- alcohol age-gate runtime
- refund/no-show runtime
- evidence packet runtime
- support console runtime
- i18n runtime
- emergency lock runtime
- production deployment

All runtime remains deferred.

---

## 21. Future Runtime Entry Requirements

Before any runtime implementation, the following must exist:

1. Explicit implementation authorization packet.
2. Narrow runtime scope.
3. Table list approved.
4. Field list approved.
5. RLS/tenant isolation plan.
6. Audit event plan.
7. i18n key plan.
8. Seed review state plan.
9. Admin permission plan.
10. Evidence retention plan.
11. Support access plan.
12. Rollback plan.
13. Test checklist.
14. Legal review note for high-risk families.
15. Confirmation that implementation does not exceed approved scope.

No broad implementation is allowed from this document.

---

## 22. Candidate Next Static Documents

If the planning package continues, possible next static documents are:

| Candidate | Purpose |
|---|---|
| `10730 Legal Notice Evidence Packet Static Field Map Policy` | Field-level packet map |
| `10731 Customer Notice Center UX Static Surface Index Policy` | Notice center surface inventory |
| `10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy` | Regulatory watch queue |
| `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy` | Store onboarding checklist |
| `10734 Legal Notice Support Playbook And Case Reason Code Policy` | Support playbook |
| `10735 Legal Notice Static Registry Readiness Check Policy` | Readiness review |
| `10736 Legal Notice Implementation Authorization Draft Policy` | Future coding authorization draft |

These are not automatically authorized.

---

## 23. Static Registry Readiness Check

The legal notice registry is considered planning-complete if:

| Check | Status |
|---|---|
| Notice master concept | Defined |
| Notice usage flow | Defined |
| Table static spec | Defined |
| Trigger/surface mapping | Defined |
| Privacy consent evidence | Defined |
| Alcohol SOP | Defined |
| Refund/no-show SOP | Defined |
| i18n review | Defined |
| Admin toggle/HQ lock | Defined |
| Seed approval workflow | Defined |
| Evidence export/dispute packet | Defined |
| Customer UX/popup fatigue | Defined |
| Emergency lock/regulatory change | Defined |
| Runtime authorization | Deferred |

This sequence is ready for archival as static planning.

---

## 24. Audit Closure Events

Recommended closure audit events:

| Event Type | Meaning |
|---|---|
| `LEGAL_NOTICE_PLANNING_SEQUENCE_CLOSED` | Planning sequence closed |
| `LEGAL_NOTICE_STATIC_REGISTRY_READY_FOR_REVIEW` | Static registry ready for review |
| `LEGAL_NOTICE_RUNTIME_DEFERRED` | Runtime explicitly deferred |
| `LEGAL_NOTICE_IMPLEMENTATION_GATE_REQUIRED` | Implementation requires separate gate |
| `LEGAL_NOTICE_NEXT_STATIC_DOC_IDENTIFIED` | Next static doc candidate recorded |

These are planning audit concepts only.

---

## 25. Anti-Patterns

Avoid:

- treating closure as coding approval
- moving directly to SQL without authorization
- seeding 200 notices without review state
- hardcoding legal text after registry design
- implementing popup runtime before surface mapping approval
- implementing consent runtime without retention policy
- implementing alcohol flow without legal review
- implementing refund policy without payment/KDS integration review
- implementing i18n without controlled translation review
- implementing support export without masking policy
- implementing emergency lock without authority model
- deleting planning caveats
- claiming legal immunity from notice registry
- using AI to bypass legal review

These anti-patterns must remain prohibited.

---

## 26. Validation Checklist

Validation must confirm:

1. Closed document sequence is listed.
2. Registry boundary is defined.
3. What the registry is is defined.
4. What the registry is not is defined.
5. Master data closure is defined.
6. Trigger and surface closure is defined.
7. Privacy consent closure is defined.
8. Alcohol notice closure is defined.
9. Refund/cancellation/no-show closure is defined.
10. i18n closure is defined.
11. Admin toggle and HQ lock closure is defined.
12. Seed review closure is defined.
13. Evidence export closure is defined.
14. Customer UX closure is defined.
15. Emergency lock closure is defined.
16. Cross-system relationships are defined.
17. Non-authority boundary is defined.
18. Runtime deferral boundary is defined.
19. Future runtime entry requirements are defined.
20. Candidate next static documents are listed.
21. Static registry readiness check is defined.
22. Audit closure events are defined.
23. Anti-patterns are listed.
24. Coding remains unauthorized.
25. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document closes and supplements:

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

It also references:

- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 28. Final Rule

The Catch Menu Legal Notice Static Registry planning package is closed for the current wave.

The registry defines how legal notices are stored, versioned, translated, triggered, displayed, acknowledged, toggled, locked, reviewed, exported, and emergency-controlled.

The registry also defines its limits.

Legal notice planning does not create automatic legal immunity.

Legal notice master data does not replace lawful business operation.

Legal notice evidence does not replace fair dispute review.

AI may assist classification, drafting, translation suggestions, and risk detection.

AI cannot approve legal text, activate notices, enforce penalties, approve refunds, approve alcohol sales, mutate evidence, or release emergency locks.

All runtime implementation remains deferred until a separate explicit authorization packet is approved.
