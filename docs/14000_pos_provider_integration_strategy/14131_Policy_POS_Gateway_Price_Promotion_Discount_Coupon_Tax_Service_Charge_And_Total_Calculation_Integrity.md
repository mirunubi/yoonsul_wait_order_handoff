# 14131_Policy_POS_Gateway_Price_Promotion_Discount_Coupon_Tax_Service_Charge_And_Total_Calculation_Integrity

## 1. Purpose

This document defines the price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy for the POS Gateway.

The POS Gateway must not treat price calculation as a simple sum of menu items.

In real store operation, the final payable amount may be affected by:

- base menu price;
- option and modifier price;
- set/combo price;
- time-based price;
- store-specific override;
- promotion;
- coupon;
- membership benefit;
- discount;
- tax rule;
- service charge;
- delivery or packaging fee;
- rounding;
- payment method restriction;
- POS provider calculation behavior.

If the gateway calculates one amount but the POS, payment provider, receipt, or settlement report calculates another, the store may face customer disputes, accounting mismatch, refund errors, settlement variance, and tax reporting risk.

This policy exists to ensure that:

- price calculation is deterministic and versioned;
- gateway totals match POS totals or approved variance rules;
- promotions, discounts, coupons, tax, and service charges are controlled;
- customer-visible totals match chargeable totals;
- rounding rules are explicit;
- price mismatches fail closed before payment where possible;
- cancellation/refund uses the original calculation evidence;
- kiosk and table ordering flows inherit the same calculation boundary.

---

## 2. Scope

This policy applies to all amount calculation behavior that affects POS Gateway transactions, including:

- menu base price;
- option/modifier price delta;
- set/combo price;
- store-specific price override;
- channel-specific price;
- time-based promotion;
- coupon;
- membership discount;
- manual discount;
- staff discount;
- service charge;
- packaging fee;
- delivery fee where connected to POS total;
- tax-included and tax-excluded calculation;
- rounding;
- split payment;
- partial cancellation;
- partial refund;
- settlement amount;
- receipt amount;
- accounting export amount;
- customer-visible total.

This document governs total calculation integrity before order submission, payment, cancellation, refund, receipt creation, and reconciliation.

---

## 3. Core Principle

The POS Gateway must preserve amount truth across the full transaction lifecycle.

For every order, the gateway must be able to prove:

```text
what item prices were used
what modifier prices were used
which promotion rules applied
which coupon rules applied
which discount rules applied
which tax rules applied
which service charges applied
which rounding rule applied
which total was shown to customer
which total was sent to POS
which total was paid
which total appeared on receipt
which total was settled
which total was refunded or cancelled
```

If these cannot be aligned or explained, the order must be blocked, restricted, or manually reviewed.

---

## 4. Calculation Ownership Model

The system must define who owns final total calculation.

Possible calculation ownership models:

| Model | Description |
|---|---|
| `gateway_authoritative` | Gateway calculates final total and POS accepts it |
| `pos_authoritative` | POS calculates final total and gateway must match or defer |
| `hybrid_gateway_precalc_pos_confirm` | Gateway calculates preview, POS confirms final amount |
| `payment_authoritative` | Payment provider amount is authoritative for charge evidence |
| `manual_authoritative` | Staff/POS operator manually confirms final amount |
| `unsupported_uncertain` | No reliable authority exists |

For production automation, calculation ownership must be explicitly configured.

Unknown calculation ownership must block automated payment or POS write.

---

## 5. Calculation Scope

Calculation rules must be scoped.

Required scope dimensions:

```text
tenant_id
store_id
provider_code
adapter_version
order_channel
menu_version_id
mapping_version_id
price_version_id
promotion_version_id
discount_rule_version_id
coupon_rule_version_id
tax_rule_version_id
service_charge_rule_version_id
payment_method
business_day
effective_from
effective_until
```

A rule verified for one store, provider, or channel must not automatically apply elsewhere.

---

## 6. Price Versioning

All production prices must be versioned.

Required price version fields:

```text
price_version_id
tenant_id
store_id
menu_item_id
option_id
modifier_id
base_price
price_delta
currency
tax_included_flag
source_system
effective_from
effective_until
approved_by
status
```

