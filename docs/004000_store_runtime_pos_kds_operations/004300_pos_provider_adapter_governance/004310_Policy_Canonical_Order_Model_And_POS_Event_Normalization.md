# 004310_Policy_Canonical_Order_Model_And_POS_Event_Normalization

## **1\. Purpose**

This document defines the canonical order model and POS event normalization policy.

The purpose of this policy is to ensure that orders from different POS providers, table order systems, kiosks, mobile web orders, delivery apps, and manual intake flows can be converted into one internal operational language.

The system must not allow each POS provider’s data structure to leak into Payment Runtime, KDS Runtime, Customer Display Runtime, Agent Runtime, Audit Runtime, or Reconciliation Runtime.

All external order events must be normalized before they become part of the common operational flow.

---

## **2\. Scope**

This policy applies to:

* POS order intake
* POS order update
* POS order cancellation
* POS payment status intake
* Table order intake
* Kiosk order intake
* Customer mobile web order intake
* Delivery app order intake
* Manual order entry
* Legacy POS order import
* Order item normalization
* Modifier and option normalization
* Discount normalization
* Tax and service charge normalization
* Table and customer session reference normalization
* Order event replay and reconciliation

This policy does not define vendor contract terms, POS provider certification, payment provider commercial rules, refund approval, settlement allocation, or tax filing.

---

## **3\. Core Principle**

External systems may speak different languages.

The internal system must speak one operational language.

The core principle is:

external provider payload
external provider event
external order status
external item format
external payment label
        ↓
normalization
        ↓
canonical order model
        ↓
common runtime processing

The canonical order model is the internal contract between intake and operation.

---

## **4\. Canonical Order Model Definition**

The canonical order model is the internal standard structure used by the system to represent an order.

It should include at minimum:

internal\_order\_id
tenant\_id
store\_id
order\_source
order\_channel
external\_provider\_type
external\_provider\_name
external\_store\_id
external\_terminal\_id
external\_order\_id
external\_event\_id
customer\_session\_id
seating\_session\_id
table\_reference
order\_status
payment\_status
fulfillment\_status
kitchen\_release\_status
items
discounts
taxes
service\_charge
subtotal\_amount
discount\_amount
tax\_amount
service\_charge\_amount
total\_amount
currency
accepted\_at
created\_at
updated\_at
source\_confidence
normalization\_status
adapter\_name
adapter\_version
raw\_payload\_reference
audit\_event\_reference

Provider-specific data may be preserved, but internal operations should use this canonical structure.

---

## **5\. Canonical Order Identity Rule**

Every normalized order must have an internal order identity.

Required identity fields include:

internal\_order\_id
store\_id
tenant\_id
order\_source
created\_at

If the order comes from an external provider, it must also include:

external\_provider\_name
external\_store\_id
external\_order\_id

If external identity is incomplete, the order must be marked:

EXTERNAL\_ORDER\_IDENTITY\_INCOMPLETE

Such orders may still be operationally visible but must not be promoted to full authority state without review.

---

## **6\. Order Source Normalization**

External order sources must be normalized into internal order source values.

Allowed internal order source values include:

POS\_COUNTER
POS\_TABLE
TABLE\_ORDER
KIOSK
CUSTOMER\_MOBILE\_WEB
DELIVERY\_APP
MANUAL\_COUNTER
MANUAL\_KITCHEN
ADMIN\_CORRECTION
EXTERNAL\_PARTNER

The original external source label should be preserved separately.

Normalization must not erase the source of the order.

---

## **7\. Order Channel Normalization**

Order source and order channel are different.

Order channel should describe the commercial or operational channel.

Allowed order channel values include:

IN\_STORE
TAKEOUT
DINE\_IN
DELIVERY
PICKUP
RESERVATION\_ORDER
PREORDER
STAFF\_ENTERED
PARTNER\_ORDER

A single source may support multiple channels.

Example:

source \= CUSTOMER\_MOBILE\_WEB
channel \= DINE\_IN

or:

source \= CUSTOMER\_MOBILE\_WEB
channel \= PICKUP

---

## **8\. Order Status Normalization**

Provider-specific order statuses must be mapped into internal order statuses.

Allowed internal order statuses include:

DRAFT
CREATED
ACCEPTED
PAYMENT\_PENDING
CONFIRMED
IN\_PREPARATION
READY
SERVED
PICKED\_UP
COMPLETED
CANCELED
FAILED
EXPIRED
REQUIRES\_REVIEW

Provider-specific labels such as “open”, “submitted”, “done”, “closed”, “void”, or “served” must be mapped carefully.

If mapping is unclear, the order must be marked:

ORDER\_STATUS\_MAPPING\_UNCERTAIN

---

## **9\. Payment Status Normalization**

Payment status must be normalized separately from order status.

Allowed internal payment statuses include:

UNPAID
PAYMENT\_PENDING
PAYMENT\_AUTHORIZED
PAYMENT\_DONE
PAYMENT\_FAILED
PAYMENT\_CANCELED
PAYMENT\_EXPIRED
PARTIALLY\_PAID
REFUND\_PENDING
REFUNDED
PARTIALLY\_REFUNDED
PAYMENT\_STATUS\_UNKNOWN
PAYMENT\_STATUS\_CONFLICT

Payment status must not be inferred only from kitchen status or order completion.

Payment truth must come from POS payment authority, Payment Runtime, or verified provider status.

---

## **10\. Fulfillment Status Normalization**

Fulfillment status must be separate from payment status.

Allowed internal fulfillment statuses include:

NOT\_RELEASED
WAITING\_PAYMENT
RELEASED\_TO\_KITCHEN
IN\_PREPARATION
HELD
READY
SERVED
PICKED\_UP
PARTIALLY\_FULFILLED
CANCELED\_BEFORE\_PREPARATION
CANCELED\_AFTER\_PREPARATION
FULFILLMENT\_STATUS\_UNKNOWN

A paid order may not yet be released to kitchen.

A kitchen-started order may still have payment uncertainty under manual fallback.

These dimensions must remain separate.

---

## **11\. Kitchen Release Status Normalization**

Kitchen release status should describe whether the order is actionable by KDS.

Allowed kitchen release statuses include:

NOT\_ELIGIBLE
WAITING\_PAYMENT
READY\_TO\_RELEASE
RELEASED
HOLD
PAYMENT\_UNCERTAIN
SOURCE\_CONFLICT\_HOLD
MANUAL\_RELEASE\_APPROVED
CANCELLED

Kitchen release status must not be directly controlled by external POS labels unless the integration level explicitly supports authority synchronization.

---

## **12\. Item Normalization**

Each order item must be normalized.

Canonical item fields should include:

internal\_order\_item\_id
internal\_order\_id
external\_item\_id
external\_item\_name
internal\_menu\_item\_id
internal\_recipe\_id
display\_name
quantity
unit\_price
line\_subtotal
line\_discount
line\_total
tax\_category
kitchen\_station
item\_status
source\_confidence
raw\_item\_reference

If internal mapping is missing, the item must be marked:

UNKNOWN\_EXTERNAL\_ITEM

or:

ITEM\_MAPPING\_REQUIRED

---

## **13\. Modifier And Option Normalization**

Modifiers and options must be normalized separately from base items.

Canonical modifier fields should include:

internal\_modifier\_id
internal\_order\_item\_id
external\_modifier\_id
external\_modifier\_name
internal\_modifier\_group\_id
internal\_option\_id
display\_name
quantity
price\_delta
kitchen\_note
mapping\_status

Modifier mapping must preserve customer intent.

If a modifier changes kitchen execution, it must be visible to KDS.

---

## **14\. Bundle And Set Menu Normalization**

Bundle, combo, and set menu structures must not be flattened carelessly.

Canonical bundle fields may include:

bundle\_id
bundle\_name
parent\_order\_item\_id
child\_order\_item\_ids
bundle\_price
component\_price\_visibility
kitchen\_split\_required

If provider bundle structure cannot be mapped safely, the order must be marked:

BUNDLE\_MAPPING\_REQUIRED

---

## **15\. Discount Normalization**

Discounts must be normalized separately from item price.

Canonical discount fields should include:

discount\_id
external\_discount\_id
discount\_type
discount\_name
discount\_scope
discount\_amount
discount\_rate
applied\_to\_order\_id
applied\_to\_item\_id
coupon\_reference
promotion\_reference
manual\_discount\_flag

