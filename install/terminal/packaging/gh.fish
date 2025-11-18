#!/usr/bin/env fish
# GitHub CLI (gh) - Official GitHub CLI tool
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "GitHub CLI"

# Check if gh is already installed
if command -v gh >/dev/null 2>&1
    success "GitHub CLI already installed: "(gh --version | head -n1)
else
    install_package gh

    # Verify installation
    if command -v gh >/dev/null 2>&1
        success "GitHub CLI installed successfully: "(gh --version | head -n1)
    else
        error "Failed to install GitHub CLI"
        exit 1
    end
end

# Check authentication status
echo ""
info "Checking GitHub CLI authentication status"
if gh auth status >/dev/null 2>&1
    success "GitHub CLI is authenticated"
    gh auth status
else
    info "GitHub CLI is not authenticated yet"

    # Only prompt for authentication in interactive mode
    if not set -q FEDPUNK_NON_INTERACTIVE
        echo ""
        if confirm "Authenticate GitHub CLI now?" "yes"
            info "Starting GitHub CLI authentication..."
            info "Please follow the prompts to authenticate with GitHub"
            gh auth login

            if gh auth status >/dev/null 2>&1
                success "GitHub CLI authenticated successfully"
            else
                warning "GitHub CLI authentication was not completed"
                info "You can authenticate later with: gh auth login"
            end
        else
            info "Skipping GitHub CLI authentication"
            info "You can authenticate later with: gh auth login"
        end
    else
        info "Non-interactive mode: skipping authentication"
        info "Authenticate later with: gh auth login"
    end
end

echo ""
box "GitHub CLI Ready!

✓ gh command available

Next steps:
  • Authenticate: gh auth login
  • Clone repos: gh repo clone owner/repo
  • Manage PRs: gh pr list

💡 Run 'gh --help' for more commands" $GUM_SUCCESS
echo ""
