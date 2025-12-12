# Fedpunk RPM Testing

Test suite for validating Fedpunk RPM packaging and installation.

---

## Quick Start

### Run COPR Mode Tests (Recommended)

```bash
# In devcontainer or Fedora container
bash test/run-all-tests.sh copr
```

This builds and tests using rpkg, exactly like COPR does. **This is now the default mode.**

### Run All Test Modes

```bash
bash test/run-all-tests.sh both    # Both COPR and legacy modes
bash test/run-all-tests.sh legacy  # Legacy mode only
```

### Run Individual Tests

```bash
# COPR mode - replicates COPR build process (recommended)
bash test/build-rpm-copr-mode.sh

# Legacy mode - template replacement for quick testing
bash test/build-rpm.sh

# Test installation (works with either build)
bash test/test-rpm-install.sh
```

---

## CI Integration

### GitHub Actions

Every push to `main` or PR targeting `main` triggers the RPM build and test workflow:

**Workflow:** `.github/workflows/test-rpm-build.yml`

**What it does:**
1. **Validate COPR Spec** (Primary):
   - Validates spec file with `test/build-rpm-copr-mode.sh` (rpkg)
   - Ensures rpkg can process templates
   - Uploads SRPM artifact as `fedpunk-srpm-copr`
   - **Fast validation - no full build**

2. **Build & Test RPM** (Secondary):
   - Builds full RPM using `test/build-rpm.sh` (legacy mode)
   - Tests installation
   - Uploads artifacts as `fedpunk-rpm-legacy` and `fedpunk-srpm-legacy`

**Both jobs must pass** before merge is allowed. COPR validation ensures COPR builds will work. Legacy mode ensures the package actually installs correctly.

**View results:**
- https://github.com/hinriksnaer/Fedpunk/actions

**Download artifacts:**
- Click on any successful workflow run
- Find "Artifacts" section at the bottom
- Download `fedpunk-rpm` or `fedpunk-srpm`

### Local Testing Before Push

**Always run tests locally before pushing to main:**

```bash
# Option 1: Using devcontainer (VS Code)
# 1. Open in VS Code
# 2. Reopen in Container
# 3. Run: bash test/run-all-tests.sh

# Option 2: Using Podman/Docker
podman run -it --rm \
  -v .:/workspace:z \
  -w /workspace \
  fedora:43 \
  bash test/run-all-tests.sh
```

---

## Test Modes

### COPR Mode (Recommended) - build-rpm-copr-mode.sh

**Purpose:** Validate spec file with rpkg (ensures COPR builds will work)

**How it works:**
- Uses rpkg to process spec file templates: `{{{ git_dir_pack }}}` and `{{{ git_dir_setup_macro }}}`
- Builds SRPM with: `rpkg srpm`
- **Validates templates only - does NOT build binary RPM**

**Why use this:**
- ✅ Validates spec file templates COPR will use
- ✅ Catches COPR-specific issues before pushing to main
- ✅ Fast validation (no full RPM build needed)
- ✅ Ensures `.copr/Makefile` and templates work correctly

**Steps:**
1. Install rpkg (minimal dependencies)
2. Verify git repository
3. Run `rpkg srpm` to create SRPM (processes templates)
4. Validate SRPM was created successfully
5. Exit (binary RPM build tested in legacy mode)

### Legacy Mode - build-rpm.sh

**Purpose:** Build RPM for quick local testing without rpkg

**How it works:**
- Modifies spec file to replace rpkg templates with static values
- Creates tarball manually with `git archive`
- Builds with standard `rpmbuild`

**Why use this:**
- ✅ Works without rpkg dependency
- ✅ Good for quick local development
- ✅ Compatible with older build tools

**Steps:**
1. Install build dependencies (rpm-build, rpmdevtools, git, fish, stow, yq, gum)
2. Create source tarball with `git archive`
3. Replace `{{{ git_dir_pack }}}` → `fedpunk-%{version}.tar.gz`
4. Replace `{{{ git_dir_setup_macro }}}` → `%autosetup`
5. Build RPM with `rpmbuild -ba`

**Important:** CI and COPR use different code paths in this mode. Use COPR mode to validate before merging.

---

## Test Suite Details

### test-rpm-install.sh

**Purpose:** Validate RPM installation and functionality

**Tests performed:**
1. ✓ System files exist in `/usr/share/fedpunk/`
2. ✓ Environment setup via `/etc/profile.d/fedpunk.sh`
3. ✓ Wrapper command `/usr/bin/fedpunk` is executable
4. ✓ `fedpunk install --mode container` runs successfully
5. ✓ User space auto-created in `~/.local/share/fedpunk/`
6. ✓ Active profile symlink points correctly
7. ✓ Fish config generated (`fedpunk-module-params.fish`)
8. ✓ Fish shell starts without errors

