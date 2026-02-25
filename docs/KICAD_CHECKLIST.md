# KiCAD Security & Best Practices Checklist
## Protecting TrailCurrent Hardware Designs for Public GitHub

**Purpose:** Document all places where personal information can leak in KiCAD files and git history

---

## Checklist

### Before Committing KiCAD Files to GitHub

- [ ] **Project File (`.kicad_pro`)** - Check for:
  - [ ] Absolute file paths in any configuration
  - [ ] References to local directories
  - [ ] User-specific environment variables
  - [ ] Recent files list (can contain personal paths)
  - [ ] Library search paths with absolute user directories

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
  - [ ] Footprint library paths with absolute user directories

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

---

## Where Personal Information Hides in KiCAD

### 1. Project Configuration File (.kicad_pro)

**Risk Level:** HIGH - Contains application state and paths

**What stores paths:**
```json
{
  "schematic": {
    "legacy_lib_dir": "<absolute-path>/KiCAD-Libs"
  },
  "pcbnew": {
    "last_paths": {
      "step": "../../CAD/file.step"
    }
  }
}
```

The `legacy_lib_dir` should never contain an absolute path. Use environment variables or relative paths.

### 2. Schematic Files (.kicad_sch)

**Risk Level:** HIGH - Can embed absolute paths

**Problem areas:**
- Symbol library references with absolute paths
- Sheet file paths with full system paths
- Comments containing personal information or author names

### 3. PCB Files (.kicad_pcb)

**Risk Level:** MEDIUM - Usually OK, but check 3D models

**Correct vs incorrect 3D model references:**
```scheme
(model "${TRAILCURRENT_3DMODEL_DIR}/connectors/connector.step")  ;; CORRECT
(model "${KIPRJMOD}/3d/connector.step")                          ;; CORRECT (relative)
(model "<absolute-path>/3D_Models/connector.step")               ;; WRONG
```

### 4. Title Block / Text Fields

**Risk Level:** HIGH - Visible in exported documents

**Best practices:**
- Designer: "TrailCurrent Team" (not personal names)
- Company: "TrailCurrent" (not personal business)
- Contact: Leave blank or use project website

### 5. 3D Model References

**Risk Level:** HIGH - Can reference system paths

**Always use environment variables:**
```scheme
(model "${TRAILCURRENT_3DMODEL_DIR}/modules/enclosure.step")  ;; BEST
(model "${KIPRJMOD}/3d_models/enclosure.step")                 ;; OK
```

### 6. Git History

**Risk Level:** HIGH - Permanent unless cleaned

Old commits can reveal previously-committed personal paths. For TrailCurrent, all projects go public from a clean state.

### 7. KiCAD Configuration Directory

**Risk Level:** MEDIUM - Not in projects, but affects what gets saved

These files are local to each developer and should never be committed:
```
~/.config/kicad/9.0/fp-lib-table
~/.config/kicad/9.0/sym-lib-table
~/.config/kicad/9.0/kicad_common.json
```

---

## Protection Strategies

### Strategy 1: Use Environment Variables (Best)

The `install.sh` script automatically sets `TRAILCURRENT_3DMODEL_DIR` in KiCAD's path configuration. Reference models using:

```scheme
(model "${TRAILCURRENT_3DMODEL_DIR}/modules/connector.step")
```

**Benefits:**
- No absolute paths in files
- Works on any system
- Easy to update library location

### Strategy 2: Use Relative Paths (Good)

```scheme
(model "${KIPRJMOD}/../../TrailCurrentKiCADLibraries/3dmodels/TrailCurrent.3dshapes/modules/connector.step")
```

**Limitations:**
- Deep relative paths are fragile
- Hard to understand structure from path

### Strategy 3: Absolute Paths (Never)

Never use absolute paths in any committed file.

---

## Recommended Workflow

### When Creating a New KiCAD Project:

1. **Set Library References FIRST**
   - Run `install.sh` to configure environment variables
   - Don't browse for libraries with absolute paths

2. **Add 3D Models**
   - Reference: `${TRAILCURRENT_3DMODEL_DIR}/category/model.step`
   - Never use absolute paths

3. **Before Committing:**
   - The pre-commit hook will automatically catch absolute paths
   - Run `./setup-hooks.sh` to install the hook

4. **Title Block Best Practices:**
   - Designer: "TrailCurrent Team"
   - Company: "TrailCurrent"
   - Contact: Leave blank or use project website

---

## Environment Variable Setup

### Automated Setup (Recommended)

Run the install script — it handles everything:

```bash
./install.sh
```

This sets `TRAILCURRENT_3DMODEL_DIR` in KiCAD's `kicad_common.json` automatically.

### Manual Setup via KiCAD GUI

1. Open KiCAD
2. Go to: Preferences > Configure Paths
3. Add: `TRAILCURRENT_3DMODEL_DIR` pointing to `<repo>/3dmodels/TrailCurrent.3dshapes`

---

## Summary Table

| Risk | File Type | Where It Leaks | How to Fix |
|------|-----------|----------------|-----------|
| HIGH | `.kicad_pro` | Library paths | Use `${TRAILCURRENT_*}` variables |
| HIGH | `.kicad_sch` | Symbol references, comments | Use environment variables |
| MED | `.kicad_pcb` | 3D model paths, title block | Use `${TRAILCURRENT_3DMODEL_DIR}` |
| HIGH | Git history | Old commits | Starting fresh, no rewriting |
| MED | File metadata | Embedded paths | Not critical for this project |
| MED | KiCAD config | Recent files | Not committed, not a risk |

---

## Final Validation Before GitHub

Before pushing any KiCAD project to GitHub:

1. Install the pre-commit hook: `./setup-hooks.sh`
2. Stage your changes: `git add <files>`
3. The hook runs automatically on `git commit` and blocks any violations
4. Fix any issues reported and re-commit

---

## Additional Notes

### Why This Matters for Open Source:

1. **Security:** Paths reveal your system setup
2. **Privacy:** Personal info persists in public repo forever
3. **Professionalism:** Clean projects attract better collaborators
4. **Portability:** Other developers need to build without your paths
5. **Consistency:** Standardized libraries easier for contributors

### For TrailCurrent Specifically:

- All 3D models consolidated in: `3dmodels/TrailCurrent.3dshapes/`
- All projects use environment variables
- New contributor experience: clone, run `install.sh`, restart KiCAD — done
