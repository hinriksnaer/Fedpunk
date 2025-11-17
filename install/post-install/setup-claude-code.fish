#!/usr/bin/env fish

# Setup Claude Code configuration
# Claude config is now managed by chezmoi and deployed automatically

function setup-claude-code
    echo "Setting up Claude Code configuration..."

    # Verify deployment (already done by chezmoi)
    if test -f "$HOME/.config/claude/config.json"
        echo "  ✓ Claude config: ~/.config/claude/config.json"
    end

    if test -f "$HOME/.mcp.json"
        echo "  ✓ MCP config: ~/.mcp.json"
    end

    if test -d "$HOME/.claude/commands"
        set command_count (count ~/.claude/commands/* 2>/dev/null)
        if test -n "$command_count"
            echo "  ✓ Claude commands: $command_count command(s) available"
        end
    end

    echo ""
    echo "  Claude Code configuration deployed via chezmoi"
    echo "  Run 'claude' in a project to use Claude Code CLI"
    return 0
end

# Run if sourced
setup-claude-code