Orders must retain the price version used at the time of calculation.

Price changes must not mutate historical order totals.

---

## 7. Customer-Visible Price Policy

The customer-visible price must match the chargeable price unless a legally and operationally approved adjustment flow exists.

Customer-visible price surfaces may include:

- kiosk screen;
- QR/table ordering page;
- mobile ordering page;
- staff tablet;
- receipt preview;
- cart total;
- payment confirmation screen.

The system must not show one amount and charge another without explicit recalculation confirmation.

If price changes while a customer cart is open, the system must either:

- preserve the original quoted price within allowed policy;
- require cart refresh before payment;
- show recalculated amount clearly;
- block payment until the customer confirms the changed total.

---

## 8. Base Price Integrity

Base price integrity requires:

- gateway base price matches active price version;
- active price version matches POS price or approved override exists;
- price source is known;
- currency is known;
- tax inclusion behavior is known;
- effective date is valid;
- inactive item price cannot be used for new order;
- stale template price cannot become active without verification.

Base price mismatch must block production order write unless an approved exception applies.

---

## 9. Modifier Price Integrity

Modifier price integrity requires:

- modifier price delta is versioned;
- modifier price delta maps to POS modifier price;
- required modifier behavior is known;
- free modifier allowance is known;
- maximum selectable quantity is enforced;
- repeated modifier price behavior is defined;
- modifier discountability is known;
- modifier tax treatment is known.

Modifier price mismatch must block the affected modifier or route to manual review.

---

## 10. Set and Combo Price Integrity

Set/combo price calculation must define:

- bundle base price;
- included components;
- optional components;
- upgrade price delta;
- excluded components;
- discount interaction;
- tax treatment;
- receipt representation;
- cancellation/refund representation;
- POS representation.

Set/combo totals must be reproducible from stored calculation evidence.

A set/combo may not be represented differently between gateway and POS unless reconciliation rules explicitly support it.

---

## 11. Promotion Rule Policy

Promotions must be versioned and scoped.

Promotion rule fields:

```text
promotion_rule_id
promotion_version_id
tenant_id
store_id
promotion_type
eligible_items
eligible_order_channels
eligible_payment_methods
start_at
end_at
weekday_scope
time_scope
minimum_order_amount
maximum_discount_amount
stacking_policy
tax_interaction
status
```

Promotions must not apply silently outside their scope.

Promotion behavior must be tested against POS calculation behavior when POS is authoritative.

---

## 12. Discount Rule Policy

Discounts must be controlled and auditable.

Discount types may include:

- fixed amount discount;
- percentage discount;
- item-level discount;
- order-level discount;
- staff discount;
- manager override discount;
- membership discount;
- promotion discount;
- coupon discount;
- manual goodwill discount.

Discount rule fields:

```text
discount_rule_id
discount_type
discount_scope
discount_value
maximum_discount_amount
eligible_items
eligible_customer_group
eligible_channel
approval_required_flag
stacking_policy
rounding_policy
tax_interaction
status
```

Manual discounts must create an audit event and approval record where required.

---

## 13. Coupon Policy

Coupons must be treated as financial modifiers.

Coupon rules must define:

- coupon identity;
- issuer;
- eligible tenant/store;
- eligible item/order scope;
- minimum amount;
- maximum benefit;
- usage count limit;
- customer eligibility;
- expiration;
- stackability;
- cancellation behavior;
- refund behavior;
- settlement/accounting treatment.

Coupon application must be linked to the order and retained for dispute and reconciliation.

Coupon use must not be lost when order is sent to POS.

---

## 14. Membership Benefit Policy

Membership benefits must be separated from generic discounts.

Membership benefit calculation must define:

- membership program;
- member identity reference;
- eligible store;
- eligible menu;
- benefit type;
- benefit amount;
- points used;
- points earned;
- coupon interaction;
- refund restoration behavior;
- cancellation restoration behavior;
- settlement treatment.

If the POS cannot represent membership benefit directly, the gateway must record how the benefit was translated.

---

## 15. Tax Calculation Policy

