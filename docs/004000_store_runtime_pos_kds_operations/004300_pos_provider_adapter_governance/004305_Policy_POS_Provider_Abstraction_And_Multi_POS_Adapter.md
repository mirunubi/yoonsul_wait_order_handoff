# 004305_Policy_POS_Provider_Abstraction_And_Multi_POS_Adapter

## **1\. Purpose**

This document defines the policy for POS provider abstraction and multi-POS adapter integration.

The purpose of this policy is to prevent the system from becoming dependent on one specific POS provider, one payment provider, one order structure, or one vendor-specific event model.

The system must support multiple POS environments by translating external POS data into an internal canonical order model.

This allows Payment Runtime, KDS Runtime, Customer Display Runtime, Agent Runtime, Audit Runtime, and Reconciliation Runtime to operate consistently regardless of which POS provider the store uses.

---

## **2\. Scope**

This policy applies to:

* Cloud POS integration
* Local POS integration
* Legacy POS integration
* VAN-linked POS
* PG-linked POS
* Tablet POS
* Franchise POS
* Store-owned POS
* Delivery order intake
* Table order intake
* Kiosk order intake
* Manual order intake
* POS order status synchronization
* POS payment status synchronization
* POS cancellation and modification events
* POS-to-KDS handoff
* POS-to-Payment Runtime handoff
* POS-to-Audit Runtime handoff

This policy does not define vendor commercial contract terms, payment fee policy, settlement allocation, refund approval, tax reporting, or legal dispute handling.

---

## **3\. Core Principle**

The system must not hard-code store operation around a single POS provider.

External POS systems are input sources.

The internal system must normalize external POS events into a common operational language.

The core principle is:

many POS providers
many external event formats
many payment structures
many order structures
        ↓
POS Adapter Layer
        ↓
Canonical Order Model
        ↓
common Payment / KDS / Display / Agent / Audit flow

The system must treat POS provider diversity as a normal operating condition, not as an exception.

---

## **4\. POS Adapter Layer**

The POS Adapter Layer is responsible for translating provider-specific POS data into internal system events.

The adapter may handle:

order intake
order update
order cancellation
payment state intake
table reference mapping
menu item mapping
modifier mapping
discount mapping
tax mapping
receipt reference mapping
KDS ticket reference mapping
refund reference mapping
provider event deduplication
provider outage detection

The adapter must not become the owner of order truth unless explicitly authorized by integration level.

---

## **5\. Canonical Order Model**

All POS provider data must be translated into an internal canonical order model.

The canonical order model should include at minimum:

internal\_order\_id
external\_pos\_provider
external\_store\_id
external\_order\_id
store\_id
tenant\_id
order\_source
order\_channel
order\_status
payment\_status
fulfillment\_status
table\_reference
customer\_session\_id
items
modifiers
discounts
taxes
service\_charge
total\_amount
currency
accepted\_at
updated\_at
source\_confidence
adapter\_status
raw\_payload\_reference

The canonical model is not the same as the provider payload.

Provider-specific payloads should be preserved as raw evidence, but internal operations should use the normalized model.

---

## **6\. Order Source Types**

The system should support multiple order sources.

Allowed order source types include:

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

The order source must remain visible through the lifecycle of the order.

Source identity must not be lost during normalization.

---

## **7\. POS Provider Identity Rule**

Every external POS event must identify its provider context.

Required provider identity fields include:

external\_pos\_provider
external\_merchant\_id
external\_store\_id
external\_terminal\_id
external\_order\_id
external\_event\_id
provider\_event\_time
provider\_payload\_version
adapter\_version

If provider identity is incomplete, the event must be marked:

PROVIDER\_IDENTITY\_INCOMPLETE

and may require review before authority-level processing.

---

## **8\. Adapter Capability Levels**

POS integration must be classified by capability level.

### **Level 0: Manual / No API**

manual order entry
staff confirmation
paper receipt reference
manual kitchen note
limited automation

