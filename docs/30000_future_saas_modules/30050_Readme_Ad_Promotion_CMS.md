# 30050_Readme_Ad_Promotion_CMS

Legacy path: $old.

1\. Purpose

This folder defines the Ad Promotion CMS for CatchMenu / Wait Order Handoff.

CatchMenu surfaces may include guest-facing screens, merchant-facing owner console screens, HQ-managed notices, trial promotion areas, reservation and pickup screens, menu screens, request completion screens, and future waiting/order handoff screens.

These surfaces may display advertisements, merchant promotions, HQ announcements, emergency notices, campaign banners, local offers, trial messages, and service notices.

Ad Promotion CMS defines how promotional and notice content is created, reviewed, approved, scheduled, displayed, measured, suspended, and audited.

Core purpose:

Define advertisement and promotion CMS governance.
Define notice and announcement governance.
Define guest-facing and merchant-facing content surfaces.
Define ad slot placement.
Define merchant promotion rules.
Define HQ campaign rules.
Define content review and approval.
Define publishing and scheduling.
Define impression, click, and conversion events.
Define privacy and personalization limits.
Define emergency notice priority.
Prevent unsafe, misleading, or unauthorized content exposure.

Korean purpose:

광고 및 프로모션 CMS 거버넌스를 정의한다.
공지 및 안내 거버넌스를 정의한다.
손님 화면과 업주 화면의 콘텐츠 노출 지면을 정의한다.
광고 슬롯 배치를 정의한다.
매장 프로모션 규칙을 정의한다.
HQ 캠페인 규칙을 정의한다.
콘텐츠 검수와 승인을 정의한다.
게시와 예약 노출을 정의한다.
노출, 클릭, 전환 이벤트를 정의한다.
개인정보와 개인화 제한을 정의한다.
긴급 공지 우선순위를 정의한다.
안전하지 않거나 오해를 부르거나 승인되지 않은 콘텐츠 노출을 방지한다.

2\. Scope

This folder covers:

advertisement
promotion
merchant promotion
HQ campaign
local offer
banner
notice
announcement
emergency notice
ad slot
placement
surface
creative asset
content review
content approval
publishing schedule
impression event
click event
conversion event
personalization limit
privacy boundary
ad suspension
content audit

This folder does not define:

guest runtime state machine
payment settlement
ad revenue settlement engine
external ad exchange
real-time bidding
full marketing automation CRM
legal final advertising contract
external advertiser portal

Related folders:

docs/02500\_guest\_webapp/
docs/02400\_owner\_console/
docs/03000\_catchmenu\_hq/
docs/00400\_identity\_access/
docs/02700\_observability\_failure\_recovery/
docs/03100\_reservation\_preorder\_governance/
docs/03300\_open\_api\_partner\_alliance/

3\. Core Principle

Ad Promotion CMS controls content exposure, not runtime authority.

Core rule:

Ad CMS decides what approved content may appear on approved surfaces.
Ad CMS does not own guest runtime, payment, order, reservation, or settlement authority.

Korean rule:

Ad CMS는 승인된 화면 영역에 어떤 승인 콘텐츠가 노출될 수 있는지를 결정한다.
Ad CMS는 손님 런타임, 결제, 주문, 예약, 정산 권한을 소유하지 않는다.

4\. Content Categories

Ad Promotion CMS may manage these content categories:

PAID\_ADVERTISEMENT
MERCHANT\_PROMOTION
HQ\_CAMPAIGN
LOCAL\_OFFER
SEASONAL\_PROMOTION
TRIAL\_NOTICE
SERVICE\_NOTICE
SYSTEM\_ANNOUNCEMENT
EMERGENCY\_NOTICE
RESERVATION\_NOTICE
PICKUP\_NOTICE
WAITING\_NOTICE
PARTNER\_PROMOTION

Each content category may have different approval, placement, and priority rules.

5\. Advertisement

Advertisement means paid or sponsored promotional content.

Advertisement may include:

brand banner
partner banner
paid placement
campaign image
clickable creative
sponsored offer
external advertiser creative

Advertisement must be reviewed before publishing.

Core rule:

Paid advertisement requires approval, schedule, placement, and measurement.

6\. Merchant Promotion

Merchant Promotion means content created or requested by the merchant for its own store.

Examples:

today's menu
pickup discount
limited-time offer
seasonal menu
sold-out notice if promotional surface is used
local event
trial promotion
store-specific coupon notice

