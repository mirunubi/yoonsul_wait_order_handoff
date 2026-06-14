00360 Entry Media Identifier Encoding And Resolution Policy

Legacy path: $old.

1\. Purpose

This document defines the identifier encoding and resolution policy for CatchMenu Entry Media.

Entry Media such as QR codes and NFC tags should not contain full store, table, menu, pricing, or operational data.

Instead, Entry Media should contain a stable identifier or short URL that can be resolved by the system into the correct store, menu, stage, placement, and runtime context.

Core purpose:

Keep QR/NFC payload small and stable.
Resolve store/menu context server-side.
Allow reassignment without reprinting when safe.
Prevent stale embedded data.
Preserve scan-time resolution history.

Korean purpose:

QR/NFC 내용은 작고 안정적으로 유지한다.
매장/메뉴 컨텍스트는 서버에서 해석한다.
안전한 경우 재인쇄 없이 재배정할 수 있게 한다.
오래된 정보가 QR/NFC 안에 박히는 것을 막는다.
스캔 당시 해석 이력을 보존한다.

2\. Scope

This document covers:

QR code payload
NFC tag payload
entry\_media\_id
short URL
server-side resolution
scan resolution result
store/menu/stage context lookup
payload safety
reassignment safety
stale embedded data prevention
resolution failure
scan-time audit

This document does not define:

physical plate manufacturing
field installation SOP
menu data creation
AI menu intake
Stage 0 request lifecycle
POS/KDS/payment integration

Related documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md
00340\_Entry\_Media\_Test\_Field\_Sample\_And\_Production\_Separation\_Policy.md
00350\_Entry\_Media\_Lost\_Damaged\_And\_Retired\_Asset\_Policy.md

3\. Core Principle

QR/NFC should identify, not carry full operational truth.

Core rule:

Entry Media contains an identifier.
Server-side mapping contains the operational context.

Korean rule:

Entry Media에는 식별자를 넣는다.
운영 컨텍스트는 서버 매핑에서 관리한다.

This allows store, menu, stage, and placement context to change without physically replacing every QR/NFC asset.

4\. Recommended Payload Pattern

Recommended QR/NFC payload:

https://catchmenu.example/q/{entry\_media\_token}

or:

https://catchmenu.example/e/{entry\_media\_token}

Example:

https://catchmenu.example/q/em\_7K9F2A

The payload should not expose internal database IDs when avoidable.

The payload should use a public-safe token.

5\. Avoid Full Embedded Data

Do not embed full operational data directly into QR/NFC.

Avoid payloads such as:

store\_id=store\_123
table\_id=table\_12
menu\_version=v3
price\_policy=...
stage=0C

Reason:

store data can change
menu data can change
stage can change
plate may be recovered and reused
embedded data may become stale
sensitive internal IDs may leak

Core rule:

Do not print operational truth into the physical world unless it is meant to be permanent.

6\. Public Token

Entry Media should use a public-safe token.

Recommended token properties:

stable
non-guessable
short enough for QR/NFC use
not sequential if public
not directly exposing internal IDs
revocable through server mapping

Example:

entry\_media\_token \= em\_7K9F2A

The token resolves server-side to "entry\_media\_id".

7\. Server-Side Resolution

When a guest scans QR or taps NFC, the server should resolve:

entry\_media\_token
→ entry\_media\_id
→ active mapping
→ store\_id
→ menu\_context\_id
→ enabled\_stage
→ placement
→ guest flow

Resolution must check:

entry media exists
media is not retired
media is not lost
media is not suspended
mapping exists
mapping is active
mapping is not ambiguous
store context exists
menu context exists
stage is enabled

8\. Resolution Result

A successful resolution should produce a structured result.

Recommended fields:

resolution\_id
entry\_media\_id
entry\_plate\_id
mapping\_id
store\_id
menu\_context\_id
enabled\_stage
placement
context\_type
environment
resolved\_at
resolution\_status
trace\_id

This result may be used by Stage 0 or future runtime modules.

9\. Resolution Status

Suggested resolution statuses:

RESOLVED
NO\_ACTIVE\_MAPPING
MULTIPLE\_ACTIVE\_MAPPINGS
DEACTIVATED
SUSPENDED
LOST
DAMAGED
RETIRED
TEST\_ONLY
ENVIRONMENT\_MISMATCH
STORE\_CONTEXT\_MISSING
MENU\_CONTEXT\_MISSING
INVALID\_TOKEN

Guest-facing messages should simplify these statuses.

Internal diagnostic should preserve exact status.

10\. Scan-Time Context Preservation

If a request is created after scan, preserve scan-time resolution context.

Recommended fields to preserve:

resolution\_id
entry\_media\_id
entry\_plate\_id
mapping\_id
store\_id
menu\_context\_id
enabled\_stage
placement
resolved\_at
guest\_session\_id

Core rule:

Request evidence must remember what the scan resolved to at the time.

Korean rule:

요청 증거는 스캔 당시 어떤 컨텍스트로 해석되었는지 기억해야 한다.

11\. Reassignment Safety

Because QR/NFC carries only a token, the same physical asset may be reassigned after proper deactivation and recovery.

