# Installing Fedpunk from COPR (Unstable)

**⚠️ WARNING: This is the unstable/bleeding-edge repository.**

This COPR repository contains automatic builds from the `main` branch. These builds are:
- **Cutting-edge** - Latest features and fixes
- **Unstable** - May contain bugs or breaking changes
- **Unversioned** - Not following semantic versioning
- **For testing** - Not recommended for production use

If you want stability, wait for the stable COPR repository (coming soon).

---

## Prerequisites

- **Fedora 39+** (tested on Fedora 40, 41, 42, 43)
- **x86_64 architecture** (ARM support planned)
- **~2GB free disk space** for full desktop installation
- **Internet connection** for package downloads

---

## Quick Installation

### 1. Enable the COPR Repository

```bash
sudo dnf copr enable hinriksnaer/fedpunk-unstable
```

This adds the Fedpunk unstable repository to your system.

### 2. Install Fedpunk

```bash
sudo dnf install fedpunk
```

This installs Fedpunk to `/usr/share/fedpunk/` with all built-in modules and themes.

### 3. Run the Installer

**For desktop systems:**
```bash
fedpunk install
```

**For containers/servers (no GUI):**
```bash
fedpunk install --mode container
```

**Non-interactive (auto-detect mode):**
```bash
fedpunk install --non-interactive
```

### 4. Start Using Fedpunk

Restart your shell or run:
```bash
exec fish
```

---

## What Gets Installed

