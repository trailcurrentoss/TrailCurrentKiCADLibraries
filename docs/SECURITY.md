# Security: Pre-Commit Hooks

This repository includes automated security checks to prevent accidental commits of sensitive information.

## What the Pre-Commit Hook Does

The pre-commit hook automatically scans staged files for:

- **Personal file paths** - Absolute paths to user home or mount directories
- **Credentials and secrets** - Passwords, API keys, tokens, private keys
- **Local development files** - `CLAUDE.md`, `.claude/` folder
- **Suspicious patterns** - Keywords like `password=`, `secret=`, `token=`, AWS keys, etc.

If violations are found, the commit is blocked with a clear error message.

## Installation

The hook is ready to use. Install it with:

```bash
./setup-hooks.sh
```

This copies the hook from `.githooks/pre-commit` to `.git/hooks/pre-commit` and makes it executable.

## What to Do If the Hook Blocks Your Commit

### Option 1: Fix the Issue (Recommended)

If the hook detected sensitive information:

1. Review the error message
2. Locate and fix the file
3. Stage the corrected file
4. Commit again

Example:
```bash
# Hook blocked commit due to hardcoded path
git diff --cached  # See what's staged
# Edit the file to remove the hardcoded path references
git add path/to/file
git commit -m "Fix hardcoded paths"
```

### Option 2: Review Before Committing

```bash
# See all staged changes
git diff --cached

# See specific file
git diff --cached path/to/file

# Unstage if needed
git reset HEAD path/to/file
```

## What Should Never Be Committed

Never commit files containing:

- Absolute paths to user home or mount directories
- User-specific directory references
- API keys or tokens
- Passwords or credentials
- Private SSH keys
- Secrets files

## If You Need to Bypass (Not Recommended)

If you have a legitimate reason to bypass the hook:

```bash
git commit --no-verify -m "message"
```

**Warning:** Use `--no-verify` only in exceptional cases. It disables all security checks.

## Customizing the Hook

To modify what the hook checks:

1. Edit `.githooks/pre-commit`
2. Run `./setup-hooks.sh` to reinstall
3. Test with a dummy commit

## Testing the Hook

Test the hook by staging a file containing an absolute user path, then attempting a commit. The hook should block it with a clear error message.

## Disabling the Hook Temporarily

If you need to temporarily disable the hook:

```bash
# Disable
chmod -x .git/hooks/pre-commit

# Re-enable
chmod +x .git/hooks/pre-commit
```

## Hook Files

- `.githooks/pre-commit` - The actual hook script (versioned in git)
- `.git/hooks/pre-commit` - Installed copy (created by `setup-hooks.sh`)
- `setup-hooks.sh` - Script to install the hook

The `.githooks/` directory is versioned, so all team members get the same hook. The `.git/hooks/` directory is local to each clone.

## Questions or Issues?

If the hook is too strict or blocks legitimate commits:

1. Check if the file should be in `.gitignore`
2. Review the error message
3. Ensure the file doesn't contain actual sensitive information

## Related Files

- [KICAD_CHECKLIST.md](KICAD_CHECKLIST.md) - Security best practices
- [../.gitignore](../.gitignore) - Files excluded from git