Safe reassignment requires:

previous mapping deactivated
previous assignment closed
physical asset recovered or verified
asset condition acceptable
new mapping created
history preserved

Reassignment must not edit old mapping in place.

Core rule:

Stable token may remain.
Active mapping changes through history.

12\. When Reprinting Is Required

Reassignment without reprinting is not always safe.

Reprinting or relabeling may be required when:

printed store name exists
printed old brand exists
old instruction is misleading
QR visually contains old store-specific text
plate condition is poor
guest-facing copy no longer matches enabled function

Core rule:

Logical remapping is not enough if physical text misleads guests.

13\. NFC Encoding

NFC tag should usually store a URL or tokenized URL.

Recommended NFC payload:

https://catchmenu.example/e/{entry\_media\_token}

Avoid storing:

full store data
full menu data
personal data
admin credentials
service role keys
private API endpoints

NFC should open guest entry only.

Core rule:

NFC is guest entry media.
NFC is not owner authentication.

14\. QR Encoding

QR code should also use a tokenized URL.

Recommended QR payload:

https://catchmenu.example/q/{entry\_media\_token}

QR should be printable, scannable, and durable.

QR should not directly expose internal operational data.

15\. Short Link Policy

Short links may be used to improve QR readability and physical layout.

Short link must resolve through approved routing.

Short link must not bypass Entry Media Inventory.

Allowed:

short link
→ Entry Media resolution endpoint
→ active mapping
→ guest flow

Prohibited:

short link
→ hardcoded store menu page without mapping history

Core rule:

Short link is a doorway.
Entry Media Inventory remains the source of mapping truth.

16\. Token Rotation

Entry Media token may need rotation when:

security concern exists
token is exposed in unsafe context
wrong mapping incident occurred
plate is retired
counterfeit risk exists

Token rotation should create event.

Token rotation must preserve old token history.

Core rule:

Rotate token with trace.
Do not erase token history.

17\. Token Revocation

Token may be revoked when:

plate is lost
plate is retired
security risk exists
counterfeit plate suspected
merchant terminated

Revoked token must not resolve to normal guest flow.

Guest-facing message:

This guide is currently not available.
Please ask staff.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

18\. Scan Failure Handling

If resolution fails, the system should fail safely.

Failure cases:

invalid token
no active mapping
multiple active mappings
deactivated media
lost media
retired media
menu context missing
store context missing
environment mismatch

Guest should not see raw internal error.

Internal diagnostic must preserve exact failure code.

19\. Guest-Facing Failure Messages

Recommended guest-facing messages:

This guide is currently not available.
Please ask staff.

The menu could not be opened.
Please ask staff.

This guide may have been replaced.
Please scan the latest guide at the store.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

메뉴를 열 수 없습니다.
직원에게 문의해주세요.

이 안내판은 교체되었을 수 있습니다.
매장의 최신 안내판을 스캔해주세요.

20\. Internal Diagnostic

Internal diagnostic should include:

entry\_media\_token
entry\_media\_id if resolved
entry\_plate\_id if resolved
resolution\_status
mapping\_status
physical\_asset\_status
context\_type
environment
failure\_code
trace\_id
resolved\_at

Internal diagnostic must not be shown to guests by default.

21\. Security Boundary

QR/NFC scan must not grant admin authority.

Prohibited:

owner console login through public QR
admin token embedded in NFC
service key embedded in QR
store management endpoint exposed through Entry Media

Core rule:

Entry Media opens guest flow.
Admin access requires authentication.

22\. Privacy Boundary

Entry Media payload must not contain personal data.

Do not encode:

guest name
phone number
email
payment information
membership identifier
staff identifier
private admin identifier

Guest session may be created after scan, but personal identity must not be embedded in QR/NFC.

23\. Environment Guard

Resolution must check environment.

Example:

TEST\_ONLY media scanned in production
→ deny or show safe message

PRODUCTION media resolving to staging context
→ deny and create failure event

Core rule:

Environment mismatch must fail closed.

24\. Placement Context

Resolution may include placement.

Examples:

OUTSIDE\_AD\_BOARD
INSIDE\_STORE\_GUIDE
COUNTER\_GUIDE
TABLE\_GUIDE
FIELD\_SAMPLE
TEST\_LOCATION

Placement can affect guest flow.

Example:

OUTSIDE\_AD\_BOARD
→ menu preview and store information

INSIDE\_STORE\_GUIDE
→ menu view and request flow

TABLE\_GUIDE
→ table context if enabled

Stage 0 POS-less default does not require table context.

25\. Stage Resolution

Entry Media mapping may determine enabled stage.

Examples:

STAGE\_0A
STAGE\_0B
STAGE\_0C

Changing enabled stage must be event-backed.

Stage 0 runtime should consume resolved stage.

Entry Media Inventory owns mapping resolution, not the detailed request lifecycle.

26\. No Table Requirement For Stage 0

For Stage 0 POS-less stores, table ID is optional.

Default resolution:

entry\_media\_id
→ store\_id
→ menu\_context\_id
→ enabled\_stage
→ table\_id \= null

