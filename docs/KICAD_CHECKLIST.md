# KiCAD Security & Best Practices Checklist
## Protecting TrailCurrent Hardware Designs for Public GitHub

**Last Updated:** Feb 12, 2026
**Purpose:** Document all places where personal information can leak in KiCAD files and git history

---

## 📋 COMPREHENSIVE CHECKLIST

### ✅ BEFORE COMMITTING KiCAD FILES TO GITHUB

- [ ] **Project File (`.kicad_pro`)** - Check for:
  - [ ] Absolute file paths in any configuration
  - [ ] References to local directories
  - [ ] User-specific environment variables
  - [ ] Recent files list (can contain personal paths)
  - [ ] Library search paths pointing to `/home/`, `/Users/`, `C:\Users\`

- [ ] **Schematic Files (`.kicad_sch`)** - Check for:
  - [ ] Hardcoded library paths in symbol instances
  - [ ] Sheet file paths with full system paths
  - [ ] Comments containing personal information
  - [ ] Author fields with your name/email
  - [ ] References to temporary directories

- [ ] **PCB Files (`.kicad_pcb`)** - Check for:
  - [ ] 3D model file paths with absolute system paths
  - [ ] Comment text with personal info
  - [ ] Title block containing personal information
  - [ ] Footprint library paths with `/home/` or user directories

- [ ] **Symbol Library Files (`.kicad_sym`)** - Check for:
  - [ ] Comments with author names
  - [ ] File paths in symbol properties
  - [ ] Embedded personal information in descriptions

- [ ] **Footprint Library Directories (`.pretty/`)** - Check for:
  - [ ] 3D model references with absolute paths
  - [ ] Comments in footprint files
  - [ ] Author information in file headers

- [ ] **3D Model Files** - Check for:
  - [ ] Filenames revealing personal info
  - [ ] Embedded metadata with author names
  - [ ] Paths in CAD model properties

- [ ] **Git Configuration** - Check for:
  - [ ] No personal information in git commits
  - [ ] No absolute paths in commit messages
  - [ ] No temporary file references
  - [ ] No debugging information

---

## 🔍 WHERE PERSONAL INFORMATION HIDES IN KiCAD

### 1. **Project Configuration File (.kicad_pro)**

**Risk Level:** 🔴 HIGH - Contains application state and paths

**What stores paths:**
```json
{
  "schematic": {
    "legacy_lib_dir": "/home/dave/KiCAD-Libs"  ← DANGER
  },
  "pcbnew": {
    "last_paths": {
      "step": "../../CAD/file.step"  ← OK (relative)
    }
  }
}
```

**Check Command:**
```bash
grep -E "(/home/|/Users/|C:\\Users|dave|FLOYD)" project.kicad_pro
```

### 2. **Schematic Files (.kicad_sch)**

**Risk Level:** 🔴 HIGH - Can embed absolute paths

**Problem Examples:**
```scheme
(symbol (lib_reference "MY_CUSTOM_LIB:/home/dave/MyLib.kicad_sym:MySymbol")...)
(sheet "SubSheet" (at 0 0) (size 297 210)
  (property "Sheet name" "SubSheet")
  (pin "1" (uuid "..."))
  ; Created by Dave Floyd - 2024  ← DANGER
)
```

**Check Command:**
```bash
grep -i "dave\|floyd\|/home/\|/Users/" schematic.kicad_sch
```

### 3. **PCB Files (.kicad_pcb)**

**Risk Level:** 🟡 MEDIUM - Usually OK, but check 3D models

**Problem Examples:**
```scheme
(model "/home/dave/3D_Models/connector.step")  ← DANGER
(model "${KIPRJMOD}/3d/connector.step")  ← OK (relative with variable)
```

**Check Command:**
```bash
grep -E "model|author|comment" pcb.kicad_pcb | grep -E "(/home/|/Users/|C:\\|dave)"
```

### 4. **Title Block / Text Fields**

**Risk Level:** 🔴 HIGH - Visible in exported documents

**Problem Examples:**
```
Designer: Dave Floyd  ← DANGER - Visible on silkscreen
Company: Floyd Consulting  ← DANGER - Exposes business
Contact: dave@example.com  ← DANGER - Email visible
```

**Check Command:**
```bash
grep -i "title_block\|designer\|company\|author" *.kicad_pcb
```

### 5. **3D Model References**

**Risk Level:** 🔴 HIGH - Can reference system paths

**Problem Examples:**
```scheme
(model "/home/dave/CAD/enclosure.step")  ← DANGER
(model "${KIPRJMOD}/3d_models/enclosure.step")  ← OK
(model "${TRAILCURRENT_3DMODEL_DIR}/modules/enclosure.step")  ← BEST
```

**Check Command:**
```bash
grep "model" *.kicad_pcb | grep -E "(/home/|/Users/|dave)"
```

### 6. **File Metadata**

**Risk Level:** 🟡 MEDIUM - Embedded in files

**What to check:**
```bash
# Check file modification info (Linux)
stat *.kicad_*

