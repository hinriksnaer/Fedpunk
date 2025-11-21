# Fedpunk Installation Helper Functions

**Reusable gum-based UI functions for consistent installation experience**

---

## 📋 Overview

This directory contains Fish shell helper functions that provide a **consistent, beautiful UI** for all Fedpunk installation scripts.

**Why helpers?**
- ✅ Consistent visual style across all scripts
- ✅ Abstraction over `gum` (easy to replace UI library)
- ✅ Fallbacks for non-interactive environments
- ✅ Reduced code duplication
- ✅ Easier maintenance

**Key Principle:**
All scripts should use these helpers instead of raw echo/read/gum commands.

---

## 🗂️ Structure

```
install/helpers/
├── README.md          ← You are here
├── all.fish           ← Loads all helpers (source this)
├── display.fish       ← Display functions (info, success, error, etc)
└── execution.fish     ← Execution functions (run_quiet, step, confirm)
```

---

## 🚀 Quick Start

### Import Helpers

```fish
#!/usr/bin/env fish
# Your installation script

# Source all helpers
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Now use helper functions
section "Installing Packages"
info "Installing core utilities"
run_quiet "Installing ripgrep" sudo dnf install -y ripgrep
success "Installation complete"
```

### Basic Usage

```fish
# Display messages
info "Starting installation"
success "Installation complete"
warning "Configuration file not found"
error "Installation failed"

# Sections with borders
section "Phase 1: Dependencies"

# Execute with spinner
run_quiet "Installing packages" sudo dnf install -y package1 package2

# Confirm actions
if confirm "Install optional component?"
    # User selected Yes
    step "Installing component" sudo dnf install -y component
end
```

---

## 📚 API Reference

### Display Functions (`display.fish`)

#### `info <message>`
Display informational message with → prefix (blue).

**Usage:**
```fish
info "Checking dependencies"
```

**Output:**
```
→ Checking dependencies
```

---

#### `success <message>`
Display success message with ✓ prefix (green).

**Usage:**
```fish
success "Installation complete"
```

**Output:**
```
✓ Installation complete
```

---

####`warning <message>`
Display warning message with ⚠ prefix (orange, bold).

**Usage:**
```fish
warning "Configuration file missing, using defaults"
```

**Output:**
```
⚠ Configuration file missing, using defaults
```

---

#### `error <message>`
Display error message with ✗ prefix (red, bold).

**Usage:**
```fish
error "Failed to install package"
```

**Output:**
```
✗ Failed to install package
```

---

#### `section <title>`
Display section header with bordered box (blue).

**Usage:**
```fish
section "Installing Core Packages"
```

**Output:**
```
╭────────────────────────────────╮
│  Installing Core Packages      │
╰────────────────────────────────╯
```

---

#### `box <message> [color]`
Display message in a styled rounded box.

**Parameters:**
- `message` - Text to display
- `color` - Optional gum color (33=blue, 35=green, 214=orange, 9=red)

**Usage:**
```fish
box "Installation Complete!" $GUM_SUCCESS
box "Warning: Check logs" $GUM_WARNING
box "Error occurred" $GUM_ERROR
```

**Output:**
```
╭─────────────────────────╮
│  Installation Complete! │
╰─────────────────────────╯
```

---

### Execution Functions (`execution.fish`)

#### `run_quiet <description> <command...>`
Run command with spinner, show output only on failure.

**Parameters:**
- `description` - What is being done (shown in spinner)
- `command...` - Command to execute

**Returns:**
- 0 on success
- Command exit code on failure

**Usage:**
```fish
run_quiet "Installing Fish shell" sudo dnf install -y fish

if test $status -ne 0
    error "Failed to install Fish"
    exit 1
end
```

**Behavior:**
- Shows spinner while running: `⠋ Installing Fish shell...`
- On success: Clears spinner, shows nothing
- On failure: Shows command output and error

---

#### `step <description> <command...>`
Run command with spinner (simpler, no error output).

**Parameters:**
- `description` - What is being done
- `command...` - Command to execute

**Usage:**
```fish
step "Syncing git submodules" git submodule sync --recursive
step "Updating submodules" git submodule update --init --recursive
```

**Behavior:**
- Shows spinner: `⠋ Syncing git submodules...`
- Completes silently (no success/failure message)
- Used for non-critical operations

---

#### `confirm <prompt>`
Display Yes/No confirmation dialog.

**Parameters:**
- `prompt` - Question to ask user

**Returns:**
- 0 (true) if user selects Yes
- 1 (false) if user selects No

**Usage:**
```fish
if confirm "Install NVIDIA drivers?"
    info "Installing NVIDIA drivers"
    run_quiet "Installing drivers" sudo dnf install -y nvidia-driver
else
    info "Skipping NVIDIA drivers"
end
```

**Interactive output:**
```
? Install NVIDIA drivers?
  Yes
> No
```

**Non-interactive:**
Returns default (No/false) in non-interactive mode.

---

#### `progress <current> <total> <description>`
Display progress indicator.

**Parameters:**
- `current` - Current step number
- `total` - Total steps
- `description` - What is being done

**Usage:**
```fish
set total_steps 5
progress 1 $total_steps "Installing dependencies"
progress 2 $total_steps "Configuring system"
progress 3 $total_steps "Setting up environment"
# ...
```

**Output:**
```
[1/5] Installing dependencies
[2/5] Configuring system
[3/5] Setting up environment
```

---

### Color Variables

Pre-defined gum color codes for consistent styling:

```fish
$GUM_INFO     # 33  - Blue (informational)
$GUM_SUCCESS  # 35  - Green/Cyan (success)
$GUM_WARNING  # 214 - Orange (warnings)
$GUM_ERROR    # 9   - Red (errors)
```

