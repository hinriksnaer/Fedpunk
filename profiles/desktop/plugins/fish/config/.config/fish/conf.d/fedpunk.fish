# Fedpunk environment setup
# Sets FEDPUNK_PATH for CLI tools to find themes and resources

# Set FEDPUNK_PATH to the installation directory (only if not already set)
# This allows fedpunk CLI to work from anywhere
# During installation, install.fish sets this to the repo location
if test -z "$FEDPUNK_PATH"
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end

# Add ~/.local/bin to PATH for user-installed binaries
# Required for tools like Claude Code, pip, cargo, npm, etc.
# that install executables to ~/.local/bin by default
fish_add_path -g ~/.local/bin
