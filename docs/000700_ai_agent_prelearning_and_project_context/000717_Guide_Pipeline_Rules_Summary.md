# 000717_Guide_Pipeline_Rules_Summary.md

Status: Active
Lifecycle: Guide
Domain: AI Agent Prelearning
Last Updated: 2026-08-10

## §0 용도

새 세션·새 도구(Claude / Claude Code / Codex / Cursor)가 작업 전에 읽는 **규칙 요약**이다.
`000701`(3459줄) / `000001`(543줄) / `000002`(441줄)의 발췌이며, **전문을 대체하지 않는다.**
충돌 시 항상 전문이 우선한다.

## §1 절대 금지 (위반 시 즉시 반려)

1. **Stage 7 없이 Stage 8을 시작하지 않는다.** 구현 착수 전 해당 ChangeContract의
   `§10 Approval State`에서 Stage 7이 승인 상태인지 확인한다. `대기`면 멈춘다. (`000701` §10)
2. **1단계(업무규칙 선언)는 Human 전담이다. AI가 대신 쓰지 않는다.** (`000701` §47.1)
3. **`sql/migrations/` 기존 파일을 수정·삭제하지 않는다.** 불변 경계를 넘은 것은
   forward migration(신규 번호)으로만 정정한다. (`000701` §14.5)
4. **frozen historical snapshot을 소급 수정하지 않는다.**
   `Report`/`Register`/`Matrix` + `Batch`/`Dry_Run`/`Closeout`/`Manifest` 계열은
   당시 사실의 기록이다. 일괄 치환 대상에서 제외한다. (`000001` §5.10)
5. **인코딩을 정규화하지 않는다.** UTF-8 유지, BOM 추가 금지, 줄바꿈 형식은 파일마다
   확인해 그대로 유지한다(저장소에 CRLF/LF가 섞여 있다). PowerShell `Set-Content` 금지,
   포매터 실행 금지. (`000001` §1)
6. **Cursor에게 한글 본문 편집을 시키지 않는다.** 대용량 스캔·grep·트리 탐색은 적합하나,
   한글 본문이 포함된 파일의 내용 작성·수정은 Codex 또는 Claude Code에게 맡긴다.
   실제 파일 손상 사례가 있다(`900160~179` 계열, 2026-07-11). (`000001` §1, `000701` §34.1)
7. **산출물의 원작자를 그 산출물의 검증자로 배정하지 않는다.** 검증 지시문 서두에
   "원작자: OOO, 따라서 검증자는 OOO 제외"를 명시한다. 검증자가 1명이면
   그 1명의 사각지대가 그대로 남는다. (`000701` §35, §37)

## §2 착수 순서 (6단계 나선, `000701` §47.1)

```text
[1단계 직전] §48 증거수집 — A~E 5단계 분류, 표 형식 필수
[1단계] 업무규칙 선언        — Human 전담, AI 위임 불가
[2단계] ERD 초안             — Cursor 조사 + Claude Code
[3단계] 인접 도메인 대조      — 반드시 새 세션(사전 맥락 0)
[4단계] 설계문서 정합화        — §46 근거 문서 목록 의무 첨부
[5단계] SQL 구현 + 이중검증
[6단계] 나선 종료 판정        — Human
```

- §48 5단계 분류: A 문서만 / B SQL 객체 존재 / C 문서-SQL 일치 /
  D 로컬 실행 검증 / E 호출자·권한까지 검증
- **"문서가 존재하므로 구현된 것으로 간주" 금지.** 단계를 건너뛰고 결론 내리지 않는다. (§48.3)
- 3단계는 2단계를 쓴 세션에서 하면 앵커링으로 무효다. 새 대화창을 연다.

## §3 근거 의무 (`000701` §46)

Overview에 **참고한 관련 MD 파일 전체 목록**을 경로와 함께 기록한다.
의도적으로 배제한 문서가 있으면 배제 사유를 한 줄 남긴다.
"이 문서들을 다 보고 썼는지"를 목록만으로 사후 확인할 수 있어야 한다.

## §4 파일명 (`000002` §1.1)

```text
xxxxxx_DocumentType_Title_In_English_Title_Case.md
```

- 6자리 필수. 4·5자리 신규 생성 금지.
- DocumentType은 `000001` §5.4의 승인 목록에서만 고른다. 없는 타입을 임의로 만들지 않는다.
- 예외는 lifecycle 9종이 `docs/implementation_evidence/<change_id>/` 안에 있을 때뿐이다.
  Stage 7 완료 시 6자리로 archive한다. (`000001` §5.4.2)

## §5 문서 변경 시 동반 갱신 (`000001` §5 / §5.11)

문서를 생성·이동·개명하면 **같은 커밋에서** 함께 갱신한다.

| 대상 | 시점 |
|---|---|
| `000005_Index_Document_Number.md` | 문서 생성·이동·개명 시 |
| `000007_Map_Full_Directory.md` | 폴더 변경 시. 단 현재 파일 단위 트리를 유지 중이므로 파일 추가 시에도 갱신 |
| 폴더 Readme | 폴더 역할·범위·번호밴드가 바뀔 때 |

하나만 고치고 멈추면 미완이다.

## §6 현재 상태 — 반드시 알아야 할 것

- **`600000\_implementation\_lifecycle` 대역은 NON-AUTHORITATIVE BY DEFAULT다.**
  provenance 재검증 전까지 설계 근거로 인용하지 않는다.
- **0-A(`601500`)는 AUTHORITY SUSPENDED.** 0-A-2 / 0-A-3 / 0-B는 HOLD.
- 감사 finding·raw evidence는 증거로 유효하나, APPROVE/COMPLETE 판정은 역사적 기록일 뿐이다.
- 판정 전문: `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md`

## §7 전문을 읽어야 하는 경우

아래에 해당하면 이 요약으로 판단하지 말고 원문을 연다.

| 상황 | 문서 |
|---|---|
| 결제·정산·환불·원장 관련 변경 | `000701` §16, §17 |
| RLS·권한·`SECURITY DEFINER` 함수 작성 | `000701` §10.5, `601503` §9 |
| 폴더 번호 변경, 대량 이동, 5→6자리 이관 | `000001` §5.8, §5.9 |
| Stage 11 감사 수행 | `000701` §13 |
| 이 요약과 원문이 어긋나 보일 때 | 해당 원문 전체 |

## §8 근거 문서 목록 (§46)

| 문서 | 인용 |
|---|---|
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §6.3, §10, §14.5, §46, §47.1, §48 |
| `000001_Md_Rules.md` | §1, §5, §5.4, §5.4.2, §5.10, §5.11 |
| `000002_Naming_Rules.md` | §1.1, §4 |
| `600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | §1.1, §1.2, §1.3, §1.4 |
