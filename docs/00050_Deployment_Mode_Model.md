# 00050_Deployment_Mode_Model

1\. Purpose

This document defines the deployment mode model for the yoonsul\_wait\_order\_handoff project.

The purpose is to separate deployment and hosting behavior from store capability stages and store operation patterns.

Store capability stage defines what the store can technically connect.

Operation pattern defines how the store physically produces, confirms, and hands off orders.

Deployment mode defines where and how the runtime operates.

These three axes must remain separate.

Capability Stage \= what the store can connect
Operation Pattern \= how the store operates physically
Deployment Mode \= where and how the runtime is hosted or synchronized

2\. Core Principle

Deployment mode is not Stage 0\~5.

Deployment mode does not define product maturity.

Deployment mode defines runtime placement, network dependency, local fallback, synchronization, and operational survivability.

The same Stage 2 store may run as cloud-only or store-local-first.

The same Stage 4 store may use cloud SaaS for policy while relying on local devices during network degradation.

The same Stage 5 tenant may require hybrid deployment because multiple stores need survivability during internet instability.

3\. Deployment Mode Summary

The project supports four deployment modes.

CLOUD\_SAAS
HYBRID\_SYNC
STORE\_LOCAL\_FIRST
STANDALONE\_LOCAL

Simple summary:

CLOUD\_SAAS \= cloud is primary
HYBRID\_SYNC \= cloud and store local runtime cooperate
STORE\_LOCAL\_FIRST \= store runtime continues locally and syncs later
STANDALONE\_LOCAL \= store-local operation with minimal or no SaaS dependency

4\. CLOUD\_SAAS

4.1 Definition

CLOUD\_SAAS is the default deployment mode where the main runtime operates in the cloud.

The store accesses the service through web, app, browser, tablet, or connected devices.

4.2 Suitable Store Types

CLOUD\_SAAS is suitable for:

\- Stage 0 QR menu board
\- Stage 1 manual handoff
\- Stage 3 POS adapter with stable internet
\- Stage 5 tenant SaaS
\- stores that do not require strong offline operation
\- stores where central policy and reporting matter more than local autonomy

4.3 Characteristics

CLOUD\_SAAS provides:

centralized runtime
centralized policy
centralized reporting
easy update
lower local device complexity
tenant-level control
external integration management

4.4 Limitations

CLOUD\_SAAS may be weak when:

internet is unstable
store needs local survivability
kitchen screen must continue during network interruption
POS/KDS local network integration is required
emergency fallback is important

4.5 Boundary

Cloud SaaS must not assume that store execution stops when the internet is unstable.

For higher operational reliability, fallback or local mode must be defined.

5\. HYBRID\_SYNC

5.1 Definition

HYBRID\_SYNC is a deployment mode where cloud runtime and store-local runtime cooperate.

The cloud remains the policy and integration center.

The store-local runtime may temporarily hold operational state and sync back to the cloud.

5.2 Suitable Store Types

HYBRID\_SYNC is suitable for:

\- Stage 2 stores using Mini KDS
\- Stage 3 stores with POS adapter and local fallback
\- Stage 4 stores with POS/KDS handoff
\- Stage 5 tenants with multi-store operation
\- stores requiring both SaaS control and local survivability

5.3 Characteristics

HYBRID\_SYNC may support:

cloud policy
store-local working queue
local Mini KDS screen
local handoff cache
sync pending state
retry queue
event replay
degraded operation
central reconciliation

5.4 Sync Direction

The sync model must distinguish:

cloud\_to\_store
store\_to\_cloud
external\_pos\_to\_store
external\_kds\_to\_store
store\_to\_external\_system

Not all data flows are equal.

Policy may come from cloud.

Operational events may originate locally.

External POS/KDS references may be received locally and later synced.

5.5 Boundary

Hybrid sync must not silently overwrite state.

If local and cloud state diverge, the system must preserve both evidence and reconcile explicitly.

6\. STORE\_LOCAL\_FIRST

6.1 Definition

STORE\_LOCAL\_FIRST is a deployment mode where store-local runtime is the primary operational surface during store execution.

Cloud is still available for policy, reporting, backup, or later synchronization, but the store can continue operating locally when connectivity is unstable.

6.2 Suitable Store Types

STORE\_LOCAL\_FIRST is suitable for:

\- stores with unstable internet
\- stores requiring strong kitchen survivability
\- Stage 2 stores relying on Mini KDS
\- Stage 4 stores with local POS/KDS network
\- high-volume stores where kitchen visibility must not stop
\- stores needing degraded operation fallback

6.3 Characteristics

STORE\_LOCAL\_FIRST may support:

local waiting queue mirror
local prepared order queue
local Mini KDS
local staff handoff screen
local POS/KDS adapter bridge
local event capture
sync pending queue
cloud reconciliation after recovery

6.4 Local Runtime Boundary

Local runtime may operate the working queue.

However, it must not become final authority for systems it does not own.

Local runtime must not become:

final POS ledger
final payment ledger
final external membership ledger
central tenant policy authority

6.5 Recovery

When cloud connectivity returns, local events must sync with evidence.

Recovery must preserve:

event order
local timestamp
server timestamp
device identity
staff identity
sync status
conflict flag
manual resolution marker

Silent merge is prohibited.

7\. STANDALONE\_LOCAL

7.1 Definition

STANDALONE\_LOCAL is a deployment mode where the store operates locally with minimal or no cloud dependency.

This mode may be useful for low-integration stores, local kiosk-like operation, or stores that do not require SaaS analytics or external membership routing.

7.2 Suitable Store Types

STANDALONE\_LOCAL may be suitable for:

\- independent small stores
\- low-connectivity environments
\- semi-unmanned stores
\- stores using local devices only
\- stores that only need local QR menu / local prepared order screen
\- stores not requiring SaaS reporting or tenant integration

7.3 Characteristics

STANDALONE\_LOCAL may support:

local menu display
local prepared order queue
local staff screen
local Mini KDS
manual POS handoff
manual kitchen handoff
limited local history
exportable logs

7.4 Limitations

STANDALONE\_LOCAL limits or disables:

central SaaS reporting
multi-store analytics
external membership connector
white label identity link
real-time benefit routing
central policy distribution
cloud audit consolidation
cross-store customer continuity

7.5 Boundary

Standalone local mode is not a higher capability stage.

It is an integration/deployment choice.

It may serve Stage 0, Stage 1, or Stage 2 stores, but it is not Stage 6\.

8\. Relationship With Store Capability Stage 0\~5

Deployment mode and capability stage are separate.

Examples:

Stage 0 \+ CLOUD\_SAAS
\= cloud-hosted QR menu board

Stage 1 \+ CLOUD\_SAAS
\= waiting and manual POS handoff through cloud webapp

Stage 2 \+ HYBRID\_SYNC
\= cloud waiting \+ local Mini KDS queue

Stage 2 \+ STORE\_LOCAL\_FIRST
\= local Mini KDS continues even during internet instability

Stage 3 \+ HYBRID\_SYNC
\= cloud policy \+ local POS adapter retry

Stage 4 \+ STORE\_LOCAL\_FIRST
\= local POS/KDS handoff continues during cloud degradation

Stage 5 \+ CLOUD\_SAAS
\= tenant SaaS with central benefit routing

Stage 5 \+ HYBRID\_SYNC
\= tenant SaaS with store-local survivability

9\. Relationship With Operation Patterns

Operation patterns may require specific deployment behavior.

9.1 Split Production

Split production may require store-local runtime if kitchen stations depend on local screens.

Recommended deployment modes:

HYBRID\_SYNC
STORE\_LOCAL\_FIRST

9.2 Multi-Channel Handoff

Multi-channel handoff may work in cloud mode, but local fallback is useful if pickup, delivery rider, and kitchen screens must continue during network instability.

Recommended deployment modes:

CLOUD\_SAAS
HYBRID\_SYNC
STORE\_LOCAL\_FIRST

9.3 Pre-order Pending Confirmation

Pre-order confirmation can work in cloud mode, but inventory or store acceptance may require local or POS/KDS integration.

Recommended deployment modes:

CLOUD\_SAAS
HYBRID\_SYNC

9.4 Standalone Kiosk Loop

Standalone kiosk loop naturally maps to local modes.

Recommended deployment modes:

STORE\_LOCAL\_FIRST
STANDALONE\_LOCAL

10\. Runtime State Requirements

Deployment mode must be visible in runtime state.

Suggested fields:

deployment\_mode
runtime\_origin
network\_status
local\_queue\_status
sync\_status
sync\_pending\_count
last\_cloud\_sync\_at
last\_local\_event\_at
fallback\_mode
recovery\_required
conflict\_status

These fields should help staff and operators understand whether the store is operating normally, degraded, local-first, or sync-pending.

11\. Fallback Rules

Fallback must be explicit.

Silent fallback is prohibited.

Examples:

CLOUD\_SAAS network failure
→ switch to manual staff handoff or local fallback if available

HYBRID\_SYNC cloud failure
→ continue local queue and mark sync pending

STORE\_LOCAL\_FIRST cloud failure
→ continue local runtime and sync after recovery

STANDALONE\_LOCAL export failure
→ preserve local logs and mark export pending

Fallback events must be logged.

12\. Sync And Reconciliation Rules

Sync and reconciliation must preserve operational evidence.

Required principles:

local event is not automatically overwritten by cloud event
cloud event is not automatically overwritten by local event
external POS/KDS reference must be preserved
manual staff action must be preserved
conflict requires explicit resolution
replay does not equal mutation
sync does not equal ownership transfer

If conflict occurs, the system must preserve:

local value
cloud value
external value
event source
event time
staff/device identity
resolution decision
resolution actor
resolved\_at

13\. Deployment Mode Matrix

Deployment Mode| Cloud Dependency| Local Survivability| SaaS Reporting| Offline/Degraded Use| Best For
CLOUD\_SAAS| High| Low| Strong| Limited| Stage 0, 1, 3, 5 basic SaaS
HYBRID\_SYNC| Medium| Medium| Strong| Supported| Stage 2\~5 with local assist
STORE\_LOCAL\_FIRST| Low during operation| Strong| Delayed| Strong| Stage 2/4 high-volume stores
STANDALONE\_LOCAL| Minimal| Strong local only| Weak| Strong local| Small/local/low-integration stores

14\. Design Rules

Do not confuse deployment mode with capability stage.

Do not treat STANDALONE\_LOCAL as Stage 6\.

Do not make local runtime the owner of POS, payment, inventory, or external membership truth unless separately defined.

Do not silently merge cloud and local state.

Do not silently downgrade operation.

Do not require general guests to install an app just because a deployment mode is complex.

Guest-facing access should remain simple:

scan QR
view menu
pre-select menu
show staff
continue after arrival/seating

15\. Final Statement

Deployment mode defines where the wait\_order\_handoff runtime runs and how it survives network or integration conditions.

It does not redefine the product stage.

It does not redefine store operation pattern.

It does not transfer ownership of POS, KDS, payment, inventory, or external membership systems.

The runtime must remain simple for guests, useful for store operators, and clear in ownership boundaries.
