---
name: Script-Hub Agent Instructions
description: "Guide for creating, reviewing, and maintaining bash scripts in the Script-Hub repository. Use when working with shell scripts, system administration tasks, or automating Linux operations."
---

# Script-Hub Development Guide

## Project Purpose

**Script-Hub** is a personal collection of Bash scripts for daily system administration and automation. Each script handles specific tasks:
- System updates and maintenance
- Development environment setup
- System configuration and cleanup

This is a **working repository**, updated as new tasks or patterns emerge.

## Script Structure & Conventions

### File Naming
- Use lowercase with hyphens: `daily-update.sh`, `get-docker.sh`
- Avoid underscores; prefer hyphens for multi-word names

### Script Header & Safety
Every script should include:
```bash
#!/bin/bash
set -e  # Exit on error
# Brief description of what the script does
```

**Key safety practices:**
- Always use `set -e` to exit immediately on errors
- Use `set -o pipefail` if piping commands
- Quote variables: `"$var"` not `$var`
- Validate commands exist before running: `if command -v flatpak &> /dev/null; then ...`

### Error Handling & User Feedback
- Use `echo` statements to log progress: `echo "Updating package lists..."`
- Prefix destructive operations with confirmation or clear messaging
- Test with dry-run flags when applicable (e.g., `apt`, `flatpak`)

### Example Pattern
```bash
#!/bin/bash
set -e

echo "Starting task..."
sudo apt update -y
echo "Task complete."
```

## Key Scripts

| Script | Purpose | Frequency |
|--------|---------|-----------|
| `daily_update.sh` | System package updates (apt, flatpak) and cleanup | Daily |
| `get-docker.sh` | Docker Engine installation (official Docker script) | As-needed |

**Note:** `get-docker.sh` is maintained by Docker; any changes should preserve its integrity as a baseline reference.

## Development Workflow

### Adding a New Script
1. Create file with `.sh` extension, following naming convention
2. Add `#!/bin/bash` header and `set -e`
3. Include comment summarizing script purpose
4. Add progress messages for each significant step
5. Test locally before committing
6. Update README.md with script description

### Testing Scripts
- Test in a non-production environment or container
- Verify all error paths (e.g., missing dependencies)
- Check that progress messages are clear
- Ensure safe exit behavior with `set -e`

### Updating the README
Keep README.md in sync with available scripts. Include:
- Brief description of each script
- Usage instructions
- Any prerequisites or warnings

## Script Lifecycle

### Versioning & Updates
- Mark breaking changes clearly in comments: `# v2.0: Changed default behavior (see README)`
- Include a version comment near the top: `# script version: 1.2`
- Document change history inline or in README for important updates

### Deprecation
- If retiring a script, rename with `.deprecated` suffix: `old-script.deprecated.sh`
- Add deprecation notice at the top: `# DEPRECATED: Use new-script.sh instead`
- Keep in repository for reference but do not execute in automation

### Testing Before Commit
- Test locally in a safe environment (container, non-production machine)
- For destructive operations (apt upgrade, cleanup), verify with dry-run mode first
- Check error paths: missing dependencies, missing directories, insufficient permissions
- Verify progress messages are clear and appear at expected intervals

## Common Patterns to Follow

### Conditional Installation Checks
```bash
if command -v flatpak &> /dev/null; then
    flatpak update -y
else
    echo "Flatpak not found, skipping..."
fi
```

### Dependency Verification
Always verify dependencies before using them:
```bash
# Check for required commands
for cmd in apt flatpak sudo; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd not found. Install it and try again."
        exit 1
    fi
done
```

### Logging & Output
- Prefix status messages with timestamps for audit trails: `echo "[$(date +'%Y-%m-%d %H:%M:%S')] Updating packages..."`
- Log to both console and file for critical operations:
```bash
LOG_FILE="/var/log/script-hub.log"
echo "Task started" | tee -a "$LOG_FILE"
```
- Use `>&2` for error messages to send them to stderr: `echo "Error: failed to update" >&2`

