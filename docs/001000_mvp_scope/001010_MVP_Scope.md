# 001010_MVP_Scope

## Included

## MVP Mode Principle

The MVP is not one universal mode for every store.

The MVP must support at least:

- Mini Kiosk Only.
- Waiting + Mini Kiosk.
- Waiting + Staff/Admin handoff.

Store Agent / Printer is an optional extension.

POS API integration is later or store-specific.

Our payment-performing mode is not the early default.

### Customer Entry

- QR, NFC, or direct URL entry into a store context
- Store identification from URL or code
- Basic session start or join flow

### Waiting Session

- Create waiting session
- Join existing waiting session using a simple token or link
- Track customer display name, party size, and contact placeholder if needed
- Show waiting status

### Menu Browsing

- Menu categories
- Menu item list
- Menu item detail
- Photos
- Descriptions
- Base prices
- Option groups and options
- Multilingual display fields, initially data-driven rather than automatic translation

### Cart

- Add item to cart
- Select item options
- Change quantity
- Remove item
- View estimated total

### Order Candidate

- Convert cart to order candidate
- Keep order candidate tied to waiting session and store
- Allow edits before staff confirmation
- Mark candidate status

### Staff Handoff

- Staff waiting list view
- Staff order candidate review
- Staff table assignment
- Staff confirmation
- Manual POS entry support through a clear summary view

### Mini Kiosk Mode

- Store menu browsing without mandatory waiting management
- Cart and order candidate creation for staff confirmation
- No payment processing

## Deferred

- POS API integration
- Payment processing
- Membership, coupons, or points
- KDS automation
- Inventory deduction
- Staff payroll or HR integration
- Franchise-level store operations
- AI recommendations
- Agent server automation
- Advanced multi-tenant administration

## MVP Roles

- Customer: joins waiting context, browses menu, creates order candidate
- Staff: manages waiting sessions, assigns table, confirms candidate
- Store Admin: seeds or edits store/menu data in a minimal internal way

## MVP Status Model

Waiting session:

- `created`
- `waiting`
- `called`
- `seated`
- `cancelled`

Order candidate:

- `draft`
- `submitted`
- `under_review`
- `confirmed`
- `cancelled`

## MVP Scope Consolidation Cross-Reference

- MVP scope is consolidated in `docs/01000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md`.
- Package/feature flag boundary is defined in `docs/01000_mvp_scope/001050_Boundary_MVP_Package_And_Feature_Flag.md`.
- Store-type adoption sequence is defined in `docs/01000_mvp_scope/001060_MVP_Store_Type_Adoption_Sequence.md`.
- `docs/22000_implementation_planning/022060_Boundary_Mvp_Implementation_Non_Goals.md` defines implementation non-goals and must remain aligned with `01040`.
