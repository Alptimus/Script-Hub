---
name: Shell Script Review & Conventions
description: "Use when reviewing, creating, or modifying bash scripts in Script-Hub. Quick checklist for safety, quoting, error handling, and alignment with project conventions."
applyTo: "**/*.sh"
---

# Shell Script Review Checklist

When working with bash scripts in Script-Hub, use this checklist to ensure consistency and safety.

## Safety & Error Handling

- [ ] Script starts with `#!/bin/bash`
- [ ] `set -e` present to exit on errors
- [ ] `set -o pipefail` present if using pipes
- [ ] All variables are quoted: `"$var"` not `$var`
- [ ] Command existence verified before use: `command -v cmd &> /dev/null`
- [ ] Errors produce informative messages to stderr: `>&2`
- [ ] Error paths tested (missing dependencies, missing directories)

## Progress & Logging

- [ ] Each significant step has a progress message via `echo`
- [ ] Timestamps included for long-running operations: `[$(date +'%Y-%m-%d %H:%M:%S')]`
- [ ] Cleanup happens on exit via `trap cleanup EXIT INT`
- [ ] Temp files created in `/tmp` and properly cleaned up

## Structure & Documentation

- [ ] Script header includes brief description of purpose
- [ ] Dependencies listed in header comment: `# Requires: sudo, rsync`
- [ ] Usage examples provided in header or README
- [ ] Inline comments explain non-obvious logic
- [ ] File follows naming convention: lowercase with hyphens (e.g., `daily-update.sh`)

## Common Patterns

- [ ] Conditional checks for optional tools: `if command -v flatpak &> /dev/null; then ...`
- [ ] Environment variables validated: `if [[ -z "$HOME" ]]; then ... exit 1; fi`
- [ ] Destructive operations support dry-run: `DRY_RUN=1 ./script.sh`
- [ ] Return codes checked explicitly or via `set -e`

## Anti-Patterns to Avoid

- ❌ Piping to `sh`: `curl ... | sh` (instead, download then execute)
- ❌ Unquoted variables: `$var` (use `"$var"`)
- ❌ Hardcoded system paths: `/opt/app/run` (check existence or use which)
- ❌ Silent failures: commands without `set -e` or error checks
- ❌ No pipeline error handling: pipes without `set -o pipefail`

## Quick Fixes

### Missing safety header
```bash
# Add to top of script:
#!/bin/bash
set -e
set -o pipefail
```

### Unquoted variables
```bash
# Bad:
echo $var

# Good:
echo "$var"
```

### Command not found handling
```bash
# Use:
if ! command -v rsync &> /dev/null; then
    echo "Error: rsync not found" >&2
    exit 1
fi
```

### Cleanup on exit
```bash
# Add to script:
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT INT TERM
```

---

## References

For detailed patterns and examples, see [.github/copilot-instructions.md](../copilot-instructions.md).

For generating new scripts, use the [new-script prompt](.github/prompts/new-script.prompt.md).
