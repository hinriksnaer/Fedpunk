# Build timestamp for unstable builds (includes time for unique versions)
%global build_timestamp %(date +%%Y%%m%%d.%%H%%M%%S)
%global branch unstable

Name:           fedpunk
Version:        0.5.0
Release:        0.%{build_timestamp}.%{branch}%{?dist}
Summary:        Minimal modular configuration engine for Fedora Linux

License:        MIT
URL:            https://github.com/hinriksnaer/Fedpunk
# GitHub automatic tarball for branch builds
Source0:        https://github.com/hinriksnaer/Fedpunk/archive/refs/heads/%{branch}.tar.gz

BuildArch:      noarch

# Core dependencies
Requires:       fish
Requires:       stow
Requires:       git
Requires:       yq
Requires:       jq

# UI dependencies
Requires:       gum

# Optional but recommended
Recommends:     dnf-plugins-core

%description
Fedpunk is a minimal configuration engine for Fedora Linux. It provides:

- Modular architecture with automatic dependency resolution
- External module support (git URLs, local paths)
- YAML-based module definitions
- Parameter system with interactive prompting
- GNU Stow integration for symlink-based deployment
- Fish-first shell experience

This is the core engine only. Profiles, themes, and most modules are
maintained in external repositories.

%prep
# Extract source tarball, stripping the variable top-level directory
# Works for both COPR (Fedpunk-{branch}/) and rpkg local (Fedpunk-{commit}-dirty/)
tar --strip-components=1 -xzf %{SOURCE0}

%build
# Nothing to build - pure Fish scripts

%install
# Create installation directories
install -d %{buildroot}%{_datadir}/%{name}
install -d %{buildroot}%{_datadir}/%{name}/bin
install -d %{buildroot}%{_datadir}/%{name}/lib/fish
install -d %{buildroot}%{_datadir}/%{name}/modules
install -d %{buildroot}%{_datadir}/%{name}/cli
install -d %{buildroot}%{_sysconfdir}/profile.d
install -d %{buildroot}%{_sysconfdir}/fish/conf.d
install -d %{buildroot}%{_bindir}

