08200 CatchMenu Knowledge Retrieval pgvector Gateway Policy

1\. Purpose

This document defines how CatchMenu knowledge retrieval should be exposed to a future AI Customer Center through the Support Gateway.

The AI Customer Center may become a separate project.

CatchMenu must not allow the AI Customer Center to start support handling by directly reading operational records.

The first layer of support response should be knowledge retrieval.

Core purpose:

AI Customer Center
→ Support Gateway
→ CatchMenu SOP / Policy / FAQ / Troubleshooting retrieval
→ Evidence Packet only when case-specific facts are required

2\. Core Principle

CatchMenu-related support should follow a knowledge-first model.

Core rule:

Knowledge first.
Evidence second.
Secondary support view third.
Primary runtime read last.

Korean rule:

지식 검색 우선.
증거 패킷은 그다음.
Secondary Support View는 그다음.
Primary 원장 조회는 최후 수단.

The AI Customer Center should not query CatchMenu runtime data when the issue can be answered from SOP, policy, FAQ, or troubleshooting documents.

3\. Gateway Boundary

The AI Customer Center must access CatchMenu knowledge through the Support Gateway.

The AI Customer Center should not directly access:

raw CatchMenu operational tables
unrestricted Supabase tables
Primary runtime DB
unmasked guest records
unmasked merchant records
auth/session data
payment-sensitive fields

The Support Gateway controls:

retrieval scope
document set
tenant/store context
language
audience
case type
issue family
access audit
retrieval trace

4\. pgvector Role

The initial knowledge retrieval store may use:

Supabase PostgreSQL \+ pgvector

Important note:

pgvector is a PostgreSQL vector extension.
It is not NoSQL.

The AI Customer Center may use MongoDB or another NoSQL database for support cases and conversations.

However:

MongoDB \= support case / conversation / AI summary storage
pgvector \= SOP / policy / FAQ / troubleshooting retrieval
CatchMenu operational DB \= runtime source of truth

5\. Knowledge Retrieval Position In Support Flow

The recommended support flow is:

1\. User or system raises an inquiry.
2\. AI Customer Center asks Support Gateway for relevant knowledge.
3\. Gateway searches pgvector-indexed CatchMenu documents.
4\. AI drafts an answer from retrieved documents.
5\. If the issue is case-specific, Gateway retrieves Evidence Packet.
6\. If Evidence Packet is incomplete, Gateway may use Secondary Support View.
7\. If same-day/active issue still cannot be resolved, Gateway may use Primary DB read-only last resort.

The AI should not skip directly to operational data.

6\. Retrieval Sources

The pgvector retrieval store may index CatchMenu and support policy documents.

Suggested document sources:

01010\_CatchMenu\_Service\_Concept
01020\_CatchMenu\_Stage\_0\_POS\_Less\_Menu\_Request\_Policy
01030\_CatchMenu\_Guest\_And\_Merchant\_Positioning
01040\_CatchMenu\_I18n\_Order\_Request\_Translation\_Policy
01050\_CatchMenu\_Module\_Option\_And\_Product\_Package\_Policy

08000\_AI\_Customer\_Center\_Foundation
08100\_CatchMenu\_Support\_Signal\_And\_Case\_Handoff\_Policy
08200\_CatchMenu\_Knowledge\_Retrieval\_pgvector\_Gateway\_Policy
08300\_AI\_Response\_Boundary
08400\_CatchMenu\_Troubleshooting\_Foundation
08500\_Evidence\_Packet\_Foundation
08600\_Support\_Server\_Strategy
08700\_Scale\_Out\_Strategy

Additional future sources:

guest FAQ
merchant FAQ
owner console SOP
Stage 0A guest webapp guide
Stage 0B owner console guide
Stage 0C request confirmation guide
POS handoff troubleshooting guide
KDS handoff troubleshooting guide
benefit routing guide
known issue guide
incident postmortem
support response template
merchant onboarding guide

7\. Retrieval Categories

Knowledge should be tagged by category.

Suggested retrieval categories:

product\_concept
guest\_help
merchant\_help
stage\_policy
i18n\_policy
module\_package\_policy
troubleshooting
evidence\_policy
support\_gateway\_policy
ai\_response\_boundary
support\_server\_strategy
scale\_out\_strategy
faq
known\_issue
incident\_resolution

8\. Audience Tags

Knowledge chunks should include audience tags.

Suggested audience values:

guest
merchant
store\_owner
store\_staff
hq\_support
ai\_customer\_center
support\_gateway
developer
internal\_policy

Examples:

guest \= simple user-facing help
merchant \= owner-facing product or troubleshooting explanation
hq\_support \= escalation and resolution guidance
developer \= implementation-facing reference
internal\_policy \= boundary and governance

AI response style should depend on audience.

9\. Stage Tags

Knowledge chunks should include CatchMenu stage tags.

Suggested stage values:

stage\_0a
stage\_0b
stage\_0c
stage\_1
stage\_2
stage\_3
stage\_4
stage\_5
all\_stages

Examples:

stage\_0a \= QR menu \+ show-to-staff
stage\_0b \= send request to owner web console
stage\_0c \= POS-less request confirmation board
stage\_1 \= manual POS handoff
stage\_2 \= Mini KDS / kitchen assist
stage\_3 \= POS Adapter
stage\_4 \= POS \+ KDS Adapter
stage\_5 \= SaaS / white label / benefit routing

10\. Issue Family Tags

Knowledge chunks should include issue family tags.

Suggested issue families:

qr\_access
language\_translation
menu\_option
guest\_request
store\_confirmation
stage\_0c\_unconfirmed\_request
waiting\_arrival
pos\_handoff
kds\_handoff
benefit\_routing
owner\_console
notification
device\_browser
policy\_usage\_confusion
abuse\_dispute\_safety
general\_support

These tags should align with "08400\_CatchMenu\_Troubleshooting\_Foundation.md".

11\. Severity Tags

Knowledge chunks may include severity tags.

Suggested severity values:

P0
P1
P2
P3
P4

Meaning:

P0 \= safety / legal / privacy / payment critical
P1 \= active store operation blocked
P2 \= active guest or merchant issue requiring same-day response
P3 \= non-urgent support issue
P4 \= FAQ / usage guidance

Severity tags help the AI determine whether it may answer directly or must escalate.

12\. Document Chunk Metadata

Each indexed chunk should preserve enough metadata to support reliable retrieval.

Suggested metadata:

doc\_id
doc\_number
doc\_title
section\_number
section\_title
chunk\_id
source\_path
category
audience
stage
module
issue\_family
severity
language
effective\_version
deprecated
replaced\_by
last\_reviewed\_at

The AI Customer Center should not treat deprecated chunks as current policy unless explicitly reviewing history.

13\. Chunking Policy

Documents should be chunked by semantic section, not arbitrary token size only.

Recommended chunk unit:

document section
subsection
policy rule block
FAQ item
troubleshooting issue family
response template

A chunk should generally preserve:

rule
exception
boundary
allowed action
prohibited action
escalation condition

Avoid separating a rule from its exception.

14\. Retrieval Query Types

The Support Gateway should support different query types.

14.1 General FAQ Query

Example:

손님이 앱을 설치해야 하나요?

Expected retrieval:

guest FAQ
01030 Guest And Merchant Positioning
01020 Stage 0 policy

No Evidence Packet required.

14.2 Merchant Usage Query

Example:

POS가 없어도 쓸 수 있나요?

Expected retrieval:

01020 Stage 0 POS-less policy
01050 Module Option Package Policy
merchant FAQ

No Evidence Packet required.

14.3 Troubleshooting Query

Example:

주문 확인을 안 눌렀는데 완료로 바뀌나요?

Expected retrieval:

01020 Stage 0C policy
08400 Troubleshooting
08500 Evidence Packet if case-specific

Evidence Packet only if the question refers to a specific request.

14.4 Case-Specific Query

Example:

방금 손님 요청이 왜 미확인 만료됐나요?

Expected retrieval:

SOP first
Evidence Packet second
Secondary Support View if needed
Primary DB only if same-day active and incomplete

14.5 Critical Issue Query

Example:

알러지 요청 번역이 잘못된 것 같습니다.

Expected retrieval:

01040 I18n Translation Policy
08400 Language / Translation Issue
08300 AI Response Boundary
Evidence Packet
human escalation

15\. Retrieval Before Evidence Rule

If the inquiry is general, answer from knowledge.

If the inquiry is case-specific, retrieve knowledge first, then evidence.

Rule:

General question
→ pgvector knowledge only

Case-specific question
→ pgvector knowledge
→ Evidence Packet

Active unresolved same-day issue
→ pgvector knowledge
→ Evidence Packet
→ Secondary Support View
→ Primary read-only last resort

16\. Primary DB Avoidance Rule

Knowledge retrieval exists to reduce unnecessary Primary DB access.

The AI Customer Center must not request Primary DB read just because a user asks a general policy question.

Examples that should not use Primary DB:

How does Stage 0C auto-completion work?
Does CatchMenu require POS?
Does the guest need to install an app?
What does “store confirmed” mean?
What languages are supported?
Is SMS/Kakao required?

Examples that may require evidence or Primary read:

Did this specific request get confirmed today?
Why did this specific POS handoff fail?
Was this guest request locked after confirmation?
Did this benefit claim fail today?

17\. Answer Grounding Policy

AI Customer Center answers should be grounded in retrieved knowledge.

The response should distinguish:

policy answer
case-specific fact
inference
missing evidence
escalation requirement

If retrieved knowledge is insufficient, AI should not guess.

Suggested response behavior:

I can explain the policy.
I need the Evidence Packet to verify this specific request.
This requires human support review.

18\. Retrieval Trace

The Support Gateway or AI Customer Center should keep a retrieval trace.

Suggested trace fields:

retrieval\_trace\_id
support\_case\_id
support\_signal\_id
gateway\_access\_id
query\_text
query\_language
retrieved\_doc\_ids
retrieved\_chunk\_ids
scores
selected\_chunks
answer\_generated
evidence\_packet\_used
secondary\_used
primary\_used
created\_at

Retrieval trace helps with:

support quality review
policy correction
AI answer audit
hallucination reduction
incident review

19\. Language Policy

Knowledge retrieval should support Korean-first internal policy and multilingual support responses.

Document language may be:

ko
en
mixed

Guest-facing answers may need to be generated in the guest language.

The AI Customer Center should retrieve Korean/internal policy if needed, then produce safe guest-language output according to response boundary.

For critical cases, translation should preserve caution and escalation language.

20\. Response Template Retrieval

The retrieval store may include response templates.

Template categories:

guest\_explanation
merchant\_instruction
owner\_console\_help
hq\_escalation\_summary
technical\_support\_note
human\_handoff\_note

Templates must be boundary-safe.

They must not authorize AI to execute operational actions.

21\. Deprecated Policy Handling

Some documents may be revised or replaced.

The retrieval layer must track whether a chunk is deprecated.

Suggested fields:

deprecated \= true / false
replaced\_by
effective\_from
effective\_until

Default behavior:

retrieve current policy first
ignore deprecated chunks unless historical review is requested

22\. Knowledge Refresh Policy

The retrieval index must be refreshed when policy documents change.

Suggested triggers:

new document added
document section changed
policy version updated
FAQ updated
known issue added
incident postmortem published
response template revised

Refresh should preserve:

doc version
chunk version
embedding version
index update time

23\. Missing Knowledge Policy

If the retrieval layer cannot find relevant policy, AI should not invent policy.

Allowed response:

No matching CatchMenu policy was found.
This should be escalated or reviewed by support.

The AI Customer Center may create a knowledge gap note.

Suggested knowledge gap fields:

query\_text
missing\_topic
case\_type
suggested\_document
created\_at
review\_status

24\. Security And Data Boundary

The knowledge retrieval layer should not contain raw sensitive operational data.

Do not index:

payment credentials
auth tokens
session secrets
raw personal data
unmasked guest contact
unmasked staff contact
internal secret keys
private tenant secrets

If example data is needed, use masked or synthetic examples.

25\. Gateway Retrieval Output

The Support Gateway should return structured retrieval results.

Suggested output:

query\_id
retrieved\_chunks
doc\_references
policy\_summary
confidence\_hint
escalation\_hint
evidence\_needed
allowed\_response\_type
prohibited\_response\_type

Example:

{
  "query\_id": "q\_20260610\_0010",
  "policy\_summary": "Stage 0C unconfirmed requests must not be auto-completed.",
  "evidence\_needed": false,
  "escalation\_hint": false,
  "allowed\_response\_type": "merchant\_guidance",
  "prohibited\_response\_type": "runtime\_mutation"
}

26\. Allowed AI Use

The AI Customer Center may use retrieval results to:

answer general FAQ
explain CatchMenu policy
guide merchant troubleshooting
draft guest response
draft merchant response
prepare HQ escalation summary
identify missing evidence
recommend support next step

27\. Prohibited AI Use

The AI Customer Center must not use retrieval results to directly:

confirm request
mark request complete
clear forced cleanup
retry POS handoff
retry KDS handoff
approve refund
grant compensation
mark benefit claimed
decide legal fault
delete evidence
overwrite operational history

Policy retrieval explains what should happen.

It does not execute what should happen.

28\. Example Retrieval Mapping

28.1 “외국인이 메뉴를 자기 언어로 볼 수 있나요?”

