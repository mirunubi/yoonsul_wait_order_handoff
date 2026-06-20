# 004430_Policy_OKPOS_And_Major_POS_Integration_Candidate

## **1\. Purpose**

This document defines the OKPOS and major POS integration candidate policy.

The purpose of this policy is to evaluate OKPOS and other large POS providers as strategic integration candidates for the POS federation platform.

The system must not assume that a major POS provider can immediately support full authority-level integration.

Each major POS provider must be evaluated through API availability, event quality, payment status quality, table support, menu mapping quality, KDS relevance, vendor cooperation, store adoption value, and fallback feasibility.

---

## **2\. Scope**

This policy applies to:

* OKPOS integration candidate review
* Major restaurant POS provider review
* Cloud POS candidate review
* VAN-linked POS candidate review
* franchise POS candidate review
* legacy POS candidate review
* POS order intake capability
* POS payment status capability
* POS cancellation and void capability
* POS table reference capability
* POS menu mapping capability
* POS-to-KDS relevance
* store pilot readiness
* vendor contact and API discovery

This policy does not define final vendor contract terms, commercial partnership terms, final API schema, production adapter code, refund execution, settlement allocation, or tax reporting.

---

## **3\. Core Principle**

Major POS integration is strategically necessary, but authority must be earned.

The system should treat OKPOS and other major POS providers as high-priority integration candidates because they may unlock many real stores.

However, the integration must begin with controlled capability levels.

The core rule is:

major POS market reach ≠ full integration readiness
vendor popularity ≠ API authority
POS visibility ≠ payment authority
POS order intake ≠ KDS release authority

Major POS providers should be pursued aggressively but integrated carefully.

---

## **4\. Strategic Rationale**

Major POS providers are strategically important because:

many restaurants already use them
owners resist replacing existing POS
POS contains order and payment context
POS may already connect to VAN, PG, printer, KDS, or kitchen devices
franchise stores often standardize around POS environments
store adoption becomes easier when existing POS can remain

The strategic message is:

Keep your existing POS.
We connect around it, normalize events, automate payment-to-kitchen flow, and diagnose failures.

---

## **5\. OKPOS Candidate Role**

OKPOS should be treated as a major POS integration candidate.

Possible roles include:

POS\_PROVIDER
ORDER\_SOURCE\_PROVIDER
PAYMENT\_STATUS\_SOURCE
TABLE\_REFERENCE\_SOURCE
RECEIPT\_REFERENCE\_SOURCE
MENU\_REFERENCE\_SOURCE
KDS\_HANDOFF\_SOURCE

OKPOS must not be treated by default as:

PAYMENT\_AUTHORITY
KDS\_AUTHORITY
REFUND\_AUTHORITY
SETTLEMENT\_AUTHORITY
CUSTOMER\_RECOVERY\_AUTHORITY

unless the integration contract and capability testing explicitly allow it.

---

## **6\. Candidate Provider Family**

Major POS candidate providers may include:

OKPOS
POSBANK-related environments
large restaurant POS providers
cloud POS providers
VAN-linked POS providers
franchise POS providers
tablet POS providers
store-owned POS environments
legacy POS environments

The provider list should remain flexible and evidence-based.

Provider priority should follow market reach, integration feasibility, and pilot availability.

---

## **7\. Initial Integration Target**

The initial target for a major POS provider should be Level 1 or Level 2\.

Recommended first target:

read POS order
read item list
read order amount
read payment status if available
read cancellation status if available
read table reference if available
normalize into canonical order model
create KDS projection
create diagnostic error events
create audit trail

Initial integration should not require full POS replacement.

Initial integration should not assume bidirectional write authority.

---

## **8\. Capability Level Target**

Major POS providers should be evaluated by capability level.

Allowed levels:

LEVEL\_0\_MANUAL\_OR\_NO\_API
LEVEL\_1\_READ\_ONLY\_INTAKE
LEVEL\_2\_EVENT\_SYNC
LEVEL\_3\_OPERATIONAL\_AUTHORITY\_INTEGRATION
LEVEL\_4\_CERTIFIED\_DEEP\_INTEGRATION

Recommended roadmap:

Phase 1: Level 1 read-only intake
Phase 2: Level 2 event synchronization
Phase 3: Level 3 limited authority integration
Phase 4: Level 4 certified deep integration

Level 3 and Level 4 must not be assumed before vendor contract, testing, security review, and pilot validation.

---

## **9\. API Discovery Checklist**

Before adapter design, the provider must be reviewed for:

public API availability
partner API availability
webhook support
polling support
order read API
order update API
payment status API
cancellation API
void API
refund visibility API
menu API
table API
KDS API or printer/KDS handoff path
test environment
credential issuance process
rate limits
support contact

If API availability is unknown, provider status should remain:

RESEARCHING

or:

BUSINESS\_CONTACT\_REQUIRED

---

## **10\. Order Intake Capability**

Order intake review must determine whether the POS can provide:

external\_order\_id
store reference
terminal reference
order created time
order accepted time
order source
order channel
item list
modifiers
discounts
tax or service charge
total amount
receipt reference
table reference
staff reference if available

