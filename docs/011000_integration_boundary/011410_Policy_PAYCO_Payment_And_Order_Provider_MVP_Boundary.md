# 004410_Policy_PAYCO_Payment_And_Order_Provider_MVP_Boundary

## **1\. Purpose**

This document defines the PAYCO payment and order provider MVP boundary policy.

The purpose of this policy is to evaluate and structure PAYCO or equivalent provider integration as a payment, order, membership, and customer-facing commerce candidate while preserving internal runtime authority.

PAYCO integration may support payment, order, membership, or partner commerce flow depending on available contract and API capability.

However, PAYCO must not automatically become the owner of POS authority, KDS authority, refund authority, settlement authority, customer recovery authority, or store operation truth.

---

## **2\. Scope**

This policy applies to:

* PAYCO payment integration
* PAYCO order-related integration if available
* PAYCO membership or customer identity integration if available
* PAYCO payment status callback
* PAYCO order status callback
* PAYCO provider status normalization
* PAYCO-to-KDS release eligibility
* PAYCO customer display status
* PAYCO failure, timeout, duplicate, and mismatch handling
* PAYCO provider onboarding checklist
* PAYCO MVP integration boundary

This policy does not define final PAYCO contract terms, actual fee structure, guaranteed settlement timing, refund authority, tax reporting, final customer membership design, or full open banking account-transfer structure.

---

## **3\. Core Principle**

PAYCO must be treated as an external provider.

The internal system must decide which role PAYCO is playing in each flow.

Possible roles include:

PAYMENT\_PROVIDER
ORDER\_PROVIDER
MEMBERSHIP\_PROVIDER
CUSTOMER\_IDENTITY\_PROVIDER
PROMOTION\_PROVIDER

PAYCO must not be treated by default as:

POS\_AUTHORITY
KDS\_AUTHORITY
REFUND\_AUTHORITY
SETTLEMENT\_AUTHORITY
STORE\_OPERATION\_AUTHORITY
CUSTOMER\_RECOVERY\_AUTHORITY

Provider role must be explicit per integration contract and capability level.

---

## **4\. MVP Goal**

The MVP goal is to determine whether PAYCO can support one or more of the following loops:

customer payment
        ↓
provider confirmation
        ↓
Payment Runtime verification
        ↓
KDS release
        ↓
customer display update

or:

external PAYCO order
        ↓
provider order event
        ↓
canonical order normalization
        ↓
payment status verification
        ↓
KDS projection or release

The MVP must not assume all PAYCO features are available at once.

---

## **5\. Provider Capability Separation**

PAYCO capability must be assessed separately by domain.

Required capability families:

payment capability
order capability
membership capability
coupon or promotion capability
refund visibility
settlement visibility
customer identity capability
webhook or callback capability
test environment capability

A provider may be strong in payment but weak in order sync.

A provider may support membership but not KDS-relevant order authority.

A provider may expose payment status but not settlement authority.

---

## **6\. PAYCO As Payment Provider**

If PAYCO is used as a payment provider, the internal flow should be:

internal order created
order amount locked
PAYCO payment request created
customer completes PAYCO payment
PAYCO payment event or status response received
Payment Runtime verifies event
internal payment status updated
KDS release becomes eligible
customer display updated
audit event created

PAYCO payment visibility must pass through Payment Runtime before KDS release.

PAYCO payment event must not directly release KDS.

---

## **7\. PAYCO As Order Provider**

If PAYCO provides order-related data, the order must pass through the POS Adapter or Order Provider Adapter layer.

The order must be normalized into the canonical order model.

Required normalized fields should include:

internal\_order\_id
external\_provider\_name \= PAYCO
external\_order\_id
external\_event\_id
store\_id
tenant\_id
order\_source
order\_channel
order\_status
payment\_status
items
total\_amount
customer\_session\_reference
source\_confidence
raw\_payload\_reference

PAYCO order data must not bypass canonical order normalization.

---

## **8\. PAYCO As Membership Provider**

If PAYCO membership or customer identity features are used, they must remain separate from internal customer identity unless explicitly linked.

The system must distinguish:

PAYCO customer identity
internal customer identity
store membership identity
tenant membership identity
윤슬 자리찜 identity
white-label tenant app identity

External membership visibility must not overwrite internal customer identity without consent and linking rules.

---

## **9\. Customer Identity Boundary**