### Environment Variables
- Export variables needed by subprocesses: `export DEBIAN_FRONTEND=noninteractive`
- Use default values for optional vars: `TIMEOUT=${TIMEOUT:-30}`
- Validate environment before proceeding:
```bash
if [[ -z "$HOME" ]]; then
    echo "Error: HOME not set" >&2
    exit 1
fi
```

### Signal Handling & Cleanup
Trap signals to ensure cleanup happens:
```bash
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f "$TEMP_FILE"
    exit 0
}
trap cleanup EXIT INT TERM
```

### Privilege Escalation
- Use `sudo` for operations requiring root
- Make privilege requirements explicit in documentation
- Consider adding a header comment: `# Requires: sudo privileges`
- Verify sudo availability: `if ! sudo -n true 2>/dev/null; then echo "sudo not available"; exit 1; fi`

### Piping & Error Propagation
Always use `set -o pipefail` when combining `set -e` with pipes:
```bash
#!/bin/bash
set -e
set -o pipefail

# This will now exit if grep fails, even in a pipeline
cat large-file.txt | grep "pattern" | wc -l
```

### Script Testing & Dry-Run Mode
Support a dry-run mode for destructive operations:
```bash
# Usage: DRY_RUN=1 ./daily_update.sh
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[DRY RUN] Would execute: sudo apt update -y"
else
    sudo apt update -y
fi
```

## Anti-Patterns to Avoid

### Critical Safety Issues
- ❌ **Piping to `sh` directly** — Never use `curl ... | sh`. Always download to a file, review, then execute:
  ```bash
  # Bad:
  curl https://get.docker.com | sh
  
  # Good:
  curl -o get-docker.sh https://get.docker.com && bash get-docker.sh
  ```

- ❌ **Ignoring errors silently** — Always use `set -e` or explicit error checks:
  ```bash
  # Bad: silently continues if apt fails
  apt update
  apt install -y package
  
  # Good: exits immediately on error
  set -e
  apt update
  apt install -y package
  ```

- ❌ **Forgetting `set -o pipefail` with pipes** — Without it, `set -e` won't catch failures in piped commands:
  ```bash
  # Bad: grep failure is silent
  set -e
  cat file.txt | grep "pattern" | sort  # If grep fails, it doesn't exit
  
  # Good: grep failure causes exit
  set -e
  set -o pipefail
  cat file.txt | grep "pattern" | sort  # Now it exits on any failure
  ```

### Code Quality Issues
- ❌ **Unquoted variables** — Leads to word splitting and globbing bugs:
  ```bash
  # Bad: $var is split and expanded
  echo $var
  
  # Good: preserves exact value
  echo "$var"
  ```

- ❌ **Hardcoding paths** that may differ across systems:
  ```bash
  # Bad: assumes path
  /opt/appname/run.sh
  
  # Good: check existence or use which
  if [[ -f /opt/appname/run.sh ]]; then /opt/appname/run.sh; fi
  ```

- ❌ **Missing progress feedback** — Users should know what's happening:
  ```bash
  # Bad: no output, user thinks it hung
  sudo apt update && sudo apt upgrade -y
  
  # Good: clear progress
  echo "Updating package lists..."
  sudo apt update -y
  echo "Upgrading packages..."
  sudo apt upgrade -y
  ```

- ❌ **No error context** — Errors should be informative:
  ```bash
  # Bad: vague error
  cd /nonexistent 2>/dev/null || exit 1
  
  # Good: specific error message
  cd /nonexistent || { echo "Error: directory not found" >&2; exit 1; }
  ```

## Quick Reference: Related Files

- [README.md](../../README.md) — Project overview and script descriptions
- [LICENSE](../../LICENSE) — Repository license

---

**For questions about script patterns, error handling, or adding new automation, refer to this guide or ask for help reviewing the pattern.**
