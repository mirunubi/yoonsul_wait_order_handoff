# 000080_Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy

1\. Purpose

This document defines the failure/error code naming hierarchy for CatchMenu, Support Gateway, AI Customer Center integration, pgvector retrieval, Evidence Packet, runtime query, POS/KDS handoff, and cross-project communication.

Failure and error messages must be structured like compiler diagnostics.

A failure must identify:

which system failed
which module failed
which adapter failed
which operation failed
which stage failed
which scope was affected
which fallback was attempted
which diagnostic trace can be followed

Core principle:

A vague error cannot improve the system.
A structured failure code can become resilience data.

Korean principle:

오류는 뭉뚱그리면 안 된다.
컴파일러처럼 어느 시스템, 어느 파트, 어느 단계, 어떤 원인인지 추적 가능해야 한다.

2\. Failure Code Hierarchy

Failure codes should follow this hierarchy:

\<SYSTEM\>.\<DOMAIN\>.\<MODULE\>.\<OPERATION\>.\<FAILURE\_TYPE\>

Example:

CM.SUPPORT.KNOWLEDGE.SEARCH.TIMEOUT
CM.SUPPORT.EVIDENCE.GENERATE.INCOMPLETE
CM.RUNTIME.REQUEST.CONFIRM.DENIED
CM.GATEWAY.RUNTIME\_QUERY.SCOPE.DENIED
CM.POS.HANDOFF.SEND.TIMEOUT
CM.KDS.HANDOFF.ACCEPT.REJECTED
AI.CASE.RESPONSE.DRAFT.BOUNDARY\_DENIED

Where:

SYSTEM \= product or system boundary
DOMAIN \= functional area
MODULE \= runtime component or adapter
OPERATION \= attempted action
FAILURE\_TYPE \= typed failure reason

3\. System Prefix

Suggested system prefixes:

CM      \= CatchMenu
CMGW    \= CatchMenu Support Gateway
CMRT    \= CatchMenu Runtime
CMSK    \= CatchMenu Support Knowledge
CMEP    \= CatchMenu Evidence Packet
CMPOS   \= CatchMenu POS Adapter
CMKDS   \= CatchMenu KDS Adapter
CMNTF   \= CatchMenu Notification Adapter
AICC    \= AI Customer Center
AIGW    \= AI Customer Center Gateway
SUP     \= Support Server
EXT     \= External System

Examples:

CMGW.RUNTIME\_QUERY.SALES\_SUMMARY.SCOPE\_DENIED
CMSK.PGVECTOR.SEARCH.TIMEOUT
CMEP.REQUEST\_PACKET.GENERATE.INCOMPLETE
AICC.RESPONSE.DRAFT.BOUNDARY\_REQUIRED

4\. Domain Values

Suggested domain values:

RUNTIME
SUPPORT
GATEWAY
KNOWLEDGE
PGVECTOR
EVIDENCE
REQUEST
WAITING
I18N
TRANSLATION
OWNER\_CONSOLE
NOTIFICATION
POS
KDS
BENEFIT
AUTH
TENANT
STORE
PRIMARY\_READ
SECONDARY\_VIEW
RUNTIME\_QUERY
CROSS\_PROJECT
AI\_RESPONSE
SUPPORT\_CASE
AUDIT

5\. Operation Values

Suggested operation values:

SEARCH
GENERATE
READ
WRITE
SEND
RECEIVE
CONFIRM
COMPLETE
LOCK
UNLOCK
CLASSIFY
MASK
AUTHORIZE
ESCALATE
RETRY
SYNC
REFRESH
INDEX
EMBED
ROUTE
VALIDATE
LOG

6\. Failure Type Values

Suggested failure type values:

TIMEOUT
UNAVAILABLE
DENIED
SCOPE\_DENIED
AUTH\_FAILED
RATE\_LIMITED
NO\_MATCH
STALE
INCOMPLETE
INVALID\_STATE
INVALID\_SCOPE
INVALID\_PAYLOAD
MISSING\_REQUIRED\_FIELD
CONFLICT
VERSION\_CONFLICT
LOW\_CONFIDENCE
BOUNDARY\_DENIED
POLICY\_DENIED
FALLBACK\_DENIED
FALLBACK\_FAILED
PRIMARY\_READ\_DENIED
SECONDARY\_STALE
QUEUE\_DELAYED
ADAPTER\_REJECTED
REMOTE\_REJECTED
UNKNOWN

"UNKNOWN" should be allowed only as a temporary failure type.

If "UNKNOWN" appears repeatedly, it must create a knowledge gap or diagnostic gap note.

7\. Diagnostic Location Format

Each failure should preserve a diagnostic location.

Suggested format:

system=\<system\>
domain=\<domain\>
module=\<module\>
adapter=\<adapter\>
operation=\<operation\>
stage=\<stage\>
source=\<source\>
target=\<target\>
scope=\<tenant/store/date/request\>
trace=\<trace\_id\>

