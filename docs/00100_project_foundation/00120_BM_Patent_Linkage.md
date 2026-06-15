# 00120_BM_Patent_Linkage

## Patent-Idea Link

The MVP supports the BM patent idea by implementing the business process where a waiting customer prepares an order before being seated, and that prepared order is linked to the seating/table handoff.

The core protected concept to preserve in the MVP narrative:

```text
waiting state + menu/order preparation + table assignment + staff handoff
```

## Business Method Flow

1. A customer enters a store-specific digital context through QR, NFC, or URL.
2. The customer creates or joins a waiting session.
3. The customer browses menu information while waiting.
4. The customer configures menu items and options.
5. The customer submits an order candidate before seating.
6. Store staff assigns the customer to a table.
7. The order candidate is matched to the table assignment.
8. Staff confirms the order candidate and proceeds with existing store operations.

## MVP Claims Support

The MVP should generate evidence for these business-method points:

- Order intent can be captured before seating.
- Menu browsing time can overlap with waiting time.
- A waiting session can be linked to a cart and order candidate.
- Seating/table assignment can trigger staff review.
- Staff confirmation creates a clean handoff point before POS entry.
- The same flow can operate as a Mini Kiosk when waiting management is unnecessary.

## What the MVP Should Demonstrate

- Customer-side order preparation during waiting
- Persistent linkage between waiting session and order candidate
- Staff-side table assignment and review
- Confirmation workflow that does not require POS integration
- Lightweight reusable store menu interface

## What the MVP Should Not Claim Yet

- Automated POS completion
- Automated payment completion
- Kitchen routing or production optimization
- Inventory optimization
- AI-based recommendation or personalization
- Full franchise operating platform

## Evidence to Capture During Testing

- Time from seating to staff-confirmed order
- Percentage of waiting sessions with submitted order candidates
- Percentage of order candidates confirmed without customer edits
- Common staff edit reasons
- Customer completion rate from menu view to submitted candidate
- Mini Kiosk usage without waiting session
