# **04330 POS Adapter Error Code And Diagnostic Message Policy**

## **1\. Purpose**

This document defines the POS adapter error code and diagnostic message policy.

The purpose of this policy is to make POS integration failures diagnosable, searchable, reproducible, and actionable across many POS providers.

When the system integrates with multiple POS providers, payment providers, table order systems, delivery apps, kiosks, and legacy devices, failures must not be described as vague messages such as “연동 오류” or “처리 실패.”

Each error must clearly identify the failing layer, event type, authority boundary, source confidence, and required next action.

The system should use Unix-like diagnostic discipline:

small error code
clear category
precise cause
stable message
actionable hint
auditable context

---

## **2\. Scope**

This policy applies to:

* POS adapter error codes
* POS provider event failures
* POS payload normalization failures
* Canonical order mapping failures
* Payment status conflicts
* KDS release blocking errors
* Webhook duplication and delay
* Event chronology uncertainty
* Table reference conflicts
* Menu item mapping errors
* Adapter capability downgrade
* Manual fallback trigger messages
* Store-facing diagnostic messages
* Developer-facing diagnostic messages
* Audit-linked error events

This policy does not define UI styling, vendor contract penalties, refund approval, settlement allocation, or legal dispute resolution.

---

## **3\. Core Principle**

Errors must be operational language.

The system must not hide integration failure behind vague messages.

The core principle is:

vague error message \= operational blindness
structured error code \= recoverable system state

Every POS adapter error should answer:

what failed
where it failed
which provider or adapter was involved
which order or event was affected
whether authority was affected
whether customer or kitchen action is blocked
what should happen next

---

## **4\. Error Code Format**

POS adapter error codes should use a stable structured format.

Recommended format:

POSADP-{DOMAIN}-{NUMBER}

Example:

POSADP-ORDER-001
POSADP-PAY-002
POSADP-KDS-003
POSADP-MAP-004
POSADP-TABLE-005
POSADP-WEBHOOK-006
POSADP-TIME-007
POSADP-CAP-008

The code must remain stable across releases.

The text message may improve over time, but the meaning of the code must not silently change.

---

## **5\. Error Domains**

Allowed POS adapter error domains include:

ORDER
PAY
KDS
MAP
TABLE
WEBHOOK
TIME
CAP
AUTH
PROVIDER
NORMALIZE
DUPLICATE
CONFLICT
FALLBACK
SECURITY
REPLAY
AUDIT

Each domain should represent a clear diagnostic category.

A single incident may create multiple error codes when multiple layers are affected.

---

## **6\. Error Severity Levels**

Each error must carry a severity level.

Allowed severity levels include:

INFO
NOTICE
WARNING
ERROR
CRITICAL
BLOCKING

Severity definitions:

INFO \= normal diagnostic information
NOTICE \= non-blocking unusual condition
WARNING \= possible operational risk
ERROR \= action failed or requires review
CRITICAL \= severe integration or authority risk
BLOCKING \= customer, payment, or kitchen action must not proceed normally

Severity must reflect operational impact, not developer discomfort.

---

## **7\. Error Audience Levels**

Each error must define its intended audience.

Allowed audience levels include:

CUSTOMER\_SAFE
STORE\_STAFF
MANAGER
OWNER
HQ\_SUPPORT
DEVELOPER
VENDOR\_SUPPORT
AUDIT\_ONLY

The same underlying error may produce different messages for different audiences.

Example:

Developer message:
POSADP-WEBHOOK-006 duplicate provider event ignored.

Store message:
이미 처리된 결제/주문 이벤트입니다. 추가 조리는 발생하지 않았습니다.

Customer-facing messages must remain simple and calm.

---

## **8\. Error Context Fields**

Each error event should include structured context.

Minimum recommended fields:

error\_code
severity
audience
tenant\_id
store\_id
adapter\_name
adapter\_version
provider\_name
external\_store\_id
external\_terminal\_id
external\_order\_id
external\_event\_id
internal\_order\_id
event\_type
source\_confidence
capability\_level
authority\_impact
customer\_impact
kitchen\_impact
payment\_impact
detected\_at
raw\_payload\_reference
audit\_event\_reference
recommended\_action

If some identifiers are unavailable, the error should explicitly mark the missing context.

---

## **9\. Authority Impact Classification**

