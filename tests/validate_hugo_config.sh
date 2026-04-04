#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# validate_hugo_config.sh — CRG Grade B: check node-alpha and node-beta Hugo configs
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Check node-alpha Hugo config
ALPHA_CONFIG=""
if [ -f "node-alpha/hugo.toml" ]; then
    ALPHA_CONFIG="node-alpha/hugo.toml"
elif [ -f "node-alpha/config.toml" ]; then
    ALPHA_CONFIG="node-alpha/config.toml"
fi

if [ -n "$ALPHA_CONFIG" ]; then
    pass "node-alpha config found: $ALPHA_CONFIG"
    # Check required Hugo fields
    if grep -q "baseURL" "$ALPHA_CONFIG"; then
        pass "node-alpha config has baseURL"
    else
        fail "node-alpha config missing baseURL"
    fi
    if grep -q "title" "$ALPHA_CONFIG"; then
        pass "node-alpha config has title"
    else
        fail "node-alpha config missing title"
    fi
else
    fail "node-alpha Hugo config (hugo.toml or config.toml) missing"
fi

# Check node-beta Hugo config
BETA_CONFIG=""
if [ -f "node-beta/hugo.toml" ]; then
    BETA_CONFIG="node-beta/hugo.toml"
elif [ -f "node-beta/config.toml" ]; then
    BETA_CONFIG="node-beta/config.toml"
fi

if [ -n "$BETA_CONFIG" ]; then
    pass "node-beta config found: $BETA_CONFIG"
    if grep -q "baseURL" "$BETA_CONFIG"; then
        pass "node-beta config has baseURL"
    else
        fail "node-beta config missing baseURL"
    fi
    if grep -q "title" "$BETA_CONFIG"; then
        pass "node-beta config has title"
    else
        fail "node-beta config missing title"
    fi
else
    fail "node-beta Hugo config (hugo.toml or config.toml) missing"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
