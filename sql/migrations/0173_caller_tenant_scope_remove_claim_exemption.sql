-- Workpacket: 602010
-- Runtime Gate RG-01 rerun; remove claim-based service_role exemption.
-- Scope: catchmenu_common.assert_caller_tenant_scope(uuid) only.

BEGIN;

CREATE OR REPLACE FUNCTION catchmenu_common.assert_caller_tenant_scope(p_tenant_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO pg_catalog
AS $gate$
DECLARE
  v_caller_tenant_id uuid;
BEGIN
  v_caller_tenant_id := catchmenu_common.current_tenant_id();
  IF v_caller_tenant_id IS NULL
     OR v_caller_tenant_id IS DISTINCT FROM p_tenant_id THEN
    RAISE EXCEPTION USING
      ERRCODE = '42501',
      MESSAGE = 'caller tenant scope denied';
  END IF;
END;
$gate$;

REVOKE ALL ON FUNCTION catchmenu_common.assert_caller_tenant_scope(uuid) FROM PUBLIC;

COMMIT;
