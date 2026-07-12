# 000010_Guide_Wait_Order_Project

1\. Purpose

This document defines the overall purpose, scope, and structure of the yoonsul\_wait\_order\_handoff project.

This project covers:

\- CatchMenu customer service
\- waiting registration
\- order preparation during waiting
\- customer arrival
\- seating
\- staff handoff
\- POS handoff
\- KDS handoff
\- Mini Kiosk
\- Mini KDS
\- SaaS / white label linkage
\- benefit routing
\- external membership integration
\- BM / patent separation

The purpose of this project is not merely to build a waiting app.

The purpose is to carry customer/order context created during waiting into store execution without losing it at the moment of arrival, seating, POS entry, or kitchen handoff.

2\. Project Identity

The project name is:

yoonsul\_wait\_order\_handoff

The customer-facing service name is:

캐치메뉴 / CatchMenu

The project can be summarized as:

CatchMenu / waiting / order preparation / arrival / seating / POS-KDS handoff / SaaS integration

3\. Core Definition

CatchMenu is the customer-facing service.

wait\_order\_handoff is the operational runtime.

CatchMenu provides the customer experience.

wait\_order\_handoff carries runtime context between customer, staff, POS, KDS, Mini Kiosk, Mini KDS, and external SaaS systems.

Core statement:

«CatchMenu is not just a waiting app.
It is a waiting-to-store-execution handoff service.»

Korean statement:

캐치메뉴는 단순 대기앱이 아니다.
대기 중 만들어진 고객/주문 맥락을 입장·착석·직원·POS·KDS로 끊기지 않게 넘기는 handoff 서비스다.

4\. Product Axes

The project is divided into five major product/design axes.

4.1 CatchMenu Service Concept

This axis defines:

\- what CatchMenu is
\- why waiting time can be used for order preparation
\- how CatchMenu differs from a normal waiting app
\- how CatchMenu differs from POS or KDS
\- how Mini Kiosk and Mini KDS are positioned
\- how SaaS and white label models are separated

4.2 Customer App / Webapp

This axis defines:

\- CatchMenu customer app
\- QR webapp
\- non-member entry
\- waiting registration
\- menu pre-selection
\- request/allergy input
\- show-to-staff screen
\- customer-facing status
\- benefit candidate display
\- membership connection flow

4.3 Store Console

This axis defines:

\- Store Wait Board
\- Staff Handoff screen
\- arrival confirmation
\- seating confirmation
\- prepared order review
\- manual POS handoff
\- Mini KDS support
\- KDS/POS returned status display
\- no-show/cancel/expired handling
\- staff confirmation log

4.4 Wait Order Core

This axis defines the runtime ledger for:

\- wait\_order\_session
\- prepared\_order\_context
\- waiting\_status
\- arrival\_status
\- seating\_status
\- order\_prep\_status
\- handoff\_status
\- POS/KDS external references
\- benefit candidate status
\- event log

4.5 Benefit Routing / External Integration

This axis defines:

\- CatchMenu customer identity
\- tenant customer identity
\- white label identity
\- identity link
\- benefit policy
\- claim token
\- duplicate guard
\- external membership connector
\- webhook/API integration

5\. Document Structure

The project documentation is organized as follows.

docs/
  00\_foundation/
  01\_product\_concept/
  02\_customer\_app/
  03\_customer\_webapp/
  04\_store\_console/
  05\_wait\_order\_core/
  06\_handoff\_runtime/
  07\_benefit\_routing/
  08\_external\_integration/
  09\_patent\_bm/

6\. Foundation Documents

The foundation layer defines the project boundary before screen, state, or DB design.

Recommended foundation documents:

00010\_Wait\_Order\_Project\_Overview.md
00020\_Store\_Capability\_Stage\_0\_To\_5\_Module\_Policy.md
00030\_Runtime\_Boundary.md
00040\_Operation\_Patterns\_For\_KDS\_And\_Mini\_Runtime.md
00050\_Deployment\_Mode\_Model.md
00060\_Glossary.md

6.1 00010 Project Overview

Defines what this project is and how major product/runtime axes are separated.

6.2 00020 Store Capability Stage 0 To 5 Module Policy

Defines the six store capability stages:

Stage 0 \= Multilingual QR Menu Board / No CatchMenu Waiting
Stage 1 \= Manual POS Handoff / POS Exists But No Integration
Stage 2 \= Manual POS \+ Mini KDS / Kitchen Assist
Stage 3 \= POS Adapter Handoff / KDS Not Directly Owned
Stage 4 \= POS \+ KDS Integrated Handoff
Stage 5 \= SaaS / White Label / External Membership / Benefit Routing

6.3 00030 Runtime Boundary

Defines what wait\_order owns and what it must not own.

wait\_order must not become:

\- POS
\- full KDS
\- inventory ledger
\- payment ledger
\- external membership ledger

6.4 00040 Operation Patterns For KDS And Mini Runtime

Defines operation patterns such as:

