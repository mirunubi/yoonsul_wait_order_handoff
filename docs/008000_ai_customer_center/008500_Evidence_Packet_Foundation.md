# 008500_Evidence_Packet_Foundation.md

## Purpose

This document defines the Evidence Packet foundation for CatchMenu AI Customer Center integration.

The AI Customer Center is expected to operate as a separate support intelligence system.

CatchMenu must not expose raw operational tables directly to AI support by default.

Instead, CatchMenu should provide a support-safe Evidence Packet for each case or incident.

An Evidence Packet is the standard unit of support review.

2\. Core Principle

An Evidence Packet is a support-safe bundle of relevant facts.

It is not the operational source of truth.

It is not an order ledger.

It is not a payment ledger.

It is not a mutation authority.

Core rule:

Evidence Packet \= support review artifact
Operational DB \= source of runtime truth
Authorized runtime function \= mutation authority

The AI Customer Center may read and summarize an Evidence Packet.

The AI Customer Center must not use an Evidence Packet to directly mutate CatchMenu runtime state.

3\. Relationship With Support Gateway

Evidence Packets should be accessed through the Support Gateway.

Normal access order:

AI Customer Center
→ Support Gateway
→ pgvector SOP / policy / troubleshooting retrieval
→ Evidence Packet
→ Secondary Support View
→ Primary DB read-only last resort

The AI Customer Center should not freely query CatchMenu operational tables.

The Support Gateway decides whether an Evidence Packet is enough or whether a limited Secondary/Primary lookup is needed.

4\. Evidence Packet Scope

An Evidence Packet should be created or assembled for a specific support case.

Possible case subjects:

guest request issue
translation issue
store confirmation issue
unconfirmed request issue
Stage 0C auto-completion issue
waiting issue
POS handoff issue
KDS handoff issue
benefit claim issue
QR access issue
owner console issue
merchant onboarding issue

Evidence Packets must be case-scoped.

They must not include unrelated guest history, unrelated store data, or broad tenant data.

5\. Required Identifiers

An Evidence Packet may include the following identifiers.

support\_case\_id
tenant\_id
store\_id
guest\_session\_id
request\_id
waiting\_id
handoff\_id
pos\_reference
kds\_reference
benefit\_candidate\_id
external\_membership\_reference

Not every packet requires every identifier.

For Stage 0A, there may be no request\_id because no request is sent to the store.

For Stage 0B and 0C, request\_id is usually required.

For Stage 3 and 4, POS/KDS references may be included if available.

6\. Case Type

Each Evidence Packet should include a case type.

Suggested case types:

QR\_MENU\_ACCESS
LANGUAGE\_SELECTION
MENU\_TRANSLATION
GUEST\_REQUEST\_SUBMISSION
STORE\_CONFIRMATION\_DELAY
UNCONFIRMED\_REQUEST
FORCED\_CLEANUP\_REQUIRED
AUTO\_COMPLETION\_DISPUTE
STORE\_CHANGE\_REQUEST
GUEST\_RECONFIRMATION
POS\_HANDOFF\_FAILURE
KDS\_HANDOFF\_FAILURE
BENEFIT\_CLAIM\_UNCERTAIN
OWNER\_CONSOLE\_ALERT\_FAILURE
PAY\_AT\_STORE\_CONFUSION
GENERAL\_TROUBLESHOOTING

Case type helps the AI Customer Center retrieve the correct SOP and troubleshooting document.

7\. Timeline

An Evidence Packet should include a timeline of relevant events.

Example timeline fields:

event\_time
event\_type
actor\_type
actor\_id\_masked
source\_surface
status\_before
status\_after
event\_summary
error\_code

Possible actor types:

guest
store\_owner
store\_staff
system
support\_agent
pos\_adapter
kds\_adapter
gateway

Possible source surfaces:

guest\_webapp
staff\_read\_view
owner\_web\_console
store\_console
mini\_kds
pos\_adapter
kds\_adapter
support\_gateway
system\_job

