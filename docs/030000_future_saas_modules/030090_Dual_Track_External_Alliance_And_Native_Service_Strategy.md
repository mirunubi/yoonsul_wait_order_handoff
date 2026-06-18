# 030090_Dual_Track_External_Alliance_And_Native_Service_Strategy

Legacy path: $old.

1\. Purpose

This document defines the Dual Track strategy for CatchMenu / Wait Order Handoff.

The restaurant technology market is moving in two directions at the same time.

One direction is external alliance.

Platforms integrate through APIs, SDKs, POS plugins, table-order channels, reservation/waiting channels, payment providers, and partner gateways.

The other direction is native all-in-one service.

Platforms try to own the full service path from waiting, preorder, seating, ordering, payment reference, KDS, CRM, CMS, support, billing, and merchant operation.

CatchMenu must pursue both tracks.

External alliance is required for early market compatibility.

Native all-in-one service is required for long-term product identity, data continuity, merchant retention, and operating OS expansion.

Core purpose:

Define Dual Track strategy.
Define external alliance path.
Define native all-in-one path.
Define why both tracks are required.
Define how POS/KDS/CMS/provider integration supports early compatibility.
Define how CatchMenu native service remains the product identity.
Define transition from lightweight trial to integrated operating OS.
Prevent false choice between external integration and native ownership.

Korean purpose:

Dual Track 전략을 정의한다.
외부 연합/연동 경로를 정의한다.
자체 all-in-one 경로를 정의한다.
왜 두 경로가 모두 필요한지 정의한다.
POS, KDS, CMS, provider 연동이 초기 시장 호환성을 어떻게 지원하는지 정의한다.
CatchMenu 자체 서비스가 제품 정체성으로 남아야 함을 정의한다.
가벼운 trial에서 통합 운영 OS로 올라가는 경로를 정의한다.
외부 연동과 자체 소유를 양자택일로 오해하는 것을 방지한다.

2\. Scope

This document covers:

dual track strategy
external alliance
provider integration
POS compatibility
KDS path
CMS connection
payment/provider reference
reservation/waiting channel integration
native all-in-one service
native data continuity
merchant owner console
AI customer center
billing entitlement
operating OS expansion
competitive response at architecture level

This document does not define:

field sales script
competitor-specific attack messaging
provider-specific API implementation
full POS replacement
full KDS implementation
payment provider settlement
legal alliance contract
sales commission payout

Related documents:

03300\_Open\_API\_Partner\_Alliance\_Readme.md
03400\_Provider\_Adapter\_Runtime\_Readme.md
03500\_External\_POS\_Integration\_Runtime\_Readme.md
03510\_POS\_Integration\_Module\_And\_All\_POS\_Expansion\_Strategy.md
03600\_Billing\_Plan\_Settlement\_Readme.md
03800\_Native\_All\_In\_One\_Service\_Runtime\_Readme.md
03900\_Merchant\_Success\_Troubleshooting\_Readme.md
sop/competitive\_response/SOP\_Competitor\_All\_In\_One\_Trend\_Response\_And\_Field\_Positioning.md

3\. Core Principle

CatchMenu must integrate outward and unify inward.

Core rule:

External alliance wins compatibility.
Native service wins continuity.
CatchMenu needs both.

Korean rule:

외부 연합은 호환성을 얻는다.
자체 서비스는 연속성을 얻는다.
CatchMenu에는 둘 다 필요하다.

4\. Why Dual Track Is Required

Restaurant operation is fragmented.

A store may already use:

existing POS
payment terminal
table-order device
reservation platform
waiting platform
delivery channel
KDS
inventory sheet
CRM/membership tool
promotion channel

Forcing replacement creates resistance.

But only connecting externally creates long-term dependency and data fragmentation.

Therefore, CatchMenu must:

connect to existing systems where needed
own its own guest and merchant service journey
normalize events into CatchMenu data model
preserve authority boundaries
grow native modules over time

Core rule:

Replacement-first is too heavy.
Integration-only is too weak.
Dual Track is required.

5\. External Alliance Track

External Alliance Track means CatchMenu connects to external providers.

