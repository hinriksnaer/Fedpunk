#!/usr/bin/env fish

# Setup Claude Code configuration
# This script deploys Claude Code configs using GNU Stow

function setup-claude-code
    echo "Setting up Claude Code configuration..."

    # Check if claude-code config package exists
    if test ! -d "$FEDPUNK_PATH/config/claude"
        echo "  Skipping: Claude Code config not found"
        return 0
    end

    # Deploy claude config using stow
    cd "$FEDPUNK_PATH/config"

    # Check if files already exist and offer to adopt or skip
    set files_exist false
    if test -f "$HOME/.config/claude/config.json"; or test -f "$HOME/.mcp.json"
        set files_exist true
    end

    if test "$files_exist" = true
        echo "  ℹ Claude Code config files already exist"

        # Try to restow (updates symlinks)
        if stow -R -v -t "$HOME" claude >/dev/null 2>&1
            echo "  ✓ Claude Code configuration updated"
        else
            echo "  ⚠ Using existing Claude Code configuration"
            echo "    To adopt Fedpunk's config, run: cd ~/.local/share/fedpunk/config && stow --adopt -t ~ claude"
        end
    else
        # Fresh install
        if stow -v -t "$HOME" claude >/dev/null 2>&1
            echo "  ✓ Claude Code configuration deployed"
        else
            echo "  ✗ Failed to deploy Claude Code config"
            return 1
        end
    end

    # Verify deployment
    if test -f "$HOME/.config/claude/config.json"
        echo "  ✓ Claude config: ~/.config/claude/config.json"
    end

    if test -f "$HOME/.mcp.json"
        echo "  ✓ MCP config: ~/.mcp.json"
    end

    if test -d "$HOME/.claude/commands"
        set command_count (count ~/.claude/commands/*)
        echo "  ✓ Claude commands: $command_count command(s) available"
    end

    echo ""
    echo "  Claude Code setup complete!"
    echo "  Run 'claude' in a project to use Claude Code CLI"
    return 0
end

# Run if sourced
setup-claude-code
