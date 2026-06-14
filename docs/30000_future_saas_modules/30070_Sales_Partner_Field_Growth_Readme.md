03700 Sales Partner Field Growth Readme

Legacy path: $old.

1\. Purpose

This folder defines Sales Partner, Field Growth, Referral Commission, Trial Entry Plate Installation, Merchant Conversion, Local Promotion, Abuse Prevention, and Early Merchant Success governance for CatchMenu / Wait Order Handoff.

CatchMenu may grow through lightweight field sales because the product can start with software, QR/NFC Entry Plate, AI Menu Intake, limited Owner Console, and POS-less or POS-light operation.

A merchant does not need to install full table-order hardware at the beginning.

A sales partner may introduce CatchMenu to a store, install or request installation of a trial Entry Plate, help collect menu materials, trigger AI Menu Intake, support early setup, and help convert the merchant after a trial period.

Core purpose:

Define field sales partner growth governance.
Define trial Entry Plate installation and conversion flow.
Define sales referral and commission policy.
Define 3-month trial sales pipeline.
Define paid conversion reward.
Define annual retention reward candidate.
Define abuse, fraud, duplicate lead, and clawback rules.
Define early troubleshooting and first merchant success linkage.
Support fast local expansion without losing audit, asset, billing, and merchant trust boundaries.

Korean purpose:

현장 영업 파트너 성장 거버넌스를 정의한다.
체험 Entry Plate 설치와 유료 전환 흐름을 정의한다.
영업 추천 및 수수료 정책을 정의한다.
3개월 체험 영업 파이프라인을 정의한다.
유료 전환 보상을 정의한다.
연간 유지 보상 후보를 정의한다.
부정 영업, 중복 리드, clawback 규칙을 정의한다.
초기 트러블슈팅 및 첫 성공 지원과의 연결을 정의한다.
감사, 자산, 과금, 고객 신뢰 경계를 잃지 않으면서 빠른 지역 확산을 지원한다.

2\. Scope

This folder covers:

sales partner
field sales agent
referral partner
local growth campaign
merchant lead
lead ownership
trial installation
trial Entry Plate handoff
AI menu intake support
first setup support
trial usage follow-up
paid conversion
commission rule
retention reward
promotion campaign
sales fraud prevention
duplicate lead handling
clawback
early troubleshooting linkage
merchant success handoff

This folder does not define:

full HR employment contract
labor payroll
tax withholding detail
external legal contract final text
payment provider execution
Entry Media physical inventory source of truth
AI Menu Intake implementation
Owner Console UI detail
POS adapter implementation
billing engine

Related folders:

docs/00300\_entry\_media\_inventory/
docs/00500\_organization\_core/
docs/02400\_owner\_console/
docs/02600\_merchant\_ops/
docs/03100\_reservation\_preorder\_governance/
docs/03400\_provider\_adapter\_runtime/
docs/03500\_external\_pos\_integration\_runtime/
docs/03600\_billing\_plan\_settlement/

3\. Core Principle

Sales growth must be fast, but controlled.

Core rule:

Sales partner may create opportunity.
Sales partner does not own merchant account authority, billing authority, POS credential authority, or Entry Media inventory authority.

Korean rule:

영업 파트너는 기회를 만들 수 있다.
하지만 Merchant Account 권한, 과금 권한, POS 인증 권한, Entry Media 재고 권한을 소유하지 않는다.

4\. Strategic Growth Model

CatchMenu can grow through a lightweight field model.

Growth sequence:

1\. identify merchant lead
2\. explain lightweight trial
3\. install or request trial Entry Plate
4\. collect menu photo/PDF/board image
5\. run AI Menu Intake
6\. review and correct menu draft
7\. activate trial flow
8\. observe usage
9\. troubleshoot early issues
10\. convert to paid plan or recover Entry Plate

Core rule:

Low installation burden enables grassroots sales.
Operational follow-through determines conversion.

5\. Product Sales Position

CatchMenu sales message should emphasize:

software-first
QR/NFC Entry Plate
AI menu input
foreign-language menu support
simple request board
POS-less start possible
external POS integration path
AI customer center path
low monthly fee candidate
trial before commitment
Entry Plate return if not converted

Core rule:

Sell low-friction adoption first.
Sell deep POS integration later.

6\. Sales Partner Types

Sales partner types may include:

FIELD\_SALES\_AGENT
REFERRAL\_PARTNER
LOCAL\_PROMOTER
VAN\_OR\_POS\_DEALER\_PARTNER
CONSULTANT\_PARTNER
MERCHANT\_INTRODUCER
INTERNAL\_SALES\_OPERATOR

MVP may start with:

FIELD\_SALES\_AGENT
REFERRAL\_PARTNER
INTERNAL\_SALES\_OPERATOR

Core rule:

Partner type determines authority, commission, and compliance requirements.

7\. Sales Partner Authority

Sales partner may be allowed to:

register merchant lead
explain trial offer
request trial setup
collect menu materials with merchant consent
help install Entry Plate if authorized
submit field notes
support first-use explanation
request conversion follow-up

Sales partner must not automatically:

create paid contract
change billing plan
bind POS credential
view merchant private data
view support evidence
deactivate Entry Media
approve AI menu draft
promise unsupported features
override refund/no-show policy
grant merchant user access

Core rule:

Sales partner creates pipeline.
CatchMenu authorized operators activate service authority.

8\. Lead Registration

Lead registration should record merchant opportunity.

Lead fields may include:

lead\_id
merchant\_name
merchant\_contact
store\_name
store\_address
business\_type
sales\_partner\_id
lead\_source
lead\_status
registered\_at
duplicate\_check\_status
field\_note

Lead status examples:

NEW
CONTACTED
VISITED
TRIAL\_PROPOSED
TRIAL\_ACCEPTED
TRIAL\_INSTALLED
TRIAL\_ACTIVE
CONVERSION\_PENDING
CONVERTED
DECLINED
UNREACHABLE
DUPLICATE
INVALID

Core rule:

Lead ownership must be recorded before commission claim.

9\. Duplicate Lead Handling

Duplicate leads must be detected.

Duplicate signals:

same store phone
same business registration number if available
same store address
same merchant owner phone
same Entry Media installation request
same POS store identity
same CatchMenu merchant account

Duplicate resolution outcomes:

first valid lead wins
shared credit
HQ review required
invalid duplicate
existing merchant no commission

Core rule:

Duplicate lead dispute must be resolved before commission payout.

10\. Trial Entry Plate Installation

Trial Entry Plate installation may be requested by sales partner.

Installation must follow Entry Media Inventory governance.

Trial installation should record:

entry\_media\_id
entry\_plate\_id
merchant\_store\_id
installed\_at
installed\_by
sales\_partner\_id
installation\_photo optional
placement
trial\_start\_at
trial\_end\_at

Core rule:

Sales installation does not transfer Entry Media ownership.

11\. Entry Plate Return Or Recovery

If merchant does not convert, Entry Plate may be recovered.

Recovery may be triggered by:

trial expired
merchant declined
merchant unreachable
not using
service terminated
fraud suspected

Recovery belongs to Entry Media Inventory and Merchant Ops workflows.

Sales partner may support recovery if authorized.

Core rule:

Trial asset must return to inventory path when not converted.

12\. AI Menu Intake Sales Flow

Sales partner may collect menu materials for AI Menu Intake.

Allowed materials:

menu board photo
paper menu photo
PDF menu
existing online menu
price list
menu category note
option/add-on note
allergy/special note if merchant provides

Sales partner must not fabricate menu data.

AI Menu Intake must go through review and approval.

Core rule:

AI menu setup reduces friction.
Final menu accuracy must be reviewed and approved.

13\. Trial Activation

Trial activation may require:

merchant account created
merchant store created
Entry Media assigned
menu draft ready
menu reviewed
Owner Console access granted
trial plan assigned
trial terms accepted
service status active

Core rule:

Sales win is not service activation until required setup is complete.

14\. Three-Month Trial Pipeline

A standard field sales trial may be three months.

Suggested stages:

Day 0: installation and activation
Day 1-7: first-use troubleshooting
Day 14: usage check
Day 30: value review
Day 60: conversion conversation
Day 75: conversion reminder
Day 90: convert or recover decision

Core rule:

Trial conversion should be managed before trial expires.

15\. First 30 Days Support Link

