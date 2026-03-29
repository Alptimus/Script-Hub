# Script-Hub

A personal collection of bash scripts for system administration and automation. Each script handles specific tasks like package updates, system maintenance, and environment setup.

## Quick Start

Clone or download the repository, then run scripts with:

```bash
bash script-name.sh
# OR (if executable):
./script-name.sh
```

## Prerequisites

Most scripts require:
- **Bash 4+** — Verify with `bash --version`
- **sudo access** — Many operations require elevated privileges
- **Package manager** — `apt` (Debian/Ubuntu) and optionally `flatpak`

Before running any script, review its documentation below to understand what it does and what permissions it needs.

## Scripts

### `daily_update.sh`
**Purpose:** System package updates and cleanup  
**Frequency:** Daily  
**Requires:** sudo, apt

Updates all system packages (apt, apt-get dependencies, optionally flatpak) and performs system cleanup:
- Updates package lists and upgrades packages
- Performs full system upgrade
- Removes unused packages and cleans package cache
- Updates flatpak apps (if installed)

**Usage:**
```bash
sudo bash daily_update.sh
# OR if you prefer with full path:
cd /path/to/Script-Hub && sudo bash daily_update.sh
```

**What it does:**
1. `sudo apt update -y` — Refresh package lists
2. `sudo apt upgrade -y` — Upgrade all packages
3. `sudo apt full-upgrade -y` — Full system upgrade
4. `sudo apt autoremove -y` — Remove unused packages
5. `sudo apt clean` — Clean package cache
6. `flatpak update -y` — Update flatpak apps (if installed)

**Note:** All operations are non-interactive (`-y` flags). Run with `DRY_RUN=1` to preview without executing (if implemented).

### `install_nvidia_drivers.sh`
**Purpose:** Install NVIDIA drivers on Ubuntu/Debian systems  
**Frequency:** As-needed  
**Requires:** sudo, lspci (pciutils), ubuntu-drivers-common

Quickly installs NVIDIA drivers on AWS EC2 instances and bare metal machines with NVIDIA GPUs.

**Usage:**
```bash
sudo bash install_nvidia_drivers.sh
```

**What it does:**
1. Detects NVIDIA GPU using `lspci` — exits if no GPU found
2. `sudo apt update -y` — Refresh package lists
3. `sudo apt upgrade -y` — Upgrade all packages
4. Installs `ubuntu-drivers-common` if missing
5. `sudo ubuntu-drivers --gpgpu install` — Install NVIDIA drivers
6. Displays reboot instructions

**After running:**
Manually reboot your system and verify installation:
```bash
sudo reboot
# After reboot:
nvidia-smi
```

**Important:** 
- ⚠️ This script **requires an NVIDIA GPU** — it exits immediately if no GPU is detected
- ⚠️ Drivers require a **system reboot** to activate — they will not work until after reboot
- Use `nvidia-smi` after rebooting to verify drivers are installed and working

### `get-docker.sh`
**Purpose:** Docker Engine installation  
**Frequency:** As-needed  
**Requires:** sudo, curl, internet connection

⚠️ **Important:** This script is maintained by Docker and fetched from their official repository. It contains Docker's installation logic for Linux. Review [Docker's installation docs](https://docs.docker.com/engine/install/) for details.

**Usage:**
```bash
sudo bash get-docker.sh
```

**What it does:**
- Detects your Linux distribution
- Adds Docker's official repository
- Installs Docker Engine, Buildx, Compose, and dependencies
- Sets up the daemon

**Security Note:** This script follows Docker's recommended installation procedure. Always review downloaded scripts before executing them.

---

## Development

### Adding New Scripts

1. Create a file with `.sh` extension following naming convention (lowercase, hyphens): `backup-home.sh`
2. Start with safety header:
   ```bash
   #!/bin/bash
   set -e
   ```
3. Include a comment describing the script's purpose and requirements
4. Add progress messages for each significant step
5. Test locally in a non-production environment
6. Update this README with script description, usage, and prerequisites
7. Commit with clear message

### Script Conventions

All scripts follow these principles:

- **Safety first:** `set -e` exits on errors, `set -o pipefail` catches pipe failures
- **User feedback:** Progress messages at each step, timestamps for long operations
- **Explicit dependencies:** Commands verified before use, requirements documented
- **Error handling:** Informative error messages to stderr, cleanup on exit
- **Testing:** Support dry-run mode for destructive operations where practical

For detailed conventions, patterns, and examples, see [.github/copilot-instructions.md](.github/copilot-instructions.md).

### Generating Scripts

Use the [`/new-script` prompt](.github/prompts/new-script.prompt.md) to generate a new script from a task description. It will create a template with safety practices, logging, and error handling built in.

### Code Review Checklist

When reviewing or modifying scripts, check [.github/instructions/shell-scripts.instructions.md](.github/instructions/shell-scripts.instructions.md) for the full safety and style checklist.

---

## Files

- `daily_update.sh` — Daily system updates and cleanup
- `install_nvidia_drivers.sh` — NVIDIA driver installation for AWS EC2 / bare metal
- `get-docker.sh` — Docker Engine installation (external source)
- [.github/copilot-instructions.md](.github/copilot-instructions.md) — Detailed development guide and conventions
- [.github/prompts/new-script.prompt.md](.github/prompts/new-script.prompt.md) — Script generation prompt
- [.github/instructions/shell-scripts.instructions.md](.github/instructions/shell-scripts.instructions.md) — Review checklist for scripts
