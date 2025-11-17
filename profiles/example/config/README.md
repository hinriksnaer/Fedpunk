# Custom Dotfiles (Stow-based)

This directory uses [chezmoi](https://www.gnu.org/software/stow/) to manage your custom dotfiles.

## How It Works

Each subdirectory here is a "Stow package" that mirrors your home directory structure:

```
custom/config/
├── nvim/                    # Package name
│   └── .config/            # Mirrors ~/ structure
│       └── nvim/
│           └── lua/
│               └── custom/
│                   └── my-plugin.lua
├── tmux/
│   └── .config/
│       └── tmux/
│           └── tmux.conf.local
├── git/
│   ├── .gitconfig          # Personal git config
│   └── .gitignore_global
└── alacritty/              # New app not in Fedpunk
    └── .config/
        └── alacritty/
            └── alacritty.toml
```

When you stow a package, it creates symlinks from your home directory to these files.

## Quick Start

### 1. Create Your Package

```bash
# Example: Custom Neovim config
mkdir -p custom/config/nvim-custom/.config/nvim/lua/custom
echo 'print("My custom Neovim config!")' > custom/config/nvim-custom/.config/nvim/lua/custom/init.lua
```

### 2. Stow It

```bash
# From the fedpunk directory
stow -d custom/config -t ~ nvim-custom

# Or use the helper script
fedpunk-stow-custom nvim-custom
```

### 3. Verify

```bash
# Check the symlink was created
ls -la ~/.config/nvim/lua/custom/init.lua
# Should point to: ~/.local/share/fedpunk/custom/config/nvim-custom/.config/nvim/lua/custom/init.lua
```

## Common Patterns

### Override Existing Fedpunk Configs

**Important:** Don't create packages with the same name as Fedpunk's configs. Instead, create separate packages that add to them:

```bash
# Good: Extend nvim config
custom/config/nvim-custom/.config/nvim/lua/custom/

# Bad: Replace entire nvim config (will conflict)
custom/config/nvim/.config/nvim/init.lua
```

### Add New App Configs

For apps not managed by Fedpunk:

```bash
# Example: Alacritty terminal
mkdir -p custom/config/alacritty/.config/alacritty
cat > custom/config/alacritty/.config/alacritty/alacritty.toml << 'EOF'
[font]
size = 12.0

[window]
opacity = 0.95
EOF

stow -d custom/config -t ~ alacritty
```

### Personal Git Config

```bash
mkdir -p custom/config/git
cat > custom/config/git/.gitconfig << 'EOF'
[user]
    name = Your Name
    email = you@example.com

[core]
    editor = nvim

[alias]
    st = status
    co = checkout
    br = branch
EOF

fedpunk-stow-custom git
```

### SSH Config

```bash
mkdir -p custom/config/ssh/.ssh
chmod 700 custom/config/ssh/.ssh

cat > custom/config/ssh/.ssh/config << 'EOF'
Host github
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

Host work
    HostName work-server.com
    User yourname
    Port 2222
EOF

chmod 600 custom/config/ssh/.ssh/config
fedpunk-stow-custom ssh
```

## Managing Custom Dotfiles

### List Stowed Packages

```bash
# See what's currently stowed from custom/config
fedpunk-stow-custom --list
```

### Unstow (Remove Symlinks)

```bash
# Remove symlinks for a package
stow -d custom/config -t ~ -D nvim-custom

# Or use helper
fedpunk-stow-custom --delete nvim-custom
```

### Restow (Refresh Symlinks)

```bash
# Useful after modifying package structure
stow -d custom/config -t ~ -R nvim-custom

# Or use helper
fedpunk-stow-custom --restow nvim-custom
```

### Stow All Custom Configs

```bash
# Stow everything in custom/config/
fedpunk-stow-custom --all
```

## Directory Structure Examples

### Neovim Custom Plugin

```
custom/config/nvim-custom/
└── .config/
    └── nvim/
        └── lua/
            └── custom/
                ├── init.lua
                ├── keymaps.lua
                └── plugins/
                    └── my-plugin.lua
```

Then in your main nvim config:
```lua
-- In ~/.config/nvim/init.lua or similar
require('custom')
```

### Tmux Local Overrides

```
custom/config/tmux-custom/
└── .config/
    └── tmux/
        └── tmux.conf.local
```

Then in main tmux.conf:
```bash
# Source local config if it exists
source-file -q ~/.config/tmux/tmux.conf.local
```

### Personal Scripts

```
custom/config/local-bin/
└── .local/
    └── bin/
        ├── my-backup-script.sh
        ├── project-launcher.fish
        └── ...
```

Stow this and scripts are automatically in PATH (since `~/.local/bin` is in PATH).

## Tips

**1. Test Before Stowing**

```bash
# Dry run - see what would be created
stow -d custom/config -t ~ -n -v nvim-custom
```

**2. Handle Conflicts**

If a file already exists and isn't a symlink:
```bash
# Stow will error - you need to move/remove the existing file
mv ~/.config/app/config.yaml ~/.config/app/config.yaml.bak
stow -d custom/config -t ~ app
```

**3. Keep Secrets Out of Git**

If you version control `custom/`:
```bash
# custom/.gitignore
config/ssh/.ssh/
config/git/.gitconfig  # If it contains personal email
*.key
*.pem
```

**4. Platform-Specific Configs**

```bash
# Organize by hostname/platform
custom/config/
├── nvim-linux/
├── nvim-mac/
└── nvim-work/

# Stow the right one
fedpunk-stow-custom nvim-$(uname -s | tr '[:upper:]' '[:lower:]')
```

## Integration with Fedpunk Configs

### Extending vs Replacing

**Extend (Recommended):**
- Use different package names
- Source your custom configs from main configs
- Example: `nvim-custom` package that main config requires

**Replace (Use Cautiously):**
- Unstow Fedpunk's package first
- Stow your replacement
- You'll need to manually manage updates

### Example: Extending Neovim

```bash
# 1. Create custom package
mkdir -p custom/config/nvim-personal/.config/nvim/lua/personal
echo 'vim.opt.number = true' > custom/config/nvim-personal/.config/nvim/lua/personal/init.lua

# 2. Stow it
fedpunk-stow-custom nvim-personal

# 3. Source in main config (one-time manual step)
# Add to ~/.config/nvim/init.lua:
# pcall(require, 'personal')
```

## Troubleshooting

**"stow: command not found"**
```bash
# Install chezmoi (should be installed by Fedpunk, but just in case)
sudo dnf install stow
```

**"WARNING! stowing X would cause conflicts"**
```bash
# A real file exists where the symlink would go
# Option 1: Back it up
mv ~/.config/app/file ~/.config/app/file.bak

# Option 2: Merge it into your custom package
cp ~/.config/app/file custom/config/app/.config/app/
rm ~/.config/app/file
stow -d custom/config -t ~ app
```

**Symlinks not working**
```bash
# Check symlink target
ls -la ~/.config/app/file

# Verify package structure mirrors home directory
tree custom/config/app
# Should start with .config/ or .local/ etc., NOT app/
```

**Want to version control custom/config/**
```bash
cd custom/config
git init
git add .
git commit -m "My custom dotfiles"
# Push to private repo
```

---

## Quick Reference

```bash
# Create package
mkdir -p custom/config/<package>/.config/<app>/

# Stow (create symlinks)
fedpunk-stow-custom <package>

# Unstow (remove symlinks)
fedpunk-stow-custom --delete <package>

# Restow (refresh)
fedpunk-stow-custom --restow <package>

# Stow all
fedpunk-stow-custom --all

# Dry run
stow -d custom/config -t ~ -n -v <package>
```
