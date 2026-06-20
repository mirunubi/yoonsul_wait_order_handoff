# 008600_Plan_Support_Server_Strategy.md

## Purpose

This document defines the support server strategy for future AI Customer Center integration with CatchMenu.

The AI Customer Center may become a separate project and server.

CatchMenu remains the operational runtime.

The AI Customer Center should not directly own or mutate CatchMenu runtime state.

This document defines the server separation, database separation, Gateway access model, retrieval model, and Primary/Secondary read strategy.

2\. Core Principle

AI Customer Center must be separated from CatchMenu runtime.

Core rule:

CatchMenu owns operational truth.
Support Gateway controls access.
Supabase pgvector provides CatchMenu support knowledge.
Secondary Support View provides support-safe operational context.
Primary Runtime DB is read-only last resort.
AI Customer Center owns support cases and conversations.

Korean rule:

CatchMenu는 운영 원장을 소유한다.
AI 고객센터는 상담/케이스/대화/요약을 소유한다.
AI 고객센터는 Support Gateway를 통해서만 CatchMenu 지식과 증거를 조회한다.
Primary 원장 조회는 당일/진행 중 이슈에서만 read-only 최후 수단으로 허용한다.

3\. High-Level Architecture

Recommended architecture:

Guest / Merchant / Store Issue
→ CatchMenu Runtime Event or Support Signal
→ Support Gateway
→ Supabase pgvector Knowledge Retrieval
→ Evidence Packet / Secondary Support View
→ Primary Runtime DB read-only last resort
→ AI Customer Center Support Server
→ MongoDB / NoSQL Support Case DB
→ Human Support / HQ / Merchant / Authorized Runtime Action

The AI Customer Center should never bypass Support Gateway for CatchMenu runtime data.

4\. System Responsibilities

4.1 CatchMenu Runtime

CatchMenu owns:

guest request state
waiting state
store confirmation state
handoff state
translation events
POS/KDS handoff context
benefit candidate context
support signal events
operational event history
runtime audit references

CatchMenu provides:

Support Gateway contract
support signal emission
Evidence Packet generation
support-safe views
pgvector knowledge index
Secondary-first lookup policy
Primary read restriction policy
masking and tenant boundary

4.2 Support Gateway

Support Gateway owns controlled access.

Gateway responsibilities:

knowledge retrieval routing
Evidence Packet lookup
Secondary Support View lookup
Primary read authorization
field masking
tenant/store boundary enforcement
case scope enforcement
access audit
rate limiting
freshness check
retrieval trace

4.3 AI Customer Center Support Server

AI Customer Center owns support work.

AI Customer Center may own:

support case creation
support case MongoDB document
conversation history
AI classification
AI summary
response draft
human review queue
HQ escalation
merchant routing
guest response workflow
resolution notes
support analytics
knowledge gap feedback

AI Customer Center does not own CatchMenu runtime mutation.

5\. Database Separation

The support architecture should separate database responsibilities.

CatchMenu Operational DB
\= runtime truth

CatchMenu Support Knowledge DB / Schema
\= SOP, policy, FAQ, troubleshooting, known issue, response template embeddings

Secondary Support View
\= support-safe replicated runtime context

AI Customer Center MongoDB / NoSQL
\= support cases, conversations, AI summaries, drafts, routing, resolution notes

No single support database should become the operational source of truth.

6\. MongoDB / NoSQL Support Case DB

AI Customer Center may use MongoDB or another NoSQL database for support cases.

Reason:

support cases are document-shaped
conversation histories vary by case
AI summaries evolve over time
evidence references differ by issue type
routing metadata may change
human support notes are flexible

MongoDB may store:

support\_case
support\_conversation
ai\_session
ai\_summary
ai\_response\_draft
case\_classification
human\_review\_note
hq\_escalation\_note
merchant\_response\_thread
guest\_response\_thread
resolution\_note
knowledge\_gap\_note

MongoDB must not store or become:

CatchMenu order ledger
POS transaction ledger
KDS execution ledger
payment ledger
benefit claim ledger
audit source of truth

7\. Supabase pgvector Knowledge Strategy

CatchMenu must maintain a support knowledge retrieval layer in Supabase PostgreSQL \+ pgvector.

Important note:

pgvector is a PostgreSQL vector extension.
It is not NoSQL.

