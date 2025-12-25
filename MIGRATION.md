# Migration Guide: Hyprpunk to Fedpunk Minimal Core

**Last Updated:** December 2024

This guide explains the architectural shift from the monolithic Fedpunk (with built-in desktop environment) to the new minimal core + external profiles architecture.

---

## 🎯 What Changed?

### Before (Monolithic Fedpunk)
```bash
# Old installation
git clone https://github.com/hinriksnaer/Fedpunk
fish install.fish --profile default --mode desktop
```

- ❌ Built-in profiles (`default`, `dev`)
- ❌ Built-in themes (12 themes included)
- ❌ 27+ desktop modules in core
- ❌ Hyprland, themes, all desktop apps bundled

### After (Minimal Core)
```bash
# New installation - Core only
sudo dnf copr enable hinriksnaer/fedpunk
sudo dnf install fedpunk

# Deploy minimal modules
fedpunk module deploy fish
fedpunk module deploy ssh

# Deploy external desktop environment
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop
```

- ✅ Minimal core (~500 KB)
- ✅ Only 3 built-in modules: `fish`, `ssh`, `ssh-clusters`
- ✅ External profiles (hyprpunk, custom)
- ✅ Themes live in profiles
- ✅ Desktop modules external

---

## 📦 Architecture Comparison

| Component | Old (Monolithic) | New (Minimal Core) |
|-----------|------------------|-------------------|
| **Installation** | Git clone + install.fish | DNF package via COPR |
| **Profiles** | Built-in (default/dev) | External git repos |
| **Themes** | Built-in (12 themes) | In external profiles |
| **Desktop Modules** | Built-in (27+ modules) | In external profiles |
| **Core Size** | ~130 MB | ~500 KB |
| **Updates** | Git pull | DNF update |

---

## 🔄 Migration Steps

### For Desktop Environment Users (Hyprland)

**Old workflow:**
```bash
git clone https://github.com/hinriksnaer/Fedpunk
cd Fedpunk
fish install.fish --profile default --mode desktop
```

**New workflow:**
```bash
# 1. Install Fedpunk core via DNF
sudo dnf copr enable hinriksnaer/fedpunk
sudo dnf install fedpunk

# 2. Deploy hyprpunk external profile
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop

# 3. Theme switching (hyprpunk-specific commands)
hyprpunk-theme-set catppuccin
hyprpunk-theme-next
```

### For Container/Server Users

**Old workflow:**
```bash
git clone https://github.com/hinriksnaer/Fedpunk
fish install.fish --profile default --mode container
```

**New workflow:**
```bash
# 1. Install Fedpunk core
sudo dnf copr enable hinriksnaer/fedpunk
sudo dnf install fedpunk

# 2. Deploy just the modules you need
fedpunk module deploy fish
fedpunk module deploy ssh

# 3. (Optional) Add more tools
fedpunk module deploy https://github.com/user/neovim-module.git
```

---

## 🗂️ What Moved Where?

