# 000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md

## 1. Purpose

Provider capability, readiness, and support status matrix for internal POS Gateway planning.

## 2. Support Status Values

| Status | Meaning |
| --- | --- |
| Official | Production-supported with evidence |
| Candidate | Integration in progress |
| Limited | Partial capability documented |
| Research | Investigation only |
| Unsupported | No integration |
| Human Review | Pending decision |

## 3. Matrix

| provider name | official API availability | sandbox availability | order create | order update | order cancel | payment authorization | payment cancel | refund | receipt ID | menu sync | price sync | option sync | sold-out sync | webhook | polling | local integration requirement | cloud integration availability | authentication method | rate limit | retry behavior | idempotency support | reconciliation support | evidence availability | known limitation | support status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| OKPOS | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Candidate |
| Toss POS | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Candidate |
| Other major POS providers TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Research |

## 4. Update Rules

- Evidence required for status promotion (`000808`).
- **Official** requires human review and test guide completion (`000810`).
- `000900` vendor packages reference this matrix; do not fork a conflicting matrix in `000900`.

## 5. Final Rule

Support status follows evidence, not integration enthusiasm.