Discount normalization must preserve whether the discount came from:

system promotion
coupon
staff manual discount
membership benefit
delivery app promotion
provider-side discount

Discount authority must not be assumed from display value alone.

---

## **16\. Tax And Service Charge Normalization**

Tax and service charge must be represented separately.

Canonical fields may include:

tax\_amount
tax\_included\_flag
tax\_category
service\_charge\_amount
service\_charge\_type
rounding\_amount
total\_amount
currency

If tax or service charge cannot be reliably mapped, the order must be marked:

TAX\_MAPPING\_UNCERTAIN

or:

SERVICE\_CHARGE\_MAPPING\_UNCERTAIN

---

## **17\. Amount Consistency Rule**

The normalized order must preserve amount consistency.

The system should calculate or compare:

item subtotal
discount total
tax total
service charge
rounding
final total
provider total
payment request amount
paid amount

If values do not match, the order must be marked:

ORDER\_AMOUNT\_MISMATCH

or:

PAYMENT\_AMOUNT\_MISMATCH

depending on where the mismatch occurs.

---

## **18\. Table And Session Normalization**

Table and customer session references must be normalized.

Canonical fields may include:

external\_table\_id
external\_table\_name
internal\_table\_id
seating\_session\_id
customer\_session\_id
party\_size
split\_order\_reference
merged\_table\_reference
table\_status

If table identity is unclear, the order must be marked:

TABLE\_REFERENCE\_UNCERTAIN

Table uncertainty must not corrupt order, payment, or kitchen authority.

---

## **19\. Time Normalization**

External providers may use different time formats or time zones.

The system must preserve:

provider\_event\_time
provider\_created\_at
provider\_updated\_at
received\_at
processed\_at
internal\_effective\_time
store\_local\_time

If chronology is unclear, the event must be marked:

EVENT\_CHRONOLOGY\_UNCERTAIN

The system must not silently overwrite newer verified state with older provider events.

---

## **20\. Raw Payload Rule**

The raw external payload must be preserved or referenced.

Raw payload is used for:

debugging
vendor dispute
adapter improvement
reconciliation
audit review
legal evidence if needed

Raw payload must not be modified to match canonical structure.

Normalization creates a derived internal representation.

It does not erase the original provider data.

---

## **21\. Normalization Status Model**

Each normalization attempt should produce a status.

Allowed normalization statuses include:

NORMALIZED
NORMALIZED\_WITH\_WARNING
NORMALIZATION\_FAILED
MAPPING\_REQUIRED
SOURCE\_CONFIDENCE\_LOW
RAW\_PAYLOAD\_ONLY
REQUIRES\_REVIEW

If normalization fails, the system should preserve the raw payload and create a review event.

---

## **22\. Source Confidence Model**

Each normalized order and event should include source confidence.

Allowed source confidence values include:

PROVIDER\_VERIFIED
PROVIDER\_WEBHOOK
PROVIDER\_API\_POLL
PROVIDER\_EXPORT
INTERNAL\_SYSTEM
STAFF\_CONFIRMED
CUSTOMER\_CONFIRMED
MANUAL\_ENTRY
LEGACY\_CAPTURE
UNKNOWN\_SOURCE

Low-confidence sources must not be promoted to verified authority without reconciliation.

---

## **23\. Event Normalization**

Provider-specific events must be normalized into internal order events.

Allowed internal event types include:

ORDER\_CREATED
ORDER\_ACCEPTED
ORDER\_UPDATED
ORDER\_CANCELED
ITEM\_ADDED
ITEM\_VOIDED
ITEM\_MODIFIED
DISCOUNT\_APPLIED
PAYMENT\_PENDING
PAYMENT\_DONE
PAYMENT\_FAILED
PAYMENT\_CANCELED
KITCHEN\_RELEASE\_REQUESTED
KITCHEN\_RELEASED
KITCHEN\_HELD
ORDER\_READY
ORDER\_COMPLETED
RECONCILIATION\_REQUIRED

The internal event must reference the external event when available.

---

## **24\. Idempotency Rule**

Normalized events must be idempotent.

The system should use:

external\_provider\_name
external\_event\_id
external\_order\_id
event\_type
payload\_hash
received\_at
adapter\_version

