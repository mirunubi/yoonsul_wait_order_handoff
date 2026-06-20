# 000810_Guide_POS_Integration_Test_Sandbox_Mock_And_Field_Verification_Context.md

## 1. Purpose

POS integration test, sandbox, mock, and field verification context.

## 2. Sandbox Testing

- Use provider sandbox per `000804` matrix.
- OKPOS and Toss POS first (Phase 1 alignment).
- Every test case produces `000808` evidence.
- No production credentials in developer environments without vault policy.

## 3. Mock Provider Testing

- Mock adapter implements full `000802` contract.
- Simulate timeout, unknown, duplicate, and partial failure.
- Validate state machine transitions without live provider.

## 4. Failure Simulation

| Simulation | Validates |
| --- | --- |
| Local failure | Degraded mode paths |
| Network interruption | Unknown state handling |
| Timeout | No false success |
| Duplicate request | Idempotency |
| Payment/POS split-brain | Separate success events |
| Menu sync drift | Reconciliation |
| Sold-out drift | Availability sync |

## 5. Field Verification

- First-store field test separate from sandbox sign-off.
- Staff manual operation paths exercised.
- Evidence capture in real store conditions (redacted as needed).
- Production readiness is **separate** from sandbox pass.

## 6. Test Approval

- Test report required per provider scope.
- Human approval before production enablement.
- `000811` release gate applies.

## 7. Final Rule

Sandbox pass ≠ production ready; field evidence required for Official status.
