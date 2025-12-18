# Fedpunk v1.0-Core Cleanup Plan

**Goal**: Transform Fedpunk into a minimal configuration engine with all user-facing content (profiles, themes, desktop modules) moved to external repositories.

## Current State Analysis

### Code Base
- **Total Fish code**: 4,534 lines across 17 files
- **Functions**: 123 total functions
- **Modules**: 4 (essentials, ssh, claude, bluetui)
- **Profiles**: 4 (default, desktop, dev, example)
- **Themes**: 12 themes (126 MB - mostly wallpapers)

### Usage Analysis
- **TOML parser**: Legacy, only used internally by module-utils (not in module.yaml)
- **installer.fish**: Legacy wrapper, superseded by deployer.fish + CLI commands
- **Profiles**: All will move to external repos
- **Themes**: All will move to profile repos (hyprpunk)

## Phased Cleanup Strategy

### Phase 1: Remove Legacy Code (LOW RISK)
**Goal**: Delete unused/superseded code without affecting current functionality

**Deletions**:
- `lib/fish/installer.fish` (510 lines)
  - Superseded by: `deployer.fish` + CLI commands (`profile.fish`, `module.fish`)
  - Test: `fedpunk profile deploy` and `fedpunk module deploy` still work

- `lib/fish/toml-parser.fish` (185 lines)
  - Only used by module-utils.fish for legacy functions
  - All modules use YAML now (module.yaml)
  - Test: Deploy any module with `fedpunk module deploy`

**Testing**:
```bash
# Test module deployment
fedpunk module deploy essentials

# Test profile deployment
fedpunk profile deploy default --mode container

# Test external module
fedpunk module deploy https://github.com/org/module.git
```

**Estimated reduction**: ~700 lines

---

### Phase 2: Move User-Facing Content to External (MEDIUM RISK)
**Goal**: Relocate all profiles and themes to external repositories, keeping only the engine

#### Phase 2a: Move Dev Profile → hyprpunk
**What moves**:
```
profiles/dev/
├── modes/
│   ├── desktop/
│   └── container/
├── plugins/
│   ├── dev-extras/
│   ├── fancontrol/
│   ├── lvm-expand/
│   ├── neovim-custom/
│   └── vertex-ai/
└── fedpunk.toml
```

**New external repo**: `hinriksnaer/hyprpunk`
- Contains: dev profile + themes + desktop-specific modules
- Usage: `fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop`

**Testing**:
1. Create hyprpunk repo with dev profile
2. Deploy from external URL
3. Verify all plugins load correctly
4. Test desktop mode deployment

#### Phase 2b: Move Default Profile → minimal-profile
**What moves**:
```
profiles/default/
├── modes/
│   ├── desktop/
│   └── container/
└── fedpunk.toml
```

**New external repo**: `hinriksnaer/fedpunk-minimal`
- Minimal reference profile
- Usage: `fedpunk profile deploy https://github.com/hinriksnaer/fedpunk-minimal --mode container`

#### Phase 2c: Delete Remaining Profiles
**Delete**:
- `profiles/desktop/` - Abandoned duplicate
- `profiles/example/` - Will use hyprpunk as example instead

**Testing**:
```bash
# Test external profile deployment
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop
fedpunk profile deploy https://github.com/hinriksnaer/fedpunk-minimal --mode container

# Verify no built-in profiles exist
ls /usr/share/fedpunk/profiles/  # Should be empty

# Check user profiles work
ls ~/.config/fedpunk/profiles/    # Should show cloned profiles
```

**Estimated reduction**: ~1.9 MB (profiles directory)

---

### Phase 3: Move Themes to Hyprpunk (HIGH IMPACT)
**Goal**: Remove 126 MB of themes from core, move to hyprpunk repo

**What moves**:
```
themes/ → hyprpunk/themes/
- 12 theme directories
- Each contains: wallpapers, configs for hyprland/kitty/rofi/etc.
```

**Why external**:
- Themes are desktop-specific (hyprland, kitty, rofi)
- 126 MB is too large for minimal core
- Users deploying container mode don't need themes

**Testing**:
```bash
# Deploy hyprpunk with themes
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop

# Verify theme commands work
fedpunk-theme-list
fedpunk-theme-set tokyo-night

# Verify themes in user space
ls ~/.local/share/fedpunk/profiles/hyprpunk/themes/
```