PAYCO customer identity may be useful for login, payment, benefit, or order history linkage.

However, external identity must not automatically become the internal customer master.

Identity linking should require:

customer consent
provider identity reference
internal customer reference
store or tenant context
linked\_at
unlink policy
data usage scope

If identity is not linked, PAYCO customer reference should remain provider-scoped.

---

## **10\. Payment Request Rule**

A PAYCO payment request must be tied to a specific internal order or provider order.

Required references:

internal\_order\_id
payment\_request\_id
provider\_name \= PAYCO
store\_id
tenant\_id
customer\_session\_id
locked\_amount
currency
created\_at
expires\_at

A generic payment request not tied to an order must not trigger automatic KDS release.

---

## **11\. Amount Lock Rule**

Before PAYCO payment request creation, the amount must be locked.

The locked amount should include:

item subtotal
discount amount
coupon amount if applicable
promotion amount if applicable
tax amount if applicable
service charge if applicable
final payment amount

If PAYCO promotion or coupon changes the amount, the internal system must preserve:

internal original amount
provider discount amount
final paid amount
discount source
promotion reference

If amount mapping is unclear, the payment must be marked:

PAYMENT\_AMOUNT\_MISMATCH

or:

PAYMENT\_AMOUNT\_REVIEW\_REQUIRED

---

## **12\. Promotion And Coupon Boundary**

PAYCO promotion or coupon may reduce customer payment amount.

The system must distinguish:

store-funded discount
provider-funded discount
tenant-funded discount
membership benefit
coupon benefit
unknown discount source

Discount visibility does not equal settlement truth.

If discount funding source is unclear, settlement must receive uncertainty flags.

---

## **13\. Provider Status Mapping**

PAYCO statuses must be mapped to internal states.

Internal payment states may include:

PAYMENT\_PENDING
PAYMENT\_AUTHORIZED
PAYMENT\_DONE
PAYMENT\_FAILED
PAYMENT\_CANCELED
PAYMENT\_EXPIRED
PAYMENT\_STATUS\_UNKNOWN
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_DUPLICATE\_SUSPECTED
MANUAL\_PAYMENT\_CONFIRMATION\_REQUIRED

Internal order states may include:

ORDER\_CREATED
ORDER\_ACCEPTED
ORDER\_UPDATED
ORDER\_CANCELED
ORDER\_EXPIRED
ORDER\_STATUS\_UNKNOWN
REQUIRES\_REVIEW

Provider labels must not be used directly by KDS or customer display.

---

## **14\. KDS Release Rule**

KDS release is allowed only when internal Payment Runtime or approved order-payment authority confirms the order is eligible.

KDS must not be released directly by:

PAYCO payment screen
PAYCO order status label
customer claim
QR scan event
provider event not verified
payment pending state
membership confirmation
coupon usage

KDS release requires an internal state such as:

PAYMENT\_DONE

or a separately approved postpaid/manual fallback policy.

---

## **15\. Customer Display Rule**

Customer display may show PAYCO as a payment option or provider flow.

Customer-facing messages may include:

PAYCO로 결제하기
결제 확인 중입니다.
결제가 완료되었습니다.
주방에 주문이 전달되었습니다.
결제가 완료되지 않았습니다. 다시 시도해 주세요.
직원 확인이 필요합니다.

Customer display must not show raw provider states, internal adapter errors, webhook details, or KDS release internals.

---

## **16\. Failure Handling**

PAYCO payment or order failure must create internal failure states.

Allowed states include:

PAYMENT\_FAILED
PAYMENT\_TIMEOUT
PAYMENT\_EXPIRED
PAYMENT\_STATUS\_UNKNOWN
ORDER\_STATUS\_UNKNOWN
PROVIDER\_EVENT\_DELAYED
PROVIDER\_UNAVAILABLE
PAYMENT\_CONFIRMATION\_REQUIRED
RECONCILIATION\_REQUIRED

Failure must not automatically become order cancellation unless store policy defines the cancellation rule.

KDS release must be blocked or held when payment or order truth is uncertain.

---

## **17\. Duplicate Handling**

PAYCO provider events may be duplicated or retried.

The system must use idempotency checks.

Duplicate detection should compare:

provider\_name
provider\_event\_id
external\_order\_id
payment\_request\_id
provider\_payment\_reference
internal\_order\_id
amount
event\_type
payload\_hash

