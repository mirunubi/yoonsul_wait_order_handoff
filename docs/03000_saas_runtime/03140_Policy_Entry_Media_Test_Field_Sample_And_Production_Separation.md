# 03140_Policy_Entry_Media_Test_Field_Sample_And_Production_Separation

Legacy path: $old.

1\. Purpose

This document defines the separation policy for test, field sample, trial, and production Entry Media.

CatchMenu Entry Media such as QR codes, NFC tags, and Entry Plates may be used for internal testing, field sales demonstration, merchant trial, and live production operation.

These contexts must not be confused.

Core purpose:

Separate test media from production media.
Separate field samples from live merchant assets.
Prevent test QR/NFC from creating production guest requests.
Prevent production QR/NFC from being used in unsafe test flows.
Preserve traceable transition when a test or sample asset becomes production-ready.

Korean purpose:

테스트용 미디어와 운영용 미디어를 분리한다.
영업 샘플과 실제 매장 자산을 분리한다.
테스트 QR/NFC가 실제 손님 요청을 만들지 않게 한다.
운영 QR/NFC가 안전하지 않은 테스트 흐름에 사용되지 않게 한다.
테스트/샘플 자산이 운영용으로 전환될 때 추적 가능한 전환 이력을 남긴다.

2\. Scope

This document covers:

test Entry Media
internal demo Entry Media
field sample Entry Plate
merchant trial Entry Plate
production Entry Plate
test-to-production conversion
sample-to-trial conversion
trial-to-production conversion
unsafe cross-use prevention
visual marking
logical marking
audit requirements
support signals
failure events

This document does not define:

field visit SOP
merchant sales script
menu data creation
AI menu intake
Stage 0 request lifecycle
POS/KDS/payment integration
physical manufacturing process

Related documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md

3\. Core Principle

Entry Media context must be explicit.

Core rule:

Test, sample, trial, and production Entry Media must be logically separated.

Korean rule:

테스트, 샘플, 체험, 운영 Entry Media는 논리적으로 분리되어야 한다.

A QR/NFC scan must not accidentally cross from test context into production context.

4\. Entry Media Context Types

Suggested context types:

INTERNAL\_TEST
INTERNAL\_DEMO
FIELD\_SAMPLE
MERCHANT\_TRIAL
PRODUCTION
RETIRED

Meaning:

INTERNAL\_TEST
\= used only by development or internal QA

INTERNAL\_DEMO
\= used for internal demonstration

FIELD\_SAMPLE
\= carried by sales/operations team for merchant explanation

MERCHANT\_TRIAL
\= installed at merchant store during trial

PRODUCTION
\= live merchant operation

RETIRED
\= no longer used

5\. Test Media

Test media is used for internal testing.

Test media may resolve to:

test store
test menu
test owner console
test guest flow
sandbox environment

Test media must be marked:

TEST\_ONLY

Test media must not create production guest requests.

Core rule:

Test media may simulate production behavior.
It must not become production behavior.

6\. Internal Demo Media

Internal demo media is used for demonstration to team members, partners, or controlled observers.

Internal demo media may show realistic flows, but must not connect to a real merchant unless explicitly approved.

Demo media should be marked:

INTERNAL\_DEMO
NOT\_FOR\_LIVE\_STORE

Demo data should be synthetic or approved.

7\. Field Sample Media

Field sample media is used by operations or sales team when visiting merchants.

Field sample may be used to show:

NFC tap behavior
QR scan behavior
guest menu view
show-to-staff flow
owner console sample view

Field sample must not be confused with installed merchant media.

Suggested status:

FIELD\_SAMPLE

Suggested placement:

FIELD\_SAMPLE

Core rule:

Field sample demonstrates.
Field sample does not operate a live merchant unless formally assigned.

8\. Merchant Trial Media

Merchant trial media is installed at a real merchant store for a limited trial period.

Merchant trial media may be live for guests.

Suggested context:

MERCHANT\_TRIAL

Trial media must have:

store assignment
menu context
trial start date
trial end date
admin access scope
mapping status
recovery expectation

Trial media may later become production media if merchant converts.

9\. Production Media

Production media is live merchant Entry Media used in ongoing operation.

Production media requires:

valid store assignment
valid menu context
active mapping
approved merchant status
non-test context
admin access policy
audit trail

Production media must not point to test menu or demo store context.

Core rule:

Production media must resolve only to approved production or live trial context.

10\. Visual Marking Requirement

Test and sample Entry Plates should be visually marked when practical.

Recommended visible labels:

TEST
SAMPLE
DEMO
NOT FOR GUEST USE

Korean labels:

