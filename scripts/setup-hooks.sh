#!/usr/bin/env bash
# Setup git hooks for The Jeff Paradox
# Run this after cloning the repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.githooks"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "Setting up git hooks..."

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "ERROR: Not a git repository. Run from project root."
    exit 1
fi

# Configure git to use our hooks directory
git config core.hooksPath .githooks

echo "Git hooks configured successfully!"
echo ""
echo "Installed hooks:"
for hook in "$HOOKS_DIR"/*; do
    if [ -f "$hook" ]; then
        chmod +x "$hook"
        echo "  - $(basename "$hook")"
    fi
done

echo ""
echo "To disable hooks temporarily, use: git commit --no-verify"
