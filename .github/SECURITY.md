# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously, even for an experimental research project.

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security vulnerabilities through one of these channels:

1. **GitHub Security Advisories** (preferred):
   - Go to the [Security tab](https://github.com/Hyperpolymath/thejeffparadox/security)
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**:
   - Send details to: security@example.com
   - Use our PGP key (see below) for sensitive information
   - Include "SECURITY" in the subject line

### What to Include

Please include as much of the following as possible:

- **Type of vulnerability** (e.g., XSS, injection, information disclosure)
- **Location** (file path, URL, component)
- **Steps to reproduce**
- **Proof of concept** (if available)
- **Impact assessment**
- **Suggested remediation** (if any)

### PGP Key

For sensitive communications, use our PGP key:

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
[Key would be published here in production]
-----END PGP PUBLIC KEY BLOCK-----
```

Fingerprint: `XXXX XXXX XXXX XXXX XXXX  XXXX XXXX XXXX XXXX XXXX`

### Response Timeline

| Stage | Timeline |
|-------|----------|
| Initial acknowledgment | Within 48 hours |
| Preliminary assessment | Within 1 week |
| Detailed response/remediation plan | Within 2 weeks |
| Fix deployment | Depends on severity |

### Severity Levels

| Severity | Description | Response Time |
|----------|-------------|---------------|
| Critical | Remote code execution, data breach | 24-48 hours |
| High | Significant security impact | 1 week |
| Medium | Limited security impact | 2 weeks |
| Low | Minimal security impact | Next release |

## Security Measures

### Current Implementations

#### HTTP Security Headers

All static sites are configured with:

```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 0
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Resource-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

#### API Security

- All LLM API calls use HTTPS only
- API keys stored in environment variables, never in code
- Rate limiting enforced
- No sensitive data in logs

#### Dependency Management

- Dependabot enabled for automated security updates
- Regular dependency audits
- Minimal dependency footprint

#### Code Security

- No user input directly executed
- No dynamic code evaluation
- Static site generation (no server-side execution)

### Threat Model

#### In Scope

| Threat | Mitigation |
|--------|------------|
| XSS in generated content | CSP, output encoding |
| Dependency vulnerabilities | Dependabot, audits |
| API key exposure | Environment variables, .gitignore |
| Information disclosure | Minimal data collection |

#### Out of Scope

This is a research project, not a production system. The following are
acknowledged but not primary concerns:

| Area | Notes |
|------|-------|
| DDoS | Static hosting provides inherent protection |
| Physical security | Not applicable |
| Social engineering | Limited attack surface |

### AI-Specific Security Considerations

#### Prompt Injection

The experiment involves LLMs generating content. Mitigations:

- System prompts are not user-controllable
- Generated content is rendered as text, not executed
- No user input reaches the LLM prompts

#### Output Safety

LLM outputs may contain:

- Unexpected content (hallucinations)
- Potentially offensive content
- Attempts to break character

Mitigations:

- Content is clearly labelled as AI-generated
- No automatic execution of generated content
- Human review for public-facing content

#### Model Security

- Using established, safety-tuned models (Claude, Mistral)
- No fine-tuning that could degrade safety
- No attempts to bypass model safety measures

## Security Best Practices for Contributors

### Do

- Keep dependencies up to date
- Use environment variables for secrets
- Follow the principle of least privilege
- Report security issues responsibly

### Don't

- Commit API keys or secrets
- Disable security headers without discussion
- Add dependencies without security review
- Implement custom cryptography

## Security Contacts

- **Primary**: security@example.com
- **Backup**: [GitHub Security Advisories](https://github.com/Hyperpolymath/thejeffparadox/security)

## Acknowledgments

We thank security researchers who help keep this project secure. Contributors
who report valid security issues will be acknowledged here (with permission):

- *No reports yet*

## Related Documents

- [.well-known/security.txt](/.well-known/security.txt)
- [Security Headers Configuration](/orchestrator/hugo.toml)
- [Dependabot Configuration](/.github/dependabot.yml)

---

Last updated: 2025-11-29
