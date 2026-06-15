# 21570_Policy_Financial_Grade_Security_Foundation_Control_Catalog_And_Bulkhead_Readiness

## 1. Purpose

This document converts the financial-grade security, submarine bulkhead, alert/logging, containment, quarantine, and pgvector observability requirements from `21560` into a Foundation control catalog and readiness policy.

The purpose is to ensure that security does not remain an architectural slogan.

Every security requirement must be converted into controlled Foundation controls before runtime coding begins.

The system must be able to answer:

- which security controls are mandatory
- which bulkhead protects which domain
- which events trigger containment
- which events trigger quarantine
- which alerts must be raised
- which logs must be preserved
- which evidence packets must be created
- which audit events are required
- which pgvector sources are allowed
- which AI/vector actions are prohibited
- which blockers prevent coding entry

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This policy applies to Foundation control catalog preparation for:

1. Financial-grade security baseline
2. Bulkhead compartment catalog
3. Containment state catalog
4. Quarantine state catalog
5. Infection prevention rules
6. Tokenization and secret isolation
7. External POS limited-trust boundary
8. Provider callback verification
9. Membership/value-bearing integration security
10. Wallet/prepaid balance security
11. Coupon/benefit security
12. Customer identity and consent security
13. KDS/order propagation security
14. Inventory/projection safety security
15. Support/admin restricted authority
16. AI authority boundary
17. pgvector approved source catalog
18. pgvector traceability metadata
19. Alert/log/evidence/audit linkage
20. Readiness blockers and validation gates

This document is Foundation-grade.

It applies across all runtime domains.

---

## 3. Core Principle

A Foundation security control is valid only if it is cataloged, testable, traceable, and enforceable by later implementation.

A security idea that is not represented as a control cannot protect the system.

A control must define:

- control id
- protected domain
- trigger condition
- required action
- alert requirement
- log requirement
- evidence requirement
- audit requirement
- containment/quarantine behavior
- pgvector eligibility
- review owner
- readiness blocker
- boundary test

Uncataloged security behavior is prohibited.

---

## 4. Foundation Security Control Record

Every Foundation security control must use a standard record structure.

| Field | Required Meaning |
|---|---|
| Control ID | Stable security control id |
| Control Family | Bulkhead, containment, quarantine, token, provider, AI, pgvector, etc. |
| Protected Domain | POS, payment, membership, KDS, projection, etc. |
| Trigger Event | Event family that activates control |
| Severity | Default severity |
| Required Action | Block, quarantine, contain, alert, review, reconcile |
| Alert Family | Related alert |
| Log Requirement | Structured log requirement |
| Evidence Requirement | Evidence packet requirement |
| Audit Requirement | Audit event requirement |
| pgvector Eligibility | Allowed, blocked, metadata-only |
| Authority Owner | Who can release/resolve |
| Review Requirement | Security, finance, legal, support, etc. |
| Readiness Blocker | Blocker if missing |
| Test Requirement | Boundary test/check |

A control without a test requirement is incomplete.

---

## 5. Security Control Family Catalog

Foundation must define security control families.

| Control Family | Meaning |
|---|---|
| `CONTROL_BULKHEAD` | Domain compartment isolation |
| `CONTROL_CONTAINMENT` | Automatic containment after high-risk event |
| `CONTROL_QUARANTINE` | Isolate untrusted event/data before processing |
| `CONTROL_TOKENIZATION` | Tokenize sensitive references |
| `CONTROL_SECRET_ISOLATION` | Prevent secret exposure |
| `CONTROL_PROVIDER_VERIFICATION` | Verify provider callbacks/capabilities |
| `CONTROL_IDEMPOTENCY` | Prevent duplicate effects |
| `CONTROL_RECONCILIATION` | Require mismatch review |
| `CONTROL_APPEND_ONLY` | Prevent silent mutation |
| `CONTROL_VISIBILITY_MASKING` | Restrict data visibility |
| `CONTROL_SUPPORT_AUTHORITY` | Restrict support/admin actions |
| `CONTROL_AI_BOUNDARY` | Prevent AI authority drift |
| `CONTROL_PGVECTOR_BOUNDARY` | Prevent vector authority/data leakage |
| `CONTROL_ALERT_ROUTING` | Route warnings correctly |
| `CONTROL_LOG_INTEGRITY` | Preserve structured/tamper-aware logs |
| `CONTROL_EVIDENCE_LINKAGE` | Attach evidence to risky actions |
| `CONTROL_AUDIT_LINKAGE` | Preserve accountability |
| `CONTROL_I18N_MESSAGE` | Prevent hardcoded warning text |
| `CONTROL_CUSTOMER_RECOVERY` | Route customer impact correctly |

