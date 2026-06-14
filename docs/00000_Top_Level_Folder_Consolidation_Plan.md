# 00000_Top_Level_Folder_Consolidation_Plan

<< docs-only · folder architecture plan · Wave 1 applied · Wave 2 applied · Wave 3-B applied · Wave 4-B applied >>
> **Wave 1 applied:** `04000_store_runtime_pos_kds_operations` parent created; four subfolders moved (2026-06-09).
> **Wave 2 applied:** `05000_customer_handoff_and_implementation_readiness` parent created; three subfolders moved (2026-06-09).
> **Wave 3-B applied:** `10000_runtime_foundation_and_cross_room_architecture` parent created; ten subfolders moved; `README.md` renamed in `10000_store_runtime_room_framing` (2026-06-09).
> **Wave 4-B applied:** sixteen stale duplicate files archived under `13000_security_runtime_test_catalog/archive_duplicate_review` (5) and `14000_pos_provider_integration_strategy/archive_duplicate_review` (11); `14000` numbered README added; `00007` synced (2026-06-09).
> **04900 band correction applied:** `13000_security_runtime_test_catalog` moved to `04900_security_runtime_test_catalog`; archive subfolder renamed to `04999_archive_duplicate_review`; README renamed to `04900_Security_Runtime_Test_Catalog_Readme.md` (2026-06-09).



## 1 Executive Summary

### Why consolidation is needed

The `docs/` tree has accumulated **adjacent numbered top-level folders** created during incremental Cursor normalization waves. Each wave correctly packaged documents, but the result is **over-fragmentation**: related store-runtime, handoff, foundation, and provider-strategy documents now sit as sibling top-level folders instead of under a small set of architectural axes.

### Over-fragmented areas

- **04000 band:** `04000`, `04100`, `04200`, `04300` (4 top-level folders)
- **05000 band:** `05000`, `05100`, `05200` (3 top-level folders)
- **10000 band:** `10000_foundation_static_catalog_package`, `10000_static_catalog_runtime_planning`, `10000_store_runtime_room_framing`, `10100`, `10400`, `10500`, `10600`, `10700`, `10720`, `10800` (**11 top-level folders**)
- **13000 band:** `13000_app_api_projection`, `13000_security_runtime_test_catalog` (**2 folders**; `14000` duplicate overlap resolved in Wave 4-B)
- **40000 band:** already consolidated (`10703`~`10720` legacy numbers preserved)

**Top-level folders inspected:** 38

### Proposed top-level bands

| Band | Proposed parent folder | Subfolder count (proposed) |
| --- | --- | --- |
| A | `docs/04000_store_runtime_pos_kds_operations/` | 4 |
| B | `docs/05000_customer_handoff_and_implementation_readiness/` | 3 |
| C | `docs/10000_runtime_foundation_and_cross_room_architecture/` | 11 |
| D | `docs/13000_pos_provider_integration_strategy/` | 3 (needs_review for app projection) |
| E | `docs/40000_menu_taxonomy_and_ai_classification/` | leave as-is |

**Consolidation candidates:** 21 folder moves / reviews across bands A?�D

## 2 Current Top-Level Folder Inventory

