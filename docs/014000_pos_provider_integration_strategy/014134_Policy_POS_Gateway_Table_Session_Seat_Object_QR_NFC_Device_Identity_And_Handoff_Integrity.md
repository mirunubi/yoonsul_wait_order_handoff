# 014134_Policy_POS_Gateway_Table_Session_Seat_Object_QR_NFC_Device_Identity_And_Handoff_Integrity

## 1. Purpose

This document defines the table, session, seat, object, QR, NFC, device identity, and handoff integrity policy for the POS Gateway.

The POS Gateway must not treat table ordering, QR ordering, NFC ordering, kiosk ordering, and waiting/preorder handoff as simple order channels.

These flows depend on physical and logical identity:

- which store the customer is in;
- which table or seat the customer is attached to;
- which QR/NFC object was scanned;
- which kiosk or device initiated the order;
- whether the table session is active;
- whether the customer should be allowed to order;
- whether the order should be held, routed, paid, or handed off;
- whether the order belongs to dine-in, takeout, waiting, preorder, or staff confirmation.

If this identity is wrong, the gateway may create orders for the wrong table, wrong store, wrong customer session, wrong POS terminal, wrong KDS lane, wrong receipt, or wrong payment path.

This policy exists to ensure that:

- physical ordering objects are mapped safely;
- table/session identity is verified before POS write;
- QR/NFC identity cannot silently drift;
- device identity is auditable;
- handoff from waiting/preorder to table/session is controlled;
- table transfer and session merge/split are explicit;
- customer, staff, POS, KDS, payment, and receipt context remain aligned.

---

## 2. Scope

This policy applies to all POS Gateway flows that depend on table, session, object, or device identity, including:

- dine-in table ordering;
- QR table ordering;
- NFC table ordering;
- table object scan;
- kiosk ordering;
- staff tablet ordering;
- waiting/preorder handoff;
- seat assignment;
- table transfer;
- table merge;
- table split;
- order round;
- customer session;
- staff-confirmed order;
- POS table mapping;
- KDS table display;
- receipt table identity;
- payment session;
- customer dispute investigation involving table or session identity.

This document governs identity integrity before order acceptance, POS write, KDS routing, payment execution, cancellation, refund, receipt issuance, reconciliation, and incident handling.

---

## 3. Core Principle

A table or device order is valid only when the ordering context is proven.

The POS Gateway must know:

```text
which physical object was used
which store owns the object
which table or zone the object maps to
whether the object is active
whether the table session is active
whether the customer/order belongs to that session
whether staff confirmation is required
which POS table or terminal should receive the order
which KDS route should display it
which payment and receipt context applies
```

If identity cannot be proven, the order must be blocked, held, or routed to staff confirmation.

---

## 4. Identity Object Model

The gateway must support physical and logical identity objects.

Recommended object types:

| Object Type | Description |
|---|---|
| `qr_table_object` | QR code physically attached to a table or zone |
| `nfc_table_object` | NFC tag physically attached to a table or zone |
| `kiosk_device` | Store kiosk or mini-order device |
| `staff_tablet` | Staff device used for ordering or confirmation |
| `pos_terminal` | POS terminal or register identity |
| `payment_terminal` | Payment terminal identity |
| `kds_station` | Kitchen display station identity |
| `pickup_display` | Pickup display or order number display |
| `table_object` | Generic physical table identity object |
| `seat_object` | Seat-specific object where supported |
| `waiting_ticket` | Waiting or preorder session identity |
| `manual_session_token` | Staff-created manual session identity |

Identity object type must be stored and audited.

---

## 5. Object Registry

Every physical ordering object must be registered.

Required object registry fields:

```text
object_id
object_type
tenant_id
store_id
object_code
physical_label
assigned_table_id
assigned_seat_id
assigned_zone_id
assigned_terminal_id
assigned_kds_scope
status
issued_at
activated_at
deactivated_at
last_verified_at
created_by
updated_by
```

Objects must not be used for production ordering unless their status is active and mapping is verified.

---

## 6. Object Status Model

Each physical object must have an explicit status.

Recommended statuses:

| Status | Meaning |
|---|---|
| `draft` | Object created but not active |
| `printed_or_encoded` | QR/NFC/device identity created but not verified |
| `installed_unverified` | Installed physically but not confirmed |
| `active` | Can be used for production ordering |
| `restricted` | Active only under limits |
| `suspended` | Temporarily disabled |
| `lost_or_removed` | Object missing or removed |
| `damaged` | Physical object damaged or unreadable |
| `reassigned_pending_verification` | Object moved or remapped but not verified |
| `retired` | No longer used |
| `compromised` | Object identity may be copied, leaked, or misused |

Objects in uncertain status must not allow automatic order creation.

---

## 7. QR and NFC Identity Policy

QR/NFC objects must not rely only on visible table numbers.

Each QR/NFC object must resolve to a stable object identity.

Required resolution fields:

```text
scan_token
object_id
tenant_id
store_id
table_id
zone_id
object_version
signature_or_integrity_token
expires_at_or_rotation_policy
status
```

The gateway must not trust manually edited URL parameters or table numbers without validating the object token.

If QR/NFC token integrity fails, the order must be blocked and an incident or security event must be created.

---

## 8. Object Versioning and Rotation

QR/NFC objects must support versioning or rotation.

Versioning is required when:

- table layout changes;
- object is moved;
- object is replaced;
- object is suspected copied;
- store changes provider mapping;
- tenant/store boundary changes;
- QR/NFC URL format changes;
- security policy changes;
- ordering flow changes materially.

Old object versions must not silently map to new tables without audit.

Rotation record must include:

```text
rotation_id
object_id
old_object_version
new_object_version
reason
rotated_by
approved_by
effective_from
status
```

---

## 9. Table Registry

The gateway must maintain or reference a table registry.

Required table fields:

```text
table_id
tenant_id
store_id
table_code
display_table_name
floor
zone
seat_count
pos_table_code
kds_display_code
status
effective_from
effective_until
```

Table identity must be mapped to POS table identity where POS table routing is required.

Unknown or unmapped table must fail closed for automated dine-in table ordering.

---

## 10. Seat Identity Policy

Seat-level identity may be optional, but if used, it must be controlled.

Seat identity may support:

- individual seat ordering;
- split bill;
- customer-specific ordering;
- allergy/special request tracking;
- party-level grouping;
- course or round ordering.

Required seat fields where applicable:

```text
seat_id
table_id
seat_code
display_seat_name
status
```

Seat identity must not replace table identity.  
Seat must remain linked to table/session context.

---

## 11. Table Session Model

Dine-in ordering must use a table session where orders may span time.

Required table session fields:

```text
table_session_id
tenant_id
store_id
table_id
opened_at
opened_by
session_source
party_size
current_status
payment_status
pos_table_reference
kds_session_reference
closed_at
closed_by
```

Recommended session statuses:

```text
not_open
open
ordering_enabled
ordering_paused
staff_confirmation_required
payment_pending
partially_paid
paid
closing
closed
transferred
merged
split
disputed
```

Orders must reference the table session used at order time.

---

## 12. Session Open Policy

A table session may be opened by:

- staff action;
- customer QR/NFC scan where policy allows;
- POS table open event;
- waiting/preorder handoff;
- kiosk assisted dine-in order;
- admin/manual operation.

Session open must verify:

- table is active;
- object maps to table;
- store is correct;
- no conflicting open session exists unless merge policy allows;
- ordering channel is enabled;
- staff confirmation requirement is known.

If multiple open sessions exist for one table, automated customer ordering must be blocked or require staff confirmation.

---

## 13. Session Close Policy

A table session may be closed only when closure conditions pass.

Closure checks:

- all orders resolved;
- payment state resolved;
- cancellation/refund state resolved;
- POS table state closed or reconciled;
- KDS pending tickets resolved or acknowledged;
- customer dispute not open;
- manual correction not pending;
- receipt behavior completed or restricted.

Closing a session must not delete its order, payment, receipt, or KDS evidence.

---

## 14. Table Transfer Policy

Table transfer must be explicit.

Examples:

- customer moves from table 3 to table 7;
- waiting customer assigned to table;
- table split due to party change;
- staff reassigns order to correct table;
- POS table transfer occurs externally.

Required transfer record:

```text
table_transfer_id
from_table_id
to_table_id
from_session_id
to_session_id
reason
actor_id
approval_id
pos_transfer_reference
kds_impact
payment_impact
receipt_impact
created_at
status
```

Table transfer must not create duplicate POS orders or duplicate KDS tickets.

---

## 15. Table Merge and Split Policy

Table merge and split must preserve order ownership.

Merge examples:

- two tables combine into one party;
- two sessions are billed together;
- staff combines KDS view.

Split examples:

- one party splits bill;
- a customer moves to another table;
- seat-level order separated.

Merge/split must preserve:

- original session IDs;
- order IDs;
- payment references;
- receipt references;
- KDS ticket references;
- customer support evidence.

Merge/split must not rewrite history.  
It must create linked relationship records.

---

## 16. Waiting / Preorder Session Handoff

Waiting/preorder handoff must bind a pre-table order to a valid table/session.

Required handoff fields:

```text
handoff_id
waiting_session_id
preorder_id
customer_reference
assigned_table_id
assigned_table_session_id
handoff_status
staff_actor_id
customer_arrival_confirmed_at
table_assigned_at
pos_write_allowed_at
created_at
```

Handoff states:

```text
waiting
customer_arrived
table_candidate_selected
table_confirmed
session_created
pos_write_ready
pos_write_completed
handoff_failed
manual_review_required
cancelled
```

A preorder must not become a dine-in table order until table/session identity is confirmed.

---

## 17. Kiosk Device Identity Policy

Each kiosk device must be registered.

Required kiosk fields:

```text
kiosk_device_id
tenant_id
store_id
device_label
device_type
assigned_terminal_id
assigned_zone_id
payment_terminal_id
status
last_heartbeat_at
last_operator_check_at
```

Kiosk orders must record the kiosk device ID.

If kiosk device identity is unknown or assigned to wrong store, production ordering must be blocked.

---

## 18. Staff Device Identity Policy

Staff device identity must be recorded for staff-assisted orders and overrides.

Required staff device context:

```text
staff_device_id
tenant_id
store_id
staff_actor_id
role
device_status
session_id
order_id
action_type
```

Staff device actions requiring audit:

- table assignment;
- session open/close;
- order confirmation;
- manual fallback;
- cancellation/refund override;
- table transfer;
- session merge/split;
- QR/NFC object suspension;
- customer dispute handling.

---

## 19. Device Health and Trust

Device identity must include health/trust status.

Device health may include:

- online/offline;
- last heartbeat;
- app version;
- assigned store;
- assigned role;
- secure session status;
- tamper/suspicious status;
- lost device status.

Device health states:

```text
trusted
degraded
offline
unverified
suspended
lost
compromised
retired
```

Untrusted devices must not initiate transaction-critical actions.

---

## 20. Object-to-Provider Mapping

Physical objects may need provider mapping.

Examples:

- table ID maps to POS table code;
- kiosk maps to POS terminal;
- payment terminal maps to provider merchant terminal;
- KDS station maps to kitchen lane;
- pickup display maps to order number flow.

Object-to-provider mapping must be verified before production.

Missing object/provider mapping must fail closed.

---

## 21. Object Scan Validation

When a customer scans QR/NFC, the gateway must validate:

- token integrity;
- object status;
- store identity;
- table mapping;
- session status;
- channel enablement;
- availability of ordering;
- staff confirmation requirement;
- suspicious scan pattern;
- expired or retired object version.

If validation fails, customer must receive safe message and staff/operations must receive actionable detail.

---

## 22. Suspicious Object Use

Suspicious object use may include:

- scans from unexpected geography or network pattern;
- repeated failed token validation;
- retired QR used;
- copied QR used outside store;
- object mapped to wrong store;
- high volume from one object;
- ordering from closed table;
- object used after suspended;
- device or token tampering.

Suspicious use must create security or incident event depending on impact.

Ordering may be blocked or require staff confirmation.

---

## 23. Customer Session Binding

A customer ordering session must be bound to object/table/session context.

Required session binding fields:

```text
customer_order_session_id
object_id
table_id
table_session_id
order_channel
customer_reference
started_at
last_activity_at
expires_at
status
```

Session binding must expire or refresh according to policy.

A stale customer session must not allow new orders without revalidation.

---

## 24. Session Expiry Policy

Customer and table sessions must have expiry rules.

Expiry may depend on:

- table session status;
- last activity;
- store closing;
- payment completion;
- table transfer;
- staff closure;
- QR/NFC object suspension;
- security risk.

Expired sessions must not allow new automated order submission.

If customer returns to expired session, the system must revalidate object and table state.

---

## 25. Payment Session Integrity

Payment session must align with table/order session.

Required payment session checks:

- order belongs to active or payable table session;
- payment amount matches session/order calculation snapshot;
- split payment state is known;
- prior payment is not duplicated;
- table transfer did not orphan payment;
- receipt identity can be linked.

Payment must not proceed when session identity is ambiguous.

---

## 26. KDS Context Integrity

KDS context must include correct table/session/device identity.

KDS ticket must show where operationally required:

- table number;
- seat number where applicable;
- order round;
- channel;
- kiosk/pickup code where applicable;
- preorder/waiting marker;
- transfer marker where applicable;
- staff confirmation marker where applicable.

KDS must not receive a ticket for the wrong table because object identity was stale.

---

## 27. Receipt Context Integrity

Receipt context must preserve:

- table ID;
- session ID;
- order channel;
- staff or customer initiation;
- POS receipt number;
- payment approval reference;
- table transfer or merge/split references where applicable.

Receipt evidence must allow investigation of table/session disputes.

---

## 28. Object Replacement Policy

When QR/NFC object or device is replaced:

- old object must be suspended or retired;
- new object must be registered;
- mapping must be verified;
- physical installation must be confirmed;
- old token must not remain active unless intended;
- dashboard must show current object;
- object replacement must create audit event.

Replacement must not silently remap old object to new table without verification.

---

## 29. Object Installation Verification

Physical installation must be verified.

Verification may include:

- staff confirms object placed at correct table;
- scan test confirms table/store mapping;
- POS table code test where applicable;
- KDS display test where applicable;
- customer-facing display test;
- photo or checklist evidence where operationally useful.

Object installation status must remain `installed_unverified` until verification passes.

---

## 30. Manual Correction Policy

If table/session/device identity is wrong, manual correction may be required.

Allowed corrections:

- attach order to correct session;
- mark wrong table assignment;
- create transfer record;
- create merge/split record;
- block affected object;
- create manual staff confirmation;
- annotate reconciliation case.

Prohibited corrections:

- changing original object scan evidence;
- deleting wrong-session record;
- rewriting original table ID without correction record;
- hiding customer-facing table mismatch;
- issuing refund/cancellation without payment evidence.

Manual correction must be audited.

---

## 31. Monitoring Requirements

The gateway must monitor identity integrity.

Required metrics:

- invalid object scan count;
- retired object scan count;
- unknown table scan count;
- duplicate open session count;
- stale session order attempt count;
- table transfer count;
- table merge/split count;
- wrong table incident count;
- kiosk unknown device count;
- staff device untrusted action count;
- suspicious object use count;
- handoff failure count;
- session/payment mismatch count.

Critical identity mismatch must alert operations.

---

## 32. Dashboard Requirements

Operations dashboard must show:

- active QR/NFC objects;
- object status by table;
- table session status;
- duplicate/conflicting sessions;
- kiosk device status;
- staff device trust status;
- waiting/preorder handoff status;
- table transfer/merge/split records;
- suspicious object use;
- identity-related incidents;
- objects requiring verification;
- retired objects still being scanned.

Dashboard must not show table ordering as enabled when object identity is unverified.

---

## 33. Incident Requirements

Identity incidents may include:

- QR/NFC maps to wrong table;
- order attached to wrong session;
- kiosk assigned to wrong store;
- staff device action unauthorized;
- preorder handed off to wrong table;
- table transfer duplicated order;
- merge/split corrupted payment state;
- receipt attached to wrong session;
- KDS ticket sent with wrong table;
- copied QR used outside intended context.

Incident response must classify:

- customer impact;
- staff impact;
- kitchen impact;
- payment impact;
- receipt impact;
- settlement impact;
- security impact.

---

## 34. Security Boundary

QR/NFC and device identity are also security boundaries.

Required security controls:

- signed or opaque scan token;
- tenant/store scope validation;
- object status validation;
- token rotation support;
- compromised object suspension;
- staff role validation for sensitive actions;
- device trust validation;
- audit event for identity changes;
- suspicious scan monitoring.

Public QR URLs must not expose enough information to forge table identity.

---

## 35. Kiosk / QR / Table Ordering Reuse

Kiosk, QR, and table ordering systems must reuse this identity boundary.

They must not independently decide:

- store identity;
- table identity;
- session identity;
- payment session identity;
- KDS route;
- receipt context;
- handoff state.

If an external kiosk or table ordering provider provides identity, the gateway must validate and map it before accepting transaction-critical actions.

