# 000909_Runbook_POS_Integration_Failure_Recovery_Reconciliation_And_Manual_Operation.md

## 1. Purpose

Failure recovery, reconciliation, and manual operation runbook for POS integration incidents.

## 2. Scenario Format

Each scenario includes: symptom, likely cause, immediate action, manual operation path, recovery step, reconciliation step, evidence required, escalation condition.

---

### Payment success but POS order failed

| Step | Action |
| --- | --- |
| Symptom | Payment authorized; POS has no order |
| Likely cause | Timeout, provider reject, mapping error |
| Immediate action | Stop customer finality; do not retry payment |
| Manual operation | Staff confirms payment state; manual POS entry if policy allows |
| Recovery | `recoverTransaction`; resubmit with idempotency or void payment per policy |
| Reconciliation | Match payment ledger to POS order ID |
| Evidence | `000558` packet with both payment and POS refs |
| Escalation | Customer charged without kitchen ticket after recovery attempt |

---

### POS order success but KDS display failed

| Step | Action |
| --- | --- |
| Symptom | POS confirmed; kitchen has no ticket |
| Likely cause | KDS sync failure, network, mapping |
| Immediate action | Kitchen print or manual ticket |
| Manual operation | Staff kitchen handoff |
| Recovery | Replay KDS projection; verify state |
| Reconciliation | POS order ID ↔ KDS ticket ID |
| Evidence | Required |
| Escalation | Repeated KDS failure in same store |

---

### Kiosk order duplicated

| Step | Action |
| --- | --- |
| Symptom | Two orders same basket/time |
| Likely cause | Retry without idempotency, double tap |
| Immediate action | Pause auto-retry; flag duplicates |
| Manual operation | Cancel duplicate per policy |
| Recovery | Reconcile idempotency keys |
| Reconciliation | Duplicate detection report |
| Evidence | Both order IDs and keys |
| Escalation | Payment on duplicate order |

---

### Payment duplicated

| Step | Action |
| --- | --- |
| Symptom | Two charges same order |
| Likely cause | Retry on timeout |
| Immediate action | Stop further payment attempts |
| Manual operation | Refund path with human approval |
| Recovery | `reconcileTransactions` |
| Reconciliation | Payment ledger vs provider |
| Evidence | Required |
| Escalation | Any unresolved duplicate charge |

---

### POS timeout

| Step | Action |
| --- | --- |
| Symptom | No response within SLA |
| Likely cause | Provider latency, network |
| Immediate action | Mark `unknown`; no success assumption |
| Manual operation | Hold customer finality |
| Recovery | Poll `getOrderStatus` / `getPaymentStatus` |
| Reconciliation | Post-recovery match |
| Evidence | Timeout logs |
| Escalation | Unknown > N minutes |

---

### Provider unavailable

| Step | Action |
| --- | --- |
| Symptom | healthCheck fails |
| Likely cause | Outage, credential, maintenance |
| Immediate action | Degraded mode per Phase 4 SOP if applicable |
| Manual operation | Direct POS or manual order |
| Recovery | Retry when healthCheck passes |
| Reconciliation | Backlog of pending items |
| Evidence | Outage window log |
| Escalation | Extended outage |

---

### Refund unknown

| Step | Action |
| --- | --- |
| Symptom | Refund initiated; status unclear |
| Likely cause | Timeout, partial provider response |
| Immediate action | `manual_review_required` |
| Manual operation | Finance/staff verification |
| Recovery | `recoverTransaction` |
| Reconciliation | Refund ledger vs provider |
| Evidence | Required |
| Escalation | Customer dispute |

---

### Cancel failed

| Step | Action |
| --- | --- |
| Symptom | Cancel rejected or unknown |
| Likely cause | Order state on POS, timing |
| Immediate action | Do not assume cancel |
| Manual operation | Staff POS cancel |
| Recovery | Retry cancel with idempotency |
| Reconciliation | All surfaces reflect cancel |
| Evidence | Required |
| Escalation | Kitchen already preparing |

---

### Menu sync mismatch

| Step | Action |
| --- | --- |
| Symptom | CMS/POS/Kiosk menu differ |
| Likely cause | Failed sync, partial deploy |
| Immediate action | Identify source of truth per policy |
| Manual operation | Disable affected items |
| Recovery | `syncMenu` rollback or redeploy |
| Reconciliation | Version compare |
| Evidence | Menu version IDs |
| Escalation | Customer orders wrong price |

---

### Sold-out sync mismatch

| Step | Action |
| --- | --- |
| Symptom | Available on kiosk, sold out on POS |
| Likely cause | syncAvailability failure |
| Immediate action | Block item on customer surfaces |
| Manual operation | Staff override sold-out |
| Recovery | Force availability sync |
| Reconciliation | Item-level state |
| Evidence | Required |
| Escalation | Order accepted for unavailable item |

---

### Internet failure

| Step | Action |
| --- | --- |
| Symptom | External APIs down; local may work |
| Likely cause | ISP, router |
| Immediate action | Resource judgment: what still works |
| Manual operation | Local POS/KDS path |
| Recovery | Resync when online |
| Reconciliation | Missing orders during outage |
| Evidence | Outage log |
| Escalation | Cannot track orders safely |

---

### Local fallback

| Step | Action |
| --- | --- |
| Symptom | Cloud path down; local server alive |
| Likely cause | Cloud outage |
| Immediate action | Limited operation mode |
| Manual operation | Per limited-operation SOP |
| Recovery | Resync to cloud |
| Reconciliation | Gap period transactions |
| Evidence | Required |
| Escalation | Safe closure criteria met |

---

### Manual order recovery

| Step | Action |
| --- | --- |
| Symptom | Orders taken manually during failure |
| Likely cause | Degraded operation |
| Immediate action | Record manual orders |
| Manual operation | Enter into system of record |
| Recovery | Backfill orders/payments |
| Reconciliation | No lost or duplicate |
| Evidence | Staff action log |
| Escalation | Cannot backfill |

---

### Reconciliation after recovery

| Step | Action |
| --- | --- |
| Symptom | Post-incident review |
| Likely cause | Prior failure window |
| Immediate action | Run `reconcileTransactions` |
| Manual operation | Review unmatched list |
| Recovery | Close or escalate each item |
| Reconciliation | Sign-off report |
| Evidence | Summary packet |
| Escalation | Unmatched financial items |

## 3. Final Rule

Never claim recovery complete without reconciliation and evidence.
