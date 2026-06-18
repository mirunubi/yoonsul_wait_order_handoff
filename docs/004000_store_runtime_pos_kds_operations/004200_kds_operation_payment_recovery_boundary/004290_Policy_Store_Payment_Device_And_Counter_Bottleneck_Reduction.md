# 004290_Policy_Store_Payment_Device_And_Counter_Bottleneck_Reduction

## **1\. Purpose**

This document defines the store payment device and counter bottleneck reduction policy.

The purpose of this policy is to ensure that dynamic QR payment, customer display, POS payment webhook, and KDS release are deployed in a way that actually reduces store workload.

The system must not ask store owners to change devices merely because the technology is convenient.

The system must reduce counter congestion, staff payment handling, order confirmation delay, manual transfer checking, and kitchen release friction.

---

## **2\. Scope**

This policy applies to:

* Counter payment display
* Customer-facing QR display
* Table payment display
* POS-connected sub monitor
* Tablet-based customer payment screen
* Mobile web payment flow
* Staff payment status screen
* KDS release visibility
* Store device placement
* Counter queue reduction
* Payment confirmation workload reduction
* Peak-time order and payment bottleneck handling

This policy does not define payment provider contracts, refund authority, settlement allocation, accounting closing, or customer compensation policy.

---

## **3\. Core Principle**

Store payment devices must reduce friction.

A device is justified only when it reduces at least one of the following:

counter waiting time
staff payment handling time
manual bank confirmation
customer payment confusion
order-to-kitchen delay
duplicate payment risk
amount entry error
queue congestion
peak-time staff interruption

A device that adds work to staff is not an improvement.

A payment display that requires staff explanation every time is not operationally ready.

---

## **4\. Store Owner Adoption Principle**

Store owners do not adopt systems because they are new.

Store owners adopt systems when they see:

less counter congestion
less staff work
fewer payment mistakes
faster table turnover
lower payment confirmation burden
better peak-time control
lower possible payment processing cost
clearer order-to-kitchen flow

The system must be presented as an operational bottleneck reducer, not as a technology replacement.

---

## **5\. Device Role Model**

Store payment devices may be divided into the following roles:

COUNTER\_CUSTOMER\_DISPLAY
COUNTER\_STAFF\_DISPLAY
TABLE\_CUSTOMER\_DISPLAY
TABLE\_ORDER\_TABLET
MOBILE\_WEB\_CUSTOMER\_SCREEN
KDS\_SCREEN
MANAGER\_CONFIRMATION\_DEVICE
PAYMENT\_STATUS\_DASHBOARD

Each device must have a clear role.

A single device may serve multiple roles only when that does not confuse staff or customers.

---

## **6\. Counter Customer Display**

Counter Customer Display is placed where the customer can see payment amount and QR without staff handing over a device.

It should show:

order summary
final amount
dynamic QR
payment progress
payment complete
payment failed or retry message

It should not show:

raw POS controls
staff admin menu
provider debug status
full customer information
other customer orders
internal audit event IDs

The goal is to let the customer pay without staff touching card, phone, or payment terminal unless needed.

---

## **7\. Counter Staff Display**

Counter Staff Display shows staff what action is required.

It should show:

payment pending
payment complete
payment failed
amount mismatch
manual confirmation required
KDS release blocked
KDS released

The staff display must be action-oriented.

It should not require staff to inspect raw payment provider logs during peak time.

---

## **8\. Table Customer Display**

Table Customer Display may be a tablet, QR web page, or customer mobile screen.

It should support:

menu selection
order review
final amount
dynamic QR or payment button
payment status
kitchen received status
staff help request

For table use, the system should reduce staff movement.

The customer should not need to call staff merely to confirm payment.

---

## **9\. Mobile Web Payment Screen**

Mobile web may be used when no physical table device exists.

The customer may scan a table QR and complete order/payment through their own phone.

The screen should support:

session restore
order review
payment request
payment return
payment checking
payment complete
retry payment
call staff

Mobile web status must be restored from server state, not browser memory alone.

