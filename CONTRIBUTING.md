# Contributing to The Jeff Paradox

Thank you for your interest in contributing!

## Quick Start

```bash
# Clone
git clone https://github.com/Hyperpolymath/thejeffparadox.git
cd thejeffparadox

# Install dependencies
just install

# Run tests
just test

# Build
just build
```

## Contribution Guidelines

### Code Style

- **Actions**: All GitHub Actions must be SHA-pinned (no `@v4`, use full SHA)
- **No npm/node**: We use Deno for JavaScript tooling if needed
- **Julia**: Follow standard Julia style guidelines
- **Shell**: Must pass ShellCheck

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Ensure CI passes (`just ci`)
5. Submit a PR to `main`

### Commit Messages

Use conventional commits:

```
feat: add new anti-convergence mechanism
fix: correct embedding dimension mismatch
docs: update README with new instructions
chore: upgrade dependencies
```

### What We Need Help With

- **Documentation**: Improve explanations, fix typos
- **Testing**: Add test coverage for Julia engine
- **Accessibility**: Improve WCAG compliance
- **Translations**: i18n support for Hugo sites
- **Analysis**: Help interpret conversation metrics

## RSR Compliance

This project follows [Rhodium Standard Repository](https://gitlab.com/hyperpolymath/rhodium-standard-repositories) guidelines:

- SHA-pinned dependencies
- Offline-first architecture
- Post-JavaScript liberation (no npm)
- Formal verification where possible

## Questions?

Open an issue or discussion. We're happy to help!
