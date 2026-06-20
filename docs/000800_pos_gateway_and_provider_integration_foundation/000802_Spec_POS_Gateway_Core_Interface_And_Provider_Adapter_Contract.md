# 000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md

## 1. Purpose

Defines the POS Gateway core interface and provider adapter contract.

This document is an interface specification only.
It is not implementation code.

## 2. Global Rules

| Rule | Requirement |
| --- | --- |
| Idempotency | Mutating methods require `idempotencyKey` |
| Timeout | Return `unknownState` on timeout; never assume success/failure |
| Retry | Gateway owns policy; adapter must be idempotent |
| Evidence | Every mutating call produces `evidenceRef` |
| Manual recovery | `unknownState` sets `recoveryRequired` |

## 3. Methods

### healthCheck

| Aspect | Contract |
| --- | --- |
| Purpose | Verify provider connectivity |
| Input | `providerId`, `storeId`, `environment` |
| Output | `status`, `latencyMs`, `providerVersion`, `evidenceRef` |
| Required identifiers | `storeId` |
| Idempotency | Not required |
| Timeout | Fail soft to degraded |
| Retry | Optional once |
| Error behavior | Non-throwing status |
| Evidence | Required |
| Manual recovery | N/A |

### createOrder

| Aspect | Contract |
| --- | --- |
| Purpose | Submit order to provider |
| Input | `idempotencyKey`, `storeId`, `orderPayload`, `paymentRef` |
| Output | `posOrderId`, `status`, `providerReceiptId`, `evidenceRef` |
| Required identifiers | `internalOrderId`, `idempotencyKey` |
| Idempotency | **Required** |
| Timeout | → `unknownState` |
| Retry | Idempotent only |
| Error behavior | `retryable`, `duplicate`, `unknownState` |
| Evidence | **Required** |
| Manual recovery | On unknown |

### updateOrder

| Aspect | Contract |
| --- | --- |
| Purpose | Update order on provider |
| Input | `idempotencyKey`, `posOrderId`, `updatePayload` |
| Output | `posOrderId`, `status`, `evidenceRef` |
| Required identifiers | `internalOrderId`, `posOrderId`, `idempotencyKey` |
| Idempotency | **Required** |
| Timeout | → unknown partial update flag |
| Retry | Idempotent |
| Error behavior | Conflict mapping |
| Evidence | Required |
| Manual recovery | On partial uncertainty |

### cancelOrder

| Aspect | Contract |
| --- | --- |
| Purpose | Cancel order on provider |
| Input | `idempotencyKey`, `posOrderId`, `cancelReason` |
| Output | `cancelStatus`, `evidenceRef` |
| Required identifiers | `posOrderId`, `idempotencyKey` |
| Idempotency | **Required** |
| Timeout | → unknown cancel state |
| Retry | Careful idempotent |
| Error behavior | already-cancelled vs failed vs unknown |
| Evidence | Required |
| Manual recovery | Required on unknown |

### authorizePayment

| Aspect | Contract |
| --- | --- |
| Purpose | Authorize payment via provider path |
| Input | `idempotencyKey`, `amount`, `paymentMethod`, `orderRef` |
| Output | `paymentId`, `authorizationStatus`, `evidenceRef` |
| Required identifiers | `internalOrderId`, `idempotencyKey` |
| Idempotency | **Required** |
| Timeout | → unknown; no double charge |
| Retry | Strict idempotent |
| Error behavior | Separate from order success |
| Evidence | **Required** |
| Manual recovery | On timeout |

### cancelPayment

| Aspect | Contract |
| --- | --- |
| Purpose | Void authorized payment |
| Input | `idempotencyKey`, `paymentId` |
| Output | `cancelStatus`, `evidenceRef` |
| Required identifiers | `paymentId`, `idempotencyKey` |
| Idempotency | **Required** |
| Timeout | unknown |
| Retry | Idempotent |
| Error behavior | Normalized |
| Evidence | Required |
| Manual recovery | Required |

### refundPayment

| Aspect | Contract |
| --- | --- |
| Purpose | Refund captured payment |
| Input | `idempotencyKey`, `paymentId`, `amount`, `reason` |
| Output | `refundId`, `refundStatus`, `evidenceRef` |
| Required identifiers | `paymentId`, `idempotencyKey` |
| Idempotency | **Required** |
| Timeout | unknown |
| Retry | No duplicate refund |
| Error behavior | Policy exceptions → human path |
| Evidence | **Required** |
| Manual recovery | **Required** |

### getOrderStatus

| Aspect | Contract |
| --- | --- |
| Purpose | Poll order status |
| Input | `posOrderId`, `internalOrderId` |
| Output | `normalizedStatus`, `providerRawStatus`, `evidenceRef` |
| Required identifiers | At least one order ID |
| Idempotency | N/A |
| Timeout | Retry read |
| Retry | Limited |
| Error behavior | Return unknown not guess |
| Evidence | On change |
| Manual recovery | When indeterminate |

### getPaymentStatus

| Aspect | Contract |
| --- | --- |
| Purpose | Poll payment status |
| Input | `paymentId` |
| Output | `normalizedPaymentStatus`, `evidenceRef` |
| Required identifiers | `paymentId` |
| Idempotency | N/A |
| Timeout | Retry read |
| Retry | Limited |
| Error behavior | not-found vs unknown |
| Evidence | Required |
| Manual recovery | On ledger mismatch |

### syncMenu

| Aspect | Contract |
| --- | --- |
| Purpose | Menu sync with provider |
| Input | `storeId`, `menuVersion`, `menuPayload` |
| Output | `syncStatus`, `providerMenuVersion`, `evidenceRef` |
| Required identifiers | `storeId`, `menuVersion` |
| Idempotency | Recommended |
| Timeout | Partial sync report |
| Retry | Version-aware |
| Error behavior | Per-section failures |
| Evidence | Required |
| Manual recovery | CMS/POS mismatch |

### syncAvailability

| Aspect | Contract |
| --- | --- |
| Purpose | Sold-out / availability sync |
| Input | `storeId`, `itemAvailability[]` |
| Output | `syncStatus`, `evidenceRef` |
| Required identifiers | `storeId` |
| Idempotency | Recommended |
| Timeout | Item-level result |
| Retry | Same version |
| Error behavior | Partial failures |
| Evidence | Required |
| Manual recovery | Divergence |

### recoverTransaction

| Aspect | Contract |
| --- | --- |
| Purpose | Recover stuck/unknown transaction |
| Input | `internalOrderId`, `paymentId`, `recoveryContext` |
| Output | `recoveredState`, `actionsTaken`, `evidenceRef` |
| Required identifiers | Order and/or payment ID |
| Idempotency | **Required** |
| Timeout | Single controlled attempt |
| Retry | One recovery cycle per approval |
| Error behavior | No auto-refund without policy |
| Evidence | **Required** |
| Manual recovery | Core function |

### reconcileTransactions

| Aspect | Contract |
| --- | --- |
| Purpose | Match provider vs internal for period |
| Input | `storeId`, `fromTime`, `toTime` |
| Output | `matched`, `missing`, `duplicate`, `mismatch[]`, `evidenceRef` |
| Required identifiers | `storeId`, time range |
| Idempotency | N/A |
| Timeout | Partial batch result |
| Retry | Batch retry |
| Error behavior | Flag incomplete |
| Evidence | **Required** |
| Manual recovery | Escalate unmatched |

## 4. Final Rule

All adapters implement this contract; gateway owns orchestration and authority.
