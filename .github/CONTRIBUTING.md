# Contributing to The Jeff Paradox

First off, thank you for considering contributing to The Jeff Paradox! This is
an experimental project at the intersection of philosophy, AI research, and
software engineering.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [What We're Looking For](#what-were-looking-for)
- [What We're Not Looking For](#what-were-not-looking-for)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Philosophical Contributions](#philosophical-contributions)

## Code of Conduct

This project and everyone participating in it is governed by our
[Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to
uphold this code. Please report unacceptable behaviour to conduct@example.com.

## What We're Looking For

### High Priority

- **Anti-convergence mechanisms**: Novel approaches to prevent the conversation
  from collapsing into repetitive patterns
- **Emergence detection**: Better metrics for identifying genuinely novel
  patterns in the dialogue
- **Accessibility improvements**: WCAG compliance, screen reader testing
- **Security hardening**: CSP improvements, vulnerability scanning
- **Philosophical framework**: Rigorous analysis of what the experiment can and
  cannot show

### Medium Priority

- **Visualisation**: Real-time dashboards for metrics
- **Documentation**: Tutorials, explanations, wiki content
- **Testing**: Unit tests, integration tests, property-based tests
- **Performance**: Optimisation of metrics computation

### Always Welcome

- Bug reports with reproduction steps
- Documentation corrections
- Accessibility testing reports
- Security vulnerability reports (see [SECURITY.md](SECURITY.md))

## What We're Not Looking For

- **Prompt injection attempts**: Do not try to manipulate the AI nodes
- **Jailbreaking**: Do not attempt to bypass safety measures
- **Claims of AI sentience**: This experiment investigates the question; it
  doesn't presuppose an answer
- **Dependencies on Python, Node.js, or TypeScript**: We're deliberately
  avoiding these

## Getting Started

### Prerequisites

- **Julia 1.9+**: For the game engine
- **Hugo extended 0.120+**: For static site generation
- **Git**: For version control
- **Make** (optional): For convenience commands

### Fork and Clone

```bash
# Fork via GitHub UI first, then:
git clone https://github.com/YOUR_USERNAME/thejeffparadox.git
cd thejeffparadox
git remote add upstream https://github.com/Hyperpolymath/thejeffparadox.git
```

### Development Setup

```bash
# Install Julia dependencies
cd engine
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Run tests
julia --project=. -e 'using Pkg; Pkg.test()'

# Build Hugo site
cd ../orchestrator
hugo server --buildDrafts
```

## Making Changes

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation only
- `refactor/description` - Code refactoring
- `test/description` - Adding tests
- `security/description` - Security improvements

### Workflow

1. Create a branch from `main`
2. Make your changes
3. Write/update tests as needed
4. Ensure all tests pass
5. Update documentation if needed
6. Submit a pull request

## Style Guidelines

### Julia

```julia
# Use 4-space indentation
# Use snake_case for functions and variables
# Use PascalCase for types
# Document public functions with docstrings

"""
    compute_metrics(game::GameState) -> Dict{String,Any}

Compute all metrics for current game state.

# Arguments
- `game::GameState`: The current game state

# Returns
- `Dict{String,Any}`: Dictionary of metric names to values
"""
function compute_metrics(game::GameState)::Dict{String,Any}
    # Implementation
end
```

### Hugo Templates

```html
{{/* Use semantic HTML5 */}}
{{/* Include ARIA attributes for accessibility */}}
{{/* Comment complex logic */}}

<article role="article" aria-labelledby="heading-{{ .Params.turn }}">
  <h2 id="heading-{{ .Params.turn }}">{{ .Title }}</h2>
  {{/* Content */}}
</article>
```

### Shell Scripts

```bash
#!/usr/bin/env bash
# Use bash, not sh
# Use set -euo pipefail
# Quote variables
# Use shellcheck

set -euo pipefail

log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*"
}
```

### CSS

```css
/* Use CSS custom properties */
/* Mobile-first responsive design */
/* Minimum 7:1 contrast ratio (AAA) */
/* Support prefers-reduced-motion */
/* Support prefers-color-scheme */

:root {
  --color-text: #1a1a1a;
  --color-bg: #fefefe;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-text: #f0f0f0;
    --color-bg: #1a1a1a;
  }
}
```

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding tests
- `chore`: Maintenance tasks
- `security`: Security improvements

### Examples

```
feat(conceptors): add aperture control based on vocabulary diversity

Implements temperature modulation that widens aperture (increases temperature)
when vocabulary diversity drops below threshold, encouraging exploration.

Closes #42
```

```
fix(metrics): correct convergence index calculation

The previous implementation used union instead of intersection for the
numerator, giving inverted results.

Fixes #37
```

## Pull Request Process

1. **Title**: Use conventional commit format
2. **Description**: Fill out the PR template completely
3. **Tests**: Ensure all tests pass
4. **Documentation**: Update if needed
5. **Review**: Wait for at least one approval
6. **Merge**: Squash and merge preferred

### PR Checklist

- [ ] I have read the contributing guidelines
- [ ] My code follows the project's style guidelines
- [ ] I have added tests for my changes
- [ ] All new and existing tests pass
- [ ] I have updated documentation as needed
- [ ] My changes generate no new warnings
- [ ] I have checked my code for accessibility issues

## Reporting Bugs

### Before Submitting

1. Check the [issue tracker](https://github.com/Hyperpolymath/thejeffparadox/issues)
   for existing reports
2. Check the [discussions](https://github.com/Hyperpolymath/thejeffparadox/discussions)
   for known issues

### Bug Report Template

Use the bug report issue template. Include:

- Clear, descriptive title
- Steps to reproduce
- Expected behaviour
- Actual behaviour
- Environment details (OS, Julia version, Hugo version)
- Relevant logs or screenshots

## Suggesting Enhancements

### Enhancement Proposal Process

1. **Discussion first**: Open a discussion to gauge interest
2. **Issue creation**: If there's support, create a feature request issue
3. **Design document**: For significant changes, write a design doc
4. **Implementation**: Submit PR referencing the issue

### What Makes a Good Enhancement

- Aligned with project goals (investigating LLM diachronic identity)
- Doesn't introduce Python/Node/TypeScript dependencies
- Maintains accessibility standards
- Includes tests and documentation

## Philosophical Contributions

This project has a philosophical dimension. We welcome:

- **Literature reviews**: Relevant work on identity, consciousness, persistence
- **Conceptual analysis**: What would it mean for an LLM to have diachronic identity?
- **Methodology critique**: What can this experiment actually show?
- **Interpretation frameworks**: How should we interpret the results?

### Guidelines for Philosophical Contributions

- Be rigorous: Cite sources, define terms, acknowledge limitations
- Be humble: The question is open; don't claim certainty
- Be relevant: Connect abstract ideas to the concrete experiment
- Be accessible: Write for a technical audience that may not be philosophy experts

## Questions?

- **General questions**: [Discussions](https://github.com/Hyperpolymath/thejeffparadox/discussions)
- **Bug reports**: [Issues](https://github.com/Hyperpolymath/thejeffparadox/issues)
- **Security issues**: [SECURITY.md](SECURITY.md)
- **Code of conduct**: conduct@example.com

---

Thank you for contributing to The Jeff Paradox!