---

## 6. Bulkhead Control Catalog

Every major runtime domain must have a bulkhead control.

| Bulkhead | Protected Domain | Default Rule |
|---|---|---|
| `BULKHEAD_POS` | External POS and POS module | Limited-trust, no financial authority |
| `BULKHEAD_PAYMENT` | Payment gateway and callback | Verify before mutation |
| `BULKHEAD_LEDGER` | Settlement ledger | Append-only, reconciliation required |
| `BULKHEAD_MEMBERSHIP` | Membership/points/benefits | No silent value mutation |
| `BULKHEAD_WALLET` | Wallet/prepaid value | Ledger-compatible, audited |
| `BULKHEAD_COUPON` | Coupon/promotion | Idempotent use required |
| `BULKHEAD_IDENTITY` | Customer identity/consent | Consent and audit required |
| `BULKHEAD_KDS` | Kitchen execution | Operational evidence only |
| `BULKHEAD_INVENTORY` | Inventory/availability | Source and timestamp required |
| `BULKHEAD_CONTENT_I18N` | Content/message registry | Key/source traceability required |
| `BULKHEAD_PROJECTION` | External projection | Projection only, not truth |
| `BULKHEAD_SUPPORT_ADMIN` | Support/admin authority | Evidence/audit required |
| `BULKHEAD_AI` | AI retrieval/output | Assistance only |
| `BULKHEAD_PGVECTOR` | Vector similarity memory | Review assist only |
| `BULKHEAD_PROVIDER` | External provider | Evidence-required by default |
| `BULKHEAD_TENANT` | SaaS tenant | Cross-tenant block required |
| `BULKHEAD_STORE` | Store boundary | Cross-store risk alert required |
| `BULKHEAD_AUDIT_EVIDENCE` | Audit/evidence integrity | Append-only/tamper-aware |

Each runtime package must declare its bulkhead before coding entry.

---

## 7. Containment Control Catalog

Containment controls define automatic blocking behavior.

| Control ID | Trigger | Required Action |
|---|---|---|
| `CTRL-CONTAIN-POS-CROSS-STORE` | POS cross-store event risk | Block propagation and alert security/support |
| `CTRL-CONTAIN-TENANT-BOUNDARY` | Cross-tenant risk | Block access and alert security |
| `CTRL-CONTAIN-PROVIDER-CALLBACK-FAILED` | Callback signature failed | Block mutation and quarantine callback |
| `CTRL-CONTAIN-TOKEN-SCOPE` | Token scope violation | Block token use and alert security |
| `CTRL-CONTAIN-WALLET-DUPLICATE` | Wallet duplicate value risk | Block value mutation |
| `CTRL-CONTAIN-COUPON-DUPLICATE` | Duplicate coupon use risk | Block duplicate benefit |
| `CTRL-CONTAIN-IDENTITY-WRONG` | Wrong account risk | Block identity merge/link |
| `CTRL-CONTAIN-LEDGER-IMBALANCE` | Ledger imbalance | Block finalization |
| `CTRL-CONTAIN-PROJECTION-ALLERGEN` | Allergen projection mismatch | Block projection/customer exposure |
| `CTRL-CONTAIN-AI-AUTHORITY` | AI authority overreach | Block AI output/action |
| `CTRL-CONTAIN-PGVECTOR-RESTRICTED` | Restricted vector source/retrieval | Block vectorization/retrieval |
| `CTRL-CONTAIN-SUPPORT-UNAUTH` | Unauthorized support mutation | Block action and alert audit/security |