Core rule:

Store-level Entry Media is valid Stage 0 Entry Media.

Korean rule:

매장 단위 Entry Media는 정상적인 Stage 0 Entry Media이다.

27\. Scan Log

The system may create scan log records.

Recommended fields:

scan\_id
entry\_media\_token\_ref
entry\_media\_id
entry\_plate\_id
scan\_time
resolution\_status
resolved\_mapping\_id
store\_id
menu\_context\_id
enabled\_stage
placement
failure\_code
trace\_id

Scan log is evidence of scan.

Scan log is not a replacement for mapping history.

28\. Resolution Audit Event

Resolution failures or sensitive resolutions may create audit events.

Events may include:

ENTRY\_MEDIA\_SCAN\_RESOLVED
ENTRY\_MEDIA\_SCAN\_FAILED
ENTRY\_MEDIA\_SCAN\_DEACTIVATED
ENTRY\_MEDIA\_SCAN\_RETIRED
ENTRY\_MEDIA\_SCAN\_TEST\_ONLY\_DENIED
ENTRY\_MEDIA\_SCAN\_MULTIPLE\_MAPPING\_DENIED
ENTRY\_MEDIA\_SCAN\_NO\_MAPPING\_FOUND

High-volume successful scans may be logged separately from audit events depending on scale.

29\. Failure Codes

Example failure codes:

WOH.ENTRY\_MEDIA.RESOLUTION.INVALID\_TOKEN
WOH.ENTRY\_MEDIA.RESOLUTION.NO\_ACTIVE\_MAPPING
WOH.ENTRY\_MEDIA.RESOLUTION.MULTIPLE\_ACTIVE\_MAPPINGS
WOH.ENTRY\_MEDIA.RESOLUTION.DEACTIVATED
WOH.ENTRY\_MEDIA.RESOLUTION.SUSPENDED
WOH.ENTRY\_MEDIA.RESOLUTION.LOST\_ASSET
WOH.ENTRY\_MEDIA.RESOLUTION.RETIRED\_ASSET
WOH.ENTRY\_MEDIA.RESOLUTION.TEST\_ONLY\_DENIED
WOH.ENTRY\_MEDIA.RESOLUTION.ENVIRONMENT\_MISMATCH
WOH.ENTRY\_MEDIA.RESOLUTION.STORE\_CONTEXT\_MISSING
WOH.ENTRY\_MEDIA.RESOLUTION.MENU\_CONTEXT\_MISSING

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

30\. Support Signals

Support signals may be generated for:

NO\_ACTIVE\_MAPPING\_SCAN
MULTIPLE\_ACTIVE\_MAPPING\_SCAN
DEACTIVATED\_MEDIA\_SCANNED
RETIRED\_MEDIA\_SCANNED
LOST\_MEDIA\_SCANNED
TEST\_MEDIA\_SCANNED\_IN\_FIELD
ENVIRONMENT\_MISMATCH\_SCAN
STORE\_CONTEXT\_MISSING\_SCAN
MENU\_CONTEXT\_MISSING\_SCAN
TOKEN\_REVOKED\_SCAN

Support Signal is not mutation authority.

It alerts authorized operators or support.

31\. Evidence Packet Relationship

Evidence Packet may include resolution evidence.

Recommended fields:

entry\_media\_id
entry\_plate\_id
entry\_media\_token\_ref
scan\_time
resolution\_status
resolved\_mapping\_id
store\_id
menu\_context\_id
enabled\_stage
placement
context\_type
environment
failure\_code
trace\_id

Evidence must distinguish:

payload token
resolved mapping
scan-time context
current mapping
historical mapping

Core rule:

Current mapping is not always the mapping used at scan time.

32\. Minimum MVP Requirement

MVP should support at least:

tokenized QR/NFC payload
server-side resolution endpoint
entry\_media\_id lookup
active mapping lookup
inactive safe message
no active mapping failure
multiple active mapping failure
lost/retired guard
test-only guard
scan-time context preservation
basic scan log
basic failure code

MVP may defer:

advanced token rotation
bulk token migration
advanced anti-counterfeit detection
high-volume analytics pipeline
geo-based scan anomaly detection

33\. Relationship To Stage 0 Runtime

Stage 0 runtime uses the resolved context.

Stage 0 should not decode store/menu context directly from QR/NFC payload.

Correct flow:

QR/NFC scan
→ Entry Media resolution
→ resolved store/menu/stage context
→ Stage 0 guest flow

Incorrect flow:

QR/NFC payload
→ Stage 0 directly trusts embedded store/menu values

Core separation:

Entry Media Inventory resolves identity.
Stage 0 runs the guest experience.

34\. Relationship To Reallocation Policy

Reallocation is governed by:

00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md

This document ensures that QR/NFC payload design allows safe reallocation without embedding stale operational data.

35\. Final Rule

Entry Media encoding must be minimal, stable, and safe.

Final rule:

Encode only a safe identifier.
Resolve context server-side.
Preserve scan-time resolution.
Do not embed operational truth.
Do not grant admin authority.
Fail closed on unsafe resolution.
Support reallocation through mapping history.
