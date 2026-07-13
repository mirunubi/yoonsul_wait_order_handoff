"""Shared cloud target constants for CatchMenu tooling.

This module is intentionally small and declarative. It centralizes the
approved Supabase cloud project identity used by safety checks before any
cloud-facing automation is allowed to proceed.
"""

EXPECTED_PROJECT_REF = "upzthfwhtvazfftxnyfu"
EXPECTED_HOST = "db.upzthfwhtvazfftxnyfu.supabase.co"
EXPECTED_POOLER_USERNAME = "postgres.upzthfwhtvazfftxnyfu"
