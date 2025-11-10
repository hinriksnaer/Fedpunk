#!/usr/bin/env fish

# Source helper functions
set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

info "Installing Claude Code CLI"

# Install Node.js and npm if not present (required for Claude Code)
if not command -v npm >/dev/null 2>&1
    step "Installing Node.js and npm" "sudo dnf install -qy nodejs npm"
else
    success "Node.js and npm already installed"
end

# Install Claude Code CLI via npm
echo ""
info "Installing Claude Code CLI via npm"
gum spin --spinner dot --title "Installing Claude Code CLI..." -- fish -c '
    sudo npm install -g @anthropic-ai/claude-code >>'"$FEDPUNK_LOG_FILE"' 2>&1
'

# Verify installation
if command -v claude >/dev/null 2>&1
    success "Claude Code CLI installed successfully: "(claude --version)
else
    warning "npm installation failed, trying alternative method..."

    # Alternative: Direct download and install
    info "Downloading Claude Code binary"

    set CLAUDE_URL "https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-x64"

    # Create local bin directory
    step "Creating local bin directory" "mkdir -p ~/.local/bin"

    # Download and install
    gum spin --spinner line --title "Downloading Claude Code binary..." -- fish -c '
        curl -fL "'$CLAUDE_URL'" -o ~/.local/bin/claude >>'"$FEDPUNK_LOG_FILE"' 2>&1
        chmod +x ~/.local/bin/claude >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '

    # Verify alternative installation
    if command -v claude >/dev/null 2>&1
        success "Claude Code installed via direct download"
    else
        error "Claude Code installation failed with both methods"
        info "Please install manually from https://claude.ai/code"
        exit 1
    end
end

# Create Claude Code configuration directory
echo ""
info "Setting up Claude Code configuration"
step "Creating config directory" "mkdir -p ~/.config/claude"

# Create basic configuration
gum spin --spinner dot --title "Creating configuration file..." -- fish -c '
    printf "%s\n" \
        "{" \
        "  \"editor\": \"nvim\"," \
        "  \"shell\": \"fish\"," \
        "  \"theme\": \"dark\"," \
        "  \"ai_assistance\": {" \
        "    \"auto_complete\": true," \
        "    \"code_suggestions\": true," \
        "    \"error_explanations\": true" \
        "  }," \
        "  \"integrations\": {" \
        "    \"git\": true," \
        "    \"package_managers\": [\"npm\", \"cargo\", \"pip\", \"dnf\"]," \
        "    \"terminals\": [\"fish\", \"tmux\"]" \
        "  }" \
        "}" > ~/.config/claude/config.json >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Configuration file created"

# Set up Fish integration
echo ""
info "Configuring Fish shell integration"

# Add Claude Code to Fish PATH (if using local install)
if test -f ~/.local/bin/claude
    step "Adding Claude to PATH" "set -U fish_user_paths ~/.local/bin \$fish_user_paths"
end

# Create Fish function for Claude Code
gum spin --spinner dot --title "Creating Fish function..." -- fish -c '
    mkdir -p ~/.config/fish/functions
    printf "%s\n" \
        "function claude" \
        "    # Enhanced claude command with Fish-specific features" \
        "    if test (count \$argv) -eq 0" \
        "        # Interactive mode" \
        "        command claude" \
        "    else" \
        "        # Pass through all arguments" \
        "        command claude \$argv" \
        "    end" \
        "end" > ~/.config/fish/functions/claude.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Fish function created"

# Create minimal Fish abbreviation
gum spin --spinner dot --title "Creating Fish abbreviations..." -- fish -c '
    printf "%s\n" \
        "# Claude Code abbreviations" \
        "abbr -a cc \"claude\"" > ~/.config/fish/conf.d/claude_abbr.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Fish abbreviations created"

# Create minimal setup file
gum spin --spinner dot --title "Creating setup files..." -- fish -c '
    printf "%s\n" \
        "# Claude Code setup - minimal integration" \
        "# Run '\''claude auth login'\'' if not authenticated" > ~/.config/fish/conf.d/claude_setup.fish

    printf "%s\n" \
        "# Claude Code Integration for Fish Shell" \
        "# Minimal integration - Claude command is available globally" > ~/.config/fish/conf.d/claude_integration.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Setup files created"

# Create Fish completions for Claude Code
gum spin --spinner dot --title "Creating Fish completions..." -- fish -c '
    printf "%s\n" \
        "# Claude Code completions for Fish shell" \
        "complete -c claude -f" \
        "" \
        "# Basic commands" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"ask\" -d \"Ask Claude a question\"" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"code\" -d \"Generate or edit code\"" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"fix\" -d \"Fix code issues\"" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"explain\" -d \"Explain code\"" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"review\" -d \"Review code\"" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"test\" -d \"Generate tests\"" \
        "complete -c claude -n \"__fish_use_subcommand\" -a \"refactor\" -d \"Refactor code\"" \
        "" \
        "# Global options" \
        "complete -c claude -s h -l help -d \"Show help\"" \
        "complete -c claude -s v -l version -d \"Show version\"" \
        "complete -c claude -l config -d \"Configuration file path\"" \
        "complete -c claude -l interactive -d \"Start interactive mode\"" > ~/.config/fish/completions/claude.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Fish completions created"

echo ""
box "Claude Code Setup Complete!

Configured:
  🤖 Claude Code CLI installed
  🐟 Fish shell integration (minimal)
  ⌨️  'cc' abbreviation for claude command

Getting started:
  1. Run 'claude auth login' to authenticate
  2. Use 'claude' or 'cc' to run commands
  3. Try 'claude --interactive' for chat mode

💡 Tip: Run 'exec fish' to load the new abbreviation" $GUM_SUCCESS
echo ""