to prevent duplicate processing.

Duplicate normalized events must not create duplicate orders, duplicate kitchen tickets, duplicate payments, or duplicate audit conclusions.

---

## **25\. Conflict Detection Rule**

Normalization must detect conflicts instead of hiding them.

Conflict examples include:

same external order maps to two internal orders
same internal order receives two provider IDs
item total does not match provider total
payment status conflicts with Payment Runtime
table reference conflicts with seating session
cancellation arrives after kitchen completion
delivery app status conflicts with POS status

Allowed conflict states include:

ORDER\_IDENTITY\_CONFLICT
ORDER\_AMOUNT\_CONFLICT
PAYMENT\_STATUS\_CONFLICT
TABLE\_REFERENCE\_CONFLICT
ITEM\_MAPPING\_CONFLICT
EVENT\_CHRONOLOGY\_CONFLICT
SOURCE\_CONFLICT\_REVIEW\_REQUIRED

Conflict resolution must require reconciliation.

---

## **26\. Projection Rule**

Canonical order model may be used to build projections for:

KDS
customer display
staff display
payment dashboard
manager dashboard
audit view
reconciliation view
agent visibility

Projection may be rebuilt from events.

Projection must not replace source event truth.

Replay may rebuild display state, but must not mutate original normalized events.

---

## **27\. Audit Requirements**

The system must create append-only audit events for:

external payload received
normalization started
normalization completed
normalization failed
mapping required
source confidence assigned
amount mismatch detected
payment status conflict detected
table conflict detected
duplicate event ignored
canonical order created
canonical order updated
reconciliation required

Audit must link:

external provider reference
raw payload reference
adapter version
internal order reference
normalized event reference

---

## **28\. MVP Cutline**

For MVP, the system should support:

canonical order identity
external order ID mapping
order source normalization
basic order status mapping
basic payment status mapping
basic fulfillment status mapping
item list normalization
total amount normalization
raw payload reference
source confidence
normalization status
idempotency check
basic conflict flags
audit event creation

Excluded from MVP:

deep tax mapping
advanced bundle mapping
complex split payment mapping
full table merge and split logic
automatic conflict resolution
AI item mapping correction
cross-provider certification
multi-currency settlement
legal evidence automation

---

## **29\. Relationship To 04300**

Document 04300 defines the POS Provider Abstraction and Multi-POS Adapter boundary.

This document defines the internal canonical order model that receives normalized events from those adapters.

The relationship is:

04300 \= adapter boundary
04310 \= canonical order model and event normalization

Without 04310, each POS provider would leak its own structure into the rest of the system.

Without 04300, the canonical model would not have a controlled adapter boundary.

---

## **30\. Relationship To Payment And KDS Policies**

This document supports:

04260 POS Payment Webhook And Kitchen Release Boundary Policy
04270 Payment Failure Timeout Duplicate And Manual Confirmation Policy
04280 Customer Display Dynamic QR And Payment Status UX Policy
04290 Store Payment Device And Counter Bottleneck Reduction Policy

The canonical order model provides the normalized order state that those runtimes consume.

Payment Runtime must not depend on provider-specific POS payloads.

KDS Runtime must not depend on provider-specific POS payloads.

Customer Display Runtime must not depend on provider-specific POS payloads.

---

## **31\. Readiness Check**

This policy is ready when:

external POS order maps to internal order identity
order source is preserved
order channel is normalized
order status is separate from payment status
payment status is separate from fulfillment status
items and modifiers are mapped or flagged
amount mismatch is detectable
table uncertainty is visible
raw payload is preserved
source confidence is assigned
duplicate events are idempotent
conflicts require reconciliation
projections do not replace source truth
audit links external and internal references

---

## **32\. Summary**

Multi-POS integration requires one internal order language.

The canonical order model is that language.

External POS systems may differ in payload, event timing, item structure, payment labels, and table references.

The system must normalize those differences before orders reach Payment Runtime, KDS Runtime, Customer Display Runtime, Agent Runtime, Audit Runtime, or Reconciliation Runtime.

The goal is:

many external order systems
        ↓
one canonical order model
        ↓
safe common operation

This is the foundation for making the project work across real small stores, restaurants, franchise stores, and mixed POS environments.
