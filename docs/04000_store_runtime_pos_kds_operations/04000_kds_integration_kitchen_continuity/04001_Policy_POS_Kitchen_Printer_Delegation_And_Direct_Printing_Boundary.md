# 04001_Policy_POS_Kitchen_Printer_Delegation_And_Direct_Printing_Boundary

## 1. Purpose

This policy defines the boundary between POS-delegated kitchen printing and platform-controlled direct kitchen printing.

The purpose is to prevent the platform from treating POS order acceptance as proof that the kitchen ticket was successfully printed, routed, read, and acted upon by store staff.

Kitchen printing is a separate operational event from POS order submission.

The POS Gateway must preserve clear evidence of what the platform controlled, what the POS provider controlled, what the printer controlled, and what the store operator had to recover manually.

## 2. Scope

This policy applies to:

* POS-delegated kitchen printing
* Direct ESC/POS kitchen printing
* Network printer routing
* Local agent print routing
* Kitchen ticket generation
* Print acknowledgment uncertainty
* Print retry behavior
* Duplicate print prevention
* Printer offline handling
* Printer IP change handling
* Garbled or malformed ticket handling
* Kitchen ticket reprint
* Store-side manual recovery
* Audit evidence for print-related events

This policy applies to all POS-connected flows where kitchen ticket output is required, including dine-in, preorder, table order, takeout, waiting-to-order handoff, and manual-assisted order flows.

## 3. Core Principle

POS order acceptance is not the same as kitchen print success.

A POS provider may acknowledge that an order was accepted while the kitchen printer remains offline, jammed, disconnected, frozen, misconfigured, or unable to print the ticket.

The POS Gateway must separate:

* Order submitted to POS
* POS accepted order
* POS rejected order
* POS delegated print responsibility
* Platform attempted direct print
* Printer accepted print command
* Printer output was operator-confirmed
* Store manually recovered the order

The platform must not collapse these into one generic “order success” state.

## 4. Kitchen Print Boundary

Kitchen printing may be controlled through different paths.

```
[Core Order Domain]
         |
         v
[POS Gateway Print Boundary]
         |
  ------------------------------
  |                            |
  v                            v
[POS Delegated Print]      [Direct Platform Print]
  |                            |
  v                            v
[POS Printer Routing]      [Local Agent / Network Printer]
  |                            |
  v                            v
[Kitchen Ticket Output]    [Kitchen Ticket Output]
```

Each path has different evidence, responsibility, and failure modes.

## 5. Non-Negotiable Rules

### 5.1 POS ACK Is Not Print ACK Rule

A POS ACK must not be treated as kitchen printer ACK.

The audit log must distinguish:

* POS order acceptance
* POS print delegation
* Printer command dispatch
* Printer command acceptance, if known
* Operator confirmation
* Print failure
* Reprint

### 5.2 Responsibility Boundary Rule

The system must record which party was responsible for kitchen printing in each order flow.

Possible responsibility owners include:

* POS provider
* Store POS application
* Platform Gateway
* Local agent
* Network printer
* Store operator
* Manual recovery process

The responsibility owner must be visible in audit and operator tools.

### 5.3 Duplicate Ticket Prevention Rule

Print retry must be idempotent or operator-controlled.

The system must avoid blindly retrying print commands in a way that creates duplicate kitchen tickets.

### 5.4 Print Failure Must Not Disappear Rule

If a print failure is detected, suspected, or manually reported, the order must enter a visible recovery state.

The system must not leave the order in a silent success state when the kitchen may not have received it.

### 5.5 Direct Printing Must Be Isolated Rule

Direct printer control must be implemented as a separate printer driver or print adapter layer.

Provider-specific POS adapter logic must not be mixed with printer command generation logic.

## 6. Print Control Modes

Each store and provider path must declare one print control mode.

### 6.1 POS Delegated Print Mode

The platform submits the order to the POS provider.

The POS provider or POS application is responsible for printing kitchen tickets.

Required evidence:

* POS submit attempt
* POS ACK or rejection
* POS print delegation flag
* Provider print responsibility owner
* Store recovery instruction
* Any provider print status, if available

This is the preferred early integration mode when the provider handles kitchen routing.

### 6.2 Direct Gateway Print Mode

The platform Gateway generates and sends the kitchen print payload directly.

This may use:

* ESC/POS command
* Network printer IP
* Local print agent
* Store-side print service
* Printer SDK
* Cloud print bridge, if supported

Required evidence:

* Ticket generation result
* Printer target
* Print command dispatch
* Print command response, if available
* Retry state
* Reprint state
* Operator confirmation, if required

### 6.3 Hybrid Print Mode

The POS provider receives the order, but the platform also prints a supplemental kitchen ticket.

This mode is risky because duplicate kitchen execution may occur.

Hybrid mode requires:

* Explicit store configuration
* Ticket labeling
* Duplicate prevention rule
* Operator training
* Audit classification
* Provider-specific readiness approval

### 6.4 Manual Kitchen Note Mode

The provider cannot reliably print structured kitchen tickets.

The Gateway may generate a manual kitchen note, operator alert, or screen-based instruction.

