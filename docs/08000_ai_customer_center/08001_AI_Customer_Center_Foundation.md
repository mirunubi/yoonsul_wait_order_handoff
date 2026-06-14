08001 AI Customer Center Foundation

1\. Purpose

This document defines the foundation for future AI Customer Center integration with CatchMenu.

The AI Customer Center may become a separate project.

CatchMenu does not implement the full AI Customer Center inside this project.

CatchMenu defines only the support-safe integration boundary, including Support Gateway, support signals, Evidence Packets, support-safe views, pgvector knowledge retrieval, and Primary runtime read restrictions.

2\. Core Principle

CatchMenu is the operational runtime.

AI Customer Center is the support intelligence layer.

They must remain separate.

Core rule:

CatchMenu signals.
Gateway controls.
Knowledge answers.
Evidence explains.
AI drafts.
Authorized human or runtime function acts.

Korean rule:

CatchMenu는 운영 원장을 소유한다.
AI 고객센터는 상담 지능 계층이다.
CatchMenu는 signal, evidence, gateway contract를 제공한다.
AI 고객센터는 support\_case, 상담, 분류, 라우팅을 소유한다.
최종 조치와 상태 변경은 권한 있는 사람 또는 runtime function이 수행한다.

3\. What This Folder Defines

This folder defines:

Support Gateway boundary
support signal policy
case candidate handoff policy
Evidence Packet foundation
pgvector knowledge retrieval policy
AI response boundary
CatchMenu troubleshooting taxonomy
support server strategy
scale-out strategy

This folder does not define:

full AI Customer Center implementation
MongoDB production schema
support agent UI
support SLA
complete case lifecycle engine
chatbot implementation
runtime mutation API
refund approval workflow
legal decision workflow

4\. Project Separation

The AI Customer Center may be developed as a separate system.

Expected AI Customer Center responsibilities:

support\_case creation
support\_case MongoDB / NoSQL storage
conversation history
AI classification
AI summary
AI response draft
human support assignment
HQ escalation
merchant routing
guest response workflow
resolution notes
support analytics

CatchMenu responsibilities:

support signal emission
case candidate hint
Evidence Packet generation
support-safe views
Support Gateway access contract
pgvector support knowledge index
tenant/store boundary
field masking
gateway access audit
Secondary-first support lookup
Primary read-only last-resort policy
runtime mutation boundary

5\. Support Gateway First

The AI Customer Center must not directly query CatchMenu operational tables.

All access must pass through Support Gateway.

Default access order:

1\. Supabase pgvector SOP / Policy / FAQ / Troubleshooting retrieval
2\. Evidence Packet
3\. Secondary Support View
4\. Primary runtime DB read-only last resort

The AI Customer Center should not start from Primary runtime data.

The Gateway decides which source is allowed.

6\. Knowledge First Policy

CatchMenu-related support should begin with knowledge retrieval.

The Support Gateway should first search:

SOP
policy documents
FAQ
troubleshooting guides
known issue patterns
response templates
merchant onboarding guides
guest help documents
incident postmortems

Initial retrieval layer:

Supabase PostgreSQL \+ pgvector

Important note:

pgvector is a PostgreSQL vector extension.
It is not NoSQL.

MongoDB or another NoSQL database may be used by the AI Customer Center for support cases and conversations.

7\. CatchMenu-Side pgvector Requirement

CatchMenu must maintain a support knowledge retrieval layer in its Supabase/PostgreSQL environment.

This does not mean embedding raw operational rows.

Correct approach:

SOP / policy / FAQ / troubleshooting / known issue / response template
→ chunk
→ embedding
→ pgvector retrieval

Incorrect approach:

raw request rows
raw waiting rows
raw handoff rows
raw event rows
→ default embedding corpus

Core rule:

Embed support knowledge.
Do not embed raw operational ledger by default.
Use Evidence Packets to connect runtime facts with support knowledge.

8\. Support Signal Policy

CatchMenu may emit support signals when a support-relevant condition occurs.

Support Signal is not a support case.

Support Signal is not a resolution.

Support Signal is not a mutation command.

Examples:

UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
LOW\_CONFIDENCE\_TRANSLATION
CRITICAL\_REQUEST\_DETECTED
STORE\_CONFIRMATION\_DELAY
OWNER\_CONSOLE\_ALERT\_FAILURE
QR\_ACCESS\_FAILURE
QR\_WRONG\_STORE\_SUSPECTED
POS\_HANDOFF\_FAILED
KDS\_HANDOFF\_FAILED
BENEFIT\_CLAIM\_FAILED

Support signals should carry minimal identifiers and evidence references.

They should not carry full raw operational data.

9\. Evidence Packet Policy

Evidence Packet is the support-safe fact bundle.

It may include:

support\_case\_id or case candidate ref
tenant\_id
store\_id
guest\_session\_id masked
request\_id
waiting\_id
handoff\_id
POS reference
KDS reference
event timeline
translation context
request status
store confirmation status
error context
device context
masked contact fields
policy references

