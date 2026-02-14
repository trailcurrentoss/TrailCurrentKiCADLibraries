# KiCAD Environment Variables Setup Guide
## Configuring TRAILCURRENT Custom Environment Variables

---

## Overview

TrailCurrent projects use three custom environment variables to reference shared libraries:

| Variable | Purpose | Path |
|----------|---------|------|
| `TRAILCURRENT_SYMBOL_DIR` | Symbol libraries | `.../TrailCurrentKiCADLibraries/symbols` |
| `TRAILCURRENT_FOOTPRINT_DIR` | Footprint libraries | `.../TrailCurrentKiCADLibraries/footprints` |
| `TRAILCURRENT_3DMODEL_DIR` | 3D model files | `.../TrailCurrentKiCADLibraries/3d_models` |

These variables allow projects to reference shared libraries without hardcoding absolute paths.

---

## Setup Instructions by Operating System

### 🐧 Linux / macOS

#### Option 1: Shell Configuration (Recommended)

Add to `~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`:

```bash
# TrailCurrent KiCAD Library Directories
export TRAILCURRENT_SYMBOL_DIR="/path/to/TrailCurrentKiCADLibraries/symbols"
export TRAILCURRENT_FOOTPRINT_DIR="/path/to/TrailCurrentKiCADLibraries/footprints"
export TRAILCURRENT_3DMODEL_DIR="/path/to/TrailCurrentKiCADLibraries/3d_models"
```

**Replace `/path/to/` with your actual path, for example:**

```bash
export TRAILCURRENT_SYMBOL_DIR="/path/to/TrailCurrentKiCADLibraries/symbols"
export TRAILCURRENT_FOOTPRINT_DIR="/path/to/TrailCurrentKiCADLibraries/footprints"
export TRAILCURRENT_3DMODEL_DIR="/path/to/TrailCurrentKiCADLibraries/3d_models"
```

**Or if cloned to home directory:**

```bash
export TRAILCURRENT_SYMBOL_DIR="$HOME/TrailCurrentKiCADLibraries/symbols"
export TRAILCURRENT_FOOTPRINT_DIR="$HOME/TrailCurrentKiCADLibraries/footprints"
export TRAILCURRENT_3DMODEL_DIR="$HOME/TrailCurrentKiCADLibraries/3d_models"
```

**Then reload:**
```bash
source ~/.bashrc  # or ~/.zshrc if using zsh
```

**Verify:**
```bash
echo $TRAILCURRENT_SYMBOL_DIR
# Should output your actual path, e.g.: /path/to/TrailCurrentKiCADLibraries/symbols
```

#### Option 2: KiCAD GUI Configuration (No Shell Required)

1. **Open KiCAD**
2. **Go to:** Preferences → Preferences (or Edit → Preferences)
3. **Navigate to:** Manage Paths (usually in left sidebar)
4. **Click:** "Add" button
5. **Create entries:**

   **First Entry:**
   - Environment Variable: `TRAILCURRENT_SYMBOL_DIR`
   - Path: `/path/to/TrailCurrentKiCADLibraries/symbols`
   - Description: TrailCurrent Symbol Libraries

   **Second Entry:**
   - Environment Variable: `TRAILCURRENT_FOOTPRINT_DIR`
   - Path: `/path/to/TrailCurrentKiCADLibraries/footprints`
   - Description: TrailCurrent Footprint Libraries

   **Third Entry:**
   - Environment Variable: `TRAILCURRENT_3DMODEL_DIR`
   - Path: `/path/to/TrailCurrentKiCADLibraries/3d_models`
   - Description: TrailCurrent 3D Model Libraries

6. **Click:** OK to save
7. **Restart KiCAD** for changes to take effect

---

### 🪟 Windows

#### Option 1: System Environment Variables (Recommended)

1. **Open Settings:**
   - Press `Win + X`
   - Select "System"

2. **Navigate to Environment Variables:**
   - Click "Advanced system settings"
   - Click "Environment Variables" button at bottom

