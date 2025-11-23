# Fedpunk Evolution: From Config Tool to Distribution

**Vision:** Fedpunk becomes a NixOS-like declarative desktop distribution built on Fedora Atomic, without the complexity of Nix.

## Current State (November 2025)

### What Works
- ✅ Module system (declarative YAML packages + configs)
- ✅ Profile/mode system (desktop, container, atomic-desktop)
- ✅ Traditional Fedora support (DNF packages)
- ✅ Atomic desktop support (rpm-ostree)
- ✅ Custom linker (replaces GNU Stow, state tracking)
- ✅ CLI with module commands
- ✅ Bash bootstrap (install.sh)
- ✅ Theme system
- ✅ Bitwarden vault integration

### Limitations
- ⚠️ Not fully reproducible (install-time variance)
- ⚠️ System can drift (user manual changes)
- ⚠️ Multi-step installation
- ⚠️ No guaranteed identical systems
- ⚠️ "Tool" not "Distribution"

## Evolution Path

### Phase 1: Foundation ✅ COMPLETE
**Status:** Done (Current state)
**Timeline:** Completed
**Deliverables:**
- [x] Module system
- [x] Atomic desktop support
- [x] Custom linker
- [x] CLI unification

### Phase 2: Image Prototype 🚧 IN PROGRESS
**Status:** Starting
**Timeline:** Week 1-2 (Nov 22 - Dec 6)
**Goal:** Validate Universal Blue approach

**Week 1: Setup & Build**
- [ ] Fork Universal Blue startingpoint → `fedpunk-images` repo
- [ ] Create minimal `fedpunk-hyprland.yml` recipe
- [ ] Local build with podman
- [ ] Test image boots in VM

**Week 2: Test & Validate**
- [ ] Test rebase from Fedora Atomic
- [ ] Verify Hyprland + Fish work
- [ ] Deploy one fedpunk module
- [ ] Confirm state tracking works
- [ ] Document findings

**Success Criteria:**
- ✅ Custom image builds successfully
- ✅ Can rebase to image
- ✅ Hyprland desktop works
- ✅ Module deployment works
- ✅ Linker tracks state correctly

**Deliverables:**
- `fedpunk-images` repository
- Working `fedpunk-hyprland` image
- Rebase instructions
- Validation report

### Phase 3: Production Infrastructure
**Status:** Planned
**Timeline:** Week 3-4 (Dec 7 - Dec 20)
**Goal:** Production-ready image builds

**Tasks:**
- [ ] Set up GitHub Actions CI/CD
- [ ] Configure automatic builds on push
- [ ] Publish to ghcr.io
- [ ] Set up image signing (cosign)
- [ ] Add `:stable`, `:latest`, `:41` tags
- [ ] Create image update workflow

