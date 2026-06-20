# 001095_Policy_CatchMenu_Guest_Identity_Session_And_Context_Continuity.md

1\. Purpose

This document defines guest identity, guest session, store context, waiting context, table context, request context, and benefit context continuity for CatchMenu.

CatchMenu must allow a guest to move from QR menu view to request, waiting, seating, handoff, payment reference, and benefit candidate without losing context.

However, CatchMenu must not silently merge guest identity with tenant membership identity, external membership identity, POS customer identity, or payment identity.

Core purpose:

Preserve guest context.
Do not silently merge identity.
Connect flow without overclaiming ownership.

Korean purpose:

손님 흐름의 맥락은 보존한다.
하지만 신원을 무단으로 병합하지 않는다.
흐름은 연결하되 소유권을 과장하지 않는다.

2\. Core Principle

CatchMenu guest identity should be lightweight by default.

A guest may use CatchMenu without installing an app or creating a full account.

Core rule:

Guest session continuity is required.
Permanent identity merge is optional and explicit.

Korean rule:

손님 세션의 연속성은 필요하다.
영구 신원 병합은 선택이며 명시적이어야 한다.

CatchMenu should preserve the guest's operational flow, not forcibly convert every guest into a permanent account.

3\. Identity Types

CatchMenu must distinguish identity types.

Suggested identity types:

guest\_session\_identity
catchmenu\_guest\_identity
tenant\_membership\_identity
external\_membership\_identity
pos\_customer\_identity
payment\_identity
waiting\_identity
table\_participation\_identity
support\_case\_identity

These identities may be linked only through explicit rules.

They must not be assumed to be the same person without evidence or consent.

4\. Guest Session Identity

A guest session identity is a lightweight temporary identity.

It may be created when the guest:

scans QR
selects language
views menu
selects menu items
sends request
joins waiting flow
joins table flow

Suggested fields:

guest\_session\_id
tenant\_id
store\_id
device\_session\_id
guest\_language
started\_at
last\_seen\_at
expires\_at
session\_status

Guest session identity should be enough to preserve flow within the same visit.

It should not automatically become a permanent customer account.

5\. CatchMenu Guest Identity

CatchMenu may later support a persistent CatchMenu guest identity.

This identity may support:

visit history
request history
wallet or coupon display
guest preferences
language preference
lightweight repeat visit support

However, persistent guest identity must be optional unless a specific business model requires it.

Core rule:

No app install should be required for basic CatchMenu use.
No permanent account should be required for Stage 0A / 0B / 0C basic use.

6\. Tenant Membership Identity

A tenant or brand may have its own membership identity.

Examples:

brand membership account
franchise membership account
store loyalty account
white-label customer account
subscription account

Tenant membership identity is not automatically the same as CatchMenu guest identity.

Core rule:

CatchMenu guest identity and tenant membership identity must not be silently merged.

Explicit linking may be allowed later through:

guest consent
tenant rule
membership login
phone verification
external connector
benefit claim flow

7\. External Membership Identity

Some stores or tenants may use external membership providers.

Examples:

Kakao channel membership
Naver booking identity
POS customer profile
delivery app customer reference
external CRM account
third-party loyalty platform

External membership identity must remain a separate reference unless explicitly linked.

CatchMenu must not claim ownership of external membership identity.

8\. POS Customer Identity

POS customer identity belongs to POS or the merchant's POS configuration.

CatchMenu may store a support-safe POS customer reference if integration exists.

CatchMenu must not:

create POS customer identity without authority
overwrite POS customer profile
merge POS customer identity with CatchMenu identity silently
treat POS customer identity as payment identity

Core rule:

POS customer identity belongs to POS authority.
CatchMenu may reference it only when authorized.

9\. Payment Identity

Payment identity belongs to payment/POS/PG authority.

CatchMenu may reference masked payment identity if integrated.

CatchMenu must not store raw payment credentials.

Payment identity must not be used as general guest identity without explicit authorization.

Core rule:

Payment identity is not general customer identity.

10\. Waiting Identity