8\. Request Context

For Stage 0B and 0C, the Evidence Packet should include request context.

request\_id
request\_status
request\_version
latest\_version\_flag
created\_at
sent\_to\_store\_at
store\_review\_started\_at
store\_confirmed\_at
manual\_completed\_at
auto\_completed\_at
closed\_at
expired\_at

Important status examples:

DRAFT
REQUESTED
UPDATED\_BY\_GUEST
STORE\_REVIEWING
CHANGE\_REQUESTED\_BY\_STORE
GUEST\_RECONFIRM\_REQUIRED
STORE\_CONFIRMED
MANUAL\_COMPLETED
AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
UNCONFIRMED\_WARNING
UNCONFIRMED\_EXPIRED
CANCELLED

9\. Translation Context

If the case involves multilingual support, the Evidence Packet should include translation context.

guest\_language
store\_language
original\_guest\_text
translated\_store\_text\_ko
translation\_source
translation\_confidence
translation\_status
critical\_request\_flags
staff\_confirmation\_required

Critical request flags may include:

allergy
spicy\_level
pork
alcohol
seafood
nuts
raw\_food
religious\_dietary\_restriction
vegetarian
vegan
child\_or\_elderly
medical\_caution
custom\_cooking\_request

For critical requests, the Evidence Packet should include a warning:

Automatic translation is not final confirmation.
Staff confirmation may be required.

10\. Store Confirmation Context

For store confirmation issues, the Evidence Packet should include:

store\_confirmed
store\_confirmed\_at
confirmed\_by\_actor\_type
confirmed\_by\_actor\_id\_masked
guest\_locked\_after\_confirmation
owner\_console\_visible\_status
guest\_visible\_status

For unconfirmed cases:

unconfirmed\_duration\_minutes
warning\_triggered\_at
top\_warning\_visible
forced\_cleanup\_required
forced\_cleanup\_triggered\_at
unconfirmed\_count\_at\_time

11\. Stage 0C Specific Context

Stage 0C requires special evidence fields because it allows simple POS-less handling.

owner\_confirm\_button\_visible
owner\_confirm\_clicked
owner\_complete\_button\_visible
owner\_complete\_clicked
auto\_completion\_policy\_applied
auto\_completion\_duration\_minutes
closing\_cleanup\_policy\_applied
unconfirmed\_warning\_policy\_applied
forced\_cleanup\_policy\_applied

Rules to preserve:

confirmed requests may be auto-completed
unconfirmed requests must not be auto-completed as completed orders
unconfirmed requests may be warned, forced into cleanup, or expired

12\. POS / KDS Handoff Context

For Stage 3 and 4 cases, the Evidence Packet may include POS/KDS context.

POS fields:

pos\_adapter\_enabled
pos\_handoff\_attempted
pos\_handoff\_status
pos\_reference
pos\_error\_code
pos\_retry\_count
manual\_pos\_fallback\_used
duplicate\_guard\_result

KDS fields:

kds\_adapter\_enabled
kds\_handoff\_attempted
kds\_handoff\_status
kds\_reference
kds\_error\_code
kds\_retry\_count
mini\_kds\_fallback\_used
ready\_status\_received

Boundary rule:

POS owns transaction authority.
KDS owns kitchen execution authority.
CatchMenu owns handoff context.
AI Customer Center owns support review only.

13\. Benefit Routing Context

For Stage 5 or benefit-related cases, the Evidence Packet may include:

benefit\_candidate\_id
benefit\_policy\_id
claim\_token\_id
claim\_status
duplicate\_guard\_status
external\_membership\_reference
external\_claim\_attempted
external\_claim\_result
claim\_deferred\_reason

Boundary rule:

Benefit candidate does not equal benefit claimed.
AI Customer Center must not mark benefits as claimed.

14\. Device And Access Context

