# Keybindings Reference

Complete keyboard shortcut reference for Fedpunk/Hyprland.

**Note:** `Super` key is typically the Windows/Command key.

---

## 🚀 Applications

| Keybinding | Action |
|------------|--------|
| `Super+Return` | Open terminal (Kitty) |
| `Super+Shift+Return` | Toggle emergency terminal workspace |
| `Super+Space` | Application launcher (Rofi) |
| `Super+B` | Open browser (Firefox) |
| `Super+E` | Open file manager (Yazi) |
| `Super+Shift+B` | Open Bluetooth manager (bluetui) |

---

## 🪟 Window Management

| Keybinding | Action |
|------------|--------|
| `Super+Q` | Close active window |
| `Super+Shift+E` | Exit Hyprland |
| `Super+V` | Toggle floating mode |
| `Super+F` | Toggle fullscreen |
| `Super+P` | Pseudo tile |
| `Super+Alt+R` | Toggle split direction (rotate) |
| `Super+Alt+Space` | Toggle layout (dwindle ↔ master) |

---

## 🧭 Window Focus (Navigation)

### Arrow Keys
| Keybinding | Action |
|------------|--------|
| `Super+Left` | Focus window to the left |
| `Super+Right` | Focus window to the right |
| `Super+Up` | Focus window above |
| `Super+Down` | Focus window below |

### Vim-Style (H/J/K/L)
| Keybinding | Action |
|------------|--------|
| `Super+H` | Focus window to the left |
| `Super+J` | Focus window below |
| `Super+K` | Focus window above |
| `Super+L` | Focus window to the right |

---

## 🔀 Window Movement

### Arrow Keys
| Keybinding | Action |
|------------|--------|
| `Super+Alt+Left` | Move window left |
| `Super+Alt+Right` | Move window right |
| `Super+Alt+Up` | Move window up |
| `Super+Alt+Down` | Move window down |

### Vim-Style (H/J/K/L)
| Keybinding | Action |
|------------|--------|
| `Super+Alt+H` | Move window left |
| `Super+Alt+J` | Move window down |
| `Super+Alt+K` | Move window up |
| `Super+Alt+L` | Move window right |

---

## 📏 Window Resizing

### Arrow Keys
| Keybinding | Action |
|------------|--------|
| `Super+Ctrl+Left` | Resize window left |
| `Super+Ctrl+Right` | Resize window right |
| `Super+Ctrl+Up` | Resize window up |
| `Super+Ctrl+Down` | Resize window down |

### Vim-Style (H/J/K/L)
| Keybinding | Action |
|------------|--------|
| `Super+Ctrl+H` | Resize window left |
| `Super+Ctrl+J` | Resize window down |
| `Super+Ctrl+K` | Resize window up |
| `Super+Ctrl+L` | Resize window right |

---

## 🏢 Workspaces

### Switching Workspaces
| Keybinding | Action |
|------------|--------|
| `Super+1` through `Super+9` | Switch to workspace 1-9 |
| `Super+0` | Switch to workspace 10 |
| `Super+Tab` | Toggle to last workspace |
| `Super+Shift+H` | Previous workspace |
| `Super+Shift+L` | Next workspace |

### Moving Windows to Workspaces
| Keybinding | Action |
|------------|--------|
| `Super+Shift+1` through `Super+Shift+9` | Move window to workspace 1-9 |
| `Super+Shift+0` | Move window to workspace 10 |

### Silent Window Movement
| Keybinding | Action |
|------------|--------|
| `Super+Ctrl+1` through `Super+Ctrl+9` | Move window silently to workspace 1-9 |
| `Super+Ctrl+0` | Move window silently to workspace 10 |

**Note:** "Silent" means move window without switching to that workspace.

---

## 🎨 Themes & Wallpapers

| Keybinding | Action |
|------------|--------|
| `Super+T` | Open theme selector (Rofi) |
| `Super+Shift+T` | Next theme |
| `Super+Shift+Y` | Previous theme |
| `Super+Shift+R` | Refresh current theme |
| `Super+W` | Open wallpaper selector |
| `Super+Shift+W` | Next wallpaper |

---

## 📸 Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot selection |
| `Super+Print` | Screenshot full screen |

---

## 🐛 Debug & Diagnostics

| Keybinding | Action |
|------------|--------|
| `Super+Shift+D` | Run startup diagnostics |

---

## 🖱️ Mouse Bindings

| Action | Result |
|--------|--------|
| `Super+Left Mouse Drag` | Move window |
| `Super+Right Mouse Drag` | Resize window |

---

## 🎯 Custom Keybindings

To add your own keybindings, edit `profile/dev/keybinds.conf`:

```conf
# Example custom keybindings
bind = Super, M, exec, spotify
bind = Super, C, exec, code
bind = Super+Shift, F, exec, firefox --private-window
```

Then reload Hyprland:
```bash
hyprctl reload
```

---

## 📚 Keybinding Syntax

Hyprland keybindings use this format:
```conf
bind = MODIFIERS, KEY, ACTION, PARAMS
```

### Common Modifiers
- `Super` - Windows/Command key
- `Alt` - Alt key
- `Shift` - Shift key
- `Ctrl` - Control key
- Combine with `+`: `Super+Shift`, `Super+Alt+Ctrl`

### Common Actions
- `exec` - Execute a command
- `killactive` - Close active window
- `workspace` - Switch workspace
- `movetoworkspace` - Move window to workspace
- `togglefloating` - Toggle floating mode
- `fullscreen` - Toggle fullscreen

### Examples
```conf
# Open terminal
bind = Super, Return, exec, kitty

# Close window
bind = Super, Q, killactive

# Switch to workspace 5
bind = Super, 5, workspace, 5

# Move window to workspace 3
bind = Super+Shift, 3, movetoworkspace, 3
```

---

## 🔍 Tips

### Learning the Keybindings
1. **Start with basics** - Window focus (Super+H/J/K/L) and workspaces (Super+1-9)
2. **Print this page** - Keep it handy while learning
3. **Practice daily** - Muscle memory develops quickly
4. **Customize** - Add shortcuts for apps you use frequently

### Common Workflows

**Tiling Windows:**
```
1. Super+Return (open terminal)
2. Super+Return (open another terminal)
3. Windows automatically tile
4. Super+H/L to switch between them
```

**Moving to Different Workspace:**
```
1. Super+Shift+5 (move current window to workspace 5)
2. Super+5 (switch to workspace 5)
```

**Organizing Workspaces:**
- Workspace 1: Browser
- Workspace 2: Code editor
- Workspace 3: Terminal
- Workspace 4: Communication (Slack, Discord)
- Workspace 5+: Project-specific

**Quick Theme Change:**
```
1. Super+Shift+T (cycle to next theme)
2. Or Super+T (open selector to choose specific theme)
```

---

## 📖 Related Documentation

- [Customization Guide](../guides/customization.md) - Adding custom keybindings
- [Configuration Reference](configuration.md) - Config file locations
- [Hyprland Documentation](https://wiki.hyprland.org) - Official Hyprland docs

---

**Master these keybindings and you'll fly through your workflow! 🚀**
