#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing tmux and dependencies"

# Packages to install
set packages tmux

sudo dnf upgrade --refresh -qy
sudo dnf install -qy $packages

# Stow the configuration
stow -t $TARGET_DIR tmux

echo "→ Setting up tmux plugin manager"

# Setup tmux plugins - clone TPM if it doesn't exist
if not test -d ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
end

# Set up token for synchronization
set token tpm_done

# Start tmux and install plugins
tmux start-server \; \
  set -g exit-empty off \; \
  source-file ~/.config/tmux/tmux.conf \; \
  run-shell "~/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux wait-for -S $token" \; \
  wait-for "$token" \; \
  set -g exit-empty on

echo "✓ tmux setup complete"