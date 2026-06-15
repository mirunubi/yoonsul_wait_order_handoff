# 04420_Policy_POS_Adapter_Runtime_Data_Object_And_Event_Family

## **1\. Purpose**

This document defines the POS Adapter Runtime data object and event family policy.

The purpose of this policy is to identify the conceptual runtime objects and event families required to support POS provider abstraction, payment provider integration, canonical order normalization, KDS release, customer display synchronization, replay, reconciliation, audit, and support escalation.

This document is not a final database schema.

It defines the object families and event families that implementation planning must respect.

---

## **2\. Scope**

This policy applies to:

* POS adapter runtime objects
* Payment provider runtime objects
* Canonical order runtime objects
* Provider event storage
* Raw payload references
* Payment request and payment event objects
* KDS release objects
* Customer display projection objects
* Diagnostic error objects
* Replay objects
* Reconciliation objects
* Support escalation objects
* Audit event linkage

This policy does not define final SQL migrations, final table names, final column types, final API endpoints, provider-specific code, or UI implementation.

---

## **3\. Core Principle**

Runtime objects must preserve source, authority, and replayability.

The system must not collapse external provider data, internal normalized state, payment truth, KDS execution, customer display, and support notes into one mutable order record.

The core principle is:

raw provider event
        ↓
normalized internal event
        ↓
canonical order projection
        ↓
payment / KDS / display / audit / reconciliation projections

Source events must remain separate from projections.

Projection may change.

Source truth must not be silently rewritten.

---

## **4\. Object Family Overview**

The POS Adapter Runtime should include the following conceptual object families:

provider family
adapter family
raw provider event family
canonical order family
order item mapping family
payment family
KDS release family
customer display family
diagnostic error family
replay family
reconciliation family
support family
audit family

Each family has a distinct responsibility.

No object family should silently take over another family’s authority.

---

## **5\. Provider Family**

Provider family objects represent external systems.

Conceptual objects include:

provider
provider\_capability
provider\_contract
provider\_credential
provider\_health
provider\_onboarding\_evidence
provider\_known\_limitation

Provider types may include:

POS
PAYMENT\_PROVIDER
TABLE\_ORDER
KIOSK
DELIVERY\_APP
ORDER\_AGGREGATOR
OPEN\_BANKING
FINTECH
LEGACY\_IMPORT
EXTERNAL\_PARTNER

Provider objects describe who the external party is and what they are allowed to do.

They do not store internal order truth.

---

## **6\. Adapter Family**

Adapter family objects represent the internal integration layer that connects provider data to the canonical model.

Conceptual objects include:

adapter
adapter\_version
adapter\_capability\_level
adapter\_mapping\_version
adapter\_runtime\_status
adapter\_certification\_result
adapter\_configuration

Adapter objects must track:

provider\_id
tenant\_id
store\_id
adapter\_name
adapter\_version
capability\_level
enabled\_status
created\_at
updated\_at

Adapter version must be recorded on every normalized event.

---

## **7\. Store Provider Integration Object**

Each store-provider connection must be represented separately.

Conceptual object:

store\_provider\_integration

Required conceptual fields:

tenant\_id
store\_id
provider\_id
adapter\_id
adapter\_version
external\_store\_id
external\_merchant\_id
external\_terminal\_id
capability\_level
enabled\_capabilities
credential\_reference
menu\_mapping\_version
table\_mapping\_version
payment\_mapping\_version
integration\_status
fallback\_mode
enabled\_at
disabled\_at

Provider capability may differ by store.

A provider may be Level 3 for one store and Level 1 for another.

---

## **8\. Raw Provider Event Family**

Raw provider event objects preserve original external input.

Conceptual objects include:

raw\_provider\_event
raw\_provider\_payload
provider\_webhook\_event
provider\_polling\_result
provider\_file\_import\_event

Required conceptual fields:

raw\_event\_id
provider\_id
adapter\_id
tenant\_id
store\_id
external\_event\_id
external\_order\_id
external\_payment\_id
provider\_event\_type
provider\_event\_time
received\_at
payload\_hash
raw\_payload\_reference
verification\_status
processing\_status

Raw provider events must not be edited to fit internal state.

---

## **9\. Provider Event Verification Object**

