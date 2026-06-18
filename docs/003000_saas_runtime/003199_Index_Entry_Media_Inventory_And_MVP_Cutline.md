# 003199_Index_Entry_Media_Inventory_And_MVP_Cutline

Legacy path: $old.

1\. Purpose

This document closes the "00300\_entry\_media\_inventory" folder by defining the document index, MVP cutline, deferred scope, and implementation boundary for CatchMenu Entry Media Inventory.

Entry Media Inventory is a root-level asset governance area.

It manages reusable QR/NFC Entry Plates, mapping history, status lifecycle, field stock, scan observation, and safe reallocation.

Core purpose:

Summarize Entry Media Inventory documents.
Define MVP implementation cutline.
Separate must-have from later enhancements.
Prevent Stage 0 from owning root-level asset lifecycle.
Keep QR/NFC physical asset governance traceable.

Korean purpose:

Entry Media Inventory 문서 묶음을 정리한다.
MVP 구현 컷라인을 정의한다.
필수 항목과 후순위 항목을 분리한다.
Stage 0이 루트급 자산 생명주기를 소유하지 않게 한다.
QR/NFC 물리 자산 거버넌스를 추적 가능하게 유지한다.

2\. Folder Role

This folder governs:

reusable Entry Plate inventory
QR/NFC identity
store-level mapping
mapping history
asset status lifecycle
test/sample/trial/production separation
lost/damaged/retired asset handling
identifier encoding and server-side resolution
scan usage observation
admin suspension and service termination link
production batch and stock control

This folder is not a runtime request flow.

This folder is not a merchant SOP.

This folder is not menu creation.

This folder is not POS/KDS/payment integration.

3\. Document Index

This folder contains:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md
00340\_Entry\_Media\_Test\_Field\_Sample\_And\_Production\_Separation\_Policy.md
00350\_Entry\_Media\_Lost\_Damaged\_And\_Retired\_Asset\_Policy.md
00360\_Entry\_Media\_Identifier\_Encoding\_And\_Resolution\_Policy.md
00370\_Entry\_Media\_Scan\_Usage\_And\_Trial\_Observation\_Policy.md
00380\_Entry\_Media\_Admin\_Access\_Suspension\_And\_Service\_Termination\_Link\_Policy.md
00390\_Entry\_Media\_Production\_Batch\_Stock\_And\_Inventory\_Control\_Policy.md
00399\_Entry\_Media\_Inventory\_Index\_And\_MVP\_Cutline.md

4\. Core Constitution

Entry Media Inventory follows these constitution-level rules:

Entry Media is a reusable root-level asset.
Stage 0 may use Entry Media but does not own it.
QR/NFC contains an identifier, not full operational truth.
Server-side mapping resolves store/menu/stage context.
Mapping history must never be erased.
Deactivation is logical.
Recovery is physical.
Reallocation creates new history.
Lost, damaged, and retired assets must fail closed.
Admin access, service status, mapping status, and physical status are separate axes.

Korean summary:

Entry Media는 재사용 가능한 루트급 자산이다.
Stage 0은 Entry Media를 사용할 뿐 소유하지 않는다.
QR/NFC에는 전체 운영 데이터가 아니라 식별자를 넣는다.
매장/메뉴/단계 컨텍스트는 서버 매핑으로 해석한다.
매핑 이력은 삭제하지 않는다.
비활성화는 논리 상태다.
회수는 물리 상태다.
재배정은 새 이력을 만든다.
분실/파손/폐기 자산은 안전하게 차단한다.
관리자 접근, 서비스 상태, 매핑 상태, 물리 상태는 서로 다른 축이다.

5\. MVP Must-Have Scope

MVP must support the minimum system of record for reusable QR/NFC Entry Plates.

MVP must include:

Entry Plate registration
Entry Media registration
QR/NFC token identity
store-level assignment
active mapping
mapping deactivation
mapping history
basic scan resolution
inactive-safe guest message
trial assignment
trial expiration status
admin suspension status
recovery requested status
recovered status
reallocation ready status
reallocated status
lost status
damaged status
retired status
basic stock count
basic audit event
basic failure event
basic support signal

6\. MVP Entity Cutline

MVP may begin with these conceptual entities:

entry\_plates
entry\_media
entry\_media\_assignments
entry\_media\_mappings
entry\_media\_status\_events
entry\_media\_scan\_logs
entry\_media\_stock\_batches
entry\_media\_inventory\_movements

Optional but useful:

entry\_media\_support\_signals
entry\_media\_failure\_events
entry\_media\_trial\_observations

Actual database schema may be decided later.

This document defines governance, not final SQL.

7\. MVP Status Cutline

MVP should support these practical statuses.

Physical asset status:

IN\_STOCK
ASSIGNED\_TO\_STORE
INSTALLED
RECOVERY\_REQUESTED
RECOVERED
INSPECTION\_REQUIRED
REALLOCATION\_READY
LOST
DAMAGED
RETIRED

Entry media / mapping status:

