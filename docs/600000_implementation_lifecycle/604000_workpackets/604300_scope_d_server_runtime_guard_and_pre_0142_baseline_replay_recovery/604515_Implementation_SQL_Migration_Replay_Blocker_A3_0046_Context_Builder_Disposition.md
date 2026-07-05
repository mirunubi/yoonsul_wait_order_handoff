# 604515_Implementation_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md

Status: Complete
Lifecycle: Implementation Record
Risk: HIGH
Last Updated: 2026-07-05

## 1. Authority and result

This implementation record accepts `604514_Approval_Gate_SQL_Migration_Replay_Blocker_A3_0046_Context_Builder_Disposition.md` as its sole authority. The controlling Final Approval Decision is:

```text
APPROVED_FOR_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_ONLY_WITH_HIGH_RISK_SINGLE_FILE_SQL_BOUNDARY
```

Implementation result:

```text
IMPLEMENTATION_RECORD_CREATED_FOR_A3_0046_CONTEXT_BUILDER_REPLAY_BLOCKER_DISPOSITION_WITH_NO_STAGING
```

No SQL or migration content was edited during 604515. The existing working-tree diff was inspected read-only and recorded for 604516 Verification.

## 2. A3 single-file disposition confirmation

The only A3 SQL file examined was:

```text
sql/migrations/0046_create_context_builder_rpc.sql
```

Read-only Git inspection confirmed:

- The file exists and is tracked.
- Git state is `M` (modified), unstaged.
- Diff size is 67 insertions and 60 deletions (`+67/-60`).
- `git diff --name-status` reports `M` for the target path.
- The target has no staged diff.
- The staging area contains no files.

The A3 high-risk, single-file SQL boundary remains intact.

## 3. Replay blockers and working-tree correction

The HEAD version has two independent PostgreSQL aggregate-call syntax blockers inside `catchmenu_knowledge.build_ai_context`:

1. The primary context-document blocker placed `limit p_max_documents` directly inside a `jsonb_agg(... ORDER BY ...)` aggregate call.
2. The secondary related-exception blocker placed `limit 5` directly inside another `jsonb_agg(... ORDER BY ...)` aggregate call.

The working-tree correction applies the approved Candidate B structure to both blocks:

- an inner subquery selects the candidate rows;
- the existing filters and candidate selection are retained;
- the existing sort is applied before the cap;
- `LIMIT p_max_documents` or `LIMIT 5` is applied at the subquery row level; and
- the outer `jsonb_agg` aggregates the already limited row set.

Read-only inspection found zero inline `jsonb_agg(... LIMIT p_max_documents)` patterns and zero inline `jsonb_agg(... LIMIT 5)` patterns. The file retains one row-level `LIMIT p_max_documents` and one row-level `LIMIT 5`, confirming that the caps were relocated rather than removed.

This is consistent with the 604350 and 604354 Candidate B lineage. Its change character is substantive query restructuring: LIMIT placement correction, preservation of sorting and candidate selection, and correction of the JSON aggregation wrapper. Existing filters, payload field sets, and audience masking semantics remain preserved by the rewrite.

## 4. Revert/discard prohibition and risk

Revert or discard to HEAD was not performed and remains prohibited. HEAD contains both invalid inline aggregate LIMIT constructs; restoring it could reintroduce the 0046 parse-time blocker and halt sequential replay at 0046 before 0047 and all later migrations.

Risk remains `HIGH` because moving LIMIT to a row-producing subquery controls which candidates enter each aggregate. The correction is therefore more than a mechanical token replacement even though it preserves the intended caps, ordering, and JSON payloads.

## 5. Boundary preservation

The following boundaries were preserved:

- A1 files `0038`, `0042`, `0063`, and `0068` remain committed and untouched.
- A2 file `0035` remains committed and untouched.
- A4 file `0065` remains excluded and untouched.
- A5 files `0066` and `0067` remain excluded, untouched, and sequentially coupled.
- Group B `0138` remains excluded and untouched.
- Group C zero-pad pairs `024/0024`, `030/0030`, and `032/0032` remain excluded and untouched.
- Group D `0142` remains excluded and untouched.
- Group E `0136`, `0139`, `0141`, and `seed_yoonsul_menu.sql` remain excluded and untouched.
- Already committed migration `0143` remains excluded and untouched.
- `tools/*`, runtime code, Flutter/KDS UI, and POS integration remain untouched.
- 0069 Analysis was not created and remains deferred.
- Scope D mainline was not resumed and remains blocked.
- No reset, discard, rename, staging, or commit was performed.

## 6. Validation evidence

The required read-only status and diff commands were executed. Results:

```text
0046 file exists: yes
0046 git state: M, tracked modified, unstaged
0046 diff size: +67/-60
inline aggregate LIMIT p_max_documents patterns: 0
inline aggregate LIMIT 5 patterns: 0
row-level LIMIT p_max_documents occurrences retained: 1
row-level LIMIT 5 occurrences retained: 1
staged files: 0
git diff --check: PASS
```

The full 0046 diff was reviewed without editing the file. This disposition record does not constitute runtime replay verification or commit authorization.

## 7. Next step

```text
604516 Verification
```

604516 must verify both corrected query blocks within the same A3 single-file boundary before any later selective staging or commit decision is considered.
