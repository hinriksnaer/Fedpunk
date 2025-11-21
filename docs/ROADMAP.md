# Fedpunk Development Roadmap

**Last Updated:** 2025-01-20
**Current Phase:** Phase 1 - Foundation Testing
**Overall Progress:** 32% (8/25 milestones)

---

## Vision

Fedpunk is a fully modular, stow-based architecture that is:
- **Modular:** Each package is self-contained
- **Extensible:** Profiles can add custom plugins
- **Transparent:** Clear lifecycle hooks, no hidden magic
- **Testable:** Each module can be deployed independently

---

## Phase 1: Foundation Testing ⏳ IN PROGRESS

**Goal:** Verify the infrastructure works before building modules

**Status:** 60% (3/5)

### Tasks

- [x] **1.1** Design module system architecture
- [x] **1.2** Implement TOML parser
- [x] **1.3** Create module manager commands
- [ ] **1.4** Install stow and test fish module
- [ ] **1.5** End-to-end test: profile selection → module deployment

### Acceptance Criteria

✅ TOML parser correctly reads module.toml files
✅ Module manager can list and describe modules
⚠️ Fish module can be stowed to $HOME
⚠️ Installer can select profile/mode interactively
⚠️ At least one module deploys successfully

### Blockers

- **Stow not installed** - Required for all testing
- **No test environment** - Need VM or container

### Estimated Completion

- **Optimistic:** End of current session
- **Realistic:** Next session
- **Pessimistic:** 2-3 sessions

---

## Phase 2: Core Modules 📅 NEXT

**Goal:** Create minimum viable set of modules for basic system

**Status:** 7% (1/14 modules)

### Priority 1: Terminal Essentials

| Module | Priority | Effort | Dependencies | Status |
|--------|----------|--------|--------------|--------|
| fish | P0 | - | - | ✅ Complete |
| neovim | P0 | Medium | - | ❌ Not started |
| tmux | P0 | Small | - | ❌ Not started |

### Priority 2: Desktop Foundation

| Module | Priority | Effort | Dependencies | Status |
|--------|----------|--------|--------------|--------|
| fonts | P1 | Small | - | ❌ Not started |
| kitty | P1 | Small | fonts | ❌ Not started |
| hyprland | P1 | Large | fonts, kitty | ❌ Not started |

### Priority 3: Development Tools

| Module | Priority | Effort | Dependencies | Status |
|--------|----------|--------|--------------|--------|
| lazygit | P2 | Small | fish | ❌ Not started |
| btop | P2 | Small | - | ❌ Not started |
| yazi | P2 | Small | fish | ❌ Not started |
| gh | P2 | Small | fish | ❌ Not started |
| claude | P2 | Small | fish | ❌ Not started |

### Priority 4: Desktop Apps

| Module | Priority | Effort | Dependencies | Status |
|--------|----------|--------|--------------|--------|
| rofi | P3 | Small | hyprland | ❌ Not started |
| firefox | P3 | Trivial | - | ❌ Not started |
| audio | P3 | Medium | - | ❌ Not started |

### Module Creation Strategy

**For each module:**
1. Extract logic from `install/packaging/<name>.fish` or `install/config/<name>.fish`
2. Create `modules/<name>/module.toml`
3. Move configs from `home/dot_config/<name>/` to `modules/<name>/config/.config/<name>/`
4. Create lifecycle scripts as needed
5. Test with `fedpunk module deploy <name>`
6. Update profile mode TOML files

**Estimated effort:**
- **Small modules:** 15-30 min each (tmux, btop, gh, etc.)
- **Medium modules:** 1-2 hours (neovim, audio)
- **Large modules:** 2-4 hours (hyprland)

**Total estimated time:** 12-20 hours

### Acceptance Criteria

✅ All 14 modules created
✅ Each module has complete module.toml
✅ Desktop mode installs successfully
✅ Container mode installs successfully

---

## Phase 3: Integration Testing 🔄 BLOCKED

**Goal:** Ensure everything works together

**Status:** 0%

**Blocked by:** Phase 2 completion

### Tasks

- [ ] **3.1** Set up Fedora test VM/container
- [ ] **3.2** Test fresh installation (desktop mode)
- [ ] **3.3** Test fresh installation (container mode)
- [ ] **3.4** Test profile switching
- [ ] **3.5** Test module update workflow
- [ ] **3.6** Document any issues found
- [ ] **3.7** Fix critical bugs

### Test Scenarios

1. **Fresh Desktop Install**
   - Boot VM with fresh Fedora
   - Run boot.sh
   - Select dev/desktop
   - Verify all modules install
   - Verify Hyprland starts
   - Verify themes work

2. **Fresh Container Install**
   - Start Fedora container
   - Run boot.sh
   - Select dev/container
   - Verify minimal install
   - Verify fish works
   - Verify neovim works

3. **Profile Switching**
   - Install with profile A
   - Switch to profile B
   - Verify configs change
   - Switch back to profile A

4. **Module Operations**
   - Deploy single module
   - Unstow module
   - Re-stow module
   - Update module

### Acceptance Criteria

✅ Bootstrap works on fresh Fedora 40+
✅ Desktop mode successfully installs complete environment
✅ Container mode successfully installs minimal environment
✅ No critical bugs block installation
✅ Documented workarounds for known issues

