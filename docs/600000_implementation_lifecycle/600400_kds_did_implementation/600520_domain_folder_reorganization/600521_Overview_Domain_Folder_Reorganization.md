# 600521_Overview_Domain_Folder_Reorganization.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`domain_folder_reorganization`

## §0 번호 확인

`600400_kds_did_implementation/` 산하 다음 빈 번호를 재확인했다: `600820`(직전 workpacket) 다음은 `600520`(이번 문서), `docs/`/`600005`/`600007` 어디에도 `600520` 사용 이력 없음 — 확정.

## §1 배경 재확인 (Codex 전수 스캔, 재확인 불필요로 전제 — 폴더 목록만 이번 턴 재확인)

`600400_kds_did_implementation/` 산하 11개 워크패킷 폴더를 이번 턴 디렉토리 조회로 재확인했다:

```
600810_kds_did_event_reactive_implementation
600410_kds_capacity_gate_and_status_reconciliation
600420_kds_status_naming_and_stale_columns
600910_stale_column_reconciliation_batch
600440_kds_status_committed_unification
600710_place_takeout_order_unassigned_record_fix
600610_takeout_session_type_fix
600720_orders_pickup_ready_timing_columns_migration
600510_confirm_payment_from_provider_overload_ambiguity
600620_customer_handoff_contract_reconciliation
600820_did_display_state_overload_and_legacy_defect
```

정확히 11개, "11개 폴더" 전제와 일치.

## §2 확정된 이동 계획

| 신규 도메인 폴더 | 이동 대상 | 근거 |
|---|---|---|
| `600400_kds_did_implementation/`(유지) | `600410`, `600420`, `600440` | 전부 `kds_status`/`kds_tickets`/`check_kds_capacity` 직접 관련 |
| `600500_payment_confirmation/`(신규) | `600510` | `confirm_payment_from_provider()`/`payment_ledger` |
| `600600_waiting_order_session/`(신규) | `600610`, `600620` | `order_sessions`/`register_waiting()` 등 대기·세션 인프라 |
| `600700_takeout_pickup_order/`(신규) | `600710`, `600720` | `place_takeout_order()`/`track_takeout_order()`/pickup 타이밍 |
| `600800_did_implementation/`(신규) | `600820`, `600810`(빈 폴더) | `get_did_display_state()`/DID 이벤트 반응형 구현 |
| `600900_cross_domain_reconciliation/`(신규) | `600910` | 여러 도메인에 걸친 stale-column 일괄 정정 배치 |

워크패킷 번호(`600510`, `600620` 등) 자체는 변경하지 않는다 — 상위 도메인 폴더만 이동한다.

### §2.1 도메인 분류 판단 확인 (2건, 투명 공개 — 반대는 아니나 경계선 사례로 기록)

- **`600610_takeout_session_type_fix`** → `600600`(Waiting/Order Session) 배정: 이 workpacket이 고친 것은 `order_sessions.session_type` 값(`'ONLINE'`→`'TAKEOUT'`)과 `create_order_session()`의 검증 배열이다 — 값 자체는 "TAKEOUT"이지만 고친 대상은 세션 인프라(`order_sessions`/`create_order_session()`)이므로 Waiting/Order Session 배정이 타당하다. `600700`(Takeout)로 배정할 수도 있었던 경계선 사례임을 기록한다.
- **`600620_customer_handoff_contract_reconciliation`** → `600600`(Waiting/Order Session) 단독 배정: 이 workpacket은 실제로 **Waiting/Order Session(Track B) + KDS Ticket(Track C) 두 경계**를 동시에 다뤘다(`600621_Overview.md`/`600622_Logic.md` 자체가 B/C 두 섹션으로 나뉘어 있음, 실제 구현도 `pre_order_while_waiting()`의 `kds_tickets` INSERT 수정을 포함). `600600` 단독 배정은 이 workpacket의 대표 성격(Contract Inventory 자체가 Waiting/Order Session 문맥에서 시작됐고 kds_tickets 수정은 그 파생물)을 반영한 것으로 이해되나, 완전한 단일 도메인은 아니라는 점을 기록해둔다 — 재분류를 제안하지는 않는다(이미 확정된 결정).

