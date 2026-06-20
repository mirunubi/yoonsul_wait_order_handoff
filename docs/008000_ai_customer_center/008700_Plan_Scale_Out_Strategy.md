# 008700_Plan_Scale_Out_Strategy.md

## Purpose

This document defines the scale-out strategy for CatchMenu AI Customer Center integration.

CatchMenu may produce many support signals, troubleshooting cases, translation issues, POS/KDS handoff issues, owner console issues, and tenant-specific questions.

The AI Customer Center may become a separate project.

Therefore, CatchMenu must define a scalable handoff strategy without allowing AI support traffic to overload or mutate the operational runtime.

2\. Core Principle

CatchMenu support integration must scale without weakening runtime safety.

Core rule:

Knowledge scales first.
Support signals scale second.
Evidence packets scale third.
Secondary support views scale fourth.
Primary runtime reads remain limited.

Korean rule:

지식 검색을 먼저 확장한다.
Support Signal 처리를 그다음 확장한다.
Evidence Packet 처리를 그다음 확장한다.
Secondary Support View를 그다음 확장한다.
Primary 원장 조회는 끝까지 제한한다.

3\. Scale-Out Layers

CatchMenu AI support scale-out should be separated into layers.

1\. Knowledge Retrieval Layer
2\. Support Signal Layer
3\. Evidence Packet Layer
4\. Support Gateway Layer
5\. Secondary Support View Layer
6\. Primary Runtime Read Layer
7\. AI Customer Center Case Layer

Each layer must scale independently.

4\. Knowledge Retrieval Layer Scale-Out

The first scale-out target is the support knowledge layer.

CatchMenu should maintain pgvector-based support knowledge in Supabase/PostgreSQL.

Knowledge sources may include:

SOP
policy documents
FAQ
troubleshooting guides
known issue patterns
response templates
merchant onboarding guides
guest help documents
incident postmortems

Knowledge retrieval should answer general questions without operational DB access.

Examples:

Does CatchMenu require POS?
What happens if the owner does not press “주문 확인”?
Does Stage 0C support app payment?
Can foreign guests use their own language?
What does forced cleanup mean?

These should be answered from pgvector-indexed knowledge.

No Evidence Packet or Primary DB read should be used for general questions.

5\. Support Knowledge Index Scale Policy

CatchMenu should not embed raw operational rows as the default retrieval corpus.

Correct approach:

SOP / policy / FAQ / troubleshooting / known issue / response template
→ chunk
→ embedding
→ pgvector retrieval

Incorrect approach:

every request row
every waiting row
every handoff row
every raw event row
→ embedding

Raw operational facts should remain in runtime tables.

Support-safe summaries may be embedded only after masking and normalization.

6\. Knowledge Partitioning

As CatchMenu scales, the knowledge index should support partitioning by:

stage
tenant
brand
country
language
audience
issue family
module
document version

Suggested partition dimensions:

stage\_0a / stage\_0b / stage\_0c / stage\_1 / stage\_2 / stage\_3 / stage\_4 / stage\_5
guest / merchant / hq\_support / developer / internal\_policy
qr\_access / translation / pos\_handoff / kds\_handoff / benefit\_routing / owner\_console
ko / en / ja / zh / es / vi / th

Tenant-specific knowledge must not leak to other tenants.

7\. Support Signal Layer Scale-Out

CatchMenu may emit many support signals.

Examples:

UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
LOW\_CONFIDENCE\_TRANSLATION
CRITICAL\_REQUEST\_DETECTED
POS\_HANDOFF\_FAILED
KDS\_HANDOFF\_FAILED
OWNER\_CONSOLE\_ALERT\_FAILURE
QR\_ACCESS\_FAILURE
BENEFIT\_CLAIM\_FAILED

Support signals should be lightweight.

They should not carry full raw operational data.

They should carry:

signal\_id
signal\_type
tenant\_id
store\_id
severity\_hint
created\_at
related\_request\_id
related\_handoff\_id
evidence\_packet\_ref
gateway\_lookup\_required

