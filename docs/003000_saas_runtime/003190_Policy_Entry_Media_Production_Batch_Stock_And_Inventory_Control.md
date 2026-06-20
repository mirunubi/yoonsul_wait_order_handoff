# 003190_Policy_Entry_Media_Production_Batch_Stock_And_Inventory_Control.md

## Purpose

This document defines the SaaS runtime or entry media inventory topic indicated by its filename and preserves its governed documentation role within `docs/003000_saas_runtime/`.

Legacy path: $old.

1\. Purpose

This document defines the production batch, stock, and inventory control policy for CatchMenu Entry Media and Entry Plates.

Entry Plates are physical reusable assets.

They may be produced in batches, stocked, assigned to stores, used as field samples, recovered, inspected, repaired, reallocated, damaged, lost, or retired.

The system must know how many Entry Plates exist, where they are, what status they have, and whether they are safe to assign.

Core purpose:

Track Entry Plate production batches.
Control Entry Media stock.
Prevent unregistered plates from field use.
Support assignment, recovery, and reallocation.
Maintain physical inventory truth.

Korean purpose:

Entry Plate 제작 배치를 추적한다.
Entry Media 재고를 관리한다.
등록되지 않은 플레이트가 현장에서 사용되지 않게 한다.
배정, 회수, 재배정을 지원한다.
물리 재고의 운영상 진실을 유지한다.

2\. Scope

This document covers:

Entry Plate production batch
stock registration
inventory location
field sample stock
trial stock
production stock
recovered stock
inspection stock
damaged stock
retired stock
batch-level tracking
asset-level tracking
inventory movement
stock count reconciliation
audit events
failure events

This document does not define:

vendor contract
printing design specification
physical manufacturing process detail
field installation SOP
merchant sales process
menu intake
AI menu generation
Stage 0 request lifecycle
POS/KDS/payment integration

Related documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md
00340\_Entry\_Media\_Test\_Field\_Sample\_And\_Production\_Separation\_Policy.md
00350\_Entry\_Media\_Lost\_Damaged\_And\_Retired\_Asset\_Policy.md
00360\_Entry\_Media\_Identifier\_Encoding\_And\_Resolution\_Policy.md
00370\_Entry\_Media\_Scan\_Usage\_And\_Trial\_Observation\_Policy.md
00380\_Entry\_Media\_Admin\_Access\_Suspension\_And\_Service\_Termination\_Link\_Policy.md

3\. Core Principle

Entry Plates must be registered before field use.

Core rule:

No unregistered Entry Plate should be assigned, installed, or reallocated.

Korean rule:

등록되지 않은 Entry Plate는 배정, 설치, 재배정하면 안 된다.

The system must treat Entry Plates as controlled reusable assets, not disposable stickers.

4\. Production Batch Definition

A production batch is a group of Entry Plates produced together.

Production batch may include:

batch\_id
batch\_code
production\_vendor
production\_date
received\_date
quantity\_produced
quantity\_received
design\_version
print\_version
nfc\_type
qr\_print\_type
quality\_check\_status
created\_by
notes

Production batch helps answer:

Which batch produced this plate?
Which design version was used?
Were defective plates from the same batch?
How many plates remain from this batch?

5\. Asset-Level Registration

Each Entry Plate should be registered individually.

Recommended fields:

entry\_plate\_id
entry\_plate\_code
batch\_id
physical\_asset\_type
design\_version
print\_version
nfc\_id
qr\_id
initial\_status
registered\_at
registered\_by
current\_inventory\_location
current\_physical\_status
current\_assignment\_id

Core rule:

Batch tracks production.
Asset record tracks individual lifecycle.

6\. Inventory Location

Entry Plate inventory location should be tracked.

Suggested inventory locations:

HQ\_STOCK
FIELD\_OPERATOR\_STOCK
TEST\_LAB
TRIAL\_STORE
PRODUCTION\_STORE
RECOVERY\_PENDING\_FIELD
RECOVERED\_STOCK
INSPECTION\_AREA
REPAIR\_AREA
RETIRED\_STORAGE
UNKNOWN\_LOCATION

Location and status are related but not the same.

Example:

physical\_asset\_status \= RECOVERED
inventory\_location \= INSPECTION\_AREA

7\. Stock Categories

Inventory may be grouped by stock category.

Suggested categories:

NEW\_STOCK
FIELD\_SAMPLE\_STOCK
TRIAL\_READY\_STOCK
PRODUCTION\_READY\_STOCK
RECOVERED\_STOCK
INSPECTION\_REQUIRED\_STOCK
REPAIR\_REQUIRED\_STOCK
DAMAGED\_STOCK
LOST\_STOCK
RETIRED\_STOCK

Stock category should be derived from asset status and location when possible.

8\. Initial Stock Registration

When a new batch is received, operations/admin should register:

batch\_id
quantity\_received
entry\_plate\_id list
NFC ID list
QR ID list
design version
physical condition
initial inventory location
quality check result

Each plate should start as:

