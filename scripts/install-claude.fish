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
cat > ~/.config/claude/config.json << 'EOF'
{
  "editor": "nvim",
  "shell": "fish",
  "theme": "dark",
  "ai_assistance": {
    "auto_complete": true,
    "code_suggestions": true,
    "error_explanations": true
  },
  "integrations": {
    "git": true,
    "package_managers": ["npm", "cargo", "pip", "dnf"],
    "terminals": ["fish", "tmux"]
  }
}
EOF

# Set up Fish integration
echo "→ Configuring Fish shell integration"

# Add Claude Code to Fish PATH (if using local install)
if test -f ~/.local/bin/claude
    set -U fish_user_paths ~/.local/bin $fish_user_paths
end

# Create Fish function for Claude Code
mkdir -p ~/.config/fish/functions
cat > ~/.config/fish/functions/claude.fish << 'EOF'
function claude
    # Enhanced claude command with Fish-specific features
    if test (count $argv) -eq 0
        # Interactive mode
        command claude --interactive
    else
        # Pass through all arguments
        command claude $argv
    end
end
EOF

# Create Fish abbreviations for common Claude Code commands
cat > ~/.config/fish/conf.d/claude_abbr.fish << 'EOF'
# Claude Code abbreviations
abbr -a cc 'claude'
abbr -a ccode 'claude code'
abbr -a cask 'claude ask'
abbr -a cfix 'claude fix'
abbr -a cexplain 'claude explain'
abbr -a creview 'claude review'
EOF

# Create Fish completions for Claude Code
cat > ~/.config/fish/completions/claude.fish << 'EOF'
# Claude Code completions for Fish shell
complete -c claude -f

# Basic commands
complete -c claude -n '__fish_use_subcommand' -a 'ask' -d 'Ask Claude a question'
complete -c claude -n '__fish_use_subcommand' -a 'code' -d 'Generate or edit code'
complete -c claude -n '__fish_use_subcommand' -a 'fix' -d 'Fix code issues'
complete -c claude -n '__fish_use_subcommand' -a 'explain' -d 'Explain code'
complete -c claude -n '__fish_use_subcommand' -a 'review' -d 'Review code'
complete -c claude -n '__fish_use_subcommand' -a 'test' -d 'Generate tests'
complete -c claude -n '__fish_use_subcommand' -a 'refactor' -d 'Refactor code'

# Global options
complete -c claude -s h -l help -d 'Show help'
complete -c claude -s v -l version -d 'Show version'
complete -c claude -l config -d 'Configuration file path'
complete -c claude -l interactive -d 'Start interactive mode'
EOF

# Set up tmux integration
echo "→ Configuring tmux integration"
if command -v tmux >/dev/null 2>&1
    # Add Claude Code keybinding to tmux
    echo "# Claude Code integration" >> ~/.config/tmux/tmux.conf
    echo "bind-key C-a new-window -n 'claude' 'claude --interactive'" >> ~/.config/tmux/tmux.conf
end

# Create startup script for Claude Code authentication
cat > ~/.config/fish/conf.d/claude_setup.fish << 'EOF'
# Check if Claude Code is authenticated on shell startup
function __claude_check_auth --on-event fish_prompt
    if command -v claude >/dev/null 2>&1
        if not claude auth status >/dev/null 2>&1
            echo "🤖 Claude Code is installed but not authenticated."
            echo "   Run 'claude auth login' to get started."
        end
    end
end
EOF

# Add Neovim integration
echo "→ Setting up Neovim integration"
mkdir -p ~/.config/nvim/lua/plugins
cat > ~/.config/nvim/lua/plugins/claude.lua << 'EOF'
-- Claude Code integration for Neovim
return {
  {
    "anthropic/claude-nvim",
    config = function()
      require("claude").setup({
        -- Configuration for Claude Code in Neovim
        auto_suggestions = true,
        keymaps = {
          ask = "<leader>ca",
          fix = "<leader>cf",
          explain = "<leader>ce",
          review = "<leader>cr",
        },
      })
    end,
  }
}
EOF

echo ""
echo "✅ Claude Code setup complete!"
echo ""
echo "🎯 What's configured:"
echo "  🤖 Claude Code CLI installed"
echo "  🐟 Fish shell integration with completions"
echo "  ⌨️  Convenient abbreviations (cc, cask, cfix, etc.)"
echo "  🪟 tmux integration (Ctrl+a, then C-a for Claude window)"
echo "  ✏️  Neovim plugin configuration"
echo ""
echo "🚀 Getting started:"
echo "  1. Run 'claude auth login' to authenticate"
echo "  2. Use 'claude ask \"your question\"' for quick queries"
echo "  3. Use 'cc' as a shortcut for claude command"
echo "  4. Try 'claude --interactive' for chat mode"
echo ""
echo "💡 Tip: Restart Fish shell or run 'exec fish' to load new functions"