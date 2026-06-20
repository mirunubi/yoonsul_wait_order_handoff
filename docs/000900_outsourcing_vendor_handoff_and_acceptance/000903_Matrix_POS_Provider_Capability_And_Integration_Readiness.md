# 000903_Matrix_POS_Provider_Capability_And_Integration_Readiness.md

## 1. Purpose

This matrix records POS provider capability and integration readiness for outsourcing and internal review.

## 2. Support Status Values

| Status | Meaning |
| --- | --- |
| Official | Production-supported with evidence and support readiness |
| Candidate | Integration in progress; not production-claimed |
| Limited | Partial capability; explicit limitations documented |
| Research | Investigation only |
| Unsupported | No integration planned |
| Human Review | Requires human decision before status change |

## 3. Capability Matrix

| provider name | official API availability | sandbox availability | order create | order update | order cancel | payment authorization | payment cancel | refund | receipt ID | menu sync | price sync | option sync | sold-out sync | webhook | polling | local integration requirement | cloud integration availability | authentication method | rate limit | retry behavior | idempotency support | reconciliation support | evidence availability | known limitation | support status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| OKPOS | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Candidate |
| Toss POS | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Candidate |
| Other major POS providers TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Research |

## 4. Update Rules

- Vendor fills cells with evidence references (`000558`).
- Internal team approves support status changes.
- No row may be marked **Official** without test report and human review.
- Phase 1 OKPOS/Toss foundation must be reflected before broad provider claims.

## 5. Final Rule

Capability matrix drives outsourcing scope—not marketing claims.