### System Files (`/usr/share/fedpunk/`)
- **lib/fish/** - Core libraries
- **modules/** - Built-in modules (fish, neovim, tmux, hyprland, etc.)
- **profiles/default/** - Default profile for most users
- **profiles/example/** - Template for creating custom profiles
- **themes/** - 12 curated themes
- **cli/** - CLI commands
- **install.fish** - Main installer

### User Files (Auto-Created)
On first run, Fedpunk creates `~/.local/share/fedpunk/`:
- **profiles/dev/** - Your personal development profile
- **.active-config** - Symlink to active profile
- **cache/external/** - External modules cache

### Environment Variables
Set via `/etc/profile.d/fedpunk.sh`:
- `FEDPUNK_SYSTEM=/usr/share/fedpunk`
- `FEDPUNK_USER=~/.local/share/fedpunk`
- `FEDPUNK_ROOT=$FEDPUNK_SYSTEM` (backward compatibility)

---

## Installation Modes

### Desktop Mode (Default)
Full GUI environment with Hyprland compositor:
```bash
fedpunk install --profile default --mode desktop
```

**Includes:**
- Hyprland compositor
- Kitty terminal
- Neovim with LSP
- tmux, lazygit, btop, yazi
- Rofi launcher, Mako notifications, Waybar
- 12 themes with instant switching
- Zen Browser

### Container Mode
Terminal-only for devcontainers and servers:
```bash
fedpunk install --profile default --mode container
```

**Includes:**
- Fish shell with modern tooling
- Neovim with full plugin suite
- tmux, lazygit, btop, yazi
- Theme system (terminal apps only)
- All development tools, no GUI components

---

## Updating

Fedpunk receives automatic updates when new commits are pushed to `main`:

```bash
# Update system packages (includes Fedpunk if available)
sudo dnf update

# If Fedpunk was updated, re-run the installer to update configs
fedpunk install --non-interactive
```

**Note:** Unstable builds may introduce breaking changes. Check the [GitHub releases](https://github.com/hinriksnaer/Fedpunk/releases) before updating.

---

## Uninstalling

### Remove Fedpunk Package
```bash
sudo dnf remove fedpunk
```

This removes `/usr/share/fedpunk/` but preserves your user data.

### Remove User Data (Optional)
```bash
rm -rf ~/.local/share/fedpunk
rm -rf ~/.config/fish
rm -rf ~/.config/nvim
rm -rf ~/.config/hypr
# ... other config directories
```

### Remove COPR Repository
```bash
sudo dnf copr remove hinriksnaer/fedpunk-unstable
```

---

## Troubleshooting

### Package Not Found
If `dnf install fedpunk` fails:
```bash
# Verify COPR is enabled
dnf copr list --enabled | grep fedpunk

# Re-enable if needed
sudo dnf copr enable hinriksnaer/fedpunk-unstable -y

# Update cache
sudo dnf clean all && sudo dnf makecache
```

### Installation Fails
Check logs:
```bash
# View recent installer output
journalctl -xe | grep fedpunk

# Check DNF logs
sudo cat /var/log/dnf.log | grep fedpunk
```

### Environment Variables Not Set
Restart your shell or manually source:
```bash
source /etc/profile.d/fedpunk.sh
```

### Fish Shell Not Default
The installer sets Fish as your default shell. If it didn't work:
```bash
chsh -s $(which fish)
```

Then log out and back in.

---

## Getting Help

### Report Issues
- **GitHub Issues:** https://github.com/hinriksnaer/Fedpunk/issues
- **Bug Template:** Please include:
  - Fedpunk version: `rpm -q fedpunk`
  - Fedora version: `cat /etc/fedora-release`
  - Installation mode: desktop or container
  - Error logs

### Check Build Status
- **COPR Build Status:** https://copr.fedorainfracloud.org/coprs/hinriksnaer/fedpunk-unstable/
- **GitHub Actions:** https://github.com/hinriksnaer/Fedpunk/actions

### Documentation
- **Main README:** https://github.com/hinriksnaer/Fedpunk/blob/main/README.md
- **Architecture:** https://github.com/hinriksnaer/Fedpunk/blob/main/ARCHITECTURE.md
- **Customization Guide:** `docs/guides/customization.md`

---

## For Contributors

### Testing Local Changes
Before pushing to `main` (which triggers COPR builds):

```bash
# Clone the repo
git clone https://github.com/hinriksnaer/Fedpunk.git
cd Fedpunk

# Build RPM locally
bash test/build-rpm.sh

# Test the RPM
bash test/test-rpm-install.sh
```

### CI Pipeline
Every push to `main` triggers:
1. **GitHub Actions** - Builds and tests RPM
2. **COPR Webhook** - Builds RPM for distribution
3. **Users get updates** - Via `dnf update`

---

## Migration from Git Clone Installation

If you previously installed via git clone:

### 1. Backup Your Custom Config
```bash
cd ~/.local/share/fedpunk
tar czf ~/fedpunk-backup.tar.gz profiles/dev/
```

### 2. Remove Git Installation
```bash
rm -rf ~/.local/share/fedpunk
```

### 3. Install from COPR
```bash
sudo dnf copr enable hinriksnaer/fedpunk-unstable
sudo dnf install fedpunk
fedpunk install
```

### 4. Restore Custom Config
```bash
cd ~
tar xzf fedpunk-backup.tar.gz -C ~/.local/share/fedpunk/
```

---

## FAQ

**Q: How often are unstable builds released?**
A: Every push to the `main` branch triggers a new build, usually within 10-20 minutes.

**Q: Can I switch from unstable to stable later?**
A: Yes, when the stable COPR is available, you can disable fedpunk-unstable and enable fedpunk-stable.

**Q: Will unstable builds break my system?**
A: Unlikely, but they may break your Fedpunk configuration. Always backup your `~/.local/share/fedpunk/profiles/dev/` directory.

**Q: How do I know which commit I'm running?**
A: `rpm -q fedpunk` shows the version with git commit hash, e.g., `fedpunk-0.5.0-0.1.20241209gitabcd123.fc40.noarch`

**Q: Can I install both unstable and stable?**
A: No, they conflict. Choose one repository.

---

**Ready to try Fedpunk? Enable the repo and install:**

```bash
sudo dnf copr enable hinriksnaer/fedpunk-unstable
sudo dnf install fedpunk
fedpunk install
```

**Happy hacking!** 🚀
