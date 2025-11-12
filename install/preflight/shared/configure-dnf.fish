#!/usr/bin/env fish
# Configure DNF for better performance and usability

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "DNF Configuration"

info "Configuring DNF for optimal performance"

# DNF configuration file
set dnf_conf "/etc/dnf/dnf.conf"

# Check if we need to add configurations
set needs_update false

# Check each setting
if not grep -q "^fastestmirror=" "$dnf_conf" 2>/dev/null
    set needs_update true
end

if not grep -q "^max_parallel_downloads=" "$dnf_conf" 2>/dev/null
    set needs_update true
end

if not grep -q "^defaultyes=" "$dnf_conf" 2>/dev/null
    set needs_update true
end

if test "$needs_update" = true
    info "Adding performance optimizations to $dnf_conf"

    gum spin --spinner dot --title "Configuring DNF settings..." -- fish -c '
        # Backup original config
        sudo cp '"$dnf_conf"' '"$dnf_conf"'.bak >>'"$FEDPUNK_LOG_FILE"' 2>&1

        # Add settings if they don'"'"'t exist
        if not grep -q "^fastestmirror=" '"$dnf_conf"' 2>/dev/null
            echo "fastestmirror=True" | sudo tee -a '"$dnf_conf"' >>'"$FEDPUNK_LOG_FILE"' 2>&1
        end

        if not grep -q "^max_parallel_downloads=" '"$dnf_conf"' 2>/dev/null
            echo "max_parallel_downloads=10" | sudo tee -a '"$dnf_conf"' >>'"$FEDPUNK_LOG_FILE"' 2>&1
        end

        if not grep -q "^defaultyes=" '"$dnf_conf"' 2>/dev/null
            echo "defaultyes=True" | sudo tee -a '"$dnf_conf"' >>'"$FEDPUNK_LOG_FILE"' 2>&1
        end
    ' && success "DNF configuration updated" || warning "Failed to update DNF configuration"

    info "DNF will now:"
    info "  • Use fastest mirrors automatically"
    info "  • Download up to 10 packages in parallel"
    info "  • Default to 'yes' for prompts"
else
    success "DNF already configured with performance optimizations"
end

# Install Terra repository
echo ""
info "Setting up Terra repository"

if rpm -qa | grep -q "terra-release"
    success "Terra repository already installed"
else
    gum spin --spinner dot --title "Installing Terra repository..." -- fish -c '
        sudo dnf install -qy --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Terra repository installed" || warning "Failed to install Terra repository"
end

# Install app-stream metadata
echo ""
info "Installing app-stream metadata"

gum spin --spinner dot --title "Upgrading core group..." -- fish -c '
    sudo dnf group upgrade -qy core >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Core group upgraded" || warning "Core group may already be up to date"

gum spin --spinner dot --title "Installing core group..." -- fish -c '
    sudo dnf group install -qy core >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Core group installed" || warning "Core group may already be installed"

echo ""
box "DNF Configuration Complete!" $GUM_SUCCESS
