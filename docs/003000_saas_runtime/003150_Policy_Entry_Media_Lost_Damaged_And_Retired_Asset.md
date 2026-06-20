# 003150_Policy_Entry_Media_Lost_Damaged_And_Retired_Asset.md

## Purpose

This document defines the SaaS runtime or entry media inventory topic indicated by its filename and preserves its governed documentation role within `docs/003000_saas_runtime/`.

Legacy path: $old.

1\. Purpose

This document defines the lost, damaged, and retired asset policy for CatchMenu Entry Media and Entry Plates.

Entry Media and Entry Plates are reusable operational assets.

When an asset is lost, damaged, unreadable, unsafe, obsolete, or retired, the system must prevent unsafe reuse, guest confusion, wrong-store routing, and mapping history loss.

Core purpose:

Identify unusable Entry Media assets.
Prevent lost or damaged assets from staying active.
Block unsafe reallocation.
Preserve last known mapping history.
Retire assets with audit trail.

Korean purpose:

사용 불가 Entry Media 자산을 식별한다.
분실 또는 파손 자산이 활성 상태로 남지 않게 한다.
위험한 재배정을 차단한다.
마지막 매핑 이력을 보존한다.
감사 이력을 남기고 자산을 폐기 처리한다.

2\. Scope

This document covers:

lost Entry Plate
lost NFC tag
lost QR plate
damaged Entry Plate
damaged NFC tag
damaged QR code
unreadable QR
failed NFC
obsolete printed plate
unsafe physical plate
retired asset
found-after-lost asset
scan after lost/damaged/retired state
support signal
audit event
failure event

This document does not define:

field recovery SOP
merchant compensation policy
physical manufacturing standard
design refresh policy
menu intake
Stage 0 request lifecycle
POS/KDS/payment integration

Related documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md
00340\_Entry\_Media\_Test\_Field\_Sample\_And\_Production\_Separation\_Policy.md

3\. Core Principle

Lost, damaged, and retired assets must fail closed.

Core rule:

If asset safety is uncertain, do not allow active guest routing.

Korean rule:

자산 안전성이 불확실하면 활성 손님 흐름을 허용하지 않는다.

The system must prefer safe deactivation over risky continued use.

4\. Status Definitions

This policy uses the following status values:

LOST
DAMAGED
NFC\_FAILED
QR\_UNREADABLE
INSPECTION\_REQUIRED
REPAIR\_REQUIRED
RETIRED
FOUND\_PENDING\_VERIFICATION

These statuses may apply to:

physical\_asset\_status
entry\_media\_status
mapping\_status
recovery\_status
audit\_status

Status axes must remain separate.

5\. Lost Asset Definition

A lost asset means the Entry Plate or Entry Media cannot be located or recovered.

Examples:

plate removed by unknown person
merchant cannot find the plate
field operator misplaced sample plate
NFC sticker detached and missing
QR board discarded
plate left at closed store and unrecoverable

Lost status means:

physical location is unknown
asset cannot be verified
asset must not be reallocated
active mapping must be reviewed or deactivated

Core rule:

Lost asset cannot remain trusted.

6\. Damaged Asset Definition

A damaged asset means the physical plate or embedded media is no longer reliable or safe for field use.

Examples:

NFC tag does not scan
QR code is scratched
printed store guidance is unreadable
plate is bent or broken
old store branding remains visible
adhesive failed
water damage occurred
plate shows misleading text

Damaged status does not always mean retired.

Damaged asset may be inspected, repaired, or retired.

7\. Retired Asset Definition

A retired asset is permanently removed from future field use.

Retirement may happen when:

NFC permanently failed
QR cannot be safely reused
physical plate is too damaged
printed branding is obsolete
security concern exists
lost asset cannot be recovered
asset was involved in repeated wrong mapping incidents

Retired asset must not be assigned again.

Core rule:

RETIRED is terminal by default.

8\. Lost Asset Immediate Handling

When an asset is reported lost, the system should:

mark physical\_asset\_status \= LOST
review active mapping
deactivate or suspend active mapping if risk exists
block reallocation
preserve last known assignment
create audit event
create support signal if guest scan risk exists