**Success criteria:**
- All 7 test sections pass
- Installation summary displays correctly
- Fish shell is usable

**Output:**
```
=== All Tests Passed! ===

Installation Summary:
  System files: /usr/share/fedpunk/
  User data:    /root/.local/share/fedpunk/
  Active profile: default
```

### run-all-tests.sh

**Purpose:** Orchestrate full test suite

**Steps:**
1. Run `build-rpm.sh`
2. Run `test-rpm-install.sh`
3. Display unified test results

**Use when:**
- Testing before pushing to main
- Validating changes locally
- Debugging RPM packaging issues

---

## Test Environments

### Fedora 43 (Primary)

Used in CI and recommended for local testing:

```bash
podman run -it --rm -v .:/workspace:z -w /workspace \
  fedora:43 bash test/run-all-tests.sh
```

### Other Fedora Versions

Test on multiple versions if needed:

```bash
# Fedora 40
podman run -it --rm -v .:/workspace:z -w /workspace \
  fedora:40 bash test/run-all-tests.sh

# Fedora 41
podman run -it --rm -v .:/workspace:z -w /workspace \
  fedora:41 bash test/run-all-tests.sh
```

### Devcontainer

`.devcontainer/devcontainer.json` provides a ready-to-use Fedora environment:

1. Open in VS Code
2. Command Palette → "Reopen in Container"
3. Run tests: `bash test/run-all-tests.sh`

---

## Troubleshooting

### Build Fails: "Source not found"

**Cause:** Tarball name doesn't match spec file expectations

**Fix:** Check `fedpunk.spec` lines 2-4 for commit hash macros and line 14 for Source0 path

### Build Fails: "File not found in %install"

**Cause:** Files referenced in spec don't exist in source tree

**Fix:** Verify all files in `%install` section exist in the repository

### Installation Test Fails: "fedpunk: command not found"

**Cause:** RPM didn't install `/usr/bin/fedpunk` wrapper

**Fix:** Check `%install` section in spec (lines 94-107)

### Installation Test Fails: "FEDPUNK_SYSTEM not set"

**Cause:** `/etc/profile.d/fedpunk.sh` not sourced

**Fix:** Manually source in test or check spec lines 72-92

### Permission Errors During Build

**Cause:** Running in non-privileged container

**Fix:** Use `--privileged` flag or run as root in container

---

## CI/CD Workflow

### Development Cycle

```
1. Make changes locally
   ↓
2. Run test/run-all-tests.sh
   ↓
3. Fix any failures
   ↓
4. Commit and push to feature branch
   ↓
5. CI runs tests automatically
   ↓
6. Create PR to main
   ↓
7. CI tests must pass before merge
   ↓
8. Merge to main
   ↓
9. COPR builds new RPM automatically
```

### COPR Integration

When code is merged to `main`:

1. **GitHub Actions** runs RPM tests
2. **GitHub webhook** notifies COPR
3. **COPR** builds RPM from main branch
4. **Users** get updates via `dnf update`

**COPR project:** https://copr.fedorainfracloud.org/coprs/hinriksnaer/fedpunk-unstable/

---

## Contributing

### Before Submitting PR

1. **Run tests locally:**
   ```bash
   bash test/run-all-tests.sh
   ```

2. **Verify changes don't break existing tests**

3. **Add new tests if adding features:**
   - Update `test-rpm-install.sh` with new validation
   - Document expected behavior

4. **Check CI passes on your branch**

### Adding New Tests

To add a test to `test-rpm-install.sh`:

```bash
# Test N: Check new feature
echo ""
echo "✓ Test N: New feature validation"
if [ -f "/expected/file" ]; then
    echo "  ✓ Feature works"
else
    echo "  ✗ Feature failed"
    exit 1
fi
```

Follow the existing pattern for consistency.

---

## Files

- **build-rpm.sh** - Builds RPM package
- **test-rpm-install.sh** - Tests installation
- **run-all-tests.sh** - Runs full test suite
- **README.md** - This file

---

## Next Steps

After local testing passes:

1. **Push to feature branch** and verify CI
2. **Create PR to main**
3. **Wait for CI approval**
4. **Merge** when ready
5. **COPR automatically builds** new RPM
6. **Users get updates** via `dnf update`

---

**Questions?** Check the [COPR installation docs](../docs/installation/copr-unstable.md) or [open an issue](https://github.com/hinriksnaer/Fedpunk/issues).