Retrieve:

01030 Guest And Merchant Positioning
01040 I18n Order Request Translation Policy
01020 Stage 0 policy

Answer type:

guest\_or\_merchant\_guidance

Evidence needed:

no

28.2 “0C에서 주문확인을 안 누르면 어떻게 되나요?”

Retrieve:

01020 Stage 0C policy
08400 Stage 0C Unconfirmed Request Issue
08500 Evidence Packet Foundation

Answer type:

merchant\_guidance

Evidence needed:

only if asking about a specific request

28.3 “이 요청이 왜 미확인 만료됐나요?”

Retrieve:

01020 Stage 0C policy
08400 Troubleshooting
Evidence Packet

Answer type:

case\_specific\_explanation

Evidence needed:

yes

28.4 “환불해 주세요.”

Retrieve:

08300 AI Response Boundary
08400 Abuse / Dispute / Safety Issue
relevant payment/refund SOP if available

Answer type:

escalation\_required

Evidence needed:

yes

AI must not approve refund.

29\. CatchMenu-Side pgvector Knowledge Index Requirement

CatchMenu must maintain a support knowledge retrieval layer inside its Supabase/PostgreSQL environment.

This does not mean adding vector columns directly to every operational runtime table.

Instead, CatchMenu should maintain a separate support knowledge schema or table group for SOP, policy, FAQ, troubleshooting, known issue, response template, and support guidance retrieval.

Core rule:

Operational runtime tables store facts and states.
Support knowledge tables store explanations, policies, troubleshooting guides, response templates, and embeddings.
Evidence Packets connect runtime facts with support knowledge.

The AI Customer Center should use the Support Gateway to search this CatchMenu-side pgvector index before requesting operational evidence.

30\. Why CatchMenu Needs Its Own Support Knowledge Index

CatchMenu can produce many different support and troubleshooting patterns.

Examples:

QR access failure
wrong store QR routing
language selection failure
translation mismatch
allergy or dietary request risk
menu option mismatch
guest request version conflict
store confirmation delay
Stage 0C unconfirmed request warning
forced cleanup threshold
auto-completion dispute
waiting / arrival mismatch
POS handoff failure
KDS handoff failure
benefit claim uncertainty
owner console alert failure
browser / device issue
guest policy confusion
merchant package confusion

These issues cannot be handled safely by hard-coded logic alone.

Therefore, CatchMenu must provide searchable support knowledge that maps issue signals to:

policy
SOP
troubleshooting step
evidence requirement
allowed AI response
prohibited AI response
escalation rule
response template

31\. Recommended Support Knowledge Table Group

Suggested CatchMenu support knowledge tables:

support\_documents
support\_document\_chunks
support\_chunk\_embeddings
troubleshooting\_taxonomy
known\_issue\_patterns
response\_templates
retrieval\_logs
knowledge\_gap\_notes

These tables belong to the support knowledge layer.

They must remain separate from runtime request, waiting, handoff, POS, KDS, payment, and benefit state tables.

32\. Support Knowledge Table Roles

32.1 support\_documents

"support\_documents" stores document-level metadata.

Suggested fields:

document\_id
doc\_number
doc\_title
source\_path
category
audience
stage
module
issue\_family
language
effective\_version
deprecated
replaced\_by
created\_at
updated\_at
last\_reviewed\_at

Purpose:

track source document identity
track version
track deprecation
support retrieval filtering
preserve document lineage

32.2 support\_document\_chunks

"support\_document\_chunks" stores searchable policy or troubleshooting sections.

Suggested fields:

chunk\_id
document\_id
section\_number
section\_title
chunk\_text
chunk\_summary
category
audience
stage
module
issue\_family
severity
language
effective\_version
deprecated

Chunking should preserve:

rule
exception
boundary
allowed action
prohibited action
escalation condition

A rule must not be separated from its exception.

32.3 support\_chunk\_embeddings

"support\_chunk\_embeddings" stores pgvector embeddings.

Suggested fields:

embedding\_id
chunk\_id
embedding\_model
embedding\_vector
embedding\_version
created\_at

The embedding belongs to a support knowledge chunk, not directly to an operational runtime row.

Core rule:

Embed support knowledge chunks.
Do not embed raw runtime facts by default.

32.4 troubleshooting\_taxonomy

"troubleshooting\_taxonomy" stores structured issue definitions.

Suggested fields:

issue\_family
issue\_type
severity\_default
evidence\_required
sop\_category
escalation\_required
allowed\_ai\_response\_type
prohibited\_ai\_response\_type

