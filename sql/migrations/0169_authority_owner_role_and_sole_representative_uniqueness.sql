-- 0169: Authority owner role and active SOLE representative uniqueness
-- Workpacket: 601500 operational authority foundation
-- Scope: DDL/role boundary only. No functions, seeds, or existing objects are rewritten.

create unique index if not exists uq_ler_sole_active
  on catchmenu_hq.legal_entity_representatives (legal_entity_id)
  where representation_mode = 'SOLE'
    and is_active = true;

do $$
begin
  if not exists (
    select 1
    from pg_roles
    where rolname = 'catchmenu_authority_owner'
  ) then
    create role catchmenu_authority_owner
      nologin
      bypassrls;
  end if;
end
$$;

grant usage on schema catchmenu_hq
  to catchmenu_authority_owner;

grant select, insert, update, delete
  on table
    catchmenu_hq.owners,
    catchmenu_hq.legal_entities,
    catchmenu_hq.legal_entity_person_roles,
    catchmenu_hq.legal_entity_representatives
  to catchmenu_authority_owner;

grant catchmenu_authority_owner to postgres;
