# Fedpunk environment setup
# Sets FEDPUNK_PATH for CLI tools to find themes and resources

# Set FEDPUNK_PATH to the installation directory
# This allows fedpunk CLI to work from anywhere
set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