\- split production
\- multi-channel handoff
\- pre-order pending confirmation
\- standalone kiosk loop

These are not Stage 6\~9.
They are operation patterns reflected through interface fields, Mini Kiosk, Mini KDS, Yoonsul KDS, or external KDS.

7\. Store Capability Stage Summary

The project supports stores at different capability levels.

Stage 0 \= Menu board only
Stage 1 \= Manual POS handoff
Stage 2 \= Manual POS \+ Mini KDS
Stage 3 \= POS Adapter
Stage 4 \= POS \+ KDS Adapter
Stage 5 \= SaaS / White Label / Benefit Routing

The stage model is not a development roadmap.

It is a store-by-store module activation policy.

A store’s capability stage determines which modules are enabled.

8\. Mini Kiosk And Mini KDS Position

8.1 Mini Kiosk

Mini Kiosk is a lightweight customer-facing ordering-preparation UI.

It may support:

\- QR menu
\- multilingual menu
\- menu pre-selection
\- allergy/request input
\- store-confirm-required notice
\- show-to-staff screen
\- handoff channel selection

Mini Kiosk does not own payment or POS transaction authority.

8.2 Mini KDS

Mini KDS is a lightweight kitchen/staff support screen.

It may support:

\- prepared order queue
\- simple kitchen grouping
\- allergy/request highlight
\- manual kitchen acknowledgment
\- manual ready check
\- handoff channel grouping
\- fallback operation

Mini KDS is not a full KDS engine unless separately promoted and governed as such.

9\. POS / KDS Position

9.1 POS

POS remains the transaction authority.

POS owns:

\- official order
\- payment
\- cancellation
\- refund
\- sales ledger
\- settlement reference

wait\_order may send prepared order context to POS, but POS remains the source of transaction truth.

9.2 KDS

KDS remains the kitchen execution authority.

KDS owns:

\- kitchen ticket
\- production task
\- line assignment
\- production priority
\- cooking status
\- ready status
\- production completion

wait\_order may send handoff context to KDS, but KDS remains the source of kitchen execution truth.

10\. CatchMenu App, Webapp, And White Label Separation

CatchMenu App is for repeat customers.

CatchMenu Webapp is for QR/link-based immediate store use.

White label app is for tenant-owned membership/service experience.

These must remain separated.

CatchMenu App
\= CatchMenu customer identity and repeated customer experience

CatchMenu Webapp
\= QR/link-based immediate entry for waiting, menu pre-selection, and show-to-staff flow

White Label App
\= tenant-owned customer membership and brand experience

A customer may have both CatchMenu identity and tenant membership identity.

These identities must not be forcibly merged.

They may be connected through identity link, claim token, policy evaluation, and duplicate guard.

11\. Benefit Routing Principle

wait\_order is not a membership ledger.

CatchMenu may detect benefit candidates.

The system may issue claim tokens.

External membership systems may receive benefit claims.

Duplicate guard must prevent duplicated reward or coupon application.

Core principle:

«Benefit candidate does not equal benefit claimed.
Identity link does not equal account merge.
wait\_order does not become the external membership ledger.»

12\. BM / Patent Separation

This project has both development and BM/patent dimensions.

The BM/patent documents should describe:

\- waiting-to-order lead-time reduction
\- customer order preparation during waiting
\- Mini Kiosk concept
\- POS/KDS handoff structure
\- software-based handoff over hardware-heavy kiosk structures
\- multilingual customer ordering support
\- SaaS/white label applicability

However, patent/BM documents must not force implementation scope.

Development documents must preserve the runtime boundary.

Patent/BM concept may be broader than MVP implementation.

13\. MVP Direction

The first practical MVP should focus on Stage 1 and Stage 2\.

Stage 1 proves:

customer waits
customer prepares order context
staff sees context
staff manually enters POS
handoff event is recorded

Stage 2 proves:

customer prepares order context
staff sees context
kitchen sees Mini KDS or kitchen assist screen
POS remains manual
handoff loss is reduced

Stage 1 and Stage 2 are enough to prove the core value without POS/KDS API risk.

14\. Long-Term Direction

The long-term direction is Stage 5\.

Stage 5 supports:

\- SaaS tenant
\- multi-store brand
\- white label app
\- external membership
\- benefit routing
\- identity link
\- POS/KDS adapter capability
\- webhook/API
\- tenant/store feature activation
\- fallback by store capability

Stage 5 must still preserve the runtime boundary:

wait\_order does not become POS
wait\_order does not become full KDS
wait\_order does not become payment
wait\_order does not become inventory
wait\_order does not become external membership ledger

15\. Final Project Statement

yoonsul\_wait\_order\_handoff is a store capability-based handoff runtime project.

It starts from multilingual menu support and manual handoff.

It can grow into Mini Kiosk, Mini KDS, POS Adapter, KDS Adapter, SaaS tenant, white label, and benefit routing.

Its core value is not simply reducing waiting time.

Its core value is preserving and transferring the customer/order context created during waiting into real store execution.