| folder_path | direct_file_count | subfolder_count | total_md_in_tree | detected_number_band | likely_domain | notes |
| --- | --- | --- | --- | --- | --- | --- |
| `docs/00100_project_foundation/` | 12 | 1 | 24 | 00100 | General / other | 00450_documentation_governance |
| `docs/01000_mvp_scope/` | 33 | 0 | 33 | 01000 | General / other | flat |
| `docs/03000_saas_runtime/` | 17 | 0 | 17 | 03000 | General / other | flat |
| `docs/04000_store_runtime_pos_kds_operations/04000_kds_integration_kitchen_continuity/` | 7 | 0 | 7 | 04000 | Store runtime / KDS / kitchen continuity | flat |
| `docs/04000_store_runtime_pos_kds_operations/04100_menu_availability_soldout_runtime/` | 6 | 0 | 6 | 04100 | Menu availability / soldout runtime | flat |
| `docs/04000_store_runtime_pos_kds_operations/04200_kds_operation_payment_recovery_boundary/` | 10 | 0 | 10 | 04200 | KDS operation / payment recovery | flat |
| `docs/04000_store_runtime_pos_kds_operations/04300_pos_provider_adapter_governance/` | 18 | 0 | 18 | 04300 | POS provider adapter governance | flat |
| `docs/05000_customer_handoff_and_implementation_readiness/05000_customer_handoff_flow/` | 6 | 0 | 6 | 05000 | Customer handoff flow | flat |
| `docs/05000_customer_handoff_and_implementation_readiness/05100_implementation_readiness_and_provider_verification/` | 12 | 0 | 12 | 05100 | Implementation readiness / provider verification | flat |
| `docs/05000_customer_handoff_and_implementation_readiness/05200_pos_payment_provider_and_kiosk_reuse/` | 7 | 0 | 7 | 05200 | POS payment provider / kiosk reuse | flat |
| `docs/07000_admin_console/` | 12 | 0 | 12 | 07000 | Admin console | flat |
| `docs/08000_ai_customer_center/` | 10 | 0 | 10 | 08000 | AI customer center | flat |
| `docs/09000_data_model_state_machine/` | 12 | 0 | 12 | 09000 | Data model / state machine | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10000_foundation_static_catalog_package/` | 24 | 0 | 24 | 10000 | Runtime foundation / static catalog | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10000_static_catalog_runtime_planning/` | 35 | 0 | 35 | 10000 | Runtime foundation / static catalog | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10000_store_runtime_room_framing/` | 18 | 0 | 18 | 10000 | Runtime foundation / static catalog | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10100_four_side_platform_skeleton/` | 7 | 0 | 7 | 10100 | Four-side platform skeleton | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10400_financial_trust_room/` | 10 | 0 | 10 | 10400 | Financial trust room | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10500_data_governance_room/` | 14 | 0 | 14 | 10500 | Data governance room | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10600_cross_room_plumbing_wiring_insulation/` | 22 | 1 | 39 | 10600 | Cross-room plumbing / wiring / insulation | 10609_financial_regulation_risk_expansion |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10700_security_trust_and_smart_order_control/` | 4 | 0 | 4 | 10700 | Security trust / smart order control | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10720_legal_notice_sop_and_regulatory_control/` | 17 | 0 | 17 | 10720 | Legal notice SOP / regulatory control | flat |
| `docs/10000_runtime_foundation_and_cross_room_architecture/10800_store_onboarding_and_sales_setup_axis/` | 10 | 0 | 10 | 10800 | Store onboarding / sales setup | flat |
| `docs/11000_integration_boundary/` | 32 | 0 | 32 | 11000 | Integration boundary | flat |
| `docs/12000_implementation_mapping/` | 14 | 0 | 14 | 12000 | Implementation mapping | flat |
| `docs/13000_app_api_projection/` | 14 | 0 | 14 | 13000 | App API projection / security test catalog (split) | flat |
| `docs/13000_security_runtime_test_catalog/` | 20 | 0 | 20 | 13000 | App API projection / security test catalog (split) | flat |
| `docs/14000_pos_provider_integration_strategy/` | 27 | 0 | 27 | 14000 | POS provider integration strategy | flat |
| `docs/15000_membership_loyalty/` | 6 | 0 | 6 | 15000 | General / other | flat |
| `docs/17000_ui_screen_composition/` | 14 | 0 | 14 | 17000 | General / other | flat |
| `docs/20000_validation_security_audit/` | 60 | 1 | 70 | 20000 | General / other | foundation_security |
| `docs/21000_financial_security_monitoring_catalog/` | 32 | 0 | 32 | 21000 | General / other | flat |
| `docs/22000_implementation_planning/` | 24 | 0 | 24 | 22000 | General / other | flat |
| `docs/24000_deployment_operations/` | 20 | 0 | 20 | 24000 | General / other | flat |
| `docs/26000_analytics_reporting_bi/` | 6 | 0 | 6 | 26000 | General / other | flat |
| `docs/28000_future_expansion/` | 6 | 0 | 6 | 28000 | General / other | flat |
| `docs/30000_future_saas_modules/` | 10 | 0 | 10 | 30000 | General / other | flat |
| `docs/40000_menu_taxonomy_and_ai_classification/` | 19 | 0 | 19 | 40000 | Menu taxonomy / AI classification | flat |

## 3 Proposed Consolidation Table

| current_folder | proposed_parent_folder | proposed_new_path | action_type | reason | risk_level | references_to_update |
| --- | --- | --- | --- | --- | --- | --- |
| `04000_kds_integration_kitchen_continuity` | `04000_store_runtime_pos_kds_operations` | `docs/04000_store_runtime_pos_kds_operations/04000_kds_integration_kitchen_continuity` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~22 path hits |
| `04100_menu_availability_soldout_runtime` | `04000_store_runtime_pos_kds_operations` | `docs/04000_store_runtime_pos_kds_operations/04100_menu_availability_soldout_runtime` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~20 path hits |
| `04200_kds_operation_payment_recovery_boundary` | `04000_store_runtime_pos_kds_operations` | `docs/04000_store_runtime_pos_kds_operations/04200_kds_operation_payment_recovery_boundary` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~26 path hits |
| `04300_pos_provider_adapter_governance` | `04000_store_runtime_pos_kds_operations` | `docs/04000_store_runtime_pos_kds_operations/04300_pos_provider_adapter_governance` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~42 path hits |
| `05000_customer_handoff_flow` | `05000_customer_handoff_and_implementation_readiness` | `docs/05000_customer_handoff_and_implementation_readiness/05000_customer_handoff_flow` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~20 path hits |
| `05100_implementation_readiness_and_provider_verification` | `05000_customer_handoff_and_implementation_readiness` | `docs/05000_customer_handoff_and_implementation_readiness/05100_implementation_readiness_and_provider_verification` | move_as_subfolder | Recently consolidated from root; folder move only, no file renumbering | low | ~72 path hits |
| `05200_pos_payment_provider_and_kiosk_reuse` | `05000_customer_handoff_and_implementation_readiness` | `docs/05000_customer_handoff_and_implementation_readiness/05200_pos_payment_provider_and_kiosk_reuse` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~58 path hits |
| `10000_foundation_static_catalog_package` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10000_foundation_static_catalog_package` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~158 path hits |
| `10000_static_catalog_runtime_planning` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10000_static_catalog_runtime_planning` | move_as_subfolder | 09660-09990 runtime planning lane; belongs under 10000 band but distinct from foundation package | medium | ~82 path hits |
| `10000_store_runtime_room_framing` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10000_store_runtime_room_framing` | move_as_subfolder | 10200-10350 store room framing axis; contains README.md (non-canonical name) and 10141 stray file | medium | ~42 path hits |
| `10100_four_side_platform_skeleton` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10100_four_side_platform_skeleton` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~50 path hits |
| `10400_financial_trust_room` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10400_financial_trust_room` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~68 path hits |
| `10500_data_governance_room` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10500_data_governance_room` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~92 path hits |
| `10600_cross_room_plumbing_wiring_insulation` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10600_cross_room_plumbing_wiring_insulation` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~250 path hits |
| `10700_security_trust_and_smart_order_control` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10700_security_trust_and_smart_order_control` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~16 path hits |
| `10720_legal_notice_sop_and_regulatory_control` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10720_legal_notice_sop_and_regulatory_control` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~108 path hits |
| `10800_store_onboarding_and_sales_setup_axis` | `10000_runtime_foundation_and_cross_room_architecture` | `docs/10000_runtime_foundation_and_cross_room_architecture/10800_store_onboarding_and_sales_setup_axis` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~66 path hits |
| `13000_app_api_projection` | `13000_pos_provider_integration_strategy` | `docs/13000_pos_provider_integration_strategy/13000_app_api_projection` | needs_review | App/API projection is a different architectural axis than POS provider strategy; may warrant separate top-level band 13100 or stay as sibling subfolder | high | ~152 path hits |
| `13000_security_runtime_test_catalog` | `13000_pos_provider_integration_strategy` | `docs/13000_pos_provider_integration_strategy/13000_security_runtime_test_catalog` | move_as_subfolder | Adjacent numbered package fits proposed parent band | low | ~34 path hits |
| `14000_pos_provider_integration_strategy` | `13000_pos_provider_integration_strategy` | `docs/13000_pos_provider_integration_strategy/14000_pos_provider_integration_strategy` | move_as_subfolder | Canonical POS strategy content; rename parent to 13000 band per proposal; keep as subfolder not merge | medium | ~36 path hits |
| `40000_menu_taxonomy_and_ai_classification` | `40000_menu_taxonomy_and_ai_classification` | `docs/40000_menu_taxonomy_and_ai_classification/40000_menu_taxonomy_and_ai_classification` | leave | Already canonical top-level band E; README exists | low | ~46 path hits |

