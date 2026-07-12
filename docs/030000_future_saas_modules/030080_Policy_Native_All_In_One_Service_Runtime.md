# 030080_Policy_Native_All_In_One_Service_Runtime

Legacy path: $old.

1\. Purpose

This folder defines the Native All-In-One Service Runtime for CatchMenu / Wait Order Handoff.

CatchMenu is designed as a native all-in-one restaurant service from the beginning.

CatchMenu is not only a QR menu.

CatchMenu is not only an external POS adapter.

CatchMenu is not only an AI menu intake tool.

CatchMenu is a unified software service that connects guest entry, menu, request, waiting, preorder, reservation, prepaid pickup, promotion, owner console, support signal, AI customer center, billing entitlement, external POS integration, and future KDS integration into one controlled service path.

External POS and provider integrations are required for market compatibility.

However, CatchMenu's product identity is its own unified service continuity.

Core purpose:

Define CatchMenu as a native all-in-one service.
Define unified guest journey.
Define unified merchant operation journey.
Define POS and KDS as part of the long-term native service path.
Define external POS integration as compatibility layer.
Define native data, event, authority, audit, and support continuity.
Define how QR/NFC entry, AI Menu Intake, request, reservation, CMS, support, billing, POS, and KDS connect.
Preserve modular architecture while delivering one service experience.

Korean purpose:

CatchMenu를 자체 일통 서비스로 정의한다.
손님 여정의 통합 흐름을 정의한다.
업주 운영 여정의 통합 흐름을 정의한다.
POS와 KDS를 장기 자체 서비스 경로의 일부로 정의한다.
외부 POS 연동을 호환성 레이어로 정의한다.
자체 데이터, 이벤트, 권한, 감사, 지원 연속성을 정의한다.
QR/NFC 진입, AI 메뉴 입력, 요청, 예약, CMS, 지원, 과금, POS, KDS가 어떻게 연결되는지 정의한다.
모듈형 아키텍처를 유지하면서 하나의 서비스 경험을 제공한다.

2\. Scope

This folder covers:

native all-in-one service runtime
unified guest journey
unified merchant journey
QR/NFC entry continuity
AI menu intake continuity
menu and request runtime
waiting and preorder runtime
reservation and prepaid pickup runtime
promotion CMS continuity
owner console continuity
support signal continuity
AI customer center continuity
billing entitlement continuity
external POS compatibility
future KDS integration path
native event model
native authority boundary
native service audit
native service failure handling

This folder does not define:

competitor response SOP
field sales script
external POS adapter implementation detail
payment provider implementation detail
full POS replacement product
full KDS implementation detail
hardware table-order manufacturing
legal contract text
tax/accounting ledger

Related folders:

docs/000100_project_foundation/000300_documentation_governance/000300_Readme_Documentation_Governance.md/
docs/001000_mvp_scope/001100_Policy_CatchMenu_I18n_Order_Request_Translation.md/
docs/02400\_owner\_console/ (not yet implemented)
docs/02600\_merchant\_ops/ (not yet implemented)
docs/003000_saas_runtime/003100_Readme_Entry_Media_Inventory.md/
docs/030000_future_saas_modules/030050_Readme_Ad_Promotion_CMS.md
docs/03300\_open\_api\_partner\_alliance/
docs/03400\_provider\_adapter\_runtime/
docs/03500\_external\_pos\_integration\_runtime/
docs/030000_future_saas_modules/030060_Readme_Billing_Plan_Settlement.md
docs/030000_future_saas_modules/030070_Readme_Sales_Partner_Field_Growth.md

3\. Core Principle

CatchMenu is a native unified service.

Core rule:

CatchMenu owns the service journey.
External providers support the journey.
POS and KDS are part of the long-term unified path.
External integration does not define CatchMenu's product identity.

Korean rule:

CatchMenu는 서비스 여정을 소유한다.
외부 제공사는 그 여정을 보완한다.
POS와 KDS는 장기 일통 경로의 일부다.
외부 연동이 CatchMenu의 제품 정체성을 정의하지 않는다.

4\. Product Identity

CatchMenu product identity:

software-first restaurant service
QR/NFC guest entry
AI-assisted menu setup
multilingual menu and request flow
waiting-to-order handoff
reservation and prepaid pickup flow
merchant owner console
ad/promotion/notice CMS
AI customer center-ready support
billing entitlement-based feature control
external POS integration-capable
future KDS integration-capable
low-friction trial SaaS

