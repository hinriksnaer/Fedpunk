# Fedpunk CLI Architecture Analysis & Overhaul Proposal

## Current Architecture Assessment

### What Exists Today

#### 1. CLI Entry Points
- **Main CLI** (`~/.local/bin/fedpunk`): Unified wrapper for profile, theme, vault, sync commands
- **Installer** (`install.fish`): Standalone orchestrator for fresh installations
- **Module Functions** (`lib/fish/fedpunk-module.fish`): NOT exposed via CLI - requires direct function calls
- **Scattered Scripts** (~/.local/bin/fedpunk-*): 15+ separate scripts for various operations

#### 2. Command Structure

```
fedpunk
├── init                    ✓ Works (TUI wizard)
├── profile                 ✓ Works (list, select, activate, current, create)
├── theme                   ✓ Works (set, list, current, select, next, prev, refresh)
├── wallpaper               ✓ Works (set, next)
├── vault                   ✓ Works (status, unlock, ssh-backup, ssh-restore, etc.)
├── apply                   ✓ Works (chezmoi apply)
├── sync                    ✓ Works (git pull + apply)
├── bluetooth               ✓ Works (bluetui wrapper)
├── module                  ✗ MISSING (must call fedpunk-module functions directly)
└── help/version            ✓ Works
```

#### 3. Stow Configuration Management

**Current Implementation:**
- Uses GNU Stow for symlink-based dotfile management (lib/fish/fedpunk-module.fish:286)
- Two-phase conflict resolution:
  1. Try `stow --restow` (fails on existing files)
  2. Fall back to `stow --adopt` (takes ownership of existing files)
- All modules have `conflicts: warn` metadata

**Problems:**
```fish
# fedpunk-module.fish:286-314 (simplified)
stow --restow -t $HOME config 2>&1
if contains "existing target" $output
    # Use --adopt to take ownership
    stow --adopt -t $HOME config
end
```

**Why This Is Problematic:**
- `--adopt` modifies your module source to match $HOME files (unexpected behavior)
- Conflicts require manual intervention or data loss risk
- No dry-run or preview capability
- Can't easily unstow/restow for testing
- Module order matters (later modules can clobber earlier ones)
- Difficult to debug which module owns which file

---

## Key Issues

### 1. CLI Fragmentation ⚠️ HIGH PRIORITY
**Problem:** Module management is invisible to users. You must know to call fish functions directly:
```fish
# What users expect:
fedpunk module list

# What they must do:
fish -c 'set -gx FEDPUNK_ROOT ~/.local/share/fedpunk; \
  source lib/fish/fedpunk-module.fish; fedpunk-module list'
```

**Impact:** Poor discoverability, difficult testing, hard to script

### 2. Stow Brittleness ⚠️ HIGH PRIORITY
**Problem:** Stow's conflict resolution is destructive and unpredictable
- `--adopt` silently modifies your modules
- No way to preview changes before applying
- Conflicts block deployment
- Can't track which module owns which file

**Impact:** Users afraid to redeploy, hard to maintain, risky updates

### 3. Multiple Patterns ⚠️ MEDIUM PRIORITY
**Problem:** Inconsistent command access patterns
- Some functionality via main CLI (`fedpunk theme set`)
- Some via separate scripts (`fedpunk-nvidia-reload`)
- Some via direct function calls (module management)
- Some via standalone files (`install.fish`)

**Impact:** Cognitive overhead, maintenance burden, testing complexity

### 4. Limited Composability ⚠️ MEDIUM PRIORITY
**Problem:** Hard to build on top of fedpunk
- No programmatic API for module operations
- Can't easily script complex workflows
- Testing requires manual setup

**Impact:** Hard to extend, difficult to automate, poor testability

---

## Recommended Overhaul

### Phase 1: Unify Module Commands (PRIORITY)

**Add to main CLI:**
```fish
fedpunk module list                    # List available modules
fedpunk module info <module>           # Show module details
fedpunk module deploy <module>         # Deploy a module
fedpunk module remove <module>         # Remove a module
fedpunk module update <module>         # Update a module
fedpunk module status                  # Show deployed modules
```

