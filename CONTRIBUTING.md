# Clone the repository
git clone https://github.com/hyperpolymath/thejeffparadox.git
cd thejeffparadox

# Install Julia dependencies
cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'
cd ..

# Or using toolbox/distrobox
toolbox create thejeffparadox-dev
toolbox enter thejeffparadox-dev
# Install: Julia 1.10+, Hugo extended 0.120+, optionally GNAT/Alire

# Verify setup
just test    # Run all 6 test targets
```

### Repository Structure
```
thejeffparadox/
├── engine/              # Julia - Game mechanics, LLM APIs, metrics
│   ├── src/             # Source modules
│   └── test/            # Julia test suite
├── node-alpha/          # Hugo - Homeward faction fragment
├── node-beta/           # Hugo - Earthbound faction fragment
├── orchestrator/        # Hugo - Game Master, public rendering
├── tui/                 # Ada - Terminal UI for experiment control
├── container/           # Podman/Wolfi - Containerised deployment
├── ffi/                 # Zig - C-compatible FFI bindings
├── contractiles/        # Contract templates (must/trust/dust/lust)
├── papers/              # Research - Whitepaper, references
├── scripts/             # Shell - Orchestration scripts
├── tests/               # Structural validation scripts
├── docs/                # Documentation
│   └── wiki/            # Architecture, FAQ, philosophy guides
├── examples/            # Example code (ReScript, etc.)
├── .github/             # GitHub config
│   ├── ISSUE_TEMPLATE/
│   └── workflows/       # 20+ CI/CD workflows
├── CHANGELOG.adoc
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md      # This file
├── GOVERNANCE.md
├── LICENSE
├── MAINTAINERS.md
├── README.adoc
├── SECURITY.md
└── Justfile             # Task runner (6 Grade B test targets)
```

---

## How to Contribute

### Reporting Bugs

**Before reporting**:
1. Search existing issues
2. Check if it's already fixed in `main`
3. Determine which perimeter the bug affects

**When reporting**:

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) and include:

- Clear, descriptive title
- Environment details (OS, versions, toolchain)
- Steps to reproduce
- Expected vs actual behaviour
- Logs, screenshots, or minimal reproduction

### Suggesting Features

**Before suggesting**:
1. Check the [roadmap](ROADMAP.md) if available
2. Search existing issues and discussions
3. Consider which perimeter the feature belongs to

**When suggesting**:

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) and include:

- Problem statement (what pain point does this solve?)
- Proposed solution
- Alternatives considered
- Which perimeter this affects

### Your First Contribution

Look for issues labelled:

- [`good first issue`](https://github.com/hyperpolymath/thejeffparadox/labels/good%20first%20issue) — Simple Perimeter 3 tasks
- [`help wanted`](https://github.com/hyperpolymath/thejeffparadox/labels/help%20wanted) — Community help needed
- [`documentation`](https://github.com/hyperpolymath/thejeffparadox/labels/documentation) — Docs improvements
- [`perimeter-3`](https://github.com/hyperpolymath/thejeffparadox/labels/perimeter-3) — Community sandbox scope

---

## Development Workflow

### Branch Naming
```
docs/short-description       # Documentation (P3)
test/what-added              # Test additions (P3)
feat/short-description       # New features (P2)
fix/issue-number-description # Bug fixes (P2)
refactor/what-changed        # Code improvements (P2)
security/what-fixed          # Security fixes (P1-2)
```

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):
```
<type>(<scope>): <description>

[optional body]

[optional footer]
