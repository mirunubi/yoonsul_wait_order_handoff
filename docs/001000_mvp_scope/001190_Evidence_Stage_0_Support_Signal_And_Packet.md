# 001190_Evidence_Stage_0_Support_Signal_And_Packet.md

1\. Purpose

This document defines the Stage 0 support signal and Evidence Packet policy for CatchMenu.

Stage 0 must be lightweight for merchants, but it must still leave enough support-safe evidence to explain what happened when a guest request, translation, owner console alert, confirmation, expiration, or completion issue occurs.

Support Signal and Evidence Packet must help support teams understand the event without giving AI or support users unsafe mutation authority.

Core purpose:

Signal support-worthy events.
Preserve request evidence.
Explain what happened.
Do not mutate runtime state through support.

Korean purpose:

지원 검토가 필요한 사건을 신호화한다.
요청 증거를 보존한다.
무슨 일이 있었는지 설명 가능하게 한다.
지원 경로가 운영 상태를 임의 변경하지 못하게 한다.

2\. Scope

This document covers Stage 0 support-safe evidence and signal generation for:

QR access issue
menu display issue
translation issue
critical request issue
request send failure
owner console delivery issue
notification failure
store confirmation delay
unconfirmed warning
forced cleanup
guest edit lock
request version conflict
duplicate request suspicion
manual completion
auto-completion
close auto-completion
unconfirmed expiration
support review requirement

This document does not define:

full AI customer center implementation
support case database ownership
MongoDB support case lifecycle
refund approval workflow
legal fault decision
payment dispute resolution
POS or KDS mutation
benefit grant mutation

3\. Core Principle

Support observes and explains.

Support does not silently operate the runtime.

Core rule:

Support Signal alerts.
Evidence Packet explains.
Authorized runtime functions act.
Support and AI must not silently mutate request state.

Korean rule:

Support Signal은 알린다.
Evidence Packet은 설명한다.
권한 있는 런타임 함수만 상태를 변경한다.
지원 담당자와 AI는 요청 상태를 조용히 변경하면 안 된다.

4\. Support Signal Definition

A Support Signal is a lightweight event or hint that something may need support review.

Support Signal is not a support case by itself.

Support Signal may later become:

support case candidate
AI customer center input
merchant support alert
HQ review candidate
Evidence Packet generation trigger
known issue pattern candidate

Core rule:

Signal is not case.
Signal is not approval.
Signal is not mutation.

5\. Evidence Packet Definition

An Evidence Packet is a support-safe structured bundle that explains what happened around a request or event.

Evidence Packet may include:

timeline
request state history
request version history
guest language
store language summary
critical flags
translation confidence
owner console events
notification attempts
failure events
support signals
actor/action records

Evidence Packet is used to explain, review, and escalate.

Evidence Packet must not directly change operational state.

Core rule:

Evidence explains history.
Evidence does not decide outcome.

6\. Signal And Evidence Separation

Support Signal and Evidence Packet must be separated.

Support Signal
\= small alert that something may require attention

Evidence Packet
\= structured context used to understand what happened

A Support Signal may reference an Evidence Packet.

An Evidence Packet may contain multiple Support Signals.

But they are not the same thing.

Core rule:

Push signal.
Pull evidence.
Do not push raw ledger.

7\. Stage 0A Evidence Boundary

Stage 0A usually has limited evidence because no store-side request is sent.

Possible Stage 0A evidence:

QR code reference
store landing page
menu version
language selected
menu viewed event if logged
show-to-staff view opened event if logged
guest-provided screenshot
staff note if later recorded
translation issue report

Stage 0A evidence must clearly state:

No store-side request may exist.
Show-to-staff screen is not order confirmation.

8\. Stage 0B Evidence Boundary

Stage 0B creates stronger evidence because the request may be sent to the owner console.

Possible Stage 0B evidence:

request\_id
request\_version
request\_sent\_at
guest session reference
store\_id
guest language
selected items
selected options
special memo
critical flags
translation confidence
owner console delivery status
store viewed event if available
request expiration event
failure events

Stage 0B evidence must clearly state:

Request sent is not order confirmation.
Owner console visibility is not payment.
Manual handling remains outside POS integration.