External alliance may include:

external POS
payment provider
reservation channel
waiting channel
table-order provider
KDS provider
kiosk provider
delivery channel
CRM/loyalty provider
CMS/advertising partner
VAN/PG provider

Core rule:

External alliance reduces adoption friction and respects installed merchant infrastructure.

6\. Native Service Track

Native Service Track means CatchMenu owns its own service continuity.

Native service includes:

Entry Media
Guest WebApp
AI Menu Intake
Menu Context
Request Runtime
Waiting/Preorder
Reservation/Prepaid Pickup
Owner Console
Ad Promotion CMS
Support Signal
AI Customer Center
Billing Entitlement
Merchant Success
External POS Integration
Future KDS Integration
Operating OS Path

Core rule:

Native service is CatchMenu's product identity.

7\. External Alliance Is Not Product Identity

CatchMenu must not become only a bridge between other platforms.

If CatchMenu only connects external systems, risks include:

weak product identity
low merchant lock-in
provider dependency
limited data ownership
low pricing power
harder AI customer center context
harder operating OS expansion

Core rule:

External integration supports CatchMenu.
It must not replace CatchMenu.

8\. Native Service Is Not Isolation

Native service does not mean refusing external integration.

If CatchMenu ignores external systems, risks include:

high merchant adoption resistance
POS replacement objection
staff duplicate work
limited medium/large store adoption
weak payment/POS reference
weak KDS path
slow market penetration

Core rule:

Native service must remain open enough to integrate.

9\. Dual Track Operating Model

CatchMenu should operate both tracks at the same time.

Model:

Track A:
External alliance and provider compatibility

Track B:
Native all-in-one service continuity

How they work together:

External POS accepts existing order infrastructure.
Native request runtime owns guest intent.

External payment provider supplies transaction fact.
Native billing owns entitlement and plan meaning.

External KDS may execute kitchen ticket.
Native service owns handoff evidence and support signal.

External reservation channel may import reservation.
Native reservation/preorder governance owns CatchMenu flow.

Core rule:

External provider facts enrich CatchMenu.
They do not erase CatchMenu authority.

10\. Initial Market Entry Strategy

Initial entry should be lightweight.

Initial path:

QR/NFC Entry Plate
AI Menu Intake
Guest menu/request
Owner Console
Request Board
Manual POS fallback
First 7 days activation
First 30 days troubleshooting
Trial-to-paid conversion

Core rule:

Start light enough for small stores.
Design deep enough for larger stores.

11\. Compatibility Expansion Strategy

After initial entry, CatchMenu should expand compatibility.

Compatibility expansion:

POS Integration Module
Provider Adapter Runtime
KDS Integration Path
CMS/Promotion integration
Payment reference integration
Reservation/waiting channel integration
Partner API

Core rule:

Compatibility expansion should reduce operational friction without creating provider lock-in.

12\. Native Expansion Strategy

Native expansion should strengthen CatchMenu's own service path.

Native expansion:

waiting-to-order continuity
reservation/preorder governance
AI customer center
promotion CMS
merchant success dashboard
billing entitlement
usage analytics
operating OS workflow
inventory/sold-out availability
KDS kitchen continuity

Core rule:

Native expansion should increase service continuity, data continuity, and merchant retention.

13\. POS In Dual Track

POS is the strongest external dependency.

Dual Track POS strategy:

Do not force POS replacement.
Start POS-less or manual fallback when needed.
Build POS Integration Module.
Add POS providers progressively.
Keep CatchMenu request separate from POS order.
Use POS acceptance as provider fact.
Preserve CatchMenu handoff evidence.

Core rule:

POS is compatibility infrastructure, not CatchMenu identity.

14\. KDS In Dual Track

KDS is the kitchen execution path.

Dual Track KDS strategy:

Do not fake KDS integration.
Prepare KDS path.
Use POS acceptance boundary when needed.
Create KDS handoff candidate only when authority is clear.
Track kitchen status as execution fact.
Preserve CatchMenu support/evidence context.

Core rule:

KDS is kitchen continuity, not only screen display.

15\. CMS In Dual Track