Containment is not resolution.

Containment must create alert/log/evidence/audit where required.

---

## 8. Quarantine Control Catalog

Quarantine controls isolate suspicious events/data before processing.

| Control ID | Trigger | Quarantine Target |
|---|---|---|
| `CTRL-QUAR-PROVIDER-CALLBACK-UNVERIFIED` | Unverified provider callback | Provider callback payload |
| `CTRL-QUAR-POS-MALFORMED` | Malformed POS event | POS event |
| `CTRL-QUAR-DUP-PAYLOAD-MISMATCH` | Duplicate key with different payload | Duplicate event |
| `CTRL-QUAR-MEMBERSHIP-CONFLICT` | Identity/point conflict | Membership event |
| `CTRL-QUAR-WALLET-MISMATCH` | Wallet balance mismatch | Wallet event |
| `CTRL-QUAR-COUPON-DUPLICATE` | Duplicate coupon use | Coupon event |
| `CTRL-QUAR-KDS-DUPLICATE` | Duplicate ticket risk | KDS event |
| `CTRL-QUAR-PROJECTION-MISMATCH` | Price/allergen/translation mismatch | Projection event |
| `CTRL-QUAR-AI-RESTRICTED-SOURCE` | AI restricted source request | AI retrieval request |
| `CTRL-QUAR-PGVECTOR-UNAPPROVED` | Unapproved vector source | Vector ingestion item |
| `CTRL-QUAR-SUPPORT-EXPORT` | Restricted export request | Export request |
| `CTRL-QUAR-PROVIDER-CAPABILITY` | Provider capability asserted without evidence | Capability assertion |

Quarantined objects must remain reviewable.

They must not be silently dropped.

---

## 9. Infection Prevention Control Catalog

Infection prevention controls block bad state propagation.

| Control ID | Infection Risk | Prevention Rule |
|---|---|---|
| `CTRL-INFECT-POS-TO-PAYMENT` | POS event mutates payment truth | Payment requires verified payment contract |
| `CTRL-INFECT-CALLBACK-TO-LEDGER` | Unverified callback mutates ledger | Callback verification required |
| `CTRL-INFECT-PROJECTION-TO-MENU` | Partner projection overwrites menu | Internal content registry remains source |
| `CTRL-INFECT-AI-TO-EVIDENCE` | AI summary becomes original evidence | AI summary marked derived only |
| `CTRL-INFECT-AI-TO-PROVIDER` | AI confirms provider capability | Provider evidence required |
| `CTRL-INFECT-KDS-TO-PAYMENT` | KDS completion implies payment success | Payment separate from KDS |
| `CTRL-INFECT-SUPPORT-TO-LEDGER` | Support note mutates ledger | Ledger correction requires authority |
| `CTRL-INFECT-MEMBERSHIP-TO-WALLET` | Membership error mutates wallet | Wallet ledger separate |
| `CTRL-INFECT-IDENTITY-CROSS-CUSTOMER` | Wrong identity changes account | Consent/review required |
| `CTRL-INFECT-STORE-CROSS-TENANT` | Store event crosses tenant | Tenant boundary block |

Infection prevention controls must be validated by boundary tests.

---

## 10. Tokenization Control Catalog

Tokenization controls must define token use.

| Control ID | Token Family | Required Control |
|---|---|---|
| `CTRL-TOKEN-PAYMENT-REF` | Payment reference token | Scoped and short-lived |
| `CTRL-TOKEN-CUSTOMER-SESSION` | Customer/session token | Consent/identity boundary |
| `CTRL-TOKEN-PROVIDER-SESSION` | Provider session token | Backend-owned, not POS-resolved |
| `CTRL-TOKEN-ORDER-PAYMENT` | Order-payment link token | Display-safe only |
| `CTRL-TOKEN-REFUND` | Refund reference token | Authority-controlled |
| `CTRL-TOKEN-SETTLEMENT` | Settlement reference token | Ledger authority only |
| `CTRL-TOKEN-PROJECTION` | Projection token | Public-safe scope only |
| `CTRL-TOKEN-MEMBERSHIP` | Membership reference token | No raw identity exposure |
| `CTRL-TOKEN-WALLET` | Wallet reference token | Value-bearing, restricted |
| `CTRL-TOKEN-SUPPORT` | Support case token | Visibility-controlled |