For troubleshooting, the Evidence Packet may include device and access context.

device\_type
browser\_name
browser\_version
os\_name
os\_version
screen\_size\_class
network\_status
qr\_entry\_url\_hash
app\_install\_required
pwa\_mode
console\_session\_status

Sensitive details should be minimized.

Authentication tokens, secrets, and raw session credentials must never be included.

15\. Error Context

The Evidence Packet may include error context.

error\_code
error\_message\_safe
error\_surface
first\_error\_at
last\_error\_at
retry\_count
recovery\_attempted
fallback\_used

Error messages should be support-safe.

Internal stack traces should not be exposed to the AI Customer Center by default.

16\. Masking Policy

Evidence Packets must apply masking before being sent to the AI Customer Center.

Masking targets:

guest name
guest phone
guest email
store owner phone
staff name
staff phone
payment-related identifiers
authentication identifiers
raw IP address
device fingerprint

Allowed examples:

010-\*\*\*\*-1234
g\*\*\*@example.com
guest\_anon\_4839
staff\_masked\_1021

Prohibited fields:

payment credentials
card number
auth token
session secret
password
full unrelated guest history
unrelated tenant data
internal secret key

17\. Evidence Packet Freshness

Evidence Packet freshness should be recorded.

packet\_created\_at
packet\_refreshed\_at
source\_freshness
secondary\_sync\_lag\_seconds
primary\_read\_used
primary\_read\_reason

If Primary DB was used, the packet must record:

primary\_read\_used \= true
primary\_read\_reason
primary\_read\_scope
primary\_read\_at
gateway\_access\_log\_id

18\. AI Usage Policy

The AI Customer Center may use the Evidence Packet to:

summarize the case
classify issue type
retrieve relevant SOP
draft guest response
draft merchant response
detect missing evidence
recommend escalation
prepare human handoff

The AI Customer Center must not use the Evidence Packet to:

confirm order
cancel order
refund payment
approve compensation
modify POS state
modify KDS state
mark benefit as claimed
delete evidence
overwrite audit history
decide legal fault

19\. Evidence Packet Lifecycle

Suggested lifecycle:

CREATED
REFRESHED
AI\_REVIEWED
HUMAN\_REVIEWED
ESCALATED
RESOLVED
ARCHIVED

Lifecycle changes should be support-case events.

They must not mutate the underlying CatchMenu operational state.

20\. Evidence Packet Minimal Example

{
  "support\_case\_id": "case\_20260610\_0001",
  "tenant\_id": "tenant\_masked",
  "store\_id": "store\_123",
  "case\_type": "UNCONFIRMED\_REQUEST",
  "request\_id": "req\_789",
  "guest\_session\_id": "guest\_anon\_4839",
  "request\_status": "UNCONFIRMED\_WARNING",
  "guest\_language": "es",
  "store\_language": "ko",
  "translated\_store\_text\_ko": "고수 제외, 맵지 않게 해주세요.",
  "translation\_confidence": "MEDIUM",
  "critical\_request\_flags": \["custom\_cooking\_request"\],
  "timeline": \[
    {
      "event\_time": "2026-06-10T12:00:00+09:00",
      "event\_type": "REQUESTED",
      "actor\_type": "guest",
      "source\_surface": "guest\_webapp"
    },
    {
      "event\_time": "2026-06-10T12:30:00+09:00",
      "event\_type": "UNCONFIRMED\_WARNING",
      "actor\_type": "system",
      "source\_surface": "owner\_web\_console"
    }
  \],
  "masking\_applied": true,
  "primary\_read\_used": false
}

21\. Final Statement

Evidence Packet is the primary support handoff unit between CatchMenu and the AI Customer Center.

It must be case-scoped, support-safe, masked, timeline-based, and boundary-preserving.

Core rule:

AI reads Evidence Packet.
AI retrieves SOP.
AI drafts or recommends.
Authorized human or runtime function acts.