Level 0 must be marked as human-dependent.

### **Level 1: Read-Only Intake**

read POS orders
import order amount
import item list
display in internal dashboard
send to KDS projection

Level 1 does not allow internal system to modify POS state.

### **Level 2: Event Synchronization**

receive order update events
receive payment events
receive cancellation events
sync KDS visibility
sync customer display status

Level 2 may support limited state synchronization but does not own POS authority.

### **Level 3: Authority Integration**

create order
update order
confirm payment
trigger kitchen release
handle cancellation
support reconciliation

Level 3 requires strict contract, idempotency, audit, and rollback rules.

MVP should begin with Level 1 or Level 2\.

Level 3 must not be assumed for all providers.

---

## **9\. Authority Boundary**

POS Adapter may observe, translate, and relay provider events.

POS Adapter must not automatically own:

payment authority
refund authority
settlement authority
tax authority
legal dispute authority
kitchen execution authority
customer compensation authority

Authority must be assigned by runtime boundary and integration level.

Provider visibility is not provider authority.

Adapter translation is not business approval.

---

## **10\. POS Event Normalization**

Provider-specific events must be normalized into internal event types.

Example internal event types include:

POS\_ORDER\_CREATED
POS\_ORDER\_ACCEPTED
POS\_ORDER\_UPDATED
POS\_ORDER\_CANCELLED
POS\_PAYMENT\_PENDING
POS\_PAYMENT\_DONE
POS\_PAYMENT\_FAILED
POS\_PAYMENT\_REFUNDED
POS\_TABLE\_ASSIGNED
POS\_TABLE\_MOVED
POS\_ITEM\_VOIDED
POS\_DISCOUNT\_APPLIED
POS\_RECEIPT\_ISSUED
POS\_PROVIDER\_EVENT\_DELAYED
POS\_PROVIDER\_EVENT\_DUPLICATED
POS\_PROVIDER\_UNAVAILABLE

The system must preserve the raw provider event while creating a normalized internal event.

---

## **11\. Raw Payload Preservation**

Every provider event should preserve a raw payload reference.

The raw payload may be used for:

debugging
vendor dispute
reconciliation
audit review
adapter improvement
source confidence calculation
incident investigation

Raw payload must not be edited to fit internal expectations.

If normalization fails, the raw payload must still be stored or referenced when possible.

---

## **12\. Idempotency Rule**

POS provider events may arrive more than once.

The adapter must prevent duplicate internal processing.

Idempotency should check:

external\_pos\_provider
external\_event\_id
external\_order\_id
external\_payment\_id
external\_terminal\_id
event\_type
event\_time
payload\_hash

Duplicate events must be marked as:

DUPLICATE\_PROVIDER\_EVENT\_IGNORED

or:

DUPLICATE\_PROVIDER\_EVENT\_ALREADY\_PROCESSED

Duplicate provider events must not create duplicate orders, duplicate KDS tickets, duplicate payment records, or duplicate audit conclusions.

---

## **13\. Ordering And Chronology Rule**

POS provider events may arrive out of order.

The adapter must distinguish:

provider\_event\_time
received\_at
processed\_at
internal\_effective\_time

If event order is uncertain, the system must mark:

EVENT\_CHRONOLOGY\_UNCERTAIN

Out-of-order events must not silently overwrite newer verified internal state.

Replay and reconciliation must be used when necessary.

---

## **14\. Source Confidence Rule**

Each normalized event should carry source confidence.

Example source confidence values include:

PROVIDER\_VERIFIED
PROVIDER\_WEBHOOK
PROVIDER\_POLLING
PROVIDER\_EXPORT
STAFF\_CONFIRMED
CUSTOMER\_CONFIRMED
MANUAL\_ENTRY
OCR\_OR\_SCREEN\_CAPTURE
UNKNOWN\_SOURCE

Human-dependent or low-confidence sources must not be promoted to verified source without reconciliation.

---

## **15\. Menu And Item Mapping Rule**