# Install core libraries
cp -r lib/fish/* %{buildroot}%{_datadir}/%{name}/lib/fish/

# Install core modules only (minimal system - essentials and ssh)
for module in ssh essentials; do
    cp -r modules/$module %{buildroot}%{_datadir}/%{name}/modules/
done

# Profiles are external only - no built-in profiles
# Themes are external only - no built-in themes

# Install CLI commands (symlinked to user space at runtime)
cp -r cli/* %{buildroot}%{_datadir}/%{name}/cli/
# Make all CLI scripts executable
find %{buildroot}%{_datadir}/%{name}/cli -name "*.fish" -exec chmod 0755 {} \;

# Install bin/fedpunk dispatcher
cp bin/fedpunk %{buildroot}%{_datadir}/%{name}/bin/fedpunk
chmod 0755 %{buildroot}%{_datadir}/%{name}/bin/fedpunk

# Create /etc/profile.d script to set environment variables
cat > %{buildroot}%{_sysconfdir}/profile.d/fedpunk.sh << 'EOF'
# Fedpunk environment variables
# Auto-loaded by all shells on login

# System installation location
export FEDPUNK_SYSTEM=/usr/share/fedpunk

# User data directory (auto-created on first use)
export FEDPUNK_USER=$HOME/.local/share/fedpunk

# Backward compatibility
export FEDPUNK_ROOT=$FEDPUNK_SYSTEM

# Add ~/.local/bin to PATH for user-installed binaries
# Required for tools like Claude Code, pip, cargo, npm, etc.
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

# Add Fedpunk CLI to PATH if it exists
if [ -d "$FEDPUNK_SYSTEM/cli" ]; then
    case ":$PATH:" in
        *":$FEDPUNK_SYSTEM/cli:"*) ;;
        *) export PATH="$FEDPUNK_SYSTEM/cli:$PATH" ;;
    esac
fi
EOF

# Create /etc/fish/conf.d script for Fish shell
cat > %{buildroot}%{_sysconfdir}/fish/conf.d/fedpunk.fish << 'EOF'
# Fedpunk environment variables for Fish shell
# Auto-loaded by Fish on startup

# System installation location
set -gx FEDPUNK_SYSTEM /usr/share/fedpunk

# User data directory (auto-created on first use)
set -gx FEDPUNK_USER $HOME/.local/share/fedpunk

# Backward compatibility
set -gx FEDPUNK_ROOT $FEDPUNK_SYSTEM

# Add ~/.local/bin to PATH for user-installed binaries
# Required for tools like Claude Code, pip, cargo, npm, etc.
fish_add_path -g $HOME/.local/bin

# Add Fedpunk CLI to PATH if it exists
if test -d $FEDPUNK_SYSTEM/cli
    fish_add_path -g $FEDPUNK_SYSTEM/cli
end
EOF

# Create fedpunk wrapper script in /usr/bin that delegates to bin/fedpunk
cat > %{buildroot}%{_bindir}/fedpunk << 'EOF'
#!/usr/bin/env fish
# Fedpunk CLI Wrapper - Delegates to the modular dispatcher

# Set environment variables for the dispatcher
if not set -q FEDPUNK_SYSTEM
    set -gx FEDPUNK_SYSTEM /usr/share/fedpunk
end

if not set -q FEDPUNK_USER
    set -gx FEDPUNK_USER $HOME/.local/share/fedpunk
end

# Set FEDPUNK_ROOT for backward compatibility with bin/fedpunk
set -gx FEDPUNK_ROOT $FEDPUNK_SYSTEM

# Delegate to the modular dispatcher
exec $FEDPUNK_SYSTEM/bin/fedpunk $argv
EOF
chmod 0755 %{buildroot}%{_bindir}/fedpunk

%files
%license LICENSE
%doc README.md
%doc docs/

%{_datadir}/%{name}/
%{_sysconfdir}/profile.d/fedpunk.sh
%{_sysconfdir}/fish/conf.d/fedpunk.fish
%{_bindir}/fedpunk

%post
# Create user space and initialize config on first install
if [ $1 -eq 1 ]; then
    # Initialize config for all users who run fedpunk
    # This will be created on first use, but we can create a system-wide template
    CONFIG_DIR="$HOME/.config/fedpunk"
    CONFIG_FILE="$CONFIG_DIR/fedpunk.yaml"

    # Only create if running as a user (not root during package install)
    if [ -n "$SUDO_USER" ]; then
        # Get the actual user's home directory
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        CONFIG_DIR="$USER_HOME/.config/fedpunk"
        CONFIG_FILE="$CONFIG_DIR/fedpunk.yaml"

        # Create config directory
        mkdir -p "$CONFIG_DIR"
        mkdir -p "$CONFIG_DIR/profiles"

        # Create initial config file
        cat > "$CONFIG_FILE" <<EOF
# Fedpunk Configuration
# Auto-generated on $(date)

profile: null
mode: null
modules:
  enabled: []
  disabled: []
EOF

        # Set ownership to the actual user
        chown -R "$SUDO_USER:$SUDO_USER" "$CONFIG_DIR"
    fi

    echo "=========================================="
    echo "Fedpunk (UNSTABLE) installed successfully"
    echo "=========================================="
    echo ""
    echo "WARNING: This is a bleeding-edge build from the main branch."
    echo "Expect bugs and breaking changes. Use at your own risk!"
    echo ""
    echo "Installation location: /usr/share/fedpunk"
    echo "Configuration: ~/.config/fedpunk/fedpunk.yaml"
    echo ""
    echo "Fedpunk is a minimal configuration engine."
    echo "No profiles or modules are installed by default."
    echo ""
    echo "Quick start (deploy external modules):"
    echo "  fedpunk module deploy essentials"
    echo "  fedpunk module deploy ssh"
    echo "  fedpunk module deploy https://github.com/user/module.git"
    echo ""
    echo "Deploy external profiles:"
    echo "  fedpunk profile deploy https://github.com/user/profile.git --mode desktop"
    echo ""
    echo "Example: Deploy Hyprpunk desktop environment"
    echo "  fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk.git --mode desktop"
    echo ""
    echo "Report issues: https://github.com/hinriksnaer/Fedpunk/issues"
    echo "=========================================="
fi

%postun
# Clean up user space on complete removal
if [ $1 -eq 0 ]; then
    echo "Fedpunk has been removed."
    echo "User data remains in ~/.local/share/fedpunk"
    echo "Remove manually if desired: rm -rf ~/.local/share/fedpunk"
fi

%changelog
* Wed Dec 18 2024 Hinrik Gudmundsson <email@example.com> - 0.5.0-1
- Transform to minimal core architecture
- Remove all built-in profiles (external only)
- Remove all themes (126 MB reduction)
- Remove claude and bluetui modules (external only)
- Only 2 core modules: essentials and ssh
- Remove legacy installer.fish and toml-parser.fish
- Total reduction: ~23,000 lines of code
- Core package now <1 MB (excluding git)
- External-first architecture for profiles and modules
- Updated documentation for minimal core approach

* Mon Dec 09 2024 Hinrik Gudmundsson <email@example.com> - 0.5.0-0.1
- Initial unstable RPM packaging for COPR
- Bleeding-edge builds from main branch
- Modular architecture with external module support
- Profile system with modes (desktop/container)
- Plugin framework for extensibility
- 12 themes with live reload
- Auto-detecting installation paths (DNF vs git clone)
