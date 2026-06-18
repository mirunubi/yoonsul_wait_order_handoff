# 005016_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix

## 1. Purpose

This matrix defines the Customer Runtime state, authority, event, and evidence coverage structure.

The purpose is to verify that every customer-facing runtime state has:

- Defined authority
- Defined event trigger
- Defined evidence output
- Defined customer-facing status
- Defined staff/manager/support visibility
- Defined closeout or handoff behavior
- Defined risk handling when the state is ambiguous or failed

This matrix converts the Customer Runtime policy lane into an implementation-readiness control map.

## 2. Scope

This matrix covers:

- Entrance state coverage
- Waiting queue state coverage
- Table session state coverage
- Customer link/token state coverage
- Web app state coverage
- Native app continuity state coverage
- Customer identity state coverage
- Membership and benefit state coverage
- Support case state coverage
- Privacy and consent state coverage
- Evidence packet state coverage
- Closeout and rollout state coverage

This matrix does not define database schema, API contracts, UI components, or final event payloads.  
Those must be handled in downstream specification documents.

## 3. Baseline Dependency

This matrix depends on:

`005015_Index_Customer_Runtime_Lane_Document_Map_Readiness_Status_Handoff_And_Governance.md`

It also covers the policy lane from:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

through:

`005014_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 4. Core Principle

A customer-facing state is not implementation-ready until it has authority, event, evidence, and recovery coverage.

The system must be able to answer:

1. Who or what is allowed to create this state?
2. Who or what is allowed to change this state?
3. What event records the transition?
4. What evidence proves the transition?
5. What does the customer see?
6. What does staff see?
7. What does manager/support/finance/privacy/audit see?
8. What happens if the state is stale, ambiguous, failed, or disputed?
9. Does closeout review this state?
10. Does rollout depend on this state?

## 5. Coverage Dimensions

Each state must be checked against the following dimensions.

| Dimension | Meaning |
|---|---|
| State | Runtime state or lifecycle marker |
| Source | Customer, staff, manager, system, provider, support, finance, privacy, or audit |
| Authority | Actor or component allowed to create/change state |
| Event | Event that records state transition |
| Evidence | Evidence record or packet output |
| Customer Display | What the customer may see |
| Staff Visibility | What staff may see or do |
| Manager Authority | Whether manager approval or override is required |
| Support Handoff | Whether unresolved state can create support case |
| Finance Handoff | Whether financial review is affected |
| Privacy Sensitivity | Whether customer data visibility risk exists |
| Closeout Impact | Whether daily closeout must review it |
| Rollout Risk | Whether missing/failed state blocks pilot or rollout |

## 6. Entrance State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Entry Link Available | System / Store Config | `customer_entry_link_available` | Link configuration evidence | Entry available | No, unless exception | Medium |
| Entry Link Opened | Customer Device | `customer_entry_link_opened` | Link open evidence | Entry page displayed | Yes, if failed/invalid | Medium |
| Store Context Resolved | System | `customer_store_context_resolved` | Store context evidence | Correct store shown | Yes, if mismatch | High |
| Store Context Invalid | System | `customer_store_context_invalid` | Invalid context evidence | Safe error / ask staff | Yes | High |
| Entrance Assist Created | Staff / Device | `entrance_assist_session_created` | Staff/device evidence | Waiting or guidance started | Yes | Medium |
| Entry Recovery Required | System / Staff | `customer_entry_recovery_required` | Recovery evidence | Recovery guidance | Yes | Medium |
| Entry Failed | System | `customer_entry_failed` | Failure evidence | Safe error | Yes | High if repeated |

## 7. Waiting State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Waiting Draft | Customer / Staff | `waiting_draft_created` | Draft evidence | Waiting being prepared | No, unless abandoned | Low |
| Waiting Active | Store Runtime | `waiting_activated` | Waiting session evidence | Waiting registered | Yes | High |
| Queue Position Assigned | Store Runtime | `waiting_queue_position_assigned` | Queue evidence | Queue status | Yes | High |
| Queue Reordered | Staff / Manager | `waiting_queue_reordered` | Before/after evidence | Updated queue status | Yes | High |
| Customer Called | Staff / System | `waiting_customer_called` | Call evidence | Called / please arrive | Yes | High |
| Arrival Pending | Store Runtime | `waiting_arrival_pending` | Call/arrival evidence | Please confirm arrival | Yes | Medium |
| Arrival Confirmed | Customer / Staff | `waiting_arrival_confirmed` | Arrival evidence | Arrival confirmed | Yes | Medium |
| No-Show Pending | Staff / System | `waiting_no_show_pending` | Pending evidence | May show limited notice | Yes | High |
| No-Show Confirmed | Staff / Manager Rule | `waiting_no_show_confirmed` | No-show evidence | No longer active / ask staff | Yes | High |
| No-Show Reversed | Manager / Authorized Staff | `waiting_no_show_reversed` | Reversal evidence | Waiting restored / staff guidance | Yes | High |
| Waiting Expired | System | `waiting_expired` | Expiration evidence | Expired / recover if allowed | Yes | Medium |
| Waiting Cancelled | Customer / Staff | `waiting_cancelled` | Cancel evidence | Cancelled | Yes, if after call | Medium |
| Waiting Recovered | Staff / System | `waiting_recovered` | Recovery evidence | Waiting restored or restarted | Yes | Medium |
| Waiting Disputed | Customer / Staff / Support | `waiting_dispute_created` | Support/dispute evidence | Support checking | Yes | High |

## 8. Table State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Table Available | Store Runtime | `table_available` | Table state evidence | Usually hidden | No | Medium |
| Table Candidate Selected | Staff / System | `table_candidate_selected` | Candidate evidence | Preparing table | Yes, if customer-visible | Medium |
| Table Session Created | Staff / Store Runtime | `table_session_created` | Table session evidence | Table assigned | Yes | High |
| Waiting Linked To Table | Store Runtime | `waiting_linked_to_table_session` | Linkage evidence | Seating confirmed | Yes | High |
| Preorder Linked To Table | Store Runtime / Staff | `preorder_linked_to_table_session` | Preorder linkage evidence | Order linked to table | Yes | High |
| Table Reassigned | Staff / Manager | `table_session_reassigned` | Before/after evidence | Updated table guidance | Yes | High |
| Table Merge Requested | Staff | `table_merge_requested` | Merge request evidence | Usually staff-managed | Yes | Medium |
| Table Merge Completed | Manager / Store Runtime | `table_merge_completed` | Merge evidence | Updated service context | Yes | High |
| Table Split Requested | Staff | `table_split_requested` | Split request evidence | Usually staff-managed | Yes | Medium |
| Table Split Completed | Manager / Store Runtime | `table_split_completed` | Split evidence | Updated service context | Yes | High |
| Table Session Closing | Staff / Store Runtime | `table_session_closing` | Closing evidence | Service closing | Yes | Medium |
| Table Session Closed | Store Runtime | `table_session_closed` | Closeout evidence | Closed / receipt/support path | Yes | High |
| Table Session Disputed | Customer / Staff / Support | `table_session_dispute_created` | Support evidence | Support checking | Yes | High |

## 9. Customer Link And Token State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Static Link Published | Store Config | `static_customer_link_published` | Config evidence | QR/NFC entry available | No, unless invalid | Medium |
| Dynamic Link Issued | System / Staff | `dynamic_customer_link_issued` | Link issue evidence | Link available | Yes, if session-specific | High |
| Token Validated | System | `customer_token_validated` | Validation evidence | Action available | Yes, if sensitive | High |
| Token Expired | System | `customer_token_expired` | Expiration evidence | Link expired / recover | Yes | Medium |
| Token Revoked | System / Staff / Manager | `customer_token_revoked` | Revocation evidence | Link no longer available | Yes | High |
| Token Replay Blocked | System | `customer_token_replay_blocked` | Abuse/replay evidence | Safe error | Yes | High |
| Link Scope Mismatch | System | `customer_link_scope_mismatch` | Scope mismatch evidence | Safe error / ask staff | Yes | High |
| Link Recovery Started | Customer / Staff | `customer_link_recovery_started` | Recovery evidence | Recovery guidance | Yes | Medium |
| Staff Assist Link Created | Staff | `staff_assist_link_created` | Staff actor evidence | Assisted link available | Yes | High |
| Support Recovery Link Created | Support | `support_recovery_link_created` | Support evidence | Recovery link available | Yes | High |
| Link Privacy Incident | System / Staff / Customer | `customer_link_privacy_incident_created` | Privacy incident evidence | Support/privacy review | Yes | Critical |

## 10. Web App State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Web Session Created | Customer / System | `customer_web_session_created` | Web session evidence | Session started | Yes, if abandoned with order/payment | Medium |
| Guest Session Attached | System | `guest_session_attached_to_web` | Guest linkage evidence | Continue as guest | Yes, if support case | Medium |
| Account Session Attached | Customer / System | `account_session_attached_to_web` | Account linkage evidence | Signed in / account linked | Yes, if merge/conflict | High |
| Menu Displayed | System | `customer_menu_displayed` | Menu display evidence | Menu visible | Yes, if availability dispute | Medium |
| Cart Draft Created | Customer | `cart_draft_created` | Cart evidence | Cart started | No, unless submitted | Low |
| Cart Updated | Customer | `cart_updated` | Cart change evidence | Cart updated | No, unless disputed | Low |
| Preorder Submitted | Customer | `preorder_submitted` | Submission evidence | Order being checked | Yes | High |
| Preorder Accepted For Review | Store Runtime | `preorder_accepted_for_review` | Runtime evidence | Checking order | Yes | High |
| Order Confirmed | POS / Store Runtime | `customer_order_confirmed` | Order confirmation evidence | Order confirmed | Yes | High |
| Order Rejected | Store Runtime / POS | `customer_order_rejected` | Rejection evidence | Order unavailable / ask staff | Yes | High |
| Payment Status Displayed | Store Runtime / Payment Boundary | `customer_payment_status_displayed` | Display evidence | Conservative payment status | Yes | Critical |
| Duplicate Submission Blocked | System | `customer_duplicate_submission_blocked` | Duplicate prevention evidence | Already submitted / checking | Yes | High |
| Web Recovery Required | System / Customer | `customer_web_recovery_required` | Recovery evidence | Recovery guidance | Yes | Medium |
| Web Error Displayed | System | `customer_web_error_displayed` | Error evidence | Safe error | Yes, if repeated/sensitive | Medium |
| Web Support Handoff | Customer / Staff / System | `customer_web_support_handoff_created` | Support evidence | Support checking | Yes | High |

## 11. Native App Continuity State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Native Scope Excluded | Release Owner | `native_app_scope_excluded` | Scope evidence | Not available | No | Low |
| Native Deep Link Opened | Customer / App | `native_deep_link_opened` | Deep link evidence | App flow opened | Yes, if in scope | Medium |
| Native Deep Link Resolved | System | `native_deep_link_resolved` | Resolution evidence | Correct session/context | Yes | High |
| Push Sent | System | `customer_push_sent` | Push evidence | Push received if available | Yes, if dispute | Medium |
| Push Opened | Customer / App | `customer_push_opened` | Open evidence | Linked status | Yes, if sensitive | Medium |
| App State Stale | System / App | `native_app_state_stale` | Stale evidence | Refresh required | Yes | Medium |
| App/Web Conflict Detected | System | `native_web_conflict_detected` | Conflict evidence | Safe recovery | Yes | High |
| Native Recovery Required | System | `native_recovery_required` | Recovery evidence | Recovery guidance | Yes | Medium |
| Native Support Handoff | Customer / System | `native_support_handoff_created` | Support evidence | Support checking | Yes | High |

## 12. Customer Identity State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Guest Identity Created | System | `guest_identity_created` | Guest evidence | Continue as guest | Yes, if linked to order/support | Medium |
| Customer Account Created | Customer / System | `customer_account_created` | Account evidence | Account created | Yes, if support/benefit | Medium |
| Account Linked To Session | Customer / System | `customer_account_linked_to_session` | Linkage evidence | Account linked | Yes | High |
| Guest Claimed By Account | Customer / Support | `guest_session_claimed_by_account` | Claim evidence | Order/session claimed | Yes | High |
| Guest-To-Account Merge Completed | System / Support | `guest_account_merge_completed` | Merge evidence | Account updated | Yes | High |
| Merge Requires Review | System / Support | `guest_account_merge_review_required` | Review evidence | Support checking | Yes | High |
| Duplicate Identity Detected | System | `duplicate_customer_identity_detected` | Duplicate evidence | Usually hidden / support checking | Yes | High |
| Identity Split Completed | Support / Manager | `customer_identity_split_completed` | Split evidence | Corrected | Yes | High |
| Wrong Account Link Detected | Customer / Staff / System | `wrong_account_link_detected` | Incident/support evidence | Support checking | Yes | Critical |
| Payment Identity Separated | System | `payment_identity_separated_from_customer` | Payment boundary evidence | Usually hidden | Yes, if disputed | High |

## 13. Membership And Benefit State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Membership Eligible | System | `membership_eligible` | Eligibility evidence | Eligible / join prompt | No, unless disputed | Low |
| Membership Enrolled | Customer / System | `membership_enrolled` | Enrollment evidence | Enrolled | Yes, if benefit used | Medium |
| Coupon Issued | System / Support / Manager | `coupon_issued` | Coupon evidence | Coupon available | Yes | Medium |
| Coupon Active | System | `coupon_active` | Coupon state evidence | Available | No, unless disputed | Low |
| Coupon Reserved | System | `coupon_reserved` | Reservation evidence | Applying coupon | Yes | High |
| Coupon Applied | Store Runtime | `coupon_applied_to_order` | Calculation evidence | Discount applied | Yes | High |
| Coupon Consumed | Store Runtime / Payment Boundary | `coupon_consumed` | Consumption evidence | Coupon used | Yes | High |
| Coupon Released | System | `coupon_released` | Release evidence | Coupon available again | Yes, if dispute | Medium |
| Coupon Restored | Support / System / Manager | `coupon_restored` | Restoration evidence | Coupon restored | Yes | High |
| Coupon Expired | System | `coupon_expired` | Expiration evidence | Expired | No, unless disputed | Low |
| Visit Count Earned | Store Runtime | `visit_count_earned` | Visit evidence | Visit counted | Yes | Medium |
| Visit Count Reversed | System / Support | `visit_count_reversed` | Reversal evidence | Adjusted | Yes | High |
| Compensation Benefit Issued | Manager / Support | `compensation_benefit_issued` | Compensation evidence | Compensation granted | Yes | High |
| Benefit Disputed | Customer / Support | `benefit_dispute_created` | Support evidence | Support checking | Yes | Medium |
| Benefit Financial Impact Created | Store Runtime / Finance | `benefit_financial_impact_created` | Finance evidence | Usually discount/refund status | Yes | High |

## 14. Support Case State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Support Case Created | Customer / Staff / System | `support_case_created` | Case evidence | Received | Yes | High |
| Case Classified | Support / System | `support_case_classified` | Classification evidence | Checking | Yes | Medium |
| Case Severity Assigned | Support / Manager | `support_case_severity_assigned` | Severity evidence | Usually hidden | Yes | High |
| Case Owner Assigned | Support Lead / System | `support_case_owner_assigned` | Owner evidence | Checking | Yes | High |
| Store Handoff Attached | Store Manager / Staff | `store_support_handoff_attached` | Handoff evidence | Checking with store | Yes | High |
| Finance Handoff Attached | Support / Finance | `support_finance_handoff_attached` | Finance handoff evidence | Payment review | Yes | Critical |
| Customer Response Needed | Support | `customer_response_needed` | Communication evidence | Need customer response | Yes | Medium |
| Resolution Proposed | Support / Manager | `support_resolution_proposed` | Resolution evidence | Resolution offered | Yes | Medium |
| Compensation Approved | Manager / Support | `support_compensation_approved` | Approval evidence | Compensation approved | Yes | High |
| Case Resolved | Support | `support_case_resolved` | Resolution evidence | Resolved | Yes | Medium |
| Case Rejected | Support / Manager | `support_case_rejected` | Rejection evidence | Rejected with reason | Yes | Medium |
| Case Reopened | Customer / Support | `support_case_reopened` | Reopen evidence | Reopened / checking | Yes | High |
| Case Carried Forward | Support / Manager | `support_case_carried_forward` | Carry-forward evidence | Follow-up pending | Yes | High |

## 15. Privacy And Consent State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Service Consent Captured | Customer / System | `service_consent_captured` | Consent evidence | Consent recorded | Yes, if disputed | Medium |
| Marketing Consent Captured | Customer / System | `marketing_consent_captured` | Consent evidence | Marketing allowed | No, unless dispute | Medium |
| Consent Withdrawn | Customer / System | `customer_consent_withdrawn` | Withdrawal evidence | Consent changed | Yes, if notification dispute | Medium |
| Customer Data Displayed | System Surface | `customer_data_displayed` | Display evidence | Scoped display | Yes, if sensitive | High |
| Staff Sensitive View | Staff | `staff_sensitive_customer_viewed` | Access evidence | Usually hidden | Yes, if sensitive | High |
| Manager Sensitive View | Manager | `manager_sensitive_customer_viewed` | Access evidence | Usually hidden | Yes | High |
| Support Evidence Access | Support | `support_customer_evidence_accessed` | Access evidence | Usually hidden | Yes | Medium |
| Finance Evidence Access | Finance | `finance_customer_evidence_accessed` | Access evidence | Usually hidden | Yes | Medium |
| Data Restricted | System / Compliance | `customer_data_restricted` | Restriction evidence | Restricted / unavailable | Yes | Medium |
| Data Expired | System | `customer_data_expired` | Expiration evidence | No longer visible | No, unless dispute | Low |
| Data Anonymized | Compliance / System | `customer_data_anonymized` | Anonymization evidence | Not identifiable | Yes, if support/audit | Medium |
| Privacy Incident Created | Customer / Staff / System | `privacy_incident_created` | Incident evidence | Support/privacy review | Yes | Critical |
| Privacy Incident Resolved | Privacy Owner | `privacy_incident_resolved` | Resolution evidence | Resolved / notified if needed | Yes | High |

## 16. Evidence Packet State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Evidence Packet Started | Evidence Owner / System | `customer_evidence_packet_started` | Packet metadata | Not customer-facing | Yes | Medium |
| Journey Evidence Linked | System / Evidence Owner | `customer_journey_evidence_linked` | Journey evidence | Not customer-facing | Yes | High |
| Waiting Evidence Linked | System / Evidence Owner | `waiting_evidence_linked` | Waiting packet | Not customer-facing | Yes | High |
| Table Evidence Linked | System / Evidence Owner | `table_evidence_linked` | Table packet | Not customer-facing | Yes | High |
| Payment Evidence Linked | Finance / System | `payment_evidence_linked` | Payment packet | Not customer-facing | Yes | Critical |
| Support Evidence Linked | Support / System | `support_evidence_linked` | Support packet | Not customer-facing | Yes | High |
| Privacy Evidence Linked | Privacy Owner / System | `privacy_evidence_linked` | Privacy packet | Not customer-facing | Yes | High |
| Evidence Gap Found | Evidence Owner / System | `customer_evidence_gap_found` | Gap record | Not customer-facing | Yes | High |
| Evidence Gap Accepted | Release / Evidence Owner | `customer_evidence_gap_accepted` | Waiver evidence | Not customer-facing | Yes | High |
| Evidence Packet Completed | Evidence Owner | `customer_evidence_packet_completed` | Completed packet | Not customer-facing | Yes | High |
| Evidence Packet Reopened | Evidence Owner / Audit | `customer_evidence_packet_reopened` | Reopen evidence | Not customer-facing | Yes | Medium |

## 17. Closeout And Rollout State Matrix

| State | Authority | Event | Evidence | Customer Display | Closeout Impact | Rollout Risk |
|---|---|---|---|---|---|---|
| Daily Customer Closeout Started | Store Manager / System | `daily_customer_closeout_started` | Closeout evidence | Not customer-facing | Yes | Medium |
| Closeout Exception Found | Store Manager / System | `customer_closeout_exception_found` | Exception evidence | Not customer-facing | Yes | High |
| Carry-Forward Owner Assigned | Manager / Support / Finance | `customer_carry_forward_owner_assigned` | Owner evidence | Follow-up pending if customer-facing | Yes | High |
| Clean Close Declared | Store Manager | `customer_clean_close_declared` | Approval evidence | Not customer-facing | Yes | High |
| Exception Close Declared | Store Manager | `customer_exception_close_declared` | Exception close evidence | Not customer-facing | Yes | High |
| Pilot Scope Approved | Release Owner | `customer_pilot_scope_approved` | Scope evidence | Not customer-facing | Pilot prerequisite | Medium |
| Pilot Started | Pilot Lead | `customer_runtime_pilot_started` | Pilot log | Not customer-facing | Yes | Medium |
| Pilot Paused | Release Owner / Pilot Lead | `customer_runtime_pilot_paused` | Pause evidence | Customer flow may show unavailable | Yes | High |
| Pilot Rolled Back | Release Owner | `customer_runtime_pilot_rolled_back` | Rollback evidence | Feature unavailable / staff assist | Yes | High |
| Pilot Closeout Completed | Pilot Lead / Evidence Owner | `customer_pilot_closeout_completed` | Closeout packet | Not customer-facing | Yes | High |
| Rollout Decision Recorded | Release Owner | `customer_rollout_decision_recorded` | Decision evidence | Not customer-facing | Rollout gate | High |
| Rollout Restricted | Release Owner | `customer_rollout_restricted` | Restriction evidence | Feature/channel limited | Rollout gate | High |
| Rollout Approved | Release Owner | `customer_rollout_approved` | Approval evidence | Feature available | Rollout gate | High |

## 18. Authority Coverage Summary

| Authority | May Create | May Change | May Approve | Must Not Do |
|---|---|---|---|---|
| Customer | Guest/session actions, cart, arrival, support claim, consent | Own scoped actions | Consent/claim confirmation | Cannot confirm order/payment/store truth alone |
| Store Runtime | Waiting/table/order status transitions | Runtime state | System-confirmed runtime transitions | Cannot override payment provider truth |
| Staff | Waiting assist, call, arrival help, correction request, support intake | Staff-authorized operational corrections | Limited service recovery if allowed | Cannot freely adjust payment, coupon, or privacy-sensitive state |
| Store Manager | No-show reversal, table exception, compensation approval, closeout | Sensitive store corrections | Manager override and closeout | Cannot hide evidence or close financial uncertainty without owner |
| POS Gateway / Payment Boundary | Payment/order status handoff | Payment-derived states | Payment-related truth where authoritative | Cannot rely on customer-visible app state alone |
| Support | Case classification, customer communication, support resolution | Support case state | Support resolution / compensation if authorized | Cannot alter runtime/payment truth without evidence |
| Finance | Refund/cancel/reconciliation review | Finance exception state | Finance resolution | Cannot use broad customer profile unnecessarily |
| Privacy/Compliance | Privacy incident, data restriction, access review | Privacy-sensitive state | Privacy resolution | Cannot erase required audit evidence casually |
| Release Owner | Pilot scope, pause, rollback, rollout decision | Release state | Rollout approval/restriction | Cannot pass rollout with unresolved critical blockers |
| Evidence Owner | Evidence packet, gap record, closeout packet | Evidence packet state | Evidence completeness judgment | Cannot rewrite evidence without trace |

## 19. Evidence Coverage Checklist

Every state in this matrix must have:

- Event name
- Actor or source
- Timestamp
- State before
- State after
- Related reference IDs
- Customer-facing status, if any
- Evidence family
- Access role
- Closeout impact
- Risk severity if missing

Missing evidence for high-risk states must route to:

`005014_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 20. Implementation Follow-Up