pgvector is used for:

SOP retrieval
policy retrieval
FAQ retrieval
troubleshooting guide retrieval
known issue pattern retrieval
response template retrieval
merchant onboarding guide retrieval
guest help guide retrieval
incident postmortem retrieval

MongoDB stores support cases.

pgvector retrieves CatchMenu knowledge.

CatchMenu runtime tables store operational truth.

8\. CatchMenu-Side Support Knowledge Tables

CatchMenu-side Supabase may include support knowledge tables such as:

support\_documents
support\_document\_chunks
support\_chunk\_embeddings
troubleshooting\_taxonomy
known\_issue\_patterns
response\_templates
retrieval\_logs
knowledge\_gap\_notes

These tables are separate from runtime request/waiting/handoff tables.

Core rule:

Embed support knowledge.
Do not embed raw operational ledger by default.
Use Evidence Packets to connect runtime facts with retrieved knowledge.

9\. Support Gateway Read Order

Support Gateway must use the following read order:

1\. pgvector Knowledge Retrieval
2\. Evidence Packet
3\. Secondary Support View
4\. Primary Runtime DB read-only last resort

Gateway must not read Primary DB merely for convenience.

General support questions should be answered from knowledge.

Case-specific issues require Evidence Packet.

Only active same-day issues with incomplete evidence may require limited Primary read.

10\. Knowledge-First Support Flow

General support inquiry:

AI Customer Center receives inquiry
→ Support Gateway searches pgvector
→ AI drafts answer from retrieved SOP / FAQ
→ no runtime DB read

Examples:

Does CatchMenu require POS?
Does the guest need to install an app?
What does “store confirmed” mean?
What happens if the owner does not press “주문 확인”?
Is SMS/Kakao required?

These should not touch Primary runtime DB.

11\. Evidence-Based Case Flow

Case-specific inquiry:

AI Customer Center receives case-specific inquiry
→ Support Gateway searches relevant SOP first
→ Support Gateway retrieves Evidence Packet
→ AI summarizes known timeline
→ AI identifies missing evidence
→ AI drafts response or recommends escalation

Examples:

Why did this request expire?
Did this store confirm the request?
Was this guest edit the latest version?
Did POS handoff fail?
Was KDS notified?

12\. Secondary-First Operational Context

Secondary Support View should be the default source for support-safe operational context.

Secondary may contain:

replicated support timelines
request status summaries
store confirmation summaries
translation context
POS/KDS handoff summaries
benefit routing summaries
masked guest context
masked store context
owner console issue context

Purpose:

protect Primary Runtime DB
separate support traffic from store operation traffic
allow async support review
reduce live runtime risk

13\. Primary Runtime DB Last Resort

Primary Runtime DB read is allowed only when strictly necessary.

Allowed conditions:

case is same-day or active
Evidence Packet is incomplete
Secondary Support View is stale or missing
query is case-scoped
access is read-only
Gateway authorizes the access
access is audited

Primary read must be denied for:

general FAQ
broad analytics
bulk support browsing
unrelated guest history
unrelated tenant data
raw payment credentials
raw auth/session data
state mutation
audit deletion
silent correction

Core rule:

Primary Runtime DB is not the AI support search engine.

14\. Support Signal Push Strategy

CatchMenu may push support signals to the support system.

Support signal examples:

UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
LOW\_CONFIDENCE\_TRANSLATION
CRITICAL\_REQUEST\_DETECTED
STORE\_CONFIRMATION\_DELAY
OWNER\_CONSOLE\_ALERT\_FAILURE
QR\_ACCESS\_FAILURE
POS\_HANDOFF\_FAILED
KDS\_HANDOFF\_FAILED
BENEFIT\_CLAIM\_FAILED

Support signals should carry minimal payload.

They may include:

signal\_id
signal\_type
tenant\_id
store\_id
severity\_hint
related\_request\_id
related\_handoff\_id
evidence\_packet\_ref
created\_at
gateway\_lookup\_required

Support signal is not a support case.

The AI Customer Center decides whether to create a support case.

15\. Gateway Pull Strategy

Default support lookup should be pull-based.

AI Customer Center asks Support Gateway for:

knowledge retrieval
Evidence Packet
support-safe timeline
Secondary Support View
Primary read request if allowed

Pull is preferred because it supports:

case-scoped access
masking
tenant boundary
access audit
rate limiting
freshness control

16\. Push / Pull Combined Model

Recommended combined model:

CatchMenu pushes lightweight support signals.
AI Customer Center pulls knowledge and evidence through Gateway.

This avoids sending too much operational data while still allowing urgent support awareness.

17\. Runtime Mutation Boundary

AI Customer Center must not mutate CatchMenu runtime through the support server.

Prohibited:

confirm request
cancel request
mark completed
clear forced cleanup
retry POS handoff
retry KDS handoff
change waiting status
change seating status
approve refund
grant compensation
mark benefit claimed
modify POS state
modify KDS state
delete evidence
overwrite audit history

Allowed path:

AI recommends
→ human or authorized support role reviews
→ authorized CatchMenu runtime function or Store/HQ action executes
→ audit event recorded

18\. Support Server Degraded Mode

If AI Customer Center or Support Gateway is unavailable, CatchMenu runtime must continue.

Support degradation must not stop:

QR menu
guest request
store confirmation
waiting
handoff
POS/KDS fallback
Stage 0C owner confirmation

Degraded support behavior:

support signals queued
AI response unavailable
SOP search delayed
Evidence Packet generation delayed
manual support fallback
Primary DB remains protected

Core rule:

Support failure must not become ordering failure.

19\. Security And Masking

Support Server and Gateway must minimize sensitive data.

Do not expose:

payment credentials
auth tokens
session secrets
raw personal data
unmasked guest contact
unmasked staff contact
raw IP address unless explicitly allowed
device fingerprint
internal secret keys
private tenant secrets
unrelated guest history
unrelated store data
cross-tenant evidence

Masking examples:

010-\*\*\*\*-1234
g\*\*\*@example.com
guest\_anon\_4839
staff\_masked\_1021

20\. Tenant Isolation

For SaaS and franchise use, tenant isolation is mandatory.

Support Gateway must ensure:

tenant A cannot retrieve tenant B evidence
tenant A cannot retrieve tenant B private SOP
tenant A cannot retrieve tenant B store data
tenant-specific knowledge does not leak
store-specific issue data is case-scoped

Knowledge visibility levels may include:

global
brand\_specific
tenant\_specific
store\_specific
internal\_only

21\. Observability

Support Server strategy requires observability.

Recommended metrics:

support\_signal\_count
support\_signal\_queue\_lag
gateway\_query\_count
pgvector\_retrieval\_latency
retrieval\_no\_result\_count
Evidence Packet create count
Evidence Packet refresh count
Secondary sync lag seconds
Primary read count
Primary read denied count
AI escalation count
knowledge gap count
issue family distribution
tenant support volume

22\. Audit Requirement

Every Gateway access should be recorded.

Suggested audit fields:

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

23\. Suggested Phase Plan

Phase 1 — CatchMenu Knowledge Retrieval

Supabase pgvector support knowledge
basic SOP / FAQ / troubleshooting documents
Support Gateway retrieval endpoint
manual Evidence Packet concept

Phase 2 — Support Signal And Evidence Packet

support\_signal\_events
case candidate hints
Evidence Packet generation
support-safe timelines
retrieval logs

Phase 3 — Secondary Support View

support-safe replicated views
Secondary-first operational lookup
freshness metadata
Primary read restriction policy

Phase 4 — External AI Customer Center

separate AI Customer Center support server
MongoDB / NoSQL case DB
conversation history
AI summary / classification / draft
human escalation
Gateway pull \+ signal push

Phase 5 — SaaS / Franchise Scale

tenant-specific support knowledge
brand policy layering
known issue feedback loop
support signal queue
support analytics
multi-language response templates

24\. Final Statement

The AI Customer Center should be an external support intelligence server.

It should use MongoDB or another NoSQL database for support cases and conversations.

It should use CatchMenu Supabase PostgreSQL \+ pgvector for SOP, policy, FAQ, troubleshooting, known issue, and response template retrieval.

It should access CatchMenu operational context only through Support Gateway.

It should use Secondary Support View by default and Primary Runtime DB only as read-only last resort.

Core rule:

MongoDB stores support work.
pgvector retrieves support knowledge.
Gateway controls access.
Secondary protects runtime.
Primary remains guarded.
AI assists.
Authorized humans or runtime functions act.