Each error must classify whether authority is affected.

Allowed authority impact values include:

NO\_AUTHORITY\_IMPACT
PAYMENT\_AUTHORITY\_AFFECTED
ORDER\_AUTHORITY\_AFFECTED
KITCHEN\_RELEASE\_AUTHORITY\_AFFECTED
REFUND\_AUTHORITY\_AFFECTED
SETTLEMENT\_AUTHORITY\_AFFECTED
UNKNOWN\_AUTHORITY\_IMPACT

If authority impact is unknown, the system must avoid automatic state promotion.

---

## **10\. Customer Impact Classification**

Each error must classify customer impact.

Allowed customer impact values include:

NO\_CUSTOMER\_IMPACT
CUSTOMER\_DISPLAY\_DELAY
PAYMENT\_RETRY\_REQUIRED
PAYMENT\_CONFIRMATION\_DELAY
STAFF\_ASSISTANCE\_REQUIRED
ORDER\_DELAY\_RISK
CUSTOMER\_RECOVERY\_REQUIRED
UNKNOWN\_CUSTOMER\_IMPACT

Customer impact classification does not automatically approve compensation.

Customer recovery must follow separate policy.

---

## **11\. Kitchen Impact Classification**

Each error must classify kitchen impact.

Allowed kitchen impact values include:

NO\_KITCHEN\_IMPACT
KDS\_RELEASE\_BLOCKED
KDS\_RELEASE\_DELAYED
KITCHEN\_HOLD\_REQUIRED
DUPLICATE\_PREPARATION\_RISK
MANUAL\_KITCHEN\_RECOVERY\_REQUIRED
KITCHEN\_STATUS\_UNCERTAIN
UNKNOWN\_KITCHEN\_IMPACT

Kitchen impact must be visible to store staff and KDS only when actionable.

---

## **12\. Payment Impact Classification**

Each error must classify payment impact.

Allowed payment impact values include:

NO\_PAYMENT\_IMPACT
PAYMENT\_PENDING
PAYMENT\_FAILED
PAYMENT\_STATUS\_UNKNOWN
PAYMENT\_AMOUNT\_MISMATCH
PAYMENT\_DUPLICATE\_SUSPECTED
MANUAL\_PAYMENT\_CONFIRMATION\_REQUIRED
PAYMENT\_RECONCILIATION\_REQUIRED
UNKNOWN\_PAYMENT\_IMPACT

Payment impact must not be inferred from kitchen status alone.

---

## **13\. POSADP-ORDER Error Codes**

Order domain errors relate to order identity, order state, or order lifecycle.

Recommended initial codes:

POSADP-ORDER-001 external\_order\_id missing
POSADP-ORDER-002 external order maps to multiple internal orders
POSADP-ORDER-003 internal order identity missing
POSADP-ORDER-004 order status mapping uncertain
POSADP-ORDER-005 order update received for unknown order
POSADP-ORDER-006 order cancellation received after kitchen release
POSADP-ORDER-007 order accepted but payment state missing
POSADP-ORDER-008 order payload incomplete
POSADP-ORDER-009 order source unknown
POSADP-ORDER-010 order channel mapping uncertain

Example diagnostic message:

POSADP-ORDER-001 external\_order\_id missing.
The provider event cannot be safely mapped to an internal order.
Action: preserve raw payload, create review event, block authority-level processing.

---

## **14\. POSADP-PAY Error Codes**

Payment domain errors relate to payment status, amount, provider confirmation, or manual confirmation.

Recommended initial codes:

POSADP-PAY-001 payment status missing
POSADP-PAY-002 payment status conflict
POSADP-PAY-003 payment amount mismatch
POSADP-PAY-004 payment provider status unknown
POSADP-PAY-005 payment webhook delayed
POSADP-PAY-006 payment confirmation required
POSADP-PAY-007 duplicate payment suspected
POSADP-PAY-008 manual payment confirmation used
POSADP-PAY-009 payment expired
POSADP-PAY-010 payment state cannot trigger KDS release

Example diagnostic message:

POSADP-PAY-002 payment status conflict.
POS provider payment status differs from Payment Runtime status.
Action: hold KDS release if not already released, create reconciliation case.

---

## **15\. POSADP-KDS Error Codes**

KDS domain errors relate to kitchen release, kitchen ticket state, or KDS visibility.

