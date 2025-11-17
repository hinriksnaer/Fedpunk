# Fedpunk Simplification Summary

**Date:** 2025-11-17
**Changes:** Removed incomplete `profiles/` system in favor of simpler `profiles/dev/` approach

---

## 🎯 What Changed

### Removed
- ❌ `profiles/` directory (4 empty profile directories)
- ❌ `bin/fedpunk-use` script
- ❌ `.active-config` from .gitignore (it's now just a symlink to `profiles/dev/`)
- ❌ `PROFILES_VS_CUSTOM.md` documentation

### Kept
- ✅ `profiles/dev/` directory (the ONLY place for user customizations)
- ✅ `.active-config` symlink → `profiles/dev/` (used internally by theme scripts)
- ✅ Installation mode selection via flags (`--terminal-only`)
- ✅ All 12 built-in themes in `themes/`

---

## 🤔 Why Remove Profiles?

**The Problem:**
1. **Not Implemented** - All `profiles/` subdirectories were empty
2. **Installer Ignores It** - Installation uses `--terminal-only` flag, not profile configs
3. **Confusion** - Two systems (`profiles/` and `profiles/dev/`) doing similar things
4. **Duplication** - Both had themes/, scripts/, config/ subdirectories

**The Solution:**
- Keep only `profiles/dev/` - it's simpler, clearer, and already works
- Use command-line flags for installation variants (already implemented)

---

## 📁 New Simplified Structure

```
fedpunk/
├── themes/              ← 12 built-in themes (shared)
├── profiles/dev/              ← YOUR customizations (gitignored)
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

All customizations go in `profiles/dev/`:

```bash
# Personal aliases
cat >> profiles/dev/config.fish << 'EOF'
alias gs='git status'
set -x EDITOR nvim
EOF

# Personal theme
cp -r themes/nord profiles/dev/themes/my-theme
vim profiles/dev/themes/my-theme/kitty.conf
fedpunk-theme-set my-theme

# Personal Hyprland shortcuts
cat >> profiles/dev/keybinds.conf << 'EOF'
bind = Super, M, exec, spotify
EOF

# Manage dotfiles (git, alacritty, etc.)
mkdir -p profiles/dev/config/git
vim profiles/dev/config/git/.gitconfig
fedpunk-stow-profile git
```

---

## 🔑 Key Benefits

### Before (Confusing)
```
profiles/default/       ← Empty, not used by installer
profiles/minimal/       ← Empty, not used by installer
profiles/gaming/        ← Empty, not used by installer
profiles/terminal-only/ ← Empty, not used by installer
profiles/dev/                 ← Actually works
bin/fedpunk-use         ← Script that switches between profiles
```

**Questions users would have:**
- "Should I use profiles/ or profiles/dev/?"
- "Why isn't fedpunk-use doing anything?"
- "Where do I put my themes?"

### After (Simple)
```
profiles/dev/  ← Put ALL your customizations here
```

**Clear answer:**
- ✅ One location for everything
- ✅ No confusion about profiles vs custom
- ✅ Everything actually works

---

## 🎨 Theme System (Unchanged)

The theme system continues to work exactly as before:

**Search Order:**
1. `profiles/dev/themes/` ← Your themes (highest priority)
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

Great news! Now there's only one place to look: `profiles/dev/`

---

## 📋 Internal Implementation Details

### How .active-config Works

`.active-config` is a symlink to `profiles/dev/`:

```bash
$ ls -la ~/.local/share/fedpunk/.active-config
lrwxrwxrwx 1 user user 41 Nov 16 02:22 .active-config -> profiles/dev/
```

This symlink is used internally by theme scripts to find user themes:

```fish
# Theme scripts check:
1. $FEDPUNK_PATH/.active-config/themes/  (→ profiles/dev/themes/)
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
- ✅ `.active-config` correctly points to `profiles/dev/`
- ✅ All theme scripts still work
- ✅ Installation scripts unchanged
- ✅ Documentation updated

---

## 🎓 Best Practices

### DO: Use profiles/dev/

```bash
# ✅ Personal themes
cp -r themes/catppuccin profiles/dev/themes/my-theme

# ✅ Personal aliases
echo "alias ll='ls -lah'" >> profiles/dev/config.fish

# ✅ Personal keybinds
echo "bind = Super, M, exec, spotify" >> profiles/dev/keybinds.conf

# ✅ Manage dotfiles
mkdir -p profiles/dev/config/git
fedpunk-stow-profile git
```

### DON'T: Modify core files

```bash
# ❌ Don't edit core configs directly
vim config/fish/.config/fish/config.fish  # NO

# ✅ Instead, override in profiles/dev/
vim profiles/dev/config.fish  # YES

# ❌ Don't edit built-in themes
vim themes/nord/kitty.conf  # NO

# ✅ Instead, copy to profiles/dev/
cp -r themes/nord profiles/dev/themes/my-nord
vim profiles/dev/themes/my-nord/kitty.conf  # YES
```

---

## 📊 Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Customization locations** | 2 (profiles/, profiles/dev/) | 1 (profiles/dev/) |
| **Empty directories** | 12 (profiles/*/{config,scripts,themes}) | 0 |
| **Unused scripts** | 1 (fedpunk-use) | 0 |
| **User confusion** | "Where do I put things?" | "Everything in profiles/dev/" |
| **Functionality** | Installation flags work | Same (no change) |
| **Themes** | profiles/dev/ → themes/ | Same (no change) |

---

## 🚀 Going Forward

**For Users:**
- Put everything in `profiles/dev/`
- Choose installation variant via bootstrap script
- No more confusion about profiles

**For Development:**
- Simpler codebase (less dead code)
- Clearer documentation
- Easier to explain to new users
- Could add proper profile system later if needed (but current approach works great)

---

**Result:** Cleaner, simpler, easier to understand, and zero functionality lost! 🎉