This mode is degraded.

It requires:

* Operator confirmation
* Manual recovery path
* Customer-facing delay state, if needed
* Audit evidence

### 6.5 Unsupported Print Mode

If an order path requires kitchen output but no reliable print, screen, or manual recovery path exists, the integration must be blocked from production.

## 7. Printer Capability Profile

Each printer or print path must have a capability profile when direct printing is used.

The profile should include:

```
printer_profile_id
store_id
printer_name
printer_role
printer_connection_type
printer_ip
printer_port
printer_model
manufacturer
command_protocol
supports_esc_pos
supports_korean_encoding
supports_multilingual_text
supports_barcode
supports_qr
supports_cut_command
supports_cash_drawer_kick
supports_status_query
supports_auto_retry
max_line_width
font_size_support
kitchen_station
active_flag
last_verified_at
```

Printer capability must be verified during store onboarding.

## 8. Ticket Content Requirements

A kitchen ticket must include enough operational information for staff to fulfill the order.

Required fields may include:

* Store name or store code
* Kitchen station
* Platform order ID or short order number
* POS receipt number, if available
* Order time
* Requested pickup or table time
* Order type
* Table number or waiting session, if applicable
* Menu lines
* Option lines
* Quantity
* Kitchen notes
* Allergy or caution notes, if supported
* Customer request note, if allowed
* Payment status indicator, if operationally required
* Reprint indicator, if applicable

Sensitive customer data must be minimized.

## 9. Ticket Identity And Idempotency

Each kitchen ticket must have a stable ticket identity.

A ticket identity should include:

```
kitchen_ticket_id
platform_order_id
store_id
kitchen_station
print_sequence
print_reason
idempotency_key
original_ticket_id
reprint_flag
```

Print reasons may include:

```
INITIAL_PRINT
RETRY_PRINT
OPERATOR_REPRINT
RECOVERY_PRINT
VOID_NOTICE
CANCEL_NOTICE
REMAKE_NOTICE
MANUAL_NOTE
```

The printer layer must use ticket identity to avoid uncontrolled duplicate prints.

## 10. Print Status Classification

The Gateway must normalize print-related states.

Allowed states include:

```
PRINT_NOT_REQUIRED
PRINT_DELEGATED_TO_POS
PRINT_PENDING
PRINT_DISPATCHED
PRINT_ACKNOWLEDGED
PRINT_STATUS_UNKNOWN
PRINT_FAILED
PRINT_RETRY_SCHEDULED
PRINT_RETRY_BLOCKED
PRINT_OPERATOR_CONFIRMATION_REQUIRED
PRINT_REPRINTED
PRINT_MANUALLY_RECOVERED
PRINT_UNSUPPORTED
```

Not every printer supports true ACK.

If printer status is unknown, the system must record unknown state instead of pretending success.

## 11. POS Delegated Print Evidence

When print is delegated to POS, the Gateway must record:

* Provider ID
* Adapter version
* POS order submission time
* POS ACK time
* Provider receipt or order reference
* Print delegation mode
* Whether provider exposes printer status
* Whether provider exposes kitchen routing
* Store recovery instruction
* Operator escalation rule

If the kitchen ticket does not print after POS ACK, the audit trail must show that platform responsibility ended at POS order acceptance unless direct print fallback was configured.

## 12. Direct Print Evidence

When direct printing is used, the Gateway must record:

* Ticket generation time
* Printer target
* Printer profile
* Local agent identity, if used
* Print command reference
* Print command response
* Print status query result, if available
* Retry attempt count
* Reprint attempt count
* Operator confirmation
* Failure reason
* Recovery outcome

This evidence is required because direct printing makes the platform responsible for the kitchen ticket path.

## 13. ESC/POS And Printer Fragmentation

Printer behavior may differ by model and manufacturer.

Differences may include:

* Korean encoding support
* Character width
* Font size
* Bold command
* Line feed handling
* Cut command
* QR code command
* Barcode command
* Cash drawer command
* Paper width
* Status query support
* Buffer behavior
* Network timeout behavior

The platform must not assume that one ESC/POS payload works for every printer.

Printer-specific formatting must be isolated inside the printer adapter layer.

## 14. Text Encoding And Formatting

Kitchen tickets must be tested for:

* Korean text
* English text
* Numeric menu codes
* Multilingual names, if supported
* Long menu names
* Long option names
* Special characters
* Emoji exclusion
* Line wrapping
* Text truncation
* Paper cut position

If truncation or normalization is required, the rule must be documented and auditable.

## 15. Print Retry Policy

Print retry must be controlled.

The retry policy must define:

* Retry eligibility
* Maximum retry count
* Retry delay
* Backoff behavior
* Duplicate print risk
* Operator confirmation requirement
* When to stop retrying
* When to show manual recovery

Blind retry is prohibited for print commands that may have succeeded but returned unknown status.

## 16. Duplicate Print Handling

Duplicate print may occur when:

* Print command succeeds but response times out
* Operator presses reprint
* POS and platform both print
* Retry sends the same ticket twice
* Local agent reconnects and replays old print jobs
* Network printer buffers commands during outage

