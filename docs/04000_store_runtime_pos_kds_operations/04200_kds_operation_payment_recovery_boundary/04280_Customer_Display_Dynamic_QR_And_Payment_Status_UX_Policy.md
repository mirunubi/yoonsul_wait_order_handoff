# **04280 Customer Display Dynamic QR And Payment Status UX Policy**

## **1\. Purpose**

This document defines the customer display UX policy for dynamic QR payment, payment progress, payment completion, payment failure, and kitchen handoff visibility.

The purpose of this policy is to make customer-facing payment and order status simple, trustworthy, and low-friction while hiding unnecessary internal system complexity.

Customer display must help customers understand what to do next without exposing webhook state, provider errors, KDS bridge internals, or operational uncertainty beyond what is necessary.

---

## **2\. Scope**

This policy applies to:

* Counter customer display
* Table order display
* Table tablet payment screen
* Customer mobile web order screen
* Dynamic QR payment screen
* Payment link screen
* Payment widget screen
* Payment progress screen
* Payment failure and retry screen
* Kitchen handoff confirmation screen
* Staff assistance request screen

This policy does not define payment authority, refund authority, settlement authority, KDS execution authority, or customer compensation approval.

---

## **3\. Core Principle**

Customer display is visibility, not authority.

Customer display may show payment and order status.

Customer display must not determine payment truth.

Customer display must not release KDS tickets.

Customer display must not convert uncertain internal states into confirmed customer messages.

The customer-facing screen should be calm, clear, and action-oriented.

---

## **4\. Customer Display Role**

Customer Display Runtime may display:

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

Customer Display Runtime must not emit:

PAYMENT\_DONE
KDS\_RELEASED
REFUND\_APPROVED
SETTLEMENT\_CONFIRMED
ORDER\_FINALIZED

unless those states were already confirmed by the proper authority runtime.

---

## **5\. Standard Customer Flow**

The standard customer-facing flow is:

1\. Customer order is created.
2\. Customer reviews order summary.
3\. Customer sees payment QR, payment link, or payment button.
4\. Customer completes payment.
5\. Customer sees payment checking screen.
6\. Customer sees payment complete screen.
7\. Customer sees kitchen received or order in preparation message.

The screen should avoid showing too many intermediate technical states.

---

## **6\. Dynamic QR Display Rule**

Dynamic QR must be displayed only for a specific order or payment request.

The customer-facing QR screen should show:

store name
order number or short reference
payment amount
payment method guidance
QR code
expiration notice
retry or cancel option
staff help option

The customer-facing QR screen should not show:

internal order\_id
payment\_request\_id
provider payment\_key
webhook secret
raw provider status
database state
KDS bridge state
audit event ID

---

## **7\. Amount Visibility Rule**

The customer must clearly see the payment amount before scanning or confirming payment.

The amount display should include:

menu subtotal
discount or coupon applied
final payment amount
tax included notice if applicable

If the order changes after QR creation, the previous QR must be expired or replaced.

The customer must not be allowed to pay using a stale amount screen.

---

## **8\. QR Expiration UX Rule**

Every dynamic QR should have an expiration policy.

The screen may show:

이 QR은 잠시 후 만료됩니다.
결제 시간이 만료되면 다시 결제 화면을 생성해 주세요.

When the QR expires, the screen should show:

결제 시간이 만료되었습니다.
다시 결제해 주세요.

The expired QR should not remain scannable as an active payment path.

---

## **9\. Payment Processing UX Rule**

After the customer attempts payment, the display should move to:

결제 확인 중입니다.
잠시만 기다려 주세요.

The customer should not be asked to verbally confirm payment unless automated verification is delayed beyond the store-defined threshold.

The screen should avoid creating panic during short webhook delays.

---

## **10\. Payment Complete UX Rule**

Payment complete may be shown only after Payment Runtime verifies the payment event.

The customer-facing message may be:

결제가 완료되었습니다.
주방에 주문이 전달되었습니다.

or:

결제 완료.
곧 준비를 시작합니다.

The system must not show payment complete based only on QR scan, customer claim, or staff observation.

---

## **11\. Kitchen Handoff Visibility Rule**

Customer display may show simple kitchen handoff status.

Allowed customer-facing kitchen status includes:

주문 접수
결제 완료
주방 전달 완료
준비 중
준비 완료
픽업 가능

Customer display must not expose internal KDS states such as:

KDS\_RELEASE\_REQUESTED
KDS\_BRIDGE\_DELAYED
PAYMENT\_HOLD
SOURCE\_CONFLICT\_REVIEW\_REQUIRED
MANUAL\_RECOVERY\_ORIGINATED

If internal uncertainty affects the customer, it should be translated into a simple message.

---

## **12\. Payment Failure UX Rule**

If payment fails, the customer-facing display should show:

결제가 완료되지 않았습니다.
다시 시도해 주세요.

The screen may provide:

retry payment
choose another method
ask staff
cancel order

The screen must not blame the customer unless the provider clearly returns a customer-actionable reason.

---

## **13\. Payment Delay UX Rule**

If payment confirmation is delayed, the customer-facing display may show:

결제 확인이 지연되고 있습니다.
잠시만 기다려 주세요.

After the store-defined threshold, the display may show:

직원 확인이 필요합니다.
카운터에 문의해 주세요.

This state must map internally to:

