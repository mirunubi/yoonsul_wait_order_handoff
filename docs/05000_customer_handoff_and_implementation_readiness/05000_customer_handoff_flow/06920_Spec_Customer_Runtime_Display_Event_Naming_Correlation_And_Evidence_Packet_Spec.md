# 06920_Spec_Customer_Runtime_Display_Event_Naming_Correlation_And_Evidence_Packet_Spec

## 1. Purpose

This specification defines the Customer Runtime display event naming, correlation, and evidence packet structure.

The purpose is to ensure that customer-facing display events can be traced across waiting, table, order, payment, refund, coupon, support, privacy, notification, kiosk, native app, and recovery flows.

A display event is useful only when it can be correlated.

The system must be able to reconstruct:

- Which customer journey produced the display
- Which runtime state triggered it
- Which message and action were shown
- Which customer action followed
- Which evidence record proves it
- Which support, finance, privacy, or rollout case consumed it
- Which release or QA gate approved the behavior

## 2. Scope

This specification covers:

- Display event naming convention
- Message event naming convention
- Action event naming convention
- Notification event naming convention
- Error and recovery event naming convention
- Stale-state event naming convention
- Emergency disable event naming convention
- Correlation ID model
- Customer journey correlation
- Session and surface correlation
- Payment/refund/cancel correlation
- Support and privacy correlation
- Evidence packet structure
- Evidence packet lifecycle
- Redaction and visibility rules
- QA and closeout usage

This specification does not define final physical event bus design, database DDL, analytics warehouse schema, message broker implementation, or full observability platform.

## 3. Baseline Dependency

This specification depends on:

`06910_Spec_Customer_Runtime_Display_Registry_Data_Model_And_Table_Candidate_Spec.md`

It must remain consistent with:

`06860_Spec_Customer_Runtime_Display_Evidence_Event_And_Audit_Schema_Spec.md`

`06700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`06620_Policy_Customer_Runtime_Evidence_Packet_Audit_Trail_Cross_Flow_Traceability_Closeout_Handoff_And_Governance.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

## 4. Core Principle

Every customer-facing display event must be named, correlated, and packet-ready.

An event without correlation is not useful for dispute resolution.  
An event without naming consistency is not useful for QA or audit.  
An event without packet linkage is not useful for closeout.

Display events must support:

1. Runtime reconstruction
2. Customer dispute review
3. Support case review
4. Payment/refund/cancel review
5. Privacy incident review
6. QA/retest proof
7. Release gate proof
8. Daily closeout proof
9. Rollout blocker analysis
10. Audit and governance review

## 5. Event Naming Principles

Event names must be:

- Lowercase snake case
- Verb-based
- Runtime-neutral enough to survive frontend changes
- Specific enough to route evidence
- Free of tenant, store, customer, provider, or device identifiers
- Stable across UI surfaces
- Versioned through schema version, not event name, unless meaning changes

Do not name events after UI components.

Avoid:

```text id="l8r2wa"
waiting_page_button_clicked
react_component_error
payment_modal_closed
kiosk_screen_3_loaded
blue_button_tapped