# 004360_Policy_POS_Provider_Onboarding_Evidence_And_Contract_Checklist

## **1\. Purpose**

This document defines the POS provider onboarding evidence and contract checklist policy.

The purpose of this policy is to ensure that each POS, payment, table order, kiosk, delivery, or external provider integration is onboarded with clear evidence, contract scope, credential control, capability classification, and operational fallback.

A provider must not be connected to production store operation based only on verbal agreement, incomplete documentation, or a successful local test.

Every provider onboarding must leave an auditable evidence trail.

---

## **2\. Scope**

This policy applies to:

* POS provider onboarding
* Payment provider onboarding
* Table order provider onboarding
* Kiosk provider onboarding
* Delivery order provider onboarding
* External order channel onboarding
* API documentation review
* Webhook documentation review
* Credential issuance
* Integration contract review
* Capability level assignment
* Security and permission review
* Test environment review
* Store pilot approval
* Production enablement checklist

This policy does not define commercial pricing, revenue share, final legal contract wording, tax filing, refund approval, settlement allocation, or customer compensation.

---

## **3\. Core Principle**

Provider onboarding must be evidence-based.

The system must not treat a provider as ready because:

a salesperson said API exists
one store already uses the provider
one test order succeeded
documentation looked simple
another vendor claims integration exists

The system may treat a provider as onboarded only when:

documentation is reviewed
capability is classified
contract scope is recorded
credentials are scoped
test scenarios are passed
fallback is defined
audit path is verified
production readiness is approved

---

## **4\. Provider Onboarding Status**

Each provider must have a clear onboarding status.

Allowed statuses include:

CANDIDATE
RESEARCHING
DOCUMENTATION\_REQUESTED
DOCUMENTATION\_RECEIVED
API\_REVIEW
CONTRACT\_REVIEW
SECURITY\_REVIEW
TECHNICAL\_SPIKE
SANDBOX\_TESTING
ADAPTER\_DEVELOPMENT
CERTIFICATION\_TESTING
PILOT\_READY
PILOT\_RUNNING
PRODUCTION\_READY
PRODUCTION\_ENABLED
DEFERRED
BLOCKED
RETIRED

Status changes must be auditable.

---

## **5\. Provider Identity Record**

Each provider onboarding must create a provider identity record.

Required fields include:

provider\_id
provider\_name
provider\_type
provider\_category
country\_or\_market
primary\_contact
support\_contact
developer\_contact
documentation\_url\_or\_reference
contract\_reference
onboarding\_status
created\_at
updated\_at
owner

Provider type may include:

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

---

## **6\. Required Documentation Checklist**

Before technical integration begins, the following documents should be collected or confirmed:

API documentation
webhook documentation
authentication documentation
rate limit documentation
sandbox documentation
production credential process
event type list
payload examples
error code reference
order model description
payment model description
cancellation model description
refund visibility description
table model description
menu model description
support escalation guide

If any required documentation is unavailable, the provider must be marked:

DOCUMENTATION\_INCOMPLETE

---

## **7\. API Capability Checklist**

The provider API must be reviewed for:

order read support
order create support
order update support
order cancellation support
item void support
payment status support
refund status support
table reference support
menu read support
menu sync support
sold-out sync support
KDS event support
webhook support
polling support
raw event access
replay or backfill support

Each capability must be marked:

SUPPORTED
PARTIALLY\_SUPPORTED
NOT\_SUPPORTED
UNKNOWN
REQUIRES\_CONTRACT

---

## **8\. Webhook Checklist**

If webhook is supported, the onboarding review must capture:

supported event types
webhook registration method
signature verification method
secret rotation process
retry behavior
duplicate delivery behavior
delivery timeout
event ordering guarantee
test webhook support
webhook failure notification
provider IP allowlist if any
payload versioning rule

If webhook verification cannot be confirmed, the provider must not be treated as high-confidence event sync.

---

## **9\. Polling Checklist**

