03600 Billing Plan Settlement Readme

Legacy path: $old.

1\. Purpose

This folder defines Billing, Plan, Subscription, Entitlement, Fee, Settlement Reference, Dispute, and Revenue Governance for CatchMenu / Wait Order Handoff.

CatchMenu is a SaaS-style restaurant operating service that may serve small independent stores, medium restaurants, large stores, multi-store merchants, Yoonsul-affiliated stores, partner merchants, and future enterprise accounts.

Because merchant size, store count, POS provider, KDS integration, CMS usage, AI support level, reservation/preorder usage, advertising usage, partner channel cost, and contract condition may differ by merchant, CatchMenu billing must be flexible from the beginning.

CatchMenu billing must not be a single rigid plan only.

Core purpose:

Define CatchMenu billing governance.
Define service plans.
Define trial and paid conversion.
Define merchant subscription billing.
Define flexible billing architecture.
Define billing by merchant scale.
Define billing by provider and integration cost.
Define feature entitlement and add-on billing.
Define reservation, payment, refund, ad, partner, POS, KDS, CMS, and AI support billing references.
Define billing suspension, reactivation, evidence, audit, and dispute handling.
Separate billing decision from payment provider execution.

Korean purpose:

CatchMenu 과금 거버넌스를 정의한다.
서비스 요금제를 정의한다.
체험과 유료 전환을 정의한다.
고객사 구독 과금을 정의한다.
유연한 Billing 구조를 정의한다.
매장 규모별 과금 구조를 정의한다.
제공사 및 연동 비용별 과금 구조를 정의한다.
기능 권한과 add-on 과금을 정의한다.
예약, 결제, 환불, 광고, 제휴, POS, KDS, CMS, AI 지원 과금 참조를 정의한다.
과금 정지, 재활성화, 증빙, 감사, 분쟁 처리를 정의한다.
과금 판단과 결제 제공사 실행을 분리한다.

2\. Scope

This folder covers:

service plan
trial plan
paid plan
custom plan
subscription billing
merchant billing
billing account
feature entitlement
add-on billing
usage-based billing
store-count billing
Entry Plate fee reference
POS integration add-on
KDS integration add-on
CMS package
AI Menu Intake usage
AI customer center support level
reservation/preorder billing reference
deposit/payment/refund reference
ad revenue reference
promotion benefit reference
partner revenue share
alliance fee
billing suspension
service limitation
reactivation
invoice reference
billing evidence
billing audit
billing dispute

This folder does not define:

payment provider execution
card acquiring settlement
VAN settlement
PG internal settlement
full accounting ledger
tax filing
legal final contract text
reservation state machine
POS order state machine
KDS execution state machine
ad content review workflow
partner contract negotiation

Related folders:

docs/03100\_reservation\_preorder\_governance/
docs/03200\_ad\_promotion\_cms/
docs/03300\_open\_api\_partner\_alliance/
docs/03400\_provider\_adapter\_runtime/
docs/03500\_external\_pos\_integration\_runtime/
docs/03700\_sales\_partner\_field\_growth/
docs/03800\_native\_all\_in\_one\_service\_runtime/
docs/00400\_identity\_access/
docs/00500\_organization\_core/
docs/03000\_catchmenu\_hq/

3\. Core Principle

Billing must follow merchant reality.

Core rule:

Billing must be flexible by merchant, store, feature, usage, provider, partner, and contract.

Korean rule:

Billing은 고객사, 매장, 기능, 사용량, 제공사, 제휴, 계약 조건에 따라 유연하게 구성되어야 한다.

CatchMenu must allow low-cost entry for small merchants and expandable integrated billing for larger merchants.

4\. Billing Boundary

Billing Plan Settlement owns:

plan definition
plan version
trial-to-paid conversion
merchant subscription
billing account reference
invoice reference
feature entitlement
add-on entitlement
usage-based billing rule
billing-related service limitation
ad revenue reference
partner fee reference
POS integration fee reference
KDS integration fee reference
AI support fee reference
billing dispute evidence

Billing Plan Settlement does not own:

card authorization
payment capture
PG settlement
VAN settlement
POS final sales record
KDS kitchen execution state
reservation cancellation decision
food preparation state
ad content approval
partner API certification

