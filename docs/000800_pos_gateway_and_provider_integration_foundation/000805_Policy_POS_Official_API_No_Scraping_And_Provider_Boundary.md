# 000805_Policy_POS_Official_API_No_Scraping_And_Provider_Boundary.md

## 1. Purpose

Official API, no-scraping, and provider boundary policy for POS Gateway integration.

## 2. Required

| Rule | Requirement |
| --- | --- |
| Official API first | Use provider-documented APIs or approved integration paths |
| Official agreement | Provider agreement where applicable before production |
| Documented limitations | Every provider gap recorded in `000804` |
| Clear support labeling | Integration possible ≠ commercially supported |
| Manual/semi-manual labeling | Non-automated paths explicitly marked |

## 3. Prohibited

| Prohibition | Reason |
| --- | --- |
| Scraping | Unstable, unauditable, often violates ToS |
| Reverse engineering | Legal and support risk |
| Undocumented bypass | Hidden production failure |
| Hidden local automation | Operational surprise |
| Credential sharing outside approved scope | Security |
| Presenting unsupported provider as supported | Customer and store risk |

## 4. Commercial Support Rule

A provider may be integrated in sandbox but remain **Candidate** or **Limited** until support criteria in `000811` are met.

## 5. Final Rule

Official paths only; document limits; label support honestly.
