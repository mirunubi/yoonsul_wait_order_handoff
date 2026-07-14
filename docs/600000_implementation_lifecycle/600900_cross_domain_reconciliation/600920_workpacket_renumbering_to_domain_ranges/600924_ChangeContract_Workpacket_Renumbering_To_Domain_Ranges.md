# 600924_ChangeContract_Workpacket_Renumbering_To_Domain_Ranges.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## §0 Authority

Based on `600921_Overview_...md`, `600922_Logic_...md`(최종 확정 — Human 결정 1(옵션 b, `600530`→`600540`)/2(`600521`–`600527` 내용 갱신) 반영 완료, 53개 파일), `600923_TestPlan_...md`.

**이 계약은 Human 결정 1/2 자체를 재논의하지 않는다.** `600922_Logic.md` §0의 번호 충돌은 옵션 b 채택(`600540`으로 재조정)으로 완전히 해소됐으며, `600540`이 실제 빈 슬롯임을 디스크/색인 양쪽에서 재확인했다 — 더 이상 Stage 4 착수를 막는 미해소 게이트는 없다.

- 9개 폴더 이동(`600480`/`600460`/`600490`/`600450`/`600470`/`600330`/`600510`/`600430`/`600530`), 워크패킷 번호 전면 재조정.
- 53개 파일 rename(그룹 1-9, `600922_Logic.md` §1 표 전체 — 그룹 9는 7개, DID(`600510`→`600820`)와 달리 이미 Stage 6 ACCEPT 완료 상태).
- 외부 참조 갱신: `000005`/`000007`(그룹 1-8 42개 엔트리 치환 + 그룹 9 7개 신규 백필), `000053`/`000054`/`000002`/`000701`, `600401`–`600404`(`600401`/`600502`는 이미 존재하는 `600530` 행의 번호만 치환), `600441`/`600442`/`600446`, `600520` 워크패킷 자신(`600521`–`600527`, 내용만 — 폴더/번호는 이동하지 않음), 도메인 Readme/NavigationMap 5쌍.
- `600510`(DID) 워크패킷은 번호만 변경(`600820`), 내용/구현 상태("미완성", Stage 2)는 전혀 재론하지 않음, 색인 백필도 계속 제외.
- `600530`(mark_payment_uncertain) 워크패킷은 번호만 변경(`600540`), 내용/구현 상태(Stage 6 ACCEPT 완료, `0154`/삼중검증/`600537_Audit.md`)는 전혀 재론하지 않음 — **단 색인 백필은 DID와 달리 이번에 포함**(§1-4).

## §1 Allowed Files And Operations