If webhook is unavailable or incomplete, polling may be reviewed.

Polling review must capture:

polling endpoint
minimum allowed interval
rate limits
pagination
query window
status query endpoint
event loss risk
backfill support
latency expectation
provider throttling behavior

Polling-based integration must be classified separately from real-time webhook integration.

Polling should not be marketed as instant unless the operational latency is acceptable and disclosed.

---

## **10\. Credential Checklist**

Provider credential onboarding must capture:

credential type
credential owner
tenant scope
store scope
terminal scope
permission scope
read permissions
write permissions
payment permissions
refund permissions
webhook secret
sandbox credential
production credential
rotation requirement
expiration date
revocation process

Credentials must follow least privilege.

A credential must not grant broader access than the integration level requires.

---

## **11\. Contract Scope Checklist**

The integration contract or agreement must define:

allowed read operations
allowed write operations
payment visibility rights
payment authority rights
refund visibility rights
refund authority rights
KDS status rights
table data rights
menu data rights
customer data rights
data retention rule
audit support rule
support responsibility
incident escalation path
provider maintenance notice path
termination or suspension rule

If contract scope is unclear, authority-level integration must be blocked.

---

## **12\. Data Protection Checklist**

Provider onboarding must review data protection risks.

Checklist:

customer personal data exposure
payment data exposure
staff data exposure
table/session data exposure
order history retention
raw payload retention
log masking
credential storage
tenant isolation
store isolation
cross-store visibility
data deletion request handling

The system must not ingest unnecessary sensitive data when a smaller data scope is sufficient.

---

## **13\. Capability Level Assignment**

After documentation and contract review, the provider must receive an initial capability level.

Allowed levels:

LEVEL\_0\_MANUAL\_OR\_NO\_API
LEVEL\_1\_READ\_ONLY\_INTAKE
LEVEL\_2\_EVENT\_SYNC
LEVEL\_3\_OPERATIONAL\_AUTHORITY\_INTEGRATION
LEVEL\_4\_CERTIFIED\_DEEP\_INTEGRATION

Capability level must be assigned separately for:

order capability
payment capability
KDS capability
menu capability
table capability
refund capability
settlement visibility

A provider may be Level 2 for order events but only Level 1 for payment visibility.

---

## **14\. Evidence Packet For Provider Onboarding**

Each provider onboarding must create an evidence packet.

The packet should include:

provider identity record
documentation review notes
API capability checklist
webhook checklist
polling checklist
credential checklist
contract scope checklist
security review result
capability level decision
test harness result
certification result
pilot readiness approval
fallback plan
known limitations
audit references

The evidence packet must be preserved for future review.

---

## **15\. Known Limitation Record**

Each provider must have a known limitation record.

Examples:

no webhook support
polling only
no refund visibility
no item modifier detail
no table merge/split support
no sandbox environment
weak provider error messages
unclear payment status mapping
rate limit too low for real-time sync
vendor contract required for write access

Known limitations must be visible to engineering, support, and deployment teams.

---

## **16\. Sandbox Requirement**

Before production, the provider should be tested in one of:

provider sandbox
test merchant account
mock provider server
recorded payload replay
shadow mode pilot

If no sandbox exists, the provider must be marked:

NO\_SANDBOX\_AVAILABLE

and the pilot must be narrower.

The absence of sandbox increases operational risk.

---

## **17\. Adapter Development Readiness**

Adapter development may begin when:

provider identity record exists
documentation is available or limitation accepted
capability target is defined
credential path is known
raw payload examples exist
test fixtures can be created
integration level is assigned
fallback expectation is clear

If these are missing, the provider should remain in research or technical spike status.

---

## **18\. Test Harness Entry Criteria**

Before test harness certification, the provider must have:

adapter version
fixture library
canonical mapping draft
error code mapping draft
capability level target
credential or mock credential
expected event list
known limitation record

Certification must not begin without a clear target level.

