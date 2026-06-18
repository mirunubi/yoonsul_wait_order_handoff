# 008000_Readme_AI_Customer_Center

1\. Purpose

This folder defines how CatchMenu prepares for future AI Customer Center integration.

The AI Customer Center may become a separate project.

This folder does not implement the AI Customer Center.

This folder defines what CatchMenu must provide so that a future AI Customer Center can safely retrieve knowledge, receive support signals, review evidence, and assist support work.

## 2 In Scope

- AI customer support.
- SOP retrieval.
- pgvector RAG.
- Answer control.
- Support evidence.
- Customer-safe response.
- AI gateway boundary.
- Escalation to human support.
- FAQ/documentation feedback loop.
- Non-authoritative AI response limits.

## 3 Relationship Notes

- `08000` owns AI customer center and AI support gateway behavior.
- `03000` owns SaaS runtime/session authority.
- `05000` owns customer handoff flow.
- `07000` owns support/admin console operator surfaces.
- Foundation Security governs identity minimization, sensitive data masking, secret non-exposure, logging/audit/evidence, retention, incident response, and AI/Agent data limits.
- AI customer center must not mutate payment truth, KDS release truth, refund authority, reconciliation conclusion, credential state, or identity reveal state.
- AI may recommend or draft; approved runtime or authorized human role must execute authority-sensitive actions.

2\. Core Boundary

CatchMenu is the operational runtime.

AI Customer Center is the support intelligence layer.

CatchMenu must not become the support case management system.

AI Customer Center must not become the operational authority of CatchMenu.

Core rule:

CatchMenu signals.
Gateway controls.
Knowledge answers.
Evidence explains.
AI drafts.
Authorized human or runtime function acts.

3\. What CatchMenu Owns

CatchMenu owns:

support signal emission
evidence packet generation
support-safe views
Support Gateway access contract
pgvector support knowledge index
tenant/store boundary
field masking
Secondary-first support lookup policy
Primary read-only last-resort policy
gateway access audit
runtime mutation boundary

CatchMenu does not own:

AI Customer Center support\_case lifecycle
AI 상담 대화 저장
AI 상담원 배정
AI 고객센터 MongoDB case 원장
상담 SLA
상담원/HQ/매장 라우팅 운영
최종 환불/보상/법적 판단

4\. What AI Customer Center Owns

The AI Customer Center may own:

support\_case creation
support case MongoDB / NoSQL storage
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

These are outside CatchMenu runtime ownership.

5\. Access Principle

The AI Customer Center must not directly query CatchMenu operational tables.

All access must pass through Support Gateway.

Default access order:

1\. Supabase pgvector SOP / Policy / FAQ / Troubleshooting retrieval
2\. Evidence Packet
3\. Secondary Support View
4\. Primary runtime DB read-only last resort

Primary DB read is allowed only when:

same-day or active issue
Evidence Packet is incomplete
Secondary Support View is stale or missing
query is case-scoped
access is read-only
access is audited
Gateway authorizes the access

6\. pgvector Principle

CatchMenu must maintain a support knowledge retrieval layer.

This does not mean adding vector embeddings to every operational runtime row.

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

7\. Folder Documents

08000\_AI\_Customer\_Center\_Foundation.md

Defines the overall philosophy and boundary between CatchMenu and the future AI Customer Center.

Focus:

AI support is separate
AI is not operational authority
CatchMenu provides support-safe integration surfaces

08100\_CatchMenu\_Support\_Signal\_And\_Case\_Handoff\_Policy.md

Defines how CatchMenu emits support signals and hands off case candidate references.

Focus:

support\_signal
case\_candidate\_hint
evidence\_packet\_ref
Gateway access contract
AI Customer Center owns support\_case lifecycle

08200\_CatchMenu\_Knowledge\_Retrieval\_pgvector\_Gateway\_Policy.md

Defines how CatchMenu knowledge is searched through Supabase PostgreSQL \+ pgvector.

Focus:

Knowledge first
Evidence second
Secondary Support View third
Primary runtime read last

08300\_AI\_Response\_Boundary.md

Defines what AI may and may not say or do.

Focus:

AI may explain, summarize, draft, classify, recommend
AI must not decide, approve, mutate, refund, compensate, penalize, or legally conclude

08400\_CatchMenu\_Troubleshooting\_Foundation.md

Defines issue families and troubleshooting categories.