Core rule:

Billing is business charging governance, not payment provider runtime.

5\. Relationship To Payment Providers

Payment providers execute payment.

Billing decides billing meaning.

Payment provider facts may include:

payment authorized
payment confirmed
payment failed
payment cancelled
refund processed
transaction reference
receipt reference

Billing may use those facts to update:

billing status
invoice reference
payment reference
suspension status
reactivation status
dispute evidence

Core rule:

Payment success is payment fact.
Billing finality requires billing policy.

6\. Plan Types

CatchMenu may support several plan types.

Suggested plan types:

FREE\_TRIAL
BASIC
STANDARD
PRO
ENTERPRISE
PILOT
CUSTOM
PARTNER\_BUNDLE
YOONSUL\_AFFILIATED
INTERNAL\_TEST

MVP may start with:

FREE\_TRIAL
BASIC
CUSTOM
INTERNAL\_TEST

Core rule:

Plan type determines feature entitlement and billing rule.

7\. Trial Plan

Trial plan supports low-friction merchant adoption.

Trial plan may include:

limited period
limited store count
limited Entry Plate count
limited request volume
limited Owner Console access
limited AI Menu Intake
limited support
limited CMS access
no or limited POS integration
no or limited KDS integration

Trial plan must define:

trial\_start\_at
trial\_end\_at
trial\_status
trial\_extension\_rule
included\_features
post-trial limitation
Entry Media recovery rule
conversion rule

Core rule:

Trial is real service with limited entitlement.
Trial is not permanent free production.

8\. Paid Plan

Paid plan grants paid entitlement.

Paid plan may include:

ongoing menu/request service
Owner Console
usage dashboard
AI Menu Intake
reservation/preorder
Ad Promotion CMS
external POS integration
future KDS integration
AI customer center
advanced support
multi-store management

Core rule:

Paid plan must explicitly define features, billing unit, and service limits.

9\. Flexible Billing Architecture

CatchMenu billing must not be designed as a single rigid price.

Billing should support:

base monthly fee
per-store fee
per Entry Plate fee
feature-based fee
usage-based fee
POS integration add-on
KDS integration add-on
reservation/preorder add-on
Ad Promotion CMS package
AI Menu Intake usage
AI customer center support level
partner channel fee
custom contract
revenue share
trial discount
launch promotion

Core rule:

Billing must follow merchant reality, store scale, feature usage, provider cost, and contract condition.

10\. Billing By Merchant Scale

CatchMenu must support billing differences by merchant scale.

Small store candidate:

low base monthly fee
one Entry Plate
basic menu/request flow
manual POS fallback
limited AI Menu Intake
basic support
optional low-cost CMS notice

Medium store candidate:

standard monthly plan
reservation/preorder add-on
promotion CMS add-on
external POS integration add-on
usage dashboard
AI customer center option
multi-surface guest flow

Large store candidate:

multi-store plan
custom contract
POS integration package
KDS integration package
advanced CMS
AI customer center package
support SLA
usage-based volume tier
custom reporting
provider integration support

Core rule:

CatchMenu can cover small stores and large stores only if billing is flexible.

11\. Billing By Provider And Integration Cost

Provider integrations may create different costs.

Examples:

Toss POS integration
TossPayments integration
PAYCO payment/channel integration
other POS provider integration
VAN-connected POS integration
KDS provider integration
external reservation channel integration
partner API integration
table-order bridge integration
kiosk bridge integration

Each provider may have different:

technical setup cost
API usage cost
support burden
credential management burden
certification cost
mapping maintenance cost
failure handling cost
replay/support cost
partner fee

Billing must be able to reflect these differences.

Core rule:

Provider integration cost must be billable, absorbable, discounted, bundled, or waived by explicit plan rule.

12\. Feature Entitlement And Add-On Billing

Billing must support base plan plus add-ons.

Possible add-ons:

external\_pos\_integration
kds\_integration
reservation\_preorder
ad\_promotion\_cms
ai\_menu\_intake\_extra
ai\_customer\_center
usage\_dashboard
multi\_store\_management
advanced\_support
partner\_api\_access
custom\_reporting

Feature entitlement controls access.

Core rule:

A feature can be technically available but commercially disabled unless entitlement allows it.