Merchant Promotion should be merchant/store-scoped.

Core rule:

Merchant Promotion may promote the merchant's own store.
It must not affect other merchants unless explicitly approved.

7\. HQ Campaign

HQ Campaign means CatchMenu-managed platform-level content.

Examples:

CatchMenu trial campaign
new feature announcement
partner campaign
service adoption campaign
reservation feature guide
QR/NFC usage guide
waiting order handoff promotion
platform-wide seasonal promotion

HQ Campaign may appear across multiple merchants or surfaces if approved.

Core rule:

HQ Campaign requires platform-level authority and scope control.

8\. Notice And Announcement

Notice and Announcement are informational content, not paid ads.

Examples:

service maintenance notice
feature update notice
trial expiry notice
reservation policy notice
pickup rule notice
support notice
merchant operation notice

Notice should be clear and non-misleading.

Core rule:

Notice informs.
Notice must not be disguised as user consent or payment confirmation.

9\. Emergency Notice

Emergency Notice has higher priority than normal ads or promotions.

Examples:

system outage
payment issue
provider integration failure
store temporarily unavailable
reservation disabled
safety warning
incorrect menu data warning
critical support notice

Emergency Notice may override normal ad slots.

Core rule:

Emergency notice overrides promotion when user safety, service reliability, or transaction clarity is at risk.

10\. Surfaces

Ad Promotion CMS may publish to approved surfaces.

Guest-facing surfaces:

QR/NFC entry screen
guest menu top banner
menu category banner
menu item detail banner
selection/cart screen
show-to-staff screen
send request confirmation screen
request completed screen
waiting screen
pickup reservation screen
prepaid pickup completion screen
no-show/cancellation policy screen

Merchant-facing surfaces:

Owner Console dashboard
request board notice area
trial status page
usage summary page
AI menu intake page
support page
service status page

HQ-facing surfaces:

CatchMenu HQ campaign manager
ad approval queue
notice management
emergency notice control
content audit view

Core rule:

Content may appear only on approved surfaces.

11\. Ad Slot

Ad Slot defines where content may appear.

Suggested slot types:

GUEST\_ENTRY\_TOP
GUEST\_MENU\_TOP
GUEST\_MENU\_CATEGORY\_INLINE
GUEST\_SELECTION\_BOTTOM
GUEST\_REQUEST\_CONFIRMATION
GUEST\_REQUEST\_COMPLETED
GUEST\_WAITING\_SCREEN
GUEST\_PICKUP\_COMPLETED
OWNER\_CONSOLE\_DASHBOARD
OWNER\_CONSOLE\_TRIAL\_NOTICE
OWNER\_CONSOLE\_SUPPORT\_NOTICE
REQUEST\_BOARD\_NOTICE
HQ\_INTERNAL\_NOTICE

Each slot should define:

slot\_id
surface
placement
content\_type\_allowed
priority\_rule
size\_rule
click\_allowed
dismiss\_allowed
start\_at
end\_at

Core rule:

Slot controls placement.
Content approval controls what may fill it.

12\. Placement Priority

Placement priority should be explicit.

Suggested priority order:

EMERGENCY\_NOTICE
SERVICE\_NOTICE
LEGAL\_OR\_POLICY\_NOTICE
STORE\_OPERATION\_NOTICE
RESERVATION\_OR\_PICKUP\_NOTICE
MERCHANT\_PROMOTION
HQ\_CAMPAIGN
PAID\_ADVERTISEMENT
DEFAULT\_EMPTY\_STATE

Core rule:

Operational clarity outranks promotion.

13\. Content Lifecycle

Suggested content lifecycle:

DRAFT
SUBMITTED
REVIEW\_PENDING
REVISION\_REQUIRED
APPROVED
SCHEDULED
PUBLISHED
PAUSED
EXPIRED
REJECTED
ARCHIVED
EMERGENCY\_DISABLED

Meaning:

DRAFT
\= content being prepared

SUBMITTED
\= content submitted for review

REVIEW\_PENDING
\= reviewer must evaluate content

REVISION\_REQUIRED
\= content needs correction

APPROVED
\= content approved but not necessarily live

SCHEDULED
\= content has future publish schedule

PUBLISHED
\= content is live

PAUSED
\= temporarily stopped

EXPIRED
\= ended by schedule