**Usage:**
```fish
box "Success!" $GUM_SUCCESS
box "Warning" $GUM_WARNING
box "Error" $GUM_ERROR
```

---

## 💡 Usage Patterns

### Basic Installation Script

```fish
#!/usr/bin/env fish
# install/mymodule/install.fish

source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Installing My Module"

info "Checking prerequisites"
if not command -v git >/dev/null
    error "Git not found"
    exit 1
end
success "Prerequisites OK"

if confirm "Install optional features?"
    run_quiet "Installing extras" sudo dnf install -y extra-package
    success "Extras installed"
else
    info "Skipping extras"
end

box "My Module installed successfully!" $GUM_SUCCESS
```

### Multi-Step Installation

```fish
#!/usr/bin/env fish

source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Multi-Step Installation"

set total_steps 4

progress 1 $total_steps "Installing dependencies"
run_quiet "Installing deps" sudo dnf install -y dep1 dep2

progress 2 $total_steps "Configuring system"
step "Writing config" cp config.conf ~/.config/

progress 3 $total_steps "Setting up plugins"
step "Installing plugins" ./setup-plugins.fish

progress 4 $total_steps "Finalizing"
success "Installation complete"
```

### Error Handling

```fish
#!/usr/bin/env fish

source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Installing with Error Handling"

info "Attempting installation"

if run_quiet "Installing package" sudo dnf install -y mypackage
    success "Package installed"
else
    error "Package installation failed"
    warning "Check logs at /tmp/install.log"
    exit 1
end

# Or check status explicitly
run_quiet "Building from source" make build
if test $status -ne 0
    error "Build failed"
    exit 1
end
```

### Conditional Features

```fish
#!/usr/bin/env fish

source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Conditional Installation"

info "Detecting environment"

if test -n "$DISPLAY"
    info "Desktop environment detected"

    if confirm "Install GUI components?"
        run_quiet "Installing GUI" sudo dnf install -y gui-package
        success "GUI components installed"
    end
else
    warning "No display server detected"
    info "Skipping GUI components"
end
```

---

## 🎨 Before & After Examples

### Before (Raw Commands)

```fish
#!/usr/bin/env fish

echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_BLUE}  Installing Packages${C_RESET}"
echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"

echo -e "${C_BLUE}→${C_RESET} Installing Fish shell"
sudo dnf install -y fish >/dev/null 2>&1
if test $status -eq 0
    echo -e "${C_GREEN}✓${C_RESET} Fish installed"
else
    echo -e "${C_RED}✗${C_RESET} Fish installation failed"
    exit 1
end

read -P "Install optional tools? [y/N]: " -n 1 response
if string match -qir '^y' -- $response
    echo -e "${C_BLUE}→${C_RESET} Installing extras"
    sudo dnf install -y extras >/dev/null 2>&1
end
```

### After (With Helpers)

```fish
#!/usr/bin/env fish

source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Installing Packages"

if run_quiet "Installing Fish shell" sudo dnf install -y fish
    success "Fish installed"
else
    error "Fish installation failed"
    exit 1
end

if confirm "Install optional tools?"
    run_quiet "Installing extras" sudo dnf install -y extras
end
```

**Benefits:**
- 50% less code
- More readable
- Consistent styling
- Easier to maintain
- Automatic spinner handling
- Better error handling

---

## 🔧 Non-Interactive Mode

All helpers support non-interactive mode for automation:

```bash
# Interactive (default)
fish install.fish

# Non-interactive
FEDPUNK_NON_INTERACTIVE=1 fish install.fish --non-interactive
```

**Behavior in non-interactive mode:**
- `confirm` returns false (No) by default
- Spinners still show (for CI/CD feedback)
- No user input required
- All messages still displayed

**Override defaults:**
```fish
# Check for non-interactive mode
if test -n "$FEDPUNK_NON_INTERACTIVE"
    # Skip confirmation, install anyway
    run_quiet "Installing component" sudo dnf install -y component
else
    if confirm "Install component?"
        run_quiet "Installing component" sudo dnf install -y component
    end
end
```

---

## 🆘 Troubleshooting

### Gum Not Found

```fish
# Helpers check for gum and fallback
if not command -v gum >/dev/null
    echo "Installing gum"
    sudo dnf install -y gum
end
```

### Colors Not Showing

```bash
# Check terminal supports colors
echo $TERM  # Should be xterm-256color or similar

# Force color output
export COLORTERM=truecolor
```

### Functions Not Loaded

```fish
# Verify helpers are sourced
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Check functions loaded
functions | grep -E "info|success|error|section|confirm"
```

---

## 📚 See Also

- **[Gum Documentation](https://github.com/charmbracelet/gum)** - UI library used
- **[Fish Shell Docs](https://fishshell.com/docs/current/)** - Fish shell reference
- **[Contributing Guide](../../docs/development/contributing.md)** - How to contribute

---

## 🤝 Contributing

When adding new helper functions:

1. **Choose the right file:**
   - Display functions → `display.fish`
   - Execution functions → `execution.fish`

2. **Follow naming conventions:**
   - Use snake_case for function names
   - Use descriptive names

3. **Add to this README:**
   - Document parameters
   - Provide usage examples
   - Show expected output

4. **Test in both modes:**
   - Interactive
   - Non-interactive (`--non-interactive`)

5. **Update `all.fish` if adding new file

**Example new function:**
```fish
# display.fish
function debug
    if test -n "$FEDPUNK_DEBUG"
        echo -e "$C_GRAY[DEBUG]$C_RESET $argv"
    end
end
```

---

**Helper Library Version:** 2.0
**Last Updated:** 2025-01-20
**Dependencies:** gum, fish shell
