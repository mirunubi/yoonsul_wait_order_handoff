# 004306_Policy_Major_POS_API_Discovery_And_Technical_Spike.md

## 1. Purpose

This document defines the Major POS API Discovery and Technical Spike policy.

The purpose of this policy is to define how the system investigates, verifies, and tests API availability, event quality, credential scope, data structure, and integration feasibility for OKPOS and other major POS providers before formal adapter development begins.

Major POS integration must not begin from assumptions.

The system must first discover what the provider actually supports, what requires contract approval, what is technically available, what is store-specific, and what must remain overlay or manual fallback.

---

## 2. Scope

This policy applies to:

* OKPOS API discovery
* Major POS provider API research
* POS vendor technical contact
* POS partner API review
* POS webhook availability review
* POS polling availability review
* POS order payload sample collection
* POS payment status sample collection
* POS menu and item structure review
* POS table reference review
* POS KDS handoff review
* POS credential scope review
* POS technical spike
* POS pilot feasibility review

This policy does not define final vendor contracts, production adapter implementation, final database schema, commercial terms, refund execution, settlement allocation, or legal partnership terms.

---

## 3. Core Principle

A major POS provider must pass discovery before adapter commitment.

The system must not assume:

```text
the POS has an API
the API is accessible to third parties
the API includes payment status
the API includes KDS state
the API supports webhook
the API supports store-level authorization
the API supports safe write-back
the provider will cooperate
```

The core rule is:

```text
discover first
spike second
pilot third
certify later
```

---

## 4. Discovery Outcome Types

Each POS provider discovery effort must result in one of the following outcomes:

```text
API_CONFIRMED
PARTNER_API_CONFIRMED
WEBHOOK_CONFIRMED
POLLING_ONLY_CONFIRMED
EXPORT_ONLY_CONFIRMED
MANUAL_OR_OVERLAY_ONLY
VENDOR_CONTACT_REQUIRED
STORE_AUTHORIZATION_REQUIRED
CONTRACT_REQUIRED
TECHNICAL_SPIKE_REQUIRED
BLOCKED
DEFERRED
```

Unknown must remain unknown.

Unknown must not be treated as supported.

---

## 5. Provider Discovery Record

Each provider discovery must create a provider discovery record.

Required conceptual fields:

```text
discovery_id
provider_name
provider_type
target_market
research_owner
discovery_status
documentation_reference
vendor_contact_status
store_contact_status
API_availability
webhook_availability
polling_availability
test_environment_status
credential_path_status
known_limitations
next_action
created_at
updated_at
```

Discovery records must be auditable.

---

## 6. API Availability Review

API availability must be classified as:

```text
PUBLIC_API_AVAILABLE
PARTNER_API_AVAILABLE
PRIVATE_API_BY_CONTRACT
STORE_AUTHORIZED_API
VENDOR_INTERNAL_ONLY
NO_API_CONFIRMED
UNKNOWN
```

If the API is partner-only or contract-only, the provider must be marked:

```text
BUSINESS_CONTACT_REQUIRED
```

or:

```text
CONTRACT_REQUIRED
```

Technical planning must not assume production access until the access path is confirmed.

---

## 7. Documentation Review Checklist

The discovery process should attempt to collect or verify:

```text
API documentation
webhook documentation
authentication documentation
authorization model
sandbox documentation
payload examples
event type list
rate limit policy
error code reference
order API description
payment API description
menu API description
table API description
KDS API description
cancellation and void description
support contact
```

If documentation is unavailable, the spike may proceed only with clearly marked uncertainty.

---

## 8. Vendor Contact Checklist

When vendor contact is required, the communication should clarify:

```text
whether third-party integration is allowed
whether store authorization is enough
whether corporate contract is required
whether order read API exists
whether payment status API exists
whether webhook exists
whether polling is allowed
whether KDS state is available
whether menu data is available
whether table data is available
whether test credentials can be issued
whether production credentials require review
whether integration fees apply
```

