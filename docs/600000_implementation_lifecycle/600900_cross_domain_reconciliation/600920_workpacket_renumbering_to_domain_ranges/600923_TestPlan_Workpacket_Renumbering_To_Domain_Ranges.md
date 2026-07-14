# 600923_TestPlan_Workpacket_Renumbering_To_Domain_Ranges.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude chat role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`workpacket_renumbering_to_domain_ranges`

## Authority

- `600921_Overview_Workpacket_Renumbering_To_Domain_Ranges.md`
- `600922_Logic_Workpacket_Renumbering_To_Domain_Ranges.md`(최종 확정 — §0 충돌 해소, 53개 파일)

## §0 Preflight — 번호 충돌 해소 확인 (더 이상 Stage 4 게이트 아님, 그러나 재확인은 필수)

`600922_Logic.md` §0.2에서 확인한 대로, Human 결정 1(옵션 b)로 `600530`의 목표 번호가 `600520`에서 `600540`으로 재조정되면서 `600520_domain_folder_reorganization/`과의 충돌이 원천적으로 사라졌다. Stage 4 착수 전 아래만 재확인한다(더 이상 별도 Human 선택을 기다리는 게이트가 아니라, 단순 사실 재확인):

```bash
ls docs/600000_implementation_lifecycle/600500_payment_confirmation/
find docs -iname "600540*"
grep -c "600540" docs/000005_Index_Document_Number.md docs/000007_Map_Full_Directory.md
```

기대: `600540`으로 시작하는 파일/폴더가 실행 직전까지도 여전히 0건(다른 워크패킷이 그 사이 그 번호를 선점하지 않았는지 최종 확인).

## §1 Test A — 폴더 rename 9개 완전성

```powershell
git status --short
```

기대: 9개 폴더 전부 `R  <구경로> -> <신경로>` 표시. Test 대상:

1. `600480→600510` 2. `600460→600610` 3. `600490→600620` 4. `600450→600710` 5. `600470→600720` 6. `600330→600810` 7. `600510→600820` 8. `600430→600910` 9. `600530→600540`

## §2 Test B — 파일 rename 53개 완전성

`600922_Logic.md` §1 전체 표(그룹 1-9)를 순회하며 각 신규 파일이 실존하고 각 구 파일명이 더 이상 존재하지 않음을 확인. 그룹 9는 이전(4개, 미완성 전제) 대비 **7개로 정정**됐음을 특히 확인(`600531`–`600537` → `600541`–`600547`, `600535`/`600536`/`600537`도 포함).

기대: 53/53 PASS, 0 미스매치.

## §3 Test C — `\b` 앵커 없는 grep으로 잔존 옛 번호 0건 확인 (핵심 검증)

```bash
cd docs
for old in 600480 600481 600482 600483 600484 600485 600486 600487 \
           600460 600461 600462 600463 600464 600465 600466 600467 \
           600490 600491 600492 600493 600494 600495 600496 600497 \
           600450 600451 600452 600453 600454 600455 600456 600457 \
           600470 600471 600472 600473 600474 600475 600476 600477 \
           600330 \
           600431 600432 600433 600434 600435 600436 600437 \
           600530 600531 600532 600533 600534 600535 600536 600537; do
  hits=$(grep -rl "$old" --include="*.md" . 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "RESIDUAL: $old found in:"
    echo "$hits"
  fi
done
```

**방법론 주의(`600921_Overview.md` §4)**: `\b` 단어경계 앵커는 이 프로젝트의 `숫자_제목` 명명 패턴에서 실제 참조를 놓친다 — 이 Test는 앵커 없는 순수 리터럴 매칭만 사용한다.

**`600510`/`600430`/`600520`은 이 리스트에서 제외**(특수 케이스, §4에서 별도 처리): `600510`은 rename 후 `confirm_payment_from_provider`의 신규 번호로만 등장해야 하는 특수 케이스. `600430`은 신규 슬롯 재사용 없음. `600520`은 **이제 §0 해소로 특수 취급이 필요 없다** — `600520_domain_folder_reorganization/`만 계속 정상적으로 등장하면 되고(변경 없음), 다른 어떤 문맥에서도 `600520`이 새로 등장하지 않아야 한다(즉 `600520`도 이제 일반 Test C 리스트에 사실상 준한다 — 다만 기존의 정당한 `600520_domain_folder_reorganization/` 언급까지 "0건"으로 착각하지 않도록 Test E에서 명시적으로 분리 확인).

기대: 위 44개 숫자 전부 0건.

## §4 Test D — `600510`/`600430` 특수 케이스 확인

### §4.1 `600510`

```bash
grep -rl "600510" docs/600000_implementation_lifecycle/600800_did_implementation/ --include="*.md"
```

기대: 0건.

### §4.2 `600430`

```bash
grep -rl "600430" docs --include="*.md"
```

기대: 0건.

## §5 Test E — `600520` 정상 상태 확인 (충돌 해소 후 최종 형태)

```bash
find docs/600000_implementation_lifecycle -maxdepth 2 -type d -iname "600520*"
```

