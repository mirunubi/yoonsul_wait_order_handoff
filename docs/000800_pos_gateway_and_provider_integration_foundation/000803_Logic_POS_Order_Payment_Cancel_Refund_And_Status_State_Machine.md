# 000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md

## 1. Purpose

Defines order, payment, cancel, refund, and status state machine for POS Gateway.

## 2. Core Rule

Payment success and order success must not be treated as the same event.

## 3. States

| State | Description |
| --- | --- |
| `request_created` | Order request initiated |
| `store_accepted` | Store accepted into internal flow |
| `payment_pending` | Payment not yet authorized |
| `payment_authorized` | Payment authorized; POS may still fail |
| `pos_order_pending` | POS submission in progress |
| `pos_order_confirmed` | POS confirmed order |
| `kds_display_pending` | Kitchen ticket pending |
| `kds_displayed` | Kitchen ticket displayed |
| `preparing` | Kitchen preparing |
| `ready` | Ready for pickup/service |
| `completed` | Fulfilled and closed |
| `cancel_requested` | Cancel initiated |
| `cancel_confirmed` | Cancel confirmed all required surfaces |
| `refund_requested` | Refund initiated |
| `refund_confirmed` | Refund confirmed with evidence |
| `failed` | Terminal failure |
| `unknown` | State uncertain |
| `recovery_required` | Automated path stopped |
| `manual_review_required` | Human decision required |

## 4. Separate Success Events

| Event | Meaning |
| --- | --- |
| Order request success | Internal request recorded |
| Payment authorization success | Payment layer authorized |
| POS transmission success | Provider accepted order |
| KDS display success | Kitchen received ticket |
| DID callout success | Customer notified for pickup |
| Cancellation success | Cancel reflected where required |
| Refund success | Refund confirmed with evidence |

## 5. Transition Principles

- No customer finality without evidence for required events.
- Timeout → `unknown` or `recovery_required`, not assumed success.
- Cancel/refund may require human approval per policy.
- Gateway owns transitions; adapter reports provider facts.

## 6. Final Rule

One state machine, many surfaces; never collapse payment and order into one flag.
