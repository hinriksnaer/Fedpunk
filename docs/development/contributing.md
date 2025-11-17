# Contributing to Fedpunk

Thank you for your interest in contributing to Fedpunk! This guide will help you get started.

---

## 🎯 Ways to Contribute

### 🎨 Create Themes
Share your beautiful color schemes with the community!

### 🐛 Report Bugs
Found an issue? Let us know!

### 📝 Improve Documentation
Help others by improving guides and references.

### ✨ Add Features
Implement new functionality or improve existing features.

### 🧪 Test
Test on different hardware and configurations.

---

## 🚀 Getting Started

### Prerequisites
- Fedora Linux 39+
- Git
- Basic knowledge of Fish shell
- For desktop features: Understanding of Hyprland/Wayland

### Development Setup
```bash
# Fork and clone the repository
git clone https://github.com/YOUR-USERNAME/Fedpunk.git ~/.local/share/fedpunk-dev
cd ~/.local/share/fedpunk-dev

# Install Fedpunk (development mode)
fish install.fish

# Create a branch for your changes
git checkout -b feature/my-awesome-feature
```

---

## 🎨 Contributing Themes

Themes are the easiest way to contribute!

### Creating a Theme

1. **Copy an existing theme:**
```bash
cd ~/.local/share/fedpunk/themes
cp -r nord my-theme-name
```

2. **Edit the theme files:**
```bash
cd my-theme-name
vim kitty.conf        # Terminal colors (omarchy format)
vim hyprland.conf     # Hyprland colors
vim rofi.rasi         # Launcher styling
vim btop.theme        # System monitor
vim mako.ini          # Notifications
vim neovim.lua        # Editor colorscheme
vim waybar.css        # Status bar
```

3. **Add wallpapers:**
```bash
mkdir -p backgrounds
cp your-wallpaper.jpg backgrounds/
```

4. **Test your theme:**
```bash
fedpunk-theme-set my-theme-name
# Check all applications for consistent colors
```

5. **Take a screenshot:**
```bash
# Take a screenshot showing your theme
# Save as preview.png in the theme directory
```

6. **Submit a pull request!**

### Theme Guidelines
- Follow omarchy format for `kitty.conf`
- Provide at least one wallpaper
- Include a `preview.png` screenshot
- Test in both light and dark environments
- Ensure good contrast and readability

---

## 🐛 Reporting Bugs

### Before Reporting
1. Check existing issues
2. Verify it's reproducible
3. Test on latest version
4. Check installation logs

### Creating a Bug Report

Include:
- **Description:** Clear description of the issue
- **Steps to reproduce:** Numbered steps
- **Expected behavior:** What should happen
- **Actual behavior:** What actually happens
- **System info:**
  - Fedora version
  - Kernel version
  - GPU (NVIDIA/AMD/Intel)
  - Desktop/Terminal-only mode
- **Logs:**
  - Installation log: `/tmp/fedpunk-install-*.log`
  - Hyprland log (if desktop): `~/.local/share/hyprland/hyprland.log`
  - Error messages

**Template:**
```markdown
## Bug Description
Clear description here

## Steps to Reproduce
1. First step
2. Second step
3. Issue occurs

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## System Information
- Fedora version:
- Kernel:
- GPU:
- Mode: Desktop/Terminal-only

## Logs
```
Paste relevant logs here
```
```

---

## 💻 Code Contributions

### Code Style

**Fish Scripts:**
- Use 4 spaces for indentation
- Use descriptive variable names
- Add comments for complex logic
- Follow existing naming patterns

**Example:**
```fish
#!/usr/bin/env fish
# Description of what this script does

function my_function
    set theme_name $argv[1]

    # Check if theme exists
    if not test -d "$themes_dir/$theme_name"
        echo "Error: Theme not found" >&2
        return 1
    end

    # Apply theme
    apply_theme "$theme_name"
end
```

**Bash Scripts:**
- Use for bootstrap scripts only
- Follow existing style
- Use shellcheck for linting

**Configuration Files:**
- Follow application-specific syntax
- Keep organized and commented
- Match existing formatting

### Commit Messages

Use conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Testing changes
- `chore`: Maintenance tasks

**Examples:**
```
feat(themes): add cyberpunk theme

Added new cyberpunk theme with neon colors and futuristic wallpapers.

Closes #123

fix(install): handle missing cargo gracefully

The installer now checks for cargo and installs it if missing,
preventing installation failures.

Fixes #456

docs(readme): update installation instructions

Clarified the difference between desktop and terminal-only installations.
```

