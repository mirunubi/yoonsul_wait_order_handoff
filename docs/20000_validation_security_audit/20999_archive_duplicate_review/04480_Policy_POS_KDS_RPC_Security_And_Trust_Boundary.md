# 04480_Policy_POS_KDS_RPC_Security_And_Trust_Boundary

\#\# 1\. Purpose

This document defines the security and trust boundary policy for POS, KDS, Bridge, Agent, and related runtime communication in the Yoonsul Wait/Order Handoff project.

The POS/KDS communication path is not a simple internal message route.

It connects transaction authority, kitchen execution, degraded operation, manual recovery, retry, replay, and audit evidence.

Therefore, every RPC, webhook, bridge call, local agent relay, and retry path must be treated as a security-sensitive boundary.

\---

\#\# 2\. Scope

This policy applies to:

\- POS to KDS communication
\- KDS to POS status return
\- POS/KDS Bridge runtime
\- Local Agent relay
\- degraded mode order/ticket recovery
\- retry and replay requests
\- kitchen ticket state transition
\- manual kitchen note transmission
\- remake, delay, hold, and ready status
\- POS accepted order boundary
\- KDS kitchen execution boundary
\- audit and evidence creation for POS/KDS mismatch

This document does not define final API implementation.

It defines the mandatory security and trust rules that later API, RPC, schema, and runtime documents must follow.

\---

\#\# 3\. Core Principle

POS and KDS must not trust each other blindly.

The project must follow this principle:

\> Connected runtime does not mean shared authority.

A runtime may receive, display, relay, or report state.

However, each runtime may mutate only the state it owns.

\---

\#\# 4\. Runtime Authority Separation

\#\#\# 4.1 POS Authority

POS is the transaction authority.

POS owns:

\- accepted order
\- order total
\- payment request
\- payment result
\- cancellation authority
\- refund trigger
\- settlement reference
\- customer payment boundary
\- final transaction truth

KDS must not overwrite POS transaction state.

\---

\#\#\# 4.2 KDS Authority

KDS is the kitchen execution authority.

KDS owns:

\- ticket received
\- ticket visible to kitchen
\- cooking started
\- hold
\- delay
\- remake requested
\- remake accepted
\- kitchen note
\- ready
\- served
\- manual kitchen recovery note

KDS must not rewrite payment, refund, settlement, or customer identity truth.

\---

\#\#\# 4.3 Bridge Authority

Bridge runtime is a federation and translation boundary.

Bridge may:

\- receive event
\- validate event
\- translate event format
\- queue event
\- retry event
\- detect stale event
\- reject invalid event
\- report mismatch
\- create evidence
\- request recovery

Bridge must not:

\- become POS authority
\- become KDS authority
\- silently correct transaction state
\- silently correct kitchen execution state
\- bypass audit requirement
\- bypass tenant/store validation
\- merge conflicting state without review

Bridge is a controlled passage, not an owner.

\---

\#\#\# 4.4 Agent Authority

Agent runtime may detect, recommend, summarize, classify, and project risk.

Agent may:

\- detect delay risk
\- detect ticket mismatch
\- recommend remake review
\- recommend manual recovery
\- summarize incident evidence
\- flag stale state
\- flag replay requirement

Agent must not:

\- approve recovery
\- cancel order
\- refund payment
\- finalize settlement
\- overwrite POS state
\- overwrite KDS state
\- close audit case
\- act as human operator

Agent output is recommendation, not execution.

\---

\#\# 5\. Trust Boundary Rule

Every POS/KDS communication must cross a trust boundary.

The system must validate:

\- who sent the request
\- which tenant the request belongs to
\- which store the request belongs to
\- which runtime sent the request
\- which device or service identity sent the request
\- whether the method is allowed
\- whether the transition is allowed
\- whether the request is fresh
\- whether the request is duplicated
\- whether the request has already been processed
\- whether the request requires audit

No POS/KDS RPC request may be accepted only because it came from an internal IP, store LAN, or trusted application name.

\---

\#\# 6\. Required RPC Request Context

Every POS/KDS RPC request must include or derive the following context:

\- tenant\_id
\- store\_id
\- runtime\_type
\- runtime\_id
\- device\_id or service\_identity
\- actor\_id if human-initiated
\- request\_id
\- idempotency\_key
\- correlation\_id
\- source\_event\_id
\- requested\_action
\- current\_known\_state
\- requested\_next\_state
\- request\_timestamp
\- client\_clock\_timestamp if applicable
\- server\_received\_timestamp
\- signature or trusted channel proof where applicable
\- degraded\_mode flag if applicable
\- fallback\_originated flag if applicable

Missing context must result in rejection or manual review.

\---

\#\# 7\. Allowed State Transition Policy