Provider event verification must be tracked separately.

Conceptual object:

provider\_event\_verification

Required conceptual fields:

raw\_event\_id
provider\_id
verification\_method
verification\_status
signature\_status
secret\_status
duplicate\_check\_status
timestamp\_check\_status
amount\_check\_status
verified\_at
verification\_error\_code

Webhook received is not webhook verified.

Provider event verification must be complete before authority-sensitive state changes.

---

## **10\. Canonical Order Family**

Canonical order objects represent the internal normalized order.

Conceptual objects include:

canonical\_order
canonical\_order\_event
canonical\_order\_projection
canonical\_order\_state\_snapshot

Minimum conceptual fields:

internal\_order\_id
tenant\_id
store\_id
order\_source
order\_channel
external\_provider\_name
external\_store\_id
external\_order\_id
customer\_session\_id
seating\_session\_id
table\_reference
order\_status
payment\_status
fulfillment\_status
kitchen\_release\_status
subtotal\_amount
discount\_amount
tax\_amount
service\_charge\_amount
total\_amount
currency
source\_confidence
normalization\_status
adapter\_version
raw\_payload\_reference
created\_at
updated\_at

Canonical order is internal operational language.

It is not the raw POS payload.

---

## **11\. Canonical Order Event Family**

Canonical order events describe state changes.

Conceptual event types include:

ORDER\_CREATED
ORDER\_ACCEPTED
ORDER\_UPDATED
ORDER\_CANCELED
ITEM\_ADDED
ITEM\_VOIDED
DISCOUNT\_APPLIED
PAYMENT\_PENDING
PAYMENT\_DONE
PAYMENT\_FAILED
KITCHEN\_RELEASE\_REQUESTED
KITCHEN\_RELEASED
KITCHEN\_HELD
ORDER\_READY
ORDER\_COMPLETED
RECONCILIATION\_REQUIRED

Each canonical order event should link to:

internal\_order\_id
raw\_event\_id
provider\_id
adapter\_version
source\_confidence
audit\_event\_reference

---

## **12\. Order Item Family**

Order item objects represent normalized items, modifiers, options, bundles, and discounts.

Conceptual objects include:

canonical\_order\_item
canonical\_order\_modifier
canonical\_order\_bundle
canonical\_order\_discount
canonical\_order\_tax
canonical\_order\_service\_charge

Required item fields include:

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
mapping\_status
source\_confidence
raw\_item\_reference

Unknown or unmapped items must remain visible.

They must not be silently dropped.

---

## **13\. Mapping Family**

Mapping objects connect external provider data to internal operational definitions.

Conceptual objects include:

item\_mapping
modifier\_mapping
bundle\_mapping
discount\_mapping
tax\_mapping
table\_mapping
payment\_status\_mapping
order\_status\_mapping

Mapping objects should track:

provider\_id
store\_id
external\_value
internal\_value
mapping\_status
mapping\_version
created\_at
updated\_at
review\_required

Mapping gaps must create diagnostic errors or review states.

---

## **14\. Payment Family**

Payment family objects represent internal payment requests, provider payment events, and payment verification results.

Conceptual objects include:

payment\_provider
payment\_request
payment\_event
payment\_verification\_result
payment\_status\_projection
payment\_error
payment\_reconciliation\_case

Payment request fields should include:

payment\_request\_id
internal\_order\_id
tenant\_id
store\_id
provider\_id
locked\_amount
currency
payment\_request\_status
provider\_payment\_reference
created\_at
expires\_at

Payment event fields should include:

payment\_event\_id
payment\_request\_id
provider\_id
provider\_event\_id
provider\_payment\_reference
payment\_status
amount
currency
received\_at
verified\_at
verification\_status
idempotency\_status
raw\_payload\_reference

---

## **15\. Payment Authority Rule**

Payment family owns payment verification state.

KDS, customer display, adapter, and support objects must not directly mark payment truth.

Payment authority transitions must be represented as events such as:

PAYMENT\_PROVIDER\_EVENT\_RECEIVED
PAYMENT\_PROVIDER\_EVENT\_VERIFIED
PAYMENT\_DONE
PAYMENT\_FAILED
PAYMENT\_EXPIRED
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_DUPLICATE\_EVENT\_IGNORED
MANUAL\_PAYMENT\_CONFIRMATION\_USED
RECONCILIATION\_REQUIRED

