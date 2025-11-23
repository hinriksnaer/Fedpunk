# Testing Fedpunk on Atomic Desktop

## Option 1: VM Testing (Recommended)

### Quick Setup with GNOME Boxes

**1. Download Fedora Silverblue ISO**
```bash
# Get latest Silverblue (GNOME) or Kinoite (KDE)
wget https://download.fedoraproject.org/pub/fedora/linux/releases/41/Silverblue/x86_64/iso/Fedora-Silverblue-ostree-x86_64-41-1.4.iso

# Or Kinoite if you prefer KDE
# wget https://download.fedoraproject.org/pub/fedora/linux/releases/41/Kinoite/x86_64/iso/Fedora-Kinoite-ostree-x86_64-41-1.4.iso
```

**2. Create VM**
```bash
# Install GNOME Boxes if not installed
sudo dnf install gnome-boxes

# Or use virt-manager
sudo dnf install virt-manager

# Launch and create VM:
# - 4GB RAM minimum (8GB recommended)
# - 40GB disk minimum
# - Install Silverblue/Kinoite
```

**3. Setup Fedpunk in VM**
```bash
# After Silverblue boots, open terminal

# Clone fedpunk (use your branch)
cd ~
git clone https://github.com/yourusername/fedpunk.git
cd fedpunk

# Checkout atomic desktop branch
git checkout feat/atomic-desktop

# Run new bash bootstrap
./install.sh --profile dev --mode atomic-desktop
```

**What to expect:**
```
1. Bootstrap detects atomic desktop (/run/ostree-booted exists)
2. Installs Fish via rpm-ostree --idempotent
3. Shows reboot prompt:
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ⚠️  REBOOT REQUIRED
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Fish has been layered but requires a reboot

4. Reboot: sudo systemctl reboot

5. After reboot, run again:
   ./install.sh --profile dev --mode atomic-desktop

6. Now Fish is available, installer proceeds:
   - Deploys modules from atomic-desktop mode
   - System packages → rpm-ostree install
   - User packages → cargo/npm (no layering)
   - Flatpaks → user install (no layering)
   - Shows reboot warning at end if packages layered
```

### What to Test

**1. Package manager abstraction**
```bash
# Check which packages were layered
rpm-ostree status

# Should show packages from modules under "LayeredPackages"
# Example:
#   LayeredPackages: fish kitty hyprland waybar
```

**2. Linker state tracking**
```bash
# Check deployed config
fedpunk module status

# Should show:
# Deployed Configuration:
#
# fish: X files
# hyprland: Y files
# ...
```

**3. Reboot behavior**
```bash
# Deploy a module with dnf packages
fedpunk module deploy kitty

# Should show:
#   📦 Layering packages (rpm-ostree): kitty
#   ⚠️  Reboot required to activate changes
#
# At end:
#   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   ⚠️  REBOOT REQUIRED
#   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**4. User-space packages (no layering)**
```bash
# Deploy module with cargo packages
fedpunk module deploy neovim

# Should NOT show reboot warning
# Cargo packages install to ~/.cargo (no system layer)
```

**5. Mode file verification**
```bash
# Check atomic-desktop mode modules
cat profiles/dev/modes/atomic-desktop.yaml

# Verify it minimizes dnf packages, maximizes Flatpaks/cargo/npm
```

---

## Option 2: Simulate Atomic Detection (Quick Test)

**Test without full VM - just verify detection logic**

```bash
# Temporarily create the ostree marker
sudo touch /run/ostree-booted

# Test detection
fish -c '
source lib/fish/package-manager.fish
if is-atomic-desktop
    echo "✓ Atomic desktop detected"
else
    echo "✗ Traditional desktop detected"
end
'

# Test package manager abstraction
fish -c '
source lib/fish/package-manager.fish
install-system-packages htop
'
# Should try rpm-ostree since marker exists

# Clean up
sudo rm /run/ostree-booted
```

**Limitations:**
- `rpm-ostree` commands will fail (not actually on atomic desktop)
- Can't test full flow, only detection logic
- Good for quick validation of code paths

---

## Option 3: Real Hardware

**If you have a spare machine or want to daily-drive atomic:**

**1. Install Silverblue/Kinoite**
- Backup your data!
- Install from ISO or rebase from Workstation:
  ```bash
  # Rebase from existing Fedora Workstation
  sudo dnf install ostree-grub2
  rpm-ostree rebase fedora:fedora/41/x86_64/silverblue
  sudo systemctl reboot
  ```

**2. Test fedpunk normally**
```bash
git clone <your-fedpunk> ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
./install.sh --profile dev --mode atomic-desktop
```

---

## Testing Checklist

### Bootstrap (install.sh)
- [ ] Detects atomic desktop (`/run/ostree-booted` exists)
- [ ] Installs Fish via `rpm-ostree install`
- [ ] Shows reboot prompt when Fish layered
- [ ] After reboot, continues with Fish-based installer

### Package Manager Abstraction
- [ ] `is-atomic-desktop` returns true
- [ ] DNF packages → `rpm-ostree install --idempotent`
- [ ] Sets `FEDPUNK_REBOOT_REQUIRED` flag
- [ ] Shows reboot warning at end
- [ ] Cargo packages → install to `~/.cargo` (no layering)
- [ ] NPM packages → install to user (no layering)
- [ ] Flatpaks → user install (no layering)

### Module Deployment
- [ ] Modules deploy successfully
- [ ] Config files linked with new linker
- [ ] State tracked in `.linker-state.json`
- [ ] `fedpunk module status` shows deployed modules
- [ ] System packages batched (one rpm-ostree call per module)

### Atomic-Specific Mode
- [ ] `atomic-desktop.yaml` loads correctly
- [ ] Minimal system packages (only hyprland, waybar, fonts, etc.)
- [ ] Heavy use of Flatpaks and user-space tools
- [ ] No unnecessary layering

### Reboot Workflow
- [ ] Reboot warning shown when needed
- [ ] After reboot, layered packages active
- [ ] `rpm-ostree status` shows correct layers
- [ ] Rollback works: `rpm-ostree rollback`

### Linker Integration
- [ ] Works on atomic desktop (symlinks work normally)
- [ ] State file created
- [ ] Conflicts handled interactively
- [ ] Remove works correctly

---

## Common Issues & Solutions

### Issue: Fish not found after layering
**Symptom:** Install script fails, Fish not in PATH

**Solution:**
```bash
# Verify Fish was layered
rpm-ostree status | grep fish