9\. Stage 0C Evidence Boundary

Stage 0C should preserve evidence for confirmation, edit lock, warning, cleanup, completion, and expiration.

Possible Stage 0C evidence:

request\_id
request\_version
request\_created\_at
request\_sent\_at
store\_confirmed\_at
confirmed\_by
guest\_edit\_locked\_at
unconfirmed\_warning\_at
forced\_cleanup\_at
completed\_at
auto\_completed\_at
close\_auto\_completed\_at
unconfirmed\_expired\_at
support\_review\_required\_at
state timeline
actor timeline
failure timeline

Stage 0C evidence must clearly distinguish:

confirmed request
unconfirmed request
completed request
auto-completed confirmed request
unconfirmed expired request
support review required request

10\. Support Signal Types

Stage 0 may generate Support Signals such as:

QR\_ACCESS\_FAILED
MENU\_DISPLAY\_FAILED
MENU\_VERSION\_MISMATCH
REQUEST\_SEND\_FAILED
OWNER\_CONSOLE\_UNAVAILABLE
OWNER\_CONSOLE\_ALERT\_DELIVERY\_FAILED
LOW\_CONFIDENCE\_TRANSLATION
UNKNOWN\_TRANSLATION\_CONFIDENCE
CRITICAL\_REQUEST\_DETECTED
ALLERGY\_REQUEST\_DETECTED
DIETARY\_RESTRICTION\_DETECTED
STORE\_RECONFIRM\_REQUIRED
REQUEST\_VERSION\_CONFLICT
DUPLICATE\_REQUEST\_SUSPECTED
UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
UNCONFIRMED\_REQUEST\_EXPIRED
AUTO\_COMPLETION\_DENIED\_UNCONFIRMED
AUTO\_COMPLETION\_BLOCKED\_BY\_CRITICAL\_REQUEST
REQUEST\_STATE\_TRANSITION\_DENIED
EVIDENCE\_PACKET\_INCOMPLETE
SUPPORT\_REVIEW\_REQUIRED

Signal names should be stable and typed.

11\. Support Signal Severity

Support Signal may include severity hint.

Suggested severity values:

INFO
LOW
MEDIUM
HIGH
CRITICAL

Severity meaning:

INFO
\= useful for support history, no immediate action expected

LOW
\= minor issue or recoverable issue

MEDIUM
\= support review may be needed

HIGH
\= merchant or guest flow may be affected

CRITICAL
\= safety, allergy, legal, or severe operational risk

Severity is a hint.

Severity is not legal conclusion.

12\. Support Signal Payload

Recommended Support Signal fields:

signal\_id
signal\_type
severity\_hint
tenant\_id
store\_id
request\_id
request\_version
guest\_session\_ref
business\_date
stage
source\_module
source\_event\_id
evidence\_packet\_ref
created\_at
trace\_id

Optional fields:

language\_code
translation\_confidence
critical\_flag\_summary
failure\_code
notification\_attempt\_id
owner\_console\_session\_ref
duplicate\_group\_hint
support\_case\_candidate\_ref

Support Signal payload should be small.

Raw sensitive details should be pulled through authorized support-safe evidence access.

13\. Evidence Packet Fields

Recommended Evidence Packet fields:

evidence\_packet\_id
evidence\_type
tenant\_id
store\_id
request\_id
request\_version
business\_date
stage
created\_at
created\_by\_system
trace\_id
timeline
current\_state\_snapshot
state\_transition\_events
request\_version\_events
guest\_context\_summary
store\_context\_summary
translation\_context
critical\_request\_summary
owner\_console\_context
notification\_context
failure\_event\_refs
support\_signal\_refs
masking\_applied
access\_policy

Evidence Packet should be structured.

Evidence Packet should not be an unbounded raw log dump.

14\. Evidence Timeline

Evidence Packet should include a timeline.

Timeline may include:

QR\_OPENED
LANGUAGE\_SELECTED
MENU\_VIEWED
ITEM\_SELECTED
REQUEST\_CREATED
REQUEST\_SENT\_TO\_STORE
REQUEST\_VERSION\_UPDATED
OWNER\_CONSOLE\_DELIVERY\_ATTEMPTED
OWNER\_CONSOLE\_DELIVERED
STORE\_VIEWED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
UNCONFIRMED\_WARNING\_CREATED
FORCED\_CLEANUP\_REQUIRED
REQUEST\_COMPLETED\_BY\_STORE
REQUEST\_AUTO\_COMPLETED
REQUEST\_CLOSE\_AUTO\_COMPLETED
REQUEST\_UNCONFIRMED\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED
FAILURE\_EVENT\_CREATED

Core rule:

Timeline should explain sequence.
Timeline should not rewrite sequence.

15\. Request Version Evidence

Evidence Packet must preserve request version history when relevant.

Recommended version evidence:

request\_version
previous\_version
version\_created\_at
version\_created\_by
change\_summary
is\_current\_version
stale\_version\_warning
acted\_version
latest\_version\_at\_action\_time

Core rule:

Do not hide guest intent changes.
Do not confirm stale intent silently.

16\. Translation Evidence

Evidence Packet should preserve translation context.

Recommended fields:

guest\_language
store\_language
menu\_version
translation\_version
original\_guest\_text
translated\_store\_summary
structured\_menu\_item\_ids
structured\_option\_ids
critical\_flags
translation\_confidence
translation\_failure\_event\_ref
staff\_reconfirmation\_required

Core rule:

Preserve original text.
Preserve translated summary.
Preserve structured identifiers.
Do not translate away risk.

17\. Critical Request Evidence

Critical request evidence should be explicit.

Critical categories include:

allergy
cannot-eat ingredient
spicy level
pork
beef
seafood
nuts
alcohol
raw food
religious dietary restriction
vegetarian or vegan request
child or elderly consideration
medical caution
custom cooking request

Evidence Packet should show:

critical flag type
source of detection
original text if applicable
structured option if applicable
staff reconfirmation state
support signal if created

Core rule:

Critical request evidence must be visible and traceable.

18\. Owner Console Evidence

Owner console evidence may include:

owner\_console\_delivery\_status
owner\_console\_opened\_at
store\_viewed\_at
store\_actor\_id
store\_actor\_role
confirm\_action\_at
complete\_action\_at
forced\_cleanup\_opened\_at
notification\_attempts
console\_refresh\_events
console\_inactivity\_hint

Owner console evidence should not overclaim what the store physically did outside CatchMenu.

Core rule:

Console action is console evidence.
It is not proof of payment, serving, or settlement.

19\. Notification Evidence

Notification evidence may include:

notification\_type
notification\_attempt\_id
notification\_target\_type
attempted\_at
delivery\_status
failure\_code
retry\_count
last\_attempt\_at

Notification evidence must state:

Notification is not source of truth.
Request board remains operational reference.

20\. Failure Event Evidence

Evidence Packet may include failure event references.

Examples:

request send failed
owner console unavailable
translation failed
state transition denied
auto-completion denied
notification failed
evidence packet incomplete
gateway access denied

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

Evidence Packet should include failure codes, not generic error text only.

21\. Support Review Required

"SUPPORT\_REVIEW\_REQUIRED" may be generated when the request cannot safely be interpreted by normal Stage 0 flow.

Possible triggers:

state conflict
invalid transition attempt
critical request unresolved
translation confidence LOW or UNKNOWN
Evidence Packet incomplete
duplicate request dispute
auto-completion dispute
unconfirmed expiration dispute
owner console failure
repeated notification failure

Support review does not authorize mutation.

Core rule:

Support review is escalation.
Support review is not runtime override.

22\. Evidence Packet Generation Timing

Evidence Packet may be generated:

on support signal creation
on support review request
on merchant support inquiry
on guest support inquiry
on state conflict
on business date close
on forced cleanup
on critical request detection

Evidence Packet may also be generated on-demand through Support Gateway.

Core rule:

Generate enough evidence to explain.
Do not generate unlimited raw logs by default.

23\. Push Signal / Pull Evidence

Stage 0 should prefer push signal and pull evidence.

Meaning:

Support Signal pushes small alert.
Evidence Packet is pulled when needed.
Raw runtime data is not pushed into support systems by default.

