# 600403_DecisionLog.md

Recorded Human decisions for the `600400_kds_did_implementation` module. 재논의 대상 아님 — 향후 세션은 이 로그를 먼저 읽고 이미 결정된 사항을 재검토하지 않는다.

## Decision 1 — 전수 문서 조사 폐기, 결함-기반 문서 연결 방식 채택

전수 문서 조사 방식을 폐기한다. 대신 결함을 하나 고칠 때마다 그 근거가 된 원본 설계 문서(900xxx 등)를 해당 변경건의 `Overview.md`에 링크하고, `600401_ChangeHistory.md`에 무엇을/왜 고쳤는지 기록하는 방식으로 문서-코드 연결을 자연스럽게 구축한다. 연결이 확인된 문서는 "살아있는 문서"로 남고, 끝까지 연결 안 되는 문서는 자연스럽게 고아 문서 후보로 드러난다 — 별도 전수 검증 작업을 만들지 않는다. (`000701_Guide_Controlled_AI_Development_Pipeline.md` §35와 함께 확정)

## Decision 2 — 도메인 폴더 재편 (`600520_domain_folder_reorganization`, 2026-07-14)

`600400_kds_did_implementation/`의 11개 워크패킷을 6개 도메인 폴더로 분리한다(상세: `600522_Logic_Domain_Folder_Reorganization.md`). 확정된 하위 결정:

(a) `600402_NavigationMap.md`는 도메인별로 분리하되, 5개 신규 도메인 폴더에는 Readme + NavigationMap만 신설한다 — `ChangeHistory`/`DecisionLog` 신설 여부는 별도 미결(§6.1, `600527_Audit.md` Open Item (a)).
(b) `000005`/`000007`은 이번 기회에 전수 백필한다(신규 47건) — 기존에 대부분 미색인 상태였던 것을 정정.
(c) `600400_Readme`는 이름/본문을 DID 언급 없이 정정한다(3개 워크패킷만 남았으므로).
(d) `600510_did_display_state_overload_and_legacy_defect`는 물리적으로만 이동하고, 색인/NavigationMap 등재는 그 워크패킷 자체가 Stage 6 ACCEPT에 도달할 때까지 보류한다 — 아직 Stage 2(승인 대기)인 워크패킷을 완료된 것처럼 색인하지 않기 위함.

이 결정들은 재논의 대상 아님 — `600524_ChangeContract.md` §8 Human Boundary Approval 4개 항목 승인 완료, `600527_Audit.md`(Stage 6 ACCEPT)로 이행 완료.
