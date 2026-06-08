# 0030 Data Model Draft

## Domain Model

Core domains:

- Store
- Store Access Context
- Waiting Session
- Menu
- Cart
- Order Candidate
- Staff Handoff

## Entity Draft

### Store

Represents one store location.

Fields:

- `id`
- `name`
- `slug`
- `default_language`
- `supported_languages`
- `timezone`
- `created_at`
- `updated_at`

### StoreAccessCode

Represents QR, NFC, or URL entry into the store context.

Fields:

- `id`
- `store_id`
- `code`
- `entry_type`
- `target_mode`
- `is_active`
- `created_at`

`entry_type` examples: `qr`, `nfc`, `url`

`target_mode` examples: `waiting`, `mini_kiosk`

### WaitingSession

Represents a customer or party waiting to be seated.

Fields:

- `id`
- `store_id`
- `session_code`
- `customer_display_name`
- `party_size`
- `status`
- `created_at`
- `called_at`
- `seated_at`
- `cancelled_at`

Statuses:

- `created`
- `waiting`
- `called`
- `seated`
- `cancelled`

### TableAssignment

Represents table assignment at seating.

Fields:

- `id`
- `store_id`
- `waiting_session_id`
- `table_number`
- `assigned_by_staff_id`
- `assigned_at`

### MenuCategory

Represents a group of menu items.

Fields:

- `id`
- `store_id`
- `sort_order`
- `name_i18n`
- `description_i18n`
- `is_active`

### MenuItem

Represents an orderable menu item.

Fields:

- `id`
- `store_id`
- `category_id`
- `name_i18n`
- `description_i18n`
- `photo_url`
- `base_price`
- `is_available`
- `sort_order`

### OptionGroup

Represents a selectable option group for a menu item.

Fields:

- `id`
- `store_id`
- `menu_item_id`
- `name_i18n`
- `min_select`
- `max_select`
- `is_required`
- `sort_order`

### OptionItem

Represents one selectable option.

Fields:

- `id`
- `store_id`
- `option_group_id`
- `name_i18n`
- `price_delta`
- `is_available`
- `sort_order`

### Cart

Represents a customer-editable cart before submission.

Fields:

- `id`
- `store_id`
- `waiting_session_id`
- `status`
- `currency`
- `created_at`
- `updated_at`

Statuses:

- `active`
- `submitted`
- `abandoned`

### CartItem

Represents one configured item in a cart.

Fields:

- `id`
- `cart_id`
- `menu_item_id`
- `quantity`
- `base_price_snapshot`
- `item_name_snapshot_i18n`
- `note`

### CartItemOption

Represents selected options for a cart item.

Fields:

- `id`
- `cart_item_id`
- `option_group_id`
- `option_item_id`
- `option_name_snapshot_i18n`
- `price_delta_snapshot`

### OrderCandidate

Represents the submitted cart for staff review.

Fields:

- `id`
- `store_id`
- `waiting_session_id`
- `cart_id`
- `status`
- `estimated_total`
- `currency`
- `submitted_at`
- `reviewed_by_staff_id`
- `confirmed_at`
- `cancelled_at`

Statuses:

- `draft`
- `submitted`
- `under_review`
- `confirmed`
- `cancelled`

### StaffUser

Represents a store staff account for MVP access.

Fields:

- `id`
- `store_id`
- `display_name`
- `role`
- `is_active`

Roles:

- `staff`
- `manager`

## Minimal Table List

- `stores`
- `store_access_codes`
- `waiting_sessions`
- `table_assignments`
- `menu_categories`
- `menu_items`
- `option_groups`
- `option_items`
- `carts`
- `cart_items`
- `cart_item_options`
- `order_candidates`
- `staff_users`

## Design Notes

- Price and translated names are snapshotted into cart and order candidate records where staff confirmation needs stable review.
- The first MVP can store `*_i18n` fields as JSON objects keyed by language code.
- The first MVP should prefer simple store scoping over complex tenant architecture.
- Manual POS entry is supported by the confirmed order candidate summary.