8\. Support Signal Queue Strategy

At scale, support signals should be routed through a queue or event stream.

Possible strategy:

CatchMenu runtime
→ support\_signal\_events
→ support\_signal\_queue
→ Support Gateway / AI Customer Center consumer

The queue must support:

retry
deduplication
rate limiting
dead-letter handling
tenant isolation
priority handling

Support signal failure must not block store operations.

Core rule:

Support signal delivery failure must not stop CatchMenu runtime.

9\. Signal Deduplication

Repeated signals must be deduplicated.

Examples:

same request triggers multiple unconfirmed warnings
same POS handoff fails repeatedly
same KDS adapter timeout repeats
same QR code failure is reported by many guests

Deduplication keys may include:

tenant\_id
store\_id
signal\_type
request\_id
handoff\_id
time\_window
issue\_family

Deduplication prevents AI Customer Center overload.

10\. Signal Severity Routing

Signals should be routed by severity.

Suggested severity:

P0 \= safety / legal / privacy / payment critical
P1 \= active store operation blocked
P2 \= same-day guest or merchant issue
P3 \= non-urgent support issue
P4 \= FAQ or low-risk guidance

Routing example:

P0 → immediate human/HQ escalation
P1 → support queue \+ operations alert
P2 → AI triage \+ support review
P3 → AI triage
P4 → knowledge retrieval only

AI must not finalize P0 cases alone.

11\. Evidence Packet Layer Scale-Out

Evidence Packets are the case-scoped support fact bundle.

At scale, Evidence Packets should be generated:

on demand
on support signal trigger
on case candidate creation
on human support request
on high-severity incident

Not every operational event requires an Evidence Packet.

Evidence Packet creation should be controlled to prevent unnecessary load.

12\. Evidence Packet Freshness Strategy

Evidence Packets should include freshness metadata.

Required fields:

packet\_created\_at
packet\_refreshed\_at
source\_freshness
secondary\_sync\_lag\_seconds
primary\_read\_used
primary\_read\_reason
gateway\_access\_log\_id

If a packet is stale, the Support Gateway may refresh it from Secondary Support View.

Primary read should remain last resort.

13\. Evidence Packet Versioning

Evidence Packets should be versioned.

Example:

evidence\_packet\_v1 \= initial packet
evidence\_packet\_v2 \= refreshed from Secondary Support View
evidence\_packet\_v3 \= refreshed after limited Primary read

Versioning rule:

Do not silently overwrite evidence.
Create a new packet version.
Preserve packet lineage.

14\. Support Gateway Scale-Out

Support Gateway is the access boundary.

At scale, Gateway must enforce:

tenant boundary
store boundary
case scope
field masking
rate limiting
audit logging
source selection
freshness check
Primary read restriction

The Gateway should be horizontally scalable.

Gateway failure should degrade support functions, not store runtime.

Core rule:

Support Gateway failure must not block ordering, waiting, POS handoff, or KDS handoff.

15\. Gateway Read Order At Scale

Even at scale, Gateway read order must remain:

1\. pgvector knowledge retrieval
2\. Evidence Packet
3\. Secondary Support View
4\. Primary DB read-only last resort

Gateway must not optimize by directly reading Primary DB for convenience.

16\. Secondary Support View Scale-Out

Secondary Support View exists to protect Primary runtime DB.

Secondary may contain:

replicated event timelines
support-safe request status
translation context
handoff context
owner console issue context
benefit routing context
masked guest/store context

Secondary sync should be monitored.

Important metrics:

sync\_lag\_seconds
replication\_failure\_count
support\_view\_refresh\_time
stale\_view\_count
evidence\_packet\_refresh\_failure\_count

If Secondary is stale, Gateway may mark:

secondary\_stale \= true

Primary read still requires strict conditions.

17\. Primary Runtime Read Protection

Primary runtime DB must be protected.

Primary read is allowed only when:

same-day or active issue
Evidence Packet incomplete
Secondary Support View stale or missing
case-scoped query
read-only access
audited access
authorized Gateway path

Primary read is prohibited for:

general FAQ
broad analytics
unrelated guest history
unrelated store history
raw payment credential access
raw auth/session access
bulk support browsing
AI direct query

Core rule:

Primary runtime DB is not the AI support search engine.

18\. MongoDB / AI Customer Center Case DB Scale-Out

The AI Customer Center may use MongoDB or another NoSQL store for:

support cases
conversations
AI summaries
AI drafts
case tags
routing metadata
human review notes
resolution notes
support analytics

MongoDB may scale independently from CatchMenu runtime.

However, MongoDB must not become the operational source of truth.

Core rule:

MongoDB owns support case workflow.
CatchMenu owns operational runtime truth.

19\. Tenant Isolation

For SaaS and franchise expansion, tenant isolation is mandatory.

Support Gateway and retrieval layers must ensure:

tenant A cannot retrieve tenant B support evidence
tenant A cannot retrieve tenant B private SOP
tenant A cannot retrieve tenant B store data
tenant-specific FAQ does not leak to other tenants

Knowledge chunks should include tenant or visibility metadata:

global
brand\_specific
tenant\_specific
store\_specific
internal\_only

20\. Brand / Franchise Scale-Out

For franchise or white-label tenants, support knowledge may be layered.

Recommended knowledge layering:

global CatchMenu policy
→ brand policy
→ tenant policy
→ store exception
→ current incident SOP

Retrieval should prefer the most specific applicable policy.

Example:

store-specific rule
beats tenant rule
beats brand rule
beats global rule

However, runtime safety boundaries still override tenant preference.

21\. Multilingual Scale-Out

As foreign guest support expands, knowledge retrieval and response templates must support multiple languages.

Recommended language strategy:

Korean internal policy remains canonical.
Guest-facing response templates may be localized.
Merchant-facing guides may be Korean-first.
Critical safety templates must be controlled and reviewed.

Critical categories requiring careful localization:

allergy
food safety
pork
alcohol
religious dietary restriction
medical caution
payment/refund
legal/privacy

AI must not freely improvise high-risk translations without boundary checks.

22\. Known Issue Pattern Scale-Out

At scale, recurring issues should become known issue patterns.

Example flow:

repeated support signals
→ support-safe incident summary
→ known\_issue\_pattern
→ troubleshooting SOP
→ pgvector embedding
→ future retrieval

Known issue examples:

specific browser blocks owner console sound
specific POS adapter times out at lunch peak
Stage 0C owners often miss forced cleanup
foreign guests confuse request sent with order confirmed
QR sticker from old store is reused accidentally

Known issue patterns must be support-safe and masked.

23\. Incident Summary Embedding

Raw event logs should not be embedded directly.

Correct flow:

raw event logs
→ masked incident summary
→ reviewed known issue pattern
→ embedding

This prevents leakage of personal or operationally sensitive data into the knowledge index.

24\. Retrieval Log Scale-Out

Retrieval logs should be retained for quality and audit.

Retrieval log fields:

retrieval\_log\_id
gateway\_access\_id
query\_text
query\_language
retrieved\_chunk\_ids
scores
selected\_chunks
evidence\_packet\_used
secondary\_used
primary\_used
created\_at

Retrieval logs help identify:

knowledge gaps
bad retrieval
repeated confusion
missing SOP
deprecated policy usage
support answer drift

25\. Knowledge Gap Feedback Loop

When AI cannot find policy, the system should create a knowledge gap note.

Knowledge gap fields:

query\_text
missing\_topic
issue\_family
stage
audience
tenant\_id\_if\_specific
suggested\_document
created\_at
review\_status

Knowledge gap review should result in:

new FAQ
new troubleshooting guide
updated SOP
new response template
known issue pattern
policy clarification

This allows support quality to improve over time.

26\. Rate Limit Strategy

