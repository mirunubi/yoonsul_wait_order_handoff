# 000001_Md_Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 Encoding Rule

- All Markdown documents must be UTF-8.
- Korean text must be preserved without encoding corruption.
- Special characters must not be rewritten through unsafe encodings.
- All documentation tasks must preserve UTF-8.
- All tasks must include the Korean/encoding safety block defined in `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md`.
- Cursor must not edit Korean body text.
- Do not use PowerShell Set-Content.
- Do not normalize encoding.
- Do not run formatters.

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for mandatory Korean documentation and encoding safety rules.

## 2 Heading Rule

- Use clear Markdown headings.
- Prefer numbered major sections for governance and design documents.
- A document should expose its purpose near the top.

## 3 Authority Rule

- One document should have one clear authority purpose.
- Avoid duplicate documents with overlapping ownership.
- Move or rename existing documents instead of recreating them when possible.

## 4 Implementation Boundary Rule

- Keep implementation details out of BM patent documents.
- BM patent documents must remain high-level.
- Implementation details belong in development design docs, not BM patent boundary docs.
- Documentation may describe architecture, boundaries, and intent.
- Documentation must not silently become SQL, migration, app, or API implementation.
- Documentation tasks must not create SQL, migrations, app code, Supabase functions, package changes, or runtime implementation.

## 5 Move And Index Rule

- All new documentation files must use six-digit prefixes according to `docs/000002_Naming_Rules.md`.
- Do not create new 4-digit-prefixed or 5-digit-prefixed docs.
- Existing 5-digit-prefixed docs are migration targets and must not be renamed except through an approved migration batch.
- Update `000005_Index_Document_Number.md` whenever documents move, are created, or are renamed.
- Update `000007_Map_Full_Directory.md` whenever folders move, are created, or are renamed.
- After moving or renaming docs, update `docs/000005_Index_Document_Number.md` and `docs/000007_Map_Full_Directory.md`.
- Internal titles should match the filename meaning after a move.

## 5.0 Six-Digit Canonical Numbering Rule

- The canonical documentation numeric prefix is six digits.
- The canonical Markdown filename format is `xxxxxx_DocumentType_Title_In_English_Title_Case.md`.
- `xxxxxx` is the mandatory six-digit numeric prefix.
- New governed Markdown documents must use six-digit prefixes.
- New five-digit-prefixed Markdown documents are not allowed.
- Existing five-digit-prefixed documents remain valid only as migration targets.
- The default migration mapping for existing five-digit numbers is `xxxxx` to `0xxxxx`.
- Actual migration must happen only in a separate approved rename batch with a dry-run manifest.

## 5.0.1 Unified Docs And SOP Numbering Rule

- `docs` and `sop` use the same six-digit numbering discipline.
- `docs` is for development documentation, architecture, specifications, boundaries, implementation lifecycle, validation, security, financial control, and audit documentation.
- `sop` is for operation SOP, system SOP, temporary QC SOP, field training SOP, and repeated operating procedure documentation.
- SOP documents must not be mixed into `docs` except for explicit cross-reference stubs when approved.
- Recipe SOP, operation SOP, and system SOP documents must be separated from development documentation.

## 5.1 Readme Index 000005 000007 Authority Rule

- A folder `Readme` is the folder-level semantic authority.
- A folder `Readme` explains what the folder is responsible for, what it owns, and what it does not own.
- A folder `Readme` should describe folder purpose, ownership boundary, internal number band, subfolder policy, add rule, and move rule.
- An `Index` document is a document list, number list, controlled registry, or reference catalog.
- Subfolder `Index` documents must not be created by default.
- Project-wide document numbers and document lists are centrally governed by `docs/000005_Index_Document_Number.md`.
- The complete directory structure is centrally governed by `docs/000007_Map_Full_Directory.md`.
- Subfolders should use `Readme` by default.
- Subfolder `Index` documents are allowed only when a bounded controlled registry is required.
- If `000005`, `000007`, and a folder `Readme` disagree, stop file movement and update the governance documents together.

## 5.2 Folder Readme Mandatory Rule

- Every governed top-level documentation folder should have a `Readme` document.
- The `Readme` document should use the folder number and domain name.
- The `Readme` document should define the local semantic boundary before new documents are added.
- A folder without a `Readme` should not receive high-volume move batches until its ownership boundary is clear.

## 5.3 Index Concentration Rule

- Do not create local index files just to list files in a folder.
- Use `000005_Index_Document_Number.md` for the project-wide document number registry.
- Use `000007_Map_Full_Directory.md` for the project-wide directory map.
- Create local `Index` documents only for controlled registries, evidence catalogs, reference catalogs, exception logs, or traceability maps that need independent review.

## 5.4 DocumentType Group Rule

DocumentType values are divided into three groups.

**Group A — General Documents (used across all docs bands)**

