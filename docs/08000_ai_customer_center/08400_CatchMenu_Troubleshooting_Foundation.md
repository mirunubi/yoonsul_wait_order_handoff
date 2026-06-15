# 08400_CatchMenu_Troubleshooting_Foundation

1\. Purpose

This document defines the troubleshooting foundation for CatchMenu AI Customer Center integration.

CatchMenu may produce guest issues, merchant issues, runtime issues, translation issues, handoff issues, and support cases.

The AI Customer Center must be able to classify these issues, retrieve the correct SOP, review Evidence Packets, and prepare safe support responses.

This document does not implement troubleshooting automation.

It defines issue categories, support boundaries, escalation triggers, and evidence requirements.

2\. Core Principle

CatchMenu troubleshooting must preserve operational boundaries.

AI Customer Center may help diagnose, summarize, and recommend.

AI Customer Center must not directly mutate CatchMenu runtime state.

Core rule:

AI may troubleshoot.
AI may summarize.
AI may draft.
AI may recommend.
AI must not directly confirm, cancel, refund, compensate, or mutate operational state.

Operational actions must be handled by authorized humans or authorized runtime functions.

3\. Troubleshooting Source Layers

Troubleshooting should use the following source order:

1\. SOP / policy / FAQ retrieval through pgvector
2\. Evidence Packet
3\. Secondary Support View
4\. Primary DB read-only lookup only when strictly necessary
5\. Human escalation

The AI Customer Center must not begin with raw Primary DB lookup.

4\. Major Issue Families

CatchMenu troubleshooting issues are grouped into the following families.

QR / Access Issue
Language / Translation Issue
Menu / Option Issue
Guest Request Issue
Store Confirmation Issue
Stage 0C Unconfirmed Request Issue
Waiting / Arrival Issue
POS Handoff Issue
KDS Handoff Issue
Benefit Routing Issue
Owner Console Issue
Notification Issue
Device / Browser Issue
Policy / Usage Confusion
Abuse / Dispute / Safety Issue

Each issue family may map to one or more SOP documents and Evidence Packet fields.

5\. QR / Access Issue

5.1 Definition

QR / Access Issue occurs when a guest cannot access CatchMenu through QR or URL.

Examples:

QR code does not open
QR code opens wrong store
QR code opens wrong menu
guest sees expired page
guest sees network error
language selector does not load
menu page is blank

5.2 Evidence Required

store\_id
qr\_entry\_url\_hash
menu\_version
device\_type
browser\_name
os\_name
network\_status
error\_code
first\_error\_at
last\_error\_at

5.3 AI Allowed Response

AI may:

guide guest to refresh page
suggest scanning QR again
suggest checking network
explain that staff can assist manually
prepare merchant troubleshooting checklist

5.4 Escalation Trigger

Escalate if:

many guests report same QR issue
wrong store/menu is displayed
QR code routes to another tenant
payment or personal data exposure is suspected

6\. Language / Translation Issue

6.1 Definition

Language / Translation Issue occurs when menu, request, or store message translation is wrong, missing, confusing, or risky.

Examples:

menu translation is incorrect
guest request translation is unclear
allergy request translation is low confidence
store message translated incorrectly
guest does not understand confirmation status

6.2 Evidence Required

guest\_language
store\_language
original\_guest\_text
translated\_store\_text\_ko
store\_message\_original\_ko
store\_message\_translated\_guest\_language
translation\_confidence
critical\_request\_flags
staff\_confirmation\_required
request\_version

6.3 AI Allowed Response

AI may:

summarize original and translated text
flag low confidence translation
recommend staff reconfirmation
retrieve translation policy
draft neutral clarification message

6.4 Escalation Trigger

Escalate if issue involves:

allergy
religious restriction
pork/alcohol
medical caution
raw food
serious guest complaint
possible harm

7\. Menu / Option Issue

7.1 Definition

Menu / Option Issue occurs when menu data, price, option, sold-out status, or menu availability is wrong or unclear.

Examples:

wrong price shown
sold-out item still visible
option missing
menu image mismatch
ingredient information missing
allergy information missing
guest chose item store cannot prepare

7.2 Evidence Required

store\_id
menu\_item\_id
menu\_version
option\_id
displayed\_price
store\_current\_price
sold\_out\_status
allergy\_info\_version
request\_id
guest\_selected\_items

7.3 AI Allowed Response

AI may:

