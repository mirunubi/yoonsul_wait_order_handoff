08100 CatchMenu Support Signal And Case Handoff Policy

1\. Purpose

This document defines how CatchMenu hands off support-related signals, evidence, and read access to a future AI Customer Center.

The AI Customer Center may become a separate project.

Therefore, CatchMenu must not define or own the full AI Customer Center support case workflow.

CatchMenu only defines what it can safely provide to support systems.

Core purpose:

CatchMenu emits support signals.
CatchMenu provides Evidence Packets.
CatchMenu exposes support-safe views through Support Gateway.
AI Customer Center owns support case workflow.

2\. Core Boundary

CatchMenu is the operational runtime.

AI Customer Center is the support intelligence system.

CatchMenu must not become the support case management system.

AI Customer Center must not become the CatchMenu operational authority.

Core rule:

CatchMenu does not manage AI Customer Center support cases.
CatchMenu emits support signals and provides evidence through Support Gateway.
AI Customer Center owns support case intake, classification, routing, conversation, and lifecycle.

Korean rule:

CatchMenu는 AI 고객센터의 support\_case 운영 원장을 소유하지 않는다.
CatchMenu는 support\_signal, evidence\_packet, support-safe view, gateway access contract를 제공한다.
support\_case의 접수, 분류, 배정, 상담 상태 변경, 사람/HQ/매장 라우팅은 AI 고객센터 프로젝트의 책임이다.

3\. What CatchMenu Owns

CatchMenu owns the operational context required for support handoff.

CatchMenu may provide:

support signal
case candidate hint
evidence packet
support-safe timeline
masked guest context
masked store context
request issue context
handoff issue context
translation issue context
benefit issue context
gateway access contract
primary read restriction policy
secondary support view policy

CatchMenu also owns:

tenant/store boundary
field masking
evidence packet generation
support-safe read model
runtime event references
gateway access audit
primary DB read restriction

4\. What AI Customer Center Owns

AI Customer Center owns the actual support operation.

AI Customer Center may own:

support\_case creation
support\_case MongoDB document
case classification
case status lifecycle
conversation history
AI summary
AI response draft
human support assignment
HQ escalation
merchant routing
guest response workflow
resolution note
support SLA
support analytics

These are not CatchMenu runtime responsibilities.

CatchMenu may provide input, evidence, and references, but it does not operate the support case lifecycle.

5\. Support Gateway Requirement

CatchMenu must provide a Support Gateway boundary.

The AI Customer Center should not directly query raw CatchMenu operational tables.

Normal access path:

AI Customer Center
→ Support Gateway
→ pgvector SOP / policy / troubleshooting retrieval
→ Evidence Packet
→ Secondary Support View
→ Primary DB read-only last resort

Support Gateway must enforce:

tenant boundary
store boundary
case scope
field masking
read permission
rate limit
audit log
source selection
freshness check
primary read restriction

6\. Push And Pull Model

CatchMenu support handoff should use both push and pull patterns.

6.1 Pull Model

The default model is Gateway Pull.

AI Customer Center asks the Support Gateway for relevant data.

Example:

AI Customer Center receives inquiry
→ asks Support Gateway for SOP
→ asks Support Gateway for Evidence Packet
→ asks Support Gateway for support timeline if needed

Pull is preferred because it allows:

case-scoped access
field masking
gateway audit
Primary DB protection
tenant/store boundary enforcement

6.2 Push Model

CatchMenu may push support signals for important events.

Push should not send raw operational data.

Push should send:

support\_signal
case\_candidate\_hint
issue\_event
evidence\_packet\_reference
minimal identifiers
severity\_hint

Push exists to notify the AI Customer Center that a support-relevant event occurred.

The AI Customer Center decides whether to create a support case.

7\. Support Signal Definition

A Support Signal is a lightweight event emitted by CatchMenu when a support-relevant condition occurs.

A Support Signal is not a support case.

A Support Signal is not a resolution.

A Support Signal is not an operational mutation command.

Core rule:

Support Signal \= “this may require support attention”
Support Case \= AI Customer Center workflow object
Evidence Packet \= support-safe fact bundle

8\. Support Signal Examples

CatchMenu may emit support signals for:

30-minute unconfirmed request warning
unconfirmed request count reached forced cleanup threshold
forced cleanup screen shown
guest request expired as unconfirmed
translation confidence LOW with critical request
allergy request detected
QR wrong-store suspicion
owner console alert failure
POS handoff failure
KDS handoff failure
manual fallback used
benefit claim failed
external membership claim deferred
guest status confusion detected
same request updated multiple times

9\. Support Signal Minimal Payload

A Support Signal should be minimal.

Example fields:

signal\_id
signal\_type
tenant\_id
store\_id
severity\_hint
created\_at
related\_request\_id
related\_waiting\_id
related\_handoff\_id
related\_guest\_session\_id\_masked
related\_evidence\_packet\_ref
gateway\_lookup\_required
primary\_read\_allowed\_hint

The signal should not include raw sensitive data.

10\. Support Signal Example

{
  "signal\_id": "sig\_20260610\_0001",
  "signal\_type": "UNCONFIRMED\_REQUEST\_WARNING",
  "tenant\_id": "tenant\_123",
  "store\_id": "store\_456",
  "severity\_hint": "P2",
  "created\_at": "2026-06-10T12:30:00+09:00",
  "related\_request\_id": "req\_789",
  "related\_guest\_session\_id\_masked": "guest\_anon\_4839",
  "related\_evidence\_packet\_ref": "ep\_20260610\_0001",
  "gateway\_lookup\_required": true,
  "primary\_read\_allowed\_hint": false
}

11\. Case Candidate Hint

A Case Candidate Hint is a stronger form of Support Signal.

It suggests that the AI Customer Center may want to create a support case.

Examples:

POS handoff failed after retry
KDS handoff failed after retry
forced cleanup blocks owner workflow
low-confidence translation includes allergy request
guest-visible status and owner-visible status mismatch
benefit claim failed after external connector attempt

Case Candidate Hint may include:

recommended\_case\_type
severity\_hint
evidence\_packet\_ref
missing\_evidence\_hint
recommended\_sop\_category

The AI Customer Center still owns the final decision to create a support case.

12\. Evidence Packet Reference

CatchMenu should pass evidence by reference whenever possible.

Instead of pushing the full Evidence Packet to AI Customer Center, CatchMenu may push:

evidence\_packet\_ref
gateway\_endpoint\_ref
evidence\_packet\_version
created\_at
freshness\_status

The AI Customer Center can then retrieve the packet through Support Gateway.

This protects:

masking policy
access audit
field-level permissions
tenant boundary
freshness control

13\. Support-Safe View

CatchMenu may expose support-safe read models through the Gateway.

Preferred support-safe views:

support\_timeline\_view
support\_evidence\_packet\_view
masked\_guest\_context\_view
masked\_store\_context\_view
request\_issue\_view
translation\_issue\_view
stage\_0c\_unconfirmed\_issue\_view
handoff\_issue\_view
benefit\_issue\_view
owner\_console\_issue\_view

These views must exclude unrelated data.

They must not expose raw operational tables.

14\. pgvector / SOP Lookup Contract

The Support Gateway may expose knowledge retrieval to AI Customer Center.

Initial retrieval source:

Supabase PostgreSQL \+ pgvector

Retrieval content may include:

CatchMenu policy documents
Stage 0A / 0B / 0C policies
I18n translation policy
troubleshooting foundation
evidence packet policy
merchant onboarding guide
guest FAQ
known issue SOP
incident resolution guide

AI Customer Center should retrieve SOP before requesting operational evidence when the issue is general guidance.

15\. Secondary First Policy

When operational context is required, Gateway should use Secondary Support View first.

Default rule:

Support Gateway reads Secondary DB / support-safe view by default.
Primary DB is not the default support source.

Secondary may contain:

replicated event timeline
support-safe request status
masked guest context
masked store context
handoff status
translation context
benefit context
issue signals

16\. Primary Last Resort Policy

Primary DB read is allowed only when strictly necessary.

Allowed only if:

case is same-day or active
Secondary is not fresh enough
Evidence Packet is incomplete
the query is case-scoped
access is read-only
access is audited

Primary DB read is prohibited for:

general browsing
broad table scan
unrelated guest history
unrelated tenant data
raw payment credentials
raw auth/session data
state mutation
silent correction
audit deletion

17\. Runtime Mutation Boundary

Support handoff must not become a mutation path.

AI Customer Center must not use Support Gateway to mutate CatchMenu runtime state.

Prohibited through support handoff:

confirm request
cancel request
mark request completed
clear forced cleanup
retry POS handoff
retry KDS handoff
approve refund
grant benefit
mark benefit claimed
delete evidence
overwrite audit history

If an operational action is required, the AI Customer Center may create a recommendation or escalation.

Execution must happen through:

authorized human
authorized store console action
authorized HQ support action
authorized CatchMenu runtime function

18\. Handoff To AI Customer Center

CatchMenu may hand off the following to AI Customer Center:

support signal
case candidate hint
evidence packet reference
support-safe timeline reference
SOP retrieval category
severity hint
tenant/store scoped identifiers
masked guest/session identifier

CatchMenu should not hand off:

full raw operational table rows
payment credentials
auth tokens
unrelated guest history
unrelated store data
internal secrets
unmasked personal data unless explicitly allowed

19\. AI Customer Center Case Workflow Boundary

AI Customer Center may define its own:

support\_case schema
case status lifecycle
assignment rules
conversation storage
AI classification model
human review workflow
HQ escalation workflow
merchant response workflow
SLA policy
resolution codes

CatchMenu does not define these in this project.

CatchMenu only defines the handoff contract and safe access boundary.

20\. Recommended Signal Types

Suggested support signal types:

UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
UNCONFIRMED\_REQUEST\_EXPIRED
AUTO\_COMPLETION\_DISPUTE\_CANDIDATE
LOW\_CONFIDENCE\_TRANSLATION
CRITICAL\_REQUEST\_DETECTED
STORE\_CONFIRMATION\_DELAY
OWNER\_CONSOLE\_ALERT\_FAILURE
QR\_ACCESS\_FAILURE
QR\_WRONG\_STORE\_SUSPECTED
POS\_HANDOFF\_FAILED
KDS\_HANDOFF\_FAILED
MANUAL\_FALLBACK\_USED
BENEFIT\_CLAIM\_FAILED
BENEFIT\_CLAIM\_DEFERRED
GUEST\_STATUS\_CONFUSION
OWNER\_ACTION\_BLOCKED

21\. Recommended Case Type Hints

CatchMenu may recommend case type hints, but AI Customer Center owns final classification.

Suggested hints:

QR\_MENU\_ACCESS
LANGUAGE\_TRANSLATION
MENU\_OPTION
GUEST\_REQUEST
STORE\_CONFIRMATION
STAGE\_0C\_UNCONFIRMED\_REQUEST
WAITING\_ARRIVAL
POS\_HANDOFF
KDS\_HANDOFF
BENEFIT\_ROUTING
OWNER\_CONSOLE
NOTIFICATION
DEVICE\_BROWSER
POLICY\_USAGE\_CONFUSION
ABUSE\_DISPUTE\_SAFETY
GENERAL\_SUPPORT

22\. Audit Requirement

Every Gateway access should create an audit or access event.

Suggested access event fields:

gateway\_access\_id
requesting\_system
requesting\_actor\_type
tenant\_id
store\_id
support\_signal\_id
evidence\_packet\_ref
access\_source
access\_reason
primary\_read\_used
primary\_read\_reason
fields\_returned
masking\_applied
created\_at

Access sources:

pgvector\_knowledge
evidence\_packet
secondary\_support\_view
primary\_runtime\_read

23\. Data Minimization

CatchMenu must apply data minimization.

Only the minimum support context needed should be returned.

Default policy:

return case-scoped facts
mask personal data
exclude unrelated history
exclude secrets
exclude payment credentials
exclude auth/session data

24\. Final Statement

CatchMenu must support future AI Customer Center integration without giving AI direct operational authority.

CatchMenu provides signals, evidence, gateway retrieval, support-safe views, masking, and audit.

AI Customer Center owns support case creation, classification, routing, conversation, and case lifecycle.

Core rule:

CatchMenu signals.
Gateway controls.
Evidence informs.
AI Customer Center manages cases.
Authorized runtime or human acts.
