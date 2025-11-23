# Universal Blue Integration - Quick Reference

**Decision Date:** 2025-11-22
**Status:** Moving to Universal Blue custom images as primary distribution method

## TL;DR

**Before:** Fedpunk = config tool you install on Fedora
**After:** Fedpunk = complete OS images you rebase to

**Why:** Better declarative/reproducible model, aligns with project goals

## Key Documents

1. **[ADR-001: Decision Record](./ADR-001-universal-blue-images.md)**
   - Why we chose Universal Blue
   - Comparison to alternatives
   - Consequences and trade-offs
   - **Read first** for full context

2. **[Roadmap](./roadmap-universal-blue.md)**
   - 10-week evolution path
   - Phase-by-phase breakdown
   - Timeline and milestones
   - Success metrics
   - **Read for** big picture planning

3. **[Building First Image](./building-first-image.md)**
   - Day-by-day implementation guide
   - Practical steps to build prototype
   - Testing and validation
   - **Read for** hands-on work

## Quick Answers

### What is Universal Blue?
Framework for building custom Fedora Atomic desktop images with declarative configs and CI/CD.

### Why not just support atomic desktop?
Supporting atomic desktop (rpm-ostree) helps, but custom images provide:
- ✅ 100% reproducibility (bit-identical)
- ✅ Fully declarative (everything in code)
- ✅ True ecosystem (shareable images)
- ✅ Zero-friction setup (one command)

### What happens to traditional install?
**Keeps working!** Dual-track:
- **Recommended:** Rebase to fedpunk images (reproducible)
- **Alternative:** Traditional install.sh (flexible)

### What about the work we just did?
**All useful!**
- ✅ CLI improvements → used in images
- ✅ Custom linker → deploys configs in images
- ✅ Module system → defines what goes in images
- ✅ Bash bootstrap → helps traditional install
- ✅ Atomic support → foundation for images

Nothing wasted. This is evolution, not replacement.

### How long to first working image?
**1 week** for minimal prototype (Hyprland + Fish)

### How long to production-ready?
**10 weeks** to full ecosystem launch

### What do users do?
```bash
# One command setup
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/fedpunk/hyprland:latest
systemctl reboot
# Done!
```

### How do power users customize?
```bash
# Fork repo
git clone github.com/fedpunk/images myname/fedpunk-custom

# Edit recipe
vim config/recipe.yml  # Add packages, modules

# Push (GitHub Actions builds automatically)
git push

# Use custom image
rpm-ostree rebase docker://ghcr.io/myname/fedpunk-custom:latest
```

## Timeline

```
Week 1-2:  Build prototype image          [Starting now]
Week 3-4:  Production infrastructure
Week 5-6:  Convert all modules
Week 7-8:  Multiple image variants
Week 9-10: Public launch
```

## Image Variants (Planned)

```
fedpunk/base        - Minimal base (uCore + Fish)
fedpunk/hyprland    - Full Hyprland desktop (primary)
fedpunk/dev         - Developer workstation
fedpunk/minimal     - Headless/server
```

## Comparison

| Approach | Setup | Reproducible | Rollback | Ecosystem |
|----------|-------|--------------|----------|-----------|
| Traditional | Multi-step | ⭐⭐ | ❌ | ⭐⭐ |
| Atomic Support | Multi-step | ⭐⭐⭐ | ✅ | ⭐⭐ |
| **Custom Images** | One command | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ |

## Technical Architecture

### Current (Traditional)
```
User → Install Fedora → Clone fedpunk → Run installer →
Deploy modules → Install packages → Deploy configs
```

### Future (Images)
```
User → Rebase to fedpunk image → Reboot → Done
(Packages pre-installed, configs pre-deployed)
```

### Hybrid (Both)
```
Path A: Rebase to image (recommended)
Path B: Traditional install (still supported)
```

## Module System Evolution

### Before (Install-time)
```yaml
# modules/hyprland/module.yaml
packages:
  dnf:
    - hyprland
    - waybar
# Installed when user runs fedpunk module deploy
```

### After (Build-time)
```yaml
# config/recipe.yml (image definition)
install:
  - hyprland
  - waybar
# Baked into image, pre-installed

# modules/hyprland/module.yaml still exists
# But only defines CONFIGS, not packages
# Configs deployed by linker at runtime
```

**Key insight:** Modules become pure config, packages move to image.

## FAQ

**Q: Is this like NixOS?**
A: Similar benefits (declarative, reproducible) but Fedora-based, no new language.

**Q: Can I still use fedpunk on Ubuntu/Arch?**
A: No. Images are Fedora Atomic. Traditional install was Fedora-only anyway.

**Q: What if I don't want Hyprland?**
A: Fork the image, change to your compositor, rebuild. Or use different variant.

**Q: How big are the images?**
A: ~2-3GB. Smaller than full Silverblue, larger than minimal uCore.

**Q: Do I need to rebuild image for config changes?**
A: No! Configs deployed via linker (runtime). Only rebuild for package changes.

**Q: Can I layer packages on top of image?**
A: Yes, but discouraged. Fork and rebuild image instead (keeps reproducibility).

**Q: What about secrets?**
A: Not in images (public). Bitwarden vault integration handles secrets.

**Q: Updates?**
A: `rpm-ostree update` pulls new image. Atomic update of entire system.

**Q: Rollback?**
A: `rpm-ostree rollback` or select previous deployment at boot.

## Success Criteria

### Week 1 (Prototype)
- [ ] Image builds successfully
- [ ] Can rebase to it
- [ ] Hyprland + Fish work
- [ ] Basic validation passes

### Week 10 (Launch)
- [ ] 4 image variants available
- [ ] Signed images on ghcr.io
- [ ] Complete documentation
- [ ] Community announcement
- [ ] First external contributors

## Next Action

**Start Week 1 today:**

```bash
# 1. Fork BlueBuild template
gh repo create fedpunk-images --template blue-build/template --public

# 2. Follow building-first-image.md guide
# 3. Build minimal fedpunk-hyprland image
# 4. Test locally
# 5. Report findings
```

**Reference documents as needed:**
- Decision rationale → ADR-001
- Big picture → Roadmap
- Implementation → Building First Image

## Communication

**For existing users:**
> "Fedpunk is evolving! We're building custom OS images for zero-friction setup. Traditional install still works, but images are the recommended path for declarative/reproducible systems."

**For new users:**
> "Get a perfect Hyprland desktop in one command: `rpm-ostree rebase fedpunk/hyprland:latest`"

**For contributors:**
> "We're building custom Fedora Atomic images with Universal Blue. Module system still core, but packages move to image recipes."

## Resources

- [Universal Blue](https://universal-blue.org)
- [BlueBuild](https://blue-build.org)
- [Template Repo](https://github.com/blue-build/template)
- [Discourse](https://universal-blue.discourse.group)

---

**Bottom Line:** Moving from config tool to distribution. Better reproducibility, better user experience, true ecosystem. 10 weeks to launch. Starting now.
