# 000904_Spec_POS_Adapter_Interface_Order_Payment_Cancel_Refund_And_Status_Contract.md

## 1. Purpose

This document defines the **common POS Adapter Interface contract**. It is an interface specification, **not** implementation code.

All provider adapters (OKPOS, Toss POS, others) must implement this contract at the adapter boundary.

## 2. Global Contract Rules

| Rule | Requirement |
| --- | --- |
| Idempotency | Every mutating call accepts `idempotencyKey` |
| Evidence | Every mutating call returns `evidenceRef` or logs to evidence pipeline |
| Errors | Normalized `AdapterError` with `retryable`, `unknownState`, `providerCode` |
| Retry | Document max retries; gateway owns retry policy |
| Manual recovery | `unknownState` must expose `recoveryRequired` flag |

## 3. Method Specifications

### healthCheck

| Field | Contract |
| --- | --- |
| Purpose | Verify provider connectivity and credentials |
| Input | `providerId`, `storeId`, `environment` |
| Output | `status`, `latencyMs`, `providerVersion`, `evidenceRef` |
| Required IDs | `storeId` |
| Error behavior | Non-throwing; return degraded status |
| Retry | Optional single retry |
| Idempotency | Not required |
| Evidence | Required |
| Manual recovery | N/A |

### createOrder

| Field | Contract |
| --- | --- |
| Purpose | Submit order to POS provider |
| Input | `idempotencyKey`, `storeId`, `orderPayload`, `paymentRef` |
| Output | `posOrderId`, `status`, `providerReceiptId`, `evidenceRef` |
| Required IDs | `internalOrderId`, `idempotencyKey` |
| Error behavior | Distinguish `retryable`, `duplicate`, `unknownState` |
| Retry | Gateway-controlled; adapter must be idempotent |
| Idempotency | **Required** |
| Evidence | **Required** |
| Manual recovery | On `unknownState`, flag `recoveryRequired` |

### updateOrder

| Field | Contract |
| --- | --- |
| Purpose | Update order items, options, or notes on POS |
| Input | `idempotencyKey`, `posOrderId`, `updatePayload` |
| Output | `posOrderId`, `status`, `evidenceRef` |
| Required IDs | `internalOrderId`, `posOrderId`, `idempotencyKey` |
| Error behavior | Map provider conflicts to normalized errors |
| Retry | Idempotent retry allowed |
| Idempotency | **Required** |
| Evidence | **Required** |
| Manual recovery | Required on partial update uncertainty |

### cancelOrder

| Field | Contract |
| --- | --- |
| Purpose | Request order cancellation on POS |
| Input | `idempotencyKey`, `posOrderId`, `cancelReason` |
| Output | `cancelStatus`, `posOrderId`, `evidenceRef` |
| Required IDs | `internalOrderId`, `posOrderId`, `idempotencyKey` |
| Error behavior | Distinguish already-cancelled vs failed vs unknown |
| Retry | Careful; duplicate cancel must not double-refund |
| Idempotency | **Required** |
| Evidence | **Required** |
| Manual recovery | Required when cancel state unknown |

### authorizePayment

| Field | Contract |
| --- | --- |
| Purpose | Authorize or initiate payment via provider path |
| Input | `idempotencyKey`, `amount`, `paymentMethod`, `orderRef` |
| Output | `paymentId`, `authorizationStatus`, `evidenceRef` |
| Required IDs | `internalOrderId`, `idempotencyKey` |
| Error behavior | Never conflate with order success |
| Retry | Strict idempotency; financial duplicate prevention |
| Idempotency | **Required** |
| Evidence | **Required** |
| Manual recovery | Required on timeout |

### cancelPayment

| Field | Contract |
| --- | --- |
| Purpose | Void or cancel authorized payment |
| Input | `idempotencyKey`, `paymentId` |
| Output | `cancelStatus`, `evidenceRef` |
| Required IDs | `paymentId`, `idempotencyKey` |
| Error behavior | Map unknown to `recoveryRequired` |
| Retry | Idempotent only |
| Idempotency | **Required** |
| Evidence | **Required** |
| Manual recovery | Required |

### refundPayment

| Field | Contract |
| --- | --- |
| Purpose | Refund captured or settled payment |
| Input | `idempotencyKey`, `paymentId`, `amount`, `reason` |
| Output | `refundId`, `refundStatus`, `evidenceRef` |
| Required IDs | `paymentId`, `idempotencyKey` |
| Error behavior | Human approval path for policy exceptions |
| Retry | Idempotent; no duplicate refund |
| Idempotency | **Required** |
| Evidence | **Required** |
| Manual recovery | **Required** |

### getOrderStatus

| Field | Contract |
| --- | --- |
| Purpose | Poll normalized order status from provider |
| Input | `posOrderId`, `internalOrderId` |
| Output | `normalizedStatus`, `providerRawStatus`, `evidenceRef` |
| Required IDs | `posOrderId` or `internalOrderId` |
| Error behavior | Return `unknown` rather than guess |
| Retry | Read retry allowed |
| Idempotency | Not required |
| Evidence | Required on state change detection |
| Manual recovery | When status cannot be determined |

### getPaymentStatus

| Field | Contract |
| --- | --- |
| Purpose | Poll payment status from provider |
| Input | `paymentId` |
| Output | `normalizedPaymentStatus`, `evidenceRef` |
| Required IDs | `paymentId` |
| Error behavior | Distinguish not-found vs unknown |
| Retry | Read retry allowed |
| Idempotency | Not required |
| Evidence | Required |
| Manual recovery | On mismatch with internal ledger |

### syncMenu

| Field | Contract |
| --- | --- |
| Purpose | Pull or push menu structure to provider |
| Input | `storeId`, `menuVersion`, `menuPayload` |
| Output | `syncStatus`, `providerMenuVersion`, `evidenceRef` |
| Required IDs | `storeId`, `menuVersion` |
| Error behavior | Partial sync must be reported |
| Retry | Version-aware retry |
| Idempotency | Recommended |
| Evidence | Required |
| Manual recovery | On CMS/POS mismatch |

### syncAvailability

| Field | Contract |
| --- | --- |
| Purpose | Sync sold-out / availability |
| Input | `storeId`, `itemAvailability[]` |
| Output | `syncStatus`, `evidenceRef` |
| Required IDs | `storeId` |
| Error behavior | Report per-item failures |
| Retry | Allowed with same version |
| Idempotency | Recommended |
| Evidence | Required |
| Manual recovery | When sold-out state diverges |

### recoverTransaction

| Field | Contract |
| --- | --- |
| Purpose | Recover unknown or stuck transaction |
| Input | `internalOrderId`, `paymentId`, `recoveryContext` |
| Output | `recoveredState`, `actionsTaken`, `evidenceRef` |
| Required IDs | At least one of order/payment ID |
| Error behavior | Never auto-finalize refund without policy |
| Retry | Single controlled attempt |
| Idempotency | Required |
| Evidence | **Required** |
| Manual recovery | **Core purpose of method** |

### reconcileTransactions

| Field | Contract |
| --- | --- |
| Purpose | Compare provider records with internal ledger for period |
| Input | `storeId`, `fromTime`, `toTime` |
| Output | `matched`, `missing`, `duplicate`, `mismatch[]`, `evidenceRef` |
| Required IDs | `storeId`, time range |
| Error behavior | Return partial results with flags |
| Retry | Batch retry allowed |
| Idempotency | Not required |
| Evidence | **Required** |
| Manual recovery | Escalate unmatched items |

## 4. Final Rule

Adapters implement this contract only.
Business state machine and source of truth remain outside the adapter.