PAYMENT\_WEBHOOK\_DELAYED
PAYMENT\_STATUS\_UNKNOWN
MANUAL\_CONFIRMATION\_REQUIRED

but these internal names must not be shown to the customer.

---

## **14\. Amount Mismatch UX Rule**

If amount mismatch occurs, the customer-facing display should show:

결제 금액 확인이 필요합니다.
직원에게 문의해 주세요.

The display must not expose internal mismatch calculations unless designed for staff view.

The system may guide the customer to:

retry payment
request staff help
wait for confirmation

Amount mismatch must not be hidden as normal payment success.

---

## **15\. Duplicate Payment UX Rule**

If duplicate payment is suspected, the customer-facing display should show:

결제 확인이 필요합니다.
중복 결제 가능성이 있어 직원이 확인 중입니다.

The display must not automatically promise refund.

Refund decision belongs to a separate refund or customer recovery policy.

Safe wording:

확인 후 안내드리겠습니다.

Unsafe wording:

곧 자동 환불됩니다.

unless an authorized refund flow actually exists.

---

## **16\. Staff Assistance UX Rule**

Customer display should provide a clear path to request staff assistance.

Allowed assistance triggers include:

payment failed
payment delayed
amount mismatch
QR expired
customer cannot scan QR
customer wants another payment method
customer claims payment completed

The customer-facing message should be short and actionable.

Example:

도움이 필요하시면 직원을 불러 주세요.

---

## **17\. Accessibility And Clarity Rule**

Customer display should support:

large readable amount
clear payment button or QR area
high-contrast status message
short Korean sentence
optional multilingual guidance
visible order number
visible retry button
visible help path

The screen should not overload customers with technical details.

For foreign customers, the MVP may support simple multilingual labels:

Pay now
Payment checking
Payment complete
Please ask staff

---

## **18\. Counter Display Rule**

For counter display, the screen should prioritize speed.

Counter display should show:

order amount
QR code
payment status
order short number
success or failure state

Counter display should avoid long explanations.

Counter display may show a large visual confirmation when payment is complete.

---

## **19\. Table Display Rule**

For table order display, the screen may include more context.

Table display may show:

selected items
quantity
total amount
payment QR
payment status
kitchen received status
estimated preparation guidance
call staff button

Table display must still avoid exposing provider or KDS internals.

---

## **20\. Customer Mobile Web Rule**

For customer mobile web, the flow should support:

order review
payment redirect
payment return
payment checking
payment complete
retry payment
staff help

If the customer leaves the page and returns, the screen should restore the latest safe customer-facing status from projection state.

Restored status must be based on verified server state, not browser memory alone.

---

## **21\. Error Message Rule**

Customer-facing error messages should be human and non-technical.

Preferred wording:

결제를 확인하지 못했습니다.
다시 시도하거나 직원을 불러 주세요.

Avoid wording:

Webhook missing.
Provider callback failed.
Payment authority timeout.
KDS release blocked.

Technical details belong to store or admin view.

---

## **22\. Privacy Rule**

Customer display must not expose unnecessary personal information.

The display should not show:

full customer phone number
full payment account number
provider token
internal user ID
staff name unless needed
other table order details
other customer payment status

If customer identity is needed, use a short reference or masked display.

---

## **23\. Fallback UX Rule**

During degraded operation, customer display may show:

현재 결제 확인이 지연되고 있습니다.
직원이 확인 후 안내드리겠습니다.

If the store switches to manual fallback, customer display must not falsely show fully automated confirmation.

Manual fallback should be customer-simple but internally marked.

Customer-visible wording should remain calm.

---

## **24\. Audit Boundary**

Customer display interactions may generate audit or event records such as:

QR displayed
payment screen opened
retry selected
staff help requested
payment complete shown
payment failure shown

However, customer display audit does not prove payment.

Payment truth must come from Payment Runtime.

---

## **25\. MVP Cutline**

For MVP, the customer display should support:

order summary
dynamic QR display
payment amount display
payment checking state
payment complete state
payment failed state
payment expired state
retry button
staff help message
kitchen received message

Excluded from MVP:

advanced multilingual UX
AI recommendation
personalized customer recovery
loyalty wallet integration
real-time preparation prediction
full accessibility certification
animated order tracking

---

## **26\. Relationship To 04260 And 04270**

Document 04260 defines the payment webhook and KDS release boundary.

Document 04270 defines payment failure, timeout, duplicate, and manual confirmation policy.

This document defines how those states are safely translated into customer-facing display.

The relationship is:

04260 \= payment verification and KDS release boundary
04270 \= payment uncertainty and failure handling
04280 \= customer-facing QR and payment status UX

---

## **27\. Readiness Check**

This policy is ready when:

customer sees clear amount before payment
QR is tied to a specific order
expired QR cannot be reused silently
payment complete is shown only after verified payment
payment delay has a calm customer message
payment failure offers retry or staff help
amount mismatch does not appear as normal success
duplicate payment does not promise refund automatically
customer display does not own payment authority
customer display does not expose KDS or provider internals

---

## **28\. Summary**

Customer display must make payment feel simple.

The system behind it may contain POS, Payment Runtime, webhook verification, KDS release, fallback, and reconciliation.

But the customer should experience a clean flow:

check order
scan or pay
wait briefly
see confirmation
know the kitchen received it

The screen is not the authority.

The screen is the customer-visible surface of verified operational state.
