-- Workpacket: 601700

BEGIN;

-- D-14
CREATE TABLE catchmenu_hq.merchant_accounts (
  id                     uuid        NOT NULL DEFAULT gen_random_uuid(),
  tenant_id              uuid        NOT NULL,
  merchant_account_name  text        NOT NULL,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT merchant_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT fk_merchant_accounts_tenant_id
    FOREIGN KEY (tenant_id)
    REFERENCES catchmenu_hq.tenants(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- D-15
ALTER TABLE catchmenu_hq.merchant_accounts
  ADD CONSTRAINT uq_merchant_accounts_tenant UNIQUE (tenant_id);

-- D-16
CREATE TRIGGER trg_merchant_accounts_updated_at
  BEFORE UPDATE ON catchmenu_hq.merchant_accounts
  FOR EACH ROW EXECUTE FUNCTION catchmenu_common.set_updated_at();

-- D-17
ALTER TABLE catchmenu_hq.merchant_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE catchmenu_hq.merchant_accounts FORCE ROW LEVEL SECURITY;

-- D-18
ALTER TABLE catchmenu_hq.stores ADD COLUMN merchant_account_id uuid;

-- D-19
ALTER TABLE catchmenu_hq.stores
  ADD CONSTRAINT fk_stores_merchant_account_id
  FOREIGN KEY (merchant_account_id)
  REFERENCES catchmenu_hq.merchant_accounts(id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

-- D-20
CREATE INDEX idx_stores_merchant_account_id
  ON catchmenu_hq.stores (merchant_account_id);

-- D-21
COMMENT ON TABLE catchmenu_hq.merchant_accounts IS
  'CatchMenu SaaS contract and management account. One-to-one with tenant.';

COMMENT ON COLUMN catchmenu_hq.merchant_accounts.tenant_id IS
  'Owning tenant. NOT NULL and UNIQUE; this column alone enforces the 1:1 relationship.';

COMMENT ON COLUMN catchmenu_hq.stores.merchant_account_id IS
  'Structural parent merchant account. Nullable in this contract; NOT NULL is deferred (C-1).';

-- M-1
INSERT INTO catchmenu_hq.merchant_accounts (tenant_id, merchant_account_name)
SELECT id, tenant_name FROM catchmenu_hq.tenants;

-- M-2
UPDATE catchmenu_hq.stores s
SET merchant_account_id = ma.id
FROM catchmenu_hq.merchant_accounts ma
WHERE ma.tenant_id = s.tenant_id;

COMMIT;