## 4 10000 Folder Conflict Section

**10000-prefix top-level folder count: 3** (plus 8 additional `10100`~`10800` foundation-adjacent top-level folders)

| folder | direct_md | subfolders | subfolder files | recommended action | notes |
| --- | --- | --- | --- | --- | --- |
| `10000_foundation_static_catalog_package` | 24 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |
| `10000_static_catalog_runtime_planning` | 35 | 0 | 0 | move_as_subfolder | 09660-09990 runtime planning lane; belongs under 10000 band but distinct from foundation package; subs: none |
| `10000_store_runtime_room_framing` | 18 | 0 | 0 | move_as_subfolder | 10200-10350 store room framing axis; contains README.md (non-canonical name) and 10141 stray file; subs: none |
| `10100_four_side_platform_skeleton` | 7 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |
| `10400_financial_trust_room` | 10 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |
| `10500_data_governance_room` | 14 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |
| `10600_cross_room_plumbing_wiring_insulation` | 22 | 1 | 17 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: 10609_financial_regulation_risk_expansion |
| `10700_security_trust_and_smart_order_control` | 4 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |
| `10720_legal_notice_sop_and_regulatory_control` | 17 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |
| `10800_store_onboarding_and_sales_setup_axis` | 10 | 0 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band; subs: none |

