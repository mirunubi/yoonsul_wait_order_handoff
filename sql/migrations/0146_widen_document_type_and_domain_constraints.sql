-- 0146_widen_document_type_and_domain_constraints.sql
-- Purpose: Widen catchmenu_knowledge.documents' chk_doc_type and
--          chk_doc_domain constraints to allow the document_type/
--          domain values used by the knowledge-document registration
--          files (0113, 0119, 0132, 0134, 0135), discovered continuing
--          the SQL migration verification pass (2026-07-10). Same
--          rationale as 0140/0145: these error_key/document rows have
--          zero prior DB precedent under any existing value (confirmed
--          0 rows in catchmenu_knowledge.documents before this batch)
--          and were confirmed as genuinely distinct document
--          types/domains, not redundant with the existing allowed
--          sets.
--          chk_doc_type gains: SPEC, GUIDE, REPORT, EVIDENCE.
--          chk_doc_domain gains (lowercase, matching the existing
--          all-lowercase convention): architecture, flutter, project,
--          operation. The 5 consumer files were updated in the same
--          pass to use lowercase domain literals for consistency.
-- Depends on: 0033_create_knowledge_gap_rpc.sql (original constraints),
--             0113_create_api_spec_docs.sql (consumer),
--             0119_create_edge_function_integration.sql (consumer),
--             0132_create_device_registry_enhanced.sql (consumer),
--             0134_create_technology_credit_package.sql (consumer),
--             0135_create_flutter_mvp_start_package.sql (consumer)
-- Note: numbered 0146 (next free slot after 0145), but must be applied
--       before 0113 to satisfy 0113's INSERT. No integer exists between
--       0112 and 0113, so this file requires an out-of-band apply ahead
--       of its number, same established pattern as 0140/0145.

alter table catchmenu_knowledge.documents
  drop constraint if exists chk_doc_type;

alter table catchmenu_knowledge.documents
  add constraint chk_doc_type check (
    document_type in (
      'SOP','POLICY','CHECKLIST','RUNBOOK','INCIDENT_GUIDE',
      'DECISION_RECORD','WORK_PACKAGE','TRAINING_GUIDE','FAQ',
      'SPEC','GUIDE','REPORT','EVIDENCE'
    )
  );

alter table catchmenu_knowledge.documents
  drop constraint if exists chk_doc_domain;

alter table catchmenu_knowledge.documents
  add constraint chk_doc_domain check (
    domain in (
      'order','payment','kds','session','delivery','inventory',
      'staff','device','agent','recovery','customer','security',
      'system',
      'architecture','flutter','project','operation'
    )
  );
