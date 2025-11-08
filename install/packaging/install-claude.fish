#!/usr/bin/env fish

echo "🤖 Installing Claude Code CLI"
echo "============================="

# Install Node.js and npm if not present (required for Claude Code)
if not command -v npm >/dev/null 2>&1
    echo "→ Installing Node.js and npm"
    sudo dnf install -qy nodejs npm
else
    echo "✅ Node.js and npm already installed"
end

# Install Claude Code CLI via npm
echo "→ Installing Claude Code CLI"
sudo npm install -g @anthropic-ai/claude-code

# Verify installation
if command -v claude >/dev/null 2>&1
    echo "✅ Claude Code CLI installed successfully"
    echo "   Version: "(claude --version)
else
    echo "❌ Claude Code installation failed"
    echo "   Trying alternative installation method..."
    
    # Alternative: Direct download and install
    echo "→ Downloading Claude Code binary"
    set CLAUDE_VERSION "latest"
    set CLAUDE_URL "https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-x64"
    
    # Create local bin directory
    mkdir -p ~/.local/bin
    
    # Download and install
    curl -fL "$CLAUDE_URL" -o ~/.local/bin/claude
    chmod +x ~/.local/bin/claude
    
    # Verify alternative installation
    if command -v claude >/dev/null 2>&1
        echo "✅ Claude Code installed via direct download"
    else
        echo "❌ Claude Code installation failed with both methods"
        echo "   Please install manually from https://claude.ai/code"
        exit 1
    end
end

# Create Claude Code configuration directory
echo "→ Setting up Claude Code configuration"
mkdir -p ~/.config/claude

# Create basic configuration
printf "%s\n" \
    '{' \
    '  "editor": "nvim",' \
    '  "shell": "fish",' \
    '  "theme": "dark",' \
    '  "ai_assistance": {' \
    '    "auto_complete": true,' \
    '    "code_suggestions": true,' \
    '    "error_explanations": true' \
    '  },' \
    '  "integrations": {' \
    '    "git": true,' \
    '    "package_managers": ["npm", "cargo", "pip", "dnf"],' \
    '    "terminals": ["fish", "tmux"]' \
    '  }' \
    '}' > ~/.config/claude/config.json

# Set up Fish integration
echo "→ Configuring Fish shell integration"

# Add Claude Code to Fish PATH (if using local install)
if test -f ~/.local/bin/claude
    set -U fish_user_paths ~/.local/bin $fish_user_paths
end

# Create Fish function for Claude Code
mkdir -p ~/.config/fish/functions
printf "%s\n" \
    'function claude' \
    '    # Enhanced claude command with Fish-specific features' \
    '    if test (count $argv) -eq 0' \
    '        # Interactive mode' \
    '        command claude \
    '    else' \
    '        # Pass through all arguments' \
    '        command claude $argv' \
    '    end' \
    'end' > ~/.config/fish/functions/claude.fish

# Create minimal Fish abbreviation
printf "%s\n" \
    '# Claude Code abbreviations' \
    'abbr -a cc "claude"' > ~/.config/fish/conf.d/claude_abbr.fish

# Create minimal setup file
printf "%s\n" \
    '# Claude Code setup - minimal integration' \
    '# Run '"'"'claude auth login'"'"' if not authenticated' > ~/.config/fish/conf.d/claude_setup.fish

# Create minimal integration file
printf "%s\n" \
    '# Claude Code Integration for Fish Shell' \
    '# Minimal integration - Claude command is available globally' > ~/.config/fish/conf.d/claude_integration.fish

# Create Fish completions for Claude Code
printf "%s\n" \
    '# Claude Code completions for Fish shell' \
    'complete -c claude -f' \
    '' \
    '# Basic commands' \
    'complete -c claude -n "__fish_use_subcommand" -a "ask" -d "Ask Claude a question"' \
    'complete -c claude -n "__fish_use_subcommand" -a "code" -d "Generate or edit code"' \
    'complete -c claude -n "__fish_use_subcommand" -a "fix" -d "Fix code issues"' \
    'complete -c claude -n "__fish_use_subcommand" -a "explain" -d "Explain code"' \
    'complete -c claude -n "__fish_use_subcommand" -a "review" -d "Review code"' \
    'complete -c claude -n "__fish_use_subcommand" -a "test" -d "Generate tests"' \
    'complete -c claude -n "__fish_use_subcommand" -a "refactor" -d "Refactor code"' \
    '' \
    '# Global options' \
    'complete -c claude -s h -l help -d "Show help"' \
    'complete -c claude -s v -l version -d "Show version"' \
    'complete -c claude -l config -d "Configuration file path"' \
    'complete -c claude -l interactive -d "Start interactive mode"' > ~/.config/fish/completions/claude.fish

# tmux integration removed - use 'claude' command directly in any tmux pane

echo ""
echo "✅ Claude Code setup complete!"
echo ""
echo "🎯 What's configured:"
echo "  🤖 Claude Code CLI installed"
echo "  🐟 Fish shell integration (minimal)"
echo "  ⌨️  'cc' abbreviation for claude command"
echo ""
echo "🚀 Getting started:"
echo "  1. Run 'claude auth login' to authenticate"
echo "  2. Use 'claude' or 'cc' to run commands"
echo "  3. Try 'claude --interactive' for chat mode"
echo ""
echo "💡 Tip: Run 'exec fish' to load the new abbreviation"