If external order identity is unavailable, the integration must be marked:

EXTERNAL\_ORDER\_IDENTITY\_INCOMPLETE

and cannot be treated as high-confidence order sync.

---

## **11\. Payment Status Capability**

Payment status review must determine whether the POS can provide:

payment pending
payment authorized
payment completed
payment failed
payment canceled
partial payment
refund visibility
payment method
payment amount
payment timestamp
payment reference

If payment status cannot be verified from provider data, payment must remain under Payment Runtime or separate provider verification.

POS payment visibility must not automatically become payment authority.

---

## **12\. Cancellation And Void Capability**

The provider must distinguish cancellation and void events.

Required distinction:

order cancellation
item void
payment cancellation
refund
partial refund
kitchen cancellation request
cancellation before preparation
cancellation after preparation

If the provider collapses these into one vague status, the adapter must mark:

CANCELLATION\_MAPPING\_UNCERTAIN

and require reconciliation for authority-sensitive actions.

---

## **13\. Table Reference Capability**

Table reference capability must be reviewed for dine-in use.

The provider may support:

table name only
table ID
floor or zone
table move
table merge
table split
seating session
party size

If only table name is provided, the adapter must avoid assuming seating session certainty.

Unclear table mapping must be marked:

TABLE\_REFERENCE\_UNCERTAIN

---

## **14\. Menu Mapping Capability**

Menu mapping must be reviewed before KDS projection.

The provider should support:

external item ID
external item name
modifier group
option ID
set or bundle structure
discount reference
tax category
sold-out state if available
menu version

Unknown items must be marked:

UNKNOWN\_EXTERNAL\_ITEM

or:

ITEM\_MAPPING\_REQUIRED

Unknown items must not be silently dropped.

---

## **15\. KDS Relevance**

Major POS providers may already have KDS, printer, or kitchen handoff structures.

The integration must determine whether the POS supports:

KDS ticket creation
kitchen station routing
ticket status
hold state
cancel state
ready state
remake state
printer ticket reference
kitchen display reference

If KDS integration is unavailable, the internal system may provide a separate KDS projection.

But internal KDS projection must be clearly separated from POS-owned KDS if both exist.

---

## **16\. External KDS Conflict Rule**

If the POS already has its own KDS flow, the system must prevent duplicate kitchen execution.

Potential conflict:

POS sends order to its own KDS
internal adapter also sends order to internal KDS
same order appears twice in kitchen

The system must support:

KDS\_PROJECTION\_ONLY
KDS\_INTERNAL\_PRIMARY
KDS\_EXTERNAL\_PRIMARY
KDS\_DUAL\_VISIBILITY
KDS\_RELEASE\_BLOCKED

The KDS ownership model must be explicit per store.

---

## **17\. Payment-To-KDS Automation Path**

If POS payment status is reliable, the system may use POS payment visibility as input.

However, KDS release must still follow internal rules:

POS payment status received
        ↓
Payment Runtime or Payment Mapping verifies
        ↓
internal PAYMENT\_DONE
        ↓
KDS release eligibility
        ↓
KDS release

The adapter must not directly convert POS paid label into KDS release without verification and mapping.

---

## **18\. Overlay Path For Major POS**

If API integration is weak, the system may still enter the store through overlay.

Overlay paths include:

customer mobile order overlay
counter dynamic QR payment overlay
staff-confirmed POS order reference
receipt reference input
manual payment confirmation
internal KDS projection
manual reconciliation

Overlay allows adoption without waiting for full POS vendor cooperation.

Overlay-originated state must be marked:

OVERLAY\_ORIGINATED

or:

FALLBACK\_ORIGINATED

where applicable.

---

## **19\. Shadow Mode Path**

Before active integration, major POS adapters should run in shadow mode where possible.

Shadow mode means:

provider data is received
canonical order projection is built
diagnostic errors are generated
audit events are created
but authority-sensitive actions are not executed

Shadow mode helps compare internal projection with real POS behavior.

Shadow mode must be clearly marked.

---

## **20\. Store Pilot Criteria**

A major POS pilot store should have:

actual provider installed
owner cooperation
manager cooperation
known order flow
known payment flow
known KDS or kitchen flow
reasonable order volume
ability to observe peak flow
willingness to report mismatches
fallback readiness

Pilot should measure operational friction, not only API success.

---

## **21\. Vendor Contact Strategy**

Vendor contact should clarify:

integration purpose
store authorization model
read access scope
write access scope
webhook availability
test environment
credential scope
commercial requirement
technical support path
API version policy
data protection requirements

Vendor cooperation must not be assumed.

If vendor cooperation is blocked, the provider may remain overlay or read-only candidate.

---

## **22\. Adapter Test Requirements**

Before production use, the provider adapter must pass:

happy path order intake
payment status mapping test
cancellation before kitchen release
cancellation after kitchen release
unknown item mapping
table ambiguity
duplicate provider event
out-of-order event
provider outage
manual fallback
audit completeness
replay safety

These tests should follow the 04350 test harness policy.

---

## **23\. Diagnostic Error Mapping**