Recommended initial codes:

POSADP-KDS-001 KDS release blocked by payment uncertainty
POSADP-KDS-002 KDS ticket missing after order accepted
POSADP-KDS-003 kitchen release requested before payment verification
POSADP-KDS-004 KDS state stale
POSADP-KDS-005 KDS bridge unavailable
POSADP-KDS-006 manual kitchen recovery required
POSADP-KDS-007 duplicate kitchen release prevented
POSADP-KDS-008 kitchen cancellation arrived after preparation started
POSADP-KDS-009 KDS projection replay required
POSADP-KDS-010 kitchen status conflict

Example diagnostic message:

POSADP-KDS-003 kitchen release requested before payment verification.
Action: block release, mark PAYMENT\_HOLD, notify staff display.

---

## **16\. POSADP-MAP Error Codes**

Mapping domain errors relate to menu items, modifiers, discounts, taxes, bundles, or provider-specific values.

Recommended initial codes:

POSADP-MAP-001 unknown external item
POSADP-MAP-002 item mapping required
POSADP-MAP-003 modifier mapping required
POSADP-MAP-004 bundle mapping required
POSADP-MAP-005 discount mapping uncertain
POSADP-MAP-006 tax mapping uncertain
POSADP-MAP-007 service charge mapping uncertain
POSADP-MAP-008 external item mapped to inactive internal item
POSADP-MAP-009 provider menu version mismatch
POSADP-MAP-010 kitchen station mapping missing

Example diagnostic message:

POSADP-MAP-001 unknown external item.
The provider item is not mapped to an internal menu item.
Action: mark ITEM\_MAPPING\_REQUIRED, allow or block KDS release based on store policy.

---

## **17\. POSADP-TABLE Error Codes**

Table domain errors relate to table, seating session, split table, merged table, or customer session reference.

Recommended initial codes:

POSADP-TABLE-001 table reference missing
POSADP-TABLE-002 table reference ambiguous
POSADP-TABLE-003 external table maps to multiple internal tables
POSADP-TABLE-004 table moved after payment request created
POSADP-TABLE-005 split table mapping uncertain
POSADP-TABLE-006 merged table mapping uncertain
POSADP-TABLE-007 seating session missing
POSADP-TABLE-008 customer session missing
POSADP-TABLE-009 table status conflict
POSADP-TABLE-010 table reference changed after KDS release

Example diagnostic message:

POSADP-TABLE-002 table reference ambiguous.
The order cannot be safely attached to one seating session.
Action: show staff review, preserve order and payment state separately.

---

## **18\. POSADP-WEBHOOK Error Codes**

Webhook domain errors relate to provider event delivery, verification, duplication, and delay.

Recommended initial codes:

POSADP-WEBHOOK-001 webhook signature verification failed
POSADP-WEBHOOK-002 webhook secret missing
POSADP-WEBHOOK-003 webhook payload malformed
POSADP-WEBHOOK-004 webhook event type unsupported
POSADP-WEBHOOK-005 webhook delivery delayed
POSADP-WEBHOOK-006 duplicate provider event ignored
POSADP-WEBHOOK-007 webhook event received for unknown order
POSADP-WEBHOOK-008 webhook replay detected
POSADP-WEBHOOK-009 webhook provider timestamp missing
POSADP-WEBHOOK-010 webhook verification unavailable

Example diagnostic message:

POSADP-WEBHOOK-006 duplicate provider event ignored.
This event has already been processed.
Action: do not create duplicate order, payment, or KDS release.

---

## **19\. POSADP-TIME Error Codes**

Time domain errors relate to chronology, ordering, timestamp uncertainty, and replay.

Recommended initial codes:

POSADP-TIME-001 provider event time missing
POSADP-TIME-002 provider event arrived out of order
POSADP-TIME-003 event chronology uncertain
POSADP-TIME-004 stale provider event ignored
POSADP-TIME-005 replay required due to time conflict
POSADP-TIME-006 provider timezone unknown
POSADP-TIME-007 received\_at earlier than provider\_event\_time beyond tolerance
POSADP-TIME-008 order update older than current verified state
POSADP-TIME-009 event time drift detected
POSADP-TIME-010 chronology conflict requires reconciliation

Example diagnostic message:

POSADP-TIME-003 event chronology uncertain.
Provider events arrived in an order that may not reflect actual operation order.
Action: preserve both events, avoid last-write-wins, require reconciliation if authority is affected.

---

## **20\. POSADP-CAP Error Codes**

Capability domain errors relate to adapter integration level, contract scope, downgrade, or unsupported operations.

Recommended initial codes:

POSADP-CAP-001 operation not allowed by integration level
POSADP-CAP-002 write attempted on read-only adapter
POSADP-CAP-003 provider capability unknown
POSADP-CAP-004 integration capability downgraded
POSADP-CAP-005 integration contract missing
POSADP-CAP-006 provider feature unsupported
POSADP-CAP-007 store-level capability lower than provider capability
POSADP-CAP-008 authority operation blocked by contract
POSADP-CAP-009 adapter version not certified
POSADP-CAP-010 capability upgrade requires review

Example diagnostic message:

POSADP-CAP-002 write attempted on read-only adapter.
The adapter is Level 1 and cannot update POS state.
Action: block write operation and create audit event.

---

## **21\. POSADP-AUTH Error Codes**

Authority domain errors relate to improper authority promotion or boundary violation.

Recommended initial codes:

POSADP-AUTH-001 payment visibility treated as payment authority
POSADP-AUTH-002 customer display attempted authority state change
POSADP-AUTH-003 KDS attempted payment authority decision
POSADP-AUTH-004 adapter attempted refund authority action
POSADP-AUTH-005 bridge attempted order truth overwrite
POSADP-AUTH-006 manual confirmation promoted without reconciliation
POSADP-AUTH-007 agent recommendation attempted execution
POSADP-AUTH-008 settlement authority crossed by payment adapter
POSADP-AUTH-009 authority boundary missing
POSADP-AUTH-010 unauthorized state promotion blocked

Example diagnostic message:

POSADP-AUTH-001 payment visibility treated as payment authority.
A visible provider or POS status was used as if it were verified payment truth.
Action: block state promotion, require Payment Runtime verification.

---

## **22\. POSADP-PROVIDER Error Codes**

Provider domain errors relate to provider availability, credentials, API response, or external service health.

Recommended initial codes:

POSADP-PROVIDER-001 provider unavailable
POSADP-PROVIDER-002 provider timeout
POSADP-PROVIDER-003 provider rate limit exceeded
POSADP-PROVIDER-004 provider credential invalid
POSADP-PROVIDER-005 provider permission denied
POSADP-PROVIDER-006 provider API version changed
POSADP-PROVIDER-007 provider response malformed
POSADP-PROVIDER-008 provider status query failed
POSADP-PROVIDER-009 provider maintenance detected
POSADP-PROVIDER-010 provider contract expired or inactive

Example diagnostic message:

POSADP-PROVIDER-003 provider rate limit exceeded.
The adapter cannot safely poll provider status at the requested frequency.
Action: slow polling, mark provider delayed, avoid real-time claims.

---

## **23\. POSADP-NORMALIZE Error Codes**

Normalization domain errors relate to conversion from provider payload to canonical order model.

Recommended initial codes:

POSADP-NORMALIZE-001 normalization failed
POSADP-NORMALIZE-002 required canonical field missing
POSADP-NORMALIZE-003 provider payload version unsupported
POSADP-NORMALIZE-004 normalized total amount inconsistent
POSADP-NORMALIZE-005 normalized item count inconsistent
POSADP-NORMALIZE-006 raw payload reference missing
POSADP-NORMALIZE-007 source confidence cannot be assigned
POSADP-NORMALIZE-008 normalization completed with warning
POSADP-NORMALIZE-009 canonical order projection failed
POSADP-NORMALIZE-010 normalization rule version mismatch

Example diagnostic message:

POSADP-NORMALIZE-002 required canonical field missing.
The provider payload cannot populate the minimum canonical order model.
Action: preserve raw payload, mark REQUIRES\_REVIEW.

---

## **24\. POSADP-DUPLICATE Error Codes**

Duplicate domain errors relate to duplicate orders, payments, provider events, or kitchen releases.

Recommended initial codes:

POSADP-DUPLICATE-001 duplicate external order detected
POSADP-DUPLICATE-002 duplicate payment event detected
POSADP-DUPLICATE-003 duplicate KDS release prevented
POSADP-DUPLICATE-004 duplicate provider event ignored
POSADP-DUPLICATE-005 duplicate manual recovery case suspected
POSADP-DUPLICATE-006 same payload hash received multiple times
POSADP-DUPLICATE-007 duplicate table session order suspected
POSADP-DUPLICATE-008 duplicate cancellation event ignored
POSADP-DUPLICATE-009 duplicate refund event detected
POSADP-DUPLICATE-010 idempotency key missing

Example diagnostic message:

POSADP-DUPLICATE-003 duplicate KDS release prevented.
The order already has a KDS release event.
Action: ignore duplicate release request and create audit record.

---

## **25\. POSADP-CONFLICT Error Codes**

Conflict domain errors relate to contradictory states across POS, Payment Runtime, KDS, customer display, or manual observation.

Recommended initial codes:

POSADP-CONFLICT-001 order status conflict
POSADP-CONFLICT-002 payment status conflict
POSADP-CONFLICT-003 kitchen status conflict
POSADP-CONFLICT-004 table reference conflict
POSADP-CONFLICT-005 item mapping conflict
POSADP-CONFLICT-006 provider event conflict
POSADP-CONFLICT-007 manual confirmation conflicts with provider state
POSADP-CONFLICT-008 customer display state conflicts with payment runtime
POSADP-CONFLICT-009 KDS state conflicts with POS cancellation
POSADP-CONFLICT-010 source conflict review required

Example diagnostic message:

POSADP-CONFLICT-002 payment status conflict.
POS says paid, but Payment Runtime does not confirm payment.
Action: hold authority-sensitive transitions and create reconciliation case.

---

## **26\. POSADP-FALLBACK Error Codes**

Fallback domain errors relate to manual or degraded operation.

Recommended initial codes:

POSADP-FALLBACK-001 fallback mode activated
POSADP-FALLBACK-002 manual order entry used
POSADP-FALLBACK-003 manual payment confirmation used
POSADP-FALLBACK-004 manual kitchen recovery used
POSADP-FALLBACK-005 fallback evidence incomplete
POSADP-FALLBACK-006 fallback reconciliation required
POSADP-FALLBACK-007 provider outage fallback active
POSADP-FALLBACK-008 device failure fallback active
POSADP-FALLBACK-009 fallback-originated state cannot close normally
POSADP-FALLBACK-010 fallback ended, reconciliation pending

Example diagnostic message:

POSADP-FALLBACK-005 fallback evidence incomplete.
Manual fallback was used but required evidence is missing.
Action: prevent silent closure and require manager review.

---

## **27\. POSADP-SECURITY Error Codes**

Security domain errors relate to credential, signature, permission, access, or data exposure.

Recommended initial codes:

POSADP-SECURITY-001 credential missing
POSADP-SECURITY-002 credential invalid
POSADP-SECURITY-003 credential scope too broad
POSADP-SECURITY-004 webhook signature invalid
POSADP-SECURITY-005 unauthorized provider operation attempted
POSADP-SECURITY-006 tenant isolation violation suspected
POSADP-SECURITY-007 store credential used outside allowed scope
POSADP-SECURITY-008 customer data exposure risk
POSADP-SECURITY-009 secret rotation required
POSADP-SECURITY-010 production credential used in test mode

Example diagnostic message:

POSADP-SECURITY-004 webhook signature invalid.
The webhook cannot be trusted.
Action: reject event, preserve payload reference, alert support.

---

## **28\. POSADP-REPLAY Error Codes**

Replay domain errors relate to projection rebuild, event replay, and state reconstruction.

Recommended initial codes:

POSADP-REPLAY-001 replay requested
POSADP-REPLAY-002 replay blocked by missing raw payload
POSADP-REPLAY-003 replay produced conflict
POSADP-REPLAY-004 replay projection differs from current projection
POSADP-REPLAY-005 replay cannot resolve authority state
POSADP-REPLAY-006 replay skipped duplicate event
POSADP-REPLAY-007 replay requires adapter version pinning
POSADP-REPLAY-008 replay requires reconciliation approval
POSADP-REPLAY-009 replay completed with warnings
POSADP-REPLAY-010 replay must not mutate source events

Example diagnostic message:

POSADP-REPLAY-010 replay must not mutate source events.
Replay may rebuild projection but cannot rewrite historical provider or audit events.

---

## **29\. POSADP-AUDIT Error Codes**