13\. Feature Entitlement

Feature entitlement defines what a merchant may use.

Entitlement examples:

Stage 0A menu view
Stage 0B send request
Stage 0C request board
AI Menu Intake
Owner Console
usage dashboard
Entry Media count
reservation/preorder
Ad Promotion CMS
external POS integration
future KDS integration
AI customer center
provider adapter integration
support level
partner API access

Core rule:

Feature availability must come from entitlement, not hidden UI assumptions.

14\. Entitlement States

Suggested entitlement states:

NOT\_INCLUDED
INCLUDED
ADD\_ON\_AVAILABLE
ADD\_ON\_ACTIVE
PILOT\_APPROVED
SUSPENDED
EXPIRED
CUSTOM\_APPROVED
REVIEW\_REQUIRED

Core rule:

Entitlement state must be explicit before feature activation.

15\. Subscription Billing

Subscription billing may be account-level or store-level.

Possible billing units:

per merchant account
per store
per Entry Media kit
per active feature
per usage tier
per POS-connected store
per KDS-connected store
per AI customer center package
per promotion campaign package
custom enterprise bundle

MVP may use simple merchant/store subscription.

Core rule:

Billing unit must be clear before invoice or service limitation.

16\. Store Count Billing

Store count billing may apply to multi-store merchants.

Billing may depend on:

number of active stores
number of trial stores
number of paid stores
number of suspended stores
number of POS-integrated stores
number of KDS-integrated stores
number of Entry Media kits

Core rule:

Store billing must follow store service status and plan entitlement.

17\. Usage-Based Billing

Usage-based billing may be introduced later.

Usage metrics may include:

scan count
menu open count
request count
confirmed request count
reservation count
prepaid pickup count
AI menu intake count
AI customer center conversation count
POS handoff count
KDS handoff count
provider API call count
ad impression count
ad click count
partner integration call count

MVP may collect usage without charging.

Core rule:

Measure first.
Charge later only with clear policy and notice.

18\. Small-Store Entry Pricing

CatchMenu should support low-friction pricing for small stores.

Small-store entry pricing may include:

low monthly base fee
free or low-cost trial
one Entry Plate included
basic menu/request flow
manual POS fallback
limited AI menu setup
basic support
optional paid add-ons later

Core rule:

Small-store entry pricing should reduce adoption resistance.

19\. Medium-Store Expansion Pricing

Medium stores may need more features.

Medium-store expansion pricing may include:

standard monthly plan
reservation/preorder add-on
promotion CMS add-on
external POS integration add-on
usage dashboard
AI customer center option
additional Entry Plates

Core rule:

Medium-store pricing should support modular expansion after proof of value.

20\. Large-Store And Multi-Store Pricing

Large stores and multi-store merchants may require custom billing.

Large-store billing may include:

multi-store base plan
per-store fee
POS/KDS integration package
advanced CMS package
AI customer center support level
support SLA
custom reporting
custom integration setup fee
usage volume tier
enterprise contract

Core rule:

Large-store pricing must support integration complexity and support burden.

21\. Custom Billing For Partner And Enterprise

Partner and enterprise merchants may require custom billing.

Custom billing may include:

fixed monthly fee
store-count pricing
usage reference
partner revenue share
co-selling discount
launch promotion
minimum guarantee
custom support package
integration setup fee
waived setup fee
custom trial
custom settlement cycle

Custom billing must be explicit and auditable.

Core rule:

Custom billing is allowed only when recorded as plan, contract, entitlement, and audit evidence.

22\. POS Integration Billing

External POS integration may be a paid add-on.

Possible fee bases:

per POS-connected store
per POS provider integration
per POS handoff volume
per advanced sync feature
per custom setup
per support tier

POS integration billing should reference:

POS provider binding
POS capability
store scope
integration status
support burden
provider cost

Core rule:

POS integration billing must reflect actual enabled capability and store binding.

23\. KDS Integration Billing

Future KDS integration may be a paid add-on.

Possible fee bases:

per KDS-connected store
per kitchen station
per KDS handoff volume
per advanced kitchen status feature
per custom KDS provider integration

KDS integration billing should be entitlement-controlled.

Core rule:

KDS integration billing must follow kitchen execution capability and support scope.