Focus:

QR / Access
Translation
Menu / Option
Guest Request
Store Confirmation
Stage 0C Unconfirmed Request
Waiting / Arrival
POS / KDS Handoff
Benefit Routing
Owner Console
Notification
Device / Browser
Policy Confusion
Safety / Dispute

08500\_Evidence\_Packet\_Foundation.md

Defines the support-safe evidence bundle.

Focus:

case-scoped facts
masked fields
timeline
request context
translation context
handoff context
Stage 0C context
gateway freshness
primary read trace

08600\_Support\_Server\_Strategy.md

Defines the external support server strategy.

Focus:

AI Customer Center as separate support server
MongoDB / NoSQL for support cases
Supabase pgvector for SOP retrieval
Secondary-first lookup
Primary read-only last resort

08700\_Scale\_Out\_Strategy.md

Defines how this support architecture scales.

Focus:

knowledge scale-out
support signal queue
evidence packet versioning
secondary support view
tenant isolation
known issue patterns
retrieval logs
Primary DB protection

8\. Support Flow Summary

General question:

AI Customer Center
→ Support Gateway
→ pgvector SOP / FAQ retrieval
→ answer or draft

Case-specific issue:

AI Customer Center
→ Support Gateway
→ pgvector policy retrieval
→ Evidence Packet
→ response draft / escalation

Active same-day issue:

AI Customer Center
→ Support Gateway
→ pgvector policy retrieval
→ Evidence Packet
→ Secondary Support View
→ Primary read-only lookup only if strictly required

Operational action required:

AI recommends
→ human or authorized support role reviews
→ authorized CatchMenu runtime function or Store/HQ action executes
→ audit event recorded

9\. Prohibited Paths

The following paths are prohibited:

AI Customer Center → raw Primary DB direct query
AI Customer Center → direct runtime mutation
AI Customer Center → direct POS/KDS state change
AI Customer Center → direct refund approval
AI Customer Center → direct benefit claim approval
AI Customer Center → unmasked broad guest data retrieval
AI Customer Center → cross-tenant evidence access
AI Customer Center → audit/evidence overwrite

10\. Stage 0C Critical Rule

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

11\. AI Response Rule

AI may:

retrieve SOP
summarize evidence
explain policy
draft guest response
draft merchant response
recommend escalation
identify missing evidence

AI must not:

confirm order
cancel order
mark completed
clear forced cleanup
retry POS/KDS handoff
approve refund
grant compensation
mark benefit claimed
decide legal fault
delete evidence
overwrite audit

12\. Design Status

This folder is an architecture and policy foundation.

It is not implementation.

No runtime tables, APIs, queues, pgvector index, MongoDB schema, or support server should be implemented solely from this folder without separate implementation design.

13\. Final Statement

CatchMenu prepares support-safe signals, evidence, knowledge retrieval, and Gateway access.

The future AI Customer Center uses those inputs to classify, summarize, draft, and escalate support work.

Operational truth stays in CatchMenu runtime.

Support case workflow stays in the AI Customer Center project.

Final authority stays with authorized humans or authorized runtime functions.

## Document List

| document | description |
| --- | --- |
| `08001_AI_Customer_Center_Foundation.md` | 08001_AI_Customer_Center_Foundation. |
| `08100_Policy_CatchMenu_Support_Signal_And_Case_Handoff.md` | 08100_Policy_CatchMenu_Support_Signal_And_Case_Handoff. |
| `08200_Policy_CatchMenu_Knowledge_Retrieval_pgvector_Gateway.md` | 08200_Policy_CatchMenu_Knowledge_Retrieval_pgvector_Gateway. |
| `08300_Boundary_AI_Response.md` | 08300_Boundary_AI_Response. |
| `08400_CatchMenu_Troubleshooting_Foundation.md` | 08400_CatchMenu_Troubleshooting_Foundation. |
| `08500_Evidence_Packet_Foundation.md` | 08500_Evidence_Packet_Foundation. |
| `08600_Support_Server_Strategy.md` | 08600_Support_Server_Strategy. |
| `08700_Scale_Out_Strategy.md` | 08700_Scale_Out_Strategy. |
| `08800_Policy_CatchMenu_AI_Gateway_Runtime_Query_And_Cross_Project_Access.md` | 08800_Policy_CatchMenu_AI_Gateway_Runtime_Query_And_Cross_Project_Access. |