The first 30 days determine adoption.

Sales partner or Merchant Ops should check:

QR/NFC scan works
menu is accurate
price is accurate
translation is acceptable
request board is visible
staff knows how to respond
critical warnings are understood
manual POS entry is practical
merchant sees usage value

Core rule:

Field growth without early troubleshooting wastes leads.

16\. Paid Conversion

Paid conversion means merchant accepts paid plan or contract.

Conversion should be linked to:

merchant\_account\_id
merchant\_store\_id
sales\_partner\_id
trial\_id
plan\_id
billing\_account\_id
conversion\_date
commitment\_term
commission\_eligibility\_status

Core rule:

Commission eligibility starts from verified paid conversion, not verbal promise.

17\. Commitment Term

Commitment term may affect commission.

Examples:

monthly no commitment
1-year commitment
2-year commitment
3-year commitment
custom term

Example candidate:

2-year commitment paid conversion
\= base commission eligible

Core rule:

Commission must reference actual commitment term.

18\. Base Commission Candidate

Candidate sales promotion:

2-year paid commitment conversion
\= 100,000 KRW base commission per merchant/store

This is a candidate business rule and must be finalized by commercial policy.

Required eligibility:

valid lead ownership
trial or direct conversion trace
paid conversion verified
merchant not duplicate
merchant not internal test
cooling-off period passed if defined
no fraud flag

Core rule:

Commission payout requires verified eligibility.

19\. Retention Reward Candidate

Candidate retention reward:

Year 1 retained
\= 20,000 KRW

Year 2 retained
\= 20,000 KRW

Year 3 retained
\= 20,000 KRW

Retention reward may require:

merchant still active
paid plan still active
no chargeback/clawback flag
sales partner still eligible
no duplicate claim
minimum usage or payment condition if defined

Core rule:

Retention reward should reward durable merchant value, not one-time signup only.

20\. Commission Payout Status

Suggested payout statuses:

NOT\_ELIGIBLE
ELIGIBILITY\_PENDING
ELIGIBLE
PAYOUT\_PENDING
PAYOUT\_APPROVED
PAID
HELD
CLAWBACK\_PENDING
CLAWED\_BACK
DISPUTED
CANCELLED

Core rule:

Commission status must be separate from merchant service status.

21\. Payout Hold

Payout may be held when:

duplicate lead dispute
merchant conversion not verified
payment not confirmed
cooling-off period not passed
fraud signal
merchant immediately churned
contract term conflict
sales partner compliance issue

Core rule:

Payout hold protects against bad growth.

22\. Clawback

Clawback means previously approved or paid commission may be reversed under defined conditions.

Possible clawback reasons:

merchant fraud
fake store
duplicate merchant
sales partner misrepresentation
early cancellation within clawback window
payment chargeback
unauthorized installation
policy violation

Core rule:

Clawback must be policy-backed and evidence-backed.

23\. Sales Misrepresentation

Sales partner must not misrepresent CatchMenu.

Prohibited claims:

guaranteed sales increase
guaranteed free forever
POS integration already available when not available
payment settlement guaranteed
refund/no-show rules different from policy
official partnership not approved
government or platform certification not true
merchant data ownership false claim

Core rule:

Fast sales must not create false promises.

24\. Promotion Campaign

Sales campaign may define limited offers.

Examples:

3-month free trial
free Entry Plate during trial
discounted first month
free AI menu setup
local market launch campaign
first 100 stores campaign
POS integration pilot campaign

Campaign must define:

campaign\_id
eligible merchant
eligible region
start\_at
end\_at
offer terms
commission effect
approval authority

Core rule:

Sales promotion must be versioned and auditable.

25\. Local Growth Territory

Territory may be used for field growth.

Territory may be:

district
station area
commercial street
shopping district
university area
food alley
city
sales route

Territory ownership may be:

exclusive
non-exclusive
campaign-based
time-limited
lead-based only

Core rule:

Territory rules prevent sales conflict.

26\. Sales Partner Onboarding

Sales partner onboarding should include:

identity verification
contact information
agreement acceptance
product training
prohibited claim training
commission policy acknowledgement
trial installation process training
merchant data handling training
support escalation guide

Core rule:

Sales partner must understand what they can and cannot promise.

27\. Sales Partner Status

Suggested sales partner statuses:

APPLICANT
ACTIVE
TRAINING\_REQUIRED
SUSPENDED
TERMINATED
COMMISSION\_HELD
REVIEW\_REQUIRED

Core rule:

Suspended sales partner cannot generate commission-eligible new leads.

28\. Field Note

Sales partner should submit field notes.

Field note may include:

merchant interest
pain point
current POS
current table-order system
reservation system
menu complexity
foreign customer ratio
owner concern
staff concern
trial readiness
competitor presence

Core rule:

Field notes improve product and support feedback loop.

29\. Competitor Context

Sales partner may record competitor context.

Examples:

table-order hardware installed
reservation platform used
POS provider
delivery channel dependence
manual menu issue
foreign customer pain
no-show issue

Competitor notes must be factual and not defamatory.

Core rule:

Competitor context helps strategy.
It must not become false sales claim.

30\. Merchant Value Proof

Conversion should rely on value proof.

Possible value proof:

scan count
menu open count
request count
foreign-language usage
staff feedback
owner feedback
manual order time reduced
customer question reduction
reservation/preorder interest
POS integration need identified

Core rule:

Paid conversion should be supported by trial evidence where possible.

31\. Sales Partner Data Access

Sales partner may see limited data.

Allowed:

own leads
lead status
trial status summary
conversion status
commission status
field task
public merchant info they registered

Not allowed by default:

merchant billing detail
support evidence
POS credential
customer personal data
payment data
other sales partner leads
HQ admin data

Core rule:

Sales partner access is pipeline-scoped.

32\. Relationship To Entry Media Inventory

Entry Media Inventory owns asset lifecycle.

Sales Partner Field Growth may trigger:

trial Entry Plate request
installation field note
activation readiness
recovery needed signal
lost/damaged report

But sales partner does not own inventory state.

Core rule:

Sales can request asset movement.
Inventory governs asset truth.

33\. Relationship To AI Menu Intake

Sales partner may collect menu materials.

AI Menu Intake owns extraction, draft generation, review, correction, and approval flow.

Core rule:

Sales helps collect.
AI Menu Intake prepares.
Merchant or authorized reviewer approves.

34\. Relationship To Billing Plan Settlement

Billing Plan Settlement owns plan, paid conversion, and billing status.

Sales Partner Field Growth may reference:

trial assignment
paid conversion
commitment term
commission eligibility
retention reward
clawback

Core rule:

Commission depends on billing/conversion evidence.

35\. Relationship To Merchant Ops

Merchant Ops owns operational follow-up.

Merchant Ops may handle:

trial onboarding
first 30 days support
merchant issue follow-up
conversion call
non-conversion recovery
Entry Plate recovery coordination

Sales partner may assist but not override Merchant Ops.

36\. Relationship To Owner Console

Owner Console may show merchant trial and conversion status.

Sales partner portal, if later added, should not be the Owner Console.

Core rule:

Merchant console and sales partner portal must remain separate.

37\. Relationship To External POS Integration

Sales partner may identify POS provider and integration opportunity.

Sales partner may not bind POS credentials unless explicitly authorized.

Core rule:

POS integration is sensitive technical authority, not ordinary sales action.

38\. Relationship To AI Customer Center

AI customer center may reduce support cost during growth.

Sales partner and merchant may route common issues to AI customer center.

Examples:

how to scan QR/NFC
how to update menu
how to view request board
trial status question
conversion question
Entry Plate issue

Core rule:

AI customer center can support scale, but sensitive billing or credential issues require human escalation.

39\. Audit Events

Recommended audit events:

SALES\_PARTNER\_CREATED
SALES\_PARTNER\_ACTIVATED
SALES\_PARTNER\_SUSPENDED
LEAD\_REGISTERED
LEAD\_DUPLICATE\_DETECTED
LEAD\_ASSIGNED
TRIAL\_PROPOSED
TRIAL\_ACCEPTED
TRIAL\_INSTALLATION\_REQUESTED
TRIAL\_INSTALLED
AI\_MENU\_MATERIAL\_COLLECTED
TRIAL\_ACTIVATED\_FROM\_SALES
CONVERSION\_REQUESTED
CONVERSION\_VERIFIED
COMMISSION\_ELIGIBILITY\_CREATED
COMMISSION\_APPROVED
COMMISSION\_PAID
COMMISSION\_HELD
CLAWBACK\_REQUESTED
CLAWBACK\_APPLIED
SALES\_PARTNER\_TERMINATED

