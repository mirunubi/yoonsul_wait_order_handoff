# 004270_Policy_Payment_Failure_Timeout_Duplicate_And_Manual_Confirmation

## **1\. Purpose**

This document defines the policy for payment failure, payment timeout, duplicate payment risk, amount mismatch, delayed webhook, and manual payment confirmation.

The purpose of this policy is to prevent payment uncertainty from causing kitchen release errors, duplicate preparation, customer disputes, settlement confusion, or hidden manual correction.

Payment automation must handle not only successful payment but also failed, delayed, duplicate, mismatched, abandoned, and manually confirmed payment situations.

---

## **2\. Scope**

This policy applies to:

* Dynamic QR payment failure
* Payment link or payment widget failure
* Toss Payments or equivalent PG webhook delay
* Virtual account deposit delay
* Open banking or fintech callback delay
* Customer payment abandonment
* Payment timeout
* Payment amount mismatch
* Duplicate payment attempt
* Duplicate webhook event
* Manual transfer confirmation
* KDS release blocking due to payment uncertainty
* Post-payment reconciliation

This policy does not define refund approval, customer compensation, final settlement allocation, tax reporting, chargeback dispute handling, or legal dispute resolution.

---

## **3\. Core Principle**

Payment uncertainty must not become kitchen truth.

Webhook received is not payment verified.

Customer claim is not payment verified.

Staff memory is not payment verified.

Bank notification screenshot is not system truth unless it is captured as manual evidence and reconciled.

KDS release must be blocked, held, or explicitly marked as manual fallback when payment truth is uncertain.

---

## **4\. Payment Failure State Model**

The system must distinguish payment states clearly.

Allowed payment uncertainty and failure states include:

PAYMENT\_PENDING
PAYMENT\_ATTEMPTED
PAYMENT\_PROCESSING
PAYMENT\_FAILED
PAYMENT\_CANCELED
PAYMENT\_EXPIRED
PAYMENT\_TIMEOUT
PAYMENT\_WEBHOOK\_DELAYED
PAYMENT\_WEBHOOK\_MISSING
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_DUPLICATE\_SUSPECTED
PAYMENT\_PROVIDER\_UNAVAILABLE
PAYMENT\_STATUS\_UNKNOWN
MANUAL\_PAYMENT\_CONFIRMATION\_REQUIRED
MANUAL\_PAYMENT\_CONFIRMATION\_USED
RECONCILIATION\_REQUIRED

These states must not be collapsed into `PAYMENT_DONE`.

---

## **5\. Payment Timeout Rule**

Every payment request must have an expiration policy.

The expiration policy should consider:

store operation type
counter order flow
table order flow
virtual account flow
provider timeout
customer display timeout
kitchen release policy

When the payment request expires, the state must become:

PAYMENT\_EXPIRED

or:

PAYMENT\_TIMEOUT

The expired QR, payment link, or payment request must not be reused.

A new payment request must be created if the customer still wants to proceed.

---

## **6\. Customer Payment Abandonment Rule**

If the customer starts payment but does not complete it, the system may mark:

CUSTOMER\_PAYMENT\_ABANDONED

or keep:

PAYMENT\_PENDING

until timeout.

The order must not be released to KDS unless the store policy allows unpaid kitchen preparation.

If customer abandonment occurs repeatedly for the same session, the system may require staff confirmation before regenerating a payment request.

---

## **7\. Webhook Delay Rule**

A delayed webhook must not be treated as failure immediately.

The system should distinguish:

PAYMENT\_WEBHOOK\_DELAYED
PAYMENT\_PROVIDER\_UNAVAILABLE
PAYMENT\_STATUS\_UNKNOWN

If the customer claims payment was completed but webhook has not arrived, the customer-facing display may show:

결제 확인 중입니다.
잠시만 기다려 주세요.

The store-facing display may show:

PAYMENT CHECK PENDING
DO NOT RELEASE WITHOUT CONFIRMATION

KDS must remain in:

PAYMENT\_HOLD

unless manual fallback is approved.

---

## **8\. Webhook Missing Rule**

If a webhook does not arrive within the defined timeout, the system must not silently assume payment success.

The system may attempt:

provider payment status query
payment request status refresh
manual staff confirmation
customer retry request
payment request replacement

If provider status cannot be verified, the state must become:

PAYMENT\_STATUS\_UNKNOWN

and:

RECONCILIATION\_REQUIRED

---

## **9\. Amount Mismatch Rule**

If the paid amount does not match the order amount, the state must become:

PAYMENT\_AMOUNT\_MISMATCH

Amount mismatch examples include:

customer paid less than required amount
customer paid more than required amount
order changed after QR creation
discount changed after payment request
coupon removed after payment request
wrong payment request reused
manual transfer amount typed incorrectly

KDS release must be blocked unless a manager-approved policy allows partial release.

Amount mismatch must create a reconciliation case.

---

## **10\. Duplicate Payment Attempt Rule**

Duplicate payment risk must be detected by comparing:

order\_id
payment\_request\_id
provider payment\_key
customer\_session\_id
amount
merchant\_reference
table\_id
timestamp

If duplicate payment is suspected, the state must become:

PAYMENT\_DUPLICATE\_SUSPECTED

The system must not create a second KDS release event from duplicate payment.

Duplicate payment does not automatically mean duplicate kitchen execution.

Payment duplicate and kitchen duplicate must be tracked separately.

---

## **11\. Duplicate Webhook Rule**

Payment providers may send the same webhook more than once.

Webhook handling must be idempotent.

The system must store:

provider\_event\_id
payment\_request\_id
provider\_payment\_key
event\_type
event\_received\_at
event\_processed\_at
idempotency\_result

If the same webhook is received again, it must be marked:

DUPLICATE\_WEBHOOK\_IGNORED

or:

DUPLICATE\_WEBHOOK\_ALREADY\_PROCESSED

It must not trigger duplicate KDS release, duplicate settlement, or duplicate customer notification.

---

## **12\. Provider Failure Rule**

When the payment provider is unavailable, the system must distinguish provider failure from customer failure.

Allowed provider failure states include:

PAYMENT\_PROVIDER\_UNAVAILABLE
PAYMENT\_PROVIDER\_TIMEOUT
PAYMENT\_STATUS\_QUERY\_FAILED
WEBHOOK\_DELIVERY\_FAILED
PROVIDER\_RECONCILIATION\_REQUIRED

The system may allow:

customer retry
alternative payment method
manual payment confirmation
postpaid store policy
order cancellation

depending on store policy.

---

## **13\. Manual Payment Confirmation Boundary**

Manual payment confirmation is allowed only when automated payment verification is degraded or unavailable.

Manual confirmation may use:

bank app confirmation
payment provider dashboard
customer transfer screen
store owner confirmation
manager confirmation
finance staff confirmation

Manual confirmation must not be treated as the same quality as verified webhook payment.

It must be marked:

MANUAL\_PAYMENT\_CONFIRMATION\_USED

and:

FALLBACK\_ORIGINATED

Manual confirmation must create or link to an evidence packet.

---

## **14\. Manual Confirmation Evidence**

Manual confirmation evidence should include:

order\_id
payment\_request\_id
customer\_session\_id
amount\_expected
amount\_observed
confirmation\_source
confirmed\_by
confirmed\_at
screenshot\_or\_note\_reference
reason\_automated\_verification\_failed
manager\_approval\_status
reconciliation\_status

If evidence is incomplete, the state must include:

EVIDENCE\_INCOMPLETE

Incomplete evidence may allow emergency service continuation but must not allow silent closure.

---

## **15\. KDS Hold And Release Boundary**

When payment failure or uncertainty occurs, KDS may show:

WAITING\_PAYMENT
PAYMENT\_HOLD
PAYMENT\_FAILED
PAYMENT\_UNCERTAIN
MANUAL\_CONFIRMATION\_REQUIRED
MANUAL\_RELEASE\_APPROVED

KDS must not independently convert these states into `RELEASED`.

Only verified payment authority or approved manual fallback may release the kitchen ticket.

---

## **16\. Manual Release Under Payment Uncertainty**

If the store decides to prepare the food despite payment uncertainty, the action must be marked:

MANUAL\_RELEASE\_UNDER\_PAYMENT\_UNCERTAINTY

This is allowed only when:

manager confirmation exists
customer impact risk is high
store policy allows manual continuation
evidence packet is created
reconciliation is required

This must not be treated as normal paid kitchen execution.

---

## **17\. Customer Display Rule**

Customer-facing messages must be clear but not expose internal provider details.

Allowed customer-facing messages include:

결제 대기 중입니다.
결제 확인 중입니다.
결제가 완료되었습니다.
결제가 실패했습니다. 다시 시도해 주세요.
결제 시간이 만료되었습니다. 다시 결제해 주세요.
직원 확인이 필요합니다.

Customer display must not show:

webhook missing
provider reconciliation failed
signature verification failed
duplicate webhook ignored
KDS release blocked by payment authority

---

## **18\. Store Display Rule**

Store-facing messages must be operationally actionable.

