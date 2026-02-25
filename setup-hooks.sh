#!/bin/bash
# Setup script for git hooks
# Installs pre-commit hook to prevent accidental commits of sensitive data

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

HOOKS_DIR="$REPO_ROOT/.git/hooks"
HOOK_SOURCE="$REPO_ROOT/.githooks/pre-commit"
HOOK_TARGET="$HOOKS_DIR/pre-commit"

# Check if hook source exists
if [ ! -f "$HOOK_SOURCE" ]; then
    echo "Error: Hook source not found at $HOOK_SOURCE"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Copy and setup hook
echo "Installing pre-commit hook..."
cp "$HOOK_SOURCE" "$HOOK_TARGET"
chmod +x "$HOOK_TARGET"

if [ -f "$HOOK_TARGET" ] && [ -x "$HOOK_TARGET" ]; then
    echo "✓ Pre-commit hook installed successfully"
    echo "  Location: $HOOK_TARGET"
    echo ""
    echo "The hook will now automatically check for:"
    echo "  - Personal file paths (absolute paths to user directories)"
    echo "  - Credentials and secrets"
    echo "  - Local development files (CLAUDE.md, .claude/)"
    echo ""
    echo "To test the hook:"
    echo "  git commit -m 'Test commit'"
    exit 0
else
    echo "Error: Failed to install pre-commit hook"
    exit 1
fi
