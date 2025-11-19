#!/usr/bin/env fish
# Install nvim-mcp server for Claude Code integration

function install_nvim_mcp
    echo "🔧 Installing nvim-mcp server..."

    # Check if cargo is installed
    if not command -v cargo &>/dev/null
        echo "⚠️  Cargo not found. Installing Rust toolchain..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    end

    # Install nvim-mcp
    if not command -v nvim-mcp &>/dev/null
        echo "📦 Installing nvim-mcp via cargo..."
        cargo install nvim-mcp
        echo "✅ nvim-mcp installed successfully"
    else
        echo "✅ nvim-mcp already installed"
    end

    # Create .mcp.json configuration
    set mcp_config '{
  "mcpServers": {
    "nvim": {
      "command": "nvim-mcp",
      "args": ["--connect", "auto"],
      "env": {
        "NVIM_AUTO_CONNECT": "${NVIM}"
      }
    }
  }
}'

    # Add to any project that has .git directory
    for project_dir in ~/Documents/*/.git ~/Projects/*/.git
        if test -d "$project_dir"
            set project_root (dirname "$project_dir")
            set mcp_file "$project_root/.mcp.json"

            if not test -f "$mcp_file"
                echo "📝 Creating .mcp.json in $project_root"
                echo "$mcp_config" > "$mcp_file"
            end
        end
    end

    echo "✨ nvim-mcp setup complete"
end

install_nvim_mcp