Core rule:

Push signal.
Pull evidence.
Do not push raw ledger.

This protects privacy, performance, and authority boundaries.

24\. Support Gateway Boundary

Support evidence should be accessed through Support Gateway or approved support-safe views/RPC.

Allowed access pattern:

support system asks for evidence
→ Support Gateway validates scope
→ approved Evidence Packet or support-safe view is returned
→ access is logged

Prohibited access pattern:

AI or support tool directly queries operational tables
AI writes SQL against runtime DB
support system bypasses Gateway
service role key shared across projects

Core rule:

Support access must be scoped, logged, and read-only unless explicitly authorized.

25\. Masking Policy

Evidence Packet should apply masking where needed.

Possible masking:

guest session pseudonymization
device hint minimization
memo masking if sensitive
phone/email masking if ever collected
staff actor masking for guest-facing support
store scope filtering
tenant scope filtering

Masking policy should depend on viewer role.

Example viewer roles:

merchant\_view
hq\_support\_view
ai\_customer\_center\_view
developer\_diagnostic\_view
audit\_view

Core rule:

Evidence must be useful but scoped.

26\. Access Logging

Every Evidence Packet access should be logged.

Recommended fields:

gateway\_access\_id
evidence\_packet\_id
requesting\_system
requesting\_actor\_type
requesting\_actor\_id
tenant\_id
store\_id
request\_id
purpose
view\_type
masking\_applied
fields\_returned
created\_at
trace\_id

Core rule:

Support evidence access is itself an auditable event.

27\. No Mutation Through Evidence

Evidence Packet must not provide mutation controls.

Evidence Packet must not directly allow:

confirm request
complete request
expire request
clear forced cleanup
retry POS
retry KDS
approve refund
grant benefit
edit payment
change settlement

If a support user needs an action, it must be routed through an authorized runtime function, approval flow, or merchant action.

Core rule:

Evidence is read path.
Runtime function is write path.

28\. AI Customer Center Boundary

AI customer center may use Support Signal and Evidence Packet to answer or assist.

AI may:

summarize what happened
draft merchant response
draft guest response
classify issue type
recommend next human action
identify missing evidence

AI must not:

confirm request
complete request
expire request
approve refund
grant benefit
modify POS/KDS/payment/settlement
silently change runtime state

Core rule:

AI can explain and draft.
AI cannot operate Stage 0 runtime.

29\. Evidence Quality Levels

Evidence Packet may indicate quality level.

Suggested values:

COMPLETE
PARTIAL
INCOMPLETE
CONFLICTED
UNAVAILABLE

Meaning:

COMPLETE
\= enough evidence exists to explain normal flow

PARTIAL
\= some evidence exists but important context is missing

INCOMPLETE
\= evidence is insufficient for confident explanation

CONFLICTED
\= evidence contains state or version conflict

UNAVAILABLE
\= evidence cannot be generated or accessed

Evidence quality must not be hidden.

30\. Evidence Gap Notes

When evidence is missing, create an evidence gap note.

Examples:

owner console delivery status missing
notification attempt not recorded
translation version unavailable
guest original memo missing
request version conflict unresolved
state projection mismatch

Evidence gap note may become a knowledge improvement or instrumentation task later.

Core rule:

Missing evidence must be named.
Do not pretend evidence exists.

31\. Support Knowledge Feedback

Repeated support signals may become reviewed support knowledge.

Flow:

raw support signal
→ masked incident summary
→ reviewed known issue pattern
→ troubleshooting SOP
→ support knowledge chunk
→ pgvector embedding

Raw runtime event rows should not be directly embedded into pgvector.

Core rule:

Learn from incidents.
Do not vectorize raw operational truth without review.

32\. Stage 0 MVP Requirements

Stage 0 MVP should include basic support evidence.

Minimum MVP support scope:

request\_id
request\_version
store\_id
business\_date
guest language
selected item summary
critical flags
translation confidence
request state timeline
store confirmation event
guest edit lock event
unconfirmed warning event
forced cleanup event
completion or expiration event
failure event reference
basic support signal
basic Evidence Packet generation

MVP may defer:

full AI customer center
MongoDB support case storage
advanced support routing
complex support dashboard
multi-tenant support analytics
automated refund workflow
legal dispute workflow

33\. Failure Cases

Stage 0 support/evidence failure cases may include:

Support Signal creation failed
Evidence Packet generation failed
Evidence Packet incomplete
Support Gateway access denied
Evidence masking failed
Evidence timeline conflict
State projection mismatch
Trace ID missing

Example failure codes:

WOH.STAGE0.SUPPORT\_SIGNAL.CREATE.FAILED
WOH.STAGE0.EVIDENCE\_PACKET.GENERATE.FAILED
WOH.STAGE0.EVIDENCE\_PACKET.TIMELINE.CONFLICT
WOH.STAGE0.EVIDENCE\_PACKET.MASKING.FAILED
WOH.STAGE0.SUPPORT\_GATEWAY.ACCESS.SCOPE\_DENIED
WOH.STAGE0.STATE.PROJECTION.MISMATCH

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

34\. Merchant-Facing Messages

Merchant-facing messages should remain practical.

Examples:

이 요청은 지원 검토가 필요할 수 있습니다.

요청 이력이 저장되었습니다.
필요 시 지원팀이 확인할 수 있습니다.

미확인 요청이 완료 처리되지 않았습니다.
요청 이력은 보존됩니다.

Avoid exposing internal terms such as:

Evidence Packet
Support Signal
Gateway trace
pgvector
Primary read

unless support mode is enabled.

35\. Guest-Facing Messages

Guest-facing messages should be simple.

Examples:

Please ask staff for help.

This request may need staff confirmation.

This request is no longer active.
Please ask staff or send a new request.

Guest-facing screen should not show internal support signal names by default.

36\. Support-Facing Messages

Support-facing view may show technical context.

Examples:

Support Signal: UNCONFIRMED\_REQUEST\_WARNING
Evidence Quality: PARTIAL
Translation Confidence: LOW
Request Version: 3
State Timeline: REQUESTED → UNCONFIRMED\_WARNING → UNCONFIRMED\_EXPIRED

Support-facing view should include:

request\_id
store\_id
business\_date
trace\_id
evidence\_packet\_id
support\_signal\_id
failure\_code if any

37\. Metrics And Monitoring

Recommended metrics:

support\_signal\_count
support\_signal\_by\_type
evidence\_packet\_generated\_count
evidence\_packet\_quality\_distribution
evidence\_packet\_generation\_failure\_count
support\_gateway\_access\_count
support\_gateway\_scope\_denied\_count
unconfirmed\_warning\_signal\_count
critical\_request\_signal\_count
translation\_signal\_count
state\_transition\_denied\_signal\_count

Metrics should improve support and reliability.

They should not become punitive by default.

38\. Relationship To AI Customer Center

Stage 0 Support Signal and Evidence Packet are inputs to later AI customer center design.

Related future documents may include:

02000\_AI\_Customer\_Center\_Readme.md
02010\_AI\_Customer\_Center\_Foundation.md
02020\_CatchMenu\_Support\_Signal\_And\_Case\_Handoff\_Policy.md
02030\_CatchMenu\_Knowledge\_Retrieval\_pgvector\_Gateway\_Policy.md

Stage 0 should provide support-safe inputs.

AI customer center should own support case and conversation lifecycle.

39\. Relationship To Stage 0 State Guard

This document depends on:

01160\_Stage\_0\_Request\_State\_Transition\_Guard.md

State guard defines valid transitions.

Evidence Packet records transition history.

Support Signal alerts when transition risk exists.

40\. Relationship To Translation Policy

This document depends on:

01180\_Stage\_0\_Translation\_And\_Critical\_Request\_Handling.md

Translation confidence and critical request flags should be included in Evidence Packet when relevant.

41\. Final Statement

Stage 0 must remain light for merchants, but it must not be blind.

Support Signal and Evidence Packet provide the minimum support-safe observability needed to explain request, translation, confirmation, warning, completion, and expiration issues.

Final rule:

Signal the risk.
Preserve the evidence.
Mask what should be masked.
Log every support access.
Explain without mutating.
Escalate without bypassing runtime authority.