REJECTED
\= not allowed

ARCHIVED
\= retained for history

EMERGENCY\_DISABLED
\= disabled due to risk

14\. Content Review

Content review should check:

truthfulness
merchant scope
surface suitability
image/text quality
price or discount accuracy
reservation or pickup policy consistency
food safety or allergy risk
legal/advertising risk
misleading payment/order wording
prohibited content
privacy risk
brand suitability

Core rule:

Content review protects customer trust and merchant safety.

15\. Content Approval

Approval authority may depend on content type.

Examples:

Merchant Promotion
\= merchant owner submission \+ HQ or automated review if required

HQ Campaign
\= HQ campaign authority

Paid Advertisement
\= HQ ad approval

Emergency Notice
\= HQ admin or authorized incident operator

Reservation Policy Notice
\= policy owner approval

Partner Promotion
\= partner alliance approval

Core rule:

Content approval must match content risk and surface impact.

16\. Prohibited Content

Prohibited content may include:

misleading price
false discount
unapproved medical/health claim
unsafe food claim
adult or inappropriate content
illegal product promotion
competitor defamation
unauthorized use of another brand
fake scarcity
misleading payment completion message
misleading reservation guarantee
content that hides cancellation/refund conditions

Core rule:

Content must not mislead customers or bypass operational policy.

17\. Merchant Promotion Boundary

Merchant Promotion must be scoped.

Merchant may promote:

own store
own menu
own discount
own event
own pickup promotion
own reservation guidance

Merchant must not promote:

another merchant without approval
external unrelated service without approval
misleading discount
unavailable menu
unapproved health claim
policy conflicting with CatchMenu reservation/refund rules

Core rule:

Merchant promotion is store-scoped unless HQ approves broader scope.

18\. Reservation And Pickup Notice

Reservation and pickup-related notices must align with Reservation Preorder Governance.

Examples:

cancellation deadline notice
pickup deadline notice
deposit policy notice
no-show policy notice
refund limitation notice
preparation started notice
group order rule notice

Core rule:

Reservation notice must match active policy version.

Related folder:

docs/03100\_reservation\_preorder\_governance/

19\. Payment And Order Wording Guard

Ads and notices must not misrepresent transaction state.

Prohibited wording unless true:

payment completed
order confirmed
POS completed
refund guaranteed
reservation guaranteed
no cancellation allowed
final settlement completed

Core rule:

CMS content must not override runtime truth.

20\. Targeting And Eligibility

Content targeting may be based on safe operational context.

Allowed targeting examples:

merchant store
region
surface
time window
service plan
trial status
enabled stage
reservation screen
pickup screen
guest language
menu category context

Avoid or restrict:

sensitive personal data targeting
unconsented personal profiling
cross-merchant personal tracking
health inference
minor-targeted advertising without policy

Core rule:

Targeting must be operationally relevant and privacy-safe.

21\. Personalization Boundary

Personalization should be limited in MVP.

MVP may allow:

language-based content
store-specific content
time-based promotion
surface-based notice
trial status-based owner notice

MVP should defer:

deep behavioral targeting
cross-store user profiling
third-party ad network personalization
lookalike audiences
sensitive-category targeting

Core rule:

Do not introduce advanced ad personalization before privacy governance is mature.

22\. Privacy Boundary

Ad Promotion CMS must respect privacy boundaries.

Privacy-sensitive data should not be exposed to ad logic by default.

Restricted data:

guest phone
guest name
payment credential
support evidence
private request memo if sensitive
Franchise OS HR data
cross-business identity data

Core rule:

Ad selection must not require unnecessary personal data.

23\. Impression Event

Impression event records that content was shown.

Suggested fields:

impression\_id
content\_id
slot\_id
surface
merchant\_store\_id
guest\_session\_id optional
user\_id optional for merchant/HQ surface
displayed\_at
language
device\_context

Core rule:

Impression measures exposure.
It does not prove customer intent.

24\. Click Event

Click event records user interaction.

Suggested fields:

click\_id
content\_id
slot\_id
surface
merchant\_store\_id
session\_id
clicked\_at
destination\_type
destination\_ref

Core rule:

Click measures interaction.
It does not prove purchase or conversion.

25\. Conversion Event

Conversion event should be carefully defined.

Possible conversion examples:

promotion detail opened
coupon saved
menu item viewed
item added to selection
request sent
pickup reservation created
support contact opened
owner trial conversion clicked

