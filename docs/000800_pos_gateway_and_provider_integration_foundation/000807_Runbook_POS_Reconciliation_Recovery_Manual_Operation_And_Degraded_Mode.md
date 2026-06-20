# 000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md

## 1. Purpose

Reconciliation, recovery, manual operation, and degraded mode runbook for POS Gateway operations.

## 2. Scenario Template

Each scenario: symptom, likely cause, immediate action, manual operation path, recovery step, reconciliation step, evidence required, escalation condition.

---

### Payment success but POS order failed

| Field | Detail |
| --- | --- |
| Symptom | Payment authorized; no POS order |
| Likely cause | Timeout, provider reject, mapping error |
| Immediate action | Block customer finality; do not re-authorize payment |
| Manual operation | Staff verify payment; manual POS entry if policy allows |
| Recovery | `recoverTransaction`; void or resubmit per policy |
| Reconciliation | Payment ledger ↔ POS order ID |
| Evidence | `000808` with both IDs |
| Escalation | Customer charged without kitchen ticket |

---

### POS order success but KDS display failed

| Field | Detail |
| --- | --- |
| Symptom | POS confirmed; no KDS ticket |
| Likely cause | KDS sync failure |
| Immediate action | Kitchen print / manual ticket |
| Manual operation | Staff kitchen handoff |
| Recovery | Replay KDS projection |
| Reconciliation | POS order ID ↔ KDS ticket |
| Evidence | Required |
| Escalation | Repeated KDS failure |

---

### Kiosk order duplicated

| Field | Detail |
| --- | --- |
| Symptom | Two orders same basket |
| Likely cause | Retry without idempotency |
| Immediate action | Stop auto-retry |
| Manual operation | Cancel duplicate per policy |
| Recovery | Idempotency audit |
| Reconciliation | Duplicate report |
| Evidence | Both order IDs and keys |
| Escalation | Double payment |

---

### Payment duplicated

| Field | Detail |
| --- | --- |
| Symptom | Two charges same order |
| Likely cause | Timeout retry with new key |
| Immediate action | Stop payment attempts |
| Manual operation | Refund with human approval |
| Recovery | `reconcileTransactions` |
| Reconciliation | Payment ledger vs provider |
| Evidence | Required |
| Escalation | Unresolved duplicate charge |

---

### POS timeout

| Field | Detail |
| --- | --- |
| Symptom | No response within SLA |
| Likely cause | Provider latency |
| Immediate action | Mark unknown |
| Manual operation | Hold finality |
| Recovery | Status poll |
| Reconciliation | Post-recovery match |
| Evidence | Timeout logs |
| Escalation | Unknown > threshold |

---

### Provider unavailable

| Field | Detail |
| --- | --- |
| Symptom | healthCheck fails |
| Likely cause | Outage |
| Immediate action | Degraded mode |
| Manual operation | Direct POS / manual order |
| Recovery | Retry when healthy |
| Reconciliation | Backlog items |
| Evidence | Outage window |
| Escalation | Extended outage |

---

### Refund unknown

| Field | Detail |
| --- | --- |
| Symptom | Refund status unclear |
| Likely cause | Timeout |
| Immediate action | `manual_review_required` |
| Manual operation | Finance verification |
| Recovery | `recoverTransaction` |
| Reconciliation | Refund ledger |
| Evidence | Required |
| Escalation | Customer dispute |

---

### Cancel failed

| Field | Detail |
| --- | --- |
| Symptom | Cancel rejected or unknown |
| Likely cause | POS state conflict |
| Immediate action | Do not assume cancelled |
| Manual operation | Staff POS cancel |
| Recovery | Idempotent cancel retry |
| Reconciliation | All surfaces |
| Evidence | Required |
| Escalation | Kitchen already preparing |

---

### Menu sync mismatch

| Field | Detail |
| --- | --- |
| Symptom | CMS/POS/Kiosk differ |
| Likely cause | Partial sync |
| Immediate action | Identify source of truth |
| Manual operation | Disable affected items |
| Recovery | syncMenu rollback/redeploy |
| Reconciliation | Version compare |
| Evidence | Menu version IDs |
| Escalation | Wrong price ordered |

---

### Sold-out sync mismatch

| Field | Detail |
| --- | --- |
| Symptom | Available on kiosk, sold out on POS |
| Likely cause | syncAvailability failure |
| Immediate action | Block item on customer surfaces |
| Manual operation | Staff override |
| Recovery | Force sync |
| Reconciliation | Item-level state |
| Evidence | Required |
| Escalation | Order for unavailable item |

---

### Internet failure

| Field | Detail |
| --- | --- |
| Symptom | External APIs down |
| Likely cause | ISP/network |
| Immediate action | Resource judgment |
| Manual operation | Local POS/KDS path |
| Recovery | Resync when online |
| Reconciliation | Gap period orders |
| Evidence | Outage log |
| Escalation | Cannot track safely |

---

### Local fallback

| Field | Detail |
| --- | --- |
| Symptom | Cloud down; local alive |
| Likely cause | Cloud outage |
| Immediate action | Limited operation |
| Manual operation | Per degraded SOP |
| Recovery | Cloud resync |
| Reconciliation | Gap transactions |
| Evidence | Required |
| Escalation | Safe closure criteria |

---

### Manual order recovery

| Field | Detail |
| --- | --- |
| Symptom | Manual orders during failure |
| Likely cause | Degraded operation |
| Immediate action | Record manual orders |
| Manual operation | Backfill system of record |
| Recovery | Reconcile duplicates/loss |
| Reconciliation | Sign-off |
| Evidence | Staff log |
| Escalation | Cannot backfill |

---

### Reconciliation after recovery

| Field | Detail |
| --- | --- |
| Symptom | Post-incident review |
| Likely cause | Prior failure window |
| Immediate action | Run reconcileTransactions |
| Manual operation | Review unmatched |
| Recovery | Close each item |
| Reconciliation | Sign-off report |
| Evidence | Summary packet |
| Escalation | Unmatched financial items |

## 3. Final Rule

Recovery is incomplete without reconciliation and evidence.