Duplicate provider events must not create duplicate orders, duplicate payments, duplicate KDS releases, or duplicate customer completion messages.

---

## **18\. Callback Or Webhook Verification Rule**

If PAYCO provides callback, webhook, or server-to-server notification, the event must be verified before internal state change.

Verification should include:

provider identity
merchant or store reference
external\_order\_id
payment reference
amount
status
timestamp
signature or provider validation rule if available
duplicate event check

If verification cannot be completed, the state must become:

PAYMENT\_SOURCE\_UNCERTAIN

or:

PROVIDER\_EVENT\_VERIFICATION\_REQUIRED

---

## **19\. Manual Fallback Boundary**

Manual confirmation may be used only as fallback.

Manual fallback may be used when:

provider callback is delayed
provider status cannot be queried
store network is degraded
customer claims payment completed
manager approves fallback

Manual confirmation must be marked:

MANUAL\_PAYMENT\_CONFIRMATION\_USED
FALLBACK\_ORIGINATED
RECONCILIATION\_REQUIRED

Manual confirmation must not be treated as provider-verified payment until reconciliation accepts it.

---

## **20\. Refund Boundary**

This MVP does not define automatic PAYCO refund authority.

PAYCO-related failure, duplicate payment, or overpayment may create:

REFUND\_REVIEW\_REQUIRED

Refund execution must follow a separate refund policy.

The system must not promise automatic refund unless the refund authority and provider refund flow are explicitly implemented and approved.

---

## **21\. Settlement Boundary**

PAYCO payment completion may create settlement visibility or settlement candidate data.

However, settlement authority remains separate.

Settlement logic must preserve flags such as:

PAYMENT\_DONE
PAYMENT\_AMOUNT\_MISMATCH
PROVIDER\_DISCOUNT\_UNCERTAIN
MANUAL\_PAYMENT\_CONFIRMATION\_USED
RECONCILIATION\_REQUIRED

PAYCO promotion, coupon, membership, or payment status must not be collapsed into final settlement truth without settlement policy.

---

## **22\. Provider Contract Assumption Rule**

The system must not assume PAYCO feature availability by brand name alone.

Each capability must be confirmed through:

provider documentation
contract scope
merchant approval
test environment
credential scope
production approval

Unknown capability must be marked:

REQUIRES\_PROVIDER\_CONFIRMATION

---

## **23\. MVP Data Objects**

The MVP should prepare conceptual objects such as:

provider
provider\_capability
provider\_credential
payment\_request
payment\_event
provider\_order\_event
provider\_customer\_reference
provider\_coupon\_reference
payment\_verification\_result
canonical\_order
kds\_release\_request
customer\_display\_state
payment\_reconciliation\_case
audit\_event

These are conceptual objects, not final database schemas.

---

## **24\. MVP Event Types**

The MVP should support event types such as:

PAYCO\_PAYMENT\_REQUEST\_CREATED
PAYCO\_PROVIDER\_EVENT\_RECEIVED
PAYCO\_PROVIDER\_EVENT\_VERIFIED
PAYCO\_PAYMENT\_DONE
PAYCO\_PAYMENT\_FAILED
PAYCO\_PAYMENT\_EXPIRED
PAYCO\_ORDER\_EVENT\_RECEIVED
PAYCO\_ORDER\_NORMALIZED
PAYCO\_COUPON\_APPLIED
PAYCO\_PROMOTION\_APPLIED
PAYMENT\_AMOUNT\_MISMATCH
KDS\_RELEASE\_REQUESTED
KDS\_RELEASED
MANUAL\_PAYMENT\_CONFIRMATION\_REQUIRED
RECONCILIATION\_REQUIRED

Provider-specific event names should be mapped into internal event families.

---

## **25\. Diagnostic Error Codes**

The MVP should reuse 04330 diagnostic codes.

Relevant codes may include:

POSADP-PAY-001 payment status missing
POSADP-PAY-002 payment status conflict
POSADP-PAY-003 payment amount mismatch
POSADP-PAY-005 payment webhook delayed
POSADP-PAY-006 payment confirmation required
POSADP-WEBHOOK-006 duplicate provider event ignored
POSADP-MAP-005 discount mapping uncertain
POSADP-NORMALIZE-001 normalization failed
POSADP-CONFLICT-002 payment status conflict
POSADP-AUTH-001 payment visibility treated as payment authority

Provider-specific issues must be translated into internal diagnostic language.

