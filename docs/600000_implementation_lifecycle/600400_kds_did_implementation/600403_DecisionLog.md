# 600403_DecisionLog.md

Recorded Human decisions for the `600400_kds_did_implementation` module. 재논의 대상 아님 — 향후 세션은 이 로그를 먼저 읽고 이미 결정된 사항을 재검토하지 않는다.

## Decision 1 — 전수 문서 조사 폐기, 결함-기반 문서 연결 방식 채택

전수 문서 조사 방식을 폐기한다. 대신 결함을 하나 고칠 때마다 그 근거가 된 원본 설계 문서(900xxx 등)를 해당 변경건의 `Overview.md`에 링크하고, `600401_ChangeHistory.md`에 무엇을/왜 고쳤는지 기록하는 방식으로 문서-코드 연결을 자연스럽게 구축한다. 연결이 확인된 문서는 "살아있는 문서"로 남고, 끝까지 연결 안 되는 문서는 자연스럽게 고아 문서 후보로 드러난다 — 별도 전수 검증 작업을 만들지 않는다. (`000701_Guide_Controlled_AI_Development_Pipeline.md` §35와 함께 확정)
