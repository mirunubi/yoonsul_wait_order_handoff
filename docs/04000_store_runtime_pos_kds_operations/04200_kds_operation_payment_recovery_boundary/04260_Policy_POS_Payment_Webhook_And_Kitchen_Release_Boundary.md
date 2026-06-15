# 04260_Policy_POS_Payment_Webhook_And_Kitchen_Release_Boundary

## **1\. Purpose**

This document defines the boundary policy for payment webhook verification and kitchen release.

The purpose of this policy is to connect POS, customer payment, customer-facing display, and KDS kitchen execution without allowing payment uncertainty to create kitchen errors, manual confirmation burden, or silent state mutation.

This policy supports dynamic QR payment, payment link, payment widget, account-transfer-style payment flows, and future fintech or banking API integration.

The core objective is to remove counter bottlenecks by allowing the system to verify payment automatically and release the kitchen ticket only after payment authority confirms the payment event.

---

## **2\. Scope**

This policy applies to:

* POS-created customer orders
* Table order-created customer orders
* Counter display dynamic QR payment
* Table display dynamic QR payment
* Payment link or payment widget flow
* Toss Payments or equivalent PG webhook
* Virtual account deposit callback
* Future open banking or fintech account transfer callback
* Payment-confirmed KDS release
* Customer display payment status update
* Payment failure, timeout, mismatch, duplicate, or uncertain state

This policy does not define refund approval, settlement allocation, customer compensation, tax reporting, accounting closing, or legal dispute resolution.

---

## **3\. Core Principle**

Payment visibility is not payment authority.

KDS must not decide payment truth.

Customer display must not decide payment truth.

Staff observation must not decide payment truth.

The payment runtime or POS payment authority must verify the payment event before the kitchen ticket is released.

A webhook received from a payment provider is not automatically trusted until the system verifies order reference, amount, merchant reference, status, signature or secret, and duplicate handling.

---

## **4\. Runtime Roles**

### **4.1 POS Runtime**

POS Runtime owns order acceptance and order amount confirmation.

POS Runtime may create:

order\_id
store\_id
table\_id
customer\_session\_id
order\_amount
payment\_request\_id
payment\_status \= PENDING

POS Runtime does not release the kitchen ticket until payment authority confirms the payment state, unless the store policy explicitly allows postpaid operation.

---

### **4.2 Payment Runtime**

Payment Runtime owns payment verification.

Payment Runtime receives and verifies:

payment\_webhook
payment\_key
payment\_request\_id
order\_id
amount
provider\_status
merchant\_reference
deposit\_callback
signature\_or\_secret

Payment Runtime may emit:

PAYMENT\_PENDING
PAYMENT\_AUTHORIZED
PAYMENT\_DONE
PAYMENT\_FAILED
PAYMENT\_CANCELED
PAYMENT\_EXPIRED
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_SOURCE\_UNCERTAIN
PAYMENT\_DUPLICATE\_SUSPECTED

Only verified payment events may trigger KDS release.

---

### **4.3 Customer Display Runtime**

Customer Display Runtime shows the customer-facing state.

It may display:

ORDER\_RECEIVED
PAYMENT\_REQUIRED
QR\_READY
PAYMENT\_PROCESSING
PAYMENT\_COMPLETE
PAYMENT\_FAILED
ASK\_STAFF

Customer Display Runtime must not directly change payment authority or KDS state.

---

### **4.4 KDS Runtime**

KDS Runtime owns kitchen execution.

KDS may receive:

KITCHEN\_TICKET\_READY
KITCHEN\_TICKET\_RELEASED
KITCHEN\_TICKET\_HOLD
KITCHEN\_TICKET\_CANCELLED
KITCHEN\_TICKET\_PAYMENT\_UNCERTAIN

KDS must not interpret QR scan, customer claim, staff memory, or unverified webhook as payment truth.

---

## **5\. Standard Flow**

The standard flow is:

1\. Order is created by POS or table order.
2\. Order amount is confirmed.
3\. Payment request is created.
4\. Dynamic QR, payment link, or payment widget is displayed to the customer.
5\. Customer completes payment.
6\. Payment provider sends webhook or callback.
7\. Payment Runtime verifies payment event.
8\. Payment Runtime emits verified payment event.
9\. POS Runtime updates payment status.
10\. KDS ticket is released.
11\. Customer display shows payment complete.
12\. Kitchen begins preparation.

The system must preserve the difference between:

QR\_DISPLAYED
CUSTOMER\_SCANNED
PAYMENT\_ATTEMPTED
WEBHOOK\_RECEIVED
PAYMENT\_VERIFIED
KDS\_RELEASED

These states must not be collapsed into a single “paid” state.

---

