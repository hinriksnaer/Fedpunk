# Desktop Experience Roadmap

**Goal:** Full desktop environment deployable on fresh Fedora install

**Current Status:** Infrastructure complete, 2/15 modules created

---

## Phase 1: Foundation Complete ✅

**Status:** DONE (PRs #12, #13, #14)

- [x] Module system with dependency resolution
- [x] YAML configuration
- [x] Essential modules (rust, fish, system-config, dev-tools, cli-tools, languages)
- [x] Bootstrap script (boot.sh)

---

## Phase 2: Terminal Environment (Priority 1)

**Goal:** Working terminal development environment

### Modules to Create

1. **neovim** (Priority: P0)
   - Dependencies: rust, dev-tools
   - Packages: neovim, tree-sitter
   - Config: LSP setup, plugins
   - Estimate: 2-3 hours

2. **tmux** (Priority: P0)
   - Dependencies: none
   - Packages: tmux
   - Config: keybindings, plugins (TPM)
   - Estimate: 1 hour

3. **lazygit** (Priority: P1)
   - Dependencies: rust
   - Packages: lazygit (via cargo fallback)
   - Config: keybindings, theme
   - Estimate: 30 min

4. **yazi** (Priority: P1)
   - Dependencies: rust
   - Packages: yazi (via cargo)
   - Config: file manager settings
   - Estimate: 30 min

5. **btop** (Priority: P1)
   - Dependencies: none
   - Packages: btop
   - Config: theme
   - Estimate: 20 min

6. **gh** (Priority: P1)
   - Dependencies: none
   - Packages: gh (GitHub CLI)
   - Config: auth, aliases
   - Estimate: 20 min

7. **claude** (Priority: P2)
   - Dependencies: none
   - Packages: Install Claude Code
   - Config: extensions, settings
   - Estimate: 30 min

**Phase 2 Test:**
```bash
# Container mode test
FEDPUNK_REF=<branch> curl -fsSL boot.sh | bash
# Select: dev/container
# Expected: Full terminal environment
```

**Estimated Time:** 5-7 hours

---

## Phase 3: Desktop Foundation (Priority 2)

**Goal:** Base desktop environment (no GUI apps)

### Modules to Create

1. **fonts** (Priority: P0)
   - Dependencies: none
   - Packages: Nerd Fonts, system fonts
   - Config: fontconfig
   - Estimate: 1 hour

2. **kitty** (Priority: P0)
   - Dependencies: fonts
   - Packages: kitty
   - Config: kitty.conf, theme
   - Estimate: 1 hour

3. **hyprland** (Priority: P0)
   - Dependencies: fonts, kitty
   - Packages: hyprland, hyprpaper, hypridle, hyprlock
   - Config: hyprland.conf, autostart
   - Estimate: 3-4 hours (complex)

4. **rofi** (Priority: P1)
   - Dependencies: fonts
   - Packages: rofi
   - Config: theme, launchers
   - Estimate: 1 hour

**Phase 3 Test:**
```bash
# Desktop mode test (no GUI apps yet)
FEDPUNK_REF=<branch> curl -fsSL boot.sh | bash
# Select: dev/desktop
# Expected: Hyprland boots, kitty works, rofi launches
```

**Estimated Time:** 6-8 hours

---

## Phase 4: Desktop Applications (Priority 3)

**Goal:** Complete desktop experience with GUI apps

### Modules to Create

1. **audio** (Priority: P0)
   - Dependencies: none
   - Packages: pipewire, wireplumber, pavucontrol
   - Config: audio routing
   - Estimate: 1-2 hours

2. **firefox** (Priority: P1)
   - Dependencies: none
   - Packages: firefox
   - Config: user.js, extensions
   - Estimate: 1 hour

**Phase 4 Test:**
```bash
# Full desktop test
FEDPUNK_REF=<branch> curl -fsSL boot.sh | bash
# Select: dev/desktop
# Expected: Complete desktop with Firefox, audio working
```

**Estimated Time:** 2-3 hours

---

## Phase 5: Integration Testing

**Goal:** Validate entire system on fresh install

### Testing Checklist

- [ ] Fresh Fedora 40+ VM
- [ ] Run boot.sh (desktop mode)
- [ ] Verify all modules deploy
- [ ] Hyprland boots
- [ ] Terminal apps work (nvim, tmux, lazygit)
- [ ] GUI apps work (firefox, kitty)
- [ ] Audio works
- [ ] No errors in logs

**Test Environments:**
1. VM (VirtualBox/QEMU)
2. Bare metal (if available)
3. Container (for container mode)

**Estimated Time:** 2-4 hours

---

## Phase 6: Polish & Documentation

**Goal:** Production-ready desktop

### Tasks

- [ ] Clean up old install/ scripts
- [ ] Update documentation
- [ ] Create troubleshooting guide
- [ ] Add screenshots/demo
- [ ] Write migration guide (from old system)
- [ ] Performance optimization

**Estimated Time:** 3-5 hours

---

## Total Timeline

| Phase | Modules | Time | Status |
|-------|---------|------|--------|
| 1. Foundation | 5 | 20h | ✅ DONE |
| 2. Terminal | 7 | 5-7h | 🔴 TODO |
| 3. Desktop Base | 4 | 6-8h | 🔴 TODO |
| 4. GUI Apps | 2 | 2-3h | 🔴 TODO |
| 5. Testing | - | 2-4h | 🔴 TODO |
| 6. Polish | - | 3-5h | 🔴 TODO |
| **TOTAL** | **18** | **38-47h** | **6% DONE** |

---

## Dependency Graph

```
Essential (meta)
  ├── rust
  ├── fish → rust
  ├── system-config
  ├── dev-tools → system-config
  └── cli-tools → rust

Terminal Apps
  ├── neovim → rust, dev-tools
  ├── tmux
  ├── lazygit → rust
  ├── yazi → rust
  ├── btop
  ├── gh
  └── claude

Desktop Foundation
  ├── fonts
  ├── kitty → fonts
  ├── hyprland → fonts, kitty
  └── rofi → fonts

Desktop Apps
  ├── audio
  └── firefox

languages (optional)
```

---

## Module Creation Template

For each module:

```yaml
module:
  name: <name>
  description: <description>
  dependencies: []
  priority: <1-20>

lifecycle:
  before:
    - install    # If needed
  after:
    - configure  # If needed

packages:
  dnf: []
  cargo: []

stow:
  target: $HOME
  conflicts: warn
```

**Steps:**
1. Create `modules/<name>/module.yaml`
2. Create `modules/<name>/scripts/` (if lifecycle needed)
3. Create `modules/<name>/config/` (dotfiles)
4. Test: `fedpunk module deploy <name>`
5. Add to profile mode TOML

---

## Next Session Plan

**Immediate tasks:**
1. Merge PR #14 (YAML migration)
2. Merge PR #13 (Essential modules) - convert to YAML
3. Start Phase 2: Create neovim module
4. Create tmux module
5. Test container mode with neovim + tmux

**Session goal:** Working terminal environment

---

## Critical Path

**Must complete in order:**
1. Phase 1 ✅ (Done)
2. Phase 2 → Container mode works
3. Phase 3 → Desktop boots
4. Phase 4 → Desktop complete
5. Phase 5 → Tested on fresh install

**Blockers:**
- None currently
- Phase 3 depends on Phase 2 (terminal tools needed first)
- Phase 4 depends on Phase 3 (desktop must boot)

---

## Success Criteria

**Phase 2 Success:**
- [ ] Container mode installs cleanly
- [ ] Neovim works with LSP
- [ ] Tmux sessions functional
- [ ] All CLI tools accessible

**Phase 3 Success:**
- [ ] Hyprland boots from GDM/SDDM
- [ ] Kitty terminal opens
- [ ] Rofi launcher works
- [ ] Keybindings functional

**Phase 4 Success:**
- [ ] Firefox browses web
- [ ] Audio plays
- [ ] All desktop features working

**Phase 5 Success:**
- [ ] Fresh install completes
- [ ] No manual intervention needed
- [ ] All features work out of box

---

## Risk Assessment

**High Risk:**
- Hyprland configuration (complex, many dependencies)
- Audio setup (pipewire/wireplumber can be finicky)

**Medium Risk:**
- Neovim LSP setup (needs careful configuration)
- Font rendering (fontconfig complexity)

**Low Risk:**
- Simple CLI tools (tmux, btop, gh)
- Firefox (minimal config needed)

**Mitigation:**
- Test each module independently before integration
- Use existing install/ scripts as reference
- Fail-fast with clear error messages

---

## Notes

- Keep modules simple initially
- Can add advanced features later
- Prioritize working system over perfect config
- Document assumptions and requirements
- Test on VM before bare metal