If the asset was active in a store, the merchant should receive replacement or recovery handling through operations SOP.

9\. Lost Asset Mapping Handling

If lost asset has active mapping, this is high risk.

Expected action:

mapping\_status \= SUSPENDED
or
mapping\_status \= DEACTIVATED

depending on risk.

Reasons:

asset may be scanned by unintended guest
asset may still point to old store
asset may be physically outside merchant control

Core rule:

Lost physical control requires logical risk review.

10\. Damaged Asset Immediate Handling

When an asset is reported damaged, the system should:

mark physical\_asset\_status \= DAMAGED
mark audit\_status \= AUDIT\_PENDING or INSPECTION\_REQUIRED
review NFC status
review QR status
review printed text safety
review active mapping
block reallocation until inspection

If damaged asset is still installed and scannable, determine whether it should be suspended.

11\. NFC Failure Handling

If NFC fails but QR remains usable:

entry\_media\_status for NFC \= DEACTIVATED or NFC\_FAILED
QR media may remain ACTIVE if safe
physical\_asset\_status may become DAMAGED or REPAIR\_REQUIRED

The system must distinguish NFC failure from total plate failure.

Core rule:

One media channel may fail while another remains usable.
Track QR and NFC separately.

12\. QR Unreadable Handling

If QR is unreadable but NFC remains usable:

entry\_media\_status for QR \= DEACTIVATED or QR\_UNREADABLE
NFC media may remain ACTIVE if safe
physical\_asset\_status may become DAMAGED or REPAIR\_REQUIRED

If printed QR contains outdated or misleading store text, the plate may need replacement even if NFC works.

13\. Misleading Physical Text

A plate may be technically scannable but physically misleading.

Examples:

old store name printed on plate
test label still visible
wrong language guide printed
obsolete brand name
wrong instruction such as payment enabled when not enabled

Such plate must not be reused without correction.

Core rule:

Physical message safety is part of asset safety.

14\. Inspection Required

Recovered, lost-found, or damaged assets may enter:

INSPECTION\_REQUIRED

Inspection should verify:

NFC scan works
QR scan works
QR resolves to expected inactive or test context
physical text is readable
old store-specific text removed or covered
plate condition acceptable
asset ID matches system record
no active unsafe mapping exists

Inspection result may be:

REALLOCATION\_READY
REPAIR\_REQUIRED
DAMAGED
RETIRED

15\. Repair Required

If asset can be repaired, use:

REPAIR\_REQUIRED

Repair may include:

replace NFC sticker
reprint QR label
replace plate surface
cover old store label
clean physical plate
replace stand or adhesive

After repair, asset must return to inspection before reallocation.

Flow:

DAMAGED
→ REPAIR\_REQUIRED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

16\. Found After Lost

If a lost asset is later found, do not directly reactivate it.

Flow:

LOST
→ FOUND\_PENDING\_VERIFICATION
→ INSPECTION\_REQUIRED

Only after verification may it become:

REALLOCATION\_READY

or:

RETIRED

Core rule:

Found does not mean trusted.

17\. Retirement Preconditions

Before retirement, record:

entry\_plate\_id
entry\_media\_id if applicable
last known assignment
last known mapping
retirement reason
asset condition
actor
timestamp
trace\_id

Retirement must create audit event.

Suggested event:

ENTRY\_PLATE\_RETIRED

or:

ENTRY\_MEDIA\_RETIRED

18\. Retirement Reasons

Suggested retirement reasons:

NFC\_PERMANENT\_FAILURE
QR\_PERMANENT\_UNREADABLE
PHYSICAL\_DAMAGE\_SEVERE
BRANDING\_OBSOLETE
SECURITY\_CONCERN
LOST\_UNRECOVERABLE
WRONG\_MAPPING\_RISK
REPEATED\_FAILURE
FIELD\_SAFETY\_ISSUE

Retirement reason must be mandatory.

Core rule:

No retirement without reason.

19\. Reallocation Block

The system must block reallocation when asset status is:

LOST
DAMAGED
NFC\_FAILED
QR\_UNREADABLE
INSPECTION\_REQUIRED
REPAIR\_REQUIRED
RETIRED
FOUND\_PENDING\_VERIFICATION

