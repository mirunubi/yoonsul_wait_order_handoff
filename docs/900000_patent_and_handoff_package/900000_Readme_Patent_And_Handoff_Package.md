# 900000_Readme_Patent_And_Handoff_Package

## Purpose

This folder is the patent and handoff package for CatchMenu / Catch & Order / Yoonsul OS: the customer waiting/handoff/late-binding pipeline, its channel implementations, kiosk/DID auto-control, and the business/patent strategy documents supporting them.

## Scope

- Customer waiting, handoff, and late-binding pipeline (overview + logic)
- Channel-specific handoff and session implementations: Channel 1 (Web App), Channel 2 (Catch Menu native app), Channel 3 (whitelabel app), Channel 4 (Yoonsul embedded app)
- Phase validation plan from Catch Menu to Yoonsul embedded
- Event-based kiosk and DID auto-control system; POS integration level-based mode transition system
- Prior-patent risk and avoidance strategy (global late-binding, POS late-binding)
- POS dynamic multi-service slot container agent system
- Business policy documents: payment/regulatory compliance and table-order design, slot container platform support (Android/Windows), coupon business model and CMS integration, Yoonsul OS multi-brand AI F&B OS SaaS vision, multi-brand expansion roadmap, workforce platform and Asia F&B expansion vision, CCP/mini-HACCP food safety, AI multi-engine gateway and inference audit log, hyper-personalization menu/pricing
- Test plan and change contract for customer handoff (waiting/preorder/payment/KDS release)

## File List

- `900180_Overview_CatchMenu_YoonsulOS_Asia_FnB_Platform.md` — top-level executive summary of the platform vision (reclassified from Executive_Summary to Overview)
- `900100`-`900179` — overview, logic, change contract, test plan, policy, and assessment documents per the areas listed above
- `906000`-`906010` — Catch Menu-specific test plan and change contract

## Non-Scope

- Runtime implementation, SQL, Flutter/Dart, or Supabase changes