explain displayed menu data
flag mismatch
recommend menu update
draft merchant checklist
suggest staff confirmation

7.4 Escalation Trigger

Escalate if:

price dispute occurs
allergy information is missing or wrong
wrong menu caused customer harm
multiple guests report same menu problem

8\. Guest Request Issue

8.1 Definition

Guest Request Issue occurs when the guest believes a request was sent, edited, rejected, or confirmed incorrectly.

Examples:

guest says request was not sent
guest edited request but store saw old version
guest cannot edit after store confirmation
guest does not understand “store confirmation”
guest thinks request is a confirmed order

8.2 Evidence Required

request\_id
guest\_session\_id
request\_status
request\_version
latest\_version\_flag
sent\_to\_store\_at
updated\_by\_guest\_at
store\_confirmed\_at
guest\_visible\_status
owner\_console\_visible\_status
timeline

8.3 AI Allowed Response

AI may:

explain current request status
explain request vs confirmed order boundary
summarize request timeline
draft response asking guest to contact staff if already locked

8.4 Escalation Trigger

Escalate if:

guest paid elsewhere but order not handled
store denies receiving request
timeline mismatch exists
duplicate request or duplicate handling is suspected

9\. Store Confirmation Issue

9.1 Definition

Store Confirmation Issue occurs when store confirmation is delayed, missed, disputed, or misunderstood.

Examples:

store did not press 주문 확인
guest waited too long
owner says request was handled offline
guest says store never confirmed
store confirmation locked guest edit unexpectedly

9.2 Evidence Required

request\_id
request\_status
store\_confirmed
store\_confirmed\_at
confirmed\_by\_actor\_type
confirmed\_by\_actor\_id\_masked
guest\_locked\_after\_confirmation
unconfirmed\_duration\_minutes
warning\_triggered\_at
timeline

9.3 AI Allowed Response

AI may:

explain confirmation status
summarize whether store confirmation occurred
retrieve Stage 0B/0C confirmation policy
draft merchant reminder
draft guest explanation

9.4 Escalation Trigger

Escalate if:

confirmation delay caused dispute
guest claims financial loss
store repeatedly misses confirmation
system alert failed

10\. Stage 0C Unconfirmed Request Issue

10.1 Definition

Stage 0C Unconfirmed Request Issue occurs when POS-less request confirmation is not performed properly.

Examples:

owner did not press 주문 확인
30-minute warning appeared
top warning keeps blinking
unconfirmed requests reached 10
forced cleanup screen appeared
owner does not understand cleanup screen
unconfirmed request expired
guest says order was handled but system shows unconfirmed

10.2 Evidence Required

request\_id
request\_status
owner\_confirm\_button\_visible
owner\_confirm\_clicked
owner\_complete\_button\_visible
owner\_complete\_clicked
unconfirmed\_duration\_minutes
warning\_triggered\_at
top\_warning\_visible
forced\_cleanup\_required
forced\_cleanup\_triggered\_at
unconfirmed\_count\_at\_time
closing\_cleanup\_policy\_applied

10.3 AI Allowed Response

AI may:

explain that unconfirmed requests are not auto-completed
explain 30-minute warning
explain forced cleanup threshold
guide owner to confirm, complete, or expire old requests
summarize whether request was confirmed before completion

10.4 Escalation Trigger

Escalate if:

owner claims many requests disappeared
guest dispute involves unconfirmed expired request
forced cleanup incorrectly blocked operation
system auto-completed an unconfirmed request

Critical rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

11\. Waiting / Arrival Issue

11.1 Definition

Waiting / Arrival Issue occurs when waiting, arrival, seating, or continuation flow fails or is misunderstood.

Examples:

guest waiting number not shown
guest called but not arrived
guest arrived but order context not continued
staff cannot find waiting guest
seating context lost
no-show dispute

11.2 Evidence Required

waiting\_id
guest\_session\_id
party\_size
waiting\_status
called\_at
arrived\_at
seated\_at
cancelled\_at
no\_show\_at
request\_id
handoff\_id
timeline

11.3 AI Allowed Response

AI may:

summarize waiting timeline
explain status
retrieve waiting SOP
draft staff-facing guidance

11.4 Escalation Trigger

Escalate if:

guest claims unfair queue handling
same waiting number assigned twice
seating dispute occurs
staff manually overrode queue

12\. POS Handoff Issue

12.1 Definition

POS Handoff Issue occurs when CatchMenu prepared order context fails to pass to POS or is duplicated/mismatched.

