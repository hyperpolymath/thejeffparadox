<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Changelog

All notable changes to `thejeffparadox` will be documented in this file.

This file is generated from conventional commits by the
[`changelog-reusable.yml`](https://github.com/hyperpolymath/standards/blob/main/.github/workflows/changelog-reusable.yml)
workflow (`hyperpolymath/standards#206`). Adopt the workflow in this repo's CI to keep this file in sync automatically — see
[`templates/cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml)
for the canonical config.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- feat(engine): improve LLM client error handling and recovery
- feat: implement metrics_trend/detect_emergent_patterns, add SPDX headers
- feat: add CRG Grade B test suite (6 targets)

### Fixed

- fix(ci): sync hypatia-scan.yml to canonical (kill cd-scanner build drift) (#28)
- fix(ci): build Hypatia escript from repo root (estate dogfood drift)
- fix(ci): Phase-2 fleet submission must not fail the security gate (#25)
- fix(ci): rsr-antipattern.yml duplicate heredoc (#24)
- fix: remove boilerplate README, fix ABI template, harden CI (#2)
- fix: remove boilerplate README, fix ABI template, harden CI
- fix: create missing metrics.jl, fix README, rate limiter, and Ada parser (#1)

### Changed

- refactor: split llm_client, wire aperture control, expand tests

### Documentation

- docs(readme): add SPDX header, OSSF and GWF badges
- docs(explainme): add EXPLAINME.adoc
- docs: remove conflicting placeholder README and fix license declarations

### CI

- ci: bump actions/upload-artifact SHA to current v4 (#23)
- ci(antipattern): fix top-level dir matching + benchmarks/lsp/bench filename allowlists (#17)
- ci(antipattern): TS check reads .claude/CLAUDE.md exemption table (#16)
- ci(antipattern): broaden TS allowlist (cli/, mod.ts, lsp-server, *vscode*, deno-*) (#15)
- ci(antipattern): allowlist legit TS bridge/adapter paths (#14)

## Pre-history

Prior commits to this file's introduction are recorded in git history but not formally classified into Keep-a-Changelog sections. To backfill, run `git cliff -o CHANGELOG.md` locally using the canonical [`cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml) — this is one-shot mechanical work.

---

<!-- This file was seeded by the 2026-05-26 estate tech-debt audit follow-up (Row-2 Phase 3); see [`hyperpolymath/standards/docs/audits/2026-05-26-estate-documentation-debt.md`](https://github.com/hyperpolymath/standards/blob/main/docs/audits/2026-05-26-estate-documentation-debt.md). -->