CatchMenu is not merely:

static QR menu
table-order hardware replacement
POS adapter
payment gateway
reservation app
advertising CMS
AI chatbot
field sales trial plate program

Core rule:

CatchMenu is the unified software layer between guest intent and store operation.

5\. Native Service Boundary

Native service boundary means CatchMenu owns its own service flow.

CatchMenu may own:

entry context
menu context
guest session
language context
item selection
request state
waiting/preorder relation
reservation/prepaid pickup policy
promotion exposure
owner console view
support signal
AI customer center context
billing entitlement
POS handoff candidate
KDS handoff candidate
evidence packet

External systems may own:

external POS final order
external payment provider fact
external reservation import
external table-order device input
external KDS execution if integrated externally
provider callback
provider transaction reference

Core rule:

CatchMenu must know what it owns and what it references.

6\. Native Service Versus External Compatibility

Native service means unified internal continuity.

External compatibility means connection to installed merchant infrastructure.

Native service:
guest journey, menu/request state, reservation/preorder policy, promotion surface, owner console, support signal, billing entitlement, event continuity

External compatibility:
POS order acceptance, payment provider fact, provider callback, external table layout, external reservation import, external channel data

Core rule:

External compatibility extends CatchMenu.
It does not replace CatchMenu service ownership.

7\. Unified Guest Journey

CatchMenu should provide one coherent guest journey.

Possible guest journey:

QR/NFC scan
store context resolved
menu context opened
language selected
menu viewed
items explored
request or preorder created
waiting or pickup context linked
store confirmation shown
reservation/payment notice shown if applicable
promotion or emergency notice displayed
support path available
POS/KDS handoff referenced if enabled

Core rule:

Guest should experience one CatchMenu flow, not scattered modules.

8\. Unified Merchant Journey

CatchMenu should provide one coherent merchant journey.

Possible merchant journey:

trial onboarding
Entry Plate activation
AI menu setup
Owner Console access
request board operation
reservation/preorder management
promotion/notice management
usage summary
support signal review
billing/plan status
POS integration status
future KDS integration status
AI customer center support

Core rule:

Merchant should operate through a unified CatchMenu surface.

9\. Native Runtime Modules

CatchMenu native service may include:

Entry Media Runtime
AI Menu Intake
Guest WebApp
Stage 0 Menu/Request Runtime
Waiting Preorder Runtime
Reservation Preorder Runtime
Ad Promotion CMS
Owner Console
Merchant Ops
Support Signal
AI Customer Center
Billing Plan Entitlement
External POS Integration
Provider Adapter Runtime
Future KDS Integration Runtime

These modules are separate internally but form one service externally.

Core rule:

Modules are bounded internally.
Service experience is unified externally.

10\. Entry Media As Service Door

Entry Media is the door into CatchMenu.

Entry Media resolves:

entry\_media\_token
entry\_media\_id
merchant\_store\_id
menu\_context\_id
enabled\_stage
guest surface
service status

Entry Media is not only a printed QR sticker.

Core rule:

Entry Media opens the CatchMenu service, not only a static menu.

11\. AI Menu Intake As Activation Engine

AI Menu Intake makes lightweight onboarding possible.

AI Menu Intake may process:

menu board photo
paper menu photo
PDF menu
existing online menu image
price list
option list
category structure
allergy/critical warning hints
translation draft

AI Menu Intake should produce a draft, not uncontrolled live menu.

Core rule:

AI Menu Intake accelerates setup.
Merchant or authorized reviewer confirms accuracy.

12\. Menu And Request Runtime

Menu and request runtime is the first operational layer.

It may include:

menu view
item detail
option selection
show-to-staff
send request
store request board
store confirmation
manual POS fallback
critical request warning
translation support

Core rule:

Menu request runtime converts guest intent into visible store operation.

13\. Waiting And Preorder Runtime

Waiting and preorder are core parts of CatchMenu's long-term service path.

They may connect:

waiting registration
estimated seating
menu preselection
preorder intent
store readiness
table readiness
inventory/sold-out signal
POS handoff candidate
KDS handoff candidate

Core rule:

Waiting time should become preparation time when operationally safe.

14\. Reservation And Prepaid Pickup Runtime

Reservation and prepaid pickup are native CatchMenu flows.

They may include:

same-day pickup reservation
prepaid pickup
advance reservation
deposit
group order
cancellation rule
no-show handling
refund reference
preparation state
support evidence

Core rule:

Reservation and prepaid pickup must connect customer commitment with store preparation state.

15\. Ad Promotion CMS Runtime

Ad Promotion CMS is part of the native service experience.

It may display:

merchant promotion
HQ campaign
emergency notice
reservation notice
pickup notice
partner promotion
trial notice
service notice

Core rule:

Promotion follows the service journey.
Promotion must not override runtime truth.

16\. Owner Console Runtime

Owner Console is the merchant-facing command surface.

Owner Console may include:

store profile
menu context
AI menu draft
request board
reservation/preorder status
promotion management
usage summary
trial status
billing status
support entry
POS integration status
future KDS status

Core rule:

Owner Console should unify merchant operation without exposing unsafe authority.

17\. Merchant Ops Runtime

Merchant Ops supports the operational side of CatchMenu.

Merchant Ops may handle:

trial onboarding
Entry Plate installation coordination
menu setup support
first 30 days troubleshooting
conversion follow-up
support escalation
Entry Plate recovery
service suspension and reactivation support

Core rule:

Native service needs operational follow-through, not only software screens.

18\. Support Signal Runtime

Support Signal connects runtime events to support attention.

Support Signal may come from:

request board inactivity
trial usage low
AI menu review blocked
Entry Media inactive
POS handoff failure
payment status unknown
reservation dispute
promotion policy conflict
billing issue
KDS handoff failure later

Core rule:

Support signal alerts humans or AI.
It does not mutate business state by itself.

19\. AI Customer Center Runtime

AI Customer Center should be designed as part of the native service.

AI Customer Center may support:

merchant onboarding question
menu setup issue
Entry Plate scan issue
request board usage
trial status question
billing question
reservation/no-show question
POS integration issue
provider failure explanation
guest FAQ

AI Customer Center should rely on trusted service context.

Core rule:

AI customer center reduces operating cost only when connected to verified service data.

20\. Billing Entitlement Runtime

Billing entitlement controls feature availability.

Plan may control:

Stage 0 usage
AI Menu Intake
reservation/preorder
promotion CMS
external POS integration
future KDS integration
usage dashboard
support level
Entry Media count

Core rule:

Feature access follows billing entitlement, not hidden UI toggles.

21\. External POS As Compatibility Layer

External POS integration is required for real restaurant operation.

But external POS is a compatibility layer.

Flow:

CatchMenu request
→ CatchMenu handoff candidate
→ external POS order if integrated
→ manual fallback if not integrated or failed

Core rule:

External POS receives operational handoff.
It does not define the whole CatchMenu journey.

22\. Future KDS As Native Continuity Path

KDS should be considered part of the long-term native continuity path.

KDS may receive:

store-confirmed order candidate
POS-accepted order reference
preorder-ready ticket
reservation/group-order prep signal
remake/retry signal
fulfillment status

KDS may be external at first and native later.

Core rule:

KDS is kitchen execution continuity.
It must be connected by explicit authority and state guards.

23\. POS And KDS Together

POS and KDS must not be treated as isolated attachments.

Long-term flow:

guest intent
→ CatchMenu request
→ store confirmation
→ POS order reference
→ KDS ticket
→ preparation status
→ fulfillment status
→ support/evidence

Core rule:

POS and KDS are separate authorities connected by controlled handoff.

24\. Native Data Advantage

Native all-in-one design creates data advantage.

Native data may support:

AI menu improvement
translation quality
customer support
merchant troubleshooting
usage analytics
trial conversion scoring
promotion performance
reservation/no-show evidence
POS handoff debugging
KDS delay analysis
billing entitlement review
sales partner performance

Core rule:

Unified data is CatchMenu's long-term moat.

25\. Native Event Model

Native service requires shared event model.

Events may include:

entry\_scanned
menu\_viewed
menu\_draft\_created
menu\_published
items\_selected
request\_sent
store\_confirmed
waiting\_registered
preorder\_created
reservation\_created
prepaid\_pickup\_created
promotion\_displayed
support\_signal\_created
pos\_handoff\_attempted
pos\_handoff\_accepted
kds\_handoff\_attempted
kds\_ticket\_created
billing\_entitlement\_changed

Core rule:

Events connect modules without collapsing ownership.

26\. Native Authority Model

Native service requires explicit authority boundaries.

Examples:

Entry Media owns entry resolution.
Menu Runtime owns menu/request state.
Reservation Runtime owns reservation/preorder state.
CMS owns content exposure.
Billing owns entitlement.
Support owns case workflow.
Provider Adapter owns provider translation.
External POS owns external POS order acceptance when integrated.
KDS owns kitchen execution state when enabled.