The Gateway must mark duplicate-risk states clearly.

Where possible, reprinted tickets must include a visible label such as:

```
REPRINT
DUPLICATE CHECK REQUIRED
RECOVERY PRINT
CANCEL NOTICE
```

The exact label may be localized later, but the operational intent must remain clear.

## 17. Printer Offline Handling

If printer offline is detected, the system must:

* Mark print state as failed or unknown
* Notify operator
* Preserve order state
* Provide manual kitchen recovery option
* Prevent infinite retry loop
* Preserve print failure evidence
* Trigger device health warning
* Allow controlled reprint after recovery

The order must not disappear from kitchen visibility.

## 18. Local Agent Relationship

Direct print through a local agent requires:

* Local agent identity
* Agent version
* Store binding
* Device binding
* Heartbeat
* Printer reachability check
* Print job queue
* Offline replay policy
* Security boundary
* Audit event emission

The local agent must not mutate core order state directly.

It may report print results to the Gateway.

## 19. Kitchen Station Routing

Some stores may route tickets by kitchen station.

Examples:

* Main kitchen
* Beverage station
* Fry station
* Cold station
* Packing station
* Hall service station

Routing rules must be explicit.

A menu item may map to one or more kitchen stations.

If the provider controls routing internally, the Gateway must record that routing is provider-delegated.

If the platform controls routing, the Gateway must record the routing rule version.

## 20. Cancel, Void, And Remake Tickets

Kitchen printing must support operational notices where applicable.

Examples:

* Cancel ticket
* Void ticket
* Refund notice
* Remake notice
* Delay notice
* Table move notice
* Pickup time change notice

These notices must not be confused with initial production tickets.

The ticket reason must be visible.

## 21. Operator Recovery Requirements

When kitchen printing fails or is uncertain, the operator console must show:

* Order ID
* Kitchen ticket ID
* Print mode
* Printer target
* Current print status
* Whether POS ACK was received
* Whether direct print was attempted
* Whether retry is safe
* Whether manual recovery is required
* Allowed actions
* Required confirmation

Allowed operator actions may include:

```
MARK_KITCHEN_RECEIVED
RETRY_PRINT
REPRINT_WITH_LABEL
SWITCH_TO_MANUAL_NOTE
CANCEL_ORDER
ESCALATE_DEVICE_ISSUE
ACKNOWLEDGE_POS_PRINT_RESPONSIBILITY
```

Operator actions must be audited.

## 22. Customer-Facing Messaging

Customer-facing messages must be cautious.

The customer should not see internal printer details unless required.

Possible customer-facing states:

```
The store is confirming your order.
Your order has been received by the store.
The store is preparing your order.
The store needs a moment to confirm this order.
This order could not be confirmed and will be canceled.
```

Customer-facing messaging must not expose printer IPs, provider internals, device errors, raw print payloads, or local network details.

## 23. Audit Requirements

Every print-related transition must preserve:

* Platform order ID
* Kitchen ticket ID
* Store ID
* Provider ID
* Print mode
* Printer profile ID, if applicable
* Kitchen station
* Ticket reason
* POS ACK reference, if delegated
* Print command reference, if direct
* Print status
* Retry count
* Reprint count
* Operator action, if any
* Failure reason
* Recovery outcome
* Trace ID
* Idempotency key
* Gateway version
* Printer adapter version
* Local agent version, if applicable
* Timestamp

Sensitive values must be redacted, tokenized, or encrypted according to the security runtime policy.

## 24. Test Requirements

Each provider or printer integration must test:

* POS delegated print path
* Direct print path, if supported
* Printer offline
* Printer timeout
* Unknown print result
* Retry after timeout
* Duplicate print risk
* Operator reprint
* Cancel ticket
* Remake ticket
* Long Korean menu name
* Option-heavy ticket
* Multilingual ticket, if supported
* Kitchen station routing
* Local agent disconnect
* Printer IP change
* Audit preservation for all print states

A provider or printer path cannot be production-ready without kitchen print evidence.

## 25. Anti-Patterns

The following are prohibited:

* Treating POS ACK as kitchen print success
* Retrying print commands blindly
* Mixing POS adapter code and printer driver code
* Sending customer personal data unnecessarily to kitchen tickets
* Using one printer format for all printer models without verification
* Ignoring Korean encoding and line width issues
* Hiding printer failure from operators
* Allowing direct print without device identity and audit
* Allowing local agent to mutate core order state directly
* Running hybrid POS and direct print without duplicate prevention

## 26. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05320 POS Menu Hierarchy Option Transformer Policy
05330 POS Master Data Sync And Precheck Validation Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Kitchen printing is an operational execution boundary and must not be hidden inside generic POS success handling.

## 27. Final Rule

The POS Gateway must always be able to answer whether the platform submitted the order, whether the POS accepted it, who owned kitchen printing, whether direct print was attempted, and what recovery happened if the kitchen did not receive the ticket.

If the system cannot distinguish POS acceptance from kitchen ticket delivery, the kitchen execution boundary has failed.
