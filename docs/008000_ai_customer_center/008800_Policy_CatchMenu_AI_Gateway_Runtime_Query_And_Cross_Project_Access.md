# 008800_Policy_CatchMenu_AI_Gateway_Runtime_Query_And_Cross_Project_Access.md

## Purpose

This document defines how a future AI Customer Center or AI Gateway may request CatchMenu runtime data across project boundaries.

This document also defines the prohibition of direct cross-database access, cross-database joins, unrestricted FDW, arbitrary SQL generation, and unsafe fallback shortcuts.

This document belongs to the AI Customer Center integration policy group, but it protects CatchMenu runtime ownership.

Core purpose:

AI Customer Center may ask.
CatchMenu Support Gateway decides.
CatchMenu runtime remains protected.

2\. Scope

This document covers:

AI Gateway runtime data requests
same-day operational data lookup
today sales summary lookup
request status lookup
handoff status lookup
POS/KDS handoff status lookup
benefit claim status lookup
Secondary Support View access
Primary runtime read-only last resort
cross-project access boundary
Gateway/API communication
DB link / FDW / cross-database join prohibition
gateway access logging
failure containment reference

This document does not define:

AI Customer Center full case lifecycle
MongoDB case schema
LLM prompt structure
merchant support UI
refund approval workflow
POS/KDS runtime implementation
payment settlement implementation

3\. Core Principle

Runtime data is not knowledge retrieval.

pgvector is used for SOP, policy, FAQ, troubleshooting, known issue, and response template retrieval.

Runtime data must be queried through approved support-safe views or RPC functions.

Core rule:

pgvector \= what policy or SOP applies
SQL / View / RPC \= what actually happened
Evidence Packet \= what facts belong to this case
Gateway log \= who asked, why, what scope, what source, what result

Korean rule:

pgvector는 정책과 SOP 검색용이다.
실시간 운영 데이터는 허용된 view/RPC로만 조회한다.
Evidence Packet은 사건 단위 사실 묶음이다.
모든 접근은 Gateway log에 남긴다.

4\. Separate Gateway Responsibility

The AI Customer Center Gateway and the CatchMenu Support Gateway are separate logical gateways.

They may be deployed on the same physical server during the initial phase.

However, their responsibilities, permissions, logs, and access boundaries must remain separate.

AI Customer Center Gateway
\= support case, conversation, AI agent, response draft, human routing

CatchMenu Support Gateway
\= CatchMenu-owned data, support knowledge, Evidence Packet, Secondary Support View, Primary read-only protection

Core rule:

AI Gateway orchestrates support.
CatchMenu Gateway protects CatchMenu.

5\. Initial Same-Server Deployment Policy

Initial deployment may place CatchMenu Support Gateway, pgvector knowledge retrieval, and AI Customer Center adapter on the same physical server or Supabase environment.

However, logical separation is mandatory from day one.

CatchMenu runtime data, support knowledge, gateway access logs, and AI customer center case/conversation data must not be mixed into one uncontrolled schema.

MongoDB separation is a future physical/data-store migration path.

MongoDB separation is not a reason to delay logical boundaries.

Core rule:

Same physical server is allowed.
Same uncontrolled ownership is not allowed.

6\. Cross-Project Communication Policy

Different Supabase accounts and projects may communicate through approved Gateway/API contracts.

Allowed communication methods:

HTTPS API
Edge Function
approved REST/RPC endpoint
Database Webhook for support signals
message queue or event queue

Prohibited as default integration methods:

direct runtime DB connection
cross-database join
DB link
unrestricted FDW
AI-generated SQL against CatchMenu runtime tables
shared service role key across projects
uncontrolled direct table access

Core rule:

Project-to-project integration must be API/Gateway based, not DB-link based.

7\. No Cross-Database Join Rule

Cross-project database linking, FDW, DB link, and cross-database join must not be used as the default integration model.

Reason:

cross DB join can hide failure origin
remote latency can stall local query
bad filter can trigger broad scan
connection pool can be exhausted
tenant/store scope mistakes can leak data
AI-side query mistakes can affect runtime DB
operational failure can propagate across project boundaries