Payment visibility is not payment authority.

---

## **16\. KDS Release Family**

KDS release family objects represent kitchen eligibility and kitchen release events.

Conceptual objects include:

kds\_release\_request
kds\_release\_event
kds\_ticket\_projection
kds\_hold\_record
manual\_kitchen\_recovery\_reference

KDS release object fields should include:

kds\_release\_id
internal\_order\_id
payment\_request\_id
store\_id
kds\_release\_status
release\_eligibility\_reason
blocked\_reason
created\_at
released\_at
source\_runtime
audit\_event\_reference

KDS release must not happen directly from external provider event without internal authority verification.

---

## **17\. Customer Display Family**

Customer display objects represent customer-facing state.

Conceptual objects include:

customer\_display\_session
customer\_payment\_display\_state
customer\_order\_status\_projection
customer\_display\_event

Customer display states may include:

ORDER\_CONFIRMING
ORDER\_CONFIRMED
PAYMENT\_REQUIRED
QR\_READY
PAYMENT\_PROCESSING
PAYMENT\_CHECKING
PAYMENT\_COMPLETE
KITCHEN\_RECEIVED
PAYMENT\_FAILED
PAYMENT\_EXPIRED
STAFF\_ASSISTANCE\_REQUIRED

Customer display must consume verified internal projection.

It must not own order, payment, or KDS authority.

---

## **18\. Diagnostic Error Family**

Diagnostic error objects represent structured failures.

Conceptual objects include:

diagnostic\_error
diagnostic\_error\_event
diagnostic\_error\_aggregation
diagnostic\_error\_lifecycle

Required fields include:

error\_code
severity
audience
tenant\_id
store\_id
provider\_id
adapter\_id
adapter\_version
external\_order\_id
external\_event\_id
internal\_order\_id
authority\_impact
customer\_impact
kitchen\_impact
payment\_impact
detected\_at
recommended\_action
lifecycle\_state
audit\_event\_reference

Diagnostic errors must be stable, searchable, and auditable.

---

## **19\. Replay Family**

Replay family objects represent controlled reconstruction.

Conceptual objects include:

replay\_request
replay\_scope
replay\_result
replay\_projection\_diff

Replay request fields should include:

replay\_request\_id
scope\_type
scope\_reference
provider\_id
adapter\_version
requested\_by
requested\_at
reason
status

Replay result states may include:

REPLAY\_COMPLETED
REPLAY\_COMPLETED\_WITH\_WARNING
REPLAY\_PRODUCED\_CONFLICT
REPLAY\_BLOCKED
REPLAY\_REQUIRES\_RECONCILIATION
REPLAY\_PROJECTION\_UPDATED
REPLAY\_NO\_CHANGE

Replay must not mutate source events.

---

## **20\. Reconciliation Family**

Reconciliation family objects represent accepted operational conclusions after uncertainty.

Conceptual objects include:

reconciliation\_case
reconciliation\_evidence
reconciliation\_conclusion
reconciliation\_exception

Reconciliation case fields should include:

reconciliation\_case\_id
case\_type
internal\_order\_id
payment\_request\_id
kds\_release\_id
provider\_id
store\_id
trigger\_error\_code
uncertainty\_reason
evidence\_references
status
created\_at
resolved\_at
conclusion

Reconciliation may accept a conclusion.

It must not rewrite raw source events.

---

## **21\. Support Family**

Support family objects represent escalation and communication.

Conceptual objects include:

support\_ticket
support\_ticket\_event
vendor\_escalation
developer\_escalation
store\_escalation
support\_evidence

Support ticket fields should include:

ticket\_id
incident\_id
store\_id
tenant\_id
provider\_id
adapter\_version
error\_codes
affected\_order\_ids
severity
owner
status
evidence\_references
reconciliation\_required
created\_at
closed\_at
closure\_type

Support closure is not the same as reconciliation closure.

---

## **22\. Incident Family**

Incident family objects represent aggregated operational issues.

Conceptual objects include:

integration\_incident
incident\_event
incident\_runbook\_step
incident\_affected\_order
incident\_postmortem