- `Readme` — 폴더 진입점. 폴더 역할, 소유 경계, 번호 밴드 설명. 폴더당 1개.
- `Index` — 번호/문서/항목 목록. 중앙 등록 카탈로그.
- `Guide` — 프로젝트/시스템 설명, 온보딩, 선행학습, 사용 지침. 절차 없음. 읽고 이해하는 문서.
- `Policy` — 반드시 지켜야 할 규칙, 금지사항, 운영 정책. must/must not 언어 중심.
- `Spec` — 공식 계약, 인터페이스 스펙, 스키마 스펙, 프로토콜 스펙, 이벤트 페이로드 계약.
- `Implementation` — 코드 작성 전 기술 설계. API 행동, 런타임 모델, 데이터 모델, 인터페이스 설계.
- `Boundary` — 시스템 소유권 경계, 통합 경계, 책임 분리. 무엇을 소유하고 소유하지 않는지.
- `Governance` — 문서 체계, 번호 체계, 명명 표준, 메타 규칙. Policy보다 상위. 체계 자체를 정의.
- `Diagram` — 구조도, 흐름도, 관계도 (텍스트 기반 포함).
- `Map` — 디렉토리 구조, 파일 트리, 시스템 배치 구조. Diagram보다 공간/위치 중심.
- `Matrix` — 매핑 표, 상태 표, 책임 표, 호환성 표. 셀 기반 대응 관계.
- `Register` — 공식 등록부. 코드, 이벤트, 결정, 예외 목록. 인스턴스 등록. 규칙 정의 아님.
- `Template` — 반복 작성 양식.
- `Assessment` — 평가, 위험 분석, 적합성 분석, 비교 검토. Report보다 주관적 판단 포함.

**Group B — Execution / Work Documents**

- `Plan` — 실행 전 계획. 작업 계획, 테스트 계획, 배치 계획. 실행 전 문서.
- `Checklist` — 실행 전후 확인 항목 목록. Plan보다 세부 체크 항목 중심.
- `SOP` — 반복 가능한 운영/시스템 절차. 순서 있는 절차.
- `Runbook` — 장애, 예외, 복구, 운영 대응 절차. SOP보다 긴급/예외 상황 중심.
- `Report` — 실행 후 결과, 검증 결과, 배치 closeout 보고. Plan의 결과물.
- `Evidence` — 검증 증거, raw log, 증거 패킷. Report보다 원시 데이터/증거 중심.
- `Audit` — 감사, 독립 리뷰, 컴플라이언스 검토 결과. 제3자 시점 또는 공식 감사.
- `ADR` — 아키텍처 결정 기록. 결정 시점의 맥락, 선택지, 결정 이유를 보존.
- `WorkPackage` — 구현/검증 작업 묶음 게이트. Plan+Checklist+Evidence를 묶는 컨테이너.
- `Closeout` — 묶음 종료, 승인, 닫힘 기록. WorkPackage나 배치의 공식 종료 선언.

**Group C — Implementation Lifecycle Only (600000 band)**

- `Overview` — 구현 WorkPackage 전 맥락. 어떤 파일(Flutter/SQL/RPC/API)을 함께 봐야 하는지. **일반 설명 문서에 사용 금지.**
- `Logic` — 구현 변경 로직. 상태 전이, 예외 처리, 권한, 감사 로직 상세. **구현 전용.**
- `Module` — 구현 결과 기록. 소스 파일, 테스트 결과, 알려진 위험, 롤백 노트. **구현 후 기록.**

Overview/Logic/Module은 코드 구현 WorkPackage 전용입니다. 프로젝트 설명, 온보딩, 시스템 설명 문서에는 Guide를 사용합니다. A small work package may include Overview, Logic, and Module sections inside one document. Core flow, financial, payment, POS, KDS, audit, and security documents should prefer separate Overview, Logic, and Module files when traceability matters.

## 5.5 Status Tag Rule

- Development lifecycle documents should declare status near the top when practical.
- Allowed status values are `Draft`, `In_Progress`, `Implemented`, `Verified`, `Archived`, and `Deprecated`.
- Lifecycle documents should identify the lifecycle class when practical: `Overview`, `Logic`, or `Module`.
- Owner may be `TBD` when ownership is not yet assigned.

Example:

```text
Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: YYYY-MM-DD
```

## 5.6 Evidence And Report Relationship Rule

- `Report` documents should be used for execution results, batch closeout, or completion findings.
- `Evidence` documents hold raw logs, proof packets, or recorded validation artifacts linked from Report or Audit.
- `Audit` documents record independent review or compliance inspection results.
- Pull request descriptions and code review records should be linked as Evidence from `Module` documents when relevant.
- Do not use `Overview` as a generic plan or explanation document. Use it only as a formal implementation lifecycle context map (Group C).

## 5.7 Conflict Resolution Rule

- If folder `Readme`, local `Index`, `000005`, and `000007` disagree, treat `00005` and `00007` as the central governance sources until a correction task resolves the conflict.
- Do not continue broad file movement while a document-number or directory-map conflict is unresolved.
- Correction tasks should update the smallest necessary governance files and report the decision.

## 5.8 Six-Digit Migration Safety Rule

Before any five-digit to six-digit migration:

1. Generate a dry-run rename manifest.
2. Detect duplicate target paths.
3. Detect case-only conflicts.
4. Detect path length risks.
5. Detect existing six-digit files.
6. Detect bad four-digit and five-digit files.
7. Detect Korean filename risks.
8. Detect internal link references to old paths.
9. Prepare an update plan for `docs/000005_Index_Document_Number.md`.
10. Prepare an update plan for `docs/000007_Map_Full_Directory.md`.
11. Prepare an update plan for folder `Readme` files.
12. Do not stage or commit unless explicitly instructed.

Migration batches must not modify runtime implementation, SQL, migrations, app code, Supabase functions, or package files.

## 6 Quality Rule

- Do not create placeholder nonsense documents.
- Each document should clearly state its scope and current status when appropriate.
- Keep documents readable by both humans and machine-assisted tools.

## 7 External Project Rule

- `yoonsul_os` may be referenced only as external context.
- Do not merge `yoonsul_wait_order_handoff` implementation into `yoonsul_os`.
- Do not index `yoonsul_os` files as internal project documents.

## 8 Current Status

Status: active root governance rule.