---

## **19\. Pilot Readiness Checklist**

Before store pilot, the provider must pass:

happy path test
payment failure test if payment-capable
duplicate event test
amount mismatch test if payment-capable
unknown item mapping test
provider outage test
manual fallback test
audit completeness test
store-facing message review
rollback plan review
support escalation review

Pilot readiness must be approved explicitly.

---

## **20\. Production Readiness Checklist**

Before production enablement, the provider must have:

pilot result reviewed
critical defects resolved
security review completed
credential rotation plan
monitoring enabled
error code mapping enabled
fallback policy enabled
audit chain verified
support path confirmed
rollback criteria defined
store-level configuration verified

Production readiness must be recorded.

---

## **21\. Store-Level Onboarding Checklist**

Provider onboarding is not complete at provider level alone.

Each store must also have a store-level onboarding record.

Required fields:

store\_id
tenant\_id
provider\_id
store\_provider\_account
terminal\_id\_or\_device\_id
credential\_scope
enabled\_capabilities
adapter\_version
menu\_mapping\_version
table\_mapping\_version
payment\_mapping\_version
pilot\_or\_production\_status
fallback\_mode
support\_contact
enabled\_at

A provider may be production-ready, but a specific store may still be pilot-only or read-only.

---

## **22\. Terminal And Device Checklist**

Some POS integrations depend on terminal or device version.

Store-level onboarding should capture:

terminal\_model
terminal\_version
POS software version
tablet version
printer version
KDS device version
network environment
local agent availability
LAN dependency
internet dependency

If terminal or device version is unknown, the store integration should be marked:

STORE\_DEVICE\_CONTEXT\_INCOMPLETE

---

## **23\. Menu Mapping Checklist**

Before KDS projection or kitchen execution, menu mapping must be reviewed.

Checklist:

external item IDs
external item names
internal menu item IDs
modifier groups
option IDs
bundle items
sold-out mapping
kitchen station mapping
recipe reference if needed
inactive item handling
unknown item fallback

Menu mapping gaps must be visible before production.

---

## **24\. Table Mapping Checklist**

For dine-in or table order providers, table mapping must be reviewed.

Checklist:

external table ID
external table name
internal table ID
seating session support
table move support
table merge support
table split support
floor or zone reference
unknown table fallback

If table mapping is weak, payment and kitchen flow must not depend on table certainty alone.

---

## **25\. Payment Mapping Checklist**

For payment-capable providers, payment mapping must be reviewed.

Checklist:

provider payment status list
internal payment status mapping
paid status definition
pending status definition
failed status definition
canceled status definition
refunded status visibility
partial payment support
amount mismatch behavior
duplicate payment behavior
webhook payment event support
manual confirmation fallback

Payment mapping must be approved before KDS release can depend on it.

---

## **26\. Cancellation And Refund Visibility Checklist**

Cancellation and refund must be separated.

Checklist:

order cancellation support
item void support
payment cancellation support
refund request visibility
refund completion visibility
partial refund support
cancellation after kitchen release
cancellation before kitchen release
provider cancellation reason
staff cancellation reason

The provider must not collapse cancellation, void, and refund into one internal state.

---

## **27\. Support And Escalation Checklist**

Provider onboarding must include support path.

Checklist:

provider technical support contact
provider business contact
emergency contact if available
support hours
expected response time if known
incident reporting channel
credential issue contact
webhook issue contact
API outage notice channel

If support path is unavailable, provider operational risk increases.

---

## **28\. Monitoring Requirement**

Before production, provider monitoring should be configured.

Monitoring should cover:

webhook success rate
webhook delay
polling failure
provider timeout
rate limit events
duplicate event rate
normalization failure rate
payment status conflict rate
KDS release block rate
manual fallback rate

Provider monitoring should map to 04330 diagnostic codes.

---

## **29\. Rollback Requirement**

Each provider integration must define rollback.

Rollback plan should include:

disable adapter
switch to read-only mode
switch to manual fallback
disable write operations
pause KDS release automation
preserve raw payload
preserve audit events
notify store support
reconcile affected orders

Rollback must not delete evidence of failed integration.

---

## **30\. Provider Change Management**

Provider APIs and payloads may change.

The onboarding record must track:

provider API version
payload version
adapter version
mapping version
contract version
last review date
change notice path
breaking change policy

If provider changes are detected, the adapter may require re-certification.

---

## **31\. Onboarding Decision Record**

Each major provider decision should have a decision record.

Decision record should include:

decision\_id
provider\_id
decision\_type
decision\_summary
reason
accepted\_risks
rejected\_options
capability\_level
fallback\_plan
approved\_by
approved\_at
review\_date

This prevents hidden assumptions from becoming production risks.

---

## **32\. Prohibited Onboarding Practices**

The following are prohibited:

production integration without provider identity record
using broad credentials without scope review
assuming write authority from read access
using payment status without mapping review
using KDS release from unverified provider event
skipping fallback plan
skipping audit link
hiding known limitations from deployment team
using one store pilot result as universal certification
treating vendor marketing claims as technical evidence

---

## **33\. MVP Cutline**

For MVP, provider onboarding should support:

provider identity record
provider status
documentation checklist
API capability checklist
credential checklist
contract scope checklist
capability level assignment
known limitation record
test result reference
pilot readiness checklist
store-level onboarding record
fallback plan
audit event creation

Excluded from MVP:

full vendor contract management system
automated legal review
partner portal
automated credential rotation
full security certification workflow
multi-country compliance automation
AI documentation parser
vendor SLA enforcement engine

---

## **34\. Relationship To 04300, 04310, 04320, 04330, 04340, And 04350**

Document 04300 defines the POS Provider Abstraction and Multi-POS Adapter boundary.

Document 04310 defines the Canonical Order Model and POS Event Normalization policy.

Document 04320 defines POS Adapter Capability Level and Integration Contract policy.

Document 04330 defines POS Adapter Error Code and Diagnostic Message policy.

Document 04340 defines POS Vendor Priority and Integration Roadmap policy.

Document 04350 defines POS Adapter Test Harness and Certification Scenario policy.

This document defines what evidence and checklist must exist before a provider can move from candidate to pilot or production.

The relationship is:

04300 \= adapter architecture
04310 \= canonical model
04320 \= capability and contract
04330 \= diagnostic language
04340 \= provider priority roadmap
04350 \= test and certification
04360 \= onboarding evidence and contract checklist

---

## **35\. Patent And SaaS Relevance**

This policy supports SaaS scalability because provider integrations become repeatable onboarding processes rather than custom one-off projects.

The strategic structure is:

provider candidate
        ↓
documentation review
        ↓
capability classification
        ↓
contract and credential scope
        ↓
test harness certification
        ↓
pilot readiness
        ↓
production onboarding
        ↓
monitoring and rollback

This creates a controlled path for adding many POS providers over several years.

The value is not only integration breadth.

The value is disciplined, evidence-based integration expansion.

---

## **36\. Readiness Check**

This policy is ready when:

provider identity record is required
provider status is tracked
documentation checklist exists
API capability checklist exists
webhook checklist exists
credential checklist exists
contract scope checklist exists
capability level is assigned
known limitations are recorded
test harness result is linked
pilot readiness checklist exists
production readiness checklist exists
store-level onboarding record exists
rollback plan is required
provider change management is tracked
audit records onboarding decisions

---

## **37\. Summary**

A POS provider must not be onboarded casually.

Every provider integration should leave evidence:

what was promised
what was documented
what was tested
what is allowed
what is blocked
what is risky
what fallback exists
who approved it

This is how the system can scale from one integration to many providers without becoming an unmanageable custom-integration project.

Provider onboarding is not a sales checklist.

It is an operational safety gate.
