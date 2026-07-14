# 600522_Logic_Domain_Folder_Reorganization.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`domain_folder_reorganization`

## §1 참조 갱신 — 정확한 Before/After

### §1.1 `600402_NavigationMap.md` — 확정: 도메인별 완전 분리 (Human 결정 2026-07-14, 재논의 금지)

`600402`는 `600400`(KDS 3건: `600410`/`600420`/`600440`)만 다루도록 축소한다. 나머지 5개 워크패킷의 행은 단순 경로 patch가 아니라 **각자 새 도메인 폴더의 신규 `NavigationMap.md`로 행 자체가 완전히 이전**한다. `000053`(교차 매트릭스)과의 역할 구분: `000053`은 "전체 조망"(도메인 A-G 전체를 가로지르는 조사 상태), 각 `NavigationMap`은 "그 도메인 폴더 내부 지역 색인"(그 폴더 안에 무엇이 있고 무슨 상태인지) — 서로 다른 축이므로 중복이 아니다.

**신규 파일 5개**(기존 `600400`/`600401`/`600402`/`600403` 넘버링 패턴을 각 도메인 폴더에 그대로 복제, 새 네이밍 규칙 적용):

| 신규 파일 | 이관되는 행 |
|---|---|
| `600500_payment_confirmation/600502_NavigationMap_Payment_Confirmation.md` | `600480_confirm_payment_from_provider_overload_ambiguity` |
| `600600_waiting_order_session/600602_NavigationMap_Waiting_Order_Session.md` | `600460_takeout_session_type_fix`, `600490_customer_handoff_contract_reconciliation` |
| `600700_takeout_pickup_order/600702_NavigationMap_Takeout_Pickup_Order.md` | `600450_place_takeout_order_unassigned_record_fix`(**신규 발견 — 아래 참고**), `600470_orders_pickup_ready_timing_columns_migration` |
| `600800_did_implementation/600802_NavigationMap_Did_Implementation.md` | **0개 행** — `600510_did_display_state_overload_and_legacy_defect`는 이번 백필에서 **제외**(Human 결정, §1.2.1 참고), `600330_kds_did_event_reactive_implementation`은 빈 폴더라 애초에 행 없음. 파일 자체는 빈 뼈대(헤더+"현재 등재된 워크패킷 없음")로 생성한다. |
| `600900_cross_domain_reconciliation/600902_NavigationMap_Cross_Domain_Reconciliation.md` | `600430_stale_column_reconciliation_batch` |

각 행의 `Links` 컬럼은 새 파일이 자기 도메인 폴더 안에 있으므로 상대경로가 그대로 짧게 유지된다(예: `600480_confirm_payment_from_provider_overload_ambiguity/600481_Overview_...md` — 경로 접두어 계산 불필요, 이관 자체가 곧 정답).

**신규 발견(이번 턴)**: `600402`의 현재 9개 행을 다시 대조한 결과, **`600450_place_takeout_order_unassigned_record_fix`는 애초에 `600402`에 행 자체가 없었다**(이전 세션에서 이미 발견해 기록만 하고 채우지 않았던 gap — 이번 턴 재확인). `600700`용 신규 `NavigationMap`을 만드는 김에, 없던 행을 처음부터 채워 넣는다(단순 이관이 아니라 신규 작성) — 근거는 `600455_Module.md`/`600456_Verification.md`/`600457_Audit.md`(ACCEPT scoped, 11곳 스칼라 변환).

#### §1.1.1 `600510` 백필 제외 확정 (Human 결정 2026-07-14, 재논의 금지)

