# 601747_Evidence_Stage11C_FaultInjection_CrossTenant_Codex.md

Status: Active
Lifecycle: Evidence
Last Updated: 2026-08-24

## Change ID

Workpacket: 601700

## §1 목적

Stage 11A ↔ Stage 11B 불일치의 fault-injection 재현.

`000701` §13.9 및 §14.2 Human Merge Checklist 요건에 따라,
`stores.tenant_id`와 참조된 `merchant_accounts.tenant_id`가 다른 행을 실제로 저장할 수 있는지 disposable PostgreSQL에서 실측한다.

## §2 환경

### §2.1 Disposable 환경

| 항목 | 값 |
|---|---|
| Container | `wp601700_fault_injection` |
| Container ID | `c5076ff08cbaa84a59e7afe55cae094ac34a2d1b56079f45b63feaeed8083e01` |
| Image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| Database | `postgres` |
| Canonical DB와의 관계 | 별도 container · 별도 PostgreSQL instance |
| 종료 후 상태 | `docker rm -f wp601700_fault_injection` 실행, 목록 0건으로 제거 확인 |

구조는 canonical migration 전체를 replay하지 않고 fault-injection에 필요한 최소 구조를 disposable DB에 직접 만들었다.

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA catchmenu_hq;

CREATE TABLE catchmenu_hq.tenants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_name text NOT NULL,
  CONSTRAINT tenants_pkey PRIMARY KEY (id)
);

CREATE TABLE catchmenu_hq.merchant_accounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  merchant_account_name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT merchant_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT fk_merchant_accounts_tenant_id FOREIGN KEY (tenant_id)
    REFERENCES catchmenu_hq.tenants(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT uq_merchant_accounts_tenant UNIQUE (tenant_id)
);

CREATE TABLE catchmenu_hq.stores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  store_code text NOT NULL,
  store_name text NOT NULL,
  store_type text NOT NULL,
  store_status text NOT NULL,
  timezone text NOT NULL,
  merchant_account_id uuid,
  CONSTRAINT stores_pkey PRIMARY KEY (id),
  CONSTRAINT fk_stores_tenant_id FOREIGN KEY (tenant_id)
    REFERENCES catchmenu_hq.tenants(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT chk_stores_type
    CHECK (store_type = ANY (ARRAY['DINE_IN','TAKEOUT','HYBRID','DELIVERY_ONLY'])),
  CONSTRAINT chk_stores_status
    CHECK (store_status = ANY (ARRAY['PREPARING','ACTIVE','SUSPENDED','CLOSED'])),
  CONSTRAINT uq_stores_tenant_code UNIQUE (tenant_id, store_code),
  CONSTRAINT fk_stores_merchant_account_id FOREIGN KEY (merchant_account_id)
    REFERENCES catchmenu_hq.merchant_accounts(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
```

### §2.2 Canonical DB 무변경 증명

canonical 접속은 아래와 같이 read-only로 고정했다.

```powershell
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres
```

| 항목 | 작업 전 | 작업 후 | 동일 |
|---|---:|---:|---|
| `catchmenu_hq.tenants` | 1 | 1 | 예 |
| `catchmenu_hq.stores` | 1 | 1 | 예 |
| `catchmenu_hq.merchant_accounts` | 1 | 1 | 예 |
| `stores WHERE merchant_account_id IS NULL` | 0 | 0 | 예 |
| `default_transaction_read_only` | `on` | `on` | 예 |

## §3 사전 상태

### §3.1 빈 구조 기준선

```text
tenants           0
merchant_accounts 0
stores            0
```

### §3.2 `stores` 제약 전문

실행 SQL:

```sql
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'catchmenu_hq.stores'::regclass
ORDER BY conname;
```

결과:

```text
chk_stores_status
  CHECK ((store_status = ANY (ARRAY['PREPARING'::text, 'ACTIVE'::text, 'SUSPENDED'::text, 'CLOSED'::text])))
chk_stores_type
  CHECK ((store_type = ANY (ARRAY['DINE_IN'::text, 'TAKEOUT'::text, 'HYBRID'::text, 'DELIVERY_ONLY'::text])))
fk_stores_merchant_account_id
  FOREIGN KEY (merchant_account_id) REFERENCES catchmenu_hq.merchant_accounts(id)
fk_stores_tenant_id
  FOREIGN KEY (tenant_id) REFERENCES catchmenu_hq.tenants(id)
stores_pkey
  PRIMARY KEY (id)
uq_stores_tenant_code
  UNIQUE (tenant_id, store_code)
```

`fk_stores_merchant_account_id`는 `merchant_account_id` 단일 컬럼이 존재하는 MerchantAccount ID인지만 검사한다.

### §3.3 2-tenant 정상 대조 상태

```sql
INSERT INTO catchmenu_hq.tenants(id, tenant_name) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-000000000001', 'Tenant A'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-000000000002', 'Tenant B');

INSERT INTO catchmenu_hq.merchant_accounts(id, tenant_id, merchant_account_name) VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-000000000001', 'MA A'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-000000000002', 'MA B');