Support Gateway should apply rate limits.

Rate limit dimensions:

tenant\_id
store\_id
support\_case\_id
AI Customer Center client
query type
Primary read request
Evidence Packet refresh request

Primary read should have the strictest rate limit.

27\. Cache Strategy

Support knowledge retrieval may use caching.

Cache candidates:

common FAQ retrieval
stage policy summaries
response templates
known issue lookups
merchant onboarding guidance

Do not cache unmasked case-specific evidence broadly.

Case-specific evidence cache must be:

short-lived
case-scoped
tenant-scoped
audit-aware
masking-preserved

28\. Degraded Mode

If AI Customer Center or Support Gateway is degraded, CatchMenu runtime must continue.

Degraded support behavior:

AI response unavailable
SOP search unavailable
Evidence Packet delayed
Support signal queued
Primary DB protected
manual support fallback

CatchMenu runtime must continue handling:

QR menu
guest request
store confirmation
waiting
handoff
POS/KDS fallback

Support degradation must not become ordering degradation.

29\. Observability Metrics

Scale-out requires observability.

Recommended metrics:

support\_signal\_count
support\_signal\_queue\_lag
support\_signal\_dedup\_count
evidence\_packet\_create\_count
evidence\_packet\_refresh\_count
gateway\_query\_count
pgvector\_retrieval\_latency
retrieval\_no\_result\_count
secondary\_sync\_lag\_seconds
primary\_read\_count
primary\_read\_denied\_count
primary\_read\_reason\_distribution
AI\_escalation\_count
knowledge\_gap\_count
tenant\_support\_volume
issue\_family\_distribution

30\. Alerting Conditions

Alerts should be triggered for:

Primary read spike
Secondary sync lag high
support signal queue backlog
Evidence Packet generation failure
pgvector retrieval unavailable
retrieval no-result spike
P0 issue detected
tenant isolation violation suspicion
repeated POS/KDS handoff failures
owner console issue spike

31\. Data Retention Strategy

Support data retention should differ by data type.

Suggested retention categories:

raw operational events \= operational retention policy
Evidence Packets \= support/audit retention policy
support signals \= shorter operational support retention
retrieval logs \= support quality retention
known issue patterns \= long-lived knowledge
response templates \= versioned policy retention
support case conversations \= AI Customer Center retention policy

Sensitive data should be minimized and masked.

32\. Security Boundary

Scale-out must not weaken security.

The following must remain prohibited:

AI direct Primary DB access
unmasked broad guest data retrieval
cross-tenant support evidence leakage
embedding raw secrets
embedding payment credentials
embedding auth/session tokens
AI runtime mutation through Gateway
silent evidence overwrite

33\. Upgrade Path

The scale-out path may proceed in phases.

Phase 1 — Single Supabase Knowledge Index

CatchMenu Supabase pgvector
basic SOP/FAQ/troubleshooting
Support Gateway retrieval
manual Evidence Packet

Phase 2 — Support Signal Queue

support\_signal\_events
signal queue
deduplication
severity routing
Evidence Packet references

Phase 3 — Secondary Support View

replicated support-safe views
secondary-first support lookup
freshness metadata
Primary read restriction

Phase 4 — AI Customer Center Separation

external AI Customer Center
MongoDB support case DB
Gateway pull
Signal push
conversation storage
AI summary/draft
human escalation

Phase 5 — Franchise / SaaS Scale

tenant-specific knowledge
brand policy layering
multi-language templates
support analytics
known issue pattern feedback loop

34\. Final Statement

CatchMenu AI support scale-out must be knowledge-first, gateway-controlled, evidence-scoped, and Primary-protective.

The system should scale by expanding knowledge, signals, evidence packets, secondary support views, and support case infrastructure.

It must not scale by giving AI direct access to operational authority.

Core rule:

Knowledge scales.
Signals notify.
Evidence explains.
Secondary protects.
Primary remains guarded.
AI assists.
Authorized humans or runtime functions act.
