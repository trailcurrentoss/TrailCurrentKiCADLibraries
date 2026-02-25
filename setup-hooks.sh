#!/bin/bash
# Setup script for git hooks
# Points git at the versioned .githooks/ directory instead of copying files

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

if [ ! -d "$REPO_ROOT/.githooks" ]; then
    echo "Error: .githooks directory not found"
    exit 1
fi

git config core.hooksPath .githooks

echo "Pre-commit hook enabled."
echo "Commits will be checked for absolute paths, credentials, and local dev files."