24\. CMS Billing

Ad Promotion CMS may have billing impact.

Possible CMS billing models:

basic notice included
merchant promotion package
paid boost package
HQ campaign package
partner-sponsored campaign
ad placement fee
impression/click reference later
custom campaign fee

CMS owns content and exposure events.

Billing owns chargeability.

Core rule:

CMS exposure does not become billable unless billing rule defines it.

25\. AI Menu Intake Billing

AI Menu Intake may be included or charged depending on plan.

Possible billing models:

first menu setup included
limited AI intake included
extra AI intake charged
large menu setup fee
translation review add-on
manual correction support fee
custom menu migration fee

Core rule:

AI Menu Intake billing must distinguish AI draft generation from human review/correction effort.

26\. AI Customer Center Billing

AI Customer Center may be a support add-on or plan component.

Possible billing models:

basic FAQ support included
merchant support AI included
guest support AI add-on
conversation volume tier
advanced support package
human escalation package
custom knowledge base setup

Core rule:

AI customer center billing must reflect usage, support scope, and escalation burden.

27\. Reservation And Preorder Billing Reference

Reservation and preorder may generate billing references.

Examples:

reservation feature add-on
prepaid pickup feature add-on
deposit handling reference
group order feature
no-show evidence handling
refund dispute support

Reservation Preorder Governance owns reservation/refund business state.

Billing owns plan and fee reference.

Core rule:

Reservation policy decides reservation outcome.
Billing records financial or entitlement effect.

28\. Deposit, Payment, And Refund Reference

Deposit, payment, and refund may appear in billing evidence.

Examples:

reservation deposit
prepaid pickup payment
group order deposit
cancellation fee
partial refund
deposit refund
deposit forfeiture candidate
store credit
coupon recovery

Billing does not decide refund policy alone.

Core rule:

Payment and refund references support billing evidence but do not replace business policy.

29\. Advertisement Revenue Reference

Ad Promotion CMS may generate revenue references.

Examples:

paid ad campaign
merchant promotion boost
partner banner fee
sponsored placement
local offer package
campaign package

Billing owns revenue reference and charging rule.

Core rule:

Ad exposure does not equal billable event unless billing rule defines it.

30\. Promotion Benefit Reference

Merchant promotions may create benefits.

Examples:

free promotional slot
trial campaign benefit
conversion discount
partner-sponsored benefit
merchant credit
ad coupon
waived setup fee

Benefit should be recorded.

Core rule:

Benefit must be traceable so billing and entitlement remain explainable.

31\. Partner Revenue Share

Partner Alliance may create revenue share.

Examples:

referral fee
integration fee
partner channel fee
co-selling revenue share
certified partner program fee
API usage fee
sales partner reward
VAN/POS dealer partnership fee

Partner Alliance defines relationship.

Billing records fee calculation and settlement reference.

Core rule:

Partner commercial model must not bypass billing and integration governance.

32\. Sales Partner Commission Reference

Sales Partner Field Growth may create commission references.

Examples:

paid conversion commission
retention reward
campaign bonus
clawback candidate
commission hold
duplicate lead dispute

Sales Partner Field Growth owns eligibility logic.

Billing may reference payout, settlement, and evidence.

Core rule:

Sales commission must be tied to verified conversion and retention evidence.

33\. Entry Media Billing Reference

Entry Media may create billing-related references.

Examples:

free trial Entry Plate
additional Entry Plate fee
lost plate replacement fee
damaged plate replacement fee
premium design fee
field installation fee
reallocation handling fee

Entry Media Inventory owns asset lifecycle.

Billing owns fee rule and billing reference.

Core rule:

Asset lifecycle and billing fee rule must be linked but separated.

34\. Billing Account

Billing account represents who is billed.

Billing account may be tied to:

merchant\_account
merchant\_company
merchant\_store
custom contract
partner account
Yoonsul-affiliated internal account

Minimum fields:

billing\_account\_id
merchant\_account\_id
merchant\_company\_id optional
billing\_contact
billing\_status
plan\_id
created\_at

Core rule:

Billing account must be tied to merchant organization context.

35\. Invoice Reference

Invoice reference may include:

invoice\_id
billing\_account\_id
billing\_period
plan
line\_items
amount
tax reference if applicable
payment\_status
issued\_at
due\_at

MVP may not implement full invoice engine.

But billing references should be structured.

Core rule:

Invoice reference should be structured even before full invoice automation.

36\. Billing Status

Suggested billing statuses:

BILLING\_NOT\_REQUIRED
TRIAL
ACTIVE
PAYMENT\_PENDING
PAYMENT\_FAILED
OVERDUE
SUSPENSION\_PENDING
SUSPENDED\_FOR\_BILLING
TERMINATED
DISPUTE\_REVIEW
REACTIVATION\_PENDING

Core rule:

Billing status and service status are related but separate.

37\. Service Limitation By Billing

Billing issues may limit service.

Possible limitation levels:

no limitation
owner console warning
new feature disabled
new request disabled
POS integration disabled
KDS integration disabled
ad campaign paused
AI support limited
service suspended
termination pending

Core rule:

Billing limitation must be policy-backed, notified, and auditable.

38\. Billing Suspension

Billing suspension may occur when merchant payment is overdue or billing issue remains unresolved.

Suspension should define:

reason
notice sent
grace period
affected features
effective time
reactivation condition
support contact
audit event

Core rule:

Billing suspension limits future use.
It must not erase merchant history.

39\. Reactivation

Reactivation may occur after billing issue is resolved.

Reactivation should record:

previous\_status
resolved\_reason
payment\_reference
operator
reactivated\_at
affected features restored
audit event

Core rule:

Reactivation must restore only entitled features.

40\. Billing Dispute

Billing dispute may include:

wrong plan charged
trial period disputed
usage count disputed
ad charge disputed
POS integration fee disputed
KDS integration fee disputed
AI support fee disputed
partner fee disputed
reservation/refund-related fee disputed
sales commission dispute

Dispute should create case and evidence.

Core rule:

Billing dispute requires evidence, not silent overwrite.

41\. Billing Evidence Packet

Billing evidence may include:

billing\_account\_id
merchant\_account\_id
merchant\_store\_id
plan version
entitlement version
trial status
service status
usage metrics
invoice reference
payment reference
reservation/refund reference
ad campaign reference
partner fee reference
POS integration reference
KDS integration reference
AI customer center reference
Entry Media reference
sales commission reference
notice history
audit events
support notes

Core rule:

Billing evidence explains why a charge, limitation, or dispute decision exists.

42\. Billing Audit Events

Recommended audit events:

PLAN\_CREATED
PLAN\_UPDATED
PLAN\_VERSION\_CREATED
PLAN\_ASSIGNED
TRIAL\_STARTED
TRIAL\_EXTENDED
TRIAL\_EXPIRED
PAID\_CONVERSION\_COMPLETED
BILLING\_ACCOUNT\_CREATED
BILLING\_STATUS\_CHANGED
FEATURE\_ENTITLEMENT\_GRANTED
FEATURE\_ENTITLEMENT\_REVOKED
ADD\_ON\_ACTIVATED
ADD\_ON\_SUSPENDED
ADD\_ON\_REVOKED
INVOICE\_REFERENCE\_CREATED
PAYMENT\_REFERENCE\_LINKED
BILLING\_SUSPENSION\_NOTICE\_SENT
BILLING\_SUSPENSION\_APPLIED
BILLING\_REACTIVATION\_APPLIED
BILLING\_DISPUTE\_CREATED
BILLING\_DISPUTE\_RESOLVED
PARTNER\_FEE\_REFERENCE\_CREATED
AD\_REVENUE\_REFERENCE\_CREATED
POS\_INTEGRATION\_FEE\_REFERENCE\_CREATED
KDS\_INTEGRATION\_FEE\_REFERENCE\_CREATED
AI\_SUPPORT\_FEE\_REFERENCE\_CREATED

Minimum audit fields:

event\_id
billing\_account\_id
merchant\_account\_id
merchant\_store\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

43\. Billing Failure Events

Example failure codes:

WOH.BILLING.PLAN.ASSIGN.MERCHANT\_REQUIRED
WOH.BILLING.PLAN.VERSION\_REQUIRED
WOH.BILLING.PLAN.ENTITLEMENT\_MISSING
WOH.BILLING.TRIAL.CONVERSION\_REQUIRED
WOH.BILLING.ADD\_ON.ENTITLEMENT\_REQUIRED
WOH.BILLING.SUSPENSION.NOTICE\_REQUIRED
WOH.BILLING.REACTIVATION.PAYMENT\_REFERENCE\_REQUIRED
WOH.BILLING.USAGE.METRIC\_CONFLICT
WOH.BILLING.AD\_REVENUE.CAMPAIGN\_REFERENCE\_REQUIRED
WOH.BILLING.PARTNER\_FEE.PARTNER\_REFERENCE\_REQUIRED
WOH.BILLING.POS\_FEE.INTEGRATION\_REFERENCE\_REQUIRED
WOH.BILLING.KDS\_FEE.INTEGRATION\_REFERENCE\_REQUIRED
WOH.BILLING.AI\_SUPPORT.REFERENCE\_REQUIRED
WOH.BILLING.DISPUTE.EVIDENCE\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

44\. Billing Support Signals

Support signals may include:

TRIAL\_EXPIRING\_SOON
TRIAL\_EXPIRED\_NOT\_CONVERTED
BILLING\_PAYMENT\_FAILED
BILLING\_OVERDUE
BILLING\_SUSPENSION\_PENDING
BILLING\_DISPUTE\_CREATED
USAGE\_BILLING\_METRIC\_CONFLICT
AD\_REVENUE\_REFERENCE\_CONFLICT
PARTNER\_FEE\_REFERENCE\_CONFLICT
POS\_INTEGRATION\_BILLING\_MISMATCH
KDS\_INTEGRATION\_BILLING\_MISMATCH
AI\_SUPPORT\_BILLING\_MISMATCH
CUSTOM\_PLAN\_REVIEW\_REQUIRED

Support Signal alerts.

It does not change billing status by itself.

45\. Relationship To Identity Access

Identity Access controls:

who can view billing
who can change plan
who can apply discount
who can activate add-on
who can suspend service for billing
who can reactivate billing-suspended service
who can view billing evidence
who can export billing data
who can approve custom plan

Billing actions must be role-scoped and audited.

Core rule:

Billing authority is sensitive administrative authority.

46\. Relationship To Organization Core

Organization Core provides:

merchant\_account
merchant\_company
merchant\_store
company context
business unit context
operator responsibility

Billing uses those structures.

Core rule:

Billing account must not float without organization context.

47\. Relationship To Reservation Preorder Governance

Reservation Preorder Governance owns:

reservation status
pickup no-show
deposit refund policy
cancellation/refund business rule
preparation state

Billing references:

deposit payment
refund outcome
feature entitlement
fee reference
dispute evidence

Core rule:

Reservation policy decides reservation outcome.
Billing records financial reference.

48\. Relationship To Ad Promotion CMS

Ad Promotion CMS owns:

content
campaign
slot
impression
click
conversion definition
content approval

Billing references:

ad campaign fee
promotion boost fee
partner-sponsored campaign
merchant benefit
ad revenue reference
CMS package entitlement

Core rule:

CMS measures exposure.
Billing defines what is chargeable.

49\. Relationship To Open API Partner Alliance

Open API Partner Alliance owns:

partner eligibility
commercial relationship
certification
merchant consent
alliance governance

Billing references:

partner fee
revenue share
referral fee
API usage fee
co-selling fee
partner bundle

Core rule:

Partner agreement defines commercial basis.
Billing records fee and settlement reference.

50\. Relationship To Provider Adapter Runtime

Provider Adapter Runtime owns:

provider credential
provider state
payment reference
callback
failure
replay

Billing references:

payment status
transaction reference
provider fee candidate
integration cost
billing event

Core rule:

Provider adapter provides payment or provider fact.
Billing decides billing effect.

51\. Relationship To External POS Integration

External POS Integration owns:

POS binding
POS handoff
POS order reference
POS failure
manual fallback
POS provider capability

Billing may reference:

POS integration add-on
POS-connected store count
POS handoff usage
POS provider fee
POS support burden
POS custom setup fee

Core rule:

POS connected status may affect billing only through defined entitlement and plan rule.

52\. Relationship To Future KDS Integration