Incident fields should include:

incident\_id
incident\_type
provider\_id
adapter\_id
store\_id
tenant\_id
severity
health\_state
affected\_order\_count
affected\_store\_count
trigger\_error\_codes
state
created\_at
resolved\_at
postmortem\_required

Incidents may aggregate many errors.

They must preserve individual affected order links.

---

## **23\. Audit Family**

Audit family objects preserve append-only operational memory.

Conceptual object:

audit\_event

Audit event fields should include:

audit\_event\_id
tenant\_id
store\_id
actor\_type
actor\_id
runtime\_family
event\_type
target\_type
target\_id
before\_state\_reference
after\_state\_reference
source\_reference
created\_at

Every authority-sensitive state change must create audit.

Audit must be append-only.

---

## **24\. Event Family Overview**

The runtime should support event families such as:

PROVIDER\_EVENT
ADAPTER\_EVENT
NORMALIZATION\_EVENT
ORDER\_EVENT
PAYMENT\_EVENT
KDS\_EVENT
CUSTOMER\_DISPLAY\_EVENT
DIAGNOSTIC\_EVENT
FALLBACK\_EVENT
REPLAY\_EVENT
RECONCILIATION\_EVENT
SUPPORT\_EVENT
AUDIT\_EVENT

Each event family should be separate enough to preserve runtime responsibility.

---

## **25\. Provider Event Family**

Provider event types may include:

PROVIDER\_WEBHOOK\_RECEIVED
PROVIDER\_WEBHOOK\_VERIFIED
PROVIDER\_WEBHOOK\_REJECTED
PROVIDER\_POLLING\_RESULT\_RECEIVED
PROVIDER\_EVENT\_DUPLICATE\_IGNORED
PROVIDER\_EVENT\_DELAYED
PROVIDER\_UNAVAILABLE
PROVIDER\_CREDENTIAL\_FAILED

Provider event does not automatically become internal order or payment truth.

---

## **26\. Adapter Event Family**

Adapter event types may include:

ADAPTER\_ENABLED
ADAPTER\_DISABLED
ADAPTER\_CAPABILITY\_ASSIGNED
ADAPTER\_CAPABILITY\_DOWNGRADED
ADAPTER\_MAPPING\_VERSION\_CHANGED
ADAPTER\_CERTIFICATION\_PASSED
ADAPTER\_CERTIFICATION\_FAILED
ADAPTER\_RUNTIME\_ERROR

Adapter events describe integration layer behavior.

They do not directly approve payment or kitchen execution.

---

## **27\. Normalization Event Family**

Normalization event types may include:

NORMALIZATION\_STARTED
NORMALIZATION\_COMPLETED
NORMALIZATION\_COMPLETED\_WITH\_WARNING
NORMALIZATION\_FAILED
MAPPING\_REQUIRED
SOURCE\_CONFIDENCE\_ASSIGNED
CANONICAL\_ORDER\_CREATED
CANONICAL\_ORDER\_UPDATED

Normalization creates internal representation.

It does not erase raw provider event.

---

## **28\. Payment Event Family**

Payment event types may include:

PAYMENT\_REQUEST\_CREATED
PAYMENT\_QR\_DISPLAYED
PAYMENT\_ATTEMPT\_STARTED
PAYMENT\_PROVIDER\_EVENT\_RECEIVED
PAYMENT\_PROVIDER\_EVENT\_VERIFIED
PAYMENT\_DONE
PAYMENT\_FAILED
PAYMENT\_EXPIRED
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_DUPLICATE\_SUSPECTED
MANUAL\_PAYMENT\_CONFIRMATION\_REQUIRED
MANUAL\_PAYMENT\_CONFIRMATION\_USED

Payment events must link to payment request and internal order.

---

## **29\. KDS Event Family**

KDS event types may include:

KDS\_RELEASE\_ELIGIBILITY\_CREATED
KDS\_RELEASE\_BLOCKED
KDS\_RELEASE\_REQUESTED
KDS\_RELEASED
KDS\_HELD
KDS\_CANCEL\_REQUESTED
KDS\_CANCEL\_CONFIRMED
KDS\_PROJECTION\_REPLAYED
MANUAL\_KITCHEN\_RECOVERY\_REQUIRED

