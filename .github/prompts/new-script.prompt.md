---
name: Generate Script from Task
description: "Use when creating a new bash script for Script-Hub. Provide a task description, and I'll generate a script with enforced safety practices (error handling, progress logging, dependency checks) plus a README entry template."
---

# Generate a New Script for Script-Hub

I'll help you create a new bash script following Script-Hub conventions. Provide the task description below, and I'll generate:

1. **The script** — with safety header, structured sections, error handling, and progress messages
2. **README entry** — formatted snippet ready to add to documentation

## Task Description

**What should this script do?** (e.g., "Backup home directory to external drive", "Install and configure Node.js")

---

## Generated Script Template

I'll generate a script with:

✓ Safety header (`#!/bin/bash`, `set -e`, `set -o pipefail`)
✓ Structured sections: setup, validation, main logic, cleanup
✓ Dependency checks (verify required commands exist)
✓ Progress logging (timestamped messages for each step)
✓ Error handling (informative messages on failure)
✓ Optional dry-run mode (for destructive operations)
✓ Inline comments explaining key steps

**Important:** After generation:
1. Review the script carefully — test in a non-production environment
2. Verify error paths and edge cases
3. Add any custom logic or optimizations
4. Test with dry-run mode before committing
5. Update the script with your validation results
6. Add the README entry to [README.md](../../README.md)

---

## Example Output

**Script file:** `backup-home.sh`
```bash
#!/bin/bash
set -e
set -o pipefail

# Backup home directory to external drive
# Requires: rsync, sudo privileges
# Usage: ./backup-home.sh [--dry-run]

DRY_RUN="${1:---dry-run}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Backup started"

# Verify dependencies
if ! command -v rsync &> /dev/null; then
    echo "Error: rsync not found. Install with: sudo apt install rsync" >&2
    exit 1
fi

# Verify target drive exists
if [[ ! -d /mnt/backup ]]; then
    echo "Error: /mnt/backup not found. Mount external drive and try again." >&2
    exit 1
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Syncing home directory..."
if [[ "$DRY_RUN" == "--dry-run" ]]; then
    rsync -av --dry-run "$HOME/" /mnt/backup/home-backup/
else
    rsync -av "$HOME/" /mnt/backup/home-backup/
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Backup complete"
```

**README entry:**
```markdown
| `backup-home.sh` | Backup home directory to external drive | As-needed |
| *Requires:* sudo, rsync; mount external drive to `/mnt/backup` first. Usage: `./backup-home.sh` or `./backup-home.sh --dry-run` |
```

---

**Ready to proceed?** Describe your task, and I'll generate the script and README entry.