Korean rule:

DB끼리 붙이지 않는다.
DB 간 JOIN하지 않는다.
AI가 운영 원장에 SQL을 만들지 않는다.
Gateway/API 계약으로만 조회한다.

FDW may be considered later only for support-safe replicated views.

FDW must not be used for unrestricted Primary runtime access.

8\. Runtime Query Classification

The Gateway must classify every runtime data request before any data access.

Suggested query types:

TODAY\_SALES\_SUMMARY
STORE\_DAY\_REQUEST\_SUMMARY
REQUEST\_STATUS\_LOOKUP
WAITING\_STATUS\_LOOKUP
HANDOFF\_STATUS\_LOOKUP
POS\_HANDOFF\_STATUS
KDS\_HANDOFF\_STATUS
BENEFIT\_CLAIM\_STATUS
STAGE\_0C\_UNCONFIRMED\_SUMMARY
OWNER\_CONSOLE\_ALERT\_STATUS
TRANSLATION\_ISSUE\_STATUS
SUPPORT\_SIGNAL\_STATUS
EVIDENCE\_PACKET\_LOOKUP

Unknown natural-language requests must not become arbitrary SQL.

Example:

Natural request:
오늘 판매된 실 데이터를 달라

Gateway classification:
TODAY\_SALES\_SUMMARY

Allowed source:
v\_support\_store\_day\_sales\_summary
or
rpc\_get\_store\_day\_sales\_summary()

9\. Runtime Query Source Order

Runtime data query should follow this order:

1\. Approved support-safe aggregate view
2\. Approved support-safe detail view
3\. Evidence Packet
4\. Secondary Support View
5\. Primary runtime DB read-only last resort

Primary read is not the default.

Primary read is allowed only when:

same-day or active issue
case-specific need exists
approved support-safe view is stale or incomplete
requesting actor has valid scope
Gateway logs the reason
result is masked or minimized

Core rule:

Secondary first.
Primary last.

10\. Today Sales Runtime Query Policy

When the AI Customer Center requests today's sales data, the Gateway must treat it as a runtime query, not pgvector retrieval.

Allowed path:

AI Customer Center Gateway
→ CatchMenu Support Gateway
→ query\_type \= TODAY\_SALES\_SUMMARY
→ tenant/store/date scope validation
→ approved sales summary view or RPC
→ masking/minimization
→ gateway\_access\_log
→ response

Allowed response fields may include:

business\_date
tenant\_id
store\_id
gross\_sales
net\_sales
order\_count
average\_order\_value
menu\_sales\_summary
refund\_count
handoff\_failure\_count
payment\_failure\_count
last\_updated\_at
source\_freshness

Prohibited response fields:

payment credentials
raw card details
unmasked guest identity
unrelated guest contact
unrelated store data
raw payment payload
raw POS payload
raw KDS payload
unscoped transaction rows

11\. Approved View/RPC Only Rule

The AI Customer Center must not generate arbitrary SQL against CatchMenu runtime tables.

All runtime access must be performed through pre-approved support-safe views or RPC functions owned by CatchMenu Support Gateway.

Suggested examples:

v\_support\_store\_day\_sales\_summary
v\_support\_store\_day\_request\_summary
v\_support\_request\_status
v\_support\_handoff\_status
v\_support\_stage\_0c\_unconfirmed\_summary
v\_support\_owner\_console\_alert\_status
v\_support\_translation\_issue\_status

rpc\_get\_store\_day\_sales\_summary()
rpc\_get\_request\_support\_status()
rpc\_get\_handoff\_support\_status()
rpc\_get\_stage\_0c\_unconfirmed\_summary()
rpc\_get\_evidence\_packet()

Core rule:

Natural language request must be translated into an allowed query\_type.
Allowed query\_type must be mapped to an approved view/RPC.

12\. Scope Enforcement

Every runtime query must enforce scope.

Required scope fields:

tenant\_id
store\_id
business\_date or date\_range
request\_id if case-specific
support\_case\_id if available
support\_signal\_id if available
requesting\_system
requesting\_actor\_type
requesting\_actor\_id or service\_identity