Allowed store-facing messages include:

PAYMENT PENDING
PAYMENT COMPLETE
PAYMENT FAILED
PAYMENT TIMEOUT
AMOUNT MISMATCH
DUPLICATE PAYMENT SUSPECTED
WEBHOOK DELAYED
MANUAL CONFIRMATION REQUIRED
DO NOT RELEASE KITCHEN
MANUAL RELEASE APPROVED

Store staff should not need to inspect raw provider logs during peak time.

---

## **19\. Refund Boundary**

This policy may detect overpayment, duplicate payment, failed payment, or customer dispute risk.

However, this policy does not approve refunds.

Refund authority belongs to a separate refund or customer recovery policy.

Payment failure handling may create:

REFUND\_REVIEW\_REQUIRED
CUSTOMER\_RECOVERY\_REQUIRED
FINANCE\_REVIEW\_REQUIRED

but must not execute refund by itself unless a separate authorized refund flow exists.

---

## **20\. Settlement Boundary**

Payment failure handling does not finalize settlement.

States such as:

PAYMENT\_DONE
MANUAL\_PAYMENT\_CONFIRMATION\_USED
PAYMENT\_DUPLICATE\_SUSPECTED
PAYMENT\_AMOUNT\_MISMATCH

must be passed to settlement logic with their uncertainty flags preserved.

Settlement must not treat manual confirmation as equal to provider-verified payment unless reconciliation confirms it.

---

## **21\. Audit Requirements**

The system must create append-only audit events for:

payment request created
payment attempt started
payment failed
payment timeout occurred
webhook delayed
webhook missing
webhook received
duplicate webhook ignored
amount mismatch detected
duplicate payment suspected
manual confirmation requested
manual confirmation completed
manual release approved
reconciliation required
reconciliation completed

Audit records must preserve the original uncertainty.

Audit must not be overwritten by later successful reconciliation.

---

## **22\. Reconciliation Rule**

Reconciliation must compare:

internal order amount
payment request amount
provider payment status
provider transaction reference
deposit callback
manual confirmation evidence
KDS release status
customer display status
settlement candidate status
refund or recovery case

Reconciliation outcomes may include:

PAYMENT\_VERIFIED\_AFTER\_DELAY
PAYMENT\_FAILED\_CONFIRMED
PAYMENT\_EXPIRED\_CONFIRMED
AMOUNT\_MISMATCH\_CONFIRMED
DUPLICATE\_PAYMENT\_CONFIRMED
MANUAL\_CONFIRMATION\_ACCEPTED
MANUAL\_CONFIRMATION\_REJECTED
REFUND\_REVIEW\_REQUIRED
SETTLEMENT\_REVIEW\_REQUIRED
HQ\_REVIEW\_REQUIRED

Reconciliation appends a conclusion.

It must not erase the original failure state.

---

## **23\. MVP Cutline**

For MVP, the system should support:

payment timeout
payment failed
payment expired
webhook delayed
webhook missing
amount mismatch
duplicate webhook idempotency
duplicate payment suspected flag
manual confirmation required
manual confirmation used flag
KDS hold
manual release approved flag
basic reconciliation status
append-only audit

Excluded from MVP:

automatic refund execution
multi-provider payment arbitration
full open banking reconciliation
advanced fraud scoring
AI duplicate payment classification
cross-store payment anomaly analytics
automatic legal dispute handling

---

## **24\. Relationship To 04260**

Document 04260 defines the successful payment verification and KDS release boundary.

This document defines what happens when that clean path fails, delays, conflicts, or requires manual confirmation.

The relationship is:

04260 \= verified payment to kitchen release policy
04270 \= payment uncertainty, failure, duplicate, and manual confirmation policy

A payment automation system is incomplete without 04270\.

---

## **25\. Readiness Check**

This policy is ready when:

payment timeout is distinguishable from failure
webhook delay is distinguishable from payment failure
amount mismatch blocks normal KDS release
duplicate webhook does not duplicate kitchen release
manual payment confirmation is marked as fallback-originated
KDS cannot decide payment truth
customer display shows simple payment status
store display shows actionable payment state
reconciliation preserves original uncertainty
refund authority remains separate
settlement authority receives uncertainty flags
audit trail is append-only

---

## **26\. Summary**

Payment automation is safe only when failure states are first-class states.

A good payment-to-kitchen system does not merely process successful payment.

It protects the store when payment is delayed, duplicated, mismatched, manually confirmed, or unknown.

The goal is not to pretend payment is simple.

The goal is to make payment uncertainty visible, controlled, auditable, and unable to corrupt kitchen execution.