POS menu items may not match internal menu definitions exactly.

The adapter must support mapping between:

external\_item\_id
external\_item\_name
internal\_menu\_item\_id
internal\_recipe\_id
modifier\_group
option\_id
bundle\_id
discount\_id
tax\_category

If item mapping is missing, the order may be marked:

ITEM\_MAPPING\_REQUIRED

or:

UNKNOWN\_EXTERNAL\_ITEM

KDS release may continue only if store policy allows unmapped item handling.

---

## **16\. Payment Status Mapping Rule**

POS payment status must be mapped carefully.

Provider payment status may include:

UNPAID
PENDING
AUTHORIZED
PAID
PARTIALLY\_PAID
FAILED
CANCELED
REFUNDED
PARTIALLY\_REFUNDED
CHARGEBACK
UNKNOWN

Internal payment status must remain consistent with Payment Runtime.

If POS and Payment Runtime disagree, the order must be marked:

PAYMENT\_STATUS\_CONFLICT

and reconciliation must be required.

---

## **17\. Cancellation And Void Rule**

POS cancellation, item void, and payment cancellation must be distinguished.

The adapter must not collapse all cancellation into a single event.

Required distinction:

ORDER\_CANCELLED
ITEM\_VOIDED
PAYMENT\_CANCELED
PAYMENT\_REFUNDED
KITCHEN\_CANCEL\_REQUESTED
KITCHEN\_CANCEL\_CONFIRMED
CUSTOMER\_CANCEL\_REQUESTED
STAFF\_CANCELLED

Kitchen action may have already started even if POS cancellation occurs.

The system must preserve kitchen and payment consequences separately.

---

## **18\. Table Reference Mapping Rule**

POS table references may differ from internal table/session references.

The adapter must support mapping:

external\_table\_id
external\_table\_name
internal\_table\_id
customer\_session\_id
seating\_session\_id
merged\_table\_reference
split\_table\_reference

If table reference is unclear, the order must be marked:

TABLE\_REFERENCE\_UNCERTAIN

Table uncertainty must not corrupt payment or kitchen authority.

---

## **19\. Delivery App And External Order Intake**

Delivery app orders may be treated as external order sources.

The system should distinguish:

DELIVERY\_APP\_ORDER
DELIVERY\_APP\_PAYMENT
DELIVERY\_APP\_CANCEL
DELIVERY\_APP\_MODIFICATION
DELIVERY\_APP\_PICKUP\_STATUS

Delivery app payment and settlement rules may differ from in-store POS payment.

The adapter must not assume that delivery app “paid” equals internal immediate settlement.

---

## **20\. Manual And Legacy POS Handling**

Legacy POS systems may not provide reliable APIs.

For such systems, the system may support:

manual order entry
CSV import
receipt reference entry
screen confirmation
staff-confirmed order
hybrid manual adapter

These events must be marked:

LEGACY\_POS\_LIMITED\_INTEGRATION

or:

HUMAN\_SOURCE\_DEPENDENT

Manual or legacy integration must not be presented as full authority integration.

---

## **21\. POS Provider Outage Rule**

If the POS provider is unavailable or delayed, the adapter must mark:

POS\_PROVIDER\_UNAVAILABLE
POS\_PROVIDER\_DELAYED
POS\_PROVIDER\_POLLING\_FAILED
POS\_PROVIDER\_WEBHOOK\_MISSING
POS\_PROVIDER\_STATUS\_UNKNOWN

The system may continue through fallback only when store policy allows it.

Fallback-originated orders must be marked:

FALLBACK\_ORIGINATED

and must later be reconciled.

---

## **22\. Conflict Handling Rule**

Conflict may occur between:

POS order status
Payment Runtime status
KDS Runtime status
Customer Display status
manual staff observation
delivery app status
provider dashboard status

Conflicts must not be silently resolved by last-write-wins.

Allowed conflict states include:

ORDER\_STATUS\_CONFLICT
PAYMENT\_STATUS\_CONFLICT
KITCHEN\_STATUS\_CONFLICT
TABLE\_REFERENCE\_CONFLICT
ITEM\_MAPPING\_CONFLICT
SOURCE\_CONFLICT\_REVIEW\_REQUIRED

Conflict resolution must create audit and reconciliation records.

---

## **23\. Adapter Versioning Rule**

Every adapter must have a version.

Adapter version must be recorded with each normalized event.

Required fields include:

adapter\_name
adapter\_version
mapping\_version
provider\_payload\_version
normalization\_rule\_version
processed\_at

When adapter mapping changes, previous normalized events must not be silently rewritten.

If reprocessing is required, replay must create new projections or reconciliation notes.

---

## **24\. Security Rule**

POS Adapter must protect provider credentials and store operation data.

The adapter must not expose:

provider API secret
merchant credential
payment key
raw customer payment data
admin token
webhook secret
staff personal data
unmasked customer information

Credentials must be scoped by tenant, store, provider, and integration purpose.

---

## **25\. Audit Requirements**

The system must create append-only audit events for:

provider connected
provider disconnected
adapter enabled
adapter disabled
provider event received
provider event normalized
normalization failed
duplicate provider event ignored
source confidence assigned
mapping conflict detected
payment status conflict detected
order status conflict detected
fallback started
reconciliation required
reconciliation completed

Audit must preserve the external provider reference and internal order reference.

---

## **26\. MVP Cutline**

For MVP, the system should support:

single provider adapter skeleton
external order intake
canonical order model
external order ID mapping
basic item mapping
basic payment status mapping
idempotency check
raw payload reference
adapter version
source confidence
KDS projection handoff
audit event creation

Excluded from MVP:

full bidirectional POS control
multi-provider certification
automatic refund integration
deep tax mapping
advanced split payment mapping
full table merge/split synchronization
cross-provider conflict automation
AI-based POS event correction

---

## **27\. Relationship To 04260, 04270, 04280, And 04290**

Document 04260 defines payment webhook and KDS release boundary.

Document 04270 defines payment failure, timeout, duplicate, and manual confirmation policy.

Document 04280 defines customer-facing QR and payment status UX.

Document 04290 defines store device placement and counter bottleneck reduction.

This document defines how multiple POS providers are abstracted before their orders enter those common runtimes.

The relationship is:

04300 \= POS provider abstraction and adapter boundary
04260 \= payment verification and KDS release
04270 \= payment uncertainty and failure handling
04280 \= customer-facing payment UX
04290 \= store device and bottleneck reduction

---

## **28\. Patent And SaaS Relevance**

This policy supports SaaS expansion because the system does not require all stores to use the same POS.

The key technical and business structure is:

external POS diversity
        ↓
adapter normalization
        ↓
canonical order model
        ↓
payment verification
        ↓
KDS release
        ↓
customer display
        ↓
audit and reconciliation

This allows small stores, franchise stores, and mixed POS environments to participate without immediate POS replacement.

The value is not a single POS integration.

The value is an abstraction layer that turns many POS environments into one operational runtime.

---

## **29\. Readiness Check**

This policy is ready when:

external POS provider identity is captured
external order ID maps to internal order ID
raw provider payload is preserved
events are normalized into internal event types
duplicate provider events are idempotent
adapter version is recorded
source confidence is assigned
payment status conflict is detectable
item mapping gaps are visible
fallback-originated legacy flows are marked
KDS receives normalized order state
audit trail links provider event to internal order

---

## **30\. Summary**

Multi-POS support must not be handled by writing one-off integrations everywhere.

The system needs a POS Adapter Layer.

Each POS may speak a different language, but the internal system must operate with one canonical order model.

The goal is:

do not force stores to replace POS first
connect to what they already use
normalize order and payment events
protect authority boundaries
release kitchen only through verified state
preserve audit and reconciliation

This is the foundation for expanding the system from one store environment into a practical SaaS platform for restaurants and small business stores.