Tax calculation must be explicit.

Required tax rule fields:

```text
tax_rule_id
tax_rule_version_id
tax_category
tax_rate
tax_included_flag
rounding_policy
eligible_item_scope
eligible_store_scope
effective_from
effective_until
source_system
status
```

Tax calculation must consider:

- item tax category;
- modifier tax category;
- discount tax interaction;
- coupon tax interaction;
- service charge taxability;
- packaging fee taxability;
- rounding;
- receipt display.

Tax mismatch must block official accounting export or trigger reconciliation case.

---

## 16. Service Charge and Fee Policy

Service charges and fees must be versioned.

Possible fees:

- packaging fee;
- delivery fee;
- table service charge;
- late-night fee;
- platform service fee;
- small order fee;
- disposable item fee;
- manual adjustment fee.

Fee rules must define:

```text
fee_rule_id
fee_type
fee_amount
fee_rate
eligible_scope
taxable_flag
receipt_display_flag
refundability
cancellation_behavior
settlement_treatment
effective_from
status
```

Fees must not be hidden from customer-visible total where legally or operationally required.

---

## 17. Rounding Policy

Rounding rules must be explicit and reproducible.

Rounding may apply to:

- item subtotal;
- modifier subtotal;
- discount amount;
- tax amount;
- order total;
- payment amount;
- refund amount;
- settlement amount.

Required rounding fields:

```text
rounding_policy_id
rounding_scope
rounding_method
rounding_unit
priority_order
provider_behavior_reference
status
```

Rounding mismatch must be classified and reconciled.

---

## 18. Stacking Policy

When multiple promotions, discounts, coupons, and membership benefits apply, stacking must be deterministic.

Stacking policy must define:

- allowed combinations;
- priority order;
- maximum total discount;
- item-level vs order-level order;
- coupon before membership or membership before coupon;
- tax before discount or discount before tax;
- manual override behavior;
- POS provider limitation.

Ambiguous stacking must fail closed.

---

## 19. Total Calculation Snapshot

Each order must retain a total calculation snapshot.

Required snapshot fields:

```text
calculation_snapshot_id
order_id
tenant_id
store_id
menu_version_id
mapping_version_id
price_version_id
promotion_version_id
discount_rule_version_id
coupon_rule_version_id
tax_rule_version_id
service_charge_rule_version_id
subtotal_amount
discount_amount
coupon_amount
membership_benefit_amount
tax_amount
service_charge_amount
fee_amount
rounding_adjustment_amount
final_total_amount
customer_visible_total_amount
pos_submitted_total_amount
payment_requested_amount
currency
calculated_at
calculation_engine_version
```

The snapshot must be immutable after payment or POS write.

Corrections must create adjustment records.

---

## 20. POS Total Verification

Before production POS write or payment execution, the gateway must verify total consistency.

Verification may compare:

- gateway calculated total;
- POS preview total if available;
- POS response total;
- payment request total;
- receipt total;
- settlement total.

If POS preview is unavailable, the gateway must rely on verified mapping and rule compatibility.

If POS response total differs from gateway expected total, the transaction must enter review or correction flow.

---

## 21. Payment Amount Integrity

Payment request amount must match the approved final total.

Required checks:

- payment amount equals calculation snapshot final total;
- payment currency matches order currency;
- payment method eligibility passes;
- coupon/discount included in amount;
- tax/service charge included correctly;
- rounding applied correctly;
- split payment shares sum to final total;
- partial payment rules are defined.

Payment must not proceed on stale cart total.

---

## 22. Split Payment Policy

Split payment must be explicitly supported before activation.

Split payment rules must define:

- number of splits;
- supported payment methods;
- partial approval behavior;
- failure handling;
- cancellation behavior;
- refund behavior;
- receipt representation;
- settlement representation;
- customer communication.

Split payment must be disabled if reconciliation cannot match partial payment evidence.

---

## 23. Cancellation Amount Policy

Cancellation amount must use original transaction evidence.

Cancellation must reference:

- original calculation snapshot;
- original payment amount;
- original POS amount;
- original coupon/discount usage;
- original tax and fee treatment;
- cancellation eligibility rule;
- cancellation timestamp.