`600510_did_display_state_overload_and_legacy_defect`는 아직 **Stage 2**(`600511`-`600514`: Overview/Logic/TestPlan/ChangeContract만 존재, Human Approval 대기 중 — 이번 턴 재확인, `600512_Verification.md`/`600512_Audit.md` 등 Stage 4-6 산출물 0건) 단계이므로, 이번 색인/`NavigationMap` 백필에서 **제외**한다. `600450`과의 결정적 차이: `600450`은 Stage 6 ACCEPT 완료(`600455_Module.md`/`600456_Verification.md`/`600457_Audit.md` 실제 존재)이므로 "이미 완료된 사실을 옮겨 적는" 것이지만, `600510`은 아직 구현 전이므로 지금 색인 행을 만들면 "미완성 워크패킷을 완료된 것처럼 기록"하게 되는 위험이 있다.

**폴더 물리적 이동은 그대로 진행**한다 — `600510`의 4개 파일 자체는 실제로 존재하므로 `git mv`로 `600800_did_implementation/`으로 옮기는 것 자체는 문제없다. 다만 `600402`(구)/`600802`(신)의 `NavigationMap` 행과 `000005`/`000007`의 색인 항목 생성만 유예한다 — `600510`이 Stage 6 ACCEPT된 이후, 별도 workpacket에서 추가한다(§4 Open Item으로 기록).

**행 수 재계산**: `600402`(3) + `600502`(1) + `600602`(2) + `600702`(2, `600450` 포함) + `600802`(**0**, 위 정정) + `600902`(1) = **9행**(이전 초안의 "10행"에서 정정 — 원래 있던 8행 중 `600510` 관련 행은 처음부터 없었으므로 "8+신규 `600450` 1 = 9"가 맞다).

### §1.2 `000005_Index_Document_Number.md` — 확정: 전면 백필 (Human 결정 2026-07-14, 재논의 금지)

이동하는 8개 워크패킷의 **모든 파일**과 `600410`의 미색인 5개 파일(`600413`-`600417`)을 지금 전부 채운다. 정확한 파일 목록(이번 턴 실제 디렉토리 조회로 확인):

| 워크패킷(이동 후 위치) | 파일 목록 |
|---|---|
| `600500_payment_confirmation/600480_.../` | `600481_Overview_...md`, `600482_Logic_...md`, `600483_TestPlan.md`, `600484_ChangeContract.md`, `600485_Module.md`, `600486_Verification.md`, `600487_Audit.md`(7개) |
| `600600_waiting_order_session/600460_.../` | `600461_Overview.md`~`600467_Audit.md`(7개, 제목 없는 구버전 파일명 그대로 — `000054`에 의해 소급 rename 대상 아님) |
| `600600_waiting_order_session/600490_.../` | `600491_Overview.md`~`600497_Audit.md`(7개, 구버전 파일명) |
| `600700_takeout_pickup_order/600450_.../` | `600451_Overview.md`~`600457_Audit.md`(7개, 구버전 파일명) |
| `600700_takeout_pickup_order/600470_.../` | `600471_Overview.md`~`600477_Audit.md`(7개, 구버전 파일명) |
| `600800_did_implementation/600510_.../` | **색인 제외**(§1.1.1) — 폴더는 물리적으로 이동하지만 `000005`/`000007` 항목은 생성하지 않는다. `600510`이 Stage 6 ACCEPT된 이후 별도로 추가. |
| `600800_did_implementation/600330_.../` | (없음 — `.gitkeep`만) |
| `600900_cross_domain_reconciliation/600430_.../` | `600431_Overview.md`~`600437_Audit.md`(7개, 구버전 파일명) |
| `600400_kds_did_implementation/600410_.../`(위치 불변, 색인만 보충) | 기존 색인된 2개(`600411_Overview.md`/`600412_Logic.md`) + 신규 5개(`600413_TestPlan.md`, `600414_ChangeContract.md`, `600415_Module.md`, `600416_Verification.md`, `600417_Audit.md`) |

**합계 재계산**(`600510`의 4개 파일 제외 반영): 이동 8개 워크패킷 중 색인 대상은 7개(`600510` 제외) = 42개 파일(7×6=42, `600430`/`600450`/`600460`/`600470`/`600480`/`600490` 6개 워크패킷 각 7개) + `600410` 신규 5개 = **총 47개 파일 항목 신규 색인**(이전 초안의 "51개"에서 `600510`의 4개를 뺀 정정치).