CMS can be external partner surface or native CatchMenu surface.

Dual Track CMS strategy:

Native CMS controls CatchMenu guest surfaces.
Partner promotions may be integrated.
Emergency/service notices must take priority.
Paid ads must be labeled where required.
Billing decides chargeability.

Core rule:

CMS must follow service truth and priority, not override operation.

16\. Billing In Dual Track

Dual Track creates billing complexity.

Billing must support:

small-store low entry
feature add-ons
POS integration add-on
KDS integration add-on
CMS package
AI customer center support level
partner bundle
custom enterprise contract
provider integration cost
revenue share

Core rule:

Dual Track requires flexible billing.
One rigid plan cannot cover both lightweight entry and integrated operation.

17\. Data Strategy

External providers produce fragmented facts.

CatchMenu must normalize them into its own event model.

Data sources:

guest scan
menu view
request sent
store confirmation
manual POS fallback
POS handoff
POS callback
KDS handoff later
reservation/preorder event
CMS exposure
support signal
billing entitlement

Core rule:

Dual Track becomes valuable only when events are normalized into CatchMenu's service model.

18\. Authority Strategy

Dual Track must not collapse authority.

Examples:

CatchMenu request ≠ POS order
POS accepted ≠ payment completed
payment reference ≠ billing finality
KDS ticket ≠ customer promise unless surfaced correctly
CMS notice ≠ runtime truth
support signal ≠ state mutation

Core rule:

Integration does not merge authority.

19\. Support Strategy

Dual Track increases failure points.

Support must know:

which module owns state
which provider supplied fact
which handoff failed
which fallback applied
which evidence packet exists
which merchant expectation was set

Core rule:

Dual Track requires stronger support signal and evidence packet.

20\. Merchant Success Strategy

Merchant Success turns Dual Track into usable operation.

Merchant Success must check:

Entry Plate works
AI menu stable
request board adopted
manual POS fallback burden
POS integration readiness
KDS readiness
CMS interest
AI support interest
conversion readiness

Core rule:

Dual Track strategy fails if merchant operation does not stabilize.

21\. Competitive Positioning

Competitors may already own stronger current integrations.

CatchMenu should not pretend otherwise.

CatchMenu's position:

We start lighter.
We design wider.
We integrate progressively.
We preserve native service continuity.
We use AI to reduce setup burden.
We use Merchant Success to stabilize adoption.

Korean position:

우리는 더 가볍게 시작한다.
더 넓게 설계한다.
순차적으로 연동한다.
자체 서비스 연속성을 유지한다.
AI로 세팅 부담을 줄인다.
Merchant Success로 사용 정착을 만든다.

Core rule:

Do not compete by exaggerating current coverage.
Compete by lowering adoption friction and building credible expansion path.

22\. Small Store Strategy

Small stores need low-friction entry.

Small store path:

one Entry Plate
AI menu setup
basic request board
manual POS fallback
low monthly fee
first 30 days support

Core rule:

Small stores should not be forced into heavy integration before value proof.

23\. Medium Store Strategy

Medium stores may need selective integration.

Medium store path:

request board adoption
reservation/preorder
POS integration interest
promotion CMS
usage dashboard
AI customer center option

Core rule:

Medium stores should expand through add-ons after operational fit is proven.

24\. Large Store Strategy

Large stores need credibility and integration path.

Large store path:

POS integration package
KDS path
multi-store owner console
CMS governance
support signal
custom billing
evidence packet
operating OS roadmap

Core rule:

Large stores require proof of integration discipline, not only lightweight onboarding.

25\. Transition From External To Native

CatchMenu should not abruptly replace external systems.

Transition path:

external reference first
normalized event second
native workflow third
native module expansion fourth
provider dependency reduction later where feasible

Core rule:

Move from compatibility to continuity gradually.

26\. Anti-Monolith Rule

Native all-in-one must not become hidden monolith.

Modules must remain bounded:

Entry Media owns entry resolution.
AI Menu Intake owns draft creation.
Menu Runtime owns guest menu/request.
POS Integration owns POS handoff.
KDS Path owns kitchen handoff later.
CMS owns content exposure.
Billing owns entitlement.
Support owns cases.
Merchant Success owns adoption stabilization.