### Pull Request Process

1. **Create an issue first** (for features)
2. **Fork the repository**
3. **Create a feature branch**
4. **Make your changes**
5. **Test thoroughly**
6. **Write/update documentation**
7. **Commit with clear messages**
8. **Push to your fork**
9. **Create pull request**

**PR Template:**
```markdown
## Description
What does this PR do?

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Theme contribution
- [ ] Refactoring

## Testing
How was this tested?

## Checklist
- [ ] Code follows project style
- [ ] Documentation updated
- [ ] Tested on Fedora 39+
- [ ] No breaking changes (or documented)
- [ ] Screenshots included (if UI changes)
```

---

## 📝 Documentation Contributions

### Documentation Structure
```
docs/
├── guides/          ← User guides
├── reference/       ← Technical reference
└── development/     ← Developer docs
```

### Writing Guidelines
- Use clear, concise language
- Include code examples
- Add screenshots where helpful
- Link to related documentation
- Test all commands/examples

### Documentation Format
- Use Markdown
- Follow existing structure
- Include table of contents for long docs
- Use proper headings hierarchy

---

## 🧪 Testing

### Manual Testing Checklist

**Desktop Installation:**
- [ ] Fresh install completes
- [ ] Hyprland starts correctly
- [ ] All keybindings work
- [ ] Theme switching works
- [ ] All applications themed correctly

**Terminal Installation:**
- [ ] Terminal-only install completes
- [ ] Fish shell works
- [ ] Neovim works with plugins
- [ ] Tmux works
- [ ] Theme switching works (terminal colors)

**Theme Testing:**
- [ ] All applications use theme colors
- [ ] Wallpaper displays correctly
- [ ] Good contrast/readability
- [ ] Works in light/dark mode

### Testing in Devcontainer
```bash
# Use the provided devcontainer
# Open in VS Code with Dev Containers extension
# Container automatically runs terminal-only install
```

---

## 🔧 Development Tips

### Useful Commands
```bash
# Check Fish syntax
fish -n script.fish

# Check Bash syntax
bash -n script.sh
shellcheck script.sh

# Test Hyprland config
hyprctl reload

# View Fish functions
functions | grep fedpunk

# Debug Fish script
fish --debug script.fish
```

### Development Workflow
1. Make changes
2. Test locally
3. Check logs for errors
4. Verify no regressions
5. Update documentation
6. Commit and push

### Common Development Tasks

**Adding a new script:**
1. Create in `bin/`
2. Make executable: `chmod +x bin/new-script`
3. Use Fish shebang: `#!/usr/bin/env fish`
4. Document in `docs/reference/scripts.md`

**Modifying installation:**
1. Edit scripts in `install/`
2. Test with: `fish install.fish --terminal-only`
3. Check logs: `/tmp/fedpunk-install-*.log`
4. Document changes

**Adding configuration:**
1. Add to appropriate `config/` subdirectory
2. Update deployment in `install/`
3. Document in `docs/reference/configuration.md`

---

## 🎓 Learning Resources

### Hyprland
- [Hyprland Wiki](https://wiki.hyprland.org)
- [Hyprland GitHub](https://github.com/hyprwlr/Hyprland)

### Fish Shell
- [Fish Tutorial](https://fishshell.com/docs/current/tutorial.html)
- [Fish Documentation](https://fishshell.com/docs/current/)

### Wayland
- [Wayland Documentation](https://wayland.freedesktop.org/)

### Omarchy (Theme Format)
- [Omarchy Themes](https://github.com/edunfelt/omarchy)

---

## 📋 Contribution Checklist

Before submitting:

- [ ] Code follows project style
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] PR description is complete
- [ ] Screenshots included (if applicable)
- [ ] No breaking changes (or documented)
- [ ] Tested on Fedora 39+
- [ ] Installation logs checked
- [ ] Theme preview included (for themes)

---

## 🤝 Community Guidelines

### Be Respectful
- Treat everyone with respect
- Be constructive in feedback
- Help others learn

### Communication
- Use clear, professional language
- Provide context and details
- Be patient with responses

### Quality Over Quantity
- Focus on quality contributions
- Test thoroughly before submitting
- One feature per PR

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

## ❓ Questions?

- Open an issue for questions
- Check existing issues first
- Provide context in your questions

---

**Thank you for contributing to Fedpunk! 🎉**

Your contributions help make Fedpunk better for everyone.
