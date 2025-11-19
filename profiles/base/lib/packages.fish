#!/usr/bin/env fish
# ============================================================================
# Package Installation Functions
# ============================================================================
# Individual package installation functions called by install/20-packages.fish
# Each function is named install_package_<name>
# ============================================================================

# Terminal Tools
# ============================================================================

function install_package_tmux
    install_if_missing tmux tmux
end

function install_package_neovim
    install_if_missing nvim neovim
end

function install_package_yazi
    # Yazi requires cargo build
    if command -v yazi >/dev/null
        success "Yazi already installed"
        return
    end

    step "Installing Yazi dependencies" "sudo dnf install -qy gcc"
    step "Installing Yazi via cargo" "cargo install yazi-fm yazi-cli"
end

function install_package_btop
    install_if_missing btop btop
end

function install_package_gh
    # GitHub CLI from official repo
    if command -v gh >/dev/null
        success "GitHub CLI already installed"
        return
    end

    step "Adding GitHub CLI repo" "sudo dnf install -qy 'dnf-command(config-manager)'"
    step "Enabling GitHub CLI repo" "sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo"
    step "Installing GitHub CLI" "sudo dnf install -qy gh"
end

function install_package_claude
    # Claude CLI (if available in repos, otherwise skip)
    install_if_missing claude claude
end

function install_package_lazygit
    if command -v lazygit >/dev/null
        success "lazygit already installed"
        return
    end

    step "Enabling lazygit COPR" "sudo dnf copr enable -qy atim/lazygit"
    step "Installing lazygit" "sudo dnf install -qy lazygit"
end

function install_package_cli_tools
    subsection "Installing CLI tools"
    install_packages ripgrep fd-find bat eza fzf
end

function install_package_languages
    subsection "Installing language toolchains"
    install_packages nodejs python3 python3-pip golang
end

# Desktop Environment
# ============================================================================

function install_package_kitty
    install_if_missing kitty kitty
end

function install_package_hyprland
    section "Hyprland & Wayland Environment"

    step "Enabling Hyprland COPR" "sudo dnf copr enable -qy solopasha/hyprland"

    set packages "hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland waybar polkit-gnome"
    step "Installing Hyprland packages" "sudo dnf install --refresh -qy --skip-broken --best $packages"

    set wayland_deps "wayland-protocols-devel wlroots wl-clipboard cliphist grim slurp"
    step "Installing Wayland dependencies" "sudo dnf install --refresh -qy --skip-unavailable --best $wayland_deps"

    step "Installing Qt6 Wayland support" "sudo dnf install --allowerasing --refresh -qy --skip-unavailable qt6-qtwayland"

    step "Updating graphics stack" "sudo dnf update -qy mesa-* --refresh"

    if command -v xdg-user-dirs-update >/dev/null
        step "Updating user directories" "xdg-user-dirs-update"
    end

    if test -d "$HOME/.config"
        step "Fixing SELinux contexts" "sudo restorecon -Rv $HOME/.config"
    end
end

function install_package_rofi
    install_if_missing rofi rofi
end

function install_package_firefox
    if rpm -q firefox >/dev/null 2>&1
        success "Firefox already installed"
        return
    end

    step "Refreshing package metadata" "sudo dnf makecache --refresh -q"
    step "Installing Firefox" "sudo dnf install -qy --skip-broken --best firefox"
end

function install_package_fonts
    subsection "Installing fonts"

    step "Creating fonts directory" "mkdir -p ~/.local/share/fonts"

    # Install JetBrainsMono Nerd Font
    if not test -d ~/.local/share/fonts/JetBrainsMonoNerd
        download_and_extract \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
            ~/.local/share/fonts/JetBrainsMonoNerd
    end

    # Install FantasqueSansMono Nerd Font
    if not test -d ~/.local/share/fonts/FantasqueSansMonoNerd
        download_and_extract \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FantasqueSansMono.zip" \
            ~/.local/share/fonts/FantasqueSansMonoNerd
    end

    step "Rebuilding font cache" "fc-cache -fv"
    success "Fonts installed"
end

# System Components
# ============================================================================

function install_package_audio
    subsection "Installing PipeWire audio stack"

    set pipewire_core "pipewire pipewire-alsa pipewire-pulseaudio pipewire-jack-audio-connection-kit"
    install_packages $pipewire_core

    set audio_tools "wireplumber pavucontrol easyeffects"
    install_packages $audio_tools

    step "Enabling PipeWire services" "systemctl --user enable --now pipewire pipewire-pulse wireplumber"
end

function install_package_multimedia
    subsection "Installing multimedia codecs"

    # Multimedia group install
    step "Installing multimedia packages" "sudo dnf group install -qy Multimedia"

    # Additional codecs
    set codecs "ffmpeg gstreamer1-plugins-{base,good,bad-free,ugly-free} lame* --exclude=lame-devel"
    step "Installing codecs" "sudo dnf install -qy $codecs"

    # Hardware acceleration (detect GPU)
    set gpu_type (detect_gpu)
    if test "$gpu_type" = "nvidia"
        step "Installing NVIDIA VAAPI" "sudo dnf install -qy nvidia-vaapi-driver"
    else if test "$gpu_type" = "amd"
        step "Installing AMD drivers" "sudo dnf install -qy mesa-va-drivers mesa-vdpau-drivers"
    else if test "$gpu_type" = "intel"
        step "Installing Intel drivers" "sudo dnf install -qy intel-media-driver libva-intel-driver"
    end
end

function install_package_bluetooth
    subsection "Installing Bluetooth support"

    install_packages bluez bluez-tools

    # Install bluetui (TUI manager)
    if not command -v bluetui >/dev/null
        step "Installing bluetui via cargo" "cargo install bluetui"
    else
        success "bluetui already installed"
    end

    step "Enabling Bluetooth service" "sudo systemctl enable --now bluetooth"
end

function install_package_extra_apps
    subsection "Installing extra applications"

    # Enable Terra repository
    if not rpm -q terra-release >/dev/null 2>&1
        step "Enabling Terra repository" "sudo dnf install -qy https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo"
    end

    # Install apps via Flatpak
    step "Installing Discord" "flatpak install -y flathub com.discordapp.Discord"
    step "Installing Spotify" "flatpak install -y flathub com.spotify.Client"
end

# GPU Drivers
# ============================================================================

function install_nvidia
    section "NVIDIA Drivers"

    if lspci | grep -i nvidia >/dev/null 2>&1
        step "Installing NVIDIA drivers" "sudo dnf install -qy akmod-nvidia xorg-x11-drv-nvidia-cuda"
        step "Installing NVIDIA Wayland support" "sudo dnf install -qy nvidia-vaapi-driver libva-nvidia-driver"

        info "NVIDIA drivers installed - reboot required"
    else
        warning "No NVIDIA GPU detected"
    end
end