The Gateway must deny requests that exceed scope.

Examples of denied requests:

all stores sales without HQ authority
all tenants data
unbounded date range
raw payment rows
guest identity without support need
Primary read without last-resort reason

13\. Masking And Minimization

Runtime query output must be minimized.

The Gateway should return only the fields required for the support purpose.

Masking should apply to:

guest identity
guest contact
merchant private contact
staff identity
payment-sensitive fields
device/session identifiers
external membership identifiers

Support-safe output should prefer:

aggregates
status
counts
timestamps
masked identifiers
case-relevant excerpts
source freshness

14\. Gateway Access Logging

Every runtime data request must create a gateway access log.

Suggested fields:

gateway\_access\_id
requesting\_system
requesting\_actor\_type
requesting\_actor\_id
tenant\_id
store\_id
query\_type
data\_scope
business\_date
date\_range
source\_used
primary\_read\_used
primary\_read\_reason
fields\_returned
row\_count
masking\_applied
purpose
support\_case\_id
support\_signal\_id
trace\_id
created\_at

Example:

{
  "gateway\_access\_id": "gw\_20260610\_00021",
  "requesting\_system": "ai\_customer\_center",
  "requesting\_actor\_type": "ai\_agent",
  "tenant\_id": "tenant\_123",
  "store\_id": "store\_456",
  "query\_type": "TODAY\_SALES\_SUMMARY",
  "data\_scope": "store\_day\_sales\_summary",
  "business\_date": "2026-06-10",
  "source\_used": "secondary\_support\_view",
  "primary\_read\_used": false,
  "fields\_returned": \[
    "gross\_sales",
    "order\_count",
    "menu\_sales\_summary",
    "handoff\_failure\_count"
  \],
  "row\_count": 1,
  "masking\_applied": true,
  "purpose": "support\_runtime\_fact\_check",
  "support\_case\_id": "case\_20260610\_0007",
  "trace\_id": "trace\_20260610\_00021",
  "created\_at": "2026-06-10T15:30:00+09:00"
}

15\. Primary Runtime Read Log Requirement

If Primary runtime DB is used, the Gateway must record why.

Example:

{
  "query\_type": "TODAY\_SALES\_SUMMARY",
  "source\_used": "primary\_runtime\_db",
  "primary\_read\_used": true,
  "primary\_read\_reason": "secondary\_view\_stale\_for\_same\_day\_active\_case",
  "primary\_read\_scope": "store\_id=store\_456,date=2026-06-10,aggregate\_only",
  "masking\_applied": true
}

Primary runtime read must be:

read-only
scoped
audited
rate-limited
masked
last-resort

16\. Runtime Query Response Format

The Gateway should return structured responses.

Suggested response:

{
  "query\_type": "TODAY\_SALES\_SUMMARY",
  "tenant\_id": "tenant\_123",
  "store\_id": "store\_456",
  "business\_date": "2026-06-10",
  "source\_used": "secondary\_support\_view",
  "source\_freshness": "fresh",
  "primary\_read\_used": false,
  "masking\_applied": true,
  "data": {
    "gross\_sales": 1820000,
    "order\_count": 173,
    "average\_order\_value": 10520,
    "handoff\_failure\_count": 2
  },
  "gateway\_access\_id": "gw\_20260610\_00021",
  "trace\_id": "trace\_20260610\_00021"
}

The response must include enough metadata for audit and support review.

17\. Support Signal Push Policy

CatchMenu may push lightweight support signals to the AI Customer Center.

Allowed push payload:

support\_signal\_id
signal\_type
tenant\_id
store\_id
severity\_hint
related\_request\_id
related\_evidence\_packet\_ref
gateway\_lookup\_required
created\_at

Push should not include raw sensitive operational data.

AI Customer Center should pull detailed knowledge or evidence through the CatchMenu Support Gateway.

Core rule:

Push signal.
Pull evidence.
Do not push raw ledger.

18\. Failure Containment

Failures must remain modular, observable, and containable.

A Gateway failure must not become a runtime failure.

