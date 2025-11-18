{ config, pkgs, lib, terminalOnly ? false, ... }:

{
  # Basic user info
  home.username = "softmax";
  home.homeDirectory = "/home/softmax";
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Package management - this replaces DNF + all installation scripts!
  home.packages = with pkgs; [
    # === Shell & Terminal Essentials ===
    fish              # Modern shell
    starship          # Fast prompt
    fzf               # Fuzzy finder
    ripgrep           # Better grep
    fd                # Better find
    lsd               # Better ls
    eza               # Another better ls
    bat               # Better cat

    # === Development Tools ===
    git               # Version control
    gh                # GitHub CLI
    lazygit           # Git TUI

    # === Editor & Multiplexer ===
    neovim            # Editor
    tmux              # Terminal multiplexer

    # === System Tools ===
    btop              # System monitor
    yazi              # File manager

    # === Nix Tools ===
    nil               # Nix LSP
    nixpkgs-fmt       # Nix formatter

  ] ++ lib.optionals (!terminalOnly) [
    # === Desktop (only if not terminal-only) ===
    kitty             # Terminal emulator
    hyprland          # Wayland compositor
    waybar            # Status bar
    rofi-wayland      # Launcher
    mako              # Notifications
    hyprpaper         # Wallpaper daemon

    # === Fonts ===
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];

  # Font configuration
  fonts.fontconfig.enable = true;

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    FEDPUNK_PATH = "${config.home.homeDirectory}/.local/share/fedpunk";
  };

  # TODO: Deploy raw configs (next step - after moving home/ to config/)
  # home.file.".config/fish".source = config.lib.file.mkOutOfStoreSymlink
  #   "${config.home.homeDirectory}/.local/share/fedpunk/config/fish";
}
