# Building Your First Fedpunk Image

**Goal:** Create a working Universal Blue custom image with Hyprland + Fish in one week.

**Prerequisites:**
- GitHub account
- Basic understanding of containers
- Fedora system (for testing)

## Day 1: Repository Setup

### Step 1: Fork Universal Blue Template

```bash
# Visit: https://github.com/blue-build/template
# Click "Use this template" → "Create a new repository"
# Name it: fedpunk-images
# Make it public (for ghcr.io publishing)

# Or via gh CLI:
gh repo create fedpunk-images --template blue-build/template --public
cd fedpunk-images
```

### Step 2: Understand the Structure

```
fedpunk-images/
├── config/                    # Image recipes
│   └── recipe.yml            # Main recipe (we'll edit this)
├── .github/
│   └── workflows/
│       └── build.yml         # GitHub Actions (auto-builds)
├── Containerfile             # Generated during build
└── README.md
```

**Key file:** `config/recipe.yml` - defines your image

### Step 3: Create Minimal Recipe

Edit `config/recipe.yml`:

```yaml
# Fedpunk Hyprland - Minimal prototype
name: fedpunk-hyprland
description: Declarative Hyprland desktop environment

# Base image - start with uCore (minimal)
base-image: ghcr.io/ublue-os/ucore-minimal:stable

# Image metadata
image-version: 41  # Fedora 41

# Modules to pull in
modules:
  # Use BlueBuild's module system
  - type: files
    files:
      - source: system
        destination: /

# Packages to install
install:
  # Core shell
  - fish

  # Hyprland compositor
  - hyprland

  # Status bar
  - waybar

  # Terminal
  - kitty

  # Launcher
  - rofi-wayland

  # Fonts
  - fira-code-fonts

  # Basic utilities
  - git
  - curl
  - vim

# Remove unwanted packages (optional)
remove:
  # uCore is minimal, not much to remove
  - []

# Post-install scripts
scripts:
  # We'll add fedpunk-specific setup later
  - setup-fish.sh
```

### Step 4: Create Setup Script

Create `config/scripts/setup-fish.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Set Fish as default shell for new users
echo "Setting up Fish as default shell..."

# Add fish to /etc/shells if not present
if ! grep -q "/usr/bin/fish" /etc/shells; then
    echo "/usr/bin/fish" >> /etc/shells
fi

# Create /etc/skel/.config for default user configs
mkdir -p /etc/skel/.config/fish

# Basic fish config (will be expanded with fedpunk modules)
cat > /etc/skel/.config/fish/config.fish << 'EOF'
# Fedpunk Fish Configuration
if status is-interactive
    # Greeting
    set -g fish_greeting "Welcome to Fedpunk 🚀"

    # Path
    set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $PATH

    # Editor
    set -gx EDITOR vim
end
EOF

chmod +x /etc/skel/.config/fish/config.fish

echo "✓ Fish setup complete"
```

Make it executable:
```bash
chmod +x config/scripts/setup-fish.sh
```

## Day 2: Local Build & Test

### Step 1: Install BlueBuild CLI

```bash
# Install BlueBuild for local building
curl -L https://blue-build.org/installer.sh | bash

# Or with cargo:
cargo install bluebuild

# Verify
bluebuild --version
```

### Step 2: Build Image Locally

```bash
# Build the image
bluebuild build config/recipe.yml

# This will:
# 1. Pull base image (uCore)
# 2. Install packages
# 3. Run scripts
# 4. Create final image

# Takes ~10-15 minutes first time
# Subsequent builds use cache (~2-3 min)
```

### Step 3: Test Image

```bash
# Check image exists
podman images | grep fedpunk

# Run in container (basic test)
podman run -it localhost/fedpunk-hyprland:latest fish

# Should drop you into Fish shell
# Type: echo $SHELL
# Should show: /usr/bin/fish
```

### Step 4: Test in VM

**Option A: Quick test with Toolbox**
```bash
# Create toolbox from your image
toolbox create --image localhost/fedpunk-hyprland:latest fedpunk-test
toolbox enter fedpunk-test

# Verify packages installed
which hyprland
which waybar
which kitty
```

**Option B: Full test with rebase**
```bash
# In a Fedora Silverblue/Kinoite VM:

# Rebase to local image
rpm-ostree rebase ostree-unverified-registry:localhost/fedpunk-hyprland:latest

# Reboot
systemctl reboot

# After reboot, verify
which hyprland fish kitty waybar
```

## Day 3: GitHub Actions Setup

### Step 1: Enable GitHub Actions

```bash
# In your fedpunk-images repo
git add .
git commit -m "Initial fedpunk-hyprland recipe"
git push origin main

# GitHub Actions will auto-trigger!
# Watch at: https://github.com/yourname/fedpunk-images/actions
```

### Step 2: Verify Build

The workflow will:
1. Build image
2. Push to ghcr.io/yourname/fedpunk-hyprland:latest
3. Sign with cosign

**Check progress:**
- Go to Actions tab
- Watch build logs
- Should complete in ~15-20 min

### Step 3: Test Published Image

```bash
# Once build completes, rebase to published image
# (In a Fedora Atomic VM or your main system)

rpm-ostree rebase ostree-unverified-registry:ghcr.io/yourname/fedpunk-hyprland:latest

# For signed images (after GitHub Actions sets up signing):
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yourname/fedpunk-hyprland:latest

systemctl reboot
```

