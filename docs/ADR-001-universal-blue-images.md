# ADR-001: Adopt Universal Blue Custom Images as Primary Distribution Method

**Status:** Accepted
**Date:** 2025-11-22
**Decision Makers:** Project maintainers
**Tags:** architecture, distribution, reproducibility

## Context

Fedpunk started as a configuration management tool for Fedora - users install Fedora, then run fedpunk's installer to deploy modules (packages + dotfiles). This works but has limitations:

### Current Approach Limitations

1. **Not Fully Reproducible**
   - Same module YAML can produce different results over time
   - DNF dependency resolution varies
   - User can manually install packages (system drift)
   - No guarantee of identical system state

2. **Not Fully Declarative**
   - Modules are declarative (YAML)
   - But system state is imperative (run installer, layer packages)
   - User manages system outside of fedpunk

3. **Limited Ecosystem**
   - Users must install Fedora first
   - Run installer manually
   - Each user has slightly different system
   - Hard to share exact environments

### Project Goals

The project aims to provide:
- ✅ **Declarative configuration** - define desired state in code
- ✅ **Full reproducibility** - same config = identical system
- ✅ **Desktop orchestration ecosystem** - reusable, shareable environments

### Discovery: Universal Blue

[Universal Blue](https://universal-blue.org) is a framework for building custom Fedora Atomic desktop images:
- Declarative image definitions (container-style builds)
- CI/CD via GitHub Actions
- Bit-identical reproducibility
- Atomic updates and rollbacks
- Growing ecosystem of custom images

**Key insight:** Building custom OS images delivers our goals better than configuration management.

## Decision

**We will adopt Universal Blue custom images as the primary distribution method for fedpunk.**

Specifically:

1. **Create fedpunk images** using Universal Blue's framework
2. **Maintain image definitions** (YAML/Containerfile) as source of truth
3. **Build images automatically** via GitHub Actions
4. **Publish to container registry** (ghcr.io)
5. **Keep traditional installer** as secondary option for DIY users

### Image Strategy

**Provide multiple image variants:**

```
fedpunk/base        - Minimal base (uCore + Fish + essentials)
fedpunk/hyprland    - Hyprland desktop (main image)
fedpunk/dev         - Developer workstation (hyprland + dev tools)
fedpunk/minimal     - Headless/server
```

**Users rebase to fedpunk images:**
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/fedpunk/hyprland:latest
systemctl reboot
```

## Rationale

### Why This Achieves Our Goals

**1. Fully Declarative**

Image definition is complete source of truth:
```yaml
# recipes/fedpunk-hyprland.yml
name: fedpunk-hyprland
base-image: ghcr.io/ublue-os/ucore:stable

packages:
  - fish
  - hyprland
  - waybar
  - kitty
  # Every package listed explicitly

modules:
  - hyprland
  - neovim
  - dev-tools
  # Fedpunk modules to enable
```

Everything is declared. No imperative steps. No hidden state.

**2. Bit-Identical Reproducibility**

- Same image definition → identical image (byte-for-byte)
- Everyone using `fedpunk/hyprland:latest` has EXACT same base system
- No install-time variance
- No dependency resolution differences
- Perfect reproducibility

**3. True Ecosystem**

- **Users:** One command to get perfect environment
- **Customization:** Fork image repository, edit YAML, rebuild
- **Sharing:** "I use fedpunk/dev:latest" = complete system description
- **Community:** Others can contribute image variants

### Comparison to Alternatives

| Approach | Declarative | Reproducible | Ecosystem | Complexity |
|----------|-------------|--------------|-----------|------------|
| Traditional install | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐ |
| Atomic support | ⭐⭐⭐½ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Custom images** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| NixOS | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Why not NixOS?**
- Steep learning curve (Nix language)
- Different packaging ecosystem
- Fedpunk provides similar benefits with familiar Fedora base

**Why Universal Blue over custom ostree setup?**
- Proven framework (used by bluefin, bazzite, aurora)
- GitHub Actions templates ready
- Active community
- Best practices built-in

## Implementation Path

### Phase 1: Prototype (Week 1-2)
- Fork Universal Blue startingpoint
- Create minimal `fedpunk-hyprland` image
- Build locally, test rebase
- Validate approach

### Phase 2: Infrastructure (Week 3-4)
- Set up GitHub Actions builds
- Publish to ghcr.io
- Sign images
- Documentation

### Phase 3: Module Integration (Week 5-6)
- Convert fedpunk modules → image recipes
- Multiple image variants
- Automated builds on module changes

### Phase 4: Ecosystem (Ongoing)
- Community contributions
- User customization guide
- Image variants for different use cases

## Consequences

### Positive

✅ **Achieves all project goals**
- Fully declarative
- 100% reproducible
- True ecosystem

✅ **User experience dramatically improved**
- One command setup (rebase)
- Zero install friction
- Guaranteed working state

✅ **Maintenance simplified**
- CI/CD builds images automatically
- Users get updates atomically
- Rollback if issues

✅ **Positions fedpunk as distribution**
- Not just a "config tool"
- Complete desktop distribution
- NixOS-like benefits without complexity

### Negative

⚠️ **Paradigm shift**
- From "tool you install" to "OS you run"
- May confuse existing users
- Need clear messaging

⚠️ **Build infrastructure needed**
- GitHub Actions
- Container registry
- Image signing

⚠️ **Less flexibility for some users**
- Can't easily mix modules without rebuilding
- Need to fork repo for heavy customization
- Solution: Keep traditional installer as option

⚠️ **Learning curve for contributors**
- Need to understand image builds
- Containerfile syntax
- CI/CD workflows

### Mitigation Strategies

**Dual-track support:**
```
Recommended: Rebase to fedpunk images (reproducible)
Alternative: Traditional install (flexible)
```

**Clear documentation:**
- Why images vs traditional
- How to customize images
- When to use each approach

**Gradual migration:**
- Existing users can continue traditional
- New users recommended to images
- Both maintained

## Related Decisions

- **ADR-002:** Module system remains core abstraction (images consume modules)
- **ADR-003:** Keep Fish shell for implementation (no bash rewrite needed)
- **ADR-004:** Custom linker for dotfile management (better than stow)

## References

- [Universal Blue Documentation](https://universal-blue.org)
- [BlueBuild (formerly Ublue-OS Startingpoint)](https://blue-build.org)
- [Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops/)
- [NixOS Comparison](https://nixos.org)

## Future Considerations

### Potential Enhancements

- **Template system** - Users define custom images via web UI
- **Feature flags** - Enable/disable features without forking
- **Variant matrix** - Automatic builds of all combinations
- **User overrides** - Layer custom configs without forking

### Open Questions

- Should we support Ubuntu/Arch bases? (Probably not - stay Fedora-focused)
- How to handle user-specific secrets? (Bitwarden integration remains)
- Version pinning strategy? (`:latest` vs `:stable` vs `:41`)

## Approval

**Accepted:** 2025-11-22

This decision represents a significant architectural direction change. All new development should align with this vision:
- Images as primary distribution
- Traditional install as secondary option
- Reproducibility and declarative config as core values

---

## Appendix: User Flows

### Traditional Approach (Old)
```bash
# User flow
1. Install Fedora Workstation
2. git clone fedpunk
3. ./install.fish --mode desktop
4. Wait for packages to install
5. Reboot if atomic desktop
6. Hope it works
```

**Issues:**
- Multi-step process
- Install-time variance
- No rollback
- Different results for different users

### Image Approach (New)
```bash
# User flow
1. rpm-ostree rebase fedpunk/hyprland:latest
2. systemctl reboot
3. Done. Perfect system.
```

**Benefits:**
- One command
- Bit-identical result
- Atomic rollback
- Everyone gets same environment

### Customization Flow (New)
```bash
# Power user flow
1. Fork github.com/fedpunk/images
2. Edit recipes/fedpunk-hyprland.yml
   - Add your packages
   - Enable your modules
3. Push to GitHub
4. Actions builds your custom image
5. rpm-ostree rebase docker://ghcr.io/yourname/fedpunk-hyprland:latest
6. Your custom fedpunk, perfectly reproducible
```

This preserves flexibility while maintaining reproducibility.