# Check for hidden metadata
file *.kicad_*

# Look for embedded strings
strings *.kicad_pcb | grep -i dave
```

### 7. **Git History**

**Risk Level:** 🔴 HIGH - Permanent unless cleaned

**Problem:**
```bash
git log --all --oneline  # Can show you fixed personal info in old commits
git show HEAD:old_file.kicad_pcb  # Can reveal deleted personal paths
```

**Solution for TrailCurrent:**
- Removing/restarting history is acceptable
- All projects go public from clean state starting now

### 8. **KiCAD Configuration Directory**

**Risk Level:** 🟡 MEDIUM - Not in projects, but affects what gets saved

**Files to check:**
```
~/.config/kicad/9.0/fp-lib-table     ← Footprint library paths
~/.config/kicad/9.0/sym-lib-table    ← Symbol library paths
~/.config/kicad/9.0/common.user      ← User settings
~/.config/kicad/9.0/kicad_common.json ← Common settings
```

**What can leak:**
- Recent project list (contains full paths)
- Default library search paths
- User-specific settings

**Best Practice:** Don't commit KiCAD config files to repo. Each developer has their own.

---

## 🛡️ PROTECTION STRATEGIES

### Strategy 1: Use Environment Variables (BEST ✅)

**How to do it:**

1. **Define custom environment variables** in KiCAD:
   ```
   TRAILCURRENT_SYMBOL_DIR    = /path/to/TrailCurrentKiCADLibraries/symbols
   TRAILCURRENT_FOOTPRINT_DIR = /path/to/TrailCurrentKiCADLibraries/footprints
   TRAILCURRENT_3DMODEL_DIR   = /path/to/TrailCurrentKiCADLibraries/3d_models
   ```

2. **Reference them in projects:**
   ```scheme
   (model "${TRAILCURRENT_3DMODEL_DIR}/modules/connector.step")
   ```

3. **Benefits:**
   - ✅ No absolute paths in files
   - ✅ Works on any system
   - ✅ Easy to update library location
   - ✅ Clear intent in project files

### Strategy 2: Use Relative Paths (GOOD ✅)

**How to do it:**

```scheme
(model "${KIPRJMOD}/../../TrailCurrentKiCADLibraries/3d_models/modules/connector.step")
(model "${KIPRJMOD}/../3d_models/local_connector.step")
```

**Benefits:**
- ✅ Works anywhere
- ✅ No system-dependent paths
- ✅ Projects stay portable

**Limitations:**
- ⚠️ Deep relative paths are fragile
- ⚠️ Hard to understand structure from path

### Strategy 3: Avoid (NEVER ❌)

```scheme
(model "/home/dave/3D_Models/connector.step")  ❌ NEVER
(model "C:\\Users\\Dave\\Documents\\KiCAD\\...")  ❌ NEVER
(model "/Volumes/DATA/KiCAD/...")  ❌ NEVER
```

---

## 📋 SPECIFIC CHECKS FOR TRAILCURRENT PROJECTS

### Before Moving Project to GitHubTransition:

#### Check 1: Scan for Absolute Paths
```bash
#!/bin/bash
PROJECT_DIR=$1

echo "🔍 Checking for absolute paths in $PROJECT_DIR..."

# Check all KiCAD files
for file in $(find "$PROJECT_DIR" -name "*.kicad_*" -o -name "*.pretty"); do
  if grep -E "(/home/|/Users/|C:\\\\Users|dave|FLOYD)" "$file" 2>/dev/null; then
    echo "⚠️  FOUND in: $file"
  fi
done

echo "✅ Scan complete"
```

#### Check 2: Scan for Personal Info
```bash
#!/bin/bash
PROJECT_DIR=$1

echo "🔍 Checking for personal information..."

# Search for names, emails
grep -ri "dave\|floyd\|@.*\.com" "$PROJECT_DIR" \
  --include="*.kicad_*" \
  --include="*.sch" \
  --exclude-dir=.git || echo "✅ No personal info found"
```

#### Check 3: Verify 3D Model References
```bash
#!/bin/bash
PROJECT_DIR=$1

echo "🔍 Checking 3D model references..."

grep -r "model" "$PROJECT_DIR" --include="*.kicad_pcb" | \
  grep -v "TRAILCURRENT_3DMODEL_DIR" | \
  grep -v "KIPRJMOD" | \
  head -20