Example:

system=CMGW
domain=RUNTIME\_QUERY
module=sales\_summary\_query
adapter=secondary\_support\_view\_adapter
operation=READ
stage=authorize\_scope
source=ai\_customer\_center\_gateway
target=v\_support\_store\_day\_sales\_summary
scope=tenant\_123/store\_456/2026-06-10
trace=trace\_20260610\_00021

8\. Compiler-Style Diagnostic Message

Internal diagnostic messages should follow a compiler-style pattern.

Format:

\<FAILURE\_CODE\>: \<short message\>
at \<system\>/\<domain\>/\<module\>/\<operation\>
scope \<tenant\_id\>/\<store\_id\>/\<business\_date\>
source \<source\>
target \<target\>
trace \<trace\_id\>
hint \<next diagnostic action\>

Example:

CMGW.RUNTIME\_QUERY.SALES\_SUMMARY.SCOPE\_DENIED:
AI Customer Center requested sales summary outside allowed store scope.
at CMGW/RUNTIME\_QUERY/sales\_summary\_query/AUTHORIZE
scope tenant\_123/store\_999/2026-06-10
source ai\_customer\_center\_gateway
target v\_support\_store\_day\_sales\_summary
trace trace\_20260610\_00021
hint verify support\_case store\_id and requesting actor scope.

9\. Message Layer Separation

Failure messages must be separated by audience.

guest\_message
merchant\_message
support\_message
developer\_diagnostic
audit\_record

The same failure may produce different messages.

Example failure code:

CMNTF.OWNER\_CONSOLE.ALERT.SEND.UNAVAILABLE

Guest message:

요청 처리 중 문제가 발생했습니다. 직원에게 확인해주세요.

Merchant message:

손님 요청 알림 전송이 지연되었습니다. 주문 확인 화면을 새로고침해주세요.

Support message:

Owner console alert delivery failed. Request was created, but notification delivery did not complete.

Developer diagnostic:

CMNTF.OWNER\_CONSOLE.ALERT.SEND.UNAVAILABLE:
websocket session unavailable during owner console alert delivery.
at CMNTF/OWNER\_CONSOLE/notification\_adapter/SEND
scope tenant\_123/store\_456/request\_req\_789
fallback top\_banner\_warning queued
trace trace\_20260610\_00033

10\. Required Failure Event Fields

Every failure event should include:

failure\_event\_id
failure\_code
failure\_family
system\_code
domain\_code
module\_code
adapter\_code
operation\_code
failure\_type
severity
tenant\_id
store\_id
business\_date
related\_request\_id
related\_support\_case\_id
related\_support\_signal\_id
related\_evidence\_packet\_id
source\_system
target\_system
source\_attempted
target\_attempted
operation\_attempted
failure\_stage
failure\_reason
retryable
fallback\_allowed
fallback\_attempted
fallback\_result
primary\_read\_attempted
primary\_read\_allowed
masking\_applied
guest\_message\_code
merchant\_message\_code
support\_message
developer\_diagnostic
trace\_id
gateway\_access\_id
created\_at

11\. Failure Families

Suggested failure families:

KNOWLEDGE\_RETRIEVAL\_FAILURE
EVIDENCE\_PACKET\_FAILURE
RUNTIME\_QUERY\_FAILURE
GATEWAY\_AUTH\_FAILURE
GATEWAY\_SCOPE\_FAILURE
CROSS\_PROJECT\_COMMUNICATION\_FAILURE
PRIMARY\_READ\_FAILURE
SECONDARY\_VIEW\_FAILURE
TRANSLATION\_FAILURE
OWNER\_CONSOLE\_FAILURE
NOTIFICATION\_FAILURE
POS\_HANDOFF\_FAILURE
KDS\_HANDOFF\_FAILURE
BENEFIT\_ROUTING\_FAILURE
AI\_RESPONSE\_BOUNDARY\_FAILURE
SUPPORT\_CASE\_FAILURE
AUDIT\_LOG\_FAILURE

12\. Severity Mapping

Suggested severity values:

P0 \= safety / legal / privacy / payment critical
P1 \= active store operation blocked
P2 \= active guest or merchant issue requiring same-day response
P3 \= non-urgent support issue
P4 \= FAQ / usage guidance

Failure code examples:

CM.I18N.TRANSLATION.CRITICAL\_REQUEST.LOW\_CONFIDENCE \= P0 or P1
CMGW.RUNTIME\_QUERY.SALES\_SUMMARY.SCOPE\_DENIED \= P1 or P2
CMSK.PGVECTOR.SEARCH.NO\_MATCH \= P3 or P4
CMNTF.OWNER\_CONSOLE.ALERT.SEND.UNAVAILABLE \= P2
CMPOS.HANDOFF.SEND.TIMEOUT \= P1 or P2
CMKDS.HANDOFF.ACCEPT.REJECTED \= P1 or P2