3. **Create New User Variables:**
   - Under "User variables for [YourUsername]", click "New"

   **First Variable:**
   - Variable name: `TRAILCURRENT_SYMBOL_DIR`
   - Variable value: `C:\Users\Dave\Path\To\TrailCurrentKiCADLibraries\symbols`
   - Click OK

   **Second Variable:**
   - Variable name: `TRAILCURRENT_FOOTPRINT_DIR`
   - Variable value: `C:\Users\Dave\Path\To\TrailCurrentKiCADLibraries\footprints`
   - Click OK

   **Third Variable:**
   - Variable name: `TRAILCURRENT_3DMODEL_DIR`
   - Variable value: `C:\Users\Dave\Path\To\TrailCurrentKiCADLibraries\3d_models`
   - Click OK

4. **Click OK** to close Environment Variables dialog
5. **Click OK** to close System Properties
6. **Restart KiCAD** (close completely and reopen)

#### Option 2: KiCAD GUI Configuration

1. Open KiCAD
2. Preferences → Manage Paths
3. Click "Add" and create the three entries (same names and paths as above)
4. Click OK and restart KiCAD

---

### 🍎 macOS (M1/M2/Intel)

**Using Shell (Same as Linux above):**

If using **homebrew cask** KiCAD, add to `~/.zprofile` (macOS default shell is zsh):

```bash
# TrailCurrent KiCAD Environments
export TRAILCURRENT_SYMBOL_DIR="$HOME/Documents/TrailCurrent/KiCADLibraries/symbols"
export TRAILCURRENT_FOOTPRINT_DIR="$HOME/Documents/TrailCurrent/KiCADLibraries/footprints"
export TRAILCURRENT_3DMODEL_DIR="$HOME/Documents/TrailCurrent/KiCADLibraries/3d_models"
```

**Then reload:**
```bash
source ~/.zprofile
```

**If using app bundle directly**, use KiCAD GUI method (Preferences → Manage Paths)

---

## Verification

### ✅ Test That Variables Are Set

**Linux/macOS:**
```bash
# Check all three variables
echo "SYMBOL_DIR: $TRAILCURRENT_SYMBOL_DIR"
echo "FOOTPRINT_DIR: $TRAILCURRENT_FOOTPRINT_DIR"
echo "3DMODEL_DIR: $TRAILCURRENT_3DMODEL_DIR"

# Should output paths, not blank
```

**Windows (Command Prompt):**
```cmd
echo %TRAILCURRENT_SYMBOL_DIR%
echo %TRAILCURRENT_FOOTPRINT_DIR%
echo %TRAILCURRENT_3DMODEL_DIR%
```

### ✅ Test That KiCAD Recognizes Variables

1. **Open KiCAD**
2. **Open a TrailCurrent project** (any `.kicad_pro` file)
3. **Check:** Preferences → Manage Paths
4. **Verify:** Your three `TRAILCURRENT_*` variables appear in the list
5. **Open a schematic:** Schematic Editor
6. **Check:** Tools → Footprint Properties (if a footprint exists)
   - Should resolve `${TRAILCURRENT_FOOTPRINT_DIR}` paths correctly
   - If paths show absolute, you may need to reload the project

### ✅ Test 3D Model Loading

1. **Open PCB Editor** on a TrailCurrent project PCB
2. **View → 3D Viewer** (or press Alt+3)
3. **Check:** 3D models should load without errors
4. If you see errors about missing models:
   - Models may use old absolute paths
   - See "Troubleshooting" section below

---

## Using Environment Variables in Projects

### In Schematic (`.kicad_sch`)

Symbol references automatically use KiCAD's standard symbol paths. For custom symbols:

```scheme
(symbol (lib_reference "CUSTOM:/home/dave/lib.kicad_sym:MySymbol")...)
```

Should be updated to use the consolidated library path.

### In PCB (`.kicad_pcb`)

3D models should reference the environment variable:

**Old (Absolute Path - DON'T USE):**
```scheme
(model "/home/dave/3D_Models/connector.step"...)
```

**New (Environment Variable - USE THIS):**
```scheme
(model "${TRAILCURRENT_3DMODEL_DIR}/modules/connector.step"...)
```

**Or (Relative Path - ALSO OK):**
```scheme
(model "${KIPRJMOD}/../../TrailCurrentKiCADLibraries/3d_models/modules/connector.step"...)
```

### In Project (`.kicad_pro`)

Library configurations should use variables:

```json
{
  "pcbnew": {
    "3dview_settings": {
      "modeldir": "${TRAILCURRENT_3DMODEL_DIR}"
    }
  }
}
```

---

## Troubleshooting

### ❌ "Cannot find environment variable"

**Cause:** Variable not set or KiCAD not restarted

**Solution:**
1. Set variable in shell or Windows
2. **Completely close KiCAD** (all windows)
3. **Reopen KiCAD**
4. Check Preferences → Manage Paths to verify variable exists

### ❌ "3D models show as broken/missing"

**Cause:** Projects may still reference old absolute paths

**Solution:**
1. In PCB Editor, select a footprint with 3D model
2. Right-click → Footprint Properties
3. Check the "3D Models" section
4. If path shows absolute (e.g., `/home/dave/...`), manually update it
5. Change to: `${TRAILCURRENT_3DMODEL_DIR}/modules/filename.step`

### ❌ "Variables work in shell but not in KiCAD"

**Cause:** KiCAD launched before shell variables loaded

**Solution:**
- **Linux/macOS:** Use KiCAD GUI method (Preferences → Manage Paths)
- **Windows:** Use System Environment Variables (not cmd.exe)

### ❌ "I get ~different~ paths on different computers"

**Cause:** Libraries in different locations on each machine

**Solution:**
1. Each developer sets `TRAILCURRENT_*` to THEIR local path
2. Example:
   - Developer A: `/path/to/TrailCurrentKiCADLibraries`
   - Jane: `/home/jane/projects/TrailCurrentKiCADLibraries`
   - Both set `TRAILCURRENT_SYMBOL_DIR` but to different paths
3. KiCAD projects use `${TRAILCURRENT_SYMBOL_DIR}`, so they work on both
4. **This is the whole point** of environment variables!

---

## For Contributors

### When Using TrailCurrent Projects

1. **Clone the KiCAD libraries:**
   ```bash
   git clone git@github.com:trailcurrentoss/TrailCurrentKiCADLibraries.git
   ```

2. **Set environment variables** to point to YOUR cloned `TrailCurrentKiCADLibraries` location
   - See setup instructions above

3. **Open projects in KiCAD** - should work!

---

## For Maintainers

### When Updating Library Paths

If you move the `TrailCurrentKiCADLibraries` directory:

1. **Update environment variables:**
   ```bash
   export TRAILCURRENT_SYMBOL_DIR="/new/path/TrailCurrentKiCADLibraries/symbols"
   ```

2. **That's it!** All projects automatically use new paths

3. **No need to update individual projects** ✅

---

## Reference: Standard KiCAD Variables

For reference, KiCAD provides these built-in variables:

| Variable | Purpose |
|----------|---------|
| `${KICAD_SYMBOL_DIR}` | Standard KiCAD symbols |
| `${KICAD_FOOTPRINT_DIR}` | Standard KiCAD footprints |
| `${KICAD_3DMODEL_DIR}` | Standard 3D models |
| `${KIPRJMOD}` | Project directory (in project files) |
| `${KICAD9_SYMBOL_DIR}` | KiCAD 9.x symbols |
| `${KICAD9_FOOTPRINT_DIR}` | KiCAD 9.x footprints |

You can use any combination with TrailCurrent variables.

---

## Summary

✅ **Environment variables are set** → KiCAD sees them
✅ **Projects use `${TRAILCURRENT_*}` paths** → Portable everywhere
✅ **Each developer sets their own paths** → Works for everyone
✅ **No absolute paths in projects** → Safe for GitHub

You're ready to work with TrailCurrent hardware designs!
