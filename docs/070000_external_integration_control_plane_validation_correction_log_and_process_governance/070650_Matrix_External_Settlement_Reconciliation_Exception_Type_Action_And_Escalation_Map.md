# 070650_Matrix_External_Settlement_Reconciliation_Exception_Type_Action_And_Escalation_Map.md

## 1. Purpose

This document defines the exception matrix for external settlement reconciliation within the `70000_External_Integration_Control_Plane` lane.

The purpose is to classify settlement reconciliation exceptions by type, severity, required evidence, allowed action, prohibited action, escalation owner, and closeout condition.

This document covers exceptions arising from external settlement files, VAN/PG settlement reports, card acquirer data, payment provider fee reports, bank deposit records, refund offset records, tax/VAT calculations, and internal expected ledger records.

## 2. Scope

This matrix applies to:

- POS / VAN settlement records
- PG settlement files
- card acquirer / acquiring bank records
- simple payment provider settlement records
- Alipay / WeChat Pay / cross-border payment settlement records
- refund / cancellation / reversal settlement offsets
- fee and VAT deduction files
- bank deposit confirmation records
- internal expected settlement ledger
- accounting / tax handoff records

This document does not replace the accounting ledger policy. It defines operational exception handling before or during ledger finalization.

## 3. Parent And Related Documents