Examples:

POS handoff failed
POS reference missing
POS item mapping mismatch
duplicate POS order suspected
manual fallback used
POS adapter timeout

12.2 Evidence Required

handoff\_id
request\_id
pos\_adapter\_enabled
pos\_handoff\_attempted
pos\_handoff\_status
pos\_reference
pos\_error\_code
pos\_retry\_count
manual\_pos\_fallback\_used
duplicate\_guard\_result
timeline

12.3 AI Allowed Response

AI may:

summarize handoff status
explain manual fallback
retrieve POS handoff troubleshooting guide
suggest checking existing POS before retry
prepare support handoff

12.4 Escalation Trigger

Escalate if:

duplicate order suspected
payment mismatch occurs
POS reference conflicts
merchant claims revenue impact

Boundary:

POS owns transaction authority.
CatchMenu owns handoff context.
AI Customer Center owns support review only.

13\. KDS Handoff Issue

13.1 Definition

KDS Handoff Issue occurs when kitchen handoff, kitchen visibility, or ready status fails or is disputed.

Examples:

KDS handoff failed
KDS reference missing
kitchen did not see request
ready status not returned
Mini KDS fallback used
staff says kitchen received wrong item

13.2 Evidence Required

handoff\_id
request\_id
kds\_adapter\_enabled
kds\_handoff\_attempted
kds\_handoff\_status
kds\_reference
kds\_error\_code
kds\_retry\_count
mini\_kds\_fallback\_used
ready\_status\_received
timeline

13.3 AI Allowed Response

AI may:

summarize KDS handoff status
explain KDS vs Mini KDS fallback
retrieve KDS troubleshooting SOP
recommend staff verification

13.4 Escalation Trigger

Escalate if:

kitchen production mismatch occurs
ready status caused guest dispute
allergy request did not reach kitchen
KDS integration repeatedly fails

Boundary:

KDS owns kitchen execution authority.
CatchMenu owns handoff context.
AI Customer Center owns support review only.

14\. Benefit Routing Issue

14.1 Definition

Benefit Routing Issue occurs when visit, menu preparation, coupon, point, or external membership benefit is unclear or disputed.

Examples:

guest expected benefit but did not receive it
benefit candidate was created but not claimed
claim token expired
external membership claim failed
duplicate guard blocked claim
tenant benefit policy unclear

14.2 Evidence Required

benefit\_candidate\_id
benefit\_policy\_id
claim\_token\_id
claim\_status
duplicate\_guard\_status
external\_membership\_reference
external\_claim\_attempted
external\_claim\_result
claim\_deferred\_reason
guest\_identity\_link\_status

14.3 AI Allowed Response

AI may:

explain candidate vs claimed boundary
summarize claim attempt
retrieve benefit policy
draft response that claim is under review

14.4 Escalation Trigger

Escalate if:

guest demands compensation
duplicate guard conflict exists
external membership system disagrees
tenant policy exception is needed

Boundary:

Benefit candidate does not equal benefit claimed.
AI must not mark benefits as claimed.

15\. Owner Console Issue

15.1 Definition

Owner Console Issue occurs when store owner/staff cannot use the web console or sees unexpected state.

Examples:

new request not visible
sound alert does not play
top warning does not blink
forced cleanup screen blocks operation
owner cannot press 주문 확인
owner cannot press 완료
request list not refreshing

15.2 Evidence Required

store\_id
owner\_session\_id\_masked
console\_session\_status
device\_type
browser\_name
browser\_version
os\_name
network\_status
request\_id
visible\_status
button\_visible
button\_clicked
error\_code

15.3 AI Allowed Response

AI may:

suggest refresh
suggest checking browser sound permission
explain warning state
guide owner through cleanup screen
retrieve owner console SOP

15.4 Escalation Trigger

Escalate if:

multiple requests affected
console cannot load
forced cleanup cannot be cleared
button click is recorded but state did not change

16\. Notification Issue

16.1 Definition

Notification Issue occurs when visual, sound, push, SMS, Kakao, or owner app notification fails or is misunderstood.

Examples:

owner did not hear sound
browser blocked sound
SMS not received
Kakao not received
push notification delayed
top warning not noticed

16.2 Evidence Required

notification\_type
notification\_enabled
notification\_sent\_at
notification\_result
browser\_permission\_status
owner\_console\_visible
sound\_attempted
sms\_provider\_result
kakao\_provider\_result

16.3 AI Allowed Response

