# Build timestamp for unstable builds (includes time for unique versions)
%global build_timestamp %(date +%%Y%%m%%d.%%H%%M%%S)
%global branch unstable

Name:           fedpunk
Version:        0.5.0
Release:        0.%{build_timestamp}.%{branch}%{?dist}
Summary:        Modular configuration engine for Fedora with Hyprland and Fish shell

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
Fedpunk is a next-generation configuration management system that transforms
Fedora into a productivity powerhouse. It provides:

- Modular architecture with automatic dependency resolution
- Profile system for multiple environments
- Plugin framework for extensibility
- Live theme engine with 12 themes
- Fish-first shell experience
- Keyboard-driven Hyprland environment

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
install -d %{buildroot}%{_datadir}/%{name}/profiles
install -d %{buildroot}%{_datadir}/%{name}/themes
install -d %{buildroot}%{_datadir}/%{name}/cli
install -d %{buildroot}%{_sysconfdir}/profile.d
install -d %{buildroot}%{_bindir}

# Install core libraries
cp -r lib/fish/* %{buildroot}%{_datadir}/%{name}/lib/fish/

# Install core modules only (minimal system)
for module in ssh essentials claude bluetui; do
    cp -r modules/$module %{buildroot}%{_datadir}/%{name}/modules/
done

# Install system profiles (default + desktop)
cp -r profiles/default %{buildroot}%{_datadir}/%{name}/profiles/
cp -r profiles/desktop %{buildroot}%{_datadir}/%{name}/profiles/

# Install themes
cp -r themes/* %{buildroot}%{_datadir}/%{name}/themes/

# Install CLI commands (symlinked to user space at runtime)
cp -r cli/* %{buildroot}%{_datadir}/%{name}/cli/
# Make all CLI scripts executable
find %{buildroot}%{_datadir}/%{name}/cli -name "*.fish" -exec chmod 0755 {} \;

# Install main installer script
cp install.fish %{buildroot}%{_datadir}/%{name}/install.fish
chmod 0755 %{buildroot}%{_datadir}/%{name}/install.fish

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
%{_bindir}/fedpunk

%post
# Create user space on first install
if [ $1 -eq 1 ]; then
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
    echo "Quick start:"
    echo "  fedpunk profile deploy default --mode container"
    echo "  fedpunk config edit"
    echo "  fedpunk apply"
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
* Mon Dec 09 2024 Hinrik Gudmundsson <email@example.com> - 0.5.0-0.1
- Initial unstable RPM packaging for COPR
- Bleeding-edge builds from main branch
- Modular architecture with external module support
- Profile system with modes (desktop/container)
- Plugin framework for extensibility
- 12 themes with live reload
- Auto-detecting installation paths (DNF vs git clone)