- Parent Index: `70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md`
- Previous: `70640_Policy_External_Deposit_Fee_Tax_Calculation_And_Expected_Ledger_Control.md`
- Next: `70660_Runbook_External_Settlement_Reconciliation_Exception_Review_And_Correction_Action.md`
- Related: `70590_Index_External_Cancel_Refund_Reversal_And_Compensation_Closeout_And_Handoff.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

Settlement exceptions must never be corrected by silent manual value editing.

Every exception must be:

1. classified,
2. linked to source evidence,
3. compared against the expected internal ledger,
4. assigned a severity,
5. routed to an allowed action,
6. logged with decision evidence,
7. closed only after reconciliation evidence is complete.

## 5. Exception Severity Levels

| Severity | Meaning | Example | Auto Close Allowed |
|---|---|---|---|
| S0 | informational difference | provider column naming difference after canonical mapping | yes |
| S1 | minor explainable variance | rounding difference within approved threshold | conditional |
| S2 | financial mismatch requiring review | 1 KRW+ unexplained deposit/fee/tax difference | no |
| S3 | customer/store/accounting impact | missing settlement, duplicate settlement, refund offset error | no |
| S4 | suspected tamper/fraud/provider incident | altered file hash, impossible settlement state, unregistered account deposit | never |

## 6. Settlement Reconciliation Exception Matrix

| Exception Type | Detection Signal | Required Evidence | Severity | Allowed Action | Prohibited Action | Escalation Owner | Closeout Condition |
|---|---|---|---|---|---|---|---|
| Missing Settlement Record | internal payment confirmed but no external settlement row | payment intent, approval response, expected ledger, provider settlement file | S3 | provider inquiry, hold ledger finalization | mark as settled manually | Finance Ops + Provider Ops | provider confirms settlement or exception memo approved |
| Extra External Settlement Record | external file contains unknown transaction | raw file, provider transaction id, terminal id, bank deposit reference | S3 | quarantine row, provider inquiry | create internal sale retroactively without evidence | Finance Ops | mapped to valid transaction or marked provider error |
| Deposit Amount Shortage | bank deposit lower than expected net settlement | bank deposit, settlement file, fee/tax calculation, refund offset | S3 | hold closeout, investigate fee/refund/chargeback | absorb as adjustment without approval | Finance Lead | shortage reason documented and ledger adjusted with approval |
| Deposit Amount Excess | bank deposit higher than expected | bank deposit, expected ledger, provider file | S3 | quarantine excess, investigate duplicate/late settlement | book as revenue directly | Finance Lead | source identified and accounting treatment approved |
| Fee Amount Mismatch | provider fee differs from expected fee | contract fee table, provider file, calculation worksheet | S2 | recalculate, provider inquiry, fee exception register | overwrite fee rate silently | Finance Ops | fee source confirmed or contract table updated |
| VAT / Tax Difference | VAT on fee or taxable amount differs | provider tax invoice, fee split, expected tax ledger | S2 | tax review, accounting hold | force-close without tax evidence | Accounting Owner | tax treatment confirmed |
| Refund Offset Mismatch | refund offset not matching refund ledger | refund request, cancel response, offset row, customer notice | S3 | trace refund offset, hold settlement finalization | close refund as complete without offset proof | Finance Ops + CS | refund offset reconciled or receivable recorded |
| Reversal / Net Cancel Missing | reversal requested but not reflected in settlement | reversal request, inquiry result, provider file | S3 | provider escalation, keep reversal pending | mark reversal completed | Payment Ops | reversal reflected or provider liability evidence obtained |
| Duplicate Settlement | same approval appears settled more than once | approval no, provider transaction id, bank deposit rows | S4 | quarantine, provider incident report | keep both as revenue | Finance Lead + Security | duplicate source resolved and ledger corrected |
| Late Settlement | valid settlement appears after expected cycle | provider cycle rule, business day calendar, settlement file | S1/S2 | classify as late, carry forward expected ledger | mark as missing permanently | Finance Ops | next cycle confirmation completed |
| Chargeback / Dispute Offset | settlement reduced by dispute/chargeback | chargeback notice, provider report, customer dispute record | S3 | dispute workflow handoff | treat as ordinary refund | Finance Ops + Legal/CS | dispute case linked and accounting treatment posted |
| Cross-Store Offset | provider offsets one store refund against another store deposit | provider statement, store ledger, HQ account ledger | S3 | HQ allocation adjustment | post to wrong store P&L | HQ Finance | inter-store allocation evidence complete |
| Cross-Border FX Difference | KRW expected differs due to FX/fee conversion | FX rate, provider file, settlement report, bank deposit | S2/S3 | FX reconciliation, provider inquiry if outside tolerance | use customer app amount as KRW settlement | Finance Ops | FX rule confirmed and ledger posted |
| File Hash Mismatch | downloaded file hash differs from stored hash | original hash, received file, download timestamp | S4 | quarantine file, source re-fetch, security review | ingest modified file | Security + Finance Lead | trusted source file revalidated |
| Untrusted Source File | file from unregistered channel or unknown sender | source metadata, channel registry, file hash | S4 | reject/quarantine | process file | Security | official source confirmed |
| Column Mapping Failure | provider column cannot be mapped to canonical field | raw file, mapping registry, parser log | S2 | update registry after review | guess field meaning | Data Ops | mapping approved and parser test passed |
| Rounding Difference | minor rounding variance within defined rule | calculation worksheet, provider rounding rule | S1 | auto classify if threshold/rule matches | widen threshold without approval | Finance Ops | rounding rule evidence attached |
| Business Day Cutoff Difference | settlement cycle differs due to weekend/holiday/cutoff | provider cycle, calendar, transaction timestamp | S1/S2 | carry forward to next cycle | mark missing immediately | Finance Ops | next cycle confirms expected settlement |
| Manual Adjustment Row | provider includes manual correction row | provider memo, adjustment reason, affected transactions | S3 | require provider explanation and approval | post adjustment without explanation | Finance Lead | adjustment memo and ledger entry complete |
| Bank Deposit Reference Mismatch | bank deposit memo does not match provider settlement id | bank record, provider settlement batch id | S2/S3 | bank/provider inquiry | assume matching only by amount | Finance Ops | batch-to-deposit link confirmed |

## 7. Automatic Handling Rules

Automatic handling is allowed only for:

- provider field naming differences already covered by canonical mapping,
- approved rounding differences,
- approved business-day carry-forward cases,
- duplicate file ingestion where file hash and batch id already exist and no new rows are processed.

Automatic handling is not allowed for:

- missing settlement,
- extra settlement,
- amount shortage,
- amount excess,
- refund offset mismatch,
- reversal missing,
- duplicate settlement,
- file tamper signal,
- untrusted file source,
- unknown provider adjustment.

## 8. Required Evidence Packet

Every S2 or higher exception must produce an evidence packet containing:

- exception id,
- provider id,
- store id,
- business date,
- settlement batch id,
- internal expected ledger reference,
- external raw settlement file reference,
- bank deposit reference where applicable,
- fee/tax calculation reference,
- related payment/cancel/refund/reversal ids,
- reviewer id,
- manager approval id if required,
- final action,
- closeout timestamp.

## 9. Escalation Path

| Condition | Escalation |
|---|---|
| S1 unresolved beyond next settlement cycle | Finance Ops Lead |
| S2 unresolved beyond daily close | Finance Lead |
| S3 unresolved beyond configured SLA | Finance Lead + Provider Ops |
| S4 immediate | Security + Finance Lead + Legal/Compliance |
| customer-impacting settlement issue | CS Lead + Finance Ops |
| store payout-impacting issue | Store Ops + Finance Lead |

## 10. Prohibited Actions

The following actions are prohibited:

- editing settlement amount without linked evidence,
- force-closing a missing settlement as paid,
- posting extra settlement as revenue without source proof,
- manually changing provider fee/tax amount without approval,
- deleting raw settlement file after mismatch,
- replacing original file without retaining the first hash,
- closing refund/reversal settlement mismatch without inquiry proof,
- using bank deposit amount alone as proof of transaction-level settlement.

## 11. Handoff To Runbook

This matrix is executed through:

`70660_Runbook_External_Settlement_Reconciliation_Exception_Review_And_Correction_Action.md`

The runbook must define:

- review queue handling,
- evidence packet creation,
- provider inquiry steps,
- correction request steps,
- accounting hold/release steps,
- manager approval workflow,
- closeout and audit logging.

## 12. Open Gaps

- Provider-specific settlement file sample registry is required.
- Contracted fee table registry is required.
- Business-day calendar and provider cutoff rule registry is required.
- Bank deposit memo matching rule must be separated by provider.
- Chargeback/dispute handling may require separate 70xxx or 75xxx follow-up documentation.

## 13. Closeout Criteria

This matrix is complete when:

- all settlement exception types are classified,
- severity levels are assigned,
- allowed and prohibited actions are defined,
- escalation owners are clear,
- S2+ evidence packet requirements are documented,
- handoff to 70660 Runbook is ready.