INSERT INTO catchmenu_hq.stores(
  id, tenant_id, store_code, store_name, store_type, store_status, timezone, merchant_account_id
) VALUES
  ('cccccccc-cccc-cccc-cccc-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-000000000001',
   'A001', 'Store A', 'DINE_IN', 'ACTIVE', 'Asia/Seoul',
   'bbbbbbbb-bbbb-bbbb-bbbb-000000000001'),
  ('cccccccc-cccc-cccc-cccc-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-000000000002',
   'B001', 'Store B', 'DINE_IN', 'ACTIVE', 'Asia/Seoul',
   'bbbbbbbb-bbbb-bbbb-bbbb-000000000002');
```

사전 대조 결과:

| Store | Store tenant | MerchantAccount tenant | `tenant_match` |
|---|---|---|---|
| `cccccccc-cccc-cccc-cccc-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000001` | `t` |
| `cccccccc-cccc-cccc-cccc-000000000002` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `t` |

사전 `tenant_match`는 2행 모두 `t`였다.

## §4 FAULT INJECTION — UPDATE

실행 SQL:

```sql
UPDATE catchmenu_hq.stores
SET merchant_account_id = (
  SELECT id FROM catchmenu_hq.merchant_accounts
  WHERE tenant_id = 'aaaaaaaa-aaaa-aaaa-aaaa-000000000002'
)
WHERE tenant_id = 'aaaaaaaa-aaaa-aaaa-aaaa-000000000001';
```

실행 결과:

```text
UPDATE 1
exit code 0
```

직후 상태:

| Store | Store tenant | MerchantAccount tenant | `tenant_match` |
|---|---|---|---|
| `cccccccc-cccc-cccc-cccc-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `f` |
| `cccccccc-cccc-cccc-cccc-000000000002` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `t` |

교차 tenant UPDATE는 오류 없이 1행에 적용됐다.

## §5 FAULT INJECTION — INSERT

실행 전 canonical CHECK 정의를 조회했고, 유효값 `DINE_IN`과 `ACTIVE`를 사용했다.

```sql
INSERT INTO catchmenu_hq.stores (
  tenant_id, store_code, store_name, store_type, store_status,
  timezone, merchant_account_id
) VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-000000000001',
  'XTEST',
  '교차 테넌트 시험',
  'DINE_IN',
  'ACTIVE',
  'Asia/Seoul',
  (SELECT id FROM catchmenu_hq.merchant_accounts
   WHERE tenant_id = 'aaaaaaaa-aaaa-aaaa-aaaa-000000000002')
);
```

실행 결과:

```text
INSERT 0 1
exit code 0
```

생성된 Store ID:

```text
adb0fc68-ad87-4407-93e0-d0facbb3712b
```

교차 tenant INSERT는 오류 없이 1행을 생성했다.

## §6 사후 상태

실행 SQL:

```sql
SELECT s.id, s.tenant_id AS store_tenant,
       ma.tenant_id AS ma_tenant,
       (s.tenant_id = ma.tenant_id) AS tenant_match
FROM catchmenu_hq.stores s
LEFT JOIN catchmenu_hq.merchant_accounts ma ON ma.id = s.merchant_account_id
ORDER BY s.id;
```

결과:

| Store | Store tenant | MerchantAccount tenant | `tenant_match` |
|---|---|---|---|
| `adb0fc68-ad87-4407-93e0-d0facbb3712b` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `f` |
| `cccccccc-cccc-cccc-cccc-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000001` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `f` |
| `cccccccc-cccc-cccc-cccc-000000000002` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `aaaaaaaa-aaaa-aaaa-aaaa-000000000002` | `t` |

```text
tenant_match = f: 2행
```

## §7 대조군 — FK 작동 확인

실행 SQL:

```sql
UPDATE catchmenu_hq.stores
SET merchant_account_id = '00000000-0000-0000-0000-000000000000'
WHERE tenant_id = 'aaaaaaaa-aaaa-aaaa-aaaa-000000000001';
```

실행 결과 전문:

```text
ERROR:  23503: insert or update on table "stores" violates foreign key constraint "fk_stores_merchant_account_id"
DETAIL:  Key (merchant_account_id)=(00000000-0000-0000-0000-000000000000) is not present in table "merchant_accounts".
SCHEMA NAME:  catchmenu_hq
TABLE NAME:  stores
CONSTRAINT NAME:  fk_stores_merchant_account_id
LOCATION:  ri_ReportViolation, ri_triggers.c:2599
psql exit code: 3
```

SQLSTATE는 `23503`이다. FK는 존재하지 않는 MerchantAccount ID를 거부했다.

## §8 판정

**D-1 CONFIRMED.**

실측 근거:

1. 자기 tenant의 MerchantAccount를 참조한 초기 2행은 모두 `tenant_match=t`였다.
2. 교차 tenant UPDATE가 `UPDATE 1`로 성공했다.
3. 교차 tenant INSERT가 `INSERT 0 1`로 성공했다.
4. 사후 `tenant_match=f` 행이 2건 존재했다.
5. 존재하지 않는 MerchantAccount ID는 동일 FK가 SQLSTATE `23503`으로 거부했다.

따라서 FK 자체는 작동하지만 Store tenant와 MerchantAccount tenant의 일치는 검사하지 않는다.

## §9 Status

Evidence only. 판정 권한 없음.

이 문서는 Stage 12 Human Merge Checklist의 입력이다.