Example issue families:

qr\_access
language\_translation
menu\_option
guest\_request
store\_confirmation
stage\_0c\_unconfirmed\_request
waiting\_arrival
pos\_handoff
kds\_handoff
benefit\_routing
owner\_console
notification
device\_browser
policy\_usage\_confusion
abuse\_dispute\_safety

32.5 known\_issue\_patterns

"known\_issue\_patterns" stores recurring support-safe issue patterns.

Suggested fields:

pattern\_id
issue\_family
signal\_type
symptom\_text
likely\_cause
recommended\_sop
evidence\_required
escalation\_rule
active
created\_at
updated\_at

Examples:

specific browser blocks owner console sound
specific POS adapter times out during lunch peak
Stage 0C owners often miss forced cleanup
foreign guests confuse request sent with order confirmed
QR sticker from old store is reused accidentally

Known issue patterns must be support-safe and masked.

32.6 response\_templates

"response\_templates" stores safe response templates.

Suggested fields:

template\_id
audience
case\_type
language
severity
template\_text
requires\_human\_review
prohibited\_for\_guest
effective\_version
deprecated

Template categories:

guest\_explanation
merchant\_instruction
owner\_console\_help
hq\_escalation\_summary
technical\_support\_note
human\_handoff\_note

Response templates must not authorize AI to execute operational actions.

32.7 retrieval\_logs

"retrieval\_logs" stores retrieval trace.

Suggested fields:

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

32.8 knowledge\_gap\_notes

"knowledge\_gap\_notes" stores missing knowledge findings.

Suggested fields:

knowledge\_gap\_id
query\_text
missing\_topic
issue\_family
stage
audience
tenant\_id\_if\_specific
suggested\_document
created\_at
review\_status
resolved\_by\_document\_id

Knowledge gaps should feed back into:

new FAQ
new troubleshooting guide
updated SOP
new response template
known issue pattern
policy clarification

33\. Operational Tables Must Not Become Vector Dump

CatchMenu must avoid adding embeddings directly to every runtime object.

Do not treat these as vector knowledge by default:

guest request row
waiting row
handoff row
POS reference row
KDS reference row
payment reference row
raw event row
raw audit row

Runtime rows may be referenced by Evidence Packet.

They should not become the primary semantic retrieval corpus.

34\. Support Signal To Knowledge Mapping

Support signals should map to retrieval categories.

Example:

UNCONFIRMED\_REQUEST\_WARNING
→ stage\_0c\_unconfirmed\_request
→ retrieve Stage 0C policy
→ retrieve troubleshooting guide
→ retrieve response template
→ retrieve evidence requirement

Example:

LOW\_CONFIDENCE\_TRANSLATION \+ allergy flag
→ language\_translation
→ retrieve I18n translation policy
→ retrieve allergy escalation SOP
→ require Evidence Packet
→ human escalation required

Example:

POS\_HANDOFF\_FAILED
→ pos\_handoff
→ retrieve POS handoff troubleshooting
→ require handoff evidence
→ recommend manual fallback check

35\. Gateway Retrieval Before Runtime Lookup

When a support signal or inquiry arrives, the Gateway should first perform knowledge retrieval.

Default path:

support inquiry or signal
→ classify issue family
→ search pgvector support knowledge
→ return SOP / policy / troubleshooting / template
→ request Evidence Packet only if case-specific facts are needed

This prevents unnecessary runtime DB access.

36\. Knowledge Index Update Policy

The pgvector index must be refreshed when support knowledge changes.

Refresh triggers:

new policy document
updated Stage policy
new troubleshooting category
new known issue pattern
new response template
incident postmortem added
support gap resolved
deprecated policy replaced

Each chunk should preserve:

document version
chunk version
embedding version
effective date
deprecated flag

37\. Final Statement

CatchMenu knowledge retrieval must be Gateway-controlled and SOP-first.

The AI Customer Center should retrieve CatchMenu policy, FAQ, SOP, troubleshooting, known issue, and response template knowledge before requesting operational facts.

Evidence Packet and runtime reads are reserved for case-specific issues.

CatchMenu must embed its support knowledge, not its raw operational ledger.

Core rule:

Embed SOP, policy, FAQ, troubleshooting, known issue, and response templates.
Do not embed raw runtime facts as the default knowledge corpus.
Use Evidence Packets to connect runtime facts to retrieved knowledge.

Final access rule:

Knowledge first.
Evidence second.
Secondary support view third.
Primary runtime read last.
AI drafts or guides.
Authorized human or runtime function acts.