Vendor claim must be treated as evidence, not final technical proof.

---

## 9. Store Authorization Review

Some POS integrations may depend on store owner authorization.

The system must determine whether the provider allows:

```text
store-level API permission
merchant-level credential
terminal-level authorization
franchise HQ authorization
vendor-issued partner credential
no third-party store authorization
```

If store authorization is unclear, the provider must be marked:

```text
STORE_AUTHORIZATION_UNCERTAIN
```

---

## 10. Credential Path Review

Credential path must be reviewed before technical spike.

Credential types may include:

```text
API key
OAuth client
merchant token
store token
terminal credential
webhook secret
partner credential
file export credential
manual dashboard access
```

Credential scope must be classified by:

```text
tenant
store
terminal
provider account
read permission
write permission
payment permission
menu permission
refund permission
```

A broad credential must not be used without security review.

---

## 11. Order API Discovery

Order API discovery must answer:

```text
Can we read orders?
Can we receive order-created events?
Can we read order details?
Can we identify external_order_id?
Can we identify store and terminal?
Can we read item list?
Can we read modifiers?
Can we read discounts?
Can we read total amount?
Can we read order status?
Can we read order update time?
Can we read cancellation state?
```

If `external_order_id` is not available, the provider cannot be considered a strong order source.

---

## 12. Payment API Discovery

Payment API discovery must answer:

```text
Can we read payment status?
Can we distinguish pending, paid, failed, canceled, refunded?
Can we read paid amount?
Can we read payment method?
Can we read payment timestamp?
Can we read provider payment reference?
Can we detect partial payment?
Can we detect refund?
Can we detect payment cancellation?
Can payment status arrive through webhook?
```

If payment status is incomplete, KDS release must not depend on POS payment visibility alone.

---

## 13. Menu API Discovery

Menu API discovery must answer:

```text
Can we read menu item IDs?
Can we read item names?
Can we read modifier groups?
Can we read option IDs?
Can we read bundle or set structures?
Can we read sold-out status?
Can we read menu version?
Can we detect menu changes?
Can we map kitchen station?
```

If menu data is weak, unknown item and mapping-required states must be expected.

---

## 14. Table API Discovery

Table API discovery must answer:

```text
Can we read table ID?
Can we read table name?
Can we read floor or zone?
Can we detect table move?
Can we detect table merge?
Can we detect table split?
Can we identify seating session?
Can we identify party size?
```

If only table name is available, table certainty must be classified as low.

---

## 15. KDS API Discovery

KDS API discovery must answer:

```text
Does the POS have its own KDS?
Can we read KDS ticket status?
Can we create KDS ticket?
Can we receive KDS release event?
Can we detect kitchen hold?
Can we detect kitchen cancel?
Can we detect ready state?
Can we detect station routing?
Can we avoid duplicate KDS ticket creation?
```

If the POS already has its own KDS, ownership must be explicit:

```text
KDS_EXTERNAL_PRIMARY
KDS_INTERNAL_PRIMARY
KDS_DUAL_VISIBILITY
KDS_PROJECTION_ONLY
```

---

## 16. Webhook Discovery

Webhook discovery must answer:

```text
Which events are supported?
How is webhook registered?
How is webhook verified?
Is signature verification available?
Is duplicate delivery possible?
Is retry policy documented?
Is ordering guaranteed?
Is event timestamp included?
Is test webhook available?
Can webhook secret be rotated?
```

If webhook ordering is not guaranteed, chronology uncertainty must be handled.

---

## 17. Polling Discovery

If webhook is unavailable, polling must be reviewed.

Polling discovery must answer:

```text
Which endpoints can be polled?
What is the minimum polling interval?
What are rate limits?
Can we query by updated_at?
Can we query by order ID?
Can we backfill missed events?
Can we detect deleted or canceled orders?
How much delay is expected?
```

Polling-based integration must not be marketed as real-time without qualification.