### Themes
**Before:** `Fedpunk/themes/` (built-in)
**After:** [hyprpunk/themes/](https://github.com/hinriksnaer/hyprpunk/tree/main/themes) (external)

### Desktop Modules
**Before:** `Fedpunk/modules/` (27+ modules built-in)
**After:** [hyprpunk/modules/](https://github.com/hinriksnaer/hyprpunk/tree/main/modules) (external)

| Module Category | Old Location | New Location |
|----------------|-------------|-------------|
| **Fish, SSH** | Built-in | Still built-in (minimal core) |
| **Desktop (Hyprland, Kitty, Rofi)** | Built-in | hyprpunk profile |
| **Development (Neovim, Tmux, Lazygit)** | Built-in | hyprpunk profile |
| **System (Audio, Bluetooth, Nvidia)** | Built-in | hyprpunk profile |
| **Themes** | Built-in | hyprpunk profile |

### Theme Commands
**Before:** `fedpunk-theme-set`, `fedpunk-wallpaper-set`
**After:** `hyprpunk-theme-set`, `hyprpunk-wallpaper-set`

---

## 💡 Key Differences

### 1. No More `install.fish`
```bash
# ❌ Old - install.fish removed
fish install.fish --profile default --mode desktop

# ✅ New - DNF package manager
sudo dnf install fedpunk
```

### 2. No More Built-in Profiles
```bash
# ❌ Old - profiles/default built-in
--profile default --mode desktop

# ✅ New - external profiles
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop
```

### 3. No More `essentials` Meta-module
```bash
# ❌ Old - essentials was a meta-module
fedpunk module deploy essentials  # Installed fish, rust, cli-tools, etc.

# ✅ New - explicit module deployment
fedpunk module deploy fish  # Just Fish shell
```

### 4. Module CLI Extensions
Module-provided CLI commands now auto-discover:

```fish
# After deploying ssh module
fedpunk ssh load       # Loads SSH keys
fedpunk ssh list       # Lists SSH hosts

# After deploying hyprpunk with theme-manager
hyprpunk-theme-set catppuccin
hyprpunk-wallpaper-next
```

---

## 🆕 New Features

### 1. DNF Package Management
```bash
# Install from COPR
sudo dnf install fedpunk

# Update via DNF
sudo dnf update fedpunk
```

### 2. Configuration File
Central configuration at `~/.config/fedpunk/fedpunk.yaml`:

```yaml
modules:
  - fish
  - ssh
  - https://github.com/user/custom-module.git

parameters:
  my_module:
    api_key: "secret123"
```

### 3. Apply Command
```bash
# Make changes to fedpunk.yaml
vim ~/.config/fedpunk/fedpunk.yaml

# Apply changes
fedpunk apply
```

### 4. Profile System
```bash
# Deploy external profiles
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop
fedpunk profile deploy ~/my-custom-profile --mode dev
```

---

## 🔍 Breaking Changes

### Removed Commands
- ❌ `fedpunk-theme-set` (use `hyprpunk-theme-set` if using hyprpunk)
- ❌ `fedpunk-wallpaper-set` (use `hyprpunk-wallpaper-set` if using hyprpunk)
- ❌ Profile/mode selection at install time (use external profiles)

### Removed Modules
- ❌ `essentials` meta-module (replaced with explicit `fish` module)
- ❌ Desktop modules (moved to hyprpunk external profile)

### Removed Directories
- ❌ `profiles/default/` (moved to hyprpunk)
- ❌ `profiles/dev/` (deprecated, use hyprpunk or custom profiles)
- ❌ `themes/` (moved to hyprpunk)

---

## 📚 Resources

### Documentation
- [Main README](README.md) - Quick start and overview
- [CLAUDE.md](CLAUDE.md) - Full architecture guide
- [hyprpunk README](https://github.com/hinriksnaer/hyprpunk) - Desktop environment

### External Profiles
- [hyprpunk](https://github.com/hinriksnaer/hyprpunk) - Full Hyprland desktop with themes
- [fedpunk-minimal](https://github.com/hinriksnaer/fedpunk-minimal) - Minimal reference profile

### Migration Documents
- [HYPRPUNK_MIGRATION_COMPLETE.md](HYPRPUNK_MIGRATION_COMPLETE.md) - Technical migration details
- [HYPRPUNK_MIGRATION_PLAN.md](HYPRPUNK_MIGRATION_PLAN.md) - Original migration plan

---

## ❓ FAQ

### Q: Can I still use the old Fedpunk?
**A:** Yes, the old monolithic version remains on the `main` branch (pre-migration). However, new features and updates will only go to the minimal core.

### Q: What happened to the default profile?
**A:** The default profile is now an external profile called **hyprpunk**: https://github.com/hinriksnaer/hyprpunk

### Q: Where did the themes go?
**A:** All 12 themes are now in the hyprpunk profile: https://github.com/hinriksnaer/hyprpunk/tree/main/themes

### Q: Can I create my own profile?
**A:** Absolutely! See the [profile creation guide](docs/MODULE_DEVELOPMENT.md) or use hyprpunk as a reference.

### Q: How do I update Fedpunk now?
**A:** Use DNF: `sudo dnf update fedpunk`

### Q: Is hyprpunk required?
**A:** No! Hyprpunk is just one example profile. You can:
- Use hyprpunk for a full desktop
- Deploy individual modules only
- Create your own custom profile
- Mix and match external modules

---

## 🚀 Getting Started

Ready to try the new architecture?

```bash
# 1. Install Fedpunk core
sudo dnf copr enable hinriksnaer/fedpunk
sudo dnf install fedpunk

# 2. Choose your path:

# Option A: Minimal (just shell tools)
fedpunk module deploy fish
fedpunk module deploy ssh

# Option B: Full desktop (hyprpunk)
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop

# Option C: Custom setup
vim ~/.config/fedpunk/fedpunk.yaml
fedpunk apply
```

---

**Questions?** Open an issue: https://github.com/hinriksnaer/Fedpunk/issues

**Fedpunk** - *Minimal core. Maximum flexibility.*
