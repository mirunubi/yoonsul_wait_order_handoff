# 011260_Policy_POS_Provider_Adapter_Contract_And_Capability_Declaration

Legacy path: $old.

1\. Purpose

This document defines the POS Provider Adapter Contract and Capability Declaration policy for CatchMenu / Wait Order Handoff.

CatchMenu must integrate with external POS providers through provider-specific adapters, but CatchMenu service logic must remain provider-neutral.

Every POS provider differs in API structure, authentication, menu model, table model, order model, callback behavior, idempotency support, status sync, payment reference support, failure behavior, and certification requirements.

Therefore, each POS provider must declare its supported capabilities before CatchMenu enables integration features for a merchant store.

Core purpose:

Define POS provider adapter contract.
Define provider capability declaration.
Define provider-specific adapter boundary.
Define provider-neutral CatchMenu contract.
Define capability-driven feature enablement.
Define unsupported capability handling.
Define provider onboarding evidence.
Prevent unsupported POS claims.
Prevent provider-specific API leakage into CatchMenu business logic.

Korean purpose:

POS 제공사 adapter 계약을 정의한다.
제공사 capability declaration을 정의한다.
제공사별 adapter 경계를 정의한다.
CatchMenu의 제공사 중립 계약을 정의한다.
지원 기능 기반 feature enablement를 정의한다.
지원하지 않는 기능 처리 방식을 정의한다.
제공사 온보딩 증빙을 정의한다.
지원되지 않는 POS 기능에 대한 과장 설명을 방지한다.
제공사별 API 차이가 CatchMenu 비즈니스 로직으로 새는 것을 방지한다.

2\. Scope

This document covers:

POS provider adapter
provider-neutral contract
provider capability declaration
provider onboarding evidence
capability-driven feature control
store-scoped capability
adapter status
adapter version
credential reference
API scope
callback support
webhook support
idempotency support
menu capability
table capability
order capability
payment reference capability
status sync capability
manual fallback requirement

This document does not define:

provider-specific source code
actual secret value
full provider certification contract
payment provider settlement
KDS ticket execution
menu mapping detail
table mapping detail
order idempotency detail
callback replay detail

Related documents:

03500\_External\_POS\_Integration\_Runtime\_Readme.md
03510\_POS\_Integration\_Module\_And\_All\_POS\_Expansion\_Strategy.md
011270_Policy_POS_Menu_Table_Order_Mapping_And_Idempotency.md
011070_Policy_POS_Callback_Replay_Manual_Fallback_And_Evidence.md
03400\_Provider\_Adapter\_Runtime\_Readme.md
03600\_Billing\_Plan\_Settlement\_Readme.md

3\. Core Principle

CatchMenu must enable POS features based on declared and verified provider capabilities.

Core rule:

No declared capability, no enabled POS feature.
No verified provider contract, no merchant-facing POS promise.

Korean rule:

선언된 capability가 없으면 POS 기능을 활성화하지 않는다.
검증된 제공사 계약이 없으면 매장에 POS 기능을 약속하지 않는다.

4\. Provider Adapter Contract

Provider Adapter Contract defines how CatchMenu talks to external POS providers through an adapter.

Adapter contract should cover:

provider identity
adapter version
supported capability set
credential reference method
store binding method
menu import/export contract
table import/export contract
order handoff contract
order status contract
payment reference contract
callback/webhook contract
error mapping contract
retry/replay contract
manual fallback contract
audit/event contract

Core rule:

Adapter contract must be stable even when provider API changes.

5\. Provider-Neutral Contract

CatchMenu internal runtime should use provider-neutral concepts.

Provider-neutral concepts:

pos\_provider
pos\_store\_binding
pos\_capability
pos\_menu\_mapping
pos\_table\_mapping
pos\_order\_handoff\_candidate
pos\_order\_handoff\_result
pos\_callback\_event
pos\_replay\_event
manual\_pos\_fallback\_event
pos\_evidence\_packet

Core rule:

CatchMenu service logic must depend on provider-neutral concepts.

6\. Provider-Specific Adapter Boundary

