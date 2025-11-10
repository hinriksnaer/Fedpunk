# Fedpunk Installation Helper Functions

Reusable gum-based interface functions for consistent installation experience.

## Available Functions

### Display Functions

#### `info <message>`
Display an informational message with → prefix.
```fish
info "Installing packages"
```

#### `success <message>`
Display a success message with ✓ prefix.
```fish
success "Installation complete"
```

#### `warning <message>`
Display a warning message with ⚠ prefix (bold, orange).
```fish
warning "No display server detected"
```

#### `error <message>`
Display an error message with ✗ prefix (bold, red).
```fish
error "Installation failed"
```

#### `section <title>`
Display a section header with a bordered box.
```fish
section "Installing Packages"
```

#### `box <message> [color]`
Display a message in a styled rounded box.
```fish
box "Installation complete!" $GUM_SUCCESS
```

### Execution Functions

#### `run_quiet <description> <command...>`
Run a command with a spinner, show output only on failure.
```fish
run_quiet "Installing Fish" sudo dnf install -y fish
```

#### `step <description> <command...>`
Run a command with a spinner (simpler version, no error output).
```fish
step "Syncing submodules" git submodule sync --recursive
```

### Interactive Functions

#### `confirm <prompt>`
Display a Yes/No confirmation using gum.
```fish
if confirm "Install Claude CLI?"
    # User selected Yes
end
```

#### `progress <current> <total> <description>`
Display a progress indicator.
```fish
progress 3 10 "Installing neovim"
```

## Color Variables

- `$GUM_INFO` (33) - Blue for informational messages
- `$GUM_SUCCESS` (35) - Green/Cyan for success messages
- `$GUM_WARNING` (214) - Orange for warnings
- `$GUM_ERROR` (9) - Red for errors

## Usage Example

```fish
#!/usr/bin/env fish

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "My Installation Step"

info "Starting installation"

if confirm "Install optional component?"
    step "Installing component" sudo dnf install -y component
    success "Component installed"
else
    info "Skipping optional component"
end

run_quiet "Final setup" some-setup-command

box "Installation Complete!" $GUM_SUCCESS
```

## Migration Guide

Old pattern:
```fish
echo -e "${C_BLUE}→${C_RESET} Installing packages"
read -P "Install Claude? [y/N]: " -n 1 response
if string match -qir '^y' -- $response
    # install
end
```

New pattern:
```fish
info "Installing packages"
if confirm "Install Claude?"
    # install
end
```