Future KDS Integration may create billing references.

KDS billing may reference:

KDS-connected store
KDS station count
KDS handoff usage
KDS provider integration
kitchen support burden
advanced KDS feature

Core rule:

KDS capability must be entitlement-controlled before billing impact.

53\. Relationship To Sales Partner Field Growth

Sales Partner Field Growth brings merchants into billing pipeline.

Sales may create:

trial lead
trial activation
paid conversion
commission eligibility
retention reward
clawback candidate

Billing references conversion and payout-related evidence.

Core rule:

Sales reward must be tied to verified billing/conversion evidence.

54\. Relationship To Native All-In-One Service Runtime

Native All-In-One Service Runtime defines the unified product path.

Billing controls commercial access to that path.

Examples:

basic request flow
AI menu setup
reservation/preorder
CMS
POS integration
KDS integration
AI customer center
operating OS features

Core rule:

Native service modules must be monetizable without forcing one rigid plan.

55\. Relationship To CatchMenu HQ

CatchMenu HQ manages:

plan management
trial conversion
billing status
merchant suspension
reactivation
billing dispute
usage review
partner fee review
ad revenue review
custom plan approval
integration fee review

HQ actions must be authorized and audited.

56\. MVP Requirements

Billing Plan Settlement MVP should support at least:

plan record
plan version
trial plan
paid plan placeholder
custom plan placeholder
merchant billing account
plan assignment
trial start
trial expiry
paid conversion marker
feature entitlement
add-on entitlement placeholder
billing status
billing suspension marker
reactivation marker
basic invoice reference
payment reference placeholder
usage metric reference
POS integration billing reference placeholder
CMS billing reference placeholder
AI support billing reference placeholder
billing audit event
billing failure event
billing support signal

MVP may defer:

full invoice engine
automatic card billing
complex tax handling
advanced usage-based billing
partner revenue share settlement automation
ad revenue settlement automation
intercompany settlement
full accounting ledger
multi-currency pricing
advanced enterprise contract engine

57\. Suggested Conceptual Entities

Suggested entities:

billing\_plans
billing\_plan\_versions
billing\_plan\_features
billing\_accounts
billing\_plan\_assignments
feature\_entitlements
billing\_add\_ons
billing\_status\_events
billing\_invoice\_references
billing\_payment\_references
billing\_usage\_metrics
billing\_disputes
billing\_evidence\_packets
billing\_audit\_events
billing\_failure\_events
billing\_support\_signals

Optional later entities:

billing\_provider\_cost\_references
billing\_partner\_fee\_references
billing\_ad\_revenue\_references
billing\_pos\_integration\_references
billing\_kds\_integration\_references
billing\_ai\_support\_references
billing\_commission\_references
custom\_contract\_terms

This document defines policy.

Actual schema may be designed later.

58\. Risk If Skipped

If Billing Plan Settlement governance is skipped, risks include:

trial merchants stay free forever
paid conversion is unclear
features are enabled without entitlement
POS integration is used without billing rule
KDS integration is promised without commercial rule
AI customer center cost is not priced
ad revenue cannot be explained
partner fee cannot be settled
small stores reject rigid pricing
large stores require custom plans that system cannot represent
billing suspension is applied without notice
merchant disputes cannot be resolved with evidence
payment provider facts are mistaken for billing decisions

Therefore, Billing Plan Settlement must be modularized before paid SaaS operation.

59\. Final Rule

CatchMenu billing must be flexible, plan-based, entitlement-controlled, evidence-backed, and separated from payment provider execution.

Final rule:

Do not force every merchant into one rigid billing model.
Support small-store entry pricing.
Support medium-store feature expansion.
Support large-store and multi-store custom plans.
Define plans.
Version plans.
Define trial.
Define paid conversion.
Define feature entitlement.
Support POS/KDS/CMS/AI customer center add-ons.
Support provider-specific integration cost handling.
Track usage before charging usage-based fees.
Reference payment facts without owning provider execution.
Reference reservation/refund facts without owning reservation policy.
Reference ad and partner revenue without bypassing review.
Notify before billing suspension.
Reactivate with evidence.
Audit every billing status change.
Make custom contracts explicit.
Keep billing explainable, adjustable, and auditable by merchant reality.