## §3 갱신 필요 참조 목록 재확인 — 실제 파일 시스템 상태 대조 (중요 발견)

Codex가 제시한 11개 파일 목록을 하나씩 직접 열어 재확인한 결과, **참조 형식이 파일마다 크게 다르다** — 이는 이동 작업의 실제 난이도와 우선순위에 직접 영향을 준다:

### §3.1 전체 경로(Full Path) 참조 — 실제로 깨지는 것들

| 파일 | 참조 형식 | 이동 후 상태 |
|---|---|---|
| `000005_Index_Document_Number.md` | `docs\600000_implementation_lifecycle\600400_kds_did_implementation\600410_...\600411_Overview.md`(전체 경로) | **깨짐** — 반드시 수정 필요 |
| `000007_Map_Full_Directory.md` | 들여쓰기 트리 형태 전체 경로 | **깨짐** — 반드시 수정 필요 |
| `600402_NavigationMap.md` | `Links` 컬럼이 `<workpacket_folder>/<file>.md`(600400 기준 상대경로) | 이동하는 워크패킷 행만 **깨짐**(600910/600610/600720/600510/600620), 유지되는 행(600410/600420/600440)은 안 깨짐 |

### §3.2 이번 턴 재확인 결과, 예상보다 훨씬 큰 별개의 사전 존재 결함 발견

`000005`/`000007`을 직접 열어 대조한 결과, **이동 작업과 무관하게 이미 심각하게 불완전한 상태**임을 확인했다:
- `000005_Index_Document_Number.md`는 `600400` 산하 11개 워크패킷 폴더 중 `600410`(그것도 7개 파일 중 2개만) 외에는 **단 하나도 색인되어 있지 않다**(600810/600420/600910/600440/600710/600610/600720/600510/600620/600820 전부 0건).
- `000007_Map_Full_Directory.md`도 `600810`/`600410`(폴더명만, 파일 목록 없음) 외에는 마찬가지로 색인되어 있지 않다.

**결론**: 이 두 파일은 "이동에 맞춰 경로만 바꾸면 되는" 상태가 아니라, **애초에 대부분의 워크패킷이 색인된 적이 없는 상태**다. 이동 작업과 함께 처리한다면, 단순 경로 치환이 아니라 "이동 후 최종 위치 기준으로 처음부터 색인 항목을 신규 추가"하는 작업에 가깝다 — `600402_Logic.md`에서 이를 반영한다.

### §3.3 bare-name(경로 없는 이름) 참조 — 이동해도 텍스트는 안 깨지는 것들

나머지 8개 파일(`000053`, `600400_Readme`, `600417_Audit.md`, `600441_Overview.md`, `600442_Logic.md`, `600404_Defect_Roadmap.md`, `600514_ChangeContract.md`, `600621_Overview.md`, `600625_Module.md`, `600821_Overview.md`)을 전부 직접 열어 확인한 결과, **전체 경로(`docs/600000_implementation_lifecycle/...`)를 포함한 참조가 단 한 건도 없었다** — 전부 `600510_confirm_payment_from_provider_overload_ambiguity`처럼 워크패킷/파일의 **이름만** 언급하는 산문체 참조다. 이런 참조는 폴더가 물리적으로 이동해도 **텍스트 자체는 여전히 사실과 일치한다**(그 workpacket의 이름은 그대로이므로) — 다만 "어디 가면 찾을 수 있는지"에 대한 안내력이 떨어질 뿐이다. 이는 `600402_NavigationMap.md`의 "전체 경로는 아니지만 상대경로"인 `Links` 컬럼과는 다른, 더 낮은 우선순위의 사안이다.