Core rule:

Unified service experience must not confuse authority ownership.

27\. Native Audit Model

Every major native service transition should be auditable.

Audit categories:

entry audit
menu audit
request audit
reservation audit
promotion audit
support audit
billing audit
POS handoff audit
KDS handoff audit
provider callback audit
admin action audit

Core rule:

Native service trust depends on explainable history.

28\. Native Failure Model

All-in-one service still needs failure governance.

Failure examples:

entry resolution failed
menu context missing
AI menu draft wrong
request board inactive
reservation state conflict
promotion policy conflict
billing entitlement missing
POS handoff failed
KDS handoff failed
support context incomplete

Core rule:

Integrated service reduces fragmentation but does not remove failure handling.

29\. Native Degraded Operation

Degraded operation must be part of native service.

Degraded options:

show-to-staff mode
manual POS entry
manual KDS/kitchen note
request board fallback
Owner Console warning
support signal
evidence packet
replay queue
temporary provider suspension

Core rule:

Native service must survive partial integration failure.

30\. MVP Position

MVP should be small but directionally native all-in-one.

MVP should prove:

Entry Media opens service context
AI Menu Intake reduces setup friction
Guest WebApp displays menu/request flow
Owner Console receives store request
Trial plan controls access
Support Signal exists
Manual POS fallback is valid
Usage summary supports conversion

MVP should not attempt full POS/KDS replacement.

Core rule:

MVP is not complete all-in-one.
MVP must be architected toward all-in-one.

31\. Scale Position

Scale stage may add:

External POS integration
Provider Adapter
Reservation Preorder
Ad Promotion CMS
AI Customer Center
Billing automation
Merchant Success automation
Waiting/preorder continuity
Inventory reference
KDS integration candidate

Core rule:

Scale stage increases native continuity and external compatibility together.

32\. Long-Term Position

Long-term CatchMenu may become:

restaurant guest-entry OS
waiting/order handoff OS
merchant lightweight operations console
AI-supported menu and support platform
promotion and reservation platform
POS-connected service layer
KDS-connected kitchen continuity layer

Core rule:

CatchMenu should not remain a thin QR menu.

33\. Native All-In-One Strength

CatchMenu's native strength is design-first integration.

Strengths:

designed as unified service from the beginning
software-first adoption
QR/NFC Entry Plate entry
AI Menu Intake setup speed
POS-less start possible
external POS compatibility planned
future KDS continuity planned
event/audit/support model from the beginning
AI customer center-ready context
billing entitlement linked to modules

Core rule:

CatchMenu's advantage is not only feature count.
Its advantage is unified design from the beginning.

34\. Hardware-Light Native All-In-One

CatchMenu all-in-one does not require heavy hardware-first deployment.

Initial deployment may use:

one Entry Plate
AI-generated menu
Owner Console
request board
manual POS fallback
support signal
trial plan

Later expansion may add:

POS integration
reservation/preorder
promotion CMS
AI customer center
KDS integration
inventory reference
CRM/membership

Core rule:

All-in-one service can begin with software and one plate.

35\. Audit Events

Recommended audit events:

NATIVE\_SERVICE\_MODULE\_ENABLED
NATIVE\_SERVICE\_MODULE\_DISABLED
NATIVE\_SERVICE\_ROUTE\_CREATED
NATIVE\_SERVICE\_ROUTE\_CHANGED
SERVICE\_JOURNEY\_EVENT\_LINKED
SERVICE\_AUTHORITY\_ASSIGNED
SERVICE\_AUTHORITY\_CHANGED
MODULE\_DEPENDENCY\_CREATED
MODULE\_DEPENDENCY\_CHANGED
EXTERNAL\_POS\_ATTACHED
EXTERNAL\_POS\_DETACHED
KDS\_PATH\_ENABLED
KDS\_PATH\_DISABLED

Minimum audit fields:

event\_id
module
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

36\. Failure Events

Example failure codes:

WOH.NATIVE\_SERVICE.AUTHORITY\_CONFLICT
WOH.NATIVE\_SERVICE.EVENT\_LINK\_MISSING
WOH.NATIVE\_SERVICE.MODULE\_DEPENDENCY\_MISSING
WOH.NATIVE\_SERVICE.RUNTIME\_ROUTE\_CONFLICT
WOH.NATIVE\_SERVICE.EXTERNAL\_POS\_REQUIRED
WOH.NATIVE\_SERVICE.KDS\_PATH\_NOT\_READY
WOH.NATIVE\_SERVICE.ENTITLEMENT\_REQUIRED
WOH.NATIVE\_SERVICE.SUPPORT\_CONTEXT\_INCOMPLETE