REGISTERED
PENDING\_ACTIVATION
ACTIVE
SUSPENDED
DEACTIVATION\_REQUESTED
DEACTIVATED
REPLACED
EXPIRED
INVALIDATED
RETIRED

Trial status:

TRIAL\_PENDING
TRIAL\_ACTIVE
TRIAL\_EXPIRED
CONVERTED
DECLINED
NOT\_USING
RECOVERY\_REQUIRED

Admin access status:

ADMIN\_NOT\_CREATED
ADMIN\_ACTIVE
ADMIN\_SUSPENSION\_REQUESTED
ADMIN\_SUSPENDED
ADMIN\_REACTIVATION\_REQUESTED
ADMIN\_REACTIVATED

8\. MVP Flow 1: New Plate Registration

Minimum flow:

produce or receive Entry Plate
→ register Entry Plate
→ register QR/NFC identity
→ QC passed
→ IN\_STOCK
→ assignment-ready

Required evidence:

entry\_plate\_id
entry\_media\_id
batch\_id if available
QR/NFC identity
physical status
registered\_at
registered\_by

9\. MVP Flow 2: Trial Store Assignment

Minimum flow:

IN\_STOCK
→ ASSIGNED\_TO\_STORE
→ ACTIVE mapping
→ TRIAL\_ACTIVE
→ INSTALLED

Required fields:

entry\_plate\_id
entry\_media\_id
store\_id
menu\_context\_id
enabled\_stage
placement
trial\_start\_at
trial\_end\_at
assigned\_by
trace\_id

Stage 0 POS-less trial may use:

table\_id \= null

Core rule:

Store-level Entry Media is valid for Stage 0 MVP.

10\. MVP Flow 3: QR/NFC Scan Resolution

Minimum flow:

guest scans QR/NFC
→ token resolved
→ active mapping found
→ store/menu/stage context returned
→ Stage 0 guest flow starts

Failure flow:

scan
→ no active mapping or unsafe status
→ safe inactive message
→ scan failure event

Guest-facing safe message:

This guide is currently not available.
Please ask staff.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

11\. MVP Flow 4: Trial Expiration And Non-Conversion

Minimum flow:

TRIAL\_ACTIVE
→ TRIAL\_EXPIRED
→ ADMIN\_SUSPENSION\_REQUESTED
→ DEACTIVATION\_REQUESTED
→ RECOVERY\_REQUESTED

After processing:

ADMIN\_SUSPENDED
MAPPING\_DEACTIVATED
RECOVERY\_REQUESTED

Core rule:

Trial expiration starts shutdown workflow.
It does not delete mapping history.

12\. MVP Flow 5: Physical Recovery

Minimum flow:

RECOVERY\_REQUESTED
→ RECOVERED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

Required evidence:

recovered\_at
recovered\_by
condition
entry\_plate\_id
previous\_store\_id
previous\_assignment\_id
previous\_mapping\_id

Core rule:

Recovered does not automatically mean reallocation-ready.
Inspection is required.

13\. MVP Flow 6: Reallocation

Minimum flow:

REALLOCATION\_READY
→ new assignment
→ new mapping
→ ACTIVE

Old mapping must remain:

previous mapping \= DEACTIVATED / HISTORICAL
new mapping \= ACTIVE

Core rule:

Reallocation creates a new assignment period.
It must not overwrite the old assignment period.

14\. MVP Flow 7: Lost / Damaged / Retired

Lost flow:

INSTALLED or RECOVERY\_REQUESTED
→ LOST
→ mapping review
→ mapping suspended or deactivated
→ reallocation blocked

Damaged flow:

RECOVERED or INSTALLED
→ DAMAGED
→ INSPECTION\_REQUIRED
→ REPAIR\_REQUIRED or RETIRED or REALLOCATION\_READY

Retired flow:

DAMAGED or LOST or INVALIDATED
→ RETIRED

Core rule:

Lost, damaged, and retired assets must not be reassigned without verification.

15\. MVP Scan Observation

MVP should capture lightweight scan usage.

Minimum scan fields:

scan\_id
entry\_media\_id
entry\_plate\_id
scan\_time
resolution\_status
store\_id
menu\_context\_id
enabled\_stage
placement
failure\_code
trace\_id

MVP usage summary:

scan\_count
qr\_scan\_count
nfc\_tap\_count
last\_scan\_at
failure\_count
trial\_usage\_level

MVP may classify:

NO\_USAGE
LOW\_USAGE
MEANINGFUL\_USAGE

Advanced analytics can wait.

16\. MVP Support Signals

MVP should support basic support signals:

NO\_ACTIVE\_MAPPING\_SCAN
MULTIPLE\_ACTIVE\_MAPPING\_SCAN
DEACTIVATED\_MEDIA\_SCANNED
LOST\_MEDIA\_SCANNED
RETIRED\_MEDIA\_SCANNED
TRIAL\_NO\_USAGE\_DETECTED
TRIAL\_EXPIRED\_MAPPING\_STILL\_ACTIVE
SERVICE\_TERMINATED\_MAPPING\_ACTIVE
RECOVERY\_REQUESTED\_BUT\_NOT\_RECOVERED
REALLOCATION\_BLOCKED\_ASSET\_UNSAFE