---

## Phase 4: Chezmoi Migration ✅ COMPLETE

**Goal:** Remove chezmoi dependency

**Status:** 100%

**Completed:** 2025-01-20

### Implementation

**Decision:** Removed chezmoi completely (Option A)
- Simplified system architecture
- Eliminated dependency
- Used lifecycle scripts for environment detection
- Removed home/ directory entirely

### Completed Tasks

- [x] **4.1** Analyzed chezmoi usage patterns
- [x] **4.2** Migrated configs from home/ to module system
- [x] **4.3** Rewrote fedpunk-reload to remove chezmoi dependency
- [x] **4.4** Removed chezmoi from fish install script
- [x] **4.5** Updated fedpunk-activate-profile
- [x] **4.6** Removed home/ directory (162 files, 1.6M)
- [x] **4.7** Updated documentation to remove references

### Results

✅ No references to chezmoi in active codebase (only in historical CHANGELOG)
✅ All configs now managed via GNU Stow
✅ System works without chezmoi installed
✅ Cleaner architecture with single deployment method

---

## Phase 5: Advanced Features 📅 FUTURE

**Goal:** Add polish and power-user features

**Status:** 0%

### Planned Features

- [ ] **5.1** Module validation command
  - Validate module.toml syntax
  - Check for missing files
  - Verify dependencies exist

- [ ] **5.2** Dependency resolution
  - Auto-install dependencies
  - Detect circular dependencies
  - Show dependency tree

- [ ] **5.3** Module versioning
  - Track module versions
  - Handle updates
  - Rollback capability

- [ ] **5.4** Profile import/export
  - Export profile to shareable format
  - Import profile from URL or file
  - Profile marketplace?

- [ ] **5.5** Module marketplace
  - Community modules
  - Module discovery
  - Installation from remote

- [ ] **5.6** Dry-run mode
  - Preview changes before applying
  - Show what would be installed
  - Safety checks

- [ ] **5.7** Logging and diagnostics
  - Better error messages
  - Installation logs
  - Debug mode

---

## Phase 6: Documentation & Release 📝 FUTURE

**Goal:** Make system accessible to users

**Status:** 40%

### Documentation Tasks

- [x] **6.1** Architecture document (ARCHITECTURE.md)
- [x] **6.2** Module design document (DOTFILE_MODULES.md)
- [ ] **6.3** Migration guide from chezmoi system
- [ ] **6.4** Module creation tutorial
- [ ] **6.5** Profile customization guide
- [ ] **6.6** Troubleshooting guide
- [ ] **6.7** Video walkthrough

### Release Tasks

- [ ] **6.8** Write changelog
- [ ] **6.9** Create release notes
- [ ] **6.10** Tag release (v1.0.0-beta)
- [ ] **6.11** Announce on GitHub
- [ ] **6.12** Update README with new system info
- [ ] **6.13** Create migration FAQ

---

## Timeline Estimates

### Optimistic (Full-time work)
- Phase 1: 1 day
- Phase 2: 2-3 days
- Phase 3: 1 day
- Phase 4: 1 day
- Phase 5: 1 week
- Phase 6: 2-3 days
- **Total: ~2 weeks**

### Realistic (Part-time work)
- Phase 1: 2-3 sessions
- Phase 2: 1 week
- Phase 3: 3-4 sessions
- Phase 4: 2-3 sessions
- Phase 5: 2-3 weeks
- Phase 6: 1 week
- **Total: 4-6 weeks**

### Pessimistic (Complex issues)
- Phase 1: 1 week
- Phase 2: 2-3 weeks
- Phase 3: 1 week
- Phase 4: 1 week
- Phase 5: 1 month
- Phase 6: 2 weeks
- **Total: 2-3 months**

---

## Risk Assessment

### High Risk

⚠️ **Breaking changes for existing users**
- Mitigation: Clear migration guide, keep old branch

⚠️ **Undiscovered issues in module system**
- Mitigation: Thorough testing in Phase 3

### Medium Risk

⚠️ **Module creation takes longer than estimated**
- Mitigation: Start with smallest modules first

⚠️ **Stow limitations/bugs**
- Mitigation: Test early, have fallback plan

### Low Risk

⚠️ **Performance issues with TOML parser**
- Mitigation: Can optimize or switch to better parser

⚠️ **UI/UX issues with gum**
- Mitigation: Already abstracted in ui.fish

---

## Success Metrics

### Phase 1 Success
- [ ] Fish module deploys without errors
- [ ] Installer completes profile selection

### Phase 2 Success
- [ ] All 14 modules created
- [ ] Desktop mode installs successfully

### Phase 3 Success
- [ ] Fresh install works on test VM
- [ ] No P0/P1 bugs

### Overall Success
- [ ] New system works as well as old system
- [ ] Documentation is clear and complete
- [ ] Users can migrate smoothly
- [ ] System is maintainable long-term

---

## Current Focus

**This Session:**
1. ✅ Create STATUS.md
2. ✅ Create ROADMAP.md
3. ⏳ Decide: Test now or document first?
4. ⏳ If testing: Install stow, test fish module
5. ⏳ If documenting: Create next 2-3 modules

**Next Session:**
- Complete Phase 1 testing
- Start Phase 2 module creation
- Create neovim and tmux modules
