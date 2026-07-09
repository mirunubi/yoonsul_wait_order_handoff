# 000714_Readme_Implementation_Lifecycle_Governance.md

## 상태: 대상 폴더 전체 격리 완료

`docs/600000_implementation_lifecycle/` 폴더 전체(`600100_readme_governance/`, `601000_olm_model/`, `602000_source_map/`, `603000_ai_handoff/`, `604000_workpackets/`, `605000_pos_gateway_package/`, `606000_evidence_diff/`, `607000_repair_closeout/`, `608000_release_gate/`, `609000_archive_review/`, 그리고 `600000_Index_Implementation_Lifecycle.md` 자체)는 `docs/990000_legacy_quarantine/`로 이동되었으며, 원래 위치의 폴더 셸은 삭제되었다. 아래 번호 체계 및 소유자 규칙은 이제 과거 기록으로만 유지되며, 더 이상 활성 폴더 구조를 설명하지 않는다.

## 이 폴더의 목적

`600000_implementation_lifecycle/`은 구현의 기획, 설계, 승인, 실행, 검증, 감사, 릴리즈 및 아카이브 전 과정을 일관된 문서 체계로 관리한다. 이 문서는 해당 체계의 번호, 소유권, 파일 추가 및 Index 등록 규칙을 정의한다.

## 파일 번호 체계 규칙

- `600000`은 구현 생명주기 전체 Index에 사용한다.
- `600100` 단위 번호는 거버넌스처럼 상위 기능 영역을 구분한다.
- `601000` 이후 번호는 OLM 모델, 소스 맵, 핸드오프, 작업 패키지, 구현 패키지, 증거, 릴리즈 및 아카이브 영역에 배정한다.
- 개별 문서는 소속 폴더의 번호 범위 안에서 중복되지 않는 번호를 사용한다.
- OLM 문서는 필요할 때 `OV`, `LG`, `MD` 식별자를 사용하여 각각 Overview, Logic, Module을 구분한다.
- 번호와 파일명은 생성 후 의미를 임의로 변경하거나 다른 문서에 재사용하지 않는다.

## 각 폴더의 소유자와 역할

| 폴더 | 소유자 | 역할 |
|---|---|---|
| 601000_olm_model/ | Cursor / Claude / Codex | Overview, Logic, Module 작성 기준 제공 |
| 602000_source_map/ | Claude Code | 소스 파일과 의존성 추적 |
| 603000_ai_handoff/ | Claude | AI 도구 간 핸드오프 계약 관리 |
| 604000_workpackets/ | Human / Claude | 승인 가능한 작업 단위 정의 |
| 605000_pos_gateway_package/ (605100~605200만 현재 위치) | Codex | 승인된 구현 패키지와 단계별 결과 관리 |
| 606000_evidence_diff/ | Claude Code | 구현 및 검증 증거 보존 |
| 607000_repair_closeout/ | Codex / Claude Code | 수리 결과와 종료 검증 관리 |
| 608000_release_gate/ | Human / Claude | Scope 통과 조건과 승인 관리 |
| 609000_archive_review/ | Human | 최종 검토 및 아카이브 승인 |

소유자는 해당 폴더 산출물의 정확성, 최신성, 승인 상태를 책임진다. 공동 소유 폴더에서는 파이프라인 순서에 따라 작성자, 검토자, 승인자의 책임을 분리한다.

## 파일 추가 규칙

1. 새 파일은 목적에 맞는 폴더와 번호 범위를 먼저 확정한다.
2. Overview, Logic, Module 문서는 `601000_olm_model/`의 해당 템플릿을 따른다.
3. 파일 헤더에 Status, Lifecycle, Owner, Last Updated를 기록한다.
4. 기존 번호를 재사용하거나 기존 문서를 덮어쓰지 않는다.
5. 구현 파일은 승인된 Governance와 허용 파일 범위를 벗어나지 않아야 한다.
6. 구현 완료는 검증 증거와 Module 문서가 모두 존재할 때만 인정한다.
7. 파일 추가 후 소유자 검토와 Human 승인을 거친다.

## Index 등록 의무

모든 공식 문서는 `600000_Index_Implementation_Lifecycle.md`에 번호, 파일명, 상태, 위치 및 역할을 등록해야 한다. Index에 등록되지 않은 파일은 초안이나 작업 산출물일 수는 있으나 공식 구현 생명주기 문서로 인정하지 않는다. 파일의 상태나 위치가 변경되면 Index도 같은 변경 단위에서 갱신한다.