Waiting identity connects a guest session to a waiting flow.

Suggested fields:

waiting\_id
guest\_session\_id
tenant\_id
store\_id
party\_size
waiting\_status
arrival\_status
created\_at
updated\_at

Waiting identity may connect to:

request\_id
table\_id
staff\_call\_event
arrival\_confirmation
handoff event

Boundary:

Waiting identity is visit context.
Waiting identity is not permanent customer identity.

11\. Table Participation Identity

A table may have multiple guests.

CatchMenu must not assume:

1 table \= 1 guest
1 guest \= 1 payment
1 payment \= 1 order
1 table \= 1 membership identity

Suggested table participation fields:

table\_participation\_id
table\_id
guest\_session\_id
request\_id
participation\_role
joined\_at
left\_at

Participation roles may include:

host\_guest
joining\_guest
payer\_candidate
viewer\_only
request\_contributor

Core rule:

Table context connects participants.
It does not merge their identities.

12\. Request Context Continuity

A request should remain connected to the guest session that created it.

Suggested links:

guest\_session\_id
request\_id
request\_version
waiting\_id if applicable
table\_participation\_id if applicable
stage
store\_id
created\_at

If the guest moves from QR menu to waiting or table participation, the system should preserve request continuity.

However, request continuity must not imply payment or benefit authority.

13\. Store Context

Every guest session and request must be scoped to a store.

Required scope:

tenant\_id if applicable
store\_id
store\_display\_name
business\_date
store\_timezone
active\_package\_or\_stage

Wrong store context is a high-risk error.

Examples:

QR code points to wrong store
guest request sent to wrong owner console
benefit routed to wrong store
support evidence generated under wrong store

Wrong store context should create a typed failure event.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

14\. Business Date And Time Context

CatchMenu should distinguish calendar date and store business date.

Examples:

calendar date \= actual date
business date \= store operating day
request created time \= timestamp
store closing time \= operation cutoff

This matters for:

today sales summary
request expiration
close auto-completion
waiting cleanup
support evidence
gateway runtime query

Core rule:

Runtime context must preserve store business date.

15\. Language Context

A guest session should preserve language context.

Suggested fields:

guest\_language
store\_language
translation\_version
translation\_confidence
critical\_request\_detected

Language context should follow the request and Evidence Packet.

Critical language issues should not be lost during handoff.

16\. Device Context

Device context may be needed for troubleshooting.

Suggested fields:

device\_type
browser\_family
os\_family
qr\_scan\_source
web\_session\_id
app\_install\_status
network\_status\_hint

Device context should be support-safe.

It should not become invasive tracking.

Core rule:

Collect only the device context needed for support and reliability.

17\. Context Continuity Across Stages

17.1 Stage 0A

Context continuity is local and lightweight.

QR scan
→ language selection
→ menu selection
→ show-to-staff view

No store request context is created unless logging is explicitly enabled.

17.2 Stage 0B

Context continuity includes request sending.

guest\_session\_id
→ request\_id
→ owner console view

17.3 Stage 0C

Context continuity includes confirmation.

guest\_session\_id
→ request\_id
→ store confirmation
→ guest edit lock
→ completion or expiration

17.4 Stage 1

Context continuity includes waiting and manual POS handoff.

guest\_session\_id
→ waiting\_id
→ request\_id
→ manual POS handoff context

17.5 Stage 2

Context continuity includes kitchen assist.

guest\_session\_id
→ request\_id
→ kitchen assist context
→ preparation state

17.6 Stage 3

Context continuity includes POS reference.

guest\_session\_id
→ request\_id
→ POS handoff
→ POS reference

17.7 Stage 4

Context continuity includes POS and KDS references.

guest\_session\_id
→ request\_id
→ POS reference
→ KDS reference

17.8 Stage 5

Context continuity may include benefit candidate and membership connector.

guest\_session\_id
→ request\_id
→ benefit\_candidate\_id
→ tenant membership reference
or
→ external membership reference

Identity merge must remain explicit.