테스트용
샘플
데모용
손님 사용 금지

Production or trial plates should not carry test labels.

If a field sample is converted to merchant trial use, the visual marking must be replaced or covered appropriately.

11\. Logical Marking Requirement

Every Entry Media must have logical context marking.

Recommended fields:

entry\_media\_context\_type
environment
is\_test\_only
is\_field\_sample
is\_production\_allowed
merchant\_live\_allowed
guest\_request\_allowed

Example:

entry\_media\_context\_type \= INTERNAL\_TEST
is\_test\_only \= true
merchant\_live\_allowed \= false
guest\_request\_allowed \= false

Example:

entry\_media\_context\_type \= MERCHANT\_TRIAL
is\_test\_only \= false
merchant\_live\_allowed \= true
guest\_request\_allowed \= true

12\. Environment Separation

Entry Media may belong to different environments.

Suggested environments:

LOCAL
DEV
STAGING
SANDBOX
PRODUCTION

Test media should not resolve to production environment unless explicitly configured for controlled production trial.

Core rule:

Environment must be explicit.
Default cross-environment resolution is prohibited.

13\. Test To Production Conversion

Test media should not normally become production media.

If conversion is required, it must be explicit.

Required steps:

verify asset identity
remove or replace test visual marking
close test mapping
create production assignment
create production mapping
record conversion reason
audit conversion
verify scan resolves to production store

Prohibited:

silently change test mapping to production store
reuse test QR without audit
leave TEST\_ONLY flag active while allowing production guest requests

14\. Field Sample To Trial Conversion

Field sample may become merchant trial media if formally assigned.

Required steps:

confirm merchant/store target
confirm plate condition
remove sample-only visual marking if needed
create trial assignment
activate trial mapping
record field operator
record installation
set trial start and end date

Core rule:

A field sample becomes trial media only through assignment.

15\. Trial To Production Conversion

Merchant trial media may become production media when merchant converts.

Required steps:

confirm merchant conversion
update merchant status
update trial status to CONVERTED
keep or renew mapping
update context type to PRODUCTION if appropriate
keep assignment history
keep trial history
preserve scan/request history

Core rule:

Trial conversion extends operational history.
It does not erase trial history.

16\. Production To Suspended

Production media may be suspended when service is paused or risk exists.

Possible reasons:

merchant payment issue
wrong mapping suspected
store closed temporarily
security concern
admin access suspended
menu context invalid

Suspension must be reversible with event history.

Guest scan should show safe inactive message when suspended.

17\. Production To Retired

Production media may be retired when no longer safe or useful.

Reasons:

plate damaged
NFC failed
QR obsolete
branding obsolete
security concern
merchant closed
asset cannot be recovered safely

Retired media must not be reassigned.

18\. Cross-Use Prohibition

The system must prevent unsafe cross-use.

Prohibited:

TEST\_ONLY media used by real guest
FIELD\_SAMPLE media creating real merchant request without assignment
PRODUCTION media resolving to test store
MERCHANT\_TRIAL media resolving to another store without reallocation
RETIRED media resolving to active guest flow
LOST media resolving to active guest flow

Core rule:

Context mismatch must fail closed.

Korean rule:

컨텍스트가 맞지 않으면 안전하게 차단해야 한다.

19\. Scan-Time Context Guard

When Entry Media is scanned, the system should check:

entry\_media\_context\_type
environment
mapping\_status
assignment\_status
physical\_asset\_status
guest\_request\_allowed
merchant\_live\_allowed

If context is unsafe, do not enter normal guest flow.

Possible safe message:

This guide is currently not available.
Please ask staff.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

20\. Guest Request Permission

Not every Entry Media may create a guest request.

Suggested field:

guest\_request\_allowed

Examples:

INTERNAL\_TEST
guest\_request\_allowed \= false by default

FIELD\_SAMPLE
guest\_request\_allowed \= false by default

MERCHANT\_TRIAL
guest\_request\_allowed \= true if trial flow enabled

PRODUCTION
guest\_request\_allowed \= true if merchant plan enabled

Core rule:

Menu viewing and request creation are separate permissions.

21\. Owner Console Permission

Owner console access must not be granted by Entry Media scan alone.

Entry Media scan may open guest flow.

Owner console requires proper merchant/admin authentication.

Core rule:

Entry Media identifies guest entry.
It does not authenticate owner access.

22\. Context Conversion Event

Any context conversion must create an event.

Suggested events:

ENTRY\_MEDIA\_TEST\_CREATED
ENTRY\_MEDIA\_FIELD\_SAMPLE\_CREATED
ENTRY\_MEDIA\_TRIAL\_ASSIGNED
ENTRY\_MEDIA\_TRIAL\_CONVERTED\_TO\_PRODUCTION
ENTRY\_MEDIA\_FIELD\_SAMPLE\_CONVERTED\_TO\_TRIAL
ENTRY\_MEDIA\_TEST\_CONVERTED\_TO\_PRODUCTION
ENTRY\_MEDIA\_PRODUCTION\_SUSPENDED
ENTRY\_MEDIA\_PRODUCTION\_RETIRED

Event fields:

event\_id
entry\_media\_id
entry\_plate\_id
previous\_context\_type
new\_context\_type
previous\_environment
new\_environment
actor\_type
actor\_id
reason
created\_at
trace\_id

23\. Failure Events

Invalid cross-use must create typed failure events.

Example failure codes:

WOH.ENTRY\_MEDIA.CONTEXT.TEST\_MEDIA\_IN\_PRODUCTION\_DENIED
WOH.ENTRY\_MEDIA.CONTEXT.FIELD\_SAMPLE\_LIVE\_REQUEST\_DENIED
WOH.ENTRY\_MEDIA.CONTEXT.PRODUCTION\_TO\_TEST\_RESOLVE\_DENIED
WOH.ENTRY\_MEDIA.CONTEXT.RETIRED\_MEDIA\_SCAN\_DENIED
WOH.ENTRY\_MEDIA.CONTEXT.LOST\_MEDIA\_SCAN\_DENIED
WOH.ENTRY\_MEDIA.CONTEXT.ENVIRONMENT\_MISMATCH
WOH.ENTRY\_MEDIA.CONTEXT.CONVERSION\_AUDIT\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

24\. Support Signals

Support signals may be generated for:

TEST\_MEDIA\_USED\_IN\_FIELD
FIELD\_SAMPLE\_SCANNED\_BY\_GUEST
TEST\_MEDIA\_IN\_PRODUCTION\_SCAN
PRODUCTION\_MEDIA\_RESOLVED\_TO\_TEST\_CONTEXT
TRIAL\_MEDIA\_WITH\_EXPIRED\_TRIAL\_STILL\_ACTIVE
RETIRED\_MEDIA\_SCANNED
LOST\_MEDIA\_SCANNED
CONTEXT\_ENVIRONMENT\_MISMATCH

Support Signal is not mutation authority.

It alerts support or admin to review and correct through authorized process.

25\. Audit Requirements

Context separation changes must be auditable.

Audit should preserve:

entry\_media\_id
entry\_plate\_id
context\_type
environment
mapping\_id
assignment\_id
actor
reason
timestamp
trace\_id

Audit should answer:

Was this QR test-only at the time of scan?
Was this NFC a field sample or live merchant plate?
When did this trial plate become production?
Who converted the context?
Was production scan routed to production environment?

26\. Evidence Packet Relationship

Evidence Packet for context issues may include:

entry\_media\_id
entry\_plate\_id
scan\_time
context\_type\_at\_scan
environment\_at\_scan
mapping\_status\_at\_scan
assignment\_status\_at\_scan
guest\_request\_allowed\_at\_scan
failure\_event\_ref
support\_signal\_ref
conversion\_history

Core rule:

Evidence must preserve context at the time of scan.

27\. Minimum MVP Requirement

MVP should support at least:

context\_type field
environment field
TEST\_ONLY flag
FIELD\_SAMPLE status
MERCHANT\_TRIAL status
PRODUCTION status
guest\_request\_allowed flag
basic conversion event
test media scan guard
field sample scan guard
production mapping guard
basic audit log

MVP may defer:

advanced environment migration
bulk sample conversion
automated sales team inventory app
geo-fenced field sample detection
multi-region physical inventory control

28\. Relationship To Stage 0

Stage 0 may use Entry Media only if the active mapping is valid for guest flow.

Stage 0 should not decide whether a plate is test, sample, trial, or production by itself.

Stage 0 consumes resolved context from Entry Media Inventory.

Core separation:

Entry Media Inventory decides whether media is live-usable.
Stage 0 runs guest flow after safe resolution.

29\. Relationship To SOP

Field SOP may describe how to label, carry, install, recover, and reuse sample plates.

This document defines system policy.

Core separation:

SOP controls field behavior.
This policy controls logical separation and audit.

30\. Final Rule

Test, sample, trial, and production Entry Media must never be silently mixed.

Final rule:

Mark the context.
Separate the environment.
Guard the scan.
Convert with event.
Audit every context change.
Do not let test or sample media become live by accident.
Do not let production media resolve to test context.