Provider-specific adapter may know provider details.

Provider details may include:

provider authentication method
provider channel key
provider API endpoint
provider menu schema
provider table schema
provider order schema
provider status code
provider error code
provider callback signature
provider retry rule
provider rate limit
provider sandbox behavior

Provider-specific adapter must not own:

CatchMenu request truth
reservation truth
billing entitlement
support case finality
audit finality
merchant success status
KDS execution truth

Core rule:

Adapter translates provider details.
CatchMenu owns service meaning.

7\. Capability Declaration

Every POS provider must declare supported capabilities.

Suggested capability groups:

MENU\_CAPABILITY
TABLE\_CAPABILITY
ORDER\_CAPABILITY
PAYMENT\_REFERENCE\_CAPABILITY
STATUS\_SYNC\_CAPABILITY
CALLBACK\_CAPABILITY
IDEMPOTENCY\_CAPABILITY
REPLAY\_CAPABILITY
CREDENTIAL\_CAPABILITY
SANDBOX\_CAPABILITY
MANUAL\_FALLBACK\_CAPABILITY

Core rule:

Capability declaration is the gate before integration mode activation.

8\. Capability Values

Suggested capability values:

UNSUPPORTED
SUPPORTED
PARTIAL
PROVIDER\_LIMITED
STORE\_LIMITED
PILOT\_ONLY
REQUIRES\_CERTIFICATION
REQUIRES\_MANUAL\_FALLBACK
UNKNOWN

Meaning:

UNSUPPORTED
\= provider does not support this capability

SUPPORTED
\= provider supports this capability in verified condition

PARTIAL
\= provider supports only part of the capability

PROVIDER\_LIMITED
\= provider supports with provider-level limitation

STORE\_LIMITED
\= capability depends on store configuration

PILOT\_ONLY
\= capability allowed only for pilot stores

REQUIRES\_CERTIFICATION
\= capability requires certification before use

REQUIRES\_MANUAL\_FALLBACK
\= capability cannot be fully automated

UNKNOWN
\= not verified yet

Core rule:

UNKNOWN must behave as unsupported for merchant-facing operation.

9\. Menu Capability

Menu capability may include:

MENU\_IMPORT
MENU\_EXPORT
MENU\_SYNC
CATEGORY\_SYNC
ITEM\_SYNC
PRICE\_SYNC
OPTION\_GROUP\_SYNC
MODIFIER\_SYNC
SOLD\_OUT\_SYNC
MENU\_VERSION\_REFERENCE

Capability notes should define:

sync direction
sync frequency
manual review requirement
mapping requirement
unsupported field
conflict behavior

Core rule:

Menu capability must be verified before automated menu mapping is trusted.

10\. Table Capability

Table capability may include:

TABLE\_IMPORT
TABLE\_SYNC
ZONE\_SYNC
SEAT\_COUNT\_SYNC
TABLE\_STATUS\_SYNC
TABLE\_MERGE\_SUPPORT
TABLE\_SPLIT\_SUPPORT
TABLE\_MOVE\_SUPPORT

Core rule:

Table-based handoff requires verified table capability or explicit manual fallback.

11\. Order Capability

Order capability may include:

ORDER\_HANDOFF\_CANDIDATE
ORDER\_INJECTION
ORDER\_ACCEPTANCE
ORDER\_REJECTION
ORDER\_CANCEL
ORDER\_MODIFY
ORDER\_STATUS\_SYNC
ORDER\_NOTE\_SUPPORT
OPTION\_SUPPORT
DUPLICATE\_PROTECTION

Core rule:

Order injection must not be enabled unless order capability is verified.

12\. Payment Reference Capability

Payment reference capability may include:

PAYMENT\_STATUS\_REFERENCE
RECEIPT\_REFERENCE
TRANSACTION\_REFERENCE
CANCEL\_REFERENCE
REFUND\_REFERENCE
SETTLEMENT\_REFERENCE

Payment reference is not billing finality.

Core rule:

Payment reference capability provides provider fact, not CatchMenu billing decision.

13\. Status Sync Capability

Status sync capability may include:

ORDER\_STATUS\_SYNC
TABLE\_STATUS\_SYNC
PAYMENT\_STATUS\_SYNC
CANCEL\_STATUS\_SYNC
PROVIDER\_HEALTH\_SYNC

Core rule:

Status sync must be treated as provider fact with timestamp and source.

14\. Callback And Webhook Capability

Callback capability may include:

WEBHOOK\_SUPPORTED
CALLBACK\_SUPPORTED
SIGNATURE\_SUPPORTED
EVENT\_ID\_SUPPORTED
TIMESTAMP\_SUPPORTED
RETRY\_SUPPORTED
CALLBACK\_REPLAY\_SUPPORTED

Core rule:

Callback support must be validated before callbacks can update integration references.

15\. Idempotency Capability

Idempotency capability may include:

CLIENT\_IDEMPOTENCY\_KEY\_SUPPORTED
PROVIDER\_IDEMPOTENCY\_KEY\_SUPPORTED
DUPLICATE\_ORDER\_PREVENTION
DUPLICATE\_CALLBACK\_PREVENTION
RETRY\_SAFE\_ORDER\_CREATE

Core rule:

No idempotency assurance, no unsafe automatic retry.

16\. Replay Capability

Replay capability may include:

MANUAL\_REPLAY
SYSTEM\_REPLAY
PROVIDER\_REPLAY
CALLBACK\_REPLAY
PAYLOAD\_REPLAY
STATUS\_RECHECK

Core rule:

Replay must be append-only and evidence-backed.

17\. Credential Capability

Credential capability may include:

API\_KEY
CHANNEL\_KEY
OAUTH
STORE\_TOKEN
PARTNER\_TOKEN
DEVICE\_BINDING
CERTIFICATE
MANUAL\_CREDENTIAL\_ENTRY

Credential must be stored or referenced securely.

Core rule:

Credential reference is allowed.
Secret exposure is prohibited.

18\. Sandbox Capability

Sandbox capability may include:

SANDBOX\_AVAILABLE
TEST\_STORE\_AVAILABLE
TEST\_MENU\_AVAILABLE
TEST\_ORDER\_AVAILABLE
TEST\_CALLBACK\_AVAILABLE
TEST\_PAYMENT\_REFERENCE\_AVAILABLE

Core rule:

Provider integration without sandbox requires stricter pilot control.

19\. Manual Fallback Capability

Manual fallback capability declares what must be handled manually.

Manual fallback areas:

manual menu mapping
manual table mapping
manual POS entry
manual order confirmation
manual payment reference
manual cancellation
manual refund reference
manual support confirmation

Core rule:

Manual fallback requirement must be visible before merchant operation.

20\. Store-Scoped Capability

Provider capability may not be identical across stores.

A provider may support a feature, but a specific merchant store may not be configured for it.

Store-scoped capability may depend on:

store subscription
POS version
device model
provider plan
credential scope
channel key setting
table layout setup
menu configuration
certification state

Core rule:

Provider-level support does not equal store-level readiness.

21\. Adapter Status

Suggested adapter statuses:

NOT\_STARTED
DISCOVERY
DESIGN
SANDBOX\_TESTING
PILOT\_READY
PILOT\_ACTIVE
CERTIFICATION\_REQUIRED
PRODUCTION\_READY
PRODUCTION\_ACTIVE
DEGRADED
SUSPENDED
DEPRECATED

Core rule:

Adapter status must control rollout eligibility.

22\. Capability Verification Status

Suggested verification statuses:

UNVERIFIED
DOCUMENTED
SANDBOX\_VERIFIED
PILOT\_VERIFIED
PRODUCTION\_VERIFIED
REGRESSION\_REQUIRED
FAILED\_VERIFICATION

Core rule:

Capability must move from documented to verified before broad rollout.

23\. Provider Onboarding Evidence

Provider onboarding evidence may include:

provider documentation
API access approval
sandbox account
test credential reference
menu test result
table test result
order handoff test result
callback validation result
failure/retry test result
manual fallback test result
commercial approval
security review
support runbook
billing impact review

Core rule:

Provider onboarding must be evidence-backed.

24\. Capability Change Management

Provider capabilities may change.

Capability change may occur due to:

provider API update
provider deprecation
provider plan change
store POS version change
credential scope change
security change
commercial contract change
callback behavior change

Capability changes must be audited.

Core rule:

Capability change must not silently alter merchant operation.

25\. Unsupported Capability Handling

If a capability is unsupported:

do not enable dependent feature
use manual fallback if safe
show integration limitation to authorized users
emit support signal if merchant expects feature
avoid sales claim
record limitation

Core rule:

Unsupported capability must become visible limitation, not hidden failure.

26\. Partial Capability Handling

If a capability is partial:

document limitation
restrict feature scope
require manual review
mark store/provider limitation
prevent full automation claim
monitor support burden

Core rule:

Partial support must not be sold as full support.

27\. Pilot-Only Capability Handling

Pilot-only capabilities may be enabled for selected stores.

Pilot must define:

pilot store
provider
capability
risk
rollback
support owner
duration
success criteria
failure criteria

Core rule:

Pilot capability must not become general availability by accident.

28\. Capability-Driven Integration Mode

Integration mode should be derived from capability.

Examples:

ORDER\_INJECTION unsupported
→ use POS\_ORDER\_HANDOFF\_CANDIDATE or MANUAL\_POS\_ENTRY

TABLE\_SYNC unsupported
→ use manual table mapping

CALLBACK unsupported
→ require manual status check or polling if available

IDEMPOTENCY unsupported
→ restrict automatic retry

PAYMENT\_REFERENCE\_SYNC unsupported
→ do not show payment reference sync

Core rule:

Integration mode must respect capability declaration.

29\. Provider Risk Level

Suggested provider risk levels:

LOW
MEDIUM
HIGH
CRITICAL

Risk factors:

poor documentation
no sandbox
weak callback validation
no idempotency
high support burden
unstable API
unclear commercial terms
credential handling risk
pilot failures

Core rule:

Provider risk must influence rollout and sales claims.

30\. Field Claim Boundary

Field and support teams must use capability-backed wording.

Allowed:

This POS provider is supported for specific capabilities.
This store can use the enabled integration mode.
Some features may require mapping or manual fallback.

Not allowed:

This POS supports everything.
All stores using this POS are automatically connected.
Order, payment, table, and KDS are all fully synced.
No setup or mapping is required.

Korean allowed:

이 POS 제공사는 특정 기능 범위에서 지원됩니다.
해당 매장은 활성화된 integration mode 안에서 사용할 수 있습니다.
일부 기능은 매핑이나 수동 fallback이 필요할 수 있습니다.

Core rule:

Claims must follow verified capability, not provider brand name.

31\. Audit Events

Recommended audit events:

POS\_ADAPTER\_CONTRACT\_CREATED
POS\_ADAPTER\_CONTRACT\_UPDATED
POS\_PROVIDER\_CAPABILITY\_DECLARED
POS\_PROVIDER\_CAPABILITY\_UPDATED
POS\_CAPABILITY\_VERIFIED
POS\_CAPABILITY\_VERIFICATION\_FAILED
POS\_STORE\_CAPABILITY\_ASSIGNED
POS\_STORE\_CAPABILITY\_CHANGED
POS\_ADAPTER\_STATUS\_CHANGED
POS\_PROVIDER\_ONBOARDING\_EVIDENCE\_ADDED
POS\_UNSUPPORTED\_CAPABILITY\_BLOCKED
POS\_PARTIAL\_CAPABILITY\_LIMITED
POS\_PILOT\_CAPABILITY\_ENABLED
POS\_PILOT\_CAPABILITY\_DISABLED

Minimum audit fields:

event\_id
provider\_id
adapter\_id
merchant\_store\_id optional
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

32\. Failure Events

Example failure codes:

WOH.POS.ADAPTER.CONTRACT\_REQUIRED
WOH.POS.ADAPTER.STATUS\_NOT\_READY
WOH.POS.CAPABILITY.UNDECLARED
WOH.POS.CAPABILITY.UNVERIFIED
WOH.POS.CAPABILITY.UNSUPPORTED
WOH.POS.CAPABILITY.PARTIAL\_LIMITATION\_REQUIRED
WOH.POS.CAPABILITY.STORE\_SCOPE\_REQUIRED
WOH.POS.PROVIDER.ONBOARDING\_EVIDENCE\_REQUIRED
WOH.POS.PROVIDER.SANDBOX\_REQUIRED
WOH.POS.PROVIDER.RISK\_HIGH

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

33\. Support Signals

Support signals may include:

POS\_CAPABILITY\_UNDECLARED
POS\_CAPABILITY\_UNVERIFIED
POS\_CAPABILITY\_UNSUPPORTED\_FOR\_STORE
POS\_ADAPTER\_NOT\_READY
POS\_PROVIDER\_ONBOARDING\_INCOMPLETE
POS\_PILOT\_ONLY\_CAPABILITY\_REQUESTED
POS\_PARTIAL\_SUPPORT\_RISK
POS\_FIELD\_CLAIM\_REVIEW\_REQUIRED

Support Signal alerts.

It does not enable capability by itself.

34\. Relationship To POS Mapping And Idempotency

Capability declaration controls whether mapping and idempotency policies can be used.

For example:

MENU\_SYNC supported
→ menu mapping may be automated or semi-automated

ORDER\_INJECTION supported
→ idempotent order handoff may be enabled

IDEMPOTENCY unsupported
→ automatic retry must be restricted

TABLE\_SYNC unsupported
→ manual table mapping required

Core rule:

Mapping and idempotency depend on capability truth.

35\. Relationship To Callback Replay Manual Fallback

Callback, replay, and manual fallback behavior depends on declared capability.

Core rule:

Provider capability determines recovery path.

36\. Relationship To Billing

Some capabilities may become paid add-ons.

Examples:

ORDER\_INJECTION
ORDER\_STATUS\_SYNC
PAYMENT\_REFERENCE\_SYNC
ADVANCED\_POS\_SYNC
CUSTOM\_PROVIDER\_ADAPTER

Billing may charge only when entitlement and capability allow.

Core rule:

Billable POS feature requires both entitlement and capability.

37\. MVP Requirements

MVP should support at least:

provider adapter registry
adapter status
provider capability declaration
capability value
capability verification status
store-scoped capability override
unsupported capability blocker
manual fallback indicator
audit event
failure event
support signal
field claim boundary

MVP may defer:

automated provider certification
advanced sandbox runner
automatic capability test suite
provider risk scoring model
multi-region provider matrix
full adapter version lifecycle automation

38\. Suggested Conceptual Entities

Suggested entities:

pos\_provider\_adapters
pos\_adapter\_contracts
pos\_provider\_capabilities
pos\_capability\_verifications
pos\_store\_capabilities
pos\_provider\_onboarding\_evidence
pos\_adapter\_status\_events
pos\_capability\_audit\_events
pos\_capability\_failure\_events
pos\_capability\_support\_signals

This document defines policy.

Actual schema may be designed later.

39\. Risk If Skipped

If POS Provider Adapter Contract and Capability Declaration policy is skipped, risks include:

provider-specific logic leaks into core service
unsupported features are enabled
field sales overclaims integration
merchant expects unavailable POS functions
store-level readiness is confused with provider-level support
callbacks mutate state unsafely
manual fallback is not prepared
billing charges unsupported POS features
support cannot diagnose provider limitation
all-POS expansion becomes chaotic

Therefore, every POS provider must pass through adapter contract and capability declaration before merchant rollout.

40\. Final Rule

POS provider integration must be capability-driven and adapter-bounded.

Final rule:

Define adapter contract.
Keep CatchMenu provider-neutral.
Keep provider details inside adapter.
Declare capabilities.
Verify capabilities.
Scope capabilities by store.
Treat unknown as unsupported.
Block unsupported features.
Limit partial features.
Pilot risky capabilities.
Control field claims.
Audit capability changes.
Use capability truth to guide mapping, handoff, callback, replay, fallback, billing, and support.