---

## 18. Payload Sample Requirement

Before adapter design, the system should obtain or create payload samples.

Required sample types:

```text
normal order
order with modifier
order with discount
order with bundle
order with service charge or tax
paid order
unpaid order
canceled order
voided item
refunded order if available
table order
takeout order
delivery order if applicable
```

Payload samples should be stored as restricted test fixtures.

Sensitive identity must be masked before general use.

---

## 19. Technical Spike Definition

A technical spike is a limited experiment to prove integration feasibility.

A spike may test:

```text
authentication
order retrieval
webhook receipt
payload normalization
canonical order creation
payment status mapping
menu item mapping
table mapping
duplicate event handling
basic audit linkage
```

A spike is not production integration.

A spike must not be used in live store operation unless separately approved as shadow mode or pilot.

---

## 20. Technical Spike Exit Criteria

A technical spike may be considered successful when it proves:

```text
provider access path works
sample order can be received or retrieved
raw payload can be preserved
external order ID can be identified
order can be normalized
amount can be mapped
payment status can be mapped or flagged
item mapping can be attempted
diagnostic errors can be emitted
audit reference can be created
known limitations are documented
```

If the spike cannot prove these, the provider should remain deferred, blocked, or overlay-only.

---

## 21. Shadow Mode Recommendation

After a successful spike, the provider may enter shadow mode.

Shadow mode means:

```text
provider data is received
canonical projections are created
diagnostic errors are logged
audit records are created
but no KDS release or payment authority action is executed
```

Shadow mode is recommended before pilot activation.

---

## 22. Pilot Feasibility Review

Before pilot, the discovery result must answer:

```text
Which store can test it?
Which POS version is installed?
Which terminal/device is used?
Can the store authorize access?
Can staff report issues?
Can fallback be used?
Can we compare POS behavior with internal projection?
Can we observe peak-time flow?
```

Pilot must test real operational friction, not only API success.

---

## 23. Overlay Decision Rule

If API access is unavailable or too limited, the provider may be handled through overlay.

Overlay paths include:

```text
customer mobile order overlay
counter dynamic QR payment overlay
manual receipt reference
staff-confirmed POS order
separate internal KDS projection
manual reconciliation
```

Overlay must be marked as:

```text
OVERLAY_ORIGINATED
```

or:

```text
FALLBACK_ORIGINATED
```

where appropriate.

---

## 24. Blocked Provider Rule

A provider should be marked `BLOCKED` when:

```text
API is unavailable
vendor refuses third-party access
store authorization is impossible
credential path is unavailable
payload quality is unusable
security risk is unacceptable
payment status cannot be verified
pilot cannot be safely conducted
```

Blocked does not mean abandoned forever.

It means no production integration should proceed until conditions change.

---

## 25. Discovery Risk Classification

Discovery must classify provider risk.

Risk levels:

```text
LOW
MEDIUM
HIGH
BLOCKING
UNKNOWN
```

Risk categories:

```text
API access risk
vendor cooperation risk
credential risk
payload quality risk
payment status risk
KDS duplication risk
security risk
support risk
pilot risk
```

High-risk providers require narrower spike or overlay-only approach.

---

## 26. Diagnostic Code Mapping During Discovery

Discovery should map likely failure points to diagnostic codes.

Relevant examples:

```text
POSADP-CAP-003 provider capability unknown
POSADP-CAP-005 integration contract missing
POSADP-PROVIDER-005 provider permission denied
POSADP-PROVIDER-006 provider API version changed
POSADP-NORMALIZE-003 provider payload version unsupported
POSADP-MAP-001 unknown external item
POSADP-TABLE-002 table reference ambiguous
POSADP-PAY-002 payment status conflict
```

Early diagnostic mapping improves later adapter design.

---

## 27. Evidence Requirement

Each discovery effort must preserve evidence.

Evidence may include:

