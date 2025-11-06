#!/usr/bin/env fish

# Figure out target user and home directory (works with/without sudo)
if test (id -u) -eq 0
    if set -q SUDO_USER; and test "$SUDO_USER" != "root"
        set TARGET_USER $SUDO_USER
        set TARGET_HOME (getent passwd $SUDO_USER | cut -d: -f6)
    else
        set TARGET_USER root
        set TARGET_HOME /root
    end
else
    set TARGET_USER (whoami)
    set TARGET_HOME $HOME
end

echo "→ Installing Neovim and dependencies for user: $TARGET_USER ($TARGET_HOME)"

cd (dirname (status -f))/../

# System packages
set packages ripgrep fzf

# Use sudo for package operations if not root
set SUDO_CMD ""
if test (id -u) -ne 0
    set SUDO_CMD sudo
end

$SUDO_CMD dnf upgrade --refresh -qy
$SUDO_CMD dnf install -qy $packages

# User-local Neovim install (no sudo)
set TMPDIR (mktemp -d)

# Cleanup function equivalent
function cleanup_tmpdir --on-process-exit
    rm -rf $TMPDIR
end

mkdir -p "$TARGET_HOME/.local" "$TARGET_HOME/.local/bin"

echo "→ Downloading Neovim"
curl -fL --retry 3 -o "$TMPDIR/nvim.tar.gz" \
  "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

# Extract into ~/.local
tar -xzf "$TMPDIR/nvim.tar.gz" -C "$TARGET_HOME/.local"

# Create symlink
ln -sfn "$TARGET_HOME/.local/nvim-linux-x86_64/bin/nvim" \
        "$TARGET_HOME/.local/bin/nvim"

# Ensure ownership if script was run with sudo
if test (id -u) -eq 0; and test "$TARGET_USER" != "root"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local"
end

# Ensure ~/.local/bin is on PATH for future shells
set add_path_line 'export PATH="$HOME/.local/bin:$PATH"'
for rc in "$TARGET_HOME/.bashrc" "$TARGET_HOME/.zshrc"
    if test -f $rc; and not grep -qF $add_path_line $rc
        echo $add_path_line >> $rc
    end
end

# Stow Neovim config
if test -d "neovim"
    echo "→ Stowing neovim configuration"
    stow -t $TARGET_HOME neovim
else if test -d "nvim"
    echo "→ Stowing nvim configuration"
    stow -t $TARGET_HOME nvim
else
    echo "⚠️ No 'neovim' or 'nvim' directory found; skipping stow"
end

echo "✓ Neovim setup complete. Run: nvim --version"