# If pending deployment, reboot
sudo systemctl reboot

# If missing entirely, layer manually
sudo rpm-ostree install fish
sudo systemctl reboot
```

### Issue: rpm-ostree says "already provided by base"
**Symptom:** Package install fails

**Solution:**
Already included in base image, skip it:
```yaml
# In module.yaml, remove from dnf: list
# Or add check in install script
```

### Issue: Reboot required but not prompted
**Symptom:** Packages layered but no warning

**Solution:**
Check the flag:
```fish
# In module script
if set -q FEDPUNK_REBOOT_REQUIRED
    echo "Reboot flag is set"
end

# Verify show-reboot-warning is called
```

### Issue: Stow vs Linker confusion
**Symptom:** Old stow conflicts

**Solution:**
```bash
# Remove old stow deployments first
cd modules/fish
stow -D -t $HOME config

# Then redeploy with linker
fedpunk module deploy fish
```

---

## Performance Testing

### Module Deployment Time
```bash
# Traditional Fedora
time ./install.sh --mode desktop
# Note: DNF installs are immediate

# Atomic Desktop
time ./install.sh --mode atomic-desktop
# Note: rpm-ostree is slower but safer
```

### Layer Minimization
```bash
# Check how many packages were layered
rpm-ostree status | grep "LayeredPackages" -A 20

# Goal: < 20 packages layered
# Compare with traditional mode (would install 100+ via DNF)
```

### Flatpak Usage
```bash
# Check Flatpaks installed
flatpak list --app

# Should see: Firefox, Spotify, Discord, etc.
# Instead of layering them
```

---

## Debugging

### Enable verbose output
```bash
# In install.sh, add:
set -x  # Before exec fish

# In fedpunk-module.fish, add:
set -x  # Enable fish tracing
```

### Check rpm-ostree status
```bash
# See all deployments
rpm-ostree status

# See pending changes
rpm-ostree status --pending

# See what's layered
rpm-ostree status | grep Layered

# See logs
journalctl -u rpm-ostreed
```

### Verify linker state
```bash
# Pretty-print state
jq . ~/.local/share/fedpunk/.linker-state.json

# Count deployed files
jq '.files | length' ~/.local/share/fedpunk/.linker-state.json

# List files by module
jq -r '.files | to_entries | group_by(.value.module)[] |
       "\(.[0].value.module): \(length) files"' \
    ~/.local/share/fedpunk/.linker-state.json
```

---

## Recommended Testing Flow

**Day 1: Set up VM**
1. Download Silverblue ISO
2. Create VM in GNOME Boxes
3. Install Silverblue
4. Basic system update

**Day 2: Bootstrap test**
1. Clone fedpunk in VM
2. Run `./install.sh --mode atomic-desktop`
3. Verify Fish layering + reboot
4. Verify installer continues after reboot

**Day 3: Module testing**
1. Deploy individual modules
2. Verify package manager abstraction
3. Check linker state tracking
4. Test conflict handling

**Day 4: Full deployment**
1. Deploy full atomic-desktop mode
2. Measure layer count
3. Verify Flatpaks vs system packages
4. Test rollback

**Day 5: Edge cases**
1. Conflicting configs
2. Module removal
3. Redeployment
4. State recovery

---

## Success Criteria

✅ **Bootstrap works**
- Fresh Silverblue VM → run install.sh → successful deployment

✅ **Minimal layering**
- < 20 system packages layered
- Most apps via Flatpak
- Dev tools via cargo/npm/rustup

✅ **Linker works**
- Config deployed with state tracking
- Conflicts handled gracefully
- Removal cleans up properly

✅ **Atomic features utilized**
- Rollback capability preserved
- Reboot workflow clear
- No surprise system changes

✅ **Mode system works**
- atomic-desktop.yaml loads correctly
- Different package strategy than desktop.yaml
- Documented best practices