A request must not be accepted only because the method exists.

The requested state transition must be allowed.

Examples:

\- \`TICKET\_RECEIVED\` may transition to \`COOKING\_STARTED\`.
\- \`COOKING\_STARTED\` may transition to \`HOLD\`.
\- \`COOKING\_STARTED\` may transition to \`READY\`.
\- \`READY\` may transition to \`SERVED\`.
\- \`DELAYED\` may transition to \`COOKING\_STARTED\` or \`READY\`.
\- \`REMAKE\_REQUESTED\` may transition to \`REMAKE\_ACCEPTED\`.
\- \`REMAKE\_ACCEPTED\` may transition to \`COOKING\_STARTED\`.

Invalid examples:

\- KDS must not transition order to \`PAID\`.
\- KDS must not transition order to \`REFUNDED\`.
\- Bridge must not transition payment to \`SETTLED\`.
\- Agent must not transition recovery to \`APPROVED\`.
\- Retry must not transition failed event into final truth without validation.
\- Replay must not overwrite current state.

Invalid transitions must be rejected and audited.

\---

\#\# 8\. Idempotency Policy

Every mutation-capable RPC request must use idempotency.

The system must prevent duplicate execution caused by:

\- network retry
\- user double tap
\- bridge retry
\- local agent replay
\- delayed webhook
\- duplicate POS event
\- duplicate KDS event
\- degraded mode sync replay

A repeated request with the same idempotency key must not create duplicate state mutation.

The system may return the previous result or mark the request as duplicate.

Duplicate detection must be auditable for sensitive events.

\---

\#\# 9\. Replay Protection Policy

Replay is a high-risk operation.

Replay may be used for:

\- reconstruction
\- evidence comparison
\- incident analysis
\- recovery proposal
\- state verification

Replay must not be used for:

\- silent correction
\- silent merge
\- hidden overwrite
\- automatic payment change
\- automatic refund
\- automatic settlement correction
\- automatic audit closure

Replay-generated results must be marked as replay-derived.

If replay conflicts with current state, the system must create:

\- \`REPLAY\_REQUIRED\`
\- \`RECONCILIATION\_REQUIRED\`
\- \`CACHE\_STATE\_UNCERTAIN\`
\- \`RECOVERY\_PENDING\`

Final correction must be handled through approved recovery or amendment flow.

\---

\#\# 10\. Timestamp And Clock Policy

POS/KDS communication may involve multiple clocks.

The system must distinguish:

\- client clock timestamp
\- device clock timestamp
\- local agent timestamp
\- bridge received timestamp
\- central server timestamp
\- audit event timestamp

Client or device timestamp must not be treated as final ordering truth by itself.

Server received timestamp and audit append timestamp must be preserved.

If time ordering is uncertain, the event must be marked:

\- \`CHRONOLOGY\_UNCERTAIN\`
\- \`CACHE\_STATE\_UNCERTAIN\`
\- \`REVIEW\_REQUIRED\`

Clock mismatch must not cause silent overwrite.

\---

\#\# 11\. Degraded Mode RPC Policy

When central connectivity is degraded, local operation may continue under strict control.

Degraded mode RPC rules:

\- local state is provisional
\- fallback-originated data must be marked
\- manual input must create evidence
\- Primary local agent may coordinate provisional state
\- Secondary local agent must not overwrite Primary state
\- POS/KDS mismatch must be preserved
\- delayed sync must not silently merge
\- central recovery must verify local evidence
\- recovery must create audit record

Degraded mode must preserve security boundaries.

Degraded mode is not a bypass.

\---

\#\# 12\. POS Accepted Order Boundary

KDS must receive only POS-accepted order candidates or approved kitchen tickets.

A kitchen ticket must not be created from an untrusted customer-side event alone.

The boundary is:

Customer request \-\> POS validation \-\> accepted order \-\> KDS ticket candidate \-\> kitchen ticket

The following must be prevented:

\- direct customer request creating KDS ticket
\- direct waiting session creating kitchen ticket without POS validation
\- direct agent recommendation creating kitchen ticket
\- direct bridge replay creating kitchen ticket without accepted source
\- manual note becoming accepted order without POS boundary

POS accepted order is the gate before kitchen execution.

\---

\#\# 13\. KDS Kitchen Ticket Boundary

Once KDS receives a valid ticket, KDS may manage kitchen execution state.

KDS execution state must remain separate from POS transaction state.

KDS may report:

\- accepted by kitchen
\- started
\- delayed
\- held
\- remake needed
\- ready
\- served
\- manual recovery needed

KDS must not report:

\- paid
\- refunded
\- settled
\- customer identity verified
\- legal compensation approved
\- payment correction completed

KDS owns execution visibility, not transaction authority.

\---

\#\# 14\. Bridge Rejection Policy

Bridge must reject or quarantine unsafe requests.

Rejection conditions include:

\- missing tenant context
\- tenant mismatch
\- missing store context
\- store mismatch
\- invalid runtime identity
\- invalid device identity
\- expired request
\- duplicated request without idempotency handling
\- invalid state transition
\- signature failure
\- unsupported method
\- replay risk
\- degraded mode conflict
\- unauthorized mutation attempt
\- suspicious source

Rejected requests must create evidence.

Security-related rejection must not be hidden as generic technical failure.

\---

\#\# 15\. Audit Requirements

The following POS/KDS security events must be audited:

\- RPC request accepted
\- RPC request rejected
\- invalid state transition
\- tenant mismatch
\- store mismatch
\- runtime identity failure
\- device identity failure
\- signature failure
\- duplicate request detected
\- replay requested
\- replay conflict detected
\- degraded mode activated
\- local agent relay used
\- manual kitchen recovery created
\- POS/KDS mismatch detected
\- bridge quarantine created
\- recovery approval requested
\- recovery approved
\- recovery denied

Audit must include:

\- tenant\_id
\- store\_id
\- runtime\_type
\- runtime\_id
\- device\_id
\- actor\_id if applicable
\- action
\- before\_state
\- after\_state
\- rejection\_reason if applicable
\- request\_id
\- idempotency\_key
\- correlation\_id
\- timestamp
\- evidence reference

Audit must be append-only.

\---

\#\# 16\. Logging And Masking

POS/KDS logs must support troubleshooting without exposing sensitive data.

Logs must not include:

\- raw customer CI
\- raw customer DI
\- full phone number
\- payment token
\- access token
\- refresh token
\- service role key
\- full personal identifier
\- raw secret configuration
\- unmasked API key

Logs may include masked or hashed references where needed.

Kitchen staff view must not expose unnecessary customer identity.

Support view must be masked by default.

\---

\#\# 17\. Error Handling Policy

Error responses must be safe.

Error responses must not expose:

\- database schema details
\- stack trace
\- secret values
\- internal service key
\- raw SQL
\- full identity data
\- payment provider secret
\- signature validation internals

Errors must be classified into safe categories:

\- invalid request
\- unauthorized
\- forbidden
\- conflict
\- duplicate request
\- stale request
\- replay required
\- recovery required
\- degraded mode active
\- manual review required

Detailed diagnostic data must be restricted to authorized internal logs.

\---

\#\# 18\. Recovery And Manual Override

Manual override may be necessary in store operation.

However, manual override is security-sensitive.

Manual override must include:

\- actor identity
\- role authority
\- device context
\- tenant context
\- store context
\- reason
\- affected ticket/order
\- before state
\- proposed after state
\- evidence reference
\- timestamp
\- approval requirement if applicable

Manual override must not erase original event.

Manual override must create append-only correction evidence.

\---

\#\# 19\. Security Readiness Checklist

Before POS/KDS RPC implementation, confirm:

\- POS authority is separated from KDS authority.
\- KDS cannot rewrite payment state.
\- Bridge cannot silently mutate transaction truth.
\- Agent cannot approve or execute recovery.
\- Every RPC validates tenant context.
\- Every RPC validates store context.
\- Every RPC validates runtime identity.
\- Every RPC validates device or service identity.
\- Mutation requests use idempotency.
\- Replay cannot overwrite current state.
\- Degraded mode does not bypass security.
\- Invalid transitions are rejected.
\- Rejected requests are audited.
\- Logs mask sensitive identity and secret values.
\- Manual override creates evidence.
\- Support access is scoped and masked.
\- POS/KDS mismatch creates recovery evidence.

If any item fails, implementation must not proceed.

\---

\#\# 20\. Non-Goals

This document does not define:

\- final RPC endpoint names
\- final SQL schema
\- final database functions
\- final queue implementation
\- final encryption algorithm
\- final POS vendor protocol
\- final KDS vendor protocol
\- final local agent implementation
\- final UI screen design
\- final incident response runbook

Those must be defined in later implementation documents.

\---

\#\# 21\. Conclusion

POS/KDS integration is a core operational boundary.

It must be secure by design.

The system must preserve the following rules:

\- POS owns transaction truth.
\- KDS owns kitchen execution truth.
\- Bridge relays and validates but does not own truth.
\- Agent recommends but does not execute authority.
\- Replay reconstructs but does not mutate.
\- Degraded mode continues operation but does not bypass security.
\- Manual override appends evidence but does not erase history.
\- Every sensitive request is validated, scoped, and audited.

This policy must be followed by all later POS, KDS, Bridge, Agent, RPC, retry, replay, and recovery implementation documents.
