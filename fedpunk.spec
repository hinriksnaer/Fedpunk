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
# GitHub creates tarballs with directory name: Fedpunk-{branch}
%autosetup -n Fedpunk-%{branch}

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

# Install CLI commands (symlinked to user space at runtime)
cp -r cli/* %{buildroot}%{_datadir}/%{name}/cli/
# Make all CLI scripts executable
find %{buildroot}%{_datadir}/%{name}/cli -name "*.fish" -exec chmod 0755 {} \;

# Install main installer script
cp install.fish %{buildroot}%{_datadir}/%{name}/install.fish
chmod 0755 %{buildroot}%{_datadir}/%{name}/install.fish

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
# Fedpunk CLI - Main entry point

# Source paths library if not already loaded
if not set -q FEDPUNK_SYSTEM
    source /usr/share/fedpunk/lib/fish/paths.fish
end

# Initialize system CLI commands on first run
function __fedpunk_init_cli
    # Ensure user CLI directory exists
    mkdir -p "$FEDPUNK_USER/cli"

    # Symlink system CLI commands if not already done
    for system_cmd in $FEDPUNK_SYSTEM/cli/*/
        if not test -d "$system_cmd"
            continue
        end

        set -l cmd_name (basename "$system_cmd")
        set -l target "$FEDPUNK_USER/cli/$cmd_name"

        # Create symlink if it doesn't exist
        if not test -e "$target"
            ln -sf "$system_cmd" "$target"
        end
    end
end

# Auto-initialize CLI on first run (fast - only creates symlinks if needed)
__fedpunk_init_cli

# Show help if no arguments
if test (count $argv) -eq 0
    echo "Fedpunk - Modular configuration engine for Fedora"
    echo ""
    echo "Usage: fedpunk <command> [options]"
    echo ""
    echo "Commands:"
    echo "  apply      Apply current configuration"
    echo "  config     Manage configuration"
    echo "  profile    Manage profiles"
    echo "  module     Manage modules"
    echo ""
    echo "Run 'fedpunk <command> --help' for more information on a command."
    exit 0
end

set subcommand $argv[1]

# Look for command in user CLI directory (includes system + module commands)
set cli_cmd "$FEDPUNK_USER/cli/$subcommand/$subcommand.fish"

if test -f "$cli_cmd"
    # Run the CLI command
    exec $cli_cmd $argv[2..-1]
else
    echo "Error: Unknown command '$subcommand'"
    echo "Run 'fedpunk' to see available commands."
    exit 1
end
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