| Operation | Scope |
|---|---|
| `git mv`(폴더) ×9 | `600480→600510`, `600460→600610`, `600490→600620`, `600450→600710`, `600470→600720`, `600330→600810`, `600510→600820`, `600430→600910`, `600530→600540`. |
| `git mv`(파일) ×53 | `600922_Logic.md` §1 그룹 1-9 표 전체(그룹 9는 7개: `600531`–`600537`→`600541`–`600547`). |
| `Edit` | 53개 이동 파일 자신의 본문 — 자기/형제 참조(옛 번호) 갱신만. |
| `Edit` | `000005_Index_Document_Number.md`/`000007_Map_Full_Directory.md` — 그룹 1-8(42개) 엔트리 경로/번호 치환 **+ 그룹 9(7개) 신규 엔트리 추가**(DID 4개는 여전히 미색인이므로 신규 엔트리 추가하지 않음). |
| `Edit` | `000053`/`000054`/`000002`/`000701` — 옛 번호 언급을 신규 번호로 치환만. |
| `Edit` | `600401_ChangeHistory.md` — 그룹 1-8 완료 기록 행 치환 **+ `mark_payment_uncertain_overload_ambiguity` 행(이미 존재)의 번호만 치환**(신규 행 추가 아님). |
| `Edit` | `600402_NavigationMap.md`/`600403_DecisionLog.md`/`600404_PlaceTakeoutOrder_Defect_Roadmap.md` — 옛 번호 언급 치환만. |
| `Edit` | `600441_Overview.md`/`600442_Logic.md`/`600446_Verification.md`(`600440`, 이동 안 함) — bare 언급 치환만. |
| `Edit` | `600521`–`600527`(`600520_domain_folder_reorganization/`, 이동 안 함) — 본문 안 옛 번호 언급 전부 치환(Human 결정 2). **파일명/폴더명 자신은 변경 금지.** |
| `Edit` | `600500_Readme_Payment_Confirmation.md`/`600502_NavigationMap_Payment_Confirmation.md` — `600480` bare 언급 치환 **+ 이미 존재하는 `600530_mark_payment_uncertain_overload_ambiguity/` 행 전체(경로·7개 파일 나열)를 `600540`/`600541`–`600547`로 치환**(신규 행 추가 아님, 기존 행 갱신). |
| `Edit` | `600600`/`600602`, `600700`/`600702`, `600800`/`600802`, `600900`/`600902` — 소속 워크패킷 번호 텍스트 치환만(신규 행 없음). |

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `600520_domain_folder_reorganization/`의 폴더명/`600521`–`600527`의 파일명 자체를 다른 번호로 변경 | Human 결정 2는 "내용 갱신"만 승인 — 옵션 b 채택으로 이 폴더는 어떤 번호 충돌과도 무관해졌으므로 이동할 이유 자체가 없다. |
| `000005`/`000007`에 DID(`600820`, 그룹 7)의 신규 색인 항목 추가 | DID는 여전히 Stage 2 — Stage 6 ACCEPT 전까지 색인 대상 아님(`600522_Logic.md` §1.1.1 원칙 유지). |
| `600502_NavigationMap_Payment_Confirmation.md`/`600401_ChangeHistory.md`에 `mark_payment_uncertain_overload_ambiguity`의 **신규** 행 추가 | 이미 존재하는 행의 번호만 치환한다 — 중복 행 생성 금지. |
| `sql/migrations/*.sql`, Flutter/런타임 코드, `tools/` 스크립트 | 범위 밖. |
| DID(`600510`→`600820`)/mark_payment_uncertain(`600530`→`600540`) 두 워크패킷의 실제 설계·구현 내용 | 번호만 바뀌고 내용은 전혀 재론하지 않음(`0154`, Option A 확정, `600537_Audit.md`의 ACCEPT 판정 등 전부 불변). |

Implementation must not:

- `600520_domain_folder_reorganization/`을 rename 대상에 포함시키지 않는다(§0/§1이 이미 이동하지 않는 것으로 확정).
- `600527_Audit.md`/`600537_Audit.md`의 ACCEPT 판정 자체를 재론하거나 되돌리지 않는다 — 본문 안 옛 번호 언급만 치환.
- 53개 파일 중 어느 것도 rename과 무관한 본문 내용을 편집하지 않는다.
- `000005`/`000007`에 그룹 9(7개) 엔트리를 추가할 때, 그룹 1-8(42개)의 기존 엔트리 형식과 다르게(예: 다른 컬럼 구조로) 추가하지 않는다 — 기존 색인 형식을 그대로 따른다.

## §3 Required Behavior Preservation

- 이동되는 53개 파일 모두 rename 전후 내용이 byte-identical해야 한다(참조 치환은 rename **이후** 별도 `Edit` 단계).
- `600527_Audit.md`/`600537_Audit.md`의 ACCEPT 판정, `600512_Logic.md`(→`600822`)/`600532_Logic.md`(→`600542`)의 Option A 확정 등 이미 내려진 모든 Human 결정/판정은 전혀 변경하지 않는다.
- `600402_NavigationMap.md`의 3개 남은 행(`600410`/`600420`/`600440`) 내용은 번호 갱신 외 변경하지 않는다.
- `600502_NavigationMap_Payment_Confirmation.md`의 두 행(`confirm_payment_from_provider`/`mark_payment_uncertain`) 모두 Scope/설명 텍스트는 번호 외에 변경하지 않는다.

## §4 Required New Behavior