### §1.3 `000007_Map_Full_Directory.md` — 확정: 전면 백필 (동일 결정, `600510` 제외 동일 반영)

`000005`와 동일한 47개 항목을 트리 구조로 반영한다. 최종 트리는 `600500_payment_confirmation/`, `600600_waiting_order_session/`, `600700_takeout_pickup_order/`, `600800_did_implementation/`, `600900_cross_domain_reconciliation/` 5개 신규 최상위 폴더가 `600400_kds_did_implementation/`(KDS 3건 + 색인 완비된 `600410`)와 나란히 `docs/600000_implementation_lifecycle/` 아래 위치하는 형태다. `600800_did_implementation/` 트리 안에는 `600510_.../` 폴더 자체(빈 디렉토리 노드)는 나타나되, 그 안의 4개 파일은 이번엔 트리에 나열하지 않는다(§1.1.1과 동일 이유) — 또는 폴더째로 생략하고 다음 백필에서 통째로 추가하는 방식도 가능, Stage 4 실행 시 세부 표기 방식 결정.

### §1.4 bare-name 참조 8개 파일 — 텍스트 수정 불필요 (재확인, `600521_Overview.md` §3.3)

`000053`/`600400_Readme`/`600417_Audit.md`/`600441_Overview.md`/`600442_Logic.md`/`600404_Defect_Roadmap.md`/`600484_ChangeContract.md`/`600491_Overview.md`/`600495_Module.md`/`600511_Overview.md` — 전부 워크패킷/파일 이름만 언급(경로 없음), 이동 후에도 텍스트 그대로 정확함. **Before/After 없음, 수정 대상 아님.**

## §2 `git mv` 순서 및 원자성 확보 방안

### §2.1 순서 원칙 — 폴더 이동을 먼저, 참조 갱신을 나중에

1. **1단계: 8개 워크패킷 폴더 + `600400_Readme` 파일명을 전부 `git mv`한다** (`600521_Overview.md` §4, `600522` §1.5). 이 단계는 순수 파일시스템 이동/rename이며, 문서 본문 내용은 전혀 건드리지 않는다 — 따라서 이 단계 도중 어떤 순서로 9개(8개 폴더 + Readme 1개)를 옮기든 서로 독립적이다.
2. **1.5단계: `600400_Readme`의 본문을 정정한다**(§1.5의 Before/After) — Subfolder Map이 최종 상태(KDS 3건만)를 반영해야 하므로 1단계 완료 후.
3. **2단계: 5개 신규 Readme + 5개 신규 NavigationMap(총 10개 신규 파일)을 작성한다**(`Write`, `git mv` 아님) — 1단계 완료 후, 폴더가 실제로 존재해야 그 안에 만들 수 있으므로 순서상 반드시 1단계 뒤.
4. **3단계: `600402`(3행으로 축소) + `000005`/`000007`(51개 항목 백필)을 갱신한다** — 1단계가 완료되어 최종 경로가 확정된 후에만 정확한 최종 값을 알 수 있으므로 반드시 마지막.

**폴더 이동을 먼저 하는 이유**: 참조 갱신을 먼저 하면 그 시점엔 아직 파일이 옛 경로에 있으므로 "존재하지 않는 경로를 가리키는 새 참조"가 일시적으로 생긴다(더 위험) — 반대로 폴더를 먼저 옮기면 일시적으로 "참조는 옛 경로, 실제 파일은 새 경로"인 상태가 되어 **참조가 stale할 뿐 깨진 링크를 만들지는 않는다**(구 경로 참조 자체는 이미 "bare-name" 참조가 대부분이라 §1.4처럼 텍스트로는 여전히 유효 — 오직 000005/000007/600402만 실제 경로 참조이고, 이들은 3단계에서 한 번에 갱신).