**Implementation:**
```fish
# In ~/.local/bin/fedpunk, add:
case module
    # Module management
    if test (count $args) -eq 0
        echo "Usage: fedpunk module <subcommand> [args...]"
        echo ""
        echo "Subcommands:"
        echo "  list              List available modules"
        echo "  info <name>       Show module information"
        echo "  deploy <name>     Deploy a module"
        echo "  remove <name>     Remove a module (unstow)"
        echo "  status            Show deployed modules"
        exit 1
    end

    set module_cmd $args[1]
    set module_args $args[2..-1]

    # Source module library
    source "$FEDPUNK_ROOT/lib/fish/fedpunk-module.fish"

    switch $module_cmd
        case list
            fedpunk-module list
        case info
            fedpunk-module info $module_args
        case deploy
            fedpunk-module deploy $module_args
        case remove unstow
            fedpunk-module unstow $module_args
        case status
            fedpunk-module-status
        case '*'
            echo "Unknown module subcommand: $module_cmd"
            exit 1
    end
```

**Benefit:** Immediate usability improvement with minimal changes

---

### Phase 2: Replace Stow with Custom Linker (RECOMMENDED)

#### Option A: Custom Fish-Based Linker ⭐ RECOMMENDED

**Why Replace Stow:**
1. Stow doesn't track which module owns which file
2. Stow's `--adopt` is destructive and surprising
3. No preview/dry-run capability
4. Can't handle overlapping files gracefully
5. Complex stow directory structure requirements

**Custom Linker Features:**
```yaml
# State tracking: ~/.local/share/fedpunk/.linker-state.json
{
  "files": {
    "/home/user/.config/fish/config.fish": {
      "source": "modules/fish/config/.config/fish/config.fish",
      "module": "fish",
      "deployed_at": "2025-11-22T10:30:00Z"
    },
    "/home/user/.config/hypr/hyprland.conf": {
      "source": "modules/hyprland/config/.config/hypr/hyprland.conf",
      "module": "hyprland",
      "deployed_at": "2025-11-22T10:31:00Z"
    }
  },
  "conflicts": {
    "/home/user/.bashrc": [
      {"module": "essentials", "action": "skipped"},
      {"existing": "user-created", "action": "preserved"}
    ]
  }
}
```