Token records must define scope, lifetime, audience, replay policy, revocation, and audit linkage.

---

## 11. Secret Isolation Control Catalog

Secret isolation controls prohibit credential leakage.

| Control ID | Secret Risk | Required Control |
|---|---|---|
| `CTRL-SECRET-PROVIDER-API` | Provider API key exposure | Secret storage only |
| `CTRL-SECRET-WEBHOOK` | Webhook secret exposure | Never in logs/docs |
| `CTRL-SECRET-SERVICE-ROLE` | Service role key exposure | Server-only boundary |
| `CTRL-SECRET-DB` | Database credential exposure | No docs/test fixtures |
| `CTRL-SECRET-OAUTH` | OAuth client secret exposure | Secure config only |
| `CTRL-SECRET-POS-LOCAL` | Secret stored in POS | Prohibited |
| `CTRL-SECRET-AI-PROMPT` | Secret included in AI prompt | Prohibited |
| `CTRL-SECRET-PGVECTOR` | Secret vectorized | Prohibited |
| `CTRL-SECRET-SCREENSHOT` | Secret visible in screenshot | Block/redact |
| `CTRL-SECRET-SUPPORT-NOTE` | Secret pasted into note | Block/redact |

No secret-like value may appear in Foundation catalogs, docs, examples, prompts, tests, logs, or vectors.

---

## 12. Provider Verification Control Catalog

Provider controls must enforce evidence-required defaults.

| Control ID | Provider Risk | Required Control |
|---|---|---|
| `CTRL-PROVIDER-CALLBACK-SIGNATURE` | Callback spoofing | Signature verification |
| `CTRL-PROVIDER-CALLBACK-REPLAY` | Callback replay | Replay protection |
| `CTRL-PROVIDER-CAPABILITY-CLAIM` | Unsupported capability | Evidence-required default |
| `CTRL-PROVIDER-SETTLEMENT-REPORT` | Missing settlement report | Evidence and reconciliation |
| `CTRL-PROVIDER-API-CHANGE` | Contract drift | Provider review alert |
| `CTRL-PROVIDER-REFUND-MISMATCH` | Refund state mismatch | Reconciliation |
| `CTRL-PROVIDER-RATE-LIMIT` | Rate limit impact | Degraded/retry policy |
| `CTRL-PROVIDER-PARTNER-SYNC` | Partner sync stale | Alert and projection block if risky |
| `CTRL-PROVIDER-GLOBAL-PAYMENT` | Overseas payment uncertainty | Provider evidence required |
| `CTRL-PROVIDER-REDTABLE-TYPE` | Redtable-type capability uncertainty | Capability-by-capability evidence |

No provider capability may default to confirmed.

---

## 13. pgvector Control Catalog

pgvector controls must prevent vector memory from becoming authority or leaking data.

| Control ID | Risk | Required Control |
|---|---|---|
| `CTRL-PGVECTOR-SOURCE-APPROVED` | Unapproved source vectorized | Approved source catalog required |
| `CTRL-PGVECTOR-TRACEABILITY` | Vector lacks source trace | Source metadata required |
| `CTRL-PGVECTOR-RESTRICTED-DATA` | Restricted data vectorized | Block/redact |
| `CTRL-PGVECTOR-CROSS-TENANT` | Cross-tenant retrieval | Tenant boundary required |
| `CTRL-PGVECTOR-CROSS-STORE` | Cross-store leakage | Store visibility rule |
| `CTRL-PGVECTOR-WRONG-LOCALE` | Wrong locale retrieval | Locale metadata required |
| `CTRL-PGVECTOR-WRONG-AUDIENCE` | Wrong audience retrieval | Audience metadata required |
| `CTRL-PGVECTOR-STALE` | Stale vector used | Refresh/delete rule |
| `CTRL-PGVECTOR-AUTHORITY-MISUSE` | Similarity treated as truth | Output boundary label |
| `CTRL-PGVECTOR-DELETE` | Source deletion not reflected | Deletion/refresh rule |

