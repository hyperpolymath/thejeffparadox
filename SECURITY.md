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
| `actions/configure-pages` | `983d7736d9b0ae728b81ab479565c72886d7745b` | v5.0.0 |
| `actions/upload-pages-artifact` | `7b1f4a764d45c48632c6b24a0339c27f5614fb0b` | v4 (main) |
| `actions/deploy-pages` | `d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e` | v4.0.5 |
| `julia-actions/setup-julia` | `9b79636afcfb07ab02c256cede01fe2db6ba808c` | v2.6.0 |
| `julia-actions/cache` | `d10a6fd8f31b12404a54613ebad242900567f2b9` | v2.1.0 |
| `peaceiris/actions-hugo` | `16361eb4acea8698b220b76c0d4e84e1fd22c61d` | v2.6.0 |
| `ad-m/github-push-action` | `77c5b412c50b723d2a4fbc6d71fb5723bcd439aa` | v1.0.0 |
| `github/codeql-action` | `662472033e021d55d94146f66f6058822b0b39fd` | v3.28.1 |
| `softprops/action-gh-release` | `c95fe1489396fe8a9eb87c0abf8aa5b2ef267fda` | v2.2.1 |
| `orhun/git-cliff-action` | `4a4a951bc43fbbe322c2a88b5481dc1e94336522` | v4.4.2 |
| `peter-evans/create-pull-request` | `84ae59a2cdc2258d6fa0732dd66352dddae2a412` | v7.0.9 |
| `aquasecurity/trivy-action` | `b6643a29fecd7f34b3597bc6acb0a98b03d33ff8` | v0.33.1 |
| `lycheeverse/lychee-action` | `a8c4c7cb88f0c7386610c35eb25108e448569cb0` | v2.7.0 |
| `ludeeus/action-shellcheck` | `00cae500b08a931fb5698e11e79bfbd38e612a38` | v2.0.0 |
| `ibiqlik/action-yamllint` | `2576378a8e339169678f9939646ee3ee325e845c` | v3.1.1 |
| `DavidAnson/markdownlint-cli2-action` | `30a0e04f1870d58f8d717450cc6134995f993c63` | v21.0.0 |
| `trufflesecurity/trufflehog` | `aade3bff5594fe8808578dd4db3dfeae9bf2abdc` | v3.91.1 |
| `denoland/setup-deno` | `5e01c016a857a4dbb5afe9d0f9733cd472cba985` | v1.5.1 |
| `webfactory/ssh-agent` | `a6f90b1f127823b31c7c27b366ef5d486f4fe3c1` | v0.9.1 |
| `ossf/scorecard-action` | `62b2cac7ed8198b15735ed49ab1e5cf35480ba46` | v2.4.0 |
| `editorconfig-checker/action-editorconfig-checker` | `8c9b118d446fce7e6410b6c0a3ce2f83bd04e97a` | latest |
| `actions/first-interaction` | `1c4688942c71f71d4f5502a26ea67c331730fa4d` | v3.1.0 |

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
- Email: security@metadatastician.art
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
