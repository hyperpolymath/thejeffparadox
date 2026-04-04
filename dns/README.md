# DNS Security Configuration

This directory contains DNS zone records for comprehensive email and domain security.

## Quick Start

1. Copy `zone-security.txt` to your DNS provider
2. Replace `YOURDOMAIN.COM` with your actual domain
3. Update placeholder values (DKIM keys, verification codes, etc.)
4. Import via zone file import or add records individually

## Records Included

| Record Type | Purpose | RFC |
|-------------|---------|-----|
| SPF | Authorize mail servers | RFC 7208 |
| DKIM | Email signing | RFC 6376 |
| DMARC | Email auth policy | RFC 7489 |
| MTA-STS | Enforce TLS for mail | RFC 8461 |
| TLS-RPT | TLS failure reports | RFC 8460 |
| BIMI | Brand logo in email | BIMI Group |
| CAA | Certificate authority control | RFC 8659 |
| DANE/TLSA | Certificate pinning | RFC 6698 |

## Implementation Order

1. **Week 1**: Add SPF and start DKIM setup
2. **Week 2**: Deploy DMARC with `p=none` (monitor mode)
3. **Week 3**: Add CAA records
4. **Week 4**: Enable DNSSEC at registrar
5. **Week 5**: Add MTA-STS and TLS-RPT
6. **Week 6**: Review DMARC reports, tighten to `p=quarantine`
7. **Week 8**: Move to `p=reject` if reports are clean
8. **Optional**: Add DANE after DNSSEC is stable, add BIMI with VMC

## Required Web Resources

These files must be hosted on your domain:

### `/.well-known/mta-sts.txt`
```
version: STSv1
mode: enforce
mx: mail.yourdomain.com
max_age: 604800
```

### `/.well-known/security.txt`
Already in repository at `.well-known/security.txt`

### `/.well-known/ai.txt`
Already in repository at `.well-known/ai.txt`

## Verification Tools

- SPF: [MXToolbox SPF](https://mxtoolbox.com/spf.aspx)
- DKIM: [MXToolbox DKIM](https://mxtoolbox.com/dkim.aspx)
- DMARC: [MXToolbox DMARC](https://mxtoolbox.com/dmarc.aspx)
- CAA: [SSLMate CAA](https://sslmate.com/caa/)
- DNSSEC: [DNSViz](https://dnsviz.net/)
- Overall: [Hardenize](https://www.hardenize.com/)

## RSR Compliance

These records satisfy RSR requirements for:
- Email authentication (SPF, DKIM, DMARC)
- Transport security (MTA-STS, DANE)
- Certificate control (CAA)
- Security disclosure (security.txt DNS pointer)