## **6\. Dynamic QR Rule**

A dynamic QR must be generated from a specific order or payment request.

The QR must include or reference:

store\_id
order\_id
payment\_request\_id
amount
merchant\_reference
expiration\_time
provider\_reference

The QR must not be a generic store bank account QR unless the store is operating in manual fallback mode.

Generic transfer QR creates manual confirmation burden and must not be treated as automated payment authority.

---

## **7\. Amount Lock Rule**

The amount shown to the customer must match the payment request amount.

Once the QR or payment request is issued, the amount must be locked unless the order is explicitly revised.

If the order changes after QR creation, the previous payment request must be:

EXPIRED
CANCELED
REPLACED

A new payment request must be issued.

If payment amount and order amount do not match, the state must become:

PAYMENT\_AMOUNT\_MISMATCH

and KDS release must be blocked or held for review.

---

## **8\. Webhook Verification Rule**

A webhook must be verified before changing payment state.

Verification must include:

provider identity
merchant identity
order\_id or payment\_request\_id
amount
status
timestamp
duplicate event check
signature, secret, or provider validation rule

A webhook event must be idempotent.

Receiving the same payment event multiple times must not create duplicate kitchen tickets, duplicate release events, or duplicate settlement records.

---

## **9\. KDS Release Rule**

KDS release is allowed only when Payment Runtime emits:

PAYMENT\_DONE

or another store-approved verified paid state.

When payment is verified, the system may emit:

KDS\_RELEASE\_REQUESTED
KDS\_RELEASED

If payment is not verified, the kitchen ticket may remain:

PAYMENT\_HOLD
WAITING\_PAYMENT
PAYMENT\_UNCERTAIN

If the store uses postpaid operation, the ticket must be marked:

POSTPAID\_ALLOWED

and must follow a separate postpaid settlement policy.

---

## **10\. Counter Bottleneck Removal**

The system is designed to remove the following manual steps:

staff receives card
staff processes payment
staff checks transfer manually
staff asks customer whether payment was sent
staff confirms bank notification
staff tells kitchen to start

The target automated path is:

order input
dynamic QR display
customer payment
webhook verification
KDS release
kitchen start

This reduces counter congestion during peak time and removes manual transfer confirmation from store staff.

---

## **11\. Toss Payments MVP Path**

For MVP, Toss Payments or equivalent PG integration may be used.

The MVP may support:

payment widget
payment window
payment link
virtual account deposit callback
webhook-based payment confirmation

The system should treat Toss or equivalent PG as a payment provider, not as the owner of store operation state.

Provider status must be mapped into internal payment states.

Example mapping:

provider DONE \-\> PAYMENT\_DONE
provider CANCELED \-\> PAYMENT\_CANCELED
provider FAILED \-\> PAYMENT\_FAILED
provider WAITING\_FOR\_DEPOSIT \-\> PAYMENT\_PENDING
virtual account deposit callback \-\> PAYMENT\_DONE after verification

The internal system must preserve its own state history even when the provider retries webhook delivery.

---

## **12\. Account Transfer And Open Banking Future Path**

A future account-transfer-style payment flow may be added.

This may include:

open banking API
bank deposit notification
fintech partner callback
virtual account per order
escrow-like deposit reference
store settlement account integration

This future path must not assume that ordinary manual bank transfer is automatically verifiable.

The system may support low-fee account-based payment only when the deposit event can be verified through a reliable API, callback, or partner integration.

If a customer sends money to a generic store account without system-verifiable reference, the payment must be treated as:

MANUAL\_PAYMENT\_CONFIRMATION\_REQUIRED

not as automatic payment completion.

---

## **13\. Fee And Settlement Communication Rule**

The system may describe account-based payment as a potential payment-cost reduction path.

The system must not promise:

guaranteed zero fee
guaranteed instant settlement
guaranteed card fee elimination

unless a specific provider contract supports that claim.

Safe business wording:

The system may support payment flows that reduce card-counter bottlenecks and may reduce payment processing cost depending on provider, banking, PG, or fintech contract conditions.

---

## **14\. Failure States**

The following failure states must be supported:

PAYMENT\_WEBHOOK\_DELAYED
PAYMENT\_WEBHOOK\_MISSING
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_DUPLICATE\_SUSPECTED
PAYMENT\_PROVIDER\_UNAVAILABLE
PAYMENT\_STATUS\_UNKNOWN
PAYMENT\_EXPIRED
CUSTOMER\_PAYMENT\_ABANDONED
KDS\_RELEASE\_BLOCKED
MANUAL\_CONFIRMATION\_REQUIRED

Failure must not automatically cancel the order unless store policy defines the cancellation timeout.

---

## **15\. Timeout Rule**