## Day 4: Integrate Fedpunk Modules

### Step 1: Add Fedpunk Dotfiles

Create `files/system/etc/skel/.config/`:

```bash
mkdir -p files/system/etc/skel/.config/{hypr,waybar,kitty,rofi}

# Copy configs from fedpunk modules
# Example: Hyprland config
cp ~/.local/share/fedpunk/modules/hyprland/config/.config/hypr/hyprland.conf \
   files/system/etc/skel/.config/hypr/

# Waybar config
cp ~/.local/share/fedpunk/modules/hyprland/config/.config/waybar/* \
   files/system/etc/skel/.config/waybar/

# etc...
```

**Structure:**
```
files/
└── system/
    └── etc/
        └── skel/              # Default user skeleton
            └── .config/
                ├── fish/
                │   └── config.fish
                ├── hypr/
                │   └── hyprland.conf
                ├── waybar/
                │   ├── config
                │   └── style.css
                └── kitty/
                    └── kitty.conf
```

### Step 2: Update Recipe

```yaml
# In recipe.yml, add files module
modules:
  - type: files
    files:
      - source: system
        destination: /  # Copies to root

# This will place configs in /etc/skel
# New users get these configs automatically
```

### Step 3: Add Post-Setup Script

Create `config/scripts/fedpunk-setup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Setting up Fedpunk environment..."

# Enable Hyprland session
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Set up SDDM/GDM for Hyprland (if using display manager)
# Or instructions for startx/ly

echo "✓ Fedpunk setup complete"
```

### Step 4: Rebuild

```bash
bluebuild build config/recipe.yml

# Test locally
podman run -it localhost/fedpunk-hyprland:latest

# Push to GitHub
git add files/ config/
git commit -m "Add fedpunk module configs"
git push

# GitHub Actions rebuilds automatically
```

## Day 5: Testing & Validation

### Validation Checklist

**Image Builds:**
- [ ] Local build succeeds
- [ ] GitHub Actions build succeeds
- [ ] Image published to ghcr.io
- [ ] Image signature valid

**Package Installation:**
- [ ] Fish installed and working
- [ ] Hyprland installed
- [ ] Waybar, Kitty, Rofi present
- [ ] All dependencies resolved

**Configuration:**
- [ ] Fish config in place
- [ ] Hyprland config in place
- [ ] Waybar config in place
- [ ] Configs valid (no syntax errors)

**Rebase Test:**
- [ ] Can rebase from Fedora Atomic
- [ ] System boots after rebase
- [ ] Hyprland session available
- [ ] Can log into Hyprland
- [ ] Waybar launches
- [ ] Kitty terminal works

**Reproducibility:**
- [ ] Same recipe → identical image
- [ ] Multiple builds produce same hash
- [ ] Two users get identical system

### Common Issues

**Issue: Build fails on package install**
```
Error: No package X found
```
**Solution:** Check package name in Fedora repos:
```bash
dnf search package-name
```

**Issue: Config files not in image**
```
/etc/skel/.config/ is empty
```
**Solution:** Verify files/ directory structure matches destination

**Issue: Hyprland won't start**
```
Failed to start compositor
```
**Solution:** Check Hyprland dependencies, verify Wayland support

**Issue: Can't rebase to image**
```
error: No such container
```
**Solution:** Verify image name, check ghcr.io visibility (public?)

## Day 6-7: Polish & Document

### Write Documentation

Create `README.md` in repo:

```markdown
# Fedpunk Hyprland

Declarative Hyprland desktop environment on Fedora Atomic.

## Quick Start

```bash
# Rebase to fedpunk-hyprland
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yourname/fedpunk-hyprland:latest
systemctl reboot
```

## What's Included

- Hyprland compositor
- Waybar status bar
- Kitty terminal
- Fish shell
- Rofi launcher
- Pre-configured dotfiles

## Customizing

Fork this repo, edit `config/recipe.yml`, push to GitHub.
Your custom image builds automatically.

## Support

Issues: https://github.com/yourname/fedpunk-images/issues
```

### Create Usage Guide

Document:
- [ ] How to rebase
- [ ] First login steps
- [ ] Keybindings
- [ ] Customization guide
- [ ] Troubleshooting

### Screenshots

Take screenshots:
- Clean desktop
- Waybar + apps
- Terminal with fetch
- Rofi launcher

Add to README.

## Next Steps

**Week 2:**
1. Add more packages (dev tools, etc.)
2. Integrate more fedpunk modules
3. Test on real hardware
4. Get feedback from friends

**Week 3-4:**
1. Set up proper image signing
2. Create variant images (dev, minimal)
3. Migration guide from traditional fedpunk
4. Community announcement

## Resources

- [BlueBuild Docs](https://blue-build.org)
- [Universal Blue Discourse](https://universal-blue.discourse.group)
- [Example Images](https://github.com/ublue-os/)
- [Fedpunk Modules](../modules/)

## Success!

If you've completed all days, you now have:
- ✅ Working custom Fedora Atomic image
- ✅ Hyprland + Fish pre-configured
- ✅ Automatic builds on GitHub
- ✅ Publishable to community

**This is the foundation for the entire fedpunk distribution!**