**Estimated reduction**: 126 MB

---

### Phase 4: Move Desktop Modules to External (MEDIUM RISK)
**Goal**: Keep only universal modules in core (essentials, ssh)

**Modules to externalize**:
- `modules/claude/` → `hinriksnaer/fedpunk-claude`
- `modules/bluetui/` → `hinriksnaer/fedpunk-bluetui`

**Reasoning**:
- Claude: Specific to Vertex AI users, not universal
- Bluetui: Desktop-specific Bluetooth manager

**Modules to keep in core**:
- `essentials` - Universal system tools (fish, starship, ripgrep, etc.)
- `ssh` - Universal SSH configuration

**Testing**:
```bash
# Test core modules
fedpunk module deploy essentials
fedpunk module deploy ssh

# Test external modules
fedpunk module deploy https://github.com/hinriksnaer/fedpunk-claude
fedpunk module deploy https://github.com/hinriksnaer/fedpunk-bluetui

# Verify they work in profiles
# Add to ~/.config/fedpunk/profiles/hyprpunk/modes/desktop/mode.yaml:
modules:
  - essentials
  - ssh
  - https://github.com/hinriksnaer/fedpunk-claude
```

**Estimated reduction**: ~50 KB (small modules)

---

### Phase 5: Consolidate Libraries (LOW RISK)
**Goal**: Merge tightly-coupled libraries to reduce file count

**Consolidations**:

1. **param-injector.fish + param-prompter.fish → parameters.fish**
   - Both handle parameter system
   - Current: 328 + 317 = 645 lines
   - Expected: ~450 lines (remove duplication)
   - Savings: ~195 lines

2. **profile-discovery.fish → deployer.fish**
   - profile-discovery only used by deployer
   - Merge into single file
   - Current: 106 + 345 = 451 lines
   - Expected: ~400 lines
   - Savings: ~51 lines

**Testing**:
```bash
# Test parameter prompting
fedpunk module deploy <module-with-params>
# Should prompt for missing parameters

# Test profile deployment
fedpunk profile deploy https://github.com/user/profile --mode desktop
# Should discover and deploy correctly
```

**Estimated reduction**: ~250 lines

---

### Phase 6: Update Documentation (NO RISK)
**Goal**: Align all documentation with minimal core architecture

**Files to update**:

1. **README.md**
   - Remove references to built-in profiles
   - Update to show external-only approach
   - Update "What's installed" to show only 2 core modules
   - Add section on creating external profiles

2. **CLAUDE.md**
   - Update project overview (minimal core, not desktop environment)
   - Update module list (only essentials, ssh)
   - Remove theme system documentation (move to hyprpunk)
   - Update library documentation (remove installer.fish, add deployer.fish)

3. **docs/MODULE_DEVELOPMENT.md**
   - Comprehensive guide to creating modules
   - Examples of all complexity levels
   - Parameter system documentation
   - External module publishing guide

4. **fedpunk.spec**
   - Update module list (only essentials, ssh)
   - Remove profile installation (external only)
   - Remove theme installation (external only)
   - Update description to reflect minimal core

**Testing**:
- Build RPM and verify it installs correctly
- Deploy external profile and verify docs match reality

---

## Expected Final State

### Core Repository (fedpunk)
```
fedpunk/
├── lib/fish/              # ~3,500 lines (down from 4,534)
│   ├── cli-dispatch.fish
│   ├── config.fish
│   ├── deployer.fish
│   ├── external-modules.fish
│   ├── fedpunk-module.fish
│   ├── linker.fish
│   ├── module-ref-parser.fish
│   ├── module-resolver.fish
│   ├── module-utils.fish
│   ├── parameters.fish    # NEW: merged param-injector + param-prompter
│   ├── paths.fish
│   ├── ui.fish
│   └── yaml-parser.fish
├── modules/
│   ├── essentials/
│   └── ssh/
├── cli/                   # CLI commands (unchanged)
├── bin/                   # Dispatcher (unchanged)
├── docs/
│   └── MODULE_DEVELOPMENT.md  # NEW: comprehensive guide
├── README.md              # Updated for minimal core
├── CLAUDE.md              # Updated for minimal core
└── fedpunk.spec           # Updated for minimal core
```

