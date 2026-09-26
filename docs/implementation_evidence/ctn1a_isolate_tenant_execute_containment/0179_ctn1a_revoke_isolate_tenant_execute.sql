-- Migration: 0179_ctn1a_revoke_isolate_tenant_execute.sql
-- Workpacket: 601513
-- Containment CTN-1a: enforce 601505 §4.1.1 (no call path) by revoking
-- EXECUTE on isolate_tenant and detect_threat from PUBLIC, anon, authenticated.
-- Explicit exception to 601902 §5 (EXECUTE ACL). Human approved 2026-09-21.
-- Function bodies, signatures, owners, and proconfig are unchanged.
-- Not closed: indirect path via SECURITY DEFINER callers (CTN-1b).
-- Idempotent: REVOKE of a privilege that is not granted is a no-op without error.

BEGIN;

REVOKE EXECUTE ON FUNCTION catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)
  FROM PUBLIC, anon, authenticated;

REVOKE EXECUTE ON FUNCTION catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)
  FROM PUBLIC, anon, authenticated;

COMMIT;
