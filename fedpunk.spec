# Commit hash for unstable builds (set by COPR or manually)
%{!?commit: %global commit HEAD}
%global shortcommit %(c=%{commit}; echo ${c:0:7})
%global build_date %(date +%%Y%%m%%d)

Name:           fedpunk
Version:        0.5.0
Release:        0.1.%{build_date}git%{shortcommit}%{?dist}
Summary:        Modular configuration engine for Fedora with Hyprland and Fish shell

License:        MIT
URL:            https://github.com/hinriksnaer/Fedpunk
# For unstable builds, COPR will use the commit tarball
Source0:        %{url}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz

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
# GitHub creates tarballs with format: Fedpunk-<commit>/
%autosetup -n Fedpunk-%{commit}

%build
# Nothing to build - pure Fish scripts

%install
# Create installation directories
install -d %{buildroot}%{_datadir}/%{name}
install -d %{buildroot}%{_datadir}/%{name}/lib/fish
install -d %{buildroot}%{_datadir}/%{name}/modules
install -d %{buildroot}%{_datadir}/%{name}/profiles
install -d %{buildroot}%{_datadir}/%{name}/themes
install -d %{buildroot}%{_datadir}/%{name}/cli
install -d %{buildroot}%{_sysconfdir}/profile.d
install -d %{buildroot}%{_bindir}

# Install core libraries
cp -r lib/fish/* %{buildroot}%{_datadir}/%{name}/lib/fish/

# Install built-in modules
cp -r modules/* %{buildroot}%{_datadir}/%{name}/modules/

# Install system profiles (default and example, NOT dev)
cp -r profiles/default %{buildroot}%{_datadir}/%{name}/profiles/
cp -r profiles/example %{buildroot}%{_datadir}/%{name}/profiles/

# Install themes
cp -r themes/* %{buildroot}%{_datadir}/%{name}/themes/

# Install CLI commands
cp -r cli/* %{buildroot}%{_datadir}/%{name}/cli/

# Install main installer script
install -m 0755 install.fish %{buildroot}%{_datadir}/%{name}/install.fish

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

# Add Fedpunk CLI to PATH if it exists
if [ -d "$FEDPUNK_SYSTEM/cli" ]; then
    case ":$PATH:" in
        *":$FEDPUNK_SYSTEM/cli:"*) ;;
        *) export PATH="$FEDPUNK_SYSTEM/cli:$PATH" ;;
    esac
fi
EOF

# Create fedpunk wrapper script in /usr/bin
cat > %{buildroot}%{_bindir}/fedpunk << 'EOF'
#!/usr/bin/env fish
# Fedpunk command wrapper

# Source paths library if not already loaded
if not set -q FEDPUNK_SYSTEM
    source /usr/share/fedpunk/lib/fish/paths.fish
end

# Handle subcommands (currently only 'install' is supported)
# Skip the 'install' subcommand if present and pass remaining args
if test (count $argv) -gt 0; and test "$argv[1]" = "install"
    set -e argv[1]  # Remove 'install' from arguments
end

# Run install.fish with remaining arguments
exec /usr/share/fedpunk/install.fish $argv
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
    echo ""
    echo "To complete installation, run:"
    echo "  fedpunk install"
    echo ""
    echo "For container/server mode:"
    echo "  fedpunk install --mode container"
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