Evidence Packet is not operational truth.

Evidence Packet is not mutation authority.

Core rule:

Evidence Packet \= support review artifact
Operational DB \= runtime source of truth
Authorized runtime function \= mutation authority

10\. Secondary First Policy

When operational facts are needed, Gateway should use Secondary Support View first.

Secondary Support View may contain:

replicated event timelines
support-safe request status
translation context
handoff context
owner console issue context
benefit routing context
masked guest/store context

Purpose:

protect Primary runtime DB
reduce operational risk
support AI review without touching live runtime
separate support traffic from store operation traffic

11\. Primary Runtime Read Last Resort

Primary runtime DB read is allowed only when strictly necessary.

Allowed only if:

case is same-day or active
Evidence Packet is incomplete
Secondary Support View is stale or missing
query is case-scoped
access is read-only
access is audited
Gateway authorizes the access

Primary DB read is prohibited for:

general FAQ
broad analytics
unrelated guest history
unrelated store history
raw payment credentials
raw auth/session data
bulk support browsing
AI direct query
state mutation
audit deletion
silent correction

Core rule:

Primary runtime DB is not the AI support search engine.

12\. AI Allowed Functions

AI Customer Center may:

retrieve SOP
classify issue
summarize evidence
summarize timeline
identify missing evidence
draft guest response
draft merchant response
prepare support note
recommend escalation
detect knowledge gap

AI Customer Center must not:

confirm order
cancel order
mark request completed
clear forced cleanup
retry POS handoff
retry KDS handoff
approve refund
grant compensation
mark benefit claimed
modify POS state
modify KDS state
decide legal fault
delete evidence
overwrite audit history

13\. Runtime Mutation Boundary

Support handoff must not become a mutation path.

If operational action is required, the path must be:

AI recommends
→ human or authorized support role reviews
→ authorized CatchMenu runtime function or Store/HQ action executes
→ audit event recorded

Prohibited path:

AI reads issue
→ AI directly mutates CatchMenu state

14\. Stage 0C Critical Rule

Stage 0C support must preserve the confirmed/unconfirmed distinction.

Core rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

Unconfirmed requests may be:

warned
shown in top warning
forced into cleanup
expired as unconfirmed

but must not silently become completed orders.

15\. Troubleshooting Scope

CatchMenu support integration must support many troubleshooting families.

Examples:

QR / Access Issue
Language / Translation Issue
Menu / Option Issue
Guest Request Issue
Store Confirmation Issue
Stage 0C Unconfirmed Request Issue
Waiting / Arrival Issue
POS Handoff Issue
KDS Handoff Issue
Benefit Routing Issue
Owner Console Issue
Notification Issue
Device / Browser Issue
Policy / Usage Confusion
Abuse / Dispute / Safety Issue

Each issue family should map to:

support signal type
knowledge retrieval category
required Evidence Packet fields
allowed AI response type
escalation rule

16\. Support Server Direction

The future AI Customer Center may use:

MongoDB / NoSQL \= support cases, conversations, summaries, drafts, routing
Supabase PostgreSQL \+ pgvector \= CatchMenu SOP / policy / FAQ / troubleshooting retrieval
Secondary Support View \= support-safe operational context
Primary runtime DB \= read-only last resort

This separation protects CatchMenu runtime while allowing AI support to scale.

17\. Scale-Out Direction

The scale-out direction is:

Knowledge scales first.
Support signals scale second.
Evidence packets scale third.
Secondary support views scale fourth.
Primary runtime reads remain limited.

The system should scale by expanding:

pgvector knowledge index
support signal queue
known issue patterns
Evidence Packet generation
support-safe views
retrieval logs
knowledge gap feedback loop
tenant-specific support knowledge

It must not scale by giving AI direct operational authority.

18\. Security And Masking

CatchMenu must minimize support data exposure.

Support handoff must not expose:

payment credentials
auth tokens
session secrets
raw personal data
unmasked guest contact
unmasked staff contact
internal secret keys
private tenant secrets
unrelated guest history
unrelated store data
cross-tenant evidence

All Gateway access should record:

gateway\_access\_id
requesting\_system
tenant\_id
store\_id
access\_source
access\_reason
primary\_read\_used
fields\_returned
masking\_applied
created\_at

19\. Design Status

This document is an architecture and policy foundation.

It is not implementation.

No runtime tables, APIs, queues, pgvector index, MongoDB schema, or support server should be implemented solely from this document without separate implementation design.

20\. Final Statement

CatchMenu prepares support-safe signals, evidence, knowledge retrieval, and Gateway access for a future AI Customer Center.

AI Customer Center uses those inputs to classify, summarize, draft, and escalate support work.

Operational truth stays in CatchMenu runtime.

Support case workflow stays in the AI Customer Center project.

Final authority stays with authorized humans or authorized runtime functions.

Core rule:

CatchMenu signals.
Gateway controls.
Knowledge answers.
Evidence explains.
AI drafts.
Authorized human or runtime function acts.