18\. Benefit Context Continuity

Benefit context may exist when Stage 5 or tenant-specific benefit routing is enabled.

Benefit context may include:

benefit\_candidate\_id
request\_id
store\_id
tenant\_id
guest\_session\_id
catchmenu\_guest\_id if available
tenant\_membership\_id if linked
external\_membership\_reference if linked
benefit\_rule\_id
benefit\_status

Core rule:

Benefit candidate is not benefit granted.
Benefit context is not identity merge.

19\. Consent And Linking Policy

Any persistent identity linking should require explicit policy.

Linking may require:

guest consent
tenant membership login
phone verification
external provider callback
benefit claim confirmation
privacy notice
unlink path

Silent linking is prohibited.

Examples of prohibited silent linking:

same device \= same permanent guest
same payment card \= same membership identity
same table \= same customer
same phone hint \= verified identity
same POS reference \= CatchMenu account

20\. Context Expiration

Guest session context should expire.

Expiration depends on stage and business need.

Suggested expiration examples:

Stage 0A local session \= short-lived
Stage 0B request session \= same business day or request expiration
Stage 0C confirmation session \= until completion/expiration plus support window
Stage 1 waiting session \= until visit resolved plus support window
Stage 5 benefit context \= according to benefit/audit policy

Expiration must not delete required audit/evidence records.

21\. Context Recovery

The system should support limited context recovery.

Examples:

guest refreshes page
guest switches language
owner console reloads
staff opens request from support view
waiting guest returns after connection loss

Recovery must respect:

session validity
store context
request status
guest edit lock
privacy boundary

22\. Context Conflict

Context conflict occurs when two or more context facts disagree.

Examples:

QR store does not match request store
waiting store does not match request store
table context does not match request store
benefit store does not match request store
guest language changed after critical request
request version mismatch
same request linked to multiple active tables

Context conflict should trigger:

support signal
Evidence Packet
state guard
possible user-facing reconfirmation

23\. Support And Evidence Context

Evidence Packet should preserve context continuity.

Evidence Packet may include:

guest\_session\_id
request\_id
waiting\_id
table\_participation\_id
store\_id
business\_date
guest\_language
translation\_context
state timeline
identity link status
benefit candidate status
support signal references
gateway access references

Evidence Packet must distinguish:

known fact
linked identity
unlinked identity
inferred context
missing evidence
conflict

24\. AI Customer Center Boundary

The AI Customer Center may use context continuity to explain what happened.

Allowed:

summarize visit flow
identify missing context
explain policy
draft support response
recommend human review

Prohibited:

silently link identities
confirm permanent identity
merge guest and membership accounts
grant benefit
override store context
mutate request state

25\. Guest-Facing Language

Guest-facing language should be simple.

Allowed:

Continue your request
Your request is linked to this store
Please ask staff if you need changes
Your request needs confirmation
This benefit may require membership confirmation

Avoid:

identity merge
external membership connector
tenant context
gateway access
Evidence Packet
support-safe view

26\. Merchant-Facing Language

Merchant-facing language should clarify operational context.

Examples:

이 요청은 현재 매장 QR에서 들어왔습니다.
이 손님 요청은 대기 정보와 연결되어 있습니다.
이 요청은 아직 POS 결제와 연결되지 않았습니다.
이 요청은 혜택 후보 상태이며, 혜택 확정은 아닙니다.

27\. Support-Facing Language

Support-facing context may include technical identifiers.

Examples:

guest\_session\_id linked to request\_id
request\_id linked to waiting\_id
request linked to POS reference
benefit candidate exists but tenant membership identity not linked
guest identity and payment identity are separate

Support views should never hide identity separation.

28\. Final Statement

CatchMenu must preserve guest flow without silently merging identities.

A guest should be able to move from QR menu to request, waiting, table participation, handoff, and benefit candidate without losing operational context.

However, session continuity is not identity ownership.

Final rule:

Preserve context.
Separate identity.
Require explicit linking.
Do not silently merge.
Do not confuse visit continuity with permanent customer identity.
