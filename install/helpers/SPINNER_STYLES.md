# Gum Spinner Styles Reference

The helper functions use `gum spin` with various spinner styles to provide visual feedback during operations. Here are the available spinner styles and when to use them:

## Available Spinners

- **dot** (default) - Simple dot animation, good for quick operations
- **line** - Horizontal line animation, good for downloads and network operations
- **moon** - Moon phases, good for discovery/scanning operations
- **monkey** - Playful monkey animation
- **jump** - Jumping animation, good for linking/connecting operations
- **pulse** - Pulsing animation, good for reload operations
- **points** - Growing points animation
- **meter** - Progress meter style, good for system upgrades
- **hamburger** - Hamburger menu style

## Usage in Helper Functions

### `step(description, command)`
Uses the **dot** spinner by default. Perfect for most operations.

```fish
step "Installing package" "sudo dnf install -y package"
```

### `run_quiet(description, command)`
Uses the **dot** spinner and shows error output on failure.

```fish
run_quiet "Building project" "make build"
```

## Custom Spinner Examples

For specialized operations in theme scripts:

```fish
# Discovering/scanning operations
gum spin --spinner moon --title "Discovering themes..." -- fish -c 'some command'

# Linking operations
gum spin --spinner jump --title "Linking configs..." -- fish -c 'some command'

# Network/download operations
gum spin --spinner line --title "Downloading..." -- fish -c 'some command'

# Reload operations
gum spin --spinner pulse --title "Reloading service..." -- fish -c 'some command'
```

## Best Practices

1. **Use helper functions first** - Use `step()` or `run_quiet()` for most operations
2. **Match the spinner to the operation** - Use thematic spinners for better UX
3. **Keep titles concise** - Title should be action + gerund ("Installing...", "Configuring...")
4. **Always provide feedback** - Follow spinners with `success()`, `error()`, or `warning()`

## Example: Theme Setup Flow

```fish
step "Creating directories" "mkdir -p ~/.config/themes"
gum spin --spinner moon --title "Discovering themes..." -- fish -c 'scan_themes'
success "Found 15 themes"

gum spin --spinner jump --title "Linking themes..." -- fish -c 'link_themes'
success "Themes linked"

gum spin --spinner pulse --title "Reloading UI..." -- fish -c 'reload_ui'
success "UI reloaded"
```

This creates a delightful visual experience that matches the operation being performed!