unless the relevant inspection or repair process changes the status to:

REALLOCATION\_READY

Core rule:

Only verified assets may be reallocated.

20\. Guest Scan On Lost Asset

If a lost asset is scanned and mapping is inactive, show safe message.

Guest-facing message:

This guide is currently not available.
Please ask staff.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

If a lost asset scan occurs repeatedly, create support signal.

Possible signal:

LOST\_ENTRY\_MEDIA\_SCANNED

21\. Guest Scan On Damaged Asset

If damaged asset still scans, the system should check mapping safety.

If mapping is active but asset is marked damaged, possible handling:

allow safe menu-only flow if risk is low
or suspend if physical message is misleading
or create support signal for inspection

Default should be conservative.

Core rule:

Damaged but active requires review.

22\. Guest Scan On Retired Asset

Retired asset scan must not enter normal guest flow.

Handling:

block guest flow
show inactive message
create scan failure event
create support signal if repeated

Possible signal:

RETIRED\_ENTRY\_MEDIA\_SCANNED

Core rule:

Retired media must not operate.

23\. Active Mapping Conflict

Lost, damaged, or retired asset with active mapping is an inconsistency.

Examples:

physical\_asset\_status \= LOST
mapping\_status \= ACTIVE

physical\_asset\_status \= RETIRED
mapping\_status \= ACTIVE

physical\_asset\_status \= DAMAGED
entry\_media\_status \= ACTIVE
audit\_status \= AUDIT\_NOT\_REQUIRED

Such inconsistencies should generate support signal or audit review.

24\. Support Signals

Support signals may include:

LOST\_PLATE\_STILL\_ACTIVE
LOST\_ENTRY\_MEDIA\_SCANNED
DAMAGED\_PLATE\_STILL\_ACTIVE
DAMAGED\_PLATE\_NEEDS\_INSPECTION
RETIRED\_MEDIA\_SCANNED
RETIRED\_PLATE\_ASSIGNMENT\_ATTEMPTED
NFC\_FAILED\_BUT\_ACTIVE
QR\_UNREADABLE\_BUT\_ACTIVE
FOUND\_LOST\_ASSET\_REQUIRES\_VERIFICATION
RELOCATION\_BLOCKED\_ASSET\_UNSAFE

Support Signal does not mutate asset state.

It alerts authorized operators.

25\. Failure Events

Invalid actions must create typed failure events.

Example invalid actions:

assign lost asset
assign retired asset
reallocate damaged asset without inspection
reactivate found asset without verification
keep retired mapping active
mark damaged asset as ready without inspection

Example failure codes:

WOH.ENTRY\_MEDIA.ASSET.ASSIGN.LOST\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.ASSET.ASSIGN.RETIRED\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.ASSET.REALLOCATE.DAMAGED\_WITHOUT\_INSPECTION\_DENIED
WOH.ENTRY\_MEDIA.ASSET.REACTIVATE.FOUND\_WITHOUT\_VERIFICATION\_DENIED
WOH.ENTRY\_MEDIA.ASSET.MAPPING.RETIRED\_ACTIVE\_CONFLICT
WOH.ENTRY\_MEDIA.ASSET.STATUS.INSPECTION\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

26\. Audit Events

Recommended audit events:

ENTRY\_PLATE\_LOST\_REPORTED
ENTRY\_PLATE\_DAMAGED\_REPORTED
ENTRY\_MEDIA\_NFC\_FAILED
ENTRY\_MEDIA\_QR\_UNREADABLE
ENTRY\_PLATE\_INSPECTION\_REQUIRED
ENTRY\_PLATE\_REPAIR\_REQUIRED
ENTRY\_PLATE\_FOUND\_AFTER\_LOST
ENTRY\_PLATE\_VERIFIED\_AFTER\_FOUND
ENTRY\_PLATE\_REALLOCATION\_BLOCKED
ENTRY\_PLATE\_RETIRED
ENTRY\_MEDIA\_RETIRED

Audit event fields:

event\_id
entry\_plate\_id
entry\_media\_id
previous\_status
new\_status
actor\_type
actor\_id
reason
evidence\_ref
created\_at
trace\_id
last\_known\_store\_id
last\_known\_assignment\_id
last\_known\_mapping\_id

