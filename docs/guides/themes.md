# Fedpunk Themes

**Omarchy-compatible theme system** for the entire Fedpunk desktop environment. Fully compatible with all omarchy themes!

Themes are swapped across all applications simultaneously using the excellent omarchy theme framework as a base.

## Quick Start

### Switch Themes

- **Super+Shift+T** - Cycle to next theme
- **Super+Shift+Y** - Cycle to previous theme
- **Super+Shift+R** - Refresh current theme
- **Super+Shift+W** - Cycle through wallpapers
- `fedpunk-theme-list` - List all available themes
- `fedpunk-theme-set <theme-name>` - Switch to specific theme

### Supported Applications

Each theme can customize:
- **Hyprland** - Window manager colors and decorations
- **Kitty** - Terminal colors (omarchy standard)
- **Walker** - Application launcher
- **btop** - System monitor
- **swaybg** - Wallpaper management

## Available Themes

Fedpunk comes with all 12 omarchy themes pre-installed, plus our custom themes:

### Omarchy Themes (Included)
All themes from the [omarchy](https://github.com/swaystudio/omarchy) project work out of the box!

### Custom Themes
- **default** - Original Fedpunk theme (coral/orange accents)
- **osaka-jade** - Custom jade/teal theme

**Note:** Any omarchy theme repository can be copied directly into `~/Fedpunk/themes/` and will work immediately!

## Adding New Themes

**Important**: Omarchy themes work out of the box! Fedpunk is fully compatible with the omarchy theme system.

### Method 1: Use Omarchy Themes (Recommended)

All omarchy themes are already included, but you can also copy additional ones:

```bash
cd ~/Fedpunk/themes
# Copy from an omarchy installation
cp -r ~/gits/omarchy/themes/* .

# Or download individual omarchy themes
git clone https://github.com/user/omarchy-theme-name my-theme
cd my-theme
rm -rf .git  # Remove git history
```

**No modifications needed!** Omarchy themes include:
- `hyprland.conf` - Hyprland colors
- `kitty.conf` - Kitty terminal colors
- `rofi.rasi` - Rofi launcher
- `btop.theme` - btop monitor
- `backgrounds/` - Theme wallpapers

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
- `kitty.conf` - Kitty terminal colors (omarchy standard)
- `rofi.rasi` - Launcher colors
- `btop.theme` - btop system monitor colors
- `backgrounds/` - Theme wallpapers

### Method 3: Adapt External Themes

If a theme uses different file names or formats:

```bash
cd ~/Fedpunk/themes
mkdir tokyo-night
cd tokyo-night

# Download the original theme files
wget https://raw.githubusercontent.com/user/theme/main/colors.conf -O hyprland.conf
wget https://raw.githubusercontent.com/user/theme/main/kitty.conf -O kitty.conf
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

### Kitty Terminal (kitty.conf)

Omarchy uses kitty as the standard terminal.

```conf
foreground #cccac2
background #1f2430
color0 #171b24  # black
color1 #ed8274  # red
# ... etc
```

### Walker (rofi.rasi)

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

1. Theme files live in `~/Fedpunk/themes/<theme-name>/` (same as omarchy)
2. Application configs import from symlinked "active" theme files:
   - `~/.config/hypr/hyprland.conf` sources `~/Fedpunk/themes/<theme-name>/hyprland.conf`
   - `~/.config/kitty/theme.conf` → `~/Fedpunk/themes/<theme-name>/kitty.conf`
   - `~/.config/walker/theme.css` → `~/Fedpunk/themes/<theme-name>/rofi.rasi`
   - `~/.config/btop/themes/active.theme` → `~/Fedpunk/themes/<theme-name>/btop.theme`
   - `~/.config/hypr/wallpapers/current` → `~/Fedpunk/themes/<theme-name>/backgrounds/<wallpaper>`
3. Theme switcher updates all symlinks at once
4. Hyprland reloads automatically; btop live reloads; kitty requires restart

## Examples

### Example 1: Download Complete Theme Repo

```bash
cd ~/Fedpunk/themes
wget https://github.com/user/cool-theme/archive/main.zip
unzip main.zip
mv cool-theme-main cool-theme
rm main.zip

# Switch to it
fedpunk-theme-set cool-theme
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
fedpunk-theme-set rose-pine
```

### Example 3: Mix and Match

```bash
cd ~/Fedpunk/themes
mkdir custom
# Take Hyprland colors from one theme
cp ayu-mirage/hyprland.conf profiles/dev/
# Take terminal colors from another
cp default/kitty.conf profiles/dev/
# Create custom walker theme
nano profiles/dev/rofi.rasi
```

## Tips

- **Omarchy compatible**: All omarchy themes work directly, no modifications needed
- **Test incrementally**: Add one config file at a time
- **Not all files required**: Theme works with any combination of files
- **Colors must match format**: Use color format native to each app
- **Kitty needs restart**: Terminal picks up theme changes on restart
- **btop live reload**: Monitor reloads automatically via SIGUSR2
- **Hyprland instant**: Window manager changes apply immediately
- **Wallpapers**: Use swaybg (like omarchy) for instant wallpaper switching

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
fedpunk-theme-set default
```

## Omarchy Compatibility

Fedpunk is built on the omarchy theming framework, which means:

- **100% compatible** with all omarchy themes
- **Same directory structure** (`~/Fedpunk/themes/` instead of `~/.local/share/omarchy/themes/`)
- **Same file formats** (hyprland.conf, kitty.conf, rofi.rasi, btop.theme, etc.)
- **Same tools** (swaybg for wallpapers)
- **Fully interchangeable** - copy themes between omarchy and Fedpunk installations

### Why Omarchy-Based?

Omarchy provides an excellent, well-designed theming system that:
- Works across multiple applications seamlessly
- Uses standard configuration file formats
- Includes comprehensive theme collections
- Supports wallpaper management per theme
- Has an active community creating themes

Fedpunk extends this with:
- Fish-based theme management scripts
- Fedora-optimized installation
- Additional development tools integration
- Master layout support for ultrawides

### Using Themes from Omarchy Installations

If you have omarchy installed, simply copy themes:

```bash
# Copy all omarchy themes to Fedpunk
cp -r ~/gits/omarchy/themes/* ~/Fedpunk/themes/

# Or copy from omarchy's default location
cp -r ~/.local/share/omarchy/themes/* ~/Fedpunk/themes/
```

All themes work immediately with no modifications!