---

## 36. Prohibited Practices

The following practices are prohibited:

- trusting table number from URL parameter without token validation;
- allowing unregistered QR/NFC object to create order;
- allowing retired object to remain active silently;
- mapping one QR object to new table without version/audit;
- accepting table order when session identity is ambiguous;
- writing preorder to POS before table/session confirmation when required;
- deleting wrong-session evidence;
- allowing untrusted device to execute refund/cancellation override;
- showing KDS wrong table due to stale object mapping;
- closing table session with unresolved payment or order state.

---

## 37. Minimum Acceptance Criteria

Table, session, object, QR/NFC, device, and handoff integrity is acceptable only when:

- identity object model exists;
- object registry exists;
- object status model exists;
- QR/NFC token validation exists;
- object versioning/rotation exists;
- table registry exists;
- table session model exists;
- session open/close policy exists;
- table transfer/merge/split policy exists;
- waiting/preorder handoff policy exists;
- kiosk and staff device identity policies exist;
- object scan validation exists;
- suspicious object use detection exists;
- payment/KDS/receipt context integrity exists;
- object replacement and installation verification exist;
- monitoring, dashboard, incident, and security controls exist.

---

## 38. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_identity_objects
pos_gateway_object_versions
pos_gateway_object_rotations
pos_gateway_table_registry
pos_gateway_seat_registry
pos_gateway_table_sessions
pos_gateway_customer_order_sessions
pos_gateway_session_bindings
pos_gateway_table_transfers
pos_gateway_table_merges
pos_gateway_table_splits
pos_gateway_waiting_preorder_handoffs
pos_gateway_kiosk_devices
pos_gateway_staff_devices
pos_gateway_device_trust_states
pos_gateway_object_scan_events
pos_gateway_identity_incidents
```

Recommended services:

```text
IdentityObjectRegistryService
QrNfcTokenValidationService
ObjectVersioningService
TableRegistryService
SeatRegistryService
TableSessionService
SessionOpenCloseService
TableTransferService
TableMergeSplitService
WaitingPreorderHandoffService
KioskDeviceIdentityService
StaffDeviceIdentityService
DeviceTrustService
ObjectScanValidationService
SuspiciousObjectUseDetector
PaymentSessionIntegrityService
KdsContextIntegrityService
ReceiptContextIntegrityService
IdentityMonitoringService
```

Recommended event types:

```text
pos_gateway.identity.object_registered
pos_gateway.identity.object_activated
pos_gateway.identity.object_suspended
pos_gateway.identity.object_retired
pos_gateway.identity.object_rotated
pos_gateway.identity.scan_validated
pos_gateway.identity.scan_rejected
pos_gateway.identity.table_session_opened
pos_gateway.identity.table_session_closed
pos_gateway.identity.table_transferred
pos_gateway.identity.table_merged
pos_gateway.identity.table_split
pos_gateway.identity.handoff_started
pos_gateway.identity.handoff_completed
pos_gateway.identity.device_trust_changed
pos_gateway.identity.suspicious_use_detected
pos_gateway.identity.incident_detected
```

---

## 39. Relationship To Adjacent Documents

This document is related to:

- 06080 POS Gateway order channel separation, dine-in, takeout, delivery, kiosk, table QR, and staff order routing policy;
- 06070 POS Gateway inventory, availability, sold-out, stock sync, and order blocking integrity policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- 06050 POS Gateway menu item, option, modifier, mapping template, versioning, and price integrity policy;
- POS Gateway KDS kitchen ticket routing policy;
- POS Gateway cancellation and refund exception policy;
- POS Gateway incident response and dispute investigation policy;
- waiting/preorder handoff and table ordering policies.

Where conflict exists, this document governs table/session/object/QR/NFC/device identity and handoff integrity for POS Gateway order routing.

---

## 40. Summary

Table, QR, NFC, kiosk, and waiting handoff flows depend on identity.

If identity is wrong, the order may go to the wrong table, wrong store, wrong kitchen lane, wrong receipt, wrong payment session, or wrong customer support case.

The POS Gateway must therefore treat physical objects and sessions as transaction infrastructure.

The correct standard is:

- register every object;
- validate every scan;
- verify every table/session;
- audit every transfer;
- preserve every handoff;
- block unknown identity;
- keep kiosk, QR, payment, KDS, and receipt context aligned.

A table order is safe only when the table identity is true.