## §4 `git mv` 시퀀스 초안 (Stage 4 대상, 이번 턴 미실행)

```powershell
# 1. 새 도메인 폴더 5개는 첫 워크패킷 이동과 함께 자동 생성됨(git mv는 대상 디렉토리를 자동 생성)
git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600510_confirm_payment_from_provider_overload_ambiguity" "docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity"

git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600610_takeout_session_type_fix" "docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix"
git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600620_customer_handoff_contract_reconciliation" "docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation"

git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600710_place_takeout_order_unassigned_record_fix" "docs/600000_implementation_lifecycle/600700_takeout_pickup_order/600710_place_takeout_order_unassigned_record_fix"
git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600720_orders_pickup_ready_timing_columns_migration" "docs/600000_implementation_lifecycle/600700_takeout_pickup_order/600720_orders_pickup_ready_timing_columns_migration"

git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600820_did_display_state_overload_and_legacy_defect" "docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect"
git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600810_kds_did_event_reactive_implementation" "docs/600000_implementation_lifecycle/600800_did_implementation/600810_kds_did_event_reactive_implementation"

git mv "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600910_stale_column_reconciliation_batch" "docs/600000_implementation_lifecycle/600900_cross_domain_reconciliation/600910_stale_column_reconciliation_batch"

# 2. 600410/600420/600440은 그대로 둠 (git mv 없음)

# 3. 각 신규 도메인 폴더에 Readme 신규 작성 (Write, git mv 아님)
#    600500_Readme_Payment_Confirmation.md
#    600600_Readme_Waiting_Order_Session.md
#    600700_Readme_Takeout_Pickup_Order.md
#    600800_Readme_Did_Implementation.md
#    600900_Readme_Cross_Domain_Reconciliation.md
```

정확한 순서·원자성·롤백 계획은 `600522_Logic.md`에서 다룬다.

## §5 신규 Readme 필요성

이동 후 각 신규 도메인 폴더는 진입점 문서가 없다 — `600400_Readme_KDS_DID_Implementation.md`가 지금까지 11개 워크패킷 전체를 아우르는 유일한 진입점이었으나, 분리 후에는 그 범위가 KDS 3건으로 축소된다. 5개 신규 폴더 각각에 `Readme`가 필요하며, `600400_Readme_KDS_DID_Implementation.md` 자신도 제목이 더 이상 정확하지 않다("KDS_DID"였으나 DID는 `600800`으로 이동) — 이 문서 자체의 제목 정정 필요 여부도 Open Item으로 남긴다(리네임은 새 네이밍 규칙상 소급 적용 대상 아닐 수 있음, `000054` 참고).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`
- `000002_Naming_Rules.md`(2026-07-14 갱신분 — 폴더 이동과 무관하나 이번 workpacket 자체의 파일명 규칙 적용 근거)

### Full Rules Required

- `docs/000005_Index_Document_Number.md` — 이동 후 전체 재작성 대상, §3.2의 사전 결함 포함.
- `docs/000007_Map_Full_Directory.md` — 동일.
- `600402_NavigationMap.md` — Links 컬럼 상대경로 갱신 대상.
- `600404_PlaceTakeoutOrder_Defect_Roadmap.md` — bare-name 참조뿐이라 텍스트 수정 불필요하나, 이동 후 물리적 위치 확인용으로 열람 필요.

### Domain Indexes

- 해당 없음.

### Excluded Rule Families

- `000053_Matrix_Domain_To_Artifact_Traceability.md` — bare-name 참조뿐, 텍스트 수정 불필요 확인됨(§3.3).
- `600417_Audit.md`/`600441_Overview.md`/`600442_Logic.md`/`600514_ChangeContract.md`/`600621_Overview.md`/`600625_Module.md`/`600821_Overview.md` — 전부 bare-name 참조뿐, 텍스트 수정 불필요 확인됨(§3.3).

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600522_Logic_Domain_Folder_Reorganization.md` 작성 진행 가능.