---

## **10\. KDS Payment Visibility**

KDS should receive only kitchen-actionable payment states.

Allowed KDS-facing payment states include:

WAITING\_PAYMENT
PAYMENT\_HOLD
RELEASED
PAYMENT\_UNCERTAIN
MANUAL\_RELEASE\_APPROVED
CANCELLED

KDS should not decide whether payment is valid.

KDS receives release or hold state from POS/Payment Runtime.

---

## **11\. Device Placement Rule**

Device placement must follow operational flow.

Counter QR display should be:

visible from customer payment position
close enough to scan without staff assistance
not blocking order-taking staff
not requiring customer to touch staff device
not showing private store controls

Table display should be:

stable
visible
easy to scan
protected from spill and heat
not easily confused with staff operation device

KDS display should be:

visible to kitchen station
not dependent on customer-facing screen
not overloaded with payment internals

---

## **12\. Minimum Hardware Strategy**

The system should support a low-hardware path.

Minimum deployment may use:

existing POS
one customer-facing tablet or small display
customer mobile web QR
existing KDS tablet or kitchen screen
server-side payment webhook

The system should not require immediate replacement of POS hardware.

The adoption message should be:

Add a payment display and automate confirmation before replacing the entire POS environment.

---

## **13\. Progressive Deployment Model**

Stores may adopt the system in stages.

### **Stage 1: Counter QR Display**

POS order input
customer-facing dynamic QR
payment webhook verification
staff sees payment complete
KDS release

### **Stage 2: Table QR Payment**

customer scans table QR
customer orders through mobile web
dynamic payment request
payment verification
KDS release

### **Stage 3: Table Tablet Order And Payment**

customer orders on table tablet
payment QR or widget appears
payment verified
kitchen released
staff intervention minimized

### **Stage 4: Full POS-KDS-Payment Synchronization**

POS
Payment Runtime
Customer Display
KDS
Audit
Reconciliation

The store should be able to start from Stage 1 without buying a full table-ordering system.

---

## **14\. Counter Bottleneck Definition**

Counter bottleneck occurs when staff must repeatedly perform:

receive order
enter order
tell amount
receive card or cash
process payment
wait for approval
confirm transfer
tell kitchen to start
explain delay
print or hand receipt

The system should reduce this to:

enter or confirm order
show customer QR or payment screen
system verifies payment
kitchen receives release
staff handles exceptions only

---

## **15\. Staff Interruption Reduction Rule**

The system should reduce staff interruptions caused by:

customer asks where to pay
customer says payment was sent
staff checks bank app
staff checks phone notification
staff calls kitchen to start
staff explains failed payment
staff compares paid amount
staff resolves duplicate payment manually

If staff must still perform these steps frequently, the deployment is not successful.

---

## **16\. Peak-Time Operation Rule**

During peak time, the payment device flow must prioritize speed.

Peak-time screen behavior should:

show large amount
show large QR
minimize steps
auto-refresh payment status
play clear payment complete sound
show actionable failure status
avoid long explanations

Peak-time staff view should prioritize:

who is paid
who is waiting
who needs manual confirmation
which ticket is blocked
which ticket is released

---

## **17\. Customer Self-Service Boundary**

Customer self-service is allowed for order review and payment.

Customer self-service must not allow:

price editing
manual discount creation
payment status override
KDS release override
refund request approval
staff-only menu access
other table visibility

Customer device is a controlled interface, not a store admin device.

---

## **18\. Store Staff Override Boundary**

Staff may help the customer when payment flow fails.

Staff may:

reissue payment request
cancel stale QR
select alternative payment method
request manager confirmation
mark manual confirmation required
start evidence packet

Staff must not:

mark payment complete without authority
hide amount mismatch
delete failed payment attempt
release KDS without approved fallback
reuse expired QR silently

---

## **19\. Manager Confirmation Device**

Manager confirmation may be required for:

manual payment confirmation
manual kitchen release under payment uncertainty
amount mismatch handling
duplicate payment suspected
customer claims paid but webhook missing
provider outage fallback

