# KiCAD Environment Setup Guide
## Installing TrailCurrent Libraries

---

## Overview

TrailCurrent libraries are installed with a single command:

```bash
./install.sh
```

The script handles everything:
- Adds `TrailCurrentSymbolLibrary` to your global sym-lib-table
- Adds `TrailCurrentFootprints` to your global fp-lib-table
- Sets `TRAILCURRENT_3DMODEL_DIR` in KiCAD's path configuration (`kicad_common.json`)
- Detects KiCAD snap installs and fixes removable-media permissions if needed
- Safe to run multiple times (skips existing entries)
- Works on Linux, macOS, and Windows (Git Bash/MSYS2)

After install, only **two** KiCAD library table entries exist (never needs updating):

| Type | Nickname |
|------|----------|
| Symbol | `TrailCurrentSymbolLibrary` |
| Footprint | `TrailCurrentFootprints` |

---

## Quick Setup

### Step 1: Clone and Install

```bash
git clone git@github.com:trailcurrentoss/TrailCurrentKiCADLibraries.git
cd TrailCurrentKiCADLibraries
./install.sh
```

### Step 2: Restart KiCAD and Verify

Close all KiCAD windows and reopen. Then verify:

1. **Add Symbol** -> search `AP63203` -> should find AP63203WU-7
2. **Add Footprint** -> search `MCP2515` -> should find MCP2515T-ISO
3. **Preferences -> Configure Paths** -> `TRAILCURRENT_3DMODEL_DIR` should appear

---

## Verification

### Test That KiCAD Recognizes the Libraries

1. Open KiCAD
2. **Preferences -> Manage Symbol Libraries** -> look for `TrailCurrentSymbolLibrary`
3. **Preferences -> Manage Footprint Libraries** -> look for `TrailCurrentFootprints`
4. **Preferences -> Configure Paths** -> look for `TRAILCURRENT_3DMODEL_DIR`

### Test 3D Model Loading

1. Open a PCB that uses TrailCurrent footprints
2. **View -> 3D Viewer** (or Alt+3)
3. 3D models should load without errors

---

## Updating Libraries

When new components are added to the repository:

```bash
cd TrailCurrentKiCADLibraries
git pull
```

No reinstall needed. KiCAD reads the library files directly from the repository directory.

---

## Troubleshooting

### "Cannot find environment variable TRAILCURRENT_3DMODEL_DIR"

**Solution:**
1. Open KiCAD -> Preferences -> Configure Paths
2. Add `TRAILCURRENT_3DMODEL_DIR` pointing to `3dmodels/TrailCurrent.3dshapes/`
3. Restart KiCAD

### "Footprint 'TrailCurrentFootprints:...' not found"

**Solution:**
1. Run `./install.sh` to register the library
2. Restart KiCAD completely (close all windows)

### "Variables work in shell but not in KiCAD"

**Cause:** KiCAD was launched before shell variables were loaded, or KiCAD doesn't inherit shell environment on your platform.

**Solution:** Use KiCAD's built-in path configuration (Preferences -> Configure Paths) instead of relying on shell variables.

### "3D models show as missing"

**Cause:** `TRAILCURRENT_3DMODEL_DIR` not set or pointing to wrong directory.

**Solution:** Verify the path in Preferences -> Configure Paths points to:
```
/path/to/TrailCurrentKiCADLibraries/3dmodels/TrailCurrent.3dshapes
```

Not to the old `3d_models/` directory.

### "Different paths on different computers"

This is expected and correct. Each developer sets their own `TRAILCURRENT_3DMODEL_DIR` path based on where they cloned the repository. KiCAD projects use the variable reference `${TRAILCURRENT_3DMODEL_DIR}`, which resolves differently on each machine.

---

## Reference: Standard KiCAD Variables

For reference, KiCAD provides these built-in variables:

| Variable | Purpose |
|----------|---------|
| `${KICAD9_SYMBOL_DIR}` | Standard KiCAD 9.x symbols |
| `${KICAD9_FOOTPRINT_DIR}` | Standard KiCAD 9.x footprints |
| `${KICAD9_3DMODEL_DIR}` | Standard KiCAD 9.x 3D models |
| `${KIPRJMOD}` | Current project directory |

TrailCurrent libraries use the custom `${TRAILCURRENT_3DMODEL_DIR}` variable alongside these standard ones.
