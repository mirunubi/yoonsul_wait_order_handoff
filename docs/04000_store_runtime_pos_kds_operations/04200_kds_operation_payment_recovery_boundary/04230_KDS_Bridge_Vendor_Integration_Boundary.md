04230 KDS Bridge Vendor Integration Boundary

1\. Purpose

This document defines the boundary between Yoonsul’s POS/KDS handoff policy and external KDS bridge or vendor integration.

The purpose is to prevent vendor integration from becoming transaction authority, menu authority, refund authority, inventory authority, or operational recovery authority.

A KDS bridge may transport, translate, confirm, retry, or replay kitchen ticket projections.

A KDS bridge must not own commercial order truth.

2\. Scope

This policy applies to:

\- External KDS vendor integration
\- POS-to-KDS bridge layer
\- Kitchen ticket projection transport
\- Vendor event mapping
\- Ticket delivery confirmation
\- Retry and replay behavior
\- Duplicate prevention
\- Vendor outage handling
\- Degraded operation fallback
\- Bridge audit and evidence
\- MVP vendor integration boundary

This policy does not define:

\- Vendor-specific API implementation
\- Final database schema
\- Final event enum
\- Printer driver implementation
\- POS payment logic
\- Refund workflow
\- Loyalty engine
\- Inventory deduction
\- Menu master management
\- Customer identity management
\- AI prediction model
\- Physical AI handoff

3\. Core Principle

The bridge is a translation and delivery layer.

The bridge is not authority.

POS accepted order \= transaction truth
Yoonsul KDS ticket projection \= kitchen work intent
KDS bridge \= translation / transport / delivery confirmation layer
External KDS \= kitchen execution surface

The bridge may adapt formats.

The bridge must not change meaning without evidence.

4\. Boundary Statement

The KDS bridge exists between Yoonsul’s internal order/kitchen policy layer and an external KDS, printer, display, or kitchen execution vendor.

The bridge may:

\- Receive KDS ticket projection
\- Translate payload format
\- Send ticket to vendor
\- Receive delivery response
\- Receive vendor state event
\- Map vendor state to Yoonsul state family
\- Retry failed delivery
\- Replay ticket projection
\- Mark delivery uncertainty
\- Record vendor failure evidence

The bridge must not:

\- Create POS order
\- Mutate payment
\- Approve refund
\- Grant loyalty
\- Mutate menu master
\- Mutate inventory master
\- Mutate customer identity
\- Silently delete accepted ticket
\- Rewrite accepted order truth
\- Hide vendor failure
\- Treat vendor response as final business resolution

5\. Integration Object Families

The bridge may handle the following object families.

Accepted order reference
Accepted order line reference
KDS ticket projection
Station route
Modifier display
Allergy/caution note
Fulfillment context
Timing context
Ticket state event
Vendor delivery response
Vendor failure event
Retry/replay event
Duplicate suspected event
Manual recovery event

Each object family must preserve traceability to the original accepted order or order line where applicable.

6\. Internal Source of Truth

Yoonsul’s internal source of truth should remain upstream of the bridge.

Internal truth includes:

\- POS accepted order
\- Order line reference
\- Payment state
\- Commercial cancellation state
\- Refund workflow state
\- Menu item identity
\- Store availability policy
\- Customer identity reference
\- Audit reference

The bridge consumes a kitchen projection.

The bridge does not become source of truth for these upstream objects.

7\. Vendor Response Boundary

Vendor responses may indicate technical or kitchen-display status.

Examples:

\- Received by vendor
\- Displayed
\- Printed
\- Acknowledged
\- In progress
\- Ready
\- Completed
\- Failed
\- Rejected
\- Timeout
\- Unknown

Vendor responses must be mapped into Yoonsul policy-level state families carefully.

A vendor response does not automatically mean the same thing as a Yoonsul business event.

8\. State Mapping Policy

The bridge may map vendor states to internal KDS state families.

Example mapping families:

Vendor Signal| Internal Policy Family
accepted / received| KDS\_TICKET\_RECEIVED
displayed / shown| KDS\_TICKET\_RECEIVED or SEEN
staff accepted| KDS\_TICKET\_ACKNOWLEDGED
cooking / preparing| IN\_PROGRESS
ready| READY
done / bumped| COMPLETED
failed / rejected| KDS\_TICKET\_FAILED
timeout| DELIVERY\_UNCERTAIN
duplicate| DUPLICATE\_SUSPECTED
resend| REPLAYED or RETRY\_ATTEMPTED

State mapping must be documented per vendor later.

