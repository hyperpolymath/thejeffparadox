# Support

## Getting Help

### Documentation

Start with our documentation:

- **[README.md](/README.md)**: Project overview and quick start
- **[claude.adoc](/claude.adoc)**: Full technical specification
- **[Wiki](/docs/wiki/)**: Comprehensive guides and explanations
- **[API Documentation](/docs/api/)**: Engine API reference

### Community

- **[GitHub Discussions](https://github.com/Hyperpolymath/thejeffparadox/discussions)**:
  Best place for questions, ideas, and conversation
  - Q&A: Technical questions
  - Ideas: Feature suggestions
  - Show and Tell: Share what you've built
  - General: Everything else

- **[Issues](https://github.com/Hyperpolymath/thejeffparadox/issues)**:
  Bug reports and feature requests only

### Categories

| Need | Where to Go |
|------|-------------|
| Question about usage | Discussions → Q&A |
| Bug report | Issues → Bug Report |
| Feature request | Issues → Feature Request |
| Security vulnerability | [SECURITY.md](SECURITY.md) |
| Philosophical discussion | Discussions → General |
| Contribution help | Discussions → Q&A |

## Self-Help Resources

### Common Issues

#### Julia Environment

```bash
# If packages fail to load
cd engine
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# If you get precompilation errors
julia --project=. -e 'using Pkg; Pkg.precompile()'
```

#### Hugo Build

```bash
# If Hugo build fails
hugo version  # Check you have extended version

# Clean build
rm -rf public resources
hugo --gc --minify
```

#### API Keys

```bash
# Verify API keys are set
echo $ANTHROPIC_API_KEY | head -c 10
echo $MISTRAL_API_KEY | head -c 10

# Keys should start with appropriate prefixes
# Anthropic: sk-ant-
# Mistral: varies
```

### Debugging

#### Enable Verbose Logging

```bash
# Run with debug output
JULIA_DEBUG=JeffEngine julia --project=engine scripts/run_turn.jl

# Hugo verbose
hugo --verbose
```

#### Check Metrics

```bash
./scripts/metrics_report.sh
```

## Response Times

This is a volunteer-run research project. Please be patient:

| Channel | Typical Response |
|---------|------------------|
| Security issues | 48 hours |
| Bug reports | 1 week |
| Feature requests | Variable |
| Questions | Community-dependent |

## What NOT to Do

- **Don't email maintainers directly** (except for security issues)
- **Don't open issues for questions** (use Discussions)
- **Don't ask the same question multiple times**
- **Don't be rude** (see [Code of Conduct](CODE_OF_CONDUCT.md))

## Commercial Support

There is no commercial support for this project. It is a research experiment.

If you need enterprise-grade LLM personality measurement, this is not the
project for you. This is philosophy, not product.

---

*"The opinions and beliefs expressed do not represent anyone.
They are the hallucinations of a slab of silicon."*