Minimum audit fields:

event\_id
sales\_partner\_id
lead\_id
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

40\. Failure Events

Invalid sales actions should create failure events.

Examples:

duplicate lead claim
commission claim without conversion
trial installation without Entry Media assignment
merchant data access outside scope
sales partner attempts POS credential binding
sales partner promises unsupported feature
clawback evidence missing

Example failure codes:

WOH.SALES.LEAD.DUPLICATE\_REVIEW\_REQUIRED
WOH.SALES.COMMISSION.CONVERSION\_REQUIRED
WOH.SALES.TRIAL\_INSTALL.ENTRY\_MEDIA\_REQUIRED
WOH.SALES.ACCESS.OUT\_OF\_SCOPE\_DENIED
WOH.SALES.POS\_CREDENTIAL.AUTHORITY\_DENIED
WOH.SALES.CLAIM.UNSUPPORTED\_FEATURE\_PROMISED
WOH.SALES.CLAWBACK.EVIDENCE\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

41\. Support Signals

Support signals may include:

TRIAL\_INSTALLED\_NOT\_ACTIVATED
AI\_MENU\_INTAKE\_BLOCKING\_TRIAL
FIRST\_7\_DAYS\_USAGE\_LOW
FIRST\_30\_DAYS\_TROUBLESHOOTING\_REQUIRED
TRIAL\_CONVERSION\_CONVERSATION\_DUE
TRIAL\_EXPIRED\_NO\_CONVERSION
ENTRY\_PLATE\_RECOVERY\_REQUIRED
SALES\_DUPLICATE\_LEAD\_DISPUTE
COMMISSION\_PAYOUT\_REVIEW\_REQUIRED
SALES\_PARTNER\_FRAUD\_REVIEW\_REQUIRED

Support Signal alerts.

It does not approve commission or conversion by itself.

42\. MVP Requirements

Sales Partner Field Growth MVP should support at least:

sales partner record
lead record
lead ownership
duplicate lead marker
trial installation reference
AI menu material collection marker
trial activation reference
conversion reference
base commission candidate
commission status
retention reward placeholder
clawback marker
field note
support signal
audit event
failure event

MVP may defer:

full sales partner portal
automatic commission payout
tax withholding automation
complex territory exclusivity
advanced CRM pipeline
sales gamification
multi-level referral hierarchy
automated clawback settlement

43\. Suggested Conceptual Entities

Suggested entities:

sales\_partners
sales\_partner\_status\_events
merchant\_leads
lead\_ownership\_events
lead\_duplicate\_reviews
sales\_field\_notes
trial\_sales\_links
sales\_conversion\_links
commission\_rules
commission\_eligibility\_events
commission\_payouts
commission\_clawbacks
sales\_campaigns
sales\_audit\_events
sales\_failure\_events
sales\_support\_signals

This document defines policy.

Actual schema may be designed later.

44\. Risk If Skipped

If Sales Partner Field Growth governance is skipped, risks include:

fast sales creates messy merchant records
duplicate lead disputes increase
trial plates are not recovered
sales partners overpromise features
AI menu setup becomes inconsistent
3-month trials do not convert systematically
commission payout becomes disputed
fraudulent or fake stores are rewarded
early troubleshooting is missed
CAC becomes uncontrolled

Therefore, sales growth must be modularized before aggressive field expansion.

45\. Final Rule

CatchMenu can scale through lightweight field sales only if lead, trial, conversion, commission, and early support are controlled.

Final rule:

Register lead.
Check duplicate.
Install trial Entry Plate with inventory trace.
Collect menu materials with consent.
Use AI Menu Intake.
Activate trial.
Support first 30 days.
Track usage.
Convert explicitly.
Pay commission only with verified conversion.
Reward retention carefully.
Hold payout when disputed.
Claw back abuse.
Recover Entry Plate if not converted.
Do not let sales speed destroy operational trust.