The MVP policy must not assume every vendor has identical state semantics.

9\. Semantic Safety Rule

When vendor state meaning is uncertain, map to uncertainty rather than overclaiming.

Unknown receipt ≠ received
Received by vendor ≠ seen by staff
Displayed ≠ started
Ready ≠ handed to customer
Completed in KDS ≠ payment settled
Timeout ≠ failed with certainty

Uncertain state should trigger retry, duplicate-suspected, or manual recovery depending on risk.

10\. Payload Translation Policy

The bridge may translate internal KDS ticket projection into vendor payload.

Payload translation must preserve:

\- Source order reference
\- Source line reference where possible
\- Ticket reference
\- Item display name
\- Quantity
\- Modifiers
\- Allergy/caution notes
\- Fulfillment type
\- Timing note
\- Station route if supported
\- Remake/retry context if supported
\- Manual recovery marker if supported

If the vendor cannot support critical fields, the integration must define a fallback display strategy.

Allergy/caution note loss is not acceptable as ordinary truncation.

11\. Restricted Payload Data

The bridge should not send unnecessary sensitive or financial data to the vendor.

Avoid sending:

\- Full payment details
\- Full customer profile
\- Loyalty balance
\- Refund state
\- Staff payroll data
\- Internal settlement data
\- Private customer notes unrelated to kitchen work
\- Sensitive identity data not required for fulfillment

Vendor payload should be privacy-minimized.

12\. Allergy and Caution Vendor Boundary

Allergy and caution notes must be preserved across the bridge.

If a vendor cannot display allergy/caution notes clearly, the integration must define one of the following:

\- Block integration for allergy-sensitive tickets
\- Route to manual review
\- Add high-visibility kitchen note
\- Use printer fallback with explicit caution
\- Require manager confirmation
\- Treat as KDS exception

The bridge must not silently drop allergy/caution notes.

13\. Modifier Vendor Boundary

Modifiers must be preserved when they affect preparation, packaging, safety, or customer satisfaction.

If modifier mapping fails, the ticket should not be treated as normal.

Possible handling:

\- Mark exception
\- Use raw modifier text fallback
\- Route to staff confirmation
\- Use manual note
\- Prevent vendor send until resolved

Modifier loss can cause wrong preparation and customer recovery risk.

14\. Station Routing Vendor Boundary

If the vendor supports station routing, the bridge may map internal station families to vendor stations.

If the vendor does not support station routing, the bridge may:

\- Send all items to main kitchen
\- Use item prefix
\- Use printed section labels
\- Use separate device routing where available
\- Use manual station routing

Station routing limitation must not hide allergy/caution notes or modifiers.

15\. Fulfillment Context Vendor Boundary

The bridge should preserve fulfillment context where relevant.

Examples:

\- Dine-in
\- Takeout
\- Delivery
\- Pickup reservation
\- Table order
\- Waiting customer
\- Staff meal
\- Recovery order

If the vendor cannot model fulfillment context, the bridge should preserve it as kitchen note or display prefix where possible.

16\. Vendor Delivery Confirmation

Vendor delivery confirmation must be interpreted carefully.

Delivery confirmation may mean:

\- Vendor API accepted payload
\- Vendor server received ticket
\- Local device received ticket
\- Printer accepted print job
\- Staff screen displayed ticket
\- Staff acknowledged ticket

Each level has different operational meaning.

The bridge must not overstate the confirmation level.

17\. Retry Policy

The bridge may retry when delivery fails or becomes uncertain.

Retry must preserve:

\- Original accepted order reference
\- Original line reference
\- Original ticket reference or correlation key
\- Retry attempt count
\- Failure reason
\- Time
\- Vendor response if any

Retry must not create a new POS order.

Retry must not create duplicate kitchen work without review when prior receipt is uncertain.

18\. Replay Policy

Replay means reconstructing or re-sending the kitchen projection to the vendor.

Replay is allowed for:

\- Vendor timeout
\- Device reconnect
\- Bridge recovery
\- Local queue recovery
\- Printer failure
\- Audit reconstruction
\- Manual recovery comparison

Replay must append evidence.

Replay must not overwrite original failure history.

Replay must not mutate accepted order truth.

19\. Duplicate Prevention

The bridge must protect against duplicate tickets.

Duplicate risk may occur when:

\- Vendor times out after receiving ticket
\- Bridge retries after uncertain response
\- Device reconnects and receives old queue
\- Printer prints twice
\- Manual note already exists
\- Vendor sends duplicate event
\- Split/merge mapping changes after retry

Bridge should use stable idempotency keys where possible.