### §2.2 원자성 — 8개 `git mv`를 하나의 논리적 단위로 취급

각 `git mv`는 Git 수준에서 개별 커밋 대상이 될 수 있으나, **8개를 전부 완료하기 전에는 커밋하지 않는다**(이 workpacket 자체가 "스테이징/커밋 금지" 지시 하에 있으므로 Stage 4 실행 시점에도 동일 원칙 적용 권고) — 8개 중 일부만 옮겨진 상태로 커밋되면 `600402`/`000005`/`000007` 갱신(3단계)이 어느 경로를 기준으로 해야 할지 모호해진다.

### §2.3 검증 체크포인트 (각 단계 사이)

- 1단계 후: `git status`로 8개 폴더 + `600400_Readme`가 모두 `renamed:` 상태인지 확인, `ls`로 8개 신규 도메인 폴더 각각에 예상 파일 수가 있는지 확인(600480=7, 600460=7, 600490=7, 600450=7, 600470=7, 600510=4, 600330=0, 600430=7 — 합 46).
- 1.5단계 후: `600400_Readme` 본문에 "DID" 단어가 (남겨야 할 이관 안내 문구 1곳 제외하고) 더 이상 없는지 확인.
- 2단계 후: 5개 Readme + 5개 NavigationMap, 총 10개 신규 파일 존재 확인.
- 3단계 후: `600402`가 정확히 3행(600410/600420/600440)인지, `000005`/`000007`이 51개 항목을 실제 파일시스템과 1:1 대조했을 때 누락/오기 없는지 확인(`600523_TestPlan.md`에서 상세화).

## §3 롤백 계획

- **1단계 도중 실패**(예: 9개 중 일부만 옮긴 상태에서 중단): 각 `git mv`는 독립적이므로, 이미 옮긴 것은 그대로 두고 나머지를 이어서 실행하거나, 전체를 역순으로 되돌린다 — 이 시점엔 문서 본문(600400_Readme 제외 전부)을 전혀 안 건드렸으므로 되돌리기 단순하다.
- **1.5단계 도중 실패**: `600400_Readme` 본문 정정 하나만 실패한 것이므로, 그 파일만 `git diff`로 확인 후 재작업하거나 `git checkout -- <file>`로 되돌린다 — 다른 8개 폴더 이동에는 영향 없다.
- **2단계 도중 실패**: 신규 Readme/NavigationMap은 새 파일 추가일 뿐이므로, 실패해도 기존 어떤 파일도 손상되지 않는다 — 미완성분을 지우거나 이어서 완성하면 된다.
- **3단계 도중 실패**(예: `600402`는 갱신했으나 `000005`/`000007`은 아직): 1/1.5/2단계는 이미 유효한 최종 상태이므로 되돌릴 필요 없다 — 3단계만 이어서 완료하면 된다.
- **전체 롤백이 필요한 경우**: 1단계 9개 `git mv`를 역순으로 되돌리는 것이 가장 안전 — 그러나 1.5/2/3단계가 이미 진행됐다면 그 결과물도 함께 되돌려야 일관성이 유지된다.

## §4 Open Items — 전부 확정됨 (Human 결정 2026-07-14)

(a) **확정됨**: `600402_NavigationMap.md`는 도메인별로 완전 분리한다 — `600402`는 `600400`(KDS 3건)만, 나머지는 각 도메인 폴더의 신규 `NavigationMap`으로 행 자체가 이전한다(§1.1). `000053`과의 역할 구분(전체 조망 vs 지역 색인)도 확정.

(b) **확정됨(정정)**: `000005`/`000007`을 이번에 전면 백필하되, `600510`은 제외한다(§1.1.1) — 이동 8개 워크패킷 중 7개의 모든 파일(42개) + `600410`의 미색인 5개 파일까지 지금 채운다(§1.2/§1.3). `600510`을 제외한 나머지는 별도 workpacket으로 이월하지 않는다.