---

## **26\. Monitoring Requirements**

PAYCO integration monitoring should track:

payment request count
payment success count
payment failure count
payment timeout count
provider callback delay
provider verification failure
duplicate event count
amount mismatch count
promotion mapping uncertainty
coupon mapping uncertainty
KDS release delay after payment
manual confirmation count
reconciliation required count

Monitoring must support both support-facing diagnosis and store-facing safe messages.

---

## **27\. Security Requirements**

PAYCO integration must protect credentials, provider references, and customer data.

Security rules:

provider credentials must be scoped
webhook or callback secrets must not be exposed
test and production credentials must be separated
customer personal data must be minimized
provider customer references must be protected
raw payload must be masked where needed
credential rotation must be possible

Provider identity linkage must respect consent and data usage scope.

---

## **28\. MVP Success Criteria**

PAYCO MVP is successful if it can prove at least one of the following:

PAYCO payment event can be verified and mapped to internal PAYMENT\_DONE
PAYCO payment confirmation can safely trigger KDS release
PAYCO order event can be normalized into canonical order model
PAYCO promotion or coupon can be represented without corrupting amount truth
PAYCO provider identity can be linked without overwriting internal customer identity

The most important first success path is:

customer pays
provider event is verified
Payment Runtime updates state
KDS release is triggered safely
audit chain is preserved

---

## **29\. MVP Exclusions**

The PAYCO MVP excludes:

full PAYCO membership master integration
automatic customer identity merge
automatic refund execution
automatic settlement allocation
full coupon funding reconciliation
full franchise-wide provider rollout
full POS replacement
full multi-provider loyalty engine
guaranteed provider fee claim

These may be later phases.

---

## **30\. Relationship To 04400**

Document 04400 defines the Toss Payments MVP Integration Boundary policy.

This document defines the PAYCO Payment and Order Provider MVP Boundary policy.

The relationship is:

04400 \= first payment provider MVP path
04410 \= second payment/order/membership provider candidate path

Together, they help prove that the internal Payment Runtime and Order Provider Adapter are provider-neutral.

---

## **31\. Relationship To POS Integration Governance**

This document depends on:

04300 POS Provider Abstraction And Multi-POS Adapter Policy
04310 Canonical Order Model And POS Event Normalization Policy
04320 POS Adapter Capability Level And Integration Contract Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04340 POS Vendor Priority And Integration Roadmap Policy
04350 POS Adapter Test Harness And Certification Scenario Policy
04360 POS Provider Onboarding Evidence And Contract Checklist Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04390 POS Integration Governance Index And Readiness Check

PAYCO must pass through the same governance model as other providers.

---

## **32\. Patent And SaaS Relevance**

This document supports the broader BM and SaaS strategy because it tests whether the platform can absorb more than one payment or order provider.

The strategic structure is:

provider-specific payment/order event
        ↓
provider verification
        ↓
canonical order or payment state
        ↓
KDS release
        ↓
customer display
        ↓
audit and reconciliation

The strategic value is not PAYCO alone.

The strategic value is provider neutrality.

---

## **33\. Known Gaps To Track**

The following gaps must remain visible:

actual PAYCO API scope
actual PAYCO order API availability
actual PAYCO payment callback method
actual PAYCO membership integration scope
actual merchant approval process
actual fee and settlement terms
actual refund support
actual coupon and promotion funding rules
actual test environment access
actual production credential process

These gaps do not block policy drafting.

They block overclaiming and production launch.

---

## **34\. Readiness Check**

This policy is ready when:

PAYCO roles are separated
payment provider role is defined
order provider role is optional and capability-based
membership provider role is separated from internal identity
Payment Runtime owns verification
KDS release requires internal verified state
customer display does not own authority
promotion and coupon amount effects are visible
refund and settlement are separate
manual confirmation is fallback-originated
provider capabilities require confirmation
MVP exclusions are explicit
known gaps are visible

---

## **35\. Summary**

PAYCO integration should not be treated as a single feature.

It may touch payment, order, membership, promotion, coupon, and customer identity.

Therefore, PAYCO must be integrated through clear boundaries.

The MVP should prove only the safe parts first:

payment or order event received
provider event verified
internal runtime updates state
KDS release remains authority-controlled
customer display remains simple
audit preserves truth

Once this works, PAYCO or equivalent providers can become part of the broader provider-neutral POS and payment federation platform.