### External Repositories

**hyprpunk** (desktop environment)
```
hyprpunk/
├── modes/
│   ├── desktop/
│   └── container/
├── plugins/               # From dev profile
├── themes/                # 12 themes from core
└── README.md
```

**fedpunk-minimal** (reference profile)
```
fedpunk-minimal/
├── modes/
│   ├── desktop/
│   └── container/
└── README.md
```

**fedpunk-claude** (external module)
```
fedpunk-claude/
├── module.yaml
├── config/
├── cli/
└── scripts/
```

### Metrics
- **Core size**: ~3,500 lines Fish code (down from 4,534)
- **Disk usage**: ~500 KB (down from ~128 MB)
- **Modules**: 2 universal (essentials, ssh)
- **Profiles**: 0 built-in (all external)
- **Themes**: 0 built-in (in hyprpunk)

---

## Testing Checklist Per Phase

### Phase 1 (Remove Legacy Code)
- [ ] `fedpunk module deploy essentials` works
- [ ] `fedpunk module deploy ssh` works
- [ ] `fedpunk profile deploy default --mode container` works
- [ ] External module deployment works
- [ ] No errors in logs

### Phase 2 (External Profiles)
- [ ] hyprpunk repo created with dev profile
- [ ] `fedpunk profile deploy https://github.com/user/hyprpunk --mode desktop` works
- [ ] All dev plugins load correctly
- [ ] fedpunk-minimal repo created
- [ ] Container mode deployment works
- [ ] No built-in profiles in `/usr/share/fedpunk/profiles/`

### Phase 3 (External Themes)
- [ ] Themes moved to hyprpunk repo
- [ ] `fedpunk-theme-list` works after hyprpunk deployment
- [ ] Theme switching works
- [ ] Wallpapers load correctly
- [ ] No themes in core repo

### Phase 4 (External Modules)
- [ ] claude module works from external repo
- [ ] bluetui module works from external repo
- [ ] Only essentials + ssh in core modules/
- [ ] External modules cache correctly

### Phase 5 (Library Consolidation)
- [ ] Parameter prompting still works
- [ ] Profile deployment still works
- [ ] No broken imports
- [ ] All functions accessible

### Phase 6 (Documentation)
- [ ] README.md reflects minimal core
- [ ] CLAUDE.md accurate
- [ ] MODULE_DEVELOPMENT.md comprehensive
- [ ] RPM builds successfully
- [ ] Post-install message correct

---

## Rollback Strategy

Each phase is a separate git branch:
- `cleanup/phase1-legacy` - Remove legacy code
- `cleanup/phase2-profiles` - External profiles
- `cleanup/phase3-themes` - External themes
- `cleanup/phase4-modules` - External modules
- `cleanup/phase5-consolidate` - Library consolidation
- `cleanup/phase6-docs` - Documentation

If any phase fails testing, we can revert to previous branch without losing all progress.

---

## Success Criteria

**Fedpunk v1.0-core is successful when:**
1. Core repo is <1 MB (excluding .git)
2. Only 2 modules in core (essentials, ssh)
3. No built-in profiles
4. No themes in core
5. External profile deployment works seamlessly
6. External module deployment works seamlessly
7. RPM builds and installs correctly
8. All documentation accurate and comprehensive
9. Hyprpunk repo provides complete desktop experience
10. Container mode works with minimal profile

---

## Timeline Estimate

- **Phase 1**: 30 minutes (delete + test)
- **Phase 2**: 2 hours (create external repos + test)
- **Phase 3**: 1 hour (move themes + test)
- **Phase 4**: 1 hour (create module repos + test)
- **Phase 5**: 1 hour (consolidate + test)
- **Phase 6**: 2 hours (update all docs + test RPM)

**Total**: ~7-8 hours of focused work

---

## Next Steps

1. **Review this plan** - Confirm approach and phases
2. **Start Phase 1** - Low risk, immediate benefit
3. **Create external repos** - Set up hyprpunk, fedpunk-minimal
4. **Execute phases sequentially** - Test between each phase
5. **Create PR to main** - After all phases complete and tested

**Ready to proceed with Phase 1?**