Audit domain errors relate to missing, incomplete, or inconsistent audit trail.

Recommended initial codes:

POSADP-AUDIT-001 audit event missing
POSADP-AUDIT-002 audit reference missing
POSADP-AUDIT-003 audit event write failed
POSADP-AUDIT-004 audit event incomplete
POSADP-AUDIT-005 audit chain discontinuity detected
POSADP-AUDIT-006 authority action without audit event
POSADP-AUDIT-007 fallback action without evidence packet
POSADP-AUDIT-008 reconciliation conclusion missing
POSADP-AUDIT-009 raw payload not linked to audit
POSADP-AUDIT-010 audit append-only rule violated

Example diagnostic message:

POSADP-AUDIT-006 authority action without audit event.
An authority-sensitive state transition occurred without required audit record.
Action: create incident, block automatic closure.

---

## **30\. Message Structure**

Each diagnostic message should follow a consistent structure.

Recommended structure:

\[error\_code\] \[short title\]
Cause: what triggered the error.
Impact: what may be affected.
Action: what should happen next.
Context: key references.

Example:

\[POSADP-PAY-003\] payment amount mismatch
Cause: provider paid amount differs from internal order amount.
Impact: KDS release is blocked until review.
Action: create reconciliation case and request manager confirmation.
Context: order=O-10294, provider=TOSS, amount\_expected=18000, amount\_paid=17000.

---

## **31\. Store-Facing Message Rule**

Store-facing messages must be short and actionable.

Example store-facing messages:

결제 금액이 주문 금액과 다릅니다. 직원 확인이 필요합니다.
POS 주문 정보가 부족해 주방 전달을 보류했습니다.
이미 처리된 주문 이벤트입니다. 중복 조리는 발생하지 않았습니다.
결제 확인이 지연되고 있습니다. 수동 확인 전까지 주방 전달이 보류됩니다.
외부 POS 연결이 지연되고 있습니다. 임시 처리 후 사후 확인이 필요합니다.

Store-facing messages should not include raw stack traces, secrets, or provider credentials.

---

## **32\. Developer-Facing Message Rule**

Developer-facing messages may include technical context.

Developer-facing messages may include:

adapter\_name
adapter\_version
provider\_payload\_version
external\_event\_id
payload\_hash
normalization\_rule\_version
capability\_level
source\_confidence
idempotency\_key
raw\_payload\_reference

Developer-facing messages must still avoid secrets and unmasked sensitive data.

---

## **33\. Customer-Facing Message Rule**

Most POS adapter errors should not be shown directly to customers.

Customer-facing messages should be translated into simple guidance.

Examples:

결제 확인 중입니다. 잠시만 기다려 주세요.
결제가 완료되지 않았습니다. 다시 시도해 주세요.
직원 확인이 필요합니다.
주문 확인 중입니다.

Customer messages must not show:

POSADP error code
webhook failure
signature failure
provider payload error
internal order conflict
KDS release block reason

unless a future support flow explicitly allows safe reference codes.

---

## **34\. Error Lifecycle**

Each error should follow a lifecycle.

Allowed lifecycle states include:

DETECTED
LOGGED
NOTIFIED
ACTION\_REQUIRED
MITIGATED
RECONCILIATION\_REQUIRED
RESOLVED
CLOSED\_WITH\_EXCEPTION
IGNORED\_AS\_DUPLICATE

An error affecting authority must not move directly from `DETECTED` to `RESOLVED` without audit and reconciliation.

---

## **35\. Error Deduplication**

The system must avoid flooding staff and support teams with repeated identical errors.

Deduplication may use:

error\_code
tenant\_id
store\_id
adapter\_name
external\_provider\_name
external\_order\_id
external\_event\_id
internal\_order\_id
payload\_hash
time\_window

Deduplication must not hide distinct authority-impacting errors.

Repeated errors may create an aggregated incident.

---

## **36\. Error Aggregation**

Repeated adapter errors may be aggregated into incident-level records.

Aggregation examples:

provider webhook delay affecting multiple orders
item mapping failure affecting one menu version
credential failure affecting one store
provider outage affecting all stores using one adapter
table mapping issue affecting one floor plan

Aggregated incidents must preserve links to individual affected orders and events.

---

## **37\. Recommended Action Types**

Each error should define a recommended action type.

