# TEST-NEEDS.md — CRG Grade B Test Documentation

## Grade B Status: 6 Test Targets

This file documents the six independently runnable test targets required for CRG Grade B compliance.

| Target | Justfile Recipe | Description | Pass Criterion |
|--------|-----------------|-------------|----------------|
| T1 | `just test-engine` | Julia engine tests (`engine/test/runtests.jl`) | All `@testset` assertions pass (skipped if julia absent) |
| T2 | `just test-zig` | Zig FFI integration test (`ffi/zig/test/integration_test.zig`) | Zig test exits 0 (skipped if zig absent) |
| T3 | `just test-structure` | Structural validation (`tests/validate_structure.sh`) | All required files/dirs present; ≥3 workflows |
| T4 | `just test-nickel` | Nickel k9 contractile typecheck | `nickel typecheck` exits 0 (skipped if nickel absent) |
| T5 | `just test-hugo-check` | Hugo config validation for node-alpha and node-beta | Both configs present with required fields |
| T6 | `just test-orchestrator` | Orchestrator structural check (`tests/validate_orchestrator.sh`) | orchestrator/ has content/, data/, layouts/, and valid hugo.toml |

## Running All Targets

```bash
just test
```

## Individual Targets

```bash
just test-engine
just test-zig
just test-structure
just test-nickel
just test-hugo-check
just test-orchestrator
```

## Notes

- T1 and T2 degrade gracefully when `julia` or `zig` are not installed — emit `SKIP:` and exit 0.
- T4 degrades gracefully when `nickel` is not installed.
- T4 strips the `K9!` header from the k9 template file before passing to `nickel typecheck` (the header is a k9 DSL marker, not valid Nickel).
- T5 accepts either `hugo.toml` or `config.toml` for both node-alpha and node-beta.
