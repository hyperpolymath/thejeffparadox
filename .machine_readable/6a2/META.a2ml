;; SPDX-License-Identifier: MPL-2.0-or-later
;; META.scm - Meta-level information for thejeffparadox
;; Media-Type: application/meta+scheme

(meta
  (architecture-decisions
    (adr-001
      (status "accepted")
      (date "2025-11-29")
      (context "Need to track game mechanics, metrics, and LLM interactions for an experiment in LLM diachronic identity")
      (decision "Use Julia for core engine due to numerical computation needs and tool calling support")
      (consequences "Julia provides excellent numerical libraries, easy interop with APIs, and clean functional style"))

    (adr-002
      (status "accepted")
      (date "2025-11-29")
      (context "Need static site generation for personality fragment nodes and orchestrator")
      (decision "Use Hugo for all three sites (node-alpha, node-beta, orchestrator)")
      (consequences "Unified tooling, fast builds, Go-based for consistency"))

    (adr-003
      (status "accepted")
      (date "2025-11-29")
      (context "Need terminal interface for experiment control and monitoring")
      (decision "Use Ada 2022 for TUI to ensure safety-critical robustness")
      (consequences "Strong type system prevents runtime errors, Alire provides package management"))

    (adr-004
      (status "accepted")
      (date "2025-11-29")
      (context "LLM conversations risk convergence to repetitive patterns")
      (decision "Implement conceptor-inspired anti-convergence mechanisms at prompt level")
      (consequences "Diversity injection, contradiction seeding, aperture control, and pattern quarantine prevent attractor collapse"))

    (adr-005
      (status "accepted")
      (date "2025-11-30")
      (context "Need secure containerised deployment")
      (decision "Use Wolfi-based Podman containers with non-root user and dropped capabilities")
      (consequences "Minimal attack surface, secure defaults, compatible with rootless Podman")))

  (development-practices
    (code-style
      (julia "4-space indent, docstrings for all exports")
      (hugo "TOML config, semantic HTML, WCAG 2.2 AAA target")
      (ada "GNAT style, Alire for dependencies")
      (shell "POSIX compliant, shellcheck clean"))
    (security
      (principle "Defense in depth")
      (api-keys "Environment variables only, never in repository")
      (http-headers "CSP, X-Frame-Options, HSTS configured")
      (container "Non-root user, read-only filesystem, dropped capabilities")
      (workflows "SHA-pinned GitHub Actions, permissions read-all"))
    (testing
      (unit "Julia Test.jl for engine")
      (integration "End-to-end turn execution tests")
      (statistical "Hypothesis testing framework for emergence detection"))
    (versioning "SemVer")
    (documentation "AsciiDoc for primary docs, Markdown for GitHub integration")
    (branching "main for stable, feature branches for development"))

  (design-rationale
    (why-julia "Numerical computation for metrics, statistics, and conceptor mathematics; excellent HTTP and JSON libraries for LLM API calls; clean functional style for game mechanics")
    (why-hugo "Fast static site generation, Go-based for consistency with tooling, excellent templating for turn rendering")
    (why-ada "Safety-critical TUI requires strong typing and formal verification support; Alire package manager modernises Ada development")
    (why-wolfi "Minimal container base, distroless philosophy, Chainguard-maintained security")
    (why-conceptors "Jaeger (2014) conceptor theory provides mathematical framework for anti-convergence; adapted to prompt-level mechanisms since we cannot access LLM activations directly")))