This matrix should later be converted into:

- Event name registry
- State machine specification
- Customer runtime audit schema
- Evidence packet field specification
- Role authority matrix
- UI status wording registry
- Customer notification template map
- Support case field map
- Privacy access log map
- Closeout checklist automation
- Pilot evidence validation automation

## 21. Acceptance Criteria

This matrix is accepted when:

- Entrance states are mapped
- Waiting states are mapped
- Table states are mapped
- Link/token states are mapped
- Web app states are mapped
- Native app continuity states are mapped
- Identity states are mapped
- Membership and benefit states are mapped
- Support case states are mapped
- Privacy and consent states are mapped
- Evidence packet states are mapped
- Closeout and rollout states are mapped
- Authority coverage summary is defined
- Evidence coverage checklist is defined
- Implementation follow-up targets are identified

## 22. Related Documents

Related document families include:

- Customer Runtime lane index
- Customer Runtime pilot readiness policy
- Customer runtime evidence packet policy
- Customer privacy consent data retention policy
- Customer support case policy
- Membership loyalty coupon benefit policy
- Customer account and guest merge policy
- Customer web app runtime policy
- Customer link token and QR/NFC security policy
- Customer notification and multilingual guidance policy
- Table matching policy
- Waiting queue policy
- Runtime evidence policy
- State machine specification
- Event audit schema
- Role authority matrix

## 23. Final Rule

A state without authority, event, evidence, visibility, and closeout behavior is not ready for implementation.

This matrix is the bridge between Customer Runtime policy and executable system design.