Allowed recommended action types include:

IGNORE\_DUPLICATE
RETRY\_PROVIDER\_QUERY
RETRY\_WEBHOOK\_VERIFICATION
REQUEST\_MANAGER\_CONFIRMATION
BLOCK\_KDS\_RELEASE
HOLD\_PAYMENT\_STATUS
CREATE\_RECONCILIATION\_CASE
CREATE\_EVIDENCE\_PACKET
REISSUE\_PAYMENT\_REQUEST
REMAP\_MENU\_ITEM
DOWNGRADE\_CAPABILITY
ACTIVATE\_FALLBACK
CONTACT\_VENDOR\_SUPPORT
ESCALATE\_HQ\_SUPPORT

Recommended action is guidance.

Authority must still follow policy boundary.

---

## **38\. Fallback Trigger Rule**

Some error codes may trigger fallback automatically or recommend fallback.

Fallback may be triggered by:

provider unavailable
credential failure
webhook missing
payment status unknown
KDS bridge unavailable
manual order required
device failure
capability downgraded

Fallback-triggered events must be marked:

FALLBACK\_ORIGINATED

Fallback must not hide the original error.

---

## **39\. Audit Requirements**

Every error event must be auditable.

Audit should record:

error\_code
severity
audience
detected\_at
detected\_by
adapter\_name
provider\_name
internal\_order\_id
external\_order\_id
external\_event\_id
authority\_impact
customer\_impact
kitchen\_impact
payment\_impact
recommended\_action
lifecycle\_state
raw\_payload\_reference

Errors that affect payment, kitchen release, refund, settlement, or fallback must always create append-only audit records.

---

## **40\. MVP Cutline**

For MVP, the system should support:

structured error code format
error domain
severity level
audience level
basic context fields
authority impact
customer impact
kitchen impact
payment impact
recommended action
audit event creation
duplicate error suppression
store-facing safe message
developer-facing diagnostic message

Initial MVP domains should include:

ORDER
PAY
KDS
MAP
WEBHOOK
TIME
CAP
AUTH
PROVIDER
CONFLICT
FALLBACK
AUDIT

Excluded from MVP:

full vendor-facing support portal
automatic root-cause AI
cross-provider error prediction
advanced anomaly clustering
automatic compensation recommendation
legal evidence packaging
multi-language diagnostic engine

---

## **41\. Relationship To 04300, 04310, And 04320**

Document 04300 defines the POS Provider Abstraction and Multi-POS Adapter boundary.

Document 04310 defines the Canonical Order Model and POS Event Normalization policy.

Document 04320 defines POS Adapter Capability Level and Integration Contract policy.

This document defines how adapter and normalization failures are named, classified, explained, and acted upon.

The relationship is:

04300 \= adapter layer exists
04310 \= adapter output is normalized
04320 \= adapter capability is classified
04330 \= adapter failures are diagnosable

Without 04330, multi-POS integration becomes a black box.

---

## **42\. Patent And SaaS Relevance**

This policy supports SaaS scalability because POS integration failures become standardized operational events.

The strategic value is not only connecting to many POS providers.

The value is:

many POS providers
many error patterns
many store environments
        ↓
one diagnostic language
        ↓
faster debugging
safer kitchen release
better vendor support
stronger audit trail
repeatable onboarding

This creates a technical and operational advantage over one-off POS integrations.

---

## **43\. Readiness Check**

This policy is ready when:

each POS adapter error has a stable code
each error belongs to a domain
each error has severity
each error has intended audience
each error has recommended action
authority impact is classified
customer impact is classified
kitchen impact is classified
payment impact is classified
store-facing messages are safe
developer-facing messages are detailed
customer-facing messages hide internals
duplicate errors are controlled
fallback triggers preserve original error
audit records link error to order and provider event

---

## **44\. Summary**

A multi-POS system cannot survive with vague error messages.

The system must turn POS failures into structured, searchable, actionable diagnostic events.

The goal is not merely to say:

POS 연동 오류

The goal is to say:

POSADP-PAY-002 payment status conflict
Cause: POS says paid, Payment Runtime does not confirm payment.
Impact: KDS release blocked.
Action: create reconciliation case.

This makes the system debuggable, auditable, and scalable.

A POS adapter platform wins not only by connecting to many providers, but by making every failure understandable.
