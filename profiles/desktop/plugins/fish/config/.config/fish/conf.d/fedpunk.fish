# Fedpunk environment setup
# Sets FEDPUNK_PATH for CLI tools to find themes and resources

# Set FEDPUNK_PATH to the installation directory (only if not already set)
# This allows fedpunk CLI to work from anywhere
# During installation, install.fish sets this to the repo location
if test -z "$FEDPUNK_PATH"
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