Failure/error naming is governed by:

docs/000080_Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy.md

37\. Support Signals

Support signals may include:

NATIVE\_SERVICE\_JOURNEY\_BROKEN
MODULE\_DEPENDENCY\_MISSING
OWNER\_CONSOLE\_CONTEXT\_INCOMPLETE
AI\_CUSTOMER\_CENTER\_CONTEXT\_INSUFFICIENT
POS\_COMPLEMENT\_REQUIRED
KDS\_COMPLEMENT\_REQUIRED
TRIAL\_TO\_NATIVE\_SERVICE\_GAP
SERVICE\_ENTITLEMENT\_CONFLICT

Support Signal alerts.

It does not change business state by itself.

38\. Relationship To External POS Integration

External POS Integration is a required compatibility module.

It connects CatchMenu service journey to installed POS infrastructure.

External POS Integration owns:

POS provider binding
POS menu mapping
POS table mapping
POS order handoff
POS acceptance/rejection evidence
manual POS fallback

Native All-In-One Runtime owns the service journey into which POS fits.

Core rule:

POS integration is necessary.
Native service continuity remains primary.

39\. Relationship To Future KDS Integration

Future KDS Integration should connect kitchen execution to native service journey.

KDS should not be a disconnected later add-on.

Potential future KDS documents may define:

KDS handoff candidate
KDS ticket
KDS retry/remake
KDS delay signal
KDS prep status
KDS fulfillment status

Core rule:

KDS belongs to kitchen execution continuity within the native service path.

40\. Relationship To Billing Plan Settlement

Billing Plan controls which native modules are available.

Examples:

AI Menu Intake enabled
reservation/preorder enabled
Ad Promotion CMS enabled
external POS integration enabled
future KDS integration enabled
support level enabled

Core rule:

Native service features must be entitlement-controlled.

41\. Relationship To Sales Partner Field Growth

Sales Partner Field Growth brings merchants into the native service through low-friction trial.

Sales promise should remain simple:

one plate
AI menu setup
3-month test
low burden
convert if useful
return if not useful

Native service provides the deeper retention path after trial.

Core rule:

Field sales wins entry.
Native all-in-one service wins retention.

42\. MVP Requirements

Native All-In-One Service Runtime MVP should support at least:

native service declaration
module dependency map
guest journey map
merchant journey map
authority boundary map
event model baseline
Entry Media connection
AI Menu Intake connection
Guest WebApp connection
Owner Console connection
request board connection
trial/billing entitlement connection
manual POS fallback connection
support signal connection
future POS/KDS path declaration

MVP may defer:

full internal POS
full internal KDS
full internal CRM
full internal inventory runtime
full payment settlement engine
hardware table-order suite
advanced kitchen optimization

43\. Suggested Conceptual Entities

Suggested entities:

native\_service\_modules
native\_service\_dependencies
native\_service\_routes
native\_service\_authority\_rules
native\_service\_event\_links
native\_service\_audit\_events
native\_service\_failure\_events
native\_service\_support\_signals

This document defines service strategy and runtime boundary.

Actual schema may be designed later.

44\. Risk If Skipped

If Native All-In-One Service Runtime is skipped, risks include:

CatchMenu becomes only a QR menu
external POS defines product direction
modules grow separately without unified experience
Owner Console becomes fragmented
AI Customer Center lacks trusted context
billing entitlement does not match features
POS/KDS path becomes late retrofit
sales promise exceeds service reality
long-term retention weakens

Therefore, CatchMenu must define itself as a native all-in-one service before module expansion becomes fragmented.

45\. Final Rule

CatchMenu is a native unified service with POS and KDS continuity planned from the beginning.

Final rule:

Own the service journey.
Start with software.
Use QR/NFC Entry Plate.
Use AI Menu Intake.
Provide unified Owner Console.
Connect request, waiting, reservation, promotion, support, billing, POS, and KDS path.
Use external POS as compatibility layer.
Prepare KDS as kitchen continuity layer.
Do not let external providers define product identity.
Keep modules bounded.
Share events.
Preserve authority.
Deliver one service experience.