Cancellation must not recalculate using current price or promotion rules.

---

## 24. Refund Amount Policy

Refund amount must be based on the original calculation snapshot and refund rule.

Refund calculation must define:

- full refund;
- partial refund;
- item-level refund;
- modifier refund;
- coupon restoration;
- membership point restoration;
- tax refund;
- fee refund;
- service charge refund;
- rounding adjustment;
- payment method restriction.

Refund must not exceed original paid amount unless a separate compensation policy applies.

---

## 25. Partial Refund and Partial Cancellation

Partial refund/cancellation requires item-level calculation evidence.

Required evidence:

- refunded item identity;
- refunded modifier identity;
- original item amount;
- original discount allocation;
- original tax allocation;
- original fee allocation;
- remaining order amount;
- provider refund reference;
- receipt adjustment reference.

If discount/tax allocation cannot be determined, partial refund automation must be disabled or require manual review.

---

## 26. Settlement and Accounting Linkage

Total calculation evidence must support settlement and accounting.

The gateway must preserve:

- gross sales;
- discount total;
- coupon total;
- tax total;
- service charge total;
- refund total;
- net sales;
- payment method split;
- provider fee where available;
- settlement batch reference;
- accounting export classification.

Settlement variance must be traceable to calculation rule, provider behavior, or manual correction.

---

## 27. Calculation Engine Versioning

If the gateway has its own calculation engine, the engine must be versioned.

Required fields:

```text
calculation_engine_version
rule_interpreter_version
rounding_engine_version
promotion_engine_version
tax_engine_version
released_at
status
```

Orders must record which calculation engine version produced the total.

Changing the calculation engine requires regression tests and readiness review.

---

## 28. Calculation Regression Tests

Calculation rules must have regression tests.

Required test scenarios:

- base item only;
- item with modifiers;
- set/combo;
- item discount;
- order discount;
- coupon;
- membership benefit;
- promotion stacking;
- tax-included item;
- tax-excluded item;
- service charge;
- rounding edge case;
- partial refund;
- cancellation;
- split payment;
- POS mismatch case.

Regression test results must be retained for production rule changes.

---

## 29. Price Mismatch Incident Handling

Price mismatch incidents may include:

- customer shown lower amount than charged;
- POS charged higher amount than gateway;
- gateway charged lower amount than POS receipt;
- discount missing;
- coupon missing;
- tax mismatch;
- refund calculated incorrectly;
- settlement mismatch due to rounding.

Incident response must classify:

- customer impact;
- financial impact;
- tax/accounting impact;
- provider impact;
- rule version involved;
- correction required;
- customer protection action.

---

## 30. Monitoring Requirements

Calculation integrity must be monitored.

Required metrics:

- price mismatch count;
- POS/gateway total mismatch count;
- payment/gateway mismatch count;
- receipt/gateway mismatch count;
- settlement/gateway mismatch count;
- stale price version count;
- expired promotion used count;
- invalid coupon attempt count;
- discount override count;
- rounding variance count;
- refund amount review count;
- tax mismatch count.

Critical mismatch alerts must route to operations and reconciliation owner.

---

## 31. Dashboard Requirements

The operations dashboard must show:

- active price version;
- active promotion version;
- active discount rule version;
- active tax rule version;
- active calculation engine version;
- price mismatch status;
- POS total verification status;
- payment amount integrity status;
- rounding variance status;
- open calculation incidents;
- active restrictions;
- last regression test result.

Dashboard must not show calculation as ready when price, tax, or payment total mismatch exists.

---

## 32. Kiosk and Table Ordering Reuse

Kiosk and table ordering flows must use the same price and calculation integrity boundary.

They must inherit:

- active price version;
- active promotion rule;
- active coupon rule;
- active discount rule;
- active tax rule;
- active fee rule;
- rounding rule;
- customer-visible total rule;
- payment amount integrity rule;
- cancellation/refund amount rule.

Kiosk/table ordering must not maintain a separate total calculation model unless formally reconciled and approved.

---

## 33. Prohibited Practices

The following practices are prohibited:

- charging a customer based on stale cart total;
- silently accepting POS/gateway price mismatch;
- applying current price to historical refund;
- applying current promotion to historical cancellation;
- treating coupon as simple text note;
- dropping discount information when writing to POS;
- applying default tax rule when tax category is unknown;
- enabling partial refund without item-level allocation evidence;
- allowing calculation engine change without regression test;
- showing customer a total that cannot be reconciled to payment and receipt;
- hiding rounding variance from settlement review.

---

## 34. Minimum Acceptance Criteria

Price and calculation integrity is acceptable only when:

- calculation ownership model is defined;
- calculation scope is explicit;
- price versioning exists;
- customer-visible total policy exists;
- modifier price integrity exists;
- promotion and discount rules are versioned;
- coupon policy exists;
- membership benefit treatment exists where applicable;
- tax and service charge rules are explicit;
- rounding policy exists;
- stacking policy is deterministic;
- calculation snapshot is retained per order;
- POS total verification exists;
- payment amount integrity exists;
- cancellation/refund amount uses original evidence;
- regression tests exist;
- monitoring and incident handling exist;
- kiosk/table ordering inherits the same calculation boundary.

---

## 35. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_price_versions
pos_gateway_promotion_rules
pos_gateway_discount_rules
pos_gateway_coupon_rules
pos_gateway_membership_benefit_rules
pos_gateway_tax_rules
pos_gateway_service_charge_rules
pos_gateway_fee_rules
pos_gateway_rounding_policies
pos_gateway_stacking_policies
pos_gateway_calculation_snapshots
pos_gateway_total_verifications
pos_gateway_calculation_regression_tests
pos_gateway_price_mismatch_incidents
```

Recommended services:

```text
PriceVersionService
PromotionRuleService
DiscountRuleService
CouponRuleService
MembershipBenefitService
TaxRuleService
ServiceChargeRuleService
RoundingPolicyService
StackingPolicyService
TotalCalculationService
CalculationSnapshotService
PosTotalVerificationService
PaymentAmountIntegrityService
CancellationAmountService
RefundAmountService
CalculationRegressionTestService
CalculationIntegrityMonitor
```

Recommended event types:

```text
pos_gateway.calculation.price_version_created
pos_gateway.calculation.promotion_rule_activated
pos_gateway.calculation.discount_rule_activated
pos_gateway.calculation.coupon_applied
pos_gateway.calculation.tax_rule_applied
pos_gateway.calculation.total_calculated
pos_gateway.calculation.snapshot_created
pos_gateway.calculation.pos_total_verified
pos_gateway.calculation.payment_amount_verified
pos_gateway.calculation.price_mismatch_detected
pos_gateway.calculation.rounding_variance_detected
pos_gateway.calculation.refund_amount_review_required
pos_gateway.calculation.regression_test_failed
```

---

## 36. Relationship To Adjacent Documents

This document is related to:

- 06050 POS Gateway menu item, option, modifier, mapping template, versioning, and price integrity policy;
- 06040 POS Gateway tenant, store, SaaS onboarding package, template provisioning, and operational enablement policy;
- POS Gateway reconciliation, settlement, closing report, and accounting linkage policy;
- POS Gateway cancellation, refund, exception, manual override, and customer protection policy;
- POS Gateway production readiness checklist and smoke test policy;
- POS Gateway incident response and dispute investigation policy;
- kiosk and table ordering calculation policies.

Where conflict exists, this document governs price, promotion, discount, coupon, tax, service charge, and total calculation integrity for POS Gateway transaction routing.

---

## 37. Summary

Price calculation is financial infrastructure.

The POS Gateway must be able to prove every amount:

- shown to the customer;
- sent to POS;
- requested from payment provider;
- printed on receipt;
- settled later;
- cancelled or refunded.

Promotions, coupons, discounts, tax, service charges, and rounding cannot be treated as UI decoration.

The correct standard is:

- version every rule;
- snapshot every calculation;
- verify every total;
- use original evidence for refund/cancellation;
- block uncertain mismatches;
- keep kiosk/table ordering inside the same calculation boundary.

A gateway that cannot prove totals cannot safely handle money.