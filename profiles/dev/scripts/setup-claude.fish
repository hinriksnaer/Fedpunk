#!/usr/bin/env fish
# Setup script for Claude Code authentication
# Prompts user to choose between standard API key or Google Vertex AI authentication

set script_dir (dirname (status --current-filename))
set profile_dir (dirname $script_dir)
set config_file "$profile_dir/config.fish"

# Check if gum is available
if not command -v gum >/dev/null 2>&1
    echo "Error: gum is required for this setup script"
    echo "Install with: sudo dnf install -y gum"
    exit 1
end

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Code Authentication Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check current status
set current_status "disabled"
if grep -q "^source.*claude-vertex.fish" "$config_file" 2>/dev/null
    set current_status "enabled"
end

echo "Current status: Claude Vertex AI is $current_status"
echo ""

# Ask if user wants to configure
set configure (gum choose \
    --header "Do you want to configure Claude Code authentication?" \
    --cursor.foreground="212" \
    "Yes" "No" \
    </dev/tty)

if test "$configure" = "No"
    echo ""
    echo "⏭️  Skipping Claude authentication setup"
    echo ""
    exit 0
end

echo ""

# Prompt for authentication method
set auth_method (gum choose \
    --header "Choose Claude Code authentication method:" \
    --cursor.foreground="212" \
    "Standard API Key" \
    "Google Vertex AI" \
    </dev/tty)

echo ""

if test "$auth_method" = "Google Vertex AI"
    # Enable Vertex AI
    echo "🔐 Enabling Google Vertex AI authentication..."

    # Uncomment the source line
    sed -i 's/^# source (dirname (status --current-filename))\/claude-vertex.fish/source (dirname (status --current-filename))\/claude-vertex.fish/' "$config_file"

    echo "✓ Google Vertex AI authentication enabled"
    echo ""
    echo "Configuration:"
    echo "  CLAUDE_CODE_USE_VERTEX: 1"
    echo "  CLOUD_ML_REGION: us-east5"
    echo "  ANTHROPIC_VERTEX_PROJECT_ID: itpc-gcp-ai-eng-claude"
    echo ""
    echo "⚠️  Restart your shell for changes to take effect:"
    echo "  exec fish"
else
    # Disable Vertex AI
    echo "🔑 Using standard API key authentication..."

    # Comment out the source line
    sed -i 's/^source (dirname (status --current-filename))\/claude-vertex.fish/# source (dirname (status --current-filename))\/claude-vertex.fish/' "$config_file"

    echo "✓ Standard API key authentication enabled"
    echo ""
    echo "⚠️  Restart your shell for changes to take effect:"
    echo "  exec fish"
end

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