Support Signal does not mutate state.

It alerts authorized operators.

17\. MVP Failure Events

MVP should support failure events for unsafe operations.

Examples:

assign unregistered plate
assign lost plate
assign retired plate
reallocate active assignment
activate without store context
activate without menu context
multiple active mappings
no active mapping
reactivate terminated merchant without review

Failure event should include:

failure\_code
entity\_id
actor\_id
reason
created\_at
trace\_id

18\. Deferred Scope

The following may be deferred after MVP:

advanced warehouse inventory
barcode scan inventory app
batch quarantine automation
vendor defect workflow
geo-based scan anomaly detection
cross-store cohort analytics
advanced token rotation
anti-counterfeit detection
bulk reallocation workflow
field route optimization
automated billing-linked suspension
complex approval workflow

Deferred does not mean ignored.

Deferred means not required for first reliable launch.

19\. AI Menu Intake Boundary

AI Menu Intake is required for future merchant onboarding.

However, it does not belong inside Entry Media Inventory.

Separation:

Entry Media Inventory
\= QR/NFC asset, mapping, scan resolution, lifecycle

AI Menu Intake
\= menu photo/PDF/image analysis, menu draft generation, price extraction, translation draft

Possible future document:

docs/02400\_owner\_console/02440\_AI\_Menu\_Intake\_And\_Menu\_Draft\_Generation\_Policy.md

or equivalent owner/admin onboarding folder.

Core rule:

Entry Media opens the door.
AI Menu Intake builds the menu draft.
They are connected but not the same module.

20\. Relationship To SOP

Field SOP lives outside "docs/".

Relevant SOP path:

sop/entry\_media\_operations/SOP\_Entry\_Media\_Trial\_Installation\_Recovery\_And\_Reallocation.md

Separation:

docs/00300\_entry\_media\_inventory/
\= system policy and source of operational truth

sop/entry\_media\_operations/
\= field action, merchant communication, installation, recovery, checklist

Core rule:

SOP tells people what to do.
Inventory policy tells the system what must be recorded.

21\. Relationship To Stage 0

Stage 0 should reference Entry Media Inventory for QR/NFC resolution.

Correct dependency:

Entry Media Inventory
→ resolves QR/NFC into store/menu/stage context
→ Stage 0 runs guest flow

Incorrect dependency:

Stage 0 owns QR/NFC plate assignment and reallocation

Core rule:

Stage 0 uses assigned Entry Media.
Stage 0 does not own Entry Media lifecycle.

22\. Relationship To Owner Console

Owner Console may show simplified asset/admin status to merchants.

Merchant-facing allowed concepts:

guide active
guide inactive
trial active
trial ended
needs replacement
contact support

Internal-only concepts:

mapping\_id
assignment\_id
trace\_id
REALLOCATION\_READY
failure code
support signal
audit event id

unless support/admin mode is enabled.

23\. Relationship To Merchant Ops

Merchant Ops may use Entry Media usage and trial signals to decide:

follow-up call
training
trial extension
conversion conversation
plate recovery
reallocation planning

But usage signal must not directly mutate asset state.

Core rule:

System signals.
Operations decides.
Authorized workflow mutates.

24\. Implementation Boundary

This folder does not require full implementation immediately.

First implementation should focus on:

register asset
assign to store
resolve scan
deactivate mapping
recover asset
reallocate safely
preserve history

Avoid overbuilding:

complex logistics
advanced analytics
over-detailed approval chains
deep warehouse system

The first goal is safe asset reuse, not enterprise-grade inventory management.

25\. Operational Risk If Skipped

If Entry Media Inventory is not built properly, risks include:

QR/NFC points to wrong store
old merchant keeps active guide after termination
trial plate cannot be recovered
plate reused without deactivation
mapping history lost
guest scans retired or lost plate
support cannot explain scan-time context
operations loses physical inventory
merchant disputes cannot be traced

Therefore, this folder is foundational even though it looks small.

26\. Final MVP Cutline

Minimum reliable launch requires:

one Entry Plate can be registered
one QR/NFC can be assigned to one store
guest scan resolves server-side
mapping can be deactivated
old mapping history is preserved
plate can be marked recovered
plate can be marked reallocation-ready
plate can be reassigned to another store
lost/damaged/retired states block reuse
trial expiration can suspend admin and deactivate mapping
basic scan usage can be counted

Anything beyond this can be phased.

27\. Final Rule

Entry Media Inventory exists to keep CatchMenu lightweight in the field but disciplined in the system.

Final rule:

Make the plate easy to install.
Make the QR/NFC easy to scan.
Keep the payload simple.
Resolve context server-side.
Track every assignment.
Preserve every mapping.
Recover unused assets.
Reallocate only with history.
Block unsafe reuse.
Do not let Stage 0 own root inventory.
