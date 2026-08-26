#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# validate_structure.sh — CRG Grade B structural check for thejeffparadox
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Required root files
if [ -f README.adoc ]; then
  pass "README.adoc present"
else
  fail "README.adoc missing"
fi
if [ -f LICENSE ]; then
  pass "LICENSE present"
else
  fail "LICENSE missing"
fi
if [ -f SECURITY.md ]; then
  pass "SECURITY.md present"
else
  fail "SECURITY.md missing"
fi
if [ -f ABI-FFI-README.adoc ]; then
  pass "ABI-FFI-README.adoc present"
else
  fail "ABI-FFI-README.adoc missing"
fi

# Required directories and key files
if [ -d engine ]; then
  pass "engine/ directory present"
else
  fail "engine/ directory missing"
fi
if [ -f engine/test/runtests.jl ]; then
  pass "engine/test/runtests.jl present"
else
  fail "engine/test/runtests.jl missing"
fi
if [ -d node-alpha ]; then
  pass "node-alpha/ directory present"
else
  fail "node-alpha/ directory missing"
fi
if [ -d node-beta ]; then
  pass "node-beta/ directory present"
else
  fail "node-beta/ directory missing"
fi
if [ -d orchestrator ]; then
  pass "orchestrator/ directory present"
else
  fail "orchestrator/ directory missing"
fi

# GitHub workflows — require at least 3
WORKFLOW_COUNT=0
if [ -d .github/workflows ]; then
    WORKFLOW_COUNT=$(find .github/workflows -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) | wc -l)
fi
if [ "$WORKFLOW_COUNT" -ge 3 ]; then
    pass ".github/workflows/ has $WORKFLOW_COUNT workflow files (≥3 required)"
else
    fail ".github/workflows/ has only $WORKFLOW_COUNT workflow files (≥3 required)"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