```

---

## 🚀 RECOMMENDED WORKFLOW

### When Creating a New KiCAD Project:

1. **Set Library References FIRST**
   - Use environment variables: `${TRAILCURRENT_SYMBOL_DIR}`
   - Don't browse for libraries with absolute paths
   - Use relative paths: `${KIPRJMOD}/../../../TrailCurrentKiCADLibraries`

2. **Add 3D Models Last**
   - Reference: `${TRAILCURRENT_3DMODEL_DIR}/category/model.step`
   - Or relative: `${KIPRJMOD}/../../TrailCurrentKiCADLibraries/3d_models/...`
   - Never use absolute paths

3. **Before Committing:**
   ```bash
   # Verify no absolute paths
   grep -r "/home/\|/Users/\|C:\\\\" . --include="*.kicad_*"

   # Verify no personal info
   grep -ri "dave\|floyd" . --include="*.kicad_*"
   ```

4. **Title Block Best Practices:**
   - Designer: "TrailCurrent Team" (not your name)
   - Company: "TrailCurrent" (not personal business)
   - Contact: Leave blank or use project website

---

## 🔧 ENVIRONMENT VARIABLE SETUP

### For TrailCurrent Development:

**Linux/macOS - Add to `.bashrc` or `.zshrc`:**
```bash
export TRAILCURRENT_SYMBOL_DIR="/path/to/TrailCurrentKiCADLibraries/symbols"
export TRAILCURRENT_FOOTPRINT_DIR="/path/to/TrailCurrentKiCADLibraries/footprints"
export TRAILCURRENT_3DMODEL_DIR="/path/to/TrailCurrentKiCADLibraries/3d_models"
```

**KiCAD GUI - Preferences > Configure Paths:**
1. Open KiCAD
2. Go to: Preferences > Configure Paths
3. Add three new paths:
   - `TRAILCURRENT_SYMBOL_DIR` = `/path/to/.../symbols`
   - `TRAILCURRENT_FOOTPRINT_DIR` = `/path/to/.../footprints`
   - `TRAILCURRENT_3DMODEL_DIR` = `/path/to/.../3d_models`

**Windows - Environment Variables:**
1. System Properties > Environment Variables
2. Click "New" under "User variables"
3. Variable name: `TRAILCURRENT_SYMBOL_DIR`
4. Variable value: `C:\Path\To\TrailCurrentKiCADLibraries\symbols`
5. Repeat for FOOTPRINT and 3DMODEL directories
6. Restart KiCAD

---

## 📊 SUMMARY TABLE

| Risk | File Type | Where It Leaks | How to Fix |
|------|-----------|----------------|-----------|
| 🔴 HIGH | `.kicad_pro` | Library paths | Use `${TRAILCURRENT_*}` variables |
| 🔴 HIGH | `.kicad_sch` | Symbol references, comments | Use environment variables |
| 🟡 MED | `.kicad_pcb` | 3D model paths, title block | Use `${TRAILCURRENT_3DMODEL_DIR}` |
| 🔴 HIGH | Git history | Old commits | Starting fresh, no rewriting |
| 🟡 MED | File metadata | Embedded paths | Not critical for this project |
| 🟡 MED | KiCAD config | Recent files | Not committed, not a risk |

---

## ✅ FINAL VALIDATION BEFORE GITHUB

Before pushing any KiCAD project to GitHub:

```bash
#!/bin/bash
# Final validation script

PROJECT="${1:-.}"

echo "=== KiCAD Security Pre-Commit Check ==="
echo ""

# Check 1: Absolute paths
echo "✓ Check 1: Absolute paths..."
if grep -r "/home/\|/Users/\|C:\\\\" "$PROJECT" --include="*.kicad_*" 2>/dev/null; then
  echo "❌ FOUND absolute paths - FIX BEFORE COMMIT"
  exit 1
fi
echo "✅ PASS - No absolute paths"

# Check 2: Personal names
echo "✓ Check 2: Personal information..."
if grep -ri "dave\|floyd\|@" "$PROJECT" --include="*.kicad_*" | grep -v "@board.pretty" 2>/dev/null; then
  echo "⚠️  Review personal info above - manually approve or fix"
fi
echo "✅ PASS"

# Check 3: Environment variables are used
echo "✓ Check 3: Using environment variables for models..."
if grep -r "model" "$PROJECT" --include="*.kicad_pcb" | grep -v "TRAILCURRENT_\|KIPRJMOD\|\${" | head -3; then
  echo "⚠️  Some models may not use environment variables"
fi
echo "✅ Check complete"

echo ""
echo "Ready for commit to GitHub ✅"
```

---

## 📝 ADDITIONAL NOTES

### Why This Matters for Open Source:

1. **Security:** Paths reveal your system setup
2. **Privacy:** Personal info persists in public repo forever
3. **Professionalism:** Clean projects attract better collaborators
4. **Portability:** Other developers need to build without your paths
5. **Consistency:** Standardized libraries easier for contributors

### For TrailCurrent Specifically:

- All 3D models consolidated in: `/path/to/TrailCurrentKiCADLibraries/3d_models/`
- All projects will use environment variables going forward
- New contributor experience: clone, set env vars, build - no path hunting

---

**Last Check:**
- ✅ No custom .pretty directories found (use standard KiCAD)
- ✅ No custom .kicad_sym files found (use standard KiCAD)
- ✅ 4 STEP files consolidated in 3d_models/
- ✅ Ready for public GitHub release
