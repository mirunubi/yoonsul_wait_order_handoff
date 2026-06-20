# 000906_Policy_POS_Outsourcing_Security_Access_IP_Credential_And_Data_Control.md

## 1. Purpose

This policy defines security, access, credential, IP, and data control rules for POS integration outsourcing.

## 2. Access Prohibitions

Vendor must **not** receive or use:

| Prohibited access | Rule |
| --- | --- |
| Production database | No direct DB connection |
| Supabase admin key | No service role or admin API keys |
| Production payment credentials | Sandbox only unless explicit approved vault |
| Customer PII export | No bulk export; minimal test fixtures only |
| RLS modification | Internal team only |
| Direct deployment permission | No production deploy keys |
| Credential storage outside approved vault | Use approved secret management only |

## 3. Development Rules

| Rule | Requirement |
| --- | --- |
| Sandbox credentials only | Default for all vendor work |
| Official API only | No scraping, reverse engineering, undocumented bypass |
| Branch restriction | Work only in approved branches |
| Allowed folder restriction | Adapter code only in contract paths |
| Evidence handling | No sensitive payloads in public tickets |
| Incident notification | Report security incidents within 24 hours |

## 4. IP and Subcontractor

| Topic | Policy |
| --- | --- |
| IP ownership | Delivered adapter code ownership per SOW; our contracts and specs remain ours |
| Subcontractor | Requires written approval; same security rules apply |
| Handoff requirement | Full source, build instructions, and test evidence on delivery |

## 5. Data Control

- Test data must be synthetic or anonymized.
- No production store IDs in vendor personal environments without approval.
- Logs must redact payment PAN, tokens, and personal identifiers.

## 6. Violation Response

Security policy violation may result in immediate access revocation and contract review.

## 7. Final Rule

Sandbox-first, official API only, no production authority for vendor.