AI may:

explain default notification policy
explain SMS/Kakao are optional if configured that way
guide browser sound permission check
recommend keeping owner console open

16.4 Escalation Trigger

Escalate if:

paid notification failed
provider delivery issue exists
many stores report notification failure

17\. Device / Browser Issue

17.1 Definition

Device / Browser Issue occurs when a guest or owner device cannot properly run CatchMenu.

Examples:

old browser not supported
PWA not working
screen too small
network unstable
page freezes
camera QR permission issue

17.2 Evidence Required

device\_type
browser\_name
browser\_version
os\_name
os\_version
screen\_size\_class
network\_status
pwa\_mode
error\_code

17.3 AI Allowed Response

AI may:

suggest browser refresh
suggest using another browser
suggest network check
suggest staff manual handling
prepare support note with device context

17.4 Escalation Trigger

Escalate if:

same device/browser class repeatedly fails
accessibility issue exists
guest cannot complete critical flow

18\. Policy / Usage Confusion

18.1 Definition

Policy / Usage Confusion occurs when guest or merchant misunderstands what CatchMenu does.

Examples:

guest thinks request is paid order
guest thinks order is confirmed immediately
owner thinks CatchMenu is POS
owner thinks CatchMenu is KDS
owner expects SMS/Kakao by default
owner expects app install is required
guest thinks payment was completed

18.2 Evidence Required

stage
package\_code
enabled\_modules
guest\_visible\_status
merchant\_plan
payment\_enabled
pos\_adapter\_enabled
kds\_adapter\_enabled
notification\_options

18.3 AI Allowed Response

AI may explain:

CatchMenu request is not POS order
payment is handled at store unless integrated
SMS/Kakao may be optional
owner app is optional
POS/KDS integration depends on stage

18.4 Escalation Trigger

Escalate if:

sales promise mismatch exists
merchant contract dispute occurs
guest financial dispute occurs

19\. Abuse / Dispute / Safety Issue

19.1 Definition

Abuse / Dispute / Safety Issue includes sensitive cases requiring human review.

Examples:

angry guest
threatening language
food safety complaint
allergy harm
payment dispute
refund demand
legal complaint
privacy complaint
store misconduct claim
fraud suspicion

19.2 Evidence Required

support\_case\_id
case\_type
severity
timeline
masked guest/store context
request context
payment reference if allowed
translation context if relevant
policy references
prior support notes

19.3 AI Allowed Response

AI may:

summarize facts
retrieve escalation SOP
draft neutral acknowledgement
flag severity
prepare human handoff

19.4 Escalation Trigger

Always escalate.

AI must not independently decide:

refund
compensation
legal fault
store penalty
food safety conclusion
privacy violation conclusion

20\. Severity Levels

Suggested severity levels:

P0 \= safety/legal/privacy/payment critical
P1 \= active store operation blocked
P2 \= active guest/store issue requiring same-day response
P3 \= non-urgent support issue
P4 \= FAQ / usage guidance

Examples:

P0: allergy harm, payment dispute, privacy exposure
P1: owner console down, POS/KDS handoff blocked
P2: guest request not confirmed today
P3: menu translation correction request
P4: how to use QR menu

21\. AI Troubleshooting Output Format

AI troubleshooting output should include:

issue summary
case type
severity
known facts
missing evidence
likely SOP reference
safe response draft
recommended next step
escalation required or not

AI should avoid pretending certainty when evidence is incomplete.

22\. Missing Evidence Policy

If required evidence is missing, AI should not guess.

AI may say:

Evidence is incomplete.
Please retrieve the request timeline.
Please confirm whether store confirmation occurred.
Please check whether Primary read is needed through Gateway.

Missing evidence should be recorded as a support note.

23\. Troubleshooting Boundary

Troubleshooting is not mutation.

AI must not directly:

change request status
clear forced cleanup
confirm request
mark completed
retry POS handoff
retry KDS handoff
issue refund
grant benefit
delete log

AI may recommend that an authorized user perform those actions.

24\. Final Statement

CatchMenu troubleshooting must be issue-family-based, evidence-packet-driven, and SOP-retrieval-first.

The AI Customer Center should diagnose and assist, but operational authority remains with CatchMenu, POS, KDS, store staff, HQ support, or authorized runtime functions.

Core rule:

SOP first.
Evidence Packet second.
Secondary support view third.
Primary read-only last.
Human or authorized runtime action for final resolution.