13\. Fallback Naming

Fallback should have its own typed result.

Suggested fallback result values:

NOT\_ALLOWED
NOT\_REQUIRED
ATTEMPTED\_SUCCESS
ATTEMPTED\_FAILED
QUEUED
ESCALATED\_TO\_HUMAN
ESCALATED\_TO\_HQ
USED\_CACHED\_KNOWLEDGE
USED\_SECONDARY\_VIEW
USED\_PRIMARY\_READ\_ONLY
DEFERRED

Example:

failure\_code \= CMSK.PGVECTOR.SEARCH.TIMEOUT
fallback\_allowed \= true
fallback\_attempted \= USED\_CACHED\_KNOWLEDGE
fallback\_result \= ATTEMPTED\_SUCCESS

Example:

failure\_code \= CMEP.REQUEST\_PACKET.GENERATE.INCOMPLETE
fallback\_allowed \= true
fallback\_attempted \= USED\_SECONDARY\_VIEW
fallback\_result \= ATTEMPTED\_SUCCESS

Example:

failure\_code \= CMSK.PGVECTOR.SEARCH.TIMEOUT
fallback\_allowed \= false
fallback\_result \= NOT\_ALLOWED
reason \= knowledge retrieval failure does not authorize Primary runtime read

14\. No Unsafe Shortcut Rule

A failed module must not automatically open a more dangerous path.

Rules:

pgvector failure does not authorize Primary DB read.
AI Gateway failure does not authorize CatchMenu Gateway bypass.
Secondary stale does not automatically authorize Primary read.
Cross-project API failure does not authorize DB link or FDW.
Evidence Packet failure does not authorize raw operational table access.

Core rule:

Do not replace one failed module with an unsafe shortcut.

Korean rule:

한 모듈이 실패했다고 해서 더 위험한 우회로를 자동으로 열지 않는다.

15\. Failure Data Integrity Rule

Failure records must be append-only.

A recovery must not overwrite the original failure.

Recovery should create a linked event:

failure\_event
→ recovery\_attempt\_event
→ recovery\_success\_event

or:

failure\_event
→ recovery\_attempt\_event
→ recovery\_failed\_event

Core rule:

Failure must not be erased by recovery.
Recovery must be linked to failure.

16\. From Failure To Knowledge

Failure records can become resilience knowledge only after review.

Raw failure logs must not be embedded directly into pgvector.

Required path:

raw failure event
→ masked incident summary
→ reviewed known issue pattern
→ troubleshooting SOP
→ support knowledge chunk
→ pgvector embedding

This protects:

privacy
tenant boundary
runtime integrity
diagnostic quality
support answer safety

17\. Example Failure Codes

17.1 pgvector Search Timeout

CMSK.PGVECTOR.SEARCH.TIMEOUT

Meaning:

Support knowledge search timed out.

Safe fallback:

cached knowledge if available
human support escalation
knowledge retrieval retry

Unsafe fallback:

Primary runtime DB read

17.2 Evidence Packet Incomplete

CMEP.REQUEST\_PACKET.GENERATE.INCOMPLETE

Meaning:

Evidence Packet could not collect all required case facts.

Safe fallback:

Secondary Support View lookup
human support review

17.3 Runtime Query Scope Denied

CMGW.RUNTIME\_QUERY.SALES\_SUMMARY.SCOPE\_DENIED

Meaning:

Requested sales summary exceeded allowed tenant/store/date scope.

Safe fallback:

deny request
log gateway access
ask for corrected scope

17.4 Primary Read Denied

CMGW.PRIMARY\_READ.REQUEST\_STATUS.POLICY\_DENIED

Meaning:

Primary runtime read was requested but did not meet last-resort policy.

Safe fallback:

return policy denial
use available evidence
human support review

17.5 Owner Console Alert Failure

CMNTF.OWNER\_CONSOLE.ALERT.SEND.UNAVAILABLE

Meaning:

Owner console alert could not be delivered.

Safe fallback:

top banner warning
queue retry
support signal

17.6 AI Response Boundary Denied

AICC.AI\_RESPONSE.REFUND\_APPROVAL.BOUNDARY\_DENIED

Meaning:

AI attempted or was requested to approve a refund, but refund approval is outside AI authority.

Safe fallback:

draft escalation summary
route to authorized human or runtime function

18\. Final Statement

Failure/error naming is part of system architecture.

A failure code must not merely say that something failed.

It must reveal:

where it failed
what failed
why it likely failed
what was affected
what was not affected
what fallback was attempted
what evidence was preserved
what should happen next

Final principle:

Failure is the mother of reliability.
But only precise, structured, and traceable failure data can become reliable system knowledge.
