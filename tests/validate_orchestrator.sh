#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# validate_orchestrator.sh — CRG Grade B: check orchestrator/ structural integrity
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Required orchestrator structure
[ -d orchestrator ]               && pass "orchestrator/ directory present"           || fail "orchestrator/ directory missing"
[ -d orchestrator/content ]       && pass "orchestrator/content/ present"             || fail "orchestrator/content/ missing"
[ -d orchestrator/data ]          && pass "orchestrator/data/ present"                || fail "orchestrator/data/ missing"
[ -d orchestrator/layouts ]       && pass "orchestrator/layouts/ present"             || fail "orchestrator/layouts/ missing"

# Hugo config
ORCH_CONFIG=""
if [ -f "orchestrator/hugo.toml" ]; then
    ORCH_CONFIG="orchestrator/hugo.toml"
elif [ -f "orchestrator/config.toml" ]; then
    ORCH_CONFIG="orchestrator/config.toml"
fi

if [ -n "$ORCH_CONFIG" ]; then
    pass "orchestrator Hugo config found: $ORCH_CONFIG"
    if grep -q "baseURL" "$ORCH_CONFIG"; then
        pass "orchestrator config has baseURL"
    else
        fail "orchestrator config missing baseURL"
    fi
    if grep -q "title" "$ORCH_CONFIG"; then
        pass "orchestrator config has title"
    else
        fail "orchestrator config missing title"
    fi
else
    fail "orchestrator Hugo config (hugo.toml or config.toml) missing"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