### 10000-specific decisions

| Folder | Decision |
| --- | --- |
| `10000_foundation_static_catalog_package` | **move_as_subfolder** under Band C parent |
| `10000_static_catalog_runtime_planning` | **move_as_subfolder** under Band C parent; holds `09660`~`09990` planning lane |
| `10000_store_runtime_room_framing` | **move_as_subfolder** under Band C parent; rename `README.md` ??canonical readme in apply wave |
| Plan archives (`*_Plan.md`) | **leave in place** within subfolders; optional `plans/` subfolder in later wave |
| `10100`~`10800` top-level folders | **move_as_subfolder** ??too dense as top-level; all fit cross-room / foundation architecture |


## 5 13000 Folder Conflict Section

**13000-prefix top-level folder count: 2**

| folder | direct_md | subfolders | recommended action | notes |
| --- | --- | --- | --- | --- |
| `13000_app_api_projection` | 14 | 0 | needs_review | App/API projection is a different architectural axis than POS provider strategy; may warrant separate top-level band 13100 or stay as sibling subfolder |
| `13000_security_runtime_test_catalog` | 20 | 0 | move_as_subfolder | Adjacent numbered package fits proposed parent band |
| `14000_pos_provider_integration_strategy` | 27 | 0 | move_as_subfolder | Canonical POS strategy content; rename parent to 13000 band per proposal; keep as subfolder not merge |

### 13000 / 14000 duplicate file overlap

The following basenames existed in **more than one folder**; Wave 4-B archived stale copies to `archive_duplicate_review/` (canonical index points to `05000` band packages):