**Implementation:**
```fish
# lib/fish/linker.fish

function linker-deploy
    # Deploy module config with conflict tracking
    set -l module_name $argv[1]
    set -l module_dir (module-resolve-path $module_name)
    set -l config_dir "$module_dir/config"

    if not test -d "$config_dir"
        return 0
    end

    # Load state
    set -l state_file "$FEDPUNK_ROOT/.linker-state.json"

    # Discover all files in module
    set -l files (find "$config_dir" -type f)

    for src_file in $files
        # Calculate target path
        set -l rel_path (string replace "$config_dir/" "" "$src_file")
        set -l target "$HOME/$rel_path"

        # Check for conflicts
        if test -e "$target" -a not test -L "$target"
            # File exists and is NOT a symlink
            echo "  ⚠️  Conflict: $target (existing file)"
            linker-handle-conflict "$target" "$src_file" "$module_name"
            continue
        end

        if test -L "$target"
            # Symlink exists - check if it's ours
            set -l current_target (readlink -f "$target")
            set -l expected_target (readlink -f "$src_file")

            if test "$current_target" != "$expected_target"
                echo "  ⚠️  Conflict: $target (owned by different module)"
                linker-handle-conflict "$target" "$src_file" "$module_name"
                continue
            else
                echo "  ✓ Already linked: $rel_path"
                continue
            end
        end

        # Create parent directory
        mkdir -p (dirname "$target")

        # Create symlink
        ln -s "$src_file" "$target"
        echo "  ✓ Linked: $rel_path"

        # Update state
        linker-state-add "$target" "$src_file" "$module_name"
    end
end

function linker-handle-conflict
    set -l target $argv[1]
    set -l src $argv[2]
    set -l module $argv[3]

    # Interactive conflict resolution
    echo ""
    echo "Conflict Resolution for: $target"
    echo "  [k] Keep existing file (skip this module file)"
    echo "  [r] Replace with module file (backup existing)"
    echo "  [d] Diff files"
    echo "  [a] Abort"

    read -P "Choose action [k/r/d/a]: " -n 1 choice
    echo ""

    switch $choice
        case k K
            echo "  → Keeping existing file"
            linker-state-add-conflict "$target" "$module" "skipped"

        case r R
            # Backup existing
            set -l backup "$target.backup."(date +%Y%m%d-%H%M%S)
            mv "$target" "$backup"
            ln -s "$src" "$target"
            echo "  → Replaced (backup: $backup)"
            linker-state-add "$target" "$src" "$module"

        case d D
            diff -u "$target" "$src" | less
            # Ask again after showing diff
            linker-handle-conflict $argv

        case a A
            echo "  → Aborting deployment"
            return 1

        case '*'
            echo "  → Invalid choice, keeping existing"
            linker-state-add-conflict "$target" "$module" "skipped"
    end
end

function linker-remove
    # Remove module symlinks
    set -l module_name $argv[1]
    set -l state_file "$FEDPUNK_ROOT/.linker-state.json"

    # Find all files owned by this module
    set -l module_files (jq -r ".files | to_entries[] | select(.value.module == \"$module_name\") | .key" "$state_file")

    for file in $module_files
        if test -L "$file"
            rm "$file"
            echo "  ✓ Removed: $file"
            linker-state-remove "$file"
        else
            echo "  ⚠️  Not a symlink: $file (manual intervention needed)"
        end
    end
end

function linker-status
    # Show deployment status
    set -l state_file "$FEDPUNK_ROOT/.linker-state.json"

    if not test -f "$state_file"
        echo "No modules deployed"
        return 0
    end

    echo "Deployed Modules:"
    jq -r '.files | to_entries | group_by(.value.module) | .[] | "\(.0.value.module): \(length) files"' "$state_file"

    echo ""
    echo "Conflicts:"
    jq -r '.conflicts | to_entries[] | "  \(.key) → \(.value.action)"' "$state_file"
end
```

**Benefits:**
- ✅ Full visibility into what's deployed
- ✅ Graceful conflict handling with user choice
- ✅ Ability to show which module owns which file
- ✅ Preview changes before applying
- ✅ Easy rollback
- ✅ No dependency on stow

**Drawbacks:**
- ⚠️ Need to implement and test custom code
- ⚠️ Migration path from existing stow-based deployments

---

#### Option B: Keep Stow, Improve Conflict Handling

**If you want to keep stow:**
```fish
function fedpunk-module-stow-improved
    set -l module_name $argv[1]
    set -l module_dir (module-resolve-path $module_name)
    set -l config_dir "$module_dir/config"

    # Dry run first
    set -l conflicts (stow --no -t $HOME config 2>&1 | grep "conflict")

    if test -n "$conflicts"
        echo "⚠️  Conflicts detected:"
        echo "$conflicts"
        echo ""

        if ui-confirm "Use --adopt to take ownership?"
            stow --adopt -t $HOME config
            echo ""
            echo "⚠️  WARNING: --adopt modified your module source!"
            echo "Review changes: cd $module_dir && git diff"
        else
            echo "Deployment cancelled"
            return 1
        end
    else
        stow --restow -t $HOME config
    end
end
```

**Benefits:**
- ✅ Minimal code changes
- ✅ Leverage stow's maturity

**Drawbacks:**
- ⚠️ Still destructive with --adopt
- ⚠️ No state tracking
- ⚠️ Can't show which module owns which file

---

### Phase 3: Consolidate Scripts (OPTIONAL)

**Current:** 15+ separate scripts in `~/.local/bin/`
```
fedpunk-theme-set
fedpunk-theme-list
fedpunk-theme-current
fedpunk-theme-next
fedpunk-theme-prev
fedpunk-wallpaper-set
fedpunk-wallpaper-next
...
```