pgvector is observability and review assistance only.

---

## 14. AI Boundary Control Catalog

AI controls must prevent AI from gaining authority.

| Control ID | Risk | Required Control |
|---|---|---|
| `CTRL-AI-RESTRICTED-SOURCE` | AI accesses restricted source | Source class block |
| `CTRL-AI-UNTRACEABLE` | AI output lacks traceability | Traceability required |
| `CTRL-AI-CUSTOMER-UNAPPROVED` | Customer response unapproved | Human approval required |
| `CTRL-AI-FINANCIAL-AUTHORITY` | AI approves/executes money action | Prohibited |
| `CTRL-AI-IDENTITY-AUTHORITY` | AI links identity | Prohibited |
| `CTRL-AI-PROVIDER-INVENTION` | AI invents provider capability | Provider evidence required |
| `CTRL-AI-EVIDENCE-MISUSE` | AI summary treated as original | Derived evidence only |
| `CTRL-AI-PROJECTION-PUBLISH` | AI publishes projection | Prohibited |
| `CTRL-AI-CONTAINMENT-RELEASE` | AI releases containment | Prohibited |
| `CTRL-AI-ALERT-RESOLUTION` | AI resolves alert | Prohibited |

AI may draft, summarize, retrieve, and suggest only under review boundaries.

---

## 15. Alert Log Evidence Audit Control Catalog

Alert/log/evidence/audit controls must link all high-risk signals.

| Control ID | Requirement | Required Control |
|---|---|---|
| `CTRL-LOG-STRUCTURED` | Structured log required | Controlled fields |
| `CTRL-LOG-APPEND-ONLY` | Log integrity required | No silent edit |
| `CTRL-LOG-CORRELATION` | Cross-system correlation | Correlation id |
| `CTRL-ALERT-SEVERITY` | Alert severity required | Severity catalog |
| `CTRL-ALERT-ROUTING` | Route required | Routing catalog |
| `CTRL-ALERT-ACK` | Acknowledgement rule required | Ack catalog |
| `CTRL-ALERT-RESOLUTION` | Resolution rule required | Resolution catalog |
| `CTRL-EVIDENCE-LINK` | Evidence required | Evidence packet |
| `CTRL-AUDIT-LINK` | Audit required | Audit event |
| `CTRL-I18N-ALERT-MESSAGE` | Alert text visible | Message key required |

Every high-risk control must define which of these apply.

---

## 16. Security Control Readiness Matrix

Before runtime coding entry, each package must complete this matrix.

| Readiness Field | Required Answer |
|---|---|
| Package ID | Which package |
| Bulkhead | Which compartment |
| Source of truth | Declared source |
| External input | External input classes |
| Trust level | Trusted, limited-trust, untrusted, evidence-only |
| Tokenization | Required or not |
| Secret exposure risk | Present or absent |
| Containment trigger | Defined or not |
| Quarantine trigger | Defined or not |
| Alert family | Defined or not |
| Log fields | Defined or not |
| Evidence packet | Required or not |
| Audit event | Required or not |
| pgvector source | Allowed or blocked |
| AI boundary | Defined or not |
| Reconciliation rule | Required or not |
| Idempotency rule | Required or not |
| Security blocker | Open or closed |
| Boundary tests | Defined or not |

Any missing required answer blocks coding.

---

## 17. Package Security Classification

Every future implementation package must declare a security class.