- 9개 폴더, 53개 파일 전부 신규 번호로 존재, 구 번호로는 존재하지 않는다.
- 모든 외부 참조 파일에서 옛 번호(그룹 1-8 42개 + 그룹 9 7개, `600510`/`600430` 특수 처리 포함)가 `\b` 앵커 없는 grep 기준 0건.
- `600520`이라는 문자열은 오직 `600400_kds_did_implementation/600520_domain_folder_reorganization/` 관련 문맥에서만 등장한다 — 정확히 1곳.
- `000005`/`000007`은 그룹 1-8(42개) 갱신 + 그룹 9(7개) 신규 추가만 되고, DID(그룹 7) 신규 엔트리는 추가되지 않는다.
- `600502_NavigationMap_Payment_Confirmation.md`는 여전히 정확히 2개 행(`600510_.../`, `600540_.../`)만 존재 — 신규 행 추가나 행 누락 없음.

## §5 Verification Requirements

`600923_TestPlan.md` Test A-J 전부 PASS. 특히 Test F.2/F.3(그룹 9 신규 백필, `600502`/`600401` 기존 행 갱신)는 이번 개정에서 새로 추가된 검증 항목이므로 빠짐없이 수행한다.

## §6 Open Items Not Approved In This Contract

### §6.1 (기존, 이월) 도메인별 `ChangeHistory`/`DecisionLog` 신설 여부

`600524_ChangeContract_Domain_Folder_Reorganization.md` §6.1에서 이미 미결.

### §6.2 (기존, 이월) `600404_PlaceTakeoutOrder_Defect_Roadmap.md`의 도메인 소속

`600524_ChangeContract_Domain_Folder_Reorganization.md` §6.2에서 이미 미결.

### §6.3 (기존, 이월, 일부 해소) `600510`/`600530` 두 워크패킷의 색인 백필 시점

`600530`(→`600540`)은 이번 워크패킷에서 색인 백필까지 포함되므로 **해소됨**. `600510`(→`600820`, DID)은 여전히 Stage 2이므로 원칙(Stage 6 ACCEPT 후 별도 워크패킷) 그대로 유지.

## §7 Risk

Risk level: **MEDIUM**(변경 없음 — 파일 수는 50→53으로 소폭 증가했으나, §0의 근본 충돌이 해소되어 실행 리스크 자체는 낮아짐).

Reasons:

- 순수 문서/파일-조직 변경, `.sql` 무관.
- §0 충돌 해소로 "이미 ACCEPT된 감사 문서와 새 워크패킷이 전역적으로 혼동될 위험"은 사라졌다.
- 남은 리스크는 이동 파일 수(53개)와 참조 치환 범위(bare-name 포함) — `600520` 워크패킷의 42개보다 규모가 크다는 점, 그리고 `600502`/`600401`의 "기존 행 갱신"이 "신규 행 추가"와 혼동되지 않도록 실행 시 각별한 주의가 필요하다는 점.

Risk controls:

- `600923_TestPlan.md` Test C의 `\b`-없는 grep 방법론.
- Test E — `600520`이 정확히 1곳에만 존재하는지 확인.
- Test F.2/F.3 — 그룹 9의 신규 백필과 `600502`/`600401`의 기존-행-갱신을 구분해 검증.

## §8 Human Boundary Approval

Human 승인이 Stage 4 착수 전 필요하다.

☑ 9개 폴더 rename + 53개 파일 rename을 §1에 명시된 그대로 승인한다(그룹 9가 7개로 정정된 것 포함). (승인일자: 2026-07-14)
☑ 외부 참조 갱신 범위(§1 표 전체, 600520 워크패킷 자신의 내용 갱신 포함)를 승인한다. (승인일자: 2026-07-14)
☑ 000005/000007에 그룹 9(7개) 신규 색인 백필을 승인하고, 600510(DID)은 계속 제외하는 것(§6.3)에 동의한다. (승인일자: 2026-07-14)
☑ 600502_NavigationMap_Payment_Confirmation.md/600401_ChangeHistory.md의 기존 600530 행을 신규 행 추가 없이 번호만 치환하는 방식(§1/§2)에 동의한다. (승인일자: 2026-07-14)

## §9 Stage 4 Instruction If Approved

**§8의 4개 박스가 전부 체크되면 Stage 4를 시작한다.** `600922_Logic.md` §6.1의 4단계 순서(폴더 rename 9개 → 파일 rename 53개 → 내용 치환 → 색인/NavigationMap 갱신)를 그대로 따른다. §0의 번호 충돌 게이트는 이미 해소됐으므로 별도의 사전 선택 절차 없이 바로 진행 가능하다.