If duplicate status is uncertain, mark Duplicate Suspected.

20\. Idempotency Key Policy

The bridge should use stable identity anchors.

Possible anchors:

store\_id
source\_order\_id
source\_order\_line\_id
kds\_ticket\_id
station\_route
ticket\_purpose
remake\_sequence
replay\_sequence
vendor\_correlation\_id

The idempotency design may vary by vendor.

The principle is mandatory: the same kitchen work should not accidentally become repeated kitchen work.

21\. Vendor Failure Policy

Vendor failure may include:

\- API unavailable
\- Timeout
\- Invalid payload
\- Authentication failure
\- Device offline
\- Printer failure
\- State response missing
\- Duplicate event
\- Unsupported field
\- Vendor state mismatch
\- Vendor delivery confirmed but staff did not see ticket

Vendor failure should trigger:

\- Retry
\- Fallback
\- Manual recovery
\- Manager alert
\- Vendor support escalation
\- Audit event

The bridge must not hide vendor failure from operational recovery.

22\. Degraded Operation Boundary

When vendor integration becomes unreliable, the store may enter degraded KDS operation.

Possible triggers:

\- Bridge cannot deliver tickets
\- Vendor state is stale
\- Vendor device offline
\- Vendor response cannot be trusted
\- Duplicate risk is high
\- Allergy/caution fields are not displayed
\- POS/KDS/vendor mismatch persists

Degraded operation must follow the manual kitchen note policy.

Vendor recovery does not automatically mean operational recovery is complete.

23\. Manual Fallback Interaction

Manual kitchen notes may overlap with vendor bridge events.

The bridge must support later reconciliation between:

\- POS accepted order
\- Internal KDS ticket
\- Vendor ticket
\- Printer output
\- Manual kitchen note
\- Staff completion evidence

Manual note is evidence.

Vendor ticket is kitchen display evidence.

POS accepted order remains transaction truth.

24\. Vendor Outage Communication

Customer-facing communication should not expose vendor blame by default.

Allowed customer-safe messages:

Your order is being confirmed by the kitchen.
Preparation may take a little longer than expected.
A staff member is checking your item.
Your order is being prepared.

Avoid:

The vendor system failed.
The KDS bridge is down.
The API timed out.
The printer integration broke.

Internal staff may see technical failure details as needed.

25\. Vendor Support Escalation

Vendor support may be contacted for technical issues.

Vendor support may help with:

\- API delivery issue
\- Device display problem
\- Printer routing issue
\- State callback issue
\- Authentication issue
\- Payload field support
\- Duplicate event diagnosis

Vendor support must not decide:

\- Refund
\- Compensation
\- Customer recovery
\- Staff fault
\- Accepted order truth
\- Menu availability truth
\- Inventory truth

26\. Vendor Capability Classification

Each vendor integration should be classified by capability.

Suggested classification:

V0: No integration
V1: One-way ticket send
V2: Delivery confirmation
V3: Staff acknowledgment / status callback
V4: Retry/replay and duplicate protection
V5: Auditable operational integration

MVP may begin with V1 or V2 only if manual fallback and duplicate prevention policy are clear.

Pilot operation should target V3 or above where possible.

Production SaaS expansion should target V4 or V5.

27\. Vendor Field Support Checklist

Before selecting or integrating a vendor, confirm support for:

\[ \] Stable ticket reference
\[ \] Source order reference display
\[ \] Source line reference or equivalent
\[ \] Item display name
\[ \] Quantity
\[ \] Modifiers
\[ \] Allergy/caution notes
\[ \] Fulfillment type
\[ \] Table/pickup context
\[ \] Station routing
\[ \] Ticket status callback
\[ \] Retry/idempotency support
\[ \] Duplicate detection support
\[ \] Offline behavior
\[ \] Printer fallback
\[ \] Audit/export capability

If a field is unsupported, document fallback.

28\. MVP Bridge Cutline

MVP must-have:

Bridge does not own transaction authority
Stable source references preserved
Ticket payload preserves item/quantity/modifier/allergy/caution
Vendor delivery result is recorded
Retry/replay does not create new POS order
Duplicate suspected state exists
Vendor failure triggers fallback path
Manual kitchen note reconciliation is possible

MVP should-have:

Vendor status callback
Staff acknowledgment callback
Basic station mapping
Basic printer fallback
Bridge failure metrics
Vendor outage escalation SOP

Later:

Multi-vendor abstraction
Advanced state normalization
Automatic station balancing
AI delay prediction
Vendor marketplace
Physical AI translation module
Cross-store vendor reliability benchmark

