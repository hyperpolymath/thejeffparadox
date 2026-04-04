# Security Policy

## SHA Pinning Requirement

**All GitHub Actions in this repository MUST be pinned to full-length commit SHAs.**

### Why SHA Pinning?

Version tags (like `@v4`) are mutable - the repository owner can update what commit a tag points to at any time. This creates a supply chain attack vector:

1. Attacker compromises an action repository
2. Attacker updates the `v4` tag to point to malicious code
3. All workflows using `@v4` now execute malicious code

### Solution

Pin to immutable commit SHAs:

```yaml
# INSECURE - mutable tag
- uses: actions/checkout@v4

# SECURE - immutable SHA
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

### Current Pinned Actions

| Action | SHA | Version |
|--------|-----|---------|
| `actions/checkout` | `11bd71901bbe5b1630ceea73d27597364c9af683` | v4.2.2 |
| `actions/upload-artifact` | `ea165f8d65b6e75b540449e92b4886f43607fa02` | v4.6.2 |
| `actions/download-artifact` | `d3f86a106a0bac45b974a628896c90dbdf5c8093` | v4.3.0 |
| `actions/setup-node` | `49933ea5288caeca8642d1e84afbd3f7d6820020` | v4.4.0 |
| `actions/stale` | `5bef64f19d7facfb25b37b414482c7164d639639` | v9.1.0 |
| `actions/labeler` | `8558fd74291d67161a8a78ce36a881fa63b766a9` | v5.0.0 |
| `actions/configure-pages` | `1f0c5cde4bc74cd7e1254d0cb4de8d49e9068c7d` | v4.0.0 |
| `actions/upload-pages-artifact` | `56afc609e74202658d3ffba0e8f6dda462b719fa` | v3.0.1 |
| `actions/deploy-pages` | `d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e` | v4.0.5 |
| `julia-actions/setup-julia` | `9b79636afcfb07ab02c256cede01fe2db6ba808c` | v2.6.0 |
| `julia-actions/cache` | `d10a6fd8f31b12404a54613ebad242900567f2b9` | v2.1.0 |
| `peaceiris/actions-hugo` | `16361eb4acea8698b220b76c0d4e84e1fd22c61d` | v2.6.0 |
| `ad-m/github-push-action` | `77c5b412c50b723d2a4fbc6d71fb5723bcd439aa` | v1.0.0 |
| `github/codeql-action` | `d3ced5c96c16c4332e2a61eb6f3649d6f1b20bb8` | v3.31.5 |
| `softprops/action-gh-release` | `5be0e66d93ac7ed76da52eca8bb058f665c3a5fe` | v2.4.2 |
| `orhun/git-cliff-action` | `b946ed27a675d653b308f29a7bbad813b85bf7aa` | v3.3.0 |
| `peter-evans/create-pull-request` | `84ae59a2cdc2258d6fa0732dd66352dddae2a412` | v7.0.9 |
| `aquasecurity/trivy-action` | `b6643a29fecd7f34b3597bc6acb0a98b03d33ff8` | v0.33.1 |
| `lycheeverse/lychee-action` | `a8c4c7cb88f0c7386610c35eb25108e448569cb0` | v2.7.0 |
| `ludeeus/action-shellcheck` | `00cae500b08a931fb5698e11e79bfbd38e612a38` | v2.0.0 |
| `ibiqlik/action-yamllint` | `2576378a8e339169678f9939646ee3ee325e845c` | v3.1.1 |
| `DavidAnson/markdownlint-cli2-action` | `db4f21d71a924e68fea27e1a2b3c67e58f823bd8` | v21.0.0 |
| `trufflesecurity/trufflehog` | `aade3bff5594fe8808578dd4db3dfeae9bf2abdc` | v3.91.1 |

## Security Scanning

### SAST (Static Application Security Testing)

- **Trivy**: Vulnerability scanning for dependencies and configurations
- **TruffleHog**: Secrets detection in code and history
- **ShellCheck**: Shell script security analysis

### Languages Not Supported by CodeQL

- **Julia**: Game engine (use Trivy for dependency scanning)
- **Ada**: TUI (compile-time type safety, use GNAT warnings)

## Container Security

All containers use **Wolfi**-based images (Chainguard) for:
- Minimal attack surface (distroless approach)
- Daily CVE scanning and patching
- SBOM generation
- Signed images

## Reporting Vulnerabilities

Please report security vulnerabilities to:
- Email: security@example.com (update with real address)
- Or create a private security advisory on GitHub

Do NOT create public issues for security vulnerabilities.

## RSR Compliance

This project follows the **Robust Software Repository (RSR)** specification:

- [x] SHA-pinned dependencies
- [x] SBOM generation
- [x] Signed containers (Wolfi/Chainguard)
- [x] Secrets scanning
- [x] Vulnerability scanning
- [x] Minimal base images
- [x] No unnecessary runtime dependencies