physical\_asset\_status \= IN\_STOCK
entry\_media\_status \= REGISTERED or PENDING\_ACTIVATION
assignment\_status \= none
mapping\_status \= none

unless preconfigured.

9\. Quality Check

New stock should pass basic quality check before field use.

Quality check should verify:

plate count
physical plate condition
printed QR readability
NFC scan response
entry media token validity
design version
guide text correctness
no visible old or wrong store text

Quality check result:

QC\_PENDING
QC\_PASSED
QC\_FAILED
QC\_REVIEW\_REQUIRED

Core rule:

QC failed stock must not become assignment-ready.

10\. Assignment-Ready Stock

An Entry Plate may be considered assignment-ready when:

registered
QC passed
not assigned
not lost
not damaged
not retired
NFC/QR registered
physical text safe
inventory location known

Suggested status:

REALLOCATION\_READY

or:

IN\_STOCK\_READY

depending on lifecycle stage.

11\. Field Operator Stock

Field operators may carry Entry Plates for trial installation or merchant demos.

Field operator stock must be tracked.

Recommended fields:

field\_operator\_id
entry\_plate\_id
checked\_out\_at
expected\_return\_at
purpose
current\_status
notes

Possible purposes:

MERCHANT\_TRIAL\_INSTALLATION
FIELD\_SAMPLE\_DEMO
REPLACEMENT\_PLATE
RECOVERY\_SWAP

Core rule:

Field stock is still inventory.
It must not disappear from asset control.

12\. Stock Checkout

When stock leaves central inventory, create checkout event.

Recommended event:

ENTRY\_PLATE\_STOCK\_CHECKED\_OUT

Fields:

entry\_plate\_id
from\_location
to\_field\_operator
purpose
checked\_out\_by
checked\_out\_at
expected\_return\_at
trace\_id

Stock checkout does not mean store assignment.

Assignment must be created separately.

13\. Stock Return

When stock returns from field operator, create return event.

Recommended event:

ENTRY\_PLATE\_STOCK\_RETURNED

Fields:

entry\_plate\_id
from\_field\_operator
to\_location
returned\_at
condition
return\_reason
trace\_id

Returned stock may need inspection before reuse.

14\. Store Installation Movement

When Entry Plate is installed at a store, inventory movement should record:

entry\_plate\_id
from\_location
to\_store\_id
placement
installed\_at
installed\_by
assignment\_id
mapping\_id
trace\_id

This movement should align with assignment policy.

Core rule:

Physical movement and logical assignment must be reconcilable.

15\. Recovered Stock

Recovered stock is physically returned from the field.

Recovered stock should not immediately become assignment-ready.

Expected flow:

RECOVERED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

Recovered stock must be inspected for:

physical damage
NFC functionality
QR readability
old store text
brand/design correctness
mapping deactivation
previous assignment closure

16\. Repair Stock

Repair stock includes assets that may be usable after fixing.

Repair may include:

QR label reprint
NFC sticker replacement
plate cleaning
guide text replacement
covering obsolete text
stand or adhesive replacement

Repair status should create event.

After repair:

REPAIR\_REQUIRED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

17\. Damaged Stock

Damaged stock must not be assigned.

Damaged stock may move to:

REPAIR\_REQUIRED

or:

RETIRED

depending on inspection.

Core rule:

Damaged stock is blocked until reviewed.

18\. Retired Stock

Retired stock is no longer usable.

Retired stock should be physically separated or clearly marked.

Retired stock must not be assigned or reallocated.

Suggested location:

RETIRED\_STORAGE

or disposal record if physically discarded.

19\. Lost Stock

Lost stock remains in inventory records but physical location is unknown.

Lost stock must be blocked from assignment.

Lost stock should preserve last known:

location
field operator
store
assignment
mapping
reported\_at
reported\_by

Core rule:

Lost does not mean deleted.

20\. Inventory Count

The system should support inventory count.

Count categories:

total\_registered
in\_stock
field\_sample
assigned\_to\_store
installed
recovery\_requested
recovered
inspection\_required
reallocation\_ready
damaged
lost
retired

Inventory count should help operations know how many plates can be deployed.

21\. Inventory Reconciliation

Inventory reconciliation compares system records with physical count.

Reconciliation may occur:

monthly
after batch receipt
after field campaign
after trial recovery wave
before large reallocation
when loss suspected

Reconciliation outcomes:

MATCHED
MISSING\_ASSET
UNREGISTERED\_ASSET\_FOUND
STATUS\_MISMATCH
LOCATION\_MISMATCH
INSPECTION\_REQUIRED

22\. Unregistered Asset Found

If an unregistered plate is found:

do not assign
do not activate
inspect physically
scan QR/NFC safely
verify whether media exists in system
register only through authorized process

Possible status:

UNKNOWN\_ASSET\_REVIEW

Core rule:

Found physical object is not trusted inventory until registered and verified.

23\. Inventory Movement Events

Recommended movement events:

ENTRY\_PLATE\_BATCH\_RECEIVED
ENTRY\_PLATE\_REGISTERED
ENTRY\_PLATE\_QC\_PASSED
ENTRY\_PLATE\_QC\_FAILED
ENTRY\_PLATE\_STOCK\_CHECKED\_OUT
ENTRY\_PLATE\_STOCK\_RETURNED
ENTRY\_PLATE\_FIELD\_SAMPLE\_ASSIGNED
ENTRY\_PLATE\_STORE\_INSTALLED
ENTRY\_PLATE\_RECOVERY\_REQUESTED
ENTRY\_PLATE\_RECOVERED\_TO\_STOCK
ENTRY\_PLATE\_MOVED\_TO\_INSPECTION
ENTRY\_PLATE\_MOVED\_TO\_REPAIR
ENTRY\_PLATE\_MARKED\_REALLOCATION\_READY
ENTRY\_PLATE\_MARKED\_DAMAGED
ENTRY\_PLATE\_MARKED\_LOST
ENTRY\_PLATE\_MARKED\_RETIRED

24\. Audit Fields

Inventory movement audit should include:

event\_id
entry\_plate\_id
batch\_id
previous\_location
new\_location
previous\_status
new\_status
actor\_type
actor\_id
reason
created\_at
trace\_id
related\_store\_id
related\_assignment\_id
related\_mapping\_id

Core rule:

Every physical inventory movement must be traceable.

25\. Failure Events

Invalid stock operations must create typed failure events.

Examples:

assign unregistered plate
assign QC failed plate
assign retired plate
assign lost plate
mark stock returned without plate identity
move assigned plate to stock without recovery
allocate same plate to two field operators

Example failure codes:

WOH.ENTRY\_MEDIA.STOCK.ASSIGN.UNREGISTERED\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.STOCK.ASSIGN.QC\_FAILED\_DENIED
WOH.ENTRY\_MEDIA.STOCK.ASSIGN.RETIRED\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.STOCK.ASSIGN.LOST\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.STOCK.RETURN.IDENTITY\_REQUIRED
WOH.ENTRY\_MEDIA.STOCK.MOVE.RECOVERY\_REQUIRED
WOH.ENTRY\_MEDIA.STOCK.CHECKOUT.ALREADY\_CHECKED\_OUT

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

26\. Support Signals

Support signals may be generated for:

LOW\_ASSIGNMENT\_READY\_STOCK
HIGH\_LOST\_STOCK\_COUNT
DAMAGED\_BATCH\_SUSPECTED
FIELD\_OPERATOR\_STOCK\_OVERDUE
RECOVERY\_STOCK\_NOT\_INSPECTED
UNREGISTERED\_ASSET\_FOUND
LOCATION\_MISMATCH
STATUS\_MISMATCH
QC\_FAILURE\_SPIKE

Support Signal does not mutate stock.

It alerts inventory/admin operators.

27\. Batch Defect Detection

If multiple plates from the same batch fail, the system may flag batch defect.

Possible signals:

BATCH\_NFC\_FAILURE\_SPIKE
BATCH\_QR\_UNREADABLE\_SPIKE
BATCH\_PRINT\_ERROR\_SUSPECTED
BATCH\_ADHESIVE\_FAILURE\_SUSPECTED

Batch defect may require:

quarantine batch
inspect remaining stock
suspend assignment from batch
replace affected plates

28\. Batch Quarantine

Batch quarantine may be used when a production defect is suspected.

Status:

BATCH\_QUARANTINED

Effects:

block new assignments from batch
flag field samples from batch
review installed plates from batch if needed
create support signal

Quarantine must be event-backed.

29\. Inventory And Mapping Separation

Inventory status and mapping status are separate.

Example:

physical\_asset\_status \= INSTALLED
mapping\_status \= ACTIVE

Example:

physical\_asset\_status \= RECOVERED
mapping\_status \= DEACTIVATED

Example inconsistency:

physical\_asset\_status \= RECOVERED
mapping\_status \= ACTIVE

which should trigger review.

Core rule:

Inventory says where the plate is.
Mapping says where the scan resolves.
Both must be reconcilable.

30\. Minimum MVP Requirement

MVP should support at least:

batch registration
entry plate registration
NFC/QR identity registration
in-stock status
field sample status
assigned/installed status
recovered status
inspection required status
reallocation ready status
damaged/lost/retired status
basic inventory count
basic movement event
basic failure event
basic support signal

MVP may defer:

advanced warehouse management
barcode scanning app
batch quarantine automation
vendor defect claim workflow
multi-region stock transfer
asset depreciation accounting

31\. Relationship To Field SOP

Field SOP may define:

how to carry plates
how to install plates
how to recover plates
how to inspect plates physically
how to package returned plates

This policy defines:

what system records must exist
what statuses are allowed
what movements must be audited
what unsafe stock actions are blocked

Core separation:

SOP moves the physical plate.
Inventory policy records asset truth.

32\. Final Rule

Entry Media stock must be controlled before it reaches the field and after it returns.

Final rule:

Register the batch.
Register every plate.
Check quality before use.
Track field movement.
Inspect recovered stock.
Block damaged and lost assets.
Retire unsafe plates.
Keep inventory count reconcilable.
Never assign unregistered stock.