Major POS provider issues must map to 04330 diagnostic codes.

Relevant codes include:

POSADP-ORDER-001 external\_order\_id missing
POSADP-ORDER-004 order status mapping uncertain
POSADP-PAY-002 payment status conflict
POSADP-KDS-003 kitchen release requested before payment verification
POSADP-MAP-001 unknown external item
POSADP-TABLE-002 table reference ambiguous
POSADP-WEBHOOK-005 webhook delivery delayed
POSADP-CAP-002 write attempted on read-only adapter
POSADP-CONFLICT-002 payment status conflict
POSADP-FALLBACK-001 fallback mode activated

Provider-specific failures must be translated into internal diagnostic language.

---

## **24\. Monitoring Requirements**

Major POS integration monitoring should track:

provider health
adapter health
order intake delay
normalization failure count
unknown item mapping count
table mapping uncertainty count
payment status conflict count
cancellation conflict count
KDS release blocked count
duplicate event count
manual fallback count
reconciliation backlog

Monitoring must support both store-safe messages and support-facing diagnostics.

---

## **25\. Support And Vendor Escalation**

Major POS integration support must follow structured escalation.

Escalation packet should include:

provider name
store reference
external order ID
external event ID
internal order ID
adapter version
error codes
time window
observed behavior
expected behavior
raw payload reference
audit reference
store evidence if any

Vendor claim must be treated as evidence, not automatic truth.

---

## **26\. Security And Credential Rule**

Major POS provider credentials must be scoped.

Credential review must consider:

tenant scope
store scope
terminal scope
read permission
write permission
payment permission
refund permission
menu permission
webhook secret
credential rotation
credential revocation

A credential must not grant broader authority than integration level requires.

---

## **27\. Rollback Rule**

Major POS integration must have rollback.

Rollback may include:

disable adapter
switch to read-only mode
disable write operations
disable KDS release automation
use overlay payment flow
use manual kitchen recovery
preserve raw payload
preserve audit events
create reconciliation cases

Rollback must not delete failed integration evidence.

---

## **28\. MVP Cutline**

For MVP, OKPOS or major POS integration candidate work should support:

provider candidate record
API discovery checklist
capability level estimate
store pilot candidate flag
read-only intake target
canonical order mapping draft
basic item mapping draft
basic payment status mapping draft
basic table reference review
diagnostic error mapping
fallback overlay path
support escalation path

Excluded from MVP:

full bidirectional POS control
full write-back to POS
automatic refund execution
full settlement integration
certified deep integration
franchise-wide rollout
vendor marketplace certification
automatic menu sync
automatic table merge/split sync

---

## **29\. Relationship To Previous Documents**

This document depends on:

04300 POS Provider Abstraction And Multi-POS Adapter Policy
04310 Canonical Order Model And POS Event Normalization Policy
04320 POS Adapter Capability Level And Integration Contract Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04340 POS Vendor Priority And Integration Roadmap Policy
04350 POS Adapter Test Harness And Certification Scenario Policy
04360 POS Provider Onboarding Evidence And Contract Checklist Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04380 POS Integration Support Escalation And Vendor Communication Policy
04390 POS Integration Governance Index And Readiness Check
04420 POS Adapter Runtime Data Object And Event Family Policy

The relationship is:

04300\~04390 \= POS federation governance
04420 \= runtime object/event foundation
04430 \= first major POS candidate integration policy

---

## **30\. Patent And SaaS Relevance**

This document supports the SaaS strategy because major POS integration is the bridge to real store adoption.

The strategic structure is:

existing major POS
        ↓
adapter or overlay
        ↓
canonical order model
        ↓
payment/KDS/display runtime
        ↓
diagnostic error language
        ↓
audit/replay/reconciliation

The competitive value is not simply claiming “we support OKPOS.”

The value is supporting major POS environments through governed, testable, diagnosable integration boundaries.

---

## **31\. Known Gaps To Track**

The following gaps must remain visible:

actual OKPOS API availability
actual vendor cooperation path
actual store authorization process
actual payment status data quality
actual menu data structure
actual KDS integration path
actual table support
actual test environment availability
actual credential scope
actual pilot store availability

These gaps do not block candidate policy drafting.

They block production claims.

---

## **32\. Readiness Check**

This policy is ready when:

OKPOS is treated as strategic POS candidate
major POS providers are grouped as candidates
API discovery checklist exists
capability level must be assigned
initial target is Level 1 or Level 2
payment authority is not assumed
KDS authority is not assumed
external KDS conflict is recognized
overlay path exists
shadow mode path exists
pilot criteria are defined
diagnostic error mapping exists
monitoring requirements are defined
rollback is defined
known gaps are visible

---

## **33\. Summary**

OKPOS and other major POS providers are strategically important because stores do not want to replace existing POS systems first.

The system should pursue major POS integration, but not recklessly.

The correct path is:

candidate review
API discovery
capability classification
read-only or event sync first
canonical normalization
diagnostic error mapping
shadow mode
pilot
fallback
reconciliation
later authority integration

This lets the platform compete in real store environments while preserving authority, audit, and operational safety.