```text
documentation copy or reference
vendor response
support email
API sample
payload sample
credential scope note
spike result
mapping note
known limitation note
security review note
pilot feasibility note
decision record
```

Discovery evidence must be linked to provider onboarding records.

---

## 28. Decision Record

At the end of discovery, create a decision record.

Decision types include:

```text
PROCEED_TO_SPIKE
PROCEED_TO_SHADOW_MODE
PROCEED_TO_PILOT
OVERLAY_ONLY
VENDOR_CONTACT_REQUIRED
CONTRACT_REQUIRED
DEFERRED
BLOCKED
```

Decision record fields:

```text
decision_id
provider_name
decision_type
reason
evidence_reference
accepted_risks
required_next_action
approved_by
approved_at
review_date
```

---

## 29. MVP Cutline

For MVP, this policy should support:

```text
provider discovery record
API availability classification
documentation checklist
vendor contact checklist
credential path review
order API discovery
payment API discovery
menu API discovery
table API discovery
KDS API discovery
payload sample requirement
technical spike definition
technical spike exit criteria
overlay decision rule
blocked provider rule
decision record
```

Excluded from MVP:

```text
automated API documentation parser
automatic adapter generation
vendor portal
formal certification marketplace
full legal contract workflow
AI-powered provider scoring
enterprise procurement workflow
```

---

## 30. Relationship To Previous Documents

This document depends on:

```text
04340 POS Vendor Priority And Integration Roadmap Policy
04350 POS Adapter Test Harness And Certification Scenario Policy
04360 POS Provider Onboarding Evidence And Contract Checklist Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04430 OKPOS And Major POS Integration Candidate Policy
```

The relationship is:

```text
04430 = major POS candidate policy
04440 = API discovery and technical spike policy
```

04430 identifies major POS providers as strategic candidates.

04440 defines how their actual integration feasibility is discovered and tested.

---

## 31. Security Foundation Redirect

Sensitive identity protection, including CI/DI, phone number, email, provider customer identity, and identity vault policy, must be handled in the Foundation or Security Governance cluster.

It should not be owned by the POS provider-specific 044xx sequence.

The POS integration layer must still obey that foundation policy.

The correct relationship is:

```text
Foundation Security = identity and sensitive data protection
044xx POS Integration = provider discovery and integration feasibility
```

---

## 32. Patent And SaaS Relevance

This policy supports SaaS expansion because it prevents provider integration from becoming assumption-driven.

The strategic structure is:

```text
major POS candidate
        ↓
API discovery
        ↓
payload sample
        ↓
technical spike
        ↓
shadow mode
        ↓
pilot
        ↓
adapter certification
```

This allows the platform to pursue OKPOS and other major POS providers without overpromising unsupported capabilities.

The value is disciplined expansion into real POS environments.

---

## 33. Known Gaps To Track

The following gaps must remain visible per provider:

```text
actual API availability
actual partner access path
actual vendor cooperation
actual credential process
actual payload format
actual payment status reliability
actual KDS ownership model
actual table support
actual menu mapping quality
actual pilot store availability
actual support path
```

These gaps block production claims.

They do not block discovery.

---

## 34. Readiness Check

This policy is ready when:

```text
API availability is classified
documentation checklist exists
vendor contact checklist exists
credential path review exists
order API discovery is defined
payment API discovery is defined
menu API discovery is defined
table API discovery is defined
KDS API discovery is defined
payload sample requirement exists
technical spike is defined
spike exit criteria are defined
shadow mode is recommended
overlay decision rule exists
blocked provider rule exists
decision record is required
security identity policy is redirected to Foundation
```

---

## 35. Summary

Major POS integration must begin with discovery, not assumptions.

The system must determine:

```text
what the provider exposes
what the provider hides
what requires contract
what requires store authorization
what can be tested
what must remain overlay
what is too risky
```

Only after discovery and technical spike should adapter development proceed.

This keeps the POS federation project ambitious but controlled.