KDS event must not decide payment truth.

---

## **30\. Customer Display Event Family**

Customer display event types may include:

CUSTOMER\_PAYMENT\_SCREEN\_SHOWN
CUSTOMER\_QR\_DISPLAYED
CUSTOMER\_PAYMENT\_CHECKING\_SHOWN
CUSTOMER\_PAYMENT\_COMPLETE\_SHOWN
CUSTOMER\_PAYMENT\_FAILED\_SHOWN
CUSTOMER\_KITCHEN\_RECEIVED\_SHOWN
CUSTOMER\_STAFF\_HELP\_REQUESTED

Customer display events show what was presented to the customer.

They do not prove payment truth.

---

## **31\. Diagnostic Event Family**

Diagnostic event types may include:

DIAGNOSTIC\_ERROR\_DETECTED
DIAGNOSTIC\_ERROR\_AGGREGATED
DIAGNOSTIC\_ERROR\_DEDUPED
DIAGNOSTIC\_ACTION\_RECOMMENDED
DIAGNOSTIC\_ESCALATION\_REQUIRED
DIAGNOSTIC\_LIFECYCLE\_UPDATED

Diagnostic events should reuse 04330 error code policy.

---

## **32\. Fallback Event Family**

Fallback event types may include:

FALLBACK\_MODE\_ACTIVATED
MANUAL\_ORDER\_ENTRY\_USED
MANUAL\_PAYMENT\_CONFIRMATION\_USED
MANUAL\_KITCHEN\_RECOVERY\_USED
FALLBACK\_EVIDENCE\_ATTACHED
FALLBACK\_RECONCILIATION\_REQUIRED
FALLBACK\_MODE\_ENDED

Fallback-originated state must remain visible.

---

## **33\. Replay Event Family**

Replay event types may include:

REPLAY\_REQUESTED
REPLAY\_STARTED
REPLAY\_BLOCKED
REPLAY\_COMPLETED
REPLAY\_COMPLETED\_WITH\_WARNING
REPLAY\_PRODUCED\_CONFLICT
REPLAY\_REQUIRES\_RECONCILIATION

Replay events must preserve replay scope and result.

---

## **34\. Reconciliation Event Family**

Reconciliation event types may include:

RECONCILIATION\_CASE\_CREATED
RECONCILIATION\_EVIDENCE\_ATTACHED
RECONCILIATION\_STARTED
RECONCILIATION\_CONCLUSION\_RECORDED
RECONCILIATION\_CLOSED
RECONCILIATION\_CLOSED\_WITH\_EXCEPTION
HQ\_REVIEW\_REQUIRED

Reconciliation conclusion must be append-only.

---

## **35\. Support Event Family**

Support event types may include:

SUPPORT\_TICKET\_CREATED
SUPPORT\_TICKET\_CLASSIFIED
SUPPORT\_OWNER\_ASSIGNED
STORE\_ESCALATION\_RECEIVED
HQ\_TRIAGE\_COMPLETED
DEVELOPER\_ESCALATION\_SENT
VENDOR\_ESCALATION\_SENT
VENDOR\_RESPONSE\_RECEIVED
SUPPORT\_TICKET\_CLOSED
SUPPORT\_TICKET\_CLOSED\_WITH\_EXCEPTION

Support events must not mutate operational truth.

---

## **36\. State Separation Rule**

The system must preserve separation among:

order\_status
payment\_status
fulfillment\_status
kitchen\_release\_status
display\_status
adapter\_status
provider\_health\_status
diagnostic\_lifecycle\_status
incident\_status
reconciliation\_status
support\_ticket\_status

These states must not be collapsed into one generic order state.

A support ticket being closed does not mean reconciliation is closed.

A customer display showing payment complete does not prove payment authority unless Payment Runtime already verified it.

---

## **37\. Source Reference Rule**

Each derived object should reference its source.

Examples:

canonical\_order \-\> raw\_provider\_event
payment\_event \-\> provider\_webhook\_event
kds\_release\_event \-\> payment\_verification\_result
customer\_display\_event \-\> customer\_display\_projection
diagnostic\_error \-\> affected event or object
reconciliation\_case \-\> evidence references
support\_ticket \-\> incident and error references
audit\_event \-\> target object

