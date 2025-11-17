# Fedpunk Simplification Summary

**Date:** 2025-11-17
**Changes:** Removed incomplete `profiles/` system in favor of simpler `custom/` approach

---

## 🎯 What Changed

### Removed
- ❌ `profiles/` directory (4 empty profile directories)
- ❌ `bin/fedpunk-use` script
- ❌ `.active-config` from .gitignore (it's now just a symlink to `custom/`)
- ❌ `PROFILES_VS_CUSTOM.md` documentation

### Kept
- ✅ `custom/` directory (the ONLY place for user customizations)
- ✅ `.active-config` symlink → `custom/` (used internally by theme scripts)
- ✅ Installation mode selection via flags (`--terminal-only`)
- ✅ All 12 built-in themes in `themes/`

---

## 🤔 Why Remove Profiles?

**The Problem:**
1. **Not Implemented** - All `profiles/` subdirectories were empty
2. **Installer Ignores It** - Installation uses `--terminal-only` flag, not profile configs
3. **Confusion** - Two systems (`profiles/` and `custom/`) doing similar things
4. **Duplication** - Both had themes/, scripts/, config/ subdirectories

**The Solution:**
- Keep only `custom/` - it's simpler, clearer, and already works
- Use command-line flags for installation variants (already implemented)

---

## 📁 New Simplified Structure

```
fedpunk/
├── themes/              ← 12 built-in themes (shared)
├── custom/              ← YOUR customizations (gitignored)
│   ├── themes/          ← Your themes (searched FIRST)
│   ├── scripts/         ← Your scripts
│   ├── config/          ← Stow-managed dotfiles
│   ├── config.fish      ← Your Fish config (loaded LAST)
│   ├── keybinds.conf    ← Your Hyprland keys
│   └── fedpunk.toml     ← Your personal config metadata
├── config/              ← Core application configs
├── bin/                 ← Utility scripts
└── install/             ← Installation system
```

---

## 🚀 How to Use Fedpunk Now

### Installation Variants

Choose your variant via bootstrap script:

```bash
# Full desktop (Hyprland + all tools)
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash

# Terminal-only (CLI tools only, no desktop)
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot-terminal.sh | bash

# From cloned repo
git clone https://github.com/hinriksnaer/Fedpunk.git ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
fish install.fish                    # Full desktop
fish install.fish --terminal-only    # Terminal-only
```

### Customization (One Location)

All customizations go in `custom/`:

```bash
# Personal aliases
cat >> custom/config.fish << 'EOF'
alias gs='git status'
set -x EDITOR nvim
EOF

# Personal theme
cp -r themes/nord custom/themes/my-theme
vim custom/themes/my-theme/kitty.conf
fedpunk-theme-set my-theme

# Personal Hyprland shortcuts
cat >> custom/keybinds.conf << 'EOF'
bind = Super, M, exec, spotify
EOF

# Manage dotfiles (git, alacritty, etc.)
mkdir -p custom/config/git
vim custom/config/git/.gitconfig
fedpunk-stow-custom git
```

---

## 🔑 Key Benefits

### Before (Confusing)
```
profiles/default/       ← Empty, not used by installer
profiles/minimal/       ← Empty, not used by installer
profiles/gaming/        ← Empty, not used by installer
profiles/terminal-only/ ← Empty, not used by installer
custom/                 ← Actually works
bin/fedpunk-use         ← Script that switches between profiles
```

**Questions users would have:**
- "Should I use profiles/ or custom/?"
- "Why isn't fedpunk-use doing anything?"
- "Where do I put my themes?"

### After (Simple)
```
custom/  ← Put ALL your customizations here
```

**Clear answer:**
- ✅ One location for everything
- ✅ No confusion about profiles vs custom
- ✅ Everything actually works

---

## 🎨 Theme System (Unchanged)

The theme system continues to work exactly as before:

**Search Order:**
1. `custom/themes/` ← Your themes (highest priority)
2. `themes/` ← Built-in themes

**Commands:**
```bash
fedpunk-theme-list              # List all themes
fedpunk-theme-set my-theme      # Set theme
fedpunk-theme-next              # Next theme (Super+Shift+T)
fedpunk-theme-prev              # Previous theme (Super+Shift+Y)
fedpunk-theme-current           # Show current theme
```

---

## 🔄 Migration Guide

**If you were using the old system:**

There's nothing to migrate! The `profiles/` directories were all empty, so:
- No data loss
- No configuration changes needed
- Everything continues to work

**If you were confused by profiles:**

Great news! Now there's only one place to look: `custom/`

---

## 📋 Internal Implementation Details

### How .active-config Works

`.active-config` is a symlink to `custom/`:

```bash
$ ls -la ~/.local/share/fedpunk/.active-config
lrwxrwxrwx 1 user user 41 Nov 16 02:22 .active-config -> custom/
```

This symlink is used internally by theme scripts to find user themes:

```fish
# Theme scripts check:
1. $FEDPUNK_PATH/.active-config/themes/  (→ custom/themes/)
2. $FEDPUNK_PATH/themes/                  (→ themes/)
```

**Why keep it?**
- Internal implementation detail
- Makes theme scripts cleaner
- Provides abstraction layer for potential future changes
- Already working, no reason to change

---

## ✅ Verification

After cleanup, verified:
- ✅ No `profiles/` directory
- ✅ No `fedpunk-use` script
- ✅ No references to "profiles" in bin/ or install/
- ✅ No references to "profiles" in README.md
- ✅ `.active-config` correctly points to `custom/`
- ✅ All theme scripts still work
- ✅ Installation scripts unchanged
- ✅ Documentation updated

---

## 🎓 Best Practices

### DO: Use custom/

```bash
# ✅ Personal themes
cp -r themes/catppuccin custom/themes/my-theme

# ✅ Personal aliases
echo "alias ll='ls -lah'" >> custom/config.fish

# ✅ Personal keybinds
echo "bind = Super, M, exec, spotify" >> custom/keybinds.conf

# ✅ Manage dotfiles
mkdir -p custom/config/git
fedpunk-stow-custom git
```

### DON'T: Modify core files

```bash
# ❌ Don't edit core configs directly
vim config/fish/.config/fish/config.fish  # NO

# ✅ Instead, override in custom/
vim custom/config.fish  # YES

# ❌ Don't edit built-in themes
vim themes/nord/kitty.conf  # NO

# ✅ Instead, copy to custom/
cp -r themes/nord custom/themes/my-nord
vim custom/themes/my-nord/kitty.conf  # YES
```

---

## 📊 Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Customization locations** | 2 (profiles/, custom/) | 1 (custom/) |
| **Empty directories** | 12 (profiles/*/{config,scripts,themes}) | 0 |
| **Unused scripts** | 1 (fedpunk-use) | 0 |
| **User confusion** | "Where do I put things?" | "Everything in custom/" |
| **Functionality** | Installation flags work | Same (no change) |
| **Themes** | custom/ → themes/ | Same (no change) |

---

## 🚀 Going Forward

**For Users:**
- Put everything in `custom/`
- Choose installation variant via bootstrap script
- No more confusion about profiles

**For Development:**
- Simpler codebase (less dead code)
- Clearer documentation
- Easier to explain to new users
- Could add proper profile system later if needed (but current approach works great)

---

**Result:** Cleaner, simpler, easier to understand, and zero functionality lost! 🎉
