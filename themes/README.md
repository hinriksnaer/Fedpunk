# Fedpunk Themes

Complete theme packages for the entire Fedpunk desktop environment. Themes are swapped across all applications simultaneously.

## Quick Start

### Switch Themes

- **Super+Shift+T** - Cycle through all installed themes
- `fish ~/.config/hypr/scripts/switch-theme.fish` - Cycle themes from terminal
- `fish ~/.config/hypr/scripts/switch-theme.fish <theme-name>` - Switch to specific theme

### Supported Applications

Each theme can customize:
- **Hyprland** - Window manager colors
- **Foot** - Terminal colors
- **Walker** - Application launcher
- **btop** - System monitor
- **Waybar** - Status bar (if installed)
- **Neovim** - Editor theme (if installed)
- **Mako** - Notifications (if installed)

## Available Themes

- **default** - Original Fedpunk theme (coral/orange accents)
- **omarchy-ayu-mirage-theme** - Warm, pastel Ayu Mirage colors (unmodified from [GitHub](https://github.com/fdidron/omarchy-ayu-mirage-theme))

## Adding New Themes

**Important**: Theme repos are NEVER modified! Fedpunk uses adapter files (`.fedpunk-*.conf`) to bridge between theme formats when needed.

### Method 1: Clone External Theme Repos (Recommended)

Perfect for themes like omarchy - just download and go!

```bash
cd ~/Fedpunk/themes
# Download all files from theme repo
git clone https://github.com/user/some-theme my-theme
cd my-theme
# Keep only the config files, remove git history
rm -rf .git
```

**No modifications needed!** As long as the theme repo has these files:
- `hyprland.conf`
- `foot.ini` or `alacritty.toml`
- `walker.css`
- `btop.theme`

The theme switcher will apply what exists and skip what doesn't.

### Method 2: Create Your Own Theme

```bash
cd ~/Fedpunk/themes
mkdir my-theme
cd my-theme
```

Create these files (copy from another theme as a starting point):

**Required files:**
- `hyprland.conf` - Window manager colors

**Optional files:**
- `foot.ini` - Terminal colors
- `walker.css` - Launcher colors
- `btop.theme` - System monitor colors
- `waybar.css` - Status bar
- `neovim.lua` - Editor theme
- `mako.ini` - Notification colors

### Method 3: Adapt External Themes

If a theme uses different file names or formats:

```bash
cd ~/Fedpunk/themes
mkdir tokyo-night
cd tokyo-night

# Download the original theme files
wget https://raw.githubusercontent.com/user/theme/main/colors.conf -O hyprland.conf
wget https://raw.githubusercontent.com/user/theme/main/terminal.toml -O foot.ini
# ... etc
```

## Theme File Formats

### Hyprland (hyprland.conf)

Must define these color variables:
```conf
$accent_color = rgb(f28779)
$inactive_color = rgba(707a8c80)
$background = rgb(1f2430)
$foreground = rgb(cccac2)
```

### Foot Terminal (foot.ini)

```ini
[colors]
foreground=cccac2
background=1f2430
regular0=171b24  # black
regular1=ed8274  # red
# ... etc
```

### Walker (walker.css)

```css
@define-color selected-text #73d0ff;
@define-color text #cccac2;
@define-color base #1f2430;
@define-color border #f28779;
```

### btop (btop.theme)

```ini
theme[main_bg]="#1f2430"
theme[main_fg]="#cccac2"
theme[title]="#ffd173"
# ... etc
```

## How It Works

1. Theme files live in `~/Fedpunk/themes/<theme-name>/`
2. Application configs import from symlinked "active" theme files:
   - `~/.config/hypr/active-theme.conf` → `~/Fedpunk/themes/<theme-name>/hyprland.conf`
   - `~/.config/foot/theme.ini` → `~/Fedpunk/themes/<theme-name>/foot.ini`
   - `~/.config/walker/theme.css` → `~/Fedpunk/themes/<theme-name>/walker.css`
   - `~/.config/btop/themes/active.theme` → `~/Fedpunk/themes/<theme-name>/btop.theme`
3. Theme switcher updates all symlinks at once
4. Hyprland reloads automatically; other apps update on next launch

## Examples

### Example 1: Download Complete Theme Repo

```bash
cd ~/Fedpunk/themes
wget https://github.com/user/cool-theme/archive/main.zip
unzip main.zip
mv cool-theme-main cool-theme
rm main.zip

# Switch to it
fish ~/.config/hypr/scripts/switch-theme.fish cool-theme
```

### Example 2: Create Minimal Theme (Hyprland Only)

```bash
cd ~/Fedpunk/themes
mkdir rose-pine
cat > rose-pine/hyprland.conf <<EOF
$accent_color = rgb(ebbcba)
$inactive_color = rgba(6e617580)
$background = rgb(191724)
$foreground = rgb(e0def4)
EOF

# Switch to it
fish ~/.config/hypr/scripts/switch-theme.fish rose-pine
```

### Example 3: Mix and Match

```bash
cd ~/Fedpunk/themes
mkdir custom
# Take Hyprland colors from one theme
cp ayu-mirage/hyprland.conf custom/
# Take terminal colors from another
cp default/foot.ini custom/
# Create custom walker theme
nano custom/walker.css
```

## Tips

- **Test incrementally**: Add one config file at a time
- **Not all files required**: Theme works with any combination of files
- **Colors must match format**: Use color format native to each app
- **Terminal needs restart**: Foot picks up theme changes on new window
- **Hyprland instant**: Window manager changes apply immediately

## Troubleshooting

**Theme not showing in list?**
- Make sure it's a directory in `~/Fedpunk/themes/`
- Directory name becomes theme name

**Some apps not themed?**
- Theme might not include config for that app
- Switcher skips missing files (check output)

**Colors look wrong?**
- Check color format matches app requirements
- Verify symlinks: `ls -la ~/.config/*/theme*`

**Reset to default?**
```bash
fish ~/.config/hypr/scripts/switch-theme.fish default
```

## Adapter System (Advanced)

Fedpunk can use external theme repos without modification through adapter files. This allows themes designed for other systems (like Omarchy) to work seamlessly.

### How Adapters Work

When you switch themes, Fedpunk looks for files in this order:

1. **Adapter file** (e.g., `.fedpunk-adapter.conf` for Hyprland)
2. **Native file** (e.g., `hyprland.conf`)

If an adapter exists, it's used. Otherwise, the native file is used. This means:
- **Omarchy themes** work as-is (adapters bridge the format gap)
- **Native Fedpunk themes** work directly
- **External repos** are NEVER modified

### Creating Adapters

Only needed if a theme uses incompatible formats:

```bash
# Example: Bridging Alacritty → Foot
cd ~/Fedpunk/themes/some-theme
cat > .fedpunk-foot.ini <<EOF
[colors]
foreground=cccac2
background=1f2430
regular0=171b24
# ... convert colors from alacritty.toml
EOF

# Example: Bridging direct config → variables
cat > .fedpunk-adapter.conf <<EOF
$accent_color = rgb(f28779)
$inactive_color = rgba(707a8c80)
# ... extract from theme's native format
EOF
```

Adapters are gitignored and never committed to theme repos.