A support failure must not become an ordering failure.

A knowledge retrieval failure must not become a Primary DB access shortcut.

A database integration failure must not cascade across projects.

Core rule:

Failure must identify the failed module.
Failure must not collapse into broad runtime access.

Failure/error code naming, diagnostic hierarchy, required failure fields, compiler-style diagnostics, append-only failure records, and unsafe shortcut prohibition are governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

19\. No Unsafe Shortcut Rule

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

20\. Cross-Project Credential Policy

Each project must maintain its own credentials.

Prohibited:

sharing service\_role keys across projects
storing service\_role keys in client code
letting AI-generated code access runtime secrets
using one global key for all tenants
using production Primary credentials for support experiments

Required:

server-side secret only
least privilege
dedicated integration identity
key rotation path
request signing or token validation
Gateway audit

21\. AI Authority Boundary

The AI Customer Center may request data through the Gateway.

The AI Customer Center may draft, summarize, classify, explain, and recommend.

The AI Customer Center must not directly:

confirm request
mark request complete
clear forced cleanup
retry POS handoff
retry KDS handoff
approve refund
grant compensation
mark benefit claimed
mutate payment state
delete evidence
overwrite runtime history

Action requests must be routed to an authorized runtime function or authorized human approval path.

22\. Runtime Query Examples

22.1 General Policy Question

Question:

0C에서 주문확인을 안 누르면 어떻게 되나요?

Path:

pgvector knowledge retrieval
no runtime query
no Evidence Packet unless case-specific

22.2 Case-Specific Request Status

Question:

이 손님 요청이 왜 미확인 만료됐나요?

Path:

pgvector policy retrieval
Evidence Packet
Secondary Support View if needed
Primary read-only only if same-day active and incomplete

22.3 Today Sales Summary

Question:

오늘 판매된 실 데이터를 보여줘

Path:

query\_type \= TODAY\_SALES\_SUMMARY
approved sales summary view/RPC
gateway\_access\_log
aggregate response

22.4 POS Handoff Failure

Question:

방금 POS handoff가 왜 실패했나요?

Path:

pgvector POS handoff troubleshooting
Evidence Packet
handoff support view
Primary read-only only if same-day active and incomplete

22.5 Refund Request

Question:

환불해 주세요

Path:

AI Response Boundary retrieval
Evidence Packet if case-specific
human or authorized runtime route
AI must not approve refund

23\. Observability

Gateway runtime query access should be observable.

Recommended metrics:

runtime\_query\_count\_by\_type
primary\_read\_count
primary\_read\_denied\_count
secondary\_stale\_count
scope\_denied\_count
rate\_limited\_count
cross\_project\_api\_failure\_count
gateway\_timeout\_count
masking\_applied\_count
query\_type\_unknown\_count

Repeated unknown query types should create a diagnostic or knowledge gap note.

24\. Migration Path To External AI Customer Center

The initial phase may use the same physical server or Supabase environment.

Future phase may move AI Customer Center case/conversation data to MongoDB or another external support data store.

Migration must not require changing CatchMenu runtime tables.

Therefore, from day one:

runtime data stays in CatchMenu runtime schema
support knowledge stays in support knowledge schema
Gateway logs stay in gateway/audit schema
AI case/conversation data stays in support-case-owned schema or external store

Core rule:

Future MongoDB separation must be possible without touching CatchMenu runtime tables.

25\. Final Statement

The AI Customer Center may ask for CatchMenu runtime facts, but it must not directly reach into CatchMenu runtime tables.

CatchMenu Support Gateway owns authorization, scope, masking, allowed query type, source selection, Primary read restriction, and access logging.

Project-to-project communication must use Gateway/API contracts.

DB link, unrestricted FDW, cross-database join, and AI-generated SQL against runtime tables are prohibited as default integration models.

Final rule:

Knowledge through pgvector.
Runtime facts through approved view/RPC.
Case facts through Evidence Packet.
Project communication through Gateway/API.
Primary runtime read only as last resort.
Every access logged.
Every failure typed.
No unsafe shortcut.