**Success Criteria:**
- ✅ Images build automatically
- ✅ Published to ghcr.io/fedpunk/*
- ✅ Signed images verify
- ✅ Tag strategy works
- ✅ Update workflow tested

**Deliverables:**
- GitHub Actions workflows
- Published signed images
- Update documentation
- Tag strategy doc

### Phase 4: Module Integration
**Status:** Planned
**Timeline:** Week 5-6 (Dec 21 - Jan 3)
**Goal:** Convert all modules to image recipes

**Tasks:**
- [ ] Audit all modules for image compatibility
- [ ] Create recipe templates for common patterns
- [ ] Convert core modules:
  - [ ] fish
  - [ ] hyprland
  - [ ] neovim
  - [ ] dev-tools
  - [ ] kitty, waybar, etc.
- [ ] Handle module dependencies in build
- [ ] Test full image with all modules

**Module Conversion Strategy:**

```yaml
# Old: module.yaml (install-time)
packages:
  dnf:
    - hyprland
    - waybar

# New: recipe.yml (build-time)
packages:
  - hyprland
  - waybar

# Modules still define configs
# But packages baked into image
```

**Success Criteria:**
- ✅ All modules converted
- ✅ Dependencies resolved correctly
- ✅ Configs still deployed via linker
- ✅ No install-time package installation

**Deliverables:**
- Module recipe templates
- Converted modules
- Build-time vs runtime guide

### Phase 5: Image Variants
**Status:** Planned
**Timeline:** Week 7-8 (Jan 4 - Jan 17)
**Goal:** Multiple image variants for different use cases

**Images to Create:**

1. **fedpunk/base**
   - Minimal base image
   - uCore + Fish + core utils
   - No desktop environment
   - Foundation for other images

2. **fedpunk/hyprland** (Primary)
   - Full Hyprland desktop
   - Waybar, Kitty, Rofi
   - Developer tools
   - Main fedpunk experience

3. **fedpunk/dev**
   - Extends hyprland
   - Additional dev tools
   - Language runtimes
   - IDE configurations

4. **fedpunk/minimal**
   - Headless/server
   - No GUI
   - SSH, tmux, basic tools
   - For remote/container use

**Tasks:**
- [ ] Define each variant's package set
- [ ] Set up image inheritance
- [ ] Build all variants
- [ ] Test each variant
- [ ] Document use cases

**Success Criteria:**
- ✅ All variants build
- ✅ Clear differentiation
- ✅ Inheritance works
- ✅ Users can choose appropriate variant

**Deliverables:**
- 4 image variants
- Variant comparison guide
- Use case documentation

### Phase 6: Ecosystem Launch
**Status:** Planned
**Timeline:** Week 9-10 (Jan 18 - Jan 31)
**Goal:** Public release, documentation, community

**Documentation:**
- [ ] Main README (image-focused)
- [ ] Quick start guide
- [ ] Customization guide (forking)
- [ ] Migration guide (traditional → images)
- [ ] FAQ
- [ ] Comparison to NixOS/others

**Community:**
- [ ] Announcement post
- [ ] Reddit/HN submission
- [ ] Discord/Matrix channel
- [ ] Contributing guide
- [ ] Issue templates

**Polish:**
- [ ] Website/landing page
- [ ] Screenshots/demos
- [ ] Video walkthrough
- [ ] Logo/branding

**Success Criteria:**
- ✅ Complete documentation
- ✅ Public announcement
- ✅ Community channels set up
- ✅ First external contributors

**Deliverables:**
- Documentation suite
- Community infrastructure
- Public launch
- Marketing materials

### Phase 7: Advanced Features
**Status:** Future
**Timeline:** Feb 2025+
**Goal:** Power user features

**Features to Add:**

1. **Template System**
   - Web UI for image customization
   - Select modules via checkboxes
   - Generate custom recipe
   - Auto-build user image

2. **Feature Flags**
   - Enable/disable features without forking
   - Via config file or environment vars
   - Examples: `FEDPUNK_ENABLE_NVIDIA=true`

3. **User Overrides**
   - Layer custom configs without forking
   - `~/.config/fedpunk/overrides/`
   - Applied on top of base image

4. **Variant Matrix**
   - Automatic builds of combinations
   - Example: `fedpunk/hyprland-nvidia:latest`
   - CPU vs GPU variants
   - X11 vs Wayland variants

**Success Criteria:**
- ✅ Advanced features working
- ✅ Don't complicate simple use case
- ✅ Power users satisfied

## Timeline Overview

```
Week 1-2:  Prototype                    [Nov 22 - Dec 6]
Week 3-4:  Infrastructure               [Dec 7 - Dec 20]
Week 5-6:  Module conversion            [Dec 21 - Jan 3]
Week 7-8:  Image variants               [Jan 4 - Jan 17]
Week 9-10: Ecosystem launch             [Jan 18 - Jan 31]
Feb+:      Advanced features            [Ongoing]
```

## Success Metrics

### Technical
- [ ] Image builds in < 30 minutes
- [ ] Image size < 3GB
- [ ] Rebase completes in < 5 minutes
- [ ] 100% module test coverage
- [ ] Zero install failures

### User Experience
- [ ] One-command setup works
- [ ] New user to working system < 10 minutes
- [ ] Customization documented clearly
- [ ] Support requests < 5/month

### Community
- [ ] 100+ GitHub stars
- [ ] 10+ external contributors
- [ ] 5+ community image forks
- [ ] Active Discord/Matrix

## Risk Management

### Risk: Build infrastructure costs
**Mitigation:** GitHub Actions has generous free tier, images build fast

### Risk: Users don't understand image paradigm
**Mitigation:**
- Clear docs comparing to traditional
- Video walkthroughs
- Keep traditional install as fallback

### Risk: Module system conflicts with image builds
**Mitigation:**
- Modules define configs (runtime)
- Images consume packages (build-time)
- Clear separation

### Risk: Universal Blue changes breaking us
**Mitigation:**
- Pin to stable versions
- Active monitoring of upstream
- Contribute back to Universal Blue

## Open Questions

### Q: Support multiple Fedora versions?
**A:** Start with latest stable (41), add `:40`, `:42` later

### Q: Support other bases (Ubuntu, Arch)?
**A:** No. Stay Fedora-focused. Fork if needed.

### Q: How to handle secrets in images?
**A:** Don't. Images are public. Bitwarden integration for secrets.

### Q: Support arm64/aarch64?
**A:** Maybe later. Start with x86_64.

## Comparison to Similar Projects

### vs NixOS
**Similar:** Declarative, reproducible, ecosystem
**Different:** Fedora-based, no new language, easier learning curve

### vs Vanilla OS
**Similar:** Atomic desktop, declarative
**Different:** Fedora (not Ubuntu), module system, developer-focused

### vs Bluefin/Aurora (Universal Blue)
**Similar:** Built on Universal Blue
**Different:** Hyprland-focused, module system, developer workflow

### vs Home Manager
**Similar:** Declarative configs
**Different:** Full system (not just dotfiles), immutable base

## Long-term Vision (2026+)

### Fedpunk Cloud
- Build custom images via web UI
- Select modules, click "Build"
- Rebase to your custom image
- SaaS for non-technical users

### Fedpunk Studio
- Desktop app for image management
- GUI for module selection
- One-click customization
- Update management

### Fedpunk Enterprise
- Organization image policies
- Centralized image registry
- Compliance/audit features
- Fleet management

## Conclusion

**Fedpunk evolves from configuration tool to distribution.**

**Timeline:** 10 weeks to public launch
**Effort:** Sustainable, incremental
**Impact:** NixOS-level reproducibility, Fedora simplicity

Next step: Build the prototype (Phase 2, Week 1).
