# 0020 User Flow

## Customer Flow

```text
Open QR/NFC/URL
  -> Store context loaded
  -> Create or join waiting session
  -> Browse menu
  -> Open item detail
  -> Select options
  -> Add to cart
  -> Review cart
  -> Submit order candidate
  -> Wait for seating
  -> See table assignment / staff confirmation status
```

## Staff Flow

```text
Open staff view
  -> See waiting sessions
  -> Select waiting session
  -> Assign table number
  -> Review submitted order candidate
  -> Confirm or ask customer to adjust
  -> Manually enter confirmed order into POS if needed
```

## Mini Kiosk Flow

```text
Open store menu URL
  -> Browse menu
  -> Add items/options to cart
  -> Submit order candidate
  -> Staff reviews and confirms
```

## Main Handoff Moment

The critical MVP moment happens when staff seats the customer:

1. Staff assigns table number.
2. The waiting session becomes `seated`.
3. The existing order candidate is shown with the table number.
4. Staff confirms the order candidate.
5. Staff manually enters it into POS when required.

## Customer Screens

1. Store landing / session entry
2. Waiting session create / join
3. Waiting status
4. Menu category list
5. Menu item list
6. Menu item detail with options
7. Cart
8. Order candidate submitted status
9. Table assignment / confirmation status

## Staff Screens

1. Staff dashboard
2. Waiting session list
3. Waiting session detail
4. Table assignment panel
5. Order candidate review
6. Confirmation result / POS manual entry summary

## Store Admin Screens

1. Store profile editor
2. Menu category editor
3. Menu item editor
4. Option group and option editor
5. QR/URL setup view

Admin screens can remain basic in the first MVP.