Manager confirmation should be quick but auditable.

Manager confirmation does not erase payment uncertainty.

---

## **20\. Sound And Visual Alert Rule**

The system should use clear but non-disruptive alerts.

Payment complete may trigger:

short sound
green-like completion visual
KDS release indicator
staff notification

Payment problem may trigger:

different alert sound
hold indicator
manual confirmation required message

Alerts should not overload kitchen staff.

Kitchen should hear only action-relevant alerts.

---

## **21\. Device Failure Rule**

If a customer-facing payment display fails, the store may switch to:

customer mobile QR
staff reissued payment link
backup tablet
printed temporary QR
manual fallback

Device failure must not become silent payment confirmation.

If manual fallback is used, it must be marked:

DEVICE\_FAILURE\_FALLBACK
FALLBACK\_ORIGINATED
MANUAL\_CONFIRMATION\_REQUIRED

---

## **22\. Security And Privacy Rule**

Customer-facing devices must not expose:

admin login
payment provider secret
merchant credentials
raw webhook logs
other customer orders
full phone numbers
settlement dashboard
refund approval controls
staff personal data

Customer display should operate in locked or kiosk mode when possible.

---

## **23\. Offline And Degraded Operation**

If internet or provider connection fails, the system may move into degraded operation.

Allowed degraded states include:

PAYMENT\_PROVIDER\_UNAVAILABLE
DISPLAY\_OFFLINE
KDS\_RELEASE\_BLOCKED
MANUAL\_CONFIRMATION\_REQUIRED
POSTPAID\_POLICY\_REQUIRED

The store may continue service only under predefined fallback policy.

The system must not pretend that automated payment verification is active when it is not.

---

## **24\. Adoption Metrics**

The system should measure whether the device deployment improves store operation.

Suggested metrics include:

average counter payment time
payment confirmation delay
number of manual payment checks
number of payment-related staff interruptions
KDS release delay after payment
payment failure retry rate
amount mismatch count
manual confirmation count
peak-time queue length
customer payment completion rate

These metrics should be used to prove value to store owners.

---

## **25\. MVP Cutline**

For MVP, the device strategy should support:

counter customer QR display
staff payment status view
payment complete alert
payment failed alert
KDS release indicator
QR expiration display
manual confirmation required display
basic device fallback path

Excluded from MVP:

full table tablet ordering
dedicated proprietary hardware
multi-screen advanced orchestration
AI-driven queue prediction
automatic staff scheduling based on payment flow
cross-store device health analytics
full offline payment guarantee

---

## **26\. Relationship To 04260, 04270, And 04280**

Document 04260 defines payment webhook and KDS release boundary.

Document 04270 defines payment failure, timeout, duplicate, and manual confirmation policy.

Document 04280 defines customer-facing QR and payment status UX.

This document defines how the required screens and devices should be deployed in the store to reduce real operational bottlenecks.

The relationship is:

04260 \= payment verification and KDS release
04270 \= payment uncertainty and failure handling
04280 \= customer-facing display UX
04290 \= store device placement and counter bottleneck reduction

---

## **27\. Readiness Check**

This policy is ready when:

customer can see payment amount without staff handoff
QR can be scanned without staff explanation
staff can see payment complete or problem status quickly
KDS release is not dependent on staff verbal confirmation
device placement reduces counter congestion
manual confirmation is exception-only
device failure has fallback states
customer device does not expose admin functions
store owner can understand the labor and bottleneck benefit
metrics can prove reduced payment handling burden

---

## **28\. Summary**

Store payment devices are not valuable because they are digital.

They are valuable only when they reduce counter bottlenecks, staff interruptions, payment confirmation burden, and kitchen release delay.

The store should be able to begin with a small customer-facing display and existing POS/KDS infrastructure.

The goal is not hardware replacement.

The goal is operational flow:

customer sees amount
customer pays
system verifies
staff is notified
KDS is released
kitchen starts
audit remains

When this flow works, the payment device becomes a labor-saving operational node, not another machine the store must manage.