| filename | locations | apply note |
| --- | --- | --- |
| `05100_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `13000_security_runtime_test_catalog/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05110_Implementation_Readiness_Backlog_And_Test_Execution_Planning_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `13000_security_runtime_test_catalog/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05120_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `13000_security_runtime_test_catalog/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05130_Evidence_Packet_Template_And_Test_Result_Recording_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `13000_security_runtime_test_catalog/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05140_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `13000_security_runtime_test_catalog/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05150_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05160_Controlled_Implementation_Entry_Gate_And_Build_Authorization_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05170_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05180_POS_Payment_Provider_Integration_Priority_Matrix_And_Openness_Assessment_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05190_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral_Policy.md` | `05100_implementation_readiness_and_provider_verification`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05100` |
| `05200_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse_Policy.md` | `05200_pos_payment_provider_and_kiosk_reuse`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05200` |
| `05210_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary_Policy.md` | `05200_pos_payment_provider_and_kiosk_reuse`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05200` |
| `05220_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary_Policy.md` | `05200_pos_payment_provider_and_kiosk_reuse`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05200` |
| `05230_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary_Policy.md` | `05200_pos_payment_provider_and_kiosk_reuse`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05200` |
| `05240_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel_Policy.md` | `05200_pos_payment_provider_and_kiosk_reuse`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05200` |
| `05250_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping_Policy.md` | `05200_pos_payment_provider_and_kiosk_reuse`, `14000_pos_provider_integration_strategy/archive_duplicate_review` | **archived Wave 4-B** — canonical under `05000/05200` |

### 13000 band recommendation

1. Create top-level `docs/13000_pos_provider_integration_strategy/` with band README.
2. Move `14000_pos_provider_integration_strategy/` as subfolder (keep name initially to avoid file path churn).
3. Move `13000_security_runtime_test_catalog/` as subfolder (`04970`~`05095` test lane; `05100`~`05140` duplicates archived Wave 4-B).
4. **`13000_app_api_projection` ??needs_review:** not POS strategy; options:
   - (a) subfolder under same 13000 band as `app_api_projection` sibling, or
   - (b) separate top-level `13100_app_api_projection` band, or
   - (c) leave at top-level until projection axis is defined.
5. **Do not move `05200` files into 13000/14000 in this plan** ??cross-reference only; duplicates already noted.

## 6 Dense Folder Band Review

### 04000 / 04100 / 04200 / 04300

| Folder | Remain top-level? | Recommendation |
| --- | --- | --- |
| `04000_kds_integration_kitchen_continuity` | No | Subfolder under `04000_store_runtime_pos_kds_operations` |
| `04100_menu_availability_soldout_runtime` | No | Subfolder ??menu availability is store-runtime operational |
| `04200_kds_operation_payment_recovery_boundary` | No | Subfolder ??payment/kitchen recovery is store-runtime |
| `04300_pos_provider_adapter_governance` | No | Subfolder ??adapter governance is store POS/KDS integration ops (distinct from 14000 strategy) |

**Cross-reference risk:** README files in `04200`/`04300` reference sibling folders by current top-level paths.

### 05000 / 05100 / 05200

| Folder | Remain top-level? | Recommendation |
| --- | --- | --- |
| `05000_customer_handoff_flow` | No | Subfolder ??customer handoff entry axis |
| `05100_implementation_readiness_and_provider_verification` | No | Subfolder ??readiness gates extend handoff-to-build |
| `05200_pos_payment_provider_and_kiosk_reuse` | No | Subfolder ??kiosk/provider boundaries support handoff surfaces |

**05200 vs 14000:** `05200` holds canonical `05200`~`05250` kiosk/provider boundary docs under the `05000` band. `14000` holds `05255`~`05410` long-term strategy extensions; stale `05150`~`05250` duplicates were archived to `archive_duplicate_review/` in Wave 4-B.

### 10000 / 10100 / 10400 / 10500 / 10600 / 10700 / 10720 / 10800

These **should not remain top-level** ??they are rooms/axes of the same runtime foundation architecture:

- `10000_*` (3 folders): foundation catalog, runtime planning, store room framing
- `10100`: four-side platform skeleton
- `10400`~`10600`: financial trust, data governance, cross-room plumbing (10600 has `10609_financial_regulation_risk_expansion/` subfolder with 17 files)
- `10700`: security trust / smart order (`10700`~`10702`)
- `10720`: legal notice SOP (`10721`~`10736`)
- `10800`: store onboarding axis (`10800`~`10807`, `10805_01`)

## 7 Proposed Final Directory Tree (Affected Folders Only)

```text
docs/
  04000_store_runtime_pos_kds_operations/
    04000_Store_Runtime_POS_KDS_Operations_Readme.md          [CREATE]
    04000_kds_integration_kitchen_continuity/               [MOVE]
    04100_menu_availability_soldout_runtime/                [MOVE]
    04200_kds_operation_payment_recovery_boundary/          [MOVE]
    04300_pos_provider_adapter_governance/                    [MOVE]
  05000_customer_handoff_and_implementation_readiness/
    05000_Customer_Handoff_And_Implementation_Readiness_Readme.md  [CREATE]
    05000_customer_handoff_flow/                            [MOVE]
    05100_implementation_readiness_and_provider_verification/ [MOVE]
    05200_pos_payment_provider_and_kiosk_reuse/             [MOVE]
  10000_runtime_foundation_and_cross_room_architecture/
    10000_Runtime_Foundation_And_Cross_Room_Architecture_Readme.md [CREATE]
    10000_foundation_static_catalog_package/                [MOVE]
    10000_static_catalog_runtime_planning/                  [MOVE]
    10000_store_runtime_room_framing/                       [MOVE]
    10100_four_side_platform_skeleton/                      [MOVE]
    10400_financial_trust_room/                             [MOVE]
    10500_data_governance_room/                             [MOVE]
    10600_cross_room_plumbing_wiring_insulation/
      10609_financial_regulation_risk_expansion/            [KEEP nested]
    10700_security_trust_and_smart_order_control/           [MOVE]
    10720_legal_notice_sop_and_regulatory_control/          [MOVE]
    10800_store_onboarding_and_sales_setup_axis/            [MOVE]
  13000_pos_provider_integration_strategy/
    13000_POS_Provider_Integration_Strategy_Readme.md         [CREATE or RENAME from 14000 readme]
    13000_app_api_projection/                               [needs_review]
    13000_security_runtime_test_catalog/                    [MOVE]
    14000_pos_provider_integration_strategy/                [MOVE]
  40000_menu_taxonomy_and_ai_classification/                [LEAVE]
    40000_Menu_Taxonomy_And_AI_Classification_Readme.md       [EXISTS]
    10703_... through 10720_...                               [NO RENUMBER in this wave]