| Security Class | Meaning |
|---|---|
| `SECURITY_CLASS_LOW_INTERNAL` | Internal low-risk catalog/helper |
| `SECURITY_CLASS_VISIBLE_TEXT` | Human-visible message/content |
| `SECURITY_CLASS_EXTERNAL_INPUT` | Accepts external input |
| `SECURITY_CLASS_PROVIDER_INPUT` | Accepts provider callback/data |
| `SECURITY_CLASS_VALUE_BEARING` | Affects money, points, coupon, wallet |
| `SECURITY_CLASS_IDENTITY_BEARING` | Affects identity/consent |
| `SECURITY_CLASS_SUPPORT_AUTHORITY` | Affects support/admin actions |
| `SECURITY_CLASS_FINANCIAL_LEDGER` | Affects ledger/settlement |
| `SECURITY_CLASS_AI_VECTOR` | Uses AI/pgvector |
| `SECURITY_CLASS_CROSS_TENANT` | Potential tenant boundary risk |
| `SECURITY_CLASS_CRITICAL` | Critical security/financial/legal risk |

Higher security classes require stricter entry gates.

---

## 18. Foundation Readiness Gate

A package may not enter runtime coding unless all required security controls are mapped.

Minimum Foundation readiness gate:

1. security class declared
2. bulkhead declared
3. source of truth declared
4. external input classified
5. tokenization rule defined if sensitive
6. secret exposure rule defined
7. containment trigger defined for high-risk events
8. quarantine trigger defined for untrusted events
9. alert family defined
10. structured log fields defined
11. evidence/audit mapping defined
12. pgvector eligibility defined
13. AI boundary defined if AI involved
14. reconciliation/idempotency rule defined if state-changing
15. i18n message keys defined for visible alerts
16. readiness blockers resolved or deferred with explicit approval
17. boundary tests defined

If any required gate is missing, coding remains deferred.

---

## 19. Validation Checklist

Security control validation must check:

- every control has an id
- every control has a protected domain
- every control has a trigger
- every high-risk trigger has containment or quarantine
- every containment has alert/log/evidence/audit mapping
- every quarantine has review/release rule
- every pgvector source is approved
- every vector item requires traceability
- every AI output state is non-authoritative
- every provider capability defaults to evidence-required
- every token has scope/lifetime/revocation
- every secret risk is blocked
- every value-bearing event has idempotency
- every mismatch has reconciliation
- every visible alert has i18n keys
- every package has boundary tests

Validation failure blocks coding entry.

---

## 20. Boundary Test Catalog Additions

Future tests/checks should include:

- package security class exists
- bulkhead exists for package
- source of truth is declared
- external input is classified
- high-risk event maps to containment
- unverified input maps to quarantine
- containment does not mark resolution
- quarantine release requires authority
- pgvector source is approved
- vector traceability fields exist
- restricted data vectorization is blocked
- AI cannot resolve alert or release containment
- provider callback cannot mutate before verification
- token scope violation blocks use
- secret-like strings are rejected
- visible alert has message key
- value-bearing event has idempotency
- mismatch creates reconciliation path
- security blocker prevents coding-ready status

These tests are planning requirements until implementation approval.

---

## 21. Relationship To Previous Documents

This document follows:

- `21560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`

It operationalizes Foundation control requirements from:

- `22490 External POS Third-Party Financial Security Ledger And Settlement Isolation Reinforcement Policy`
- `21500 Financial Security Ledger Foundation Catalog And Status Value Addendum Policy`
- `21510 Financial Event Alert Logging And Automated Warning System Policy`
- `21520 Universal Integration Event Alert Logging And Evidence Policy`
- `21530 Universal Integration Event Catalog And Alert Family Index Policy`
- `21540 Universal Integration Reconciliation And Idempotency Catalog Policy`
- `21550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`

This document is Foundation-grade.

It does not authorize coding.

---

## 22. Final Rule

Financial-company-grade security must be expressed as Foundation controls before runtime coding begins.

Every integration package must declare its security class, bulkhead, source of truth, external input trust level, tokenization need, containment trigger, quarantine trigger, alert/log/evidence/audit mapping, pgvector eligibility, AI boundary, reconciliation/idempotency rule, readiness blocker, and boundary tests.

The system must behave like a submarine with watertight bulkheads.

If one domain is compromised or uncertain, the system must automatically contain, quarantine, alert, log, preserve evidence, create audit, and block dangerous propagation.

pgvector must be embedded for observability and anomaly review, but it must never become source of truth or execution authority.

Coding remains deferred until these Foundation security controls are cataloged, validated, and approved through package-specific entry gates.