Conversion must not be confused with payment or settlement unless payment module confirms.

Core rule:

Conversion definition must be explicit.

26\. Ad Revenue And Merchant Benefit

Ad Promotion CMS may later support revenue or benefit models.

Possible models:

paid placement
partner promotion fee
merchant boost package
revenue share
free trial promotional slot
platform-sponsored campaign
local merchant benefit

MVP may defer settlement.

Core rule:

Ad revenue model must not bypass content review or user trust.

27\. Campaign Schedule

Campaign schedule should include:

start\_at
end\_at
timezone
dayparting optional
merchant/store scope
surface scope
priority
status

Expired campaigns should stop automatically.

Core rule:

Content must not remain live beyond approved schedule.

28\. Content Asset

Content asset may include:

title
body
image
thumbnail
link
CTA text
language versions
alt text
brand label
sponsor label if paid
policy version if notice

Paid ads should be clearly labeled when required.

Core rule:

User should understand when content is promotional or sponsored.

29\. Multi-Language Content

CatchMenu may serve multilingual guests.

Content should support:

Korean
English
Japanese
Chinese
other supported languages later

If translation confidence is low, content should not be published to that language without review.

Core rule:

Promotional translation must not change offer meaning.

30\. Emergency Disable

HQ or authorized incident operator may emergency-disable content.

Reasons:

misleading offer
wrong price
policy conflict
legal concern
safety concern
merchant complaint
system incident
partner issue
privacy concern

Emergency disable must be audited.

Core rule:

Unsafe content must be stoppable immediately.

31\. CMS Authority

CMS authority must be controlled by Identity Access.

Roles may include:

MERCHANT\_PROMOTION\_EDITOR
MERCHANT\_PROMOTION\_APPROVER
HQ\_CAMPAIGN\_MANAGER
AD\_REVIEWER
AD\_APPROVER
EMERGENCY\_NOTICE\_OPERATOR
CMS\_AUDIT\_REVIEWER

Core rule:

CMS publishing authority is not the same as merchant store authority.

32\. Audit Events

Recommended audit events:

CMS\_CONTENT\_CREATED
CMS\_CONTENT\_SUBMITTED
CMS\_CONTENT\_REVIEWED
CMS\_CONTENT\_APPROVED
CMS\_CONTENT\_REJECTED
CMS\_CONTENT\_SCHEDULED
CMS\_CONTENT\_PUBLISHED
CMS\_CONTENT\_PAUSED
CMS\_CONTENT\_EXPIRED
CMS\_CONTENT\_ARCHIVED
CMS\_CONTENT\_EMERGENCY\_DISABLED
CMS\_SLOT\_CREATED
CMS\_SLOT\_UPDATED
CMS\_TARGETING\_CHANGED
CMS\_IMPRESSION\_RECORDED
CMS\_CLICK\_RECORDED
CMS\_CONVERSION\_RECORDED

Minimum audit fields:

event\_id
content\_id
slot\_id
actor\_type
actor\_id
merchant\_account\_id
merchant\_store\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

33\. Failure Events

Invalid CMS actions should create failure events.

Examples:

publish without approval
publish outside schedule
publish to unauthorized store
merchant promotes another merchant
reservation notice policy mismatch
paid ad missing sponsor label
translation missing for required language
emergency notice authority missing
content attempts to override runtime state

Example failure codes:

WOH.CMS.CONTENT.PUBLISH.APPROVAL\_REQUIRED
WOH.CMS.CONTENT.PUBLISH.SCHEDULE\_INVALID
WOH.CMS.CONTENT.PUBLISH.STORE\_SCOPE\_DENIED
WOH.CMS.CONTENT.MERCHANT\_SCOPE\_DENIED
WOH.CMS.NOTICE.POLICY\_VERSION\_MISMATCH
WOH.CMS.AD.SPONSOR\_LABEL\_REQUIRED
WOH.CMS.CONTENT.TRANSLATION\_REQUIRED
WOH.CMS.EMERGENCY.AUTHORITY\_REQUIRED
WOH.CMS.CONTENT.RUNTIME\_OVERRIDE\_DENIED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

34\. Support Signals

Support signals may include:

CMS\_CONTENT\_REVIEW\_OVERDUE
CMS\_CONTENT\_POLICY\_CONFLICT
CMS\_PROMOTION\_EXPIRED\_BUT\_VISIBLE
CMS\_AD\_CLICK\_SPIKE
CMS\_AD\_IMPRESSION\_FAILURE
CMS\_EMERGENCY\_NOTICE\_ACTIVE
CMS\_MERCHANT\_PROMOTION\_SCOPE\_CONFLICT
CMS\_TRANSLATION\_REVIEW\_REQUIRED
CMS\_RESERVATION\_NOTICE\_MISMATCH

Support Signal alerts.

It does not publish or remove content by itself.

35\. Relationship To Guest WebApp

Guest WebApp displays approved CMS content.

Guest WebApp does not decide campaign governance.

Guest WebApp must:

request eligible content
render approved content
respect emergency notice priority
record impression and click events
avoid exposing internal CMS metadata

Core rule:

Guest WebApp is display surface.
Ad Promotion CMS is content governance.

36\. Relationship To Owner Console

Owner Console may allow merchants to:

create merchant promotion draft
submit promotion
view promotion status
view basic promotion metrics
pause own promotion if allowed
see HQ notices
see trial campaign notices

Owner Console must not allow merchant to publish to unauthorized surfaces.

37\. Relationship To CatchMenu HQ

CatchMenu HQ manages:

content review queue
ad approval
HQ campaign
emergency notice
slot management
targeting rule
content audit
platform-wide campaign

HQ actions must be authorized and audited.

38\. Relationship To Identity Access

Identity Access controls:

who can create content
who can submit content
who can approve content
who can publish content
who can emergency-disable content
who can view metrics
who can export CMS data

Core rule:

CMS content authority must be role-scoped and surface-scoped.

39\. Relationship To Reservation Preorder Governance

Reservation-related notices must match active reservation policy.

Examples:

pickup deadline
cancellation cutoff
deposit rule
no-show warning
refund limitation
group order policy

CMS must not show outdated or conflicting reservation rules.

40\. Relationship To Provider Adapter Runtime

Provider failures may require notices.

Examples:

Toss payment issue notice
PAYCO payment issue notice
POS handoff degraded notice
provider callback delay notice
manual fallback notice

Provider Adapter may generate support signal.

CMS may display approved notice if authorized.

41\. Relationship To Open API Partner Alliance

Partner campaigns or co-marketing may use CMS.

Examples:

partner promotion
integration launch campaign
partner-certified badge
co-selling banner
merchant benefit announcement

Partner content must be reviewed and approved.

42\. MVP Requirements

Ad Promotion CMS MVP should support at least:

CMS content record
content category
merchant promotion
HQ notice
emergency notice
guest menu top banner slot
request completed screen slot
owner console notice slot
content review status
approval status
publish schedule
store scope
surface scope
impression event
click event
audit event
failure event
support signal
emergency disable

MVP may defer:

external advertiser portal
real-time bidding
advanced personalization
ad revenue settlement
advanced A/B testing
third-party ad network
complex campaign optimization
deep CRM segmentation

43\. Suggested Conceptual Entities

Suggested entities:

cms\_contents
cms\_content\_assets
cms\_slots
cms\_campaigns
cms\_content\_reviews
cms\_publish\_schedules
cms\_targeting\_rules
cms\_impression\_events
cms\_click\_events
cms\_conversion\_events
cms\_audit\_events
cms\_failure\_events
cms\_support\_signals

This document defines policy.

Actual schema may be designed later.

44\. Risk If Skipped

If Ad Promotion CMS governance is skipped, risks include:

unapproved ads appear to guests
merchant promotion leaks to other stores
outdated cancellation policy is displayed
paid ad is not labeled
emergency notice cannot override promotion
misleading discount causes dispute
translation changes offer meaning
CMS content overrides runtime truth
ad metrics become unreliable
privacy-invasive targeting starts too early

Therefore, Ad Promotion CMS must be defined before advertisement, promotion, notice, or campaign features are implemented.

45\. Final Rule

Ad Promotion CMS must make promotional content useful, controlled, measurable, and safe.

Final rule:

Define surfaces.
Define slots.
Classify content.
Review content.
Approve before publish.
Schedule content.
Respect emergency priority.
Scope merchant promotions.
Label paid ads when required.
Do not override runtime truth.
Measure impressions and clicks.
Limit personalization.
Audit every sensitive CMS action.
Stop unsafe content immediately.