No important runtime object should be orphaned from its source.

---

## **38\. Idempotency Rule**

Idempotency must be represented at the event processing level.

Idempotency keys may include:

provider\_id
external\_event\_id
external\_order\_id
provider\_payment\_reference
event\_type
payload\_hash
adapter\_version

Duplicate events must be marked, not reprocessed into duplicate orders, payments, or KDS releases.

---

## **39\. Authority-Sensitive Event Rule**

Authority-sensitive events require audit and verification.

Authority-sensitive events include:

PAYMENT\_DONE
PAYMENT\_AMOUNT\_MISMATCH
KDS\_RELEASED
MANUAL\_PAYMENT\_CONFIRMATION\_USED
MANUAL\_KITCHEN\_RECOVERY\_USED
REFUND\_REVIEW\_REQUIRED
SETTLEMENT\_REVIEW\_REQUIRED
RECONCILIATION\_CONCLUSION\_RECORDED
CAPABILITY\_DOWNGRADED

These events must not occur silently.

---

## **40\. MVP Cutline**

For MVP, the system should prepare conceptual support for:

provider
store\_provider\_integration
adapter
adapter\_version
raw\_provider\_event
canonical\_order
canonical\_order\_event
canonical\_order\_item
payment\_request
payment\_event
payment\_verification\_result
kds\_release\_request
customer\_display\_state
diagnostic\_error
reconciliation\_case
support\_ticket
audit\_event

MVP event families should include:

PROVIDER\_EVENT
NORMALIZATION\_EVENT
ORDER\_EVENT
PAYMENT\_EVENT
KDS\_EVENT
CUSTOMER\_DISPLAY\_EVENT
DIAGNOSTIC\_EVENT
FALLBACK\_EVENT
AUDIT\_EVENT

Excluded from MVP:

full vendor portal objects
advanced certification object graph
multi-provider settlement objects
full refund execution objects
AI diagnostic objects
automatic adapter generation objects
enterprise SLA objects

---

## **41\. Relationship To Previous Documents**

This document supports:

04260 POS Payment Webhook And Kitchen Release Boundary Policy
04270 Payment Failure Timeout Duplicate And Manual Confirmation Policy
04280 Customer Display Dynamic QR And Payment Status UX Policy
04290 Store Payment Device And Counter Bottleneck Reduction Policy
04300 POS Provider Abstraction And Multi-POS Adapter Policy
04310 Canonical Order Model And POS Event Normalization Policy
04320 POS Adapter Capability Level And Integration Contract Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04390 POS Integration Governance Index And Readiness Check
04400 Toss Payments MVP Integration Boundary Policy
04410 PAYCO Payment And Order Provider MVP Boundary Policy

The relationship is:

04300\~04390 \= governance and integration boundary
04400\~04410 \= provider MVP boundary
04420 \= shared runtime object and event family foundation

---

## **42\. Patent And SaaS Relevance**

This document supports the broader BM and SaaS architecture because it shows how multiple external providers can be absorbed into common runtime objects and event families.

The structural value is:

external provider events
        ↓
raw event preservation
        ↓
canonical normalization
        ↓
runtime-specific projections
        ↓
diagnostic errors
        ↓
replay and reconciliation
        ↓
audit and support

This is the internal skeleton that allows the platform to scale beyond one POS, one PG, or one store environment.

---

## **43\. Readiness Check**

This policy is ready when:

provider objects are separated from adapter objects
raw provider events are separated from canonical orders
payment objects are separated from KDS release objects
customer display objects are visibility-only
diagnostic errors are first-class objects
replay and reconciliation are separated
support tickets do not equal operational truth
audit events are append-only
event families are defined
authority-sensitive events are identified
MVP object cutline is explicit

---

## **44\. Summary**

A multi-POS platform cannot be built around one mutable order table.

It needs object families and event families.

The system must preserve:

what the provider sent
what the adapter understood
what the internal order became
what payment verified
what KDS released
what the customer saw
what failed
what was replayed
what was reconciled
what support closed
what audit remembers

This separation is what allows the platform to be diagnosable, replayable, auditable, and scalable across many POS and payment environments.