Core rule:

Unified experience does not mean collapsed modules.

27\. Dual Track Roadmap

Suggested roadmap:

Stage 0:
QR/NFC Entry Plate, AI Menu Intake, request board, manual POS fallback

Stage 1:
Merchant Success, trial conversion, flexible billing

Stage 2:
POS Integration Module and priority provider adapters

Stage 3:
Reservation/preorder, CMS, AI customer center

Stage 4:
KDS integration path and menu availability/sold-out control

Stage 5:
Operating OS expansion and advanced analytics

Stage 6:
Multi-store/native all-in-one service maturity

Core rule:

Roadmap should add depth without destroying lightweight entry.

28\. Field Claim Boundary

Allowed field claim:

CatchMenu can start lightly and is designed to integrate progressively with POS/KDS/CMS and operating workflows.

Not allowed:

CatchMenu already replaces every POS, KDS, reservation, CRM, and table-order system.

Korean allowed:

CatchMenu는 가볍게 시작하고, POS/KDS/CMS 및 운영 흐름과 단계적으로 연동되도록 설계되어 있습니다.

Core rule:

Dual Track must be explained as staged strategy, not finished coverage.

29\. Audit Events

Recommended audit events:

DUAL\_TRACK\_STRATEGY\_VERSION\_CREATED
EXTERNAL\_ALLIANCE\_PATH\_DEFINED
NATIVE\_SERVICE\_PATH\_DEFINED
PROVIDER\_COMPATIBILITY\_ADDED
NATIVE\_MODULE\_ENABLED
NATIVE\_MODULE\_DEPENDENCY\_UPDATED
DUAL\_TRACK\_ROADMAP\_UPDATED
FIELD\_CLAIM\_BOUNDARY\_UPDATED

30\. Support Signals

Support signals may include:

DUAL\_TRACK\_EXPECTATION\_MISMATCH
EXTERNAL\_PROVIDER\_REQUIRED
NATIVE\_MODULE\_NOT\_READY
POS\_PATH\_REQUIRED
KDS\_PATH\_REQUIRED
CMS\_PATH\_REQUIRED
BILLING\_FLEXIBILITY\_REQUIRED
MERCHANT\_EXPECTS\_FINISHED\_ALL\_IN\_ONE

Support Signal alerts.

It does not change strategy state by itself.

31\. MVP Requirements

MVP should support at least:

Dual Track strategy declaration
external alliance boundary
native service boundary
POS compatibility statement
manual fallback statement
native module dependency map
field claim boundary
support signal list
roadmap stage map

MVP may defer:

full partner alliance automation
full native POS replacement
full KDS runtime
full inventory runtime
advanced CRM
multi-provider certification platform

32\. Suggested Conceptual Entities

Suggested entities:

dual\_track\_strategy\_versions
external\_alliance\_paths
native\_service\_paths
dual\_track\_module\_dependencies
dual\_track\_roadmap\_stages
dual\_track\_claim\_boundaries
dual\_track\_support\_signals
dual\_track\_audit\_events

This document defines strategy.

Actual schema may be designed later.

33\. Risk If Skipped

If Dual Track strategy is skipped, risks include:

CatchMenu becomes too isolated from real merchant infrastructure
or becomes only a connector for other providers
POS/KDS/CMS expansion becomes incoherent
field sales overclaims finished all-in-one
small-store entry and large-store expansion conflict
billing cannot handle mixed provider/native modules
support cannot explain ownership
native all-in-one identity weakens

Therefore, CatchMenu must explicitly define Dual Track strategy.

34\. Final Rule

CatchMenu must connect outward and unify inward.

Final rule:

Use external alliance for compatibility.
Use native service for continuity.
Start lightweight.
Respect existing POS.
Build provider adapters.
Prepare KDS path.
Connect CMS and support.
Keep billing flexible.
Normalize events.
Preserve authority boundaries.
Do not overclaim finished coverage.
Do not become only an external bridge.
Grow from trial plate to native operating OS.
