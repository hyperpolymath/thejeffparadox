#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# validate_structure.sh — CRG Grade B structural check for thejeffparadox
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Required root files
[ -f README.adoc ]          && pass "README.adoc present"           || fail "README.adoc missing"
[ -f LICENSE ]              && pass "LICENSE present"                || fail "LICENSE missing"
[ -f SECURITY.md ]          && pass "SECURITY.md present"           || fail "SECURITY.md missing"
[ -f ABI-FFI-README.md ]    && pass "ABI-FFI-README.md present"     || fail "ABI-FFI-README.md missing"

# Required directories and key files
[ -d engine ]                       && pass "engine/ directory present"               || fail "engine/ directory missing"
[ -f engine/test/runtests.jl ]      && pass "engine/test/runtests.jl present"        || fail "engine/test/runtests.jl missing"
[ -d node-alpha ]                   && pass "node-alpha/ directory present"           || fail "node-alpha/ directory missing"
[ -d node-beta ]                    && pass "node-beta/ directory present"            || fail "node-beta/ directory missing"
[ -d orchestrator ]                 && pass "orchestrator/ directory present"         || fail "orchestrator/ directory missing"

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
