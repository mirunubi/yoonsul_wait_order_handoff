-- Workpacket: 601700

BEGIN;

-- D-1
ALTER TABLE catchmenu_hq.owners RENAME TO persons;

-- D-2
ALTER TABLE catchmenu_hq.legal_entity_person_roles
  RENAME COLUMN owner_id TO person_id;

-- D-3
ALTER TABLE catchmenu_hq.legal_entity_representatives
  RENAME COLUMN owner_id TO person_id;

-- D-4
ALTER TABLE catchmenu_hq.persons
  RENAME COLUMN owner_name TO person_name;

-- D-5
ALTER TRIGGER trg_owners_updated_at ON catchmenu_hq.persons
  RENAME TO trg_persons_updated_at;

-- D-6
ALTER TABLE catchmenu_hq.legal_entity_person_roles
  RENAME CONSTRAINT legal_entity_person_roles_owner_id_fkey
  TO legal_entity_person_roles_person_id_fkey;

-- D-7
ALTER TABLE catchmenu_hq.legal_entity_representatives
  RENAME CONSTRAINT legal_entity_representatives_owner_id_fkey
  TO legal_entity_representatives_person_id_fkey;

-- D-8
ALTER INDEX catchmenu_hq.owners_pkey RENAME TO persons_pkey;

-- D-9
ALTER INDEX catchmenu_hq.idx_lepr_owner RENAME TO idx_lepr_person;

-- D-10
ALTER TABLE catchmenu_hq.persons DROP COLUMN is_active;

-- D-11
ALTER TABLE catchmenu_hq.legal_entity_person_roles
  DROP CONSTRAINT chk_lepr_ownership_percent;

-- D-12
ALTER TABLE catchmenu_hq.legal_entity_person_roles
  DROP COLUMN ownership_percent;

-- D-13
COMMENT ON TABLE catchmenu_hq.persons IS
  'Canonical natural persons who hold operational or legal authority for legal entities.';

COMMIT;