29\. Bridge Event Families

Bridge-level event families may include:

BRIDGE\_TICKET\_PREPARED
BRIDGE\_TICKET\_SENT
BRIDGE\_VENDOR\_ACCEPTED
BRIDGE\_VENDOR\_REJECTED
BRIDGE\_VENDOR\_TIMEOUT
BRIDGE\_VENDOR\_RECEIVED
BRIDGE\_VENDOR\_ACKNOWLEDGED
BRIDGE\_VENDOR\_STATUS\_UPDATED
BRIDGE\_RETRY\_ATTEMPTED
BRIDGE\_REPLAY\_ATTEMPTED
BRIDGE\_DUPLICATE\_SUSPECTED
BRIDGE\_PAYLOAD\_FIELD\_LOSS
BRIDGE\_MANUAL\_RECOVERY\_REQUIRED
BRIDGE\_VENDOR\_OUTAGE\_DETECTED
BRIDGE\_RECOVERY\_COMPLETED

These are policy-level event families.

Final enum or schema may be defined later.

30\. Payload Field Loss Policy

Payload field loss occurs when the bridge cannot deliver or represent required data.

Critical field loss includes:

\- Item
\- Quantity
\- Modifier
\- Allergy/caution note
\- Fulfillment type
\- Source order reference
\- Source line reference where required

Critical field loss must not be treated as successful normal delivery.

Possible handling:

\- Block send
\- Mark exception
\- Send raw fallback note
\- Route to manager review
\- Trigger manual kitchen note
\- Mark vendor capability gap

31\. Audit and Evidence

Bridge events should preserve:

\- Internal ticket reference
\- Source order reference
\- Source line reference
\- Vendor ticket reference
\- Vendor correlation id
\- Payload version if applicable
\- Sent time
\- Response time
\- Vendor status
\- Failure reason
\- Retry count
\- Replay count
\- Staff/source if manual action
\- Field loss indicator
\- Manual recovery reference if applicable

Audit exists for reconstruction and reliability improvement.

Audit is not automatic staff blame.

32\. Security and Privacy

Vendor integration should follow privacy minimization.

The bridge should send only data needed for kitchen execution.

Vendor access should be scoped.

Vendor logs should not unnecessarily expose:

\- Full customer identity
\- Payment details
\- Loyalty balance
\- Private profile details
\- Internal financial settlement
\- Staff payroll or HR data

Security review may be required before production vendor integration.

33\. Vendor Lock-in Risk

KDS vendor behavior must not define Yoonsul’s core authority model.

Vendor-specific concepts should be mapped into Yoonsul policy-level state families.

The internal policy should remain portable across:

\- Vendor A
\- Vendor B
\- Printer-only fallback
\- Internal KDS
\- Local agent queue
\- Future physical AI translation module

Vendor integration must remain replaceable where possible.

34\. Non-goals

This document does not define:

\- Actual API endpoint
\- JSON payload
\- Database table
\- Vendor SDK usage
\- Authentication implementation
\- Printer driver setup
\- UI design
\- POS payment flow
\- Refund process
\- Loyalty process
\- Inventory engine
\- AI model
\- Physical AI control

35\. Acceptance Criteria

This boundary is ready when:

\- Bridge role is defined as translation/transport layer
\- Vendor integration is not transaction authority
\- Vendor response boundary is documented
\- State mapping safety is documented
\- Payload preservation requirements are documented
\- Restricted payload data is documented
\- Allergy/caution and modifier preservation are explicit
\- Retry and replay boundaries are documented
\- Duplicate prevention is documented
\- Vendor failure and degraded operation path are documented
\- Manual fallback reconciliation is documented
\- Vendor capability classification is documented
\- MVP bridge cutline is documented
\- Payload field loss policy is documented
\- Audit/security/vendor lock-in risks are documented
\- No implementation-specific vendor design is forced

36\. Open Questions

\- Should MVP start with one-way vendor send or require status callback?
\- Should vendor delivery confirmation be enough for Received, or should staff acknowledgment be required?
\- Should bridge retry be automatic, staff-triggered, or manager-triggered?
\- Should payload field loss block ticket send or send fallback text?
\- Should allergy/caution unsupported vendors be disallowed?
\- Should vendor outage automatically trigger degraded mode?
\- Should printer fallback be part of bridge responsibility or separate SOP?
\- Should vendor status be normalized before or after internal event storage?
\- Should each store be allowed to choose KDS vendor, or should HQ restrict vendors?
\- Should future multi-vendor bridge be designed before first MVP implementation?