기대: **정확히 1개** — `600400_kds_did_implementation/600520_domain_folder_reorganization/`만. `600500_payment_confirmation/` 산하에는 `600520`으로 시작하는 어떤 폴더도 없어야 한다(대신 `600540_mark_payment_uncertain_overload_ambiguity/`가 있어야 함).

```bash
grep -rl "600521\|600522\|600523\|600524" docs --include="*.md"
```

기대: `600520_domain_folder_reorganization/` 내부의 `600521`–`600524` 4개 파일 자신 + 그 파일들을 참조하는 문서(`600402`류 bare 언급 등)만 나와야 하며, `600500_payment_confirmation/` 산하 어디에도 `600521`–`600524`가 등장하지 않아야 한다(그룹 9는 `600541`–`600544`를 쓰므로).

## §6 Test F — 색인/NavigationMap 갱신 완전성

### §6.1 그룹 1-8 (42개, 기존 엔트리 치환)

`600922_Logic.md` §4의 42개 파일에 대해 `000005`/`000007` 1:1 대조.

### §6.2 그룹 9 (7개, 신규 백필 — DID와 다른 처리)

```bash
for f in 600541_Overview_Mark_Payment_Uncertain_Overload.md \
         600542_Logic_Mark_Payment_Uncertain_Overload.md \
         600543_TestPlan_Mark_Payment_Uncertain_Overload.md \
         600544_ChangeContract_Mark_Payment_Uncertain_Overload.md \
         600545_Module.md 600546_Verification.md 600547_Audit.md; do
  c=$(grep -c "$f" docs/000005_Index_Document_Number.md)
  # c는 정확히 1이어야 함(신규 백필) — DID(600820 계열)와 달리 여기는 0이면 FAIL
done
```

기대: 그룹 9의 7개 전부 `000005`/`000007`에 정확히 1회씩 신규 등재. DID(`600820`, 그룹 7)는 여전히 0건이어야 함(대조군).

### §6.3 `600502_NavigationMap_Payment_Confirmation.md`/`600401_ChangeHistory.md` 기존 행 갱신 확인 (신규 항목이 아닌 특수 케이스)

이미 존재하는 `600530_mark_payment_uncertain_overload_ambiguity/` 행(NavigationMap)과 `mark_payment_uncertain_overload_ambiguity` 완료 기록 행(ChangeHistory)이 **새로 추가되지 않고 기존 행의 번호만 치환**됐는지 확인 — 치환 전후 행 개수가 동일해야 한다(NavigationMap 2행 유지: `600510_.../`, `600540_.../`; ChangeHistory 행 개수 불변, 번호만 갱신).

## §7 Test G — `600441`/`600442`/`600446`/`600402`/`600403`/`600404` bare 언급 갱신 확인

각 파일에서 옛 번호(§3 리스트) 0건, 신규 번호가 정확히 등장하는지 대조.

## §8 Test H — `000701`/`000053`/`000054`/`000002` 갱신 확인

관련 섹션(§37/§41.3/§44.3, §G, basename-collision 예시)의 옛 번호가 신규 번호로 정확히 바뀌었는지 대조.

## §9 Test I — `600520` 워크패킷 자신(`600521`–`600527`) 내용 갱신 확인

`600922_Logic.md` §5에 따라 7개 파일 본문의 옛 번호 언급이 신규 번호로 바뀌었는지 확인 — 단, 이 7개 파일 자신의 파일명/폴더명은 그대로 `600520_domain_folder_reorganization/600521`–`600527`이어야 한다(§0.2로 이 폴더는 이제 rename 대상이 전혀 아님).

## §10 Test J — sql/migrations 무변경, Flutter/런타임 무변경

```bash
git diff --stat -- sql/migrations/
git status --short -- sql/migrations/
```

기대: 둘 다 빈 결과.

## §11 Acceptance Criteria

1. §0 재확인 통과(`600540` 여전히 빈 슬롯).
2. 9개 폴더 rename 전부 완료(Test A).
3. 53개 파일 rename 전부 완료(Test B, 그룹 9는 7개).
4. `\b` 없는 grep으로 옛 번호(600510/600430/600520 제외 44개) 잔존 0건(Test C).
5. `600510`/`600430` 특수 케이스 검증 통과(Test D).
6. `600520`이 `600400_kds_did_implementation/` 산하에만 정확히 1곳 존재(Test E).
7. `000005`/`000007`: 그룹 1-8(42개) 치환 + 그룹 9(7개) 신규 백필 완료, DID(그룹 7)는 여전히 미색인(Test F).
8. `600502_NavigationMap_Payment_Confirmation.md`/`600401_ChangeHistory.md`의 기존 `600530` 행이 신규 추가 없이 번호만 치환(Test F.3).
9. bare 언급 갱신 확인(Test G/H/I).
10. `sql/migrations`/Flutter/런타임 무변경(Test J).

## §12 Known Non-Blocking Open Items

- `600404_PlaceTakeoutOrder_Defect_Roadmap.md`의 도메인 소속 문제(`600524_ChangeContract_Domain_Folder_Reorganization.md` §6.2, 아직 미결)는 이번 워크패킷 범위 밖.
- `authorize_kds_release()` 오버로드 정리는 별도 워크패킷(`600537_Audit.md` Open Item (d) 참고), 이번 재편과 무관.
