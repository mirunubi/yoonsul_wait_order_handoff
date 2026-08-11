# 070190_Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff.md

## Document Control

- Document Number: 70190
- Document Type: Index
- Domain: External Integration Control Plane
- Lane: POS / VAN / PG External Payment Integration Governance
- Status: Draft
- Parent Index: [70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md](./070100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md)
- Root Index: [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./070000_Readme_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md)
- Related Integrity Index: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` (미작성)
- Previous: [70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md](./070180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md)
- Next: [70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md](./070200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md)

---

## 1. Purpose

This document closes the 70100 POS/VAN/PG external payment integration governance lane and hands off the remaining external integration concerns to the next control lanes.

The 70100 lane establishes that external payment providers are not final state authorities. POS, VAN, PG, simple payment providers, card acquirers, and settlement intermediaries may generate payment events, but the internal system must validate, normalize, log, reconcile, and, when required, compensate those events before financial state is finalized.

The closeout purpose is to confirm that the following defenses have been defined:

1. external provider trust boundary;
2. request and response ledger separation;
3. response field registry;
4. amount, tax, discount, service charge, and order match validation;
5. timeout and unknown-state treatment;
6. communication recovery runbook;
7. raw payload evidence and tamper check;
8. failure mode and state transition matrix.

This lane is not a complete payment integrity architecture. Full payment self-healing, idempotency, net cancel, Saga, transactional outbox, double-entry ledger, and hardware-level payment device integrity are handed off to the 75000 Payment Integrity Architecture lane.

---

## 2. Scope

### 2.1 In Scope

This closeout covers external payment integration governance for:

- POS payment responses;
- VAN approval and cancel responses;
- PG approval, confirm, cancel, refund, and webhook responses;
- simple payment responses, including domestic wallet and QR/barcode payments;
- card company, acquirer, and merchant approval metadata;
- terminal, merchant, provider, and trace identifiers;
- receipt, slip, approval number, cancel number, response code, and raw payload evidence;
- timeout, communication error, ambiguous payment state, and manual review entry conditions;
- payment failure mode classification and recovery routing.

### 2.2 Out of Scope

The following are not closed in this lane and must be handled by later lanes:

- external webhook event contract beyond payment response basics;
- delivery app order integration;
- external membership, coupon, voucher, and point integration;
- kiosk vendor and KDS vendor integration;
- accounting, tax, ERP, and bank deposit integrations;
- full settlement file processing and double-entry accounting ledger;
- payment self-healing architecture, including idempotency, net cancel, Saga, outbox, CDC, and compensation engine;
- local CAT terminal, serial port, VAN agent, secure boot, masking, and watchdog hardening.

---

## 3. Closed Document Set

| Document | Status | Closeout Role |
|---|---:|---|
| [70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md](./070100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md) | Closed by this index | Opens the POS/VAN/PG external payment integration governance lane. |
| [70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md](./070110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md) | Closed by this index | Defines provider trust boundary, evidence obligation, and liability separation. |
| [70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md](./070120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md) | Closed by this index | Separates request ledger, response ledger, and internal state authority. |
| [70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md](./070130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md) | Closed by this index | Registers canonical approval, cancel, receipt, and trace metadata. |
| [70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md](./070140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md) | Closed by this index | Requires amount, tax, discount, service charge, and order matching before confirmation. |
| [70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md](./070150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md) | Closed by this index | Treats timeout as unknown rather than failed and routes to inquiry or review. |
| [70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md](./070160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md) | Closed by this index | Defines store and manager action for communication error and reversal recovery. |
| [70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md](./070170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md) | Closed by this index | Preserves raw payload, hash, receipt evidence, and tamper-check data. |
| [70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md](./070180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md) | Closed by this index | Maps payment failure modes to state transitions, prohibited actions, and recovery actions. |

---

## 4. Lane-Level Control Principles

The 70100 lane is closed with the following mandatory principles.

### 4.1 External Response Is Evidence, Not Final Truth

An external response may be used as evidence, but it must not directly finalize internal payment, order, inventory, point, or settlement state.

The internal validation gate is the final state authority for:

- order confirmation;
- payment confirmation;
- cancel confirmation;
- refund confirmation;
- customer-facing completion message;
- kitchen ticket release;
- settlement inclusion;
- accounting posting.

### 4.2 Request and Response Ledgers Must Be Separate

A payment request must be recorded before the external call is made. A payment response must be stored as a separate inbound event. Final state is derived only after joining the request ledger, response ledger, and validation result.

### 4.3 Timeout Is Not Failure

Timeout, socket disconnect, VAN agent no response, PG API timeout, webhook delay, and device crash must enter an unknown or ambiguous state until inquiry, reconciliation, or authorized manual review resolves the event.

### 4.4 Amount Matching Is Non-Negotiable

Payment confirmation requires strict matching of expected and approved financial values, including:

- total amount;
- taxable amount;
- tax amount;
- discount amount;
- service charge;
- tip if applicable;
- currency;
- order identifier;
- store identifier;
- terminal identifier;
- provider transaction identifier.

### 4.5 Raw Evidence Must Be Preserved

All external payment responses must preserve raw payload and normalized fields. Hash, receipt, approval number, response code, trace identifier, received time, and provider identifier must be retained for audit and dispute handling.

---

## 5. Required State Authority Model

The following model is mandatory for all documents handed off from this lane.

| External Event | Allowed Internal Interpretation | Prohibited Shortcut |
|---|---|---|
| POS returns success | Evidence of possible approval | Direct order completion without validation |
| VAN returns approval number | Evidence of external approval | Settlement inclusion without amount/order match |
| PG confirm succeeds | Evidence of authorization | Inventory, point, or ledger finalization without internal transaction completion |
| Timeout occurs | Unknown state | Treating as payment failure |
| Cancel request returns timeout | Cancel unknown | Telling customer cancellation is complete |
| Duplicate response arrives | Possible replay or retry | Creating second payment |
| Response code is unknown | Provider mapping gap | Defaulting to success or failure |
| Receipt data is missing | Evidence gap | Marking transaction audit-complete |

---

## 6. Handoff to 70200 External RPC/API/Webhook Contract Lane

The next lane must expand the external response concept beyond payment response into generic external event contracts.

The 70200 lane must define:

- external RPC request/response envelope;
- callback and webhook event envelope;
- signature verification;
- event timestamp and replay-window control;
- idempotency key and event deduplication;
- provider event sequence handling;
- canonical event mapping;
- DLQ, retry, replay, and event rehydration;
- event contract certification checklist.

Minimum next documents:

| Next Document | Purpose |
|---|---|
| [70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md](./070200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md) | Opens the generic external RPC/API/Webhook event control lane. |
| 70210_Spec_External_Event_Envelope_Provider_Message_Id_Timestamp_Signature_And_Source_Metadata.md | Defines canonical external event envelope. |
| 70220_Policy_External_Webhook_Signature_Replay_Window_And_Duplicate_Event_Control.md | Controls webhook authenticity, replay, and duplicate event risk. |
| 70230_Policy_External_Event_Canonical_Mapping_Response_Code_And_State_Translation.md | Maps provider-specific codes to internal canonical event semantics. |
| 70240_Runbook_External_Event_Delivery_Failure_DLQ_Replay_And_Manual_Rehydration.md | Defines DLQ, replay, and manual rehydration process. |

---

## 7. Handoff to 75000 Payment Integrity Architecture Lane

This 70100 lane identifies the external evidence layer, but it does not fully define financial self-healing architecture. The following must be handled in the 75000 lane:

- idempotency key generation, storage, TTL, and response replay;
- duplicate payment prevention;
- delayed net cancel and reversal worker;
- Saga orchestration for order, inventory, point, coupon, payment, and receipt workflows;
- compensation transaction model;
- transactional outbox and CDC relay;
- double-entry ledger and accounting posting;
- reconciliation between internal ledger, provider ledger, and bank deposit;
- local payment agent, CAT terminal, serial port, secure boot, masking, and watchdog integrity.

Minimum related 75000 documents:

| Related Document | Purpose |
|---|---|
| `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` (미작성) | Opens the payment integrity architecture lane. |
| 75100_Index_Payment_Idempotency_Duplicate_Prevention_And_Request_Replay_Control.md | Defines idempotency and duplicate prevention. |
| 75200_Index_Net_Cancel_Delayed_Reversal_And_Self_Healing_Payment_Recovery.md | Defines net cancel and delayed reversal. |
| 75300_Index_Saga_Orchestration_Compensation_Transaction_And_Partial_Failure_Control.md | Defines distributed transaction recovery. |
| 75400_Index_Transactional_Outbox_CDC_Event_Relay_And_Dual_Write_Prevention.md | Defines event delivery integrity. |
| 75500_Index_Double_Entry_Ledger_Settlement_Reconciliation_And_Accounting_Integrity.md | Defines ledger and reconciliation integrity. |

---

## 8. Open Gaps

The following gaps remain open after this closeout and must not be treated as complete.

| Gap ID | Gap | Target Lane |
|---|---|---|
| GAP-70190-001 | Provider-specific response code catalogs are not yet fully mapped. | 70230 / provider-specific specs |
| GAP-70190-002 | Inquiry API availability differs by POS/VAN/PG provider. | 70300 / onboarding checklist |
| GAP-70190-003 | Receipt payload formats vary by terminal and provider. | 70130 / provider adapters |
| GAP-70190-004 | Cross-border approval, FX amount, RMB/KRW conversion, and global gateway trace metadata need a separate lane. | 71700 or 70000 expansion |
| GAP-70190-005 | Delivery-app-originated payment and order-event mismatch is not covered by 70100. | 71000 / 71100 |
| GAP-70190-006 | Membership, coupon, and external point reconciliation is not covered by 70100. | 71200 / 75300 |
| GAP-70190-007 | Hardware payment agent crash and local DB mismatch are only referenced, not fully governed. | 75000 / hardware integrity lane |

---

## 9. Closeout Criteria

The 70100 lane is considered closed only when the following are true:

- [ ] all 70100~70180 documents exist and follow the filename/H1 rule;
- [ ] each document links to parent, previous, next, and related 75000 lane where applicable;
- [ ] every external payment response is treated as evidence, not final state;
- [ ] timeout is explicitly mapped to unknown or ambiguous state;
- [ ] request ledger and response ledger are separated;
- [ ] raw payload and hash evidence are required;
- [ ] failure modes have recovery actions and prohibited actions;
- [ ] open gaps are registered for later lanes;
- [ ] 70200 and 75000 handoff documents are referenced.

---

## 10. Operating Rule

No implementation, test, pilot, or store rollout may treat POS/VAN/PG payment integration as ready unless the 70100 lane is closed and the required 70200 and 75000 handoff items are either completed or explicitly accepted as deferred risks.