27\. Evidence Requirements

Evidence may include:

field note
photo
scan test result
NFC test result
QR scan result
operator confirmation
merchant message
support ticket reference
audit reviewer note

Evidence should be proportional.

Do not collect unnecessary personal data.

28\. Last Known Assignment Preservation

Lost, damaged, or retired asset must preserve last known assignment.

Recommended fields:

last\_known\_store\_id
last\_known\_assignment\_id
last\_known\_mapping\_id
last\_known\_placement
last\_known\_status\_at\_report
reported\_at
reported\_by

This helps support investigate later scans or merchant disputes.

Core rule:

Unsafe asset status must not erase location memory.

29\. Mapping Deactivation Relationship

If lost, severely damaged, or retired asset has active mapping, mapping should usually be deactivated or suspended.

Mapping action should follow:

00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md

Core separation:

Asset status says whether the plate is physically/logically safe.
Mapping status says whether scan resolves to runtime context.

Both must be tracked.

30\. Admin Access Relationship

Lost or damaged Entry Plate does not automatically mean admin access must be suspended.

However, if service is terminated or trial ended, admin access may need suspension.

Core rule:

Asset issue and admin access issue are separate unless policy links them.

Example:

plate damaged
→ replace plate
→ admin remains active

trial ended and plate lost
→ admin suspended
→ mapping deactivated
→ asset marked lost

31\. Replacement Asset

If a store needs a replacement plate:

mark old asset DAMAGED, LOST, or RETIRED
deactivate old mapping if needed
assign replacement plate
create new mapping
preserve old assignment history
record replacement reason

Core rule:

Replacement creates new asset relationship.
It does not erase old asset history.

32\. Obsolete Branding

A physical plate may be retired due to obsolete branding or wording.

Examples:

old product name
wrong service name
outdated legal notice
wrong guest instruction
old trial wording

Obsolete branding may require:

REPAIR\_REQUIRED

or:

RETIRED

depending on whether relabeling is possible.

33\. Security Concern

If asset may be used maliciously or unsafely:

mark security review
suspend mapping
block reallocation
create audit event
create support signal
retire if needed

Security concern may include:

tampered QR
replaced NFC sticker
unknown redirect behavior
suspected counterfeit plate
unauthorized field use

Core rule:

Suspected tampering must fail closed.

34\. Counterfeit Or Unknown Plate

If a plate is found that is not registered:

do not activate
do not assign
mark as UNKNOWN\_ASSET\_REVIEW if tracked
verify physical QR/NFC
check whether QR/NFC exists in system
escalate to admin/security

Possible failure code:

WOH.ENTRY\_MEDIA.ASSET.UNKNOWN\_FOUND

Unknown plate must not be treated as valid inventory.

35\. Minimum MVP Requirement

MVP should support at least:

LOST status
DAMAGED status
RETIRED status
INSPECTION\_REQUIRED status
REALLOCATION\_READY block until inspection
active mapping conflict detection
basic audit event
basic failure event
basic support signal
last known assignment preservation

MVP may defer:

repair workflow detail
photo evidence storage
batch inspection app
counterfeit detection automation
advanced asset depreciation tracking

36\. Relationship To Field SOP

Field SOP may define:

how to collect damaged plate
how to photograph condition
how to test NFC
how to test QR
how to store retired plate
how to dispose plate

This policy defines:

what system state must be recorded
what transitions are allowed
what history must be preserved
what unsafe actions are blocked

Core separation:

SOP handles field procedure.
This policy handles system truth.

37\. Relationship To Test And Production Separation

If lost or damaged asset is test/sample media, it must still be tracked.

Related policy:

00340\_Entry\_Media\_Test\_Field\_Sample\_And\_Production\_Separation\_Policy.md

Test/sample assets are not exempt from lost/damaged/retired tracking.

38\. Final Rule

Lost, damaged, and retired Entry Media must not create unsafe guest flow, wrong-store routing, or erased asset history.

Final rule:

Mark the asset.
Review the mapping.
Block unsafe reuse.
Preserve last known assignment.
Inspect before reallocation.
Retire with reason.
Never reactivate lost or retired media without verification.
