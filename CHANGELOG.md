# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial Julia game engine with anti-convergence mechanisms
- Hugo sites for orchestrator, node-alpha, node-beta
- GitHub Actions CI/CD with SHA-pinned actions
- Containerfile for Wolfi-based deployment
- Comprehensive documentation (claude.adoc, whitepaper)
- RSR compliance infrastructure

### Fixed

- JeffEngine module exports and include order
- GitHub Actions SHA pinning for all dependencies
- Hugo theme configuration

## [0.1.0] - 2025-11-29

### Added

- Initial project structure
- Core game mechanics (chaos, exposure, faction)
- Anti-convergence system (conceptors)
- LLM client abstraction (Anthropic, Mistral, local)
- Metrics collection framework
- Accessibility-first Hugo layouts

---

Based on the original [The Jeff Paradox](https://criticalkit.us/products/the-jeff-paradox)
TTRPG by Tim Roberts / Critical Kit LLC.