(e) **신규**: `600510_did_display_state_overload_and_legacy_defect`의 `NavigationMap`/`000005`/`000007` 색인 백필은 **그 워크패킷이 Stage 6 ACCEPT된 이후, 별도 workpacket에서 처리한다**(§1.1.1). 폴더의 물리적 `git mv`(600400→600800)는 이번 workpacket에서 그대로 진행하지만, "무엇이 그 안에 있고 무슨 상태인지"를 기록하는 색인 작업은 미완성 워크패킷에 대해 하지 않는다는 원칙에 따라 유예한다.

(c) **확정됨**: `600400_Readme_KDS_DID_Implementation.md` → `600400_Readme_KDS_Implementation.md`로 rename한다. `000054`의 "소급 rename 금지" 원칙은 "처음부터 잘못 지어진 이름"을 다루는 것이고, 이 파일은 **작성 당시엔 정확했으나(KDS+DID를 실제로 함께 다뤘음) 이번 도메인 분리로 상황 자체가 바뀐 경우**라 다른 케이스로 판단됨 — `000054`의 예외 대상이 아니므로 정상적인 rename 대상이다. rename과 함께 본문의 DID 관련 서술(Purpose 문단의 "KDS(주방 디스플레이)/DID(매장 디스플레이)", In Scope의 DID 언급 등)도 KDS 단독 범위로 정정한다 — 정확한 Before/After는 §1.5에서 다룬다.

(d) **해결됨(이전 확인 유지)**: `600330_kds_did_event_reactive_implementation`은 `.gitkeep` 하나만 있는 빈 폴더 — `git mv` 그대로 진행 가능.

### §1.5 `600400_Readme` rename 및 본문 정정 — Before/After

**파일명**: `600400_Readme_KDS_DID_Implementation.md` → `600400_Readme_KDS_Implementation.md`(`git mv`, 번호 불변).

**본문 정정**(현재 내용 기준, 이번 턴 재확인):

| 위치 | Before | After |
|---|---|---|
| Purpose 문단 | "**KDS(주방 디스플레이)/DID(매장 디스플레이) 관련 결함 발견 및 정정 작업**을 다룬다" | "**KDS(주방 디스플레이) 관련 결함 발견 및 정정 작업**을 다룬다. DID 관련 작업은 `600800_did_implementation/`으로 이관됨(2026-07-14, 도메인 분리)." |
| In Scope 첫 줄 | "KDS/DID 런타임 결함 발견 및 정정 워크패킷" | "KDS 런타임 결함 발견 및 정정 워크패킷" |
| Out of Scope 둘째 줄 | "이 모듈 밖 결함(결제/고객식별/Flutter 등)을 이 모듈에서 다루는 것" | "이 모듈 밖 결함(결제/대기·세션/포장·픽업/DID/교차도메인/고객식별/Flutter 등)을 이 모듈에서 다루는 것" — 신규 5개 도메인 명시 추가 |
| Subfolder Map | `600330`(무관 언급)/`600410` 2행만 | `600410`/`600420`/`600440` 3행(KDS 전용, `600330`은 `600800`으로 이관되어 이 표에서 제거) |

(§1.5의 Before/After가 실행되는 정확한 순서상 위치는 §2.1의 4단계 시퀀스 — "1단계"에 `600400_Readme` rename 포함, "1.5단계"에 본문 정정 — 를 참고.)

## Snapshot Decision

**확정.** §4(a)/(b)/(c) 전부 Human 결정으로 확정되어 더 이상 Open Item이 아니며, `600510` 색인 제외(§1.1.1, §4(e))가 추가 반영됐다. 이 스냅샷으로 Stage 2(`600523_TestPlan.md`/`600524_ChangeContract.md`) 진행 가능. `.sql` 파일은 물론 어떤 `git mv`/파일 이동도 이번 턴에서 실행하지 않았다.