**Proposed:** Merge into main CLI, keep separate scripts as implementation details
```
~/.local/bin/fedpunk          # Main CLI (calls lib functions)
~/.local/share/fedpunk/lib/
  ├── fish/
  │   ├── theme.fish          # Theme functions
  │   ├── wallpaper.fish      # Wallpaper functions
  │   ├── vault.fish          # Vault functions
  │   └── module.fish         # Module functions
```

**Benefit:** Single entry point, easier to maintain

---

## Stow Alternatives Comparison

| Approach | Pros | Cons | Effort |
|----------|------|------|--------|
| **Custom Linker** | Full control, state tracking, conflict resolution | Need to implement | Medium |
| **Improved Stow** | Familiar, mature | Still limited, --adopt is destructive | Low |
| **Chezmoi** | Rich features, templates, secrets | Heavy, different paradigm | High |
| **Home Manager** | Nix ecosystem, atomic | Nix dependency, steep learning curve | Very High |
| **YADM** | Git-based, encryption | No module system | High |

**Recommendation:** Custom linker for best fedpunk integration

---

## Migration Path

### Step 1: Add Module Commands to CLI (Week 1)
- Add `fedpunk module` subcommand to main CLI
- Expose existing functions (list, info, deploy, unstow)
- Test with current stow-based deployment
- **No breaking changes**

### Step 2: Implement Custom Linker (Week 2-3)
- Write linker.fish with state tracking
- Add conflict resolution UI
- Implement linker-deploy, linker-remove, linker-status
- Test alongside stow (don't switch yet)

### Step 3: Migration Tool (Week 4)
- Create `fedpunk migrate-to-linker` command
- Scans existing stow symlinks
- Generates linker state from current deployment
- Offers to switch

### Step 4: Deprecate Stow (Week 5+)
- Update documentation
- Add warnings to stow-based commands
- Eventually remove stow code

---

## Recommended Action Plan

### Immediate (This Week)
1. ✅ **Add `fedpunk module` commands to CLI** (Phase 1)
   - Fixes immediate usability issue
   - No architectural changes
   - Can be done in <1 hour

### Short Term (Next 2 Weeks)
2. ✅ **Implement custom linker** (Phase 2, Option A)
   - Solves stow brittleness
   - Adds state tracking
   - Enables better conflict resolution

### Medium Term (Next Month)
3. ✅ **Create migration tool**
   - Smooth transition from stow
   - Preserve existing deployments

### Long Term (Optional)
4. ⚪ **Consolidate scattered scripts** (Phase 3)
   - Cleaner architecture
   - Not urgent, can wait

---

## Decision Matrix

| Issue | Solution | Priority | Effort | Impact |
|-------|----------|----------|--------|--------|
| Module commands missing from CLI | Add to fedpunk wrapper | 🔴 HIGH | Low (1h) | High |
| Stow conflicts are destructive | Custom linker with state | 🔴 HIGH | Medium (2-3d) | Very High |
| Multiple script patterns | Consolidate into lib/ | 🟡 MEDIUM | Medium (2d) | Medium |
| Hard to test/script | Module API + linker state | 🟡 MEDIUM | Low (bundled) | High |

---

## Recommendation Summary

**YES, an overhaul is needed, but it can be phased:**

1. **Start with CLI unification** (immediate, low effort)
   - Add `fedpunk module` commands
   - Expose existing functionality
   - Test on atomic desktop branch

2. **Replace stow with custom linker** (short term, medium effort)
   - Implement state tracking
   - Add conflict resolution UI
   - Enable preview/dry-run
   - Migrate existing deployments

3. **Consolidate scripts** (optional, medium effort)
   - Move to lib/ functions
   - Keep single CLI entry point

**Bottom Line:** The module system is well-designed, but the CLI and stow implementation are holding it back. The fixes are straightforward and can be done incrementally without breaking existing users.