Each payment request must have an expiration policy.

Example timeout states:

PAYMENT\_PENDING
PAYMENT\_EXPIRED
ORDER\_PAYMENT\_TIMEOUT
CUSTOMER\_RETRY\_REQUIRED
STAFF\_CONFIRMATION\_REQUIRED

After expiration, the original QR or payment request must not be reused.

A new payment request must be created if the customer still wants to proceed.

---

## **16\. Duplicate Protection**

The system must prevent duplicate kitchen execution.

Duplicate protection must check:

same order\_id
same payment\_request\_id
same provider payment\_key
same amount
same customer session
same table
same webhook event id
same KDS release event

If duplicate payment or duplicate webhook is suspected, the system must not release another kitchen ticket automatically.

The state must become:

PAYMENT\_DUPLICATE\_SUSPECTED

and require reconciliation.

---

## **17\. Manual Fallback Boundary**

Manual payment confirmation may be used only during degraded operation.

Manual fallback examples:

provider webhook outage
store network failure
KDS bridge unavailable
customer paid but callback delayed
bank transfer manually confirmed

Manual fallback must create an evidence packet and must be marked:

FALLBACK\_ORIGINATED
MANUAL\_PAYMENT\_CONFIRMATION\_USED

Manual fallback must not erase the original payment uncertainty.

---

## **18\. Audit Requirements**

The system must create append-only audit events for:

payment request created
QR displayed
payment attempt started
webhook received
webhook verified
payment state changed
KDS release requested
KDS release completed
payment mismatch detected
manual confirmation used
fallback evidence packet created
reconciliation completed

Audit events must not be overwritten.

Replay may recreate projection state, but replay must not mutate the historical payment truth.

---

## **19\. Customer Experience Rule**

The customer-facing experience should be simple.

The customer should see:

주문 확인
결제 QR
결제 진행 중
결제 완료
주방 전달 완료

The customer should not see internal states such as:

webhook retry
signature verification
provider reconciliation
payment authority delay
KDS bridge release event

If payment confirmation is delayed, the customer-facing display may show:

결제 확인 중입니다.
잠시만 기다려 주세요.

---

## **20\. Store Experience Rule**

The store-facing experience must reduce work.

Staff should not need to:

open banking app
check SMS deposit alert
ask customer to show transfer screen
manually tell kitchen to start
compare order amount by memory

Staff should see:

payment complete
payment pending
payment failed
amount mismatch
manual confirmation required

with clear sound and visual alerts.

---

## **21\. Kitchen Experience Rule**

Kitchen should see only actionable states.

Allowed kitchen-facing states include:

WAITING\_PAYMENT
RELEASED
HOLD
CANCELLED
PAYMENT\_UNCERTAIN
MANUAL\_RECOVERY

Kitchen should not be asked to decide whether payment is real.

If payment is uncertain, kitchen should either hold or follow manager-approved manual fallback policy.

---

## **22\. MVP Cutline**

For MVP, the system should implement:

order\_id generation
amount lock
payment request creation
dynamic QR or payment link display
payment webhook receiver
webhook verification
idempotency check
payment status update
KDS release event
customer display payment complete event
audit event creation
manual fallback flag

Excluded from MVP:

full open banking integration
multi-bank deposit aggregation
zero-fee account transfer guarantee
automatic refund routing
tax settlement automation
cross-provider settlement optimization
AI payment fraud scoring

---

## **23\. Patent And BM Relevance**

This policy supports a business method structure where:

dynamic payment QR
verified payment webhook
automatic KDS release
customer display synchronization
counter bottleneck reduction
manual fallback evidence

are connected into one operational loop.

The novelty is not merely displaying a QR code.

The key structure is that payment verification becomes the trigger that synchronizes POS, KDS, customer display, and store operation state without requiring staff to manually confirm payment.

---

## **24\. Readiness Check**

This policy is ready when:

QR is generated per order, not as a generic static account QR
amount is locked before payment
payment webhook is verified before KDS release
KDS does not own payment authority
customer display does not own payment authority
duplicate webhook does not duplicate kitchen ticket
manual payment confirmation creates evidence
failed payment does not silently release kitchen ticket
store staff can operate without checking bank app manually
audit trail exists for every payment-to-kitchen transition

---

## **25\. Summary**

The system should not ask store owners to change hardware because it is convenient.

The system should reduce counter bottlenecks, remove manual payment confirmation, lower operational friction, and allow kitchen execution to begin only after verified payment authority.

Dynamic QR alone is not the product.

The product is the automated loop:

order created
payment requested
payment verified
kitchen released
customer informed
audit preserved

This loop is the foundation for POS-payment-KDS automation in small stores, restaurants, and future franchise operations.