```

## 8 Index Impact

### docs/00005_Document_Number_Index.md

- **~350+ table rows** use paths under affected folders (sections 8??1, 19??0, 31??0 per current index).
- Every `docs\<old_top_level>\` prefix must update to `docs\<new_parent>\<old_top_level>\`.
- Section headers (e.g. `## 19 docs/13000_security_runtime_test_catalog`) should become nested paths or be regrouped under band README sections.
- Duplicate index entries for `05100`~`05250` (pointing at `05100`/`05200` packages vs `13000_security`/`14000` copies) need **dedupe review** before or during Wave 4.

### docs/00007_Full_Directory_Map.md

- Tree indentation for ~21 folder branches moves one level deeper.
- Directory Notes section: replace 11 separate top-level bullets with 4 band bullets.
- Root-level governance files (`00005`, `00007`, this plan) stay at `docs/` root.

### README path updates

- 4 new band READMEs (A?�D) to create.
- Existing package READMEs: update Relationship Notes paths only (content wave optional).
- `10000_store_runtime_room_framing/README.md` ??rename to canonical numbered readme in apply wave.

### Stale references risk

| Risk | Severity | Mitigation |
| --- | --- | --- |
| Cross-package README relationship links | Medium | Grep `docs/<folder>` before each wave |
| Inline backtick document references | Medium | Search old folder slug per wave |
| `00005` / `00007` | High | Update in same commit as folder moves |
| Duplicate file basenames (`05100`~`05250`) | High | Separate dedupe wave; do not delete during folder move |

## 9 Apply Recommendation

**Recommendation: apply in waves ??not all at once.**

| Readiness | Bands |
| --- | --- |
| Safe to apply now | **Wave 1 (04000 band)** ??cohesive domain, no duplicate files, 41 files across 4 folders |
| Safe with index sync | **Wave 2 (05000 band)** ??recently organized; low file churn |
| Needs careful ordering | **Wave 3 (10000 band)** ??largest move (11 folders, ~170+ files); 3 competing `10000_*` names |
| Needs user decision | **Wave 4 (13000 band)** ??`13000_app_api_projection` placement + duplicate dedupe with `14000`/`05100`/`05200` |
| Review only | **Wave 5 (40000)** ??already canonical; optional future `107xx` ??`400xx` renumbering is out of scope |

## 10 Wave Proposal

| Wave | Scope | Folders moved | Est. files | Pre-requisites |
| --- | --- | --- | --- | --- |
| **Wave 1** | 04000 consolidation | 4 ??under `04000_store_runtime_pos_kds_operations` | ~41 | Create band README |
| **Wave 2** | 05000 consolidation | 3 ??under `05000_customer_handoff_and_implementation_readiness` | ~25 | Wave 1 optional |
| **Wave 3** | 10000 consolidation | 11 ??under `10000_runtime_foundation_and_cross_room_architecture` | ~170+ | Resolve `10000_store_runtime_room_framing/README.md` |
| **Wave 4** | 13000 consolidation | 2?? ??under `13000_pos_provider_integration_strategy` | ~61+ | **User decision** on `13000_app_api_projection`; dedupe plan for overlaps |
| **Wave 5** | 40000 review | 0 (leave) | 19 | Future renumbering wave if approved |

### Out of scope for this plan

- File content rewrites
- Document number renumbering (`10703`??40003`, etc.)
- Deleting duplicate markdown copies
- Moving `05200` files into `14000`
- Top-level folders outside bands A?�E (e.g. `07000`, `11000`, `20000`) ??stable, not over-fragmented

## 11 Validation Record

- Plan generated from live folder inspection
- No folders moved
- No files moved
- No file contents edited
- No index updates
- No commit performed
