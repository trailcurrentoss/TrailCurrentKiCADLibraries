# TrailCurrent KiCAD Libraries
## Consolidated Symbol, Footprint, and 3D Model Repository

---

## Overview

**TrailCurrentKiCADLibraries** is a consolidated repository containing all reusable KiCAD libraries for the TrailCurrent hardware projects:

- 📦 **Symbol Libraries** - Standard KiCAD symbols
- 📐 **Footprint Libraries** - PCB footprints
- 🎯 **3D Models** - STEP files for 3D visualization and CAM

This repository is designed to:
- ✅ Centralize all hardware design assets
- ✅ Make projects reproducible for contributors
- ✅ Remove personal system paths from project files
- ✅ Enable easy library updates across all projects

---

## Directory Structure

```
TrailCurrentKiCADLibraries/
│
├── symbols/                          # Symbol libraries
│   ├── core/                        # Core components (R, L, C, etc.)
│   ├── connectors/                  # Connector symbols
│   ├── power/                       # Power distribution symbols
│   └── modules/                     # Module symbols (MCUs, etc.)
│
├── footprints/                      # Footprint libraries
│   ├── connectors/                  # Connector footprints
│   ├── passives/                    # Passive component footprints
│   ├── semiconductors/              # IC footprints
│   └── modules/                     # Custom module footprints
│
├── 3d_models/                       # 3D model files
│   ├── connectors/                  # Connector 3D models
│   ├── enclosures/                  # Enclosure models
│   └── modules/                     # Component 3D models
│
├── README.md                        # This file
├── docs/                            # Core documentation
│   ├── KICAD_CHECKLIST.md          # Security & best practices
│   ├── KICAD_ENVIRONMENT_SETUP.md  # Environment setup instructions
│   └── SECURITY.md                 # Pre-commit hook security system
│
├── tools/                           # Optional workflow utilities
│   ├── README.md                   # Tools documentation
│   ├── add_supplier_fields.py      # Automation script (optional)
│   ├── jst_xh_connector_parts.csv  # Parts database (optional)
│   ├── SUPPLIER_PART_NUMBERS.md    # Supplier integration guide
│   ├── BOM_ASSEMBLY_WORKFLOW.md    # Assembly and BOM workflow
│   └── SUPPLIER_PARTS_README.md    # Supplier parts system overview
```

---

## Quick Start

### 1. Clone This Repository

```bash
git clone https://codeberg.org/trailcurrent/TrailCurrentKiCADLibraries.git
```

### 2. Set Environment Variables

**Linux/macOS:**
```bash
export TRAILCURRENT_SYMBOL_DIR="/path/to/TrailCurrentKiCADLibraries/symbols"
export TRAILCURRENT_FOOTPRINT_DIR="/path/to/TrailCurrentKiCADLibraries/footprints"
export TRAILCURRENT_3DMODEL_DIR="/path/to/TrailCurrentKiCADLibraries/3d_models"
```

**Windows:**
```cmd
set TRAILCURRENT_SYMBOL_DIR=C:\Path\To\TrailCurrentKiCADLibraries\symbols
set TRAILCURRENT_FOOTPRINT_DIR=C:\Path\To\TrailCurrentKiCADLibraries\footprints
set TRAILCURRENT_3DMODEL_DIR=C:\Path\To\TrailCurrentKiCADLibraries\3d_models
```

**KiCAD GUI:**
- Preferences → Manage Paths
- Add three new entries with the paths above

See [KICAD_ENVIRONMENT_SETUP.md](docs/KICAD_ENVIRONMENT_SETUP.md) for detailed instructions.

### 3. Open a TrailCurrent Project

```bash
kicad /path/to/TrailCurrentGpsModule/EDA/trailcurrent-gps-module/trailcurrent-gps-module.kicad_pro
```

All libraries should automatically resolve!

---

## Contents Inventory

### 3D Models

Consolidated STEP files from all TrailCurrent hardware modules:

```
3d_models/modules/
├── Pi5CanAndBuckHat.step              (9.6M) - Raspberry Pi CAN adapter
├── TrailCurrentAirQualityModule.step  (4.7M) - Air quality sensor enclosure
├── TrailCurrentTempAndHumiditySensor.step (53K) - Temperature/humidity module
└── trailer-shunt-can-bus.step         (3.8M) - CAN shunt gateway enclosure
```

**Total:** 9.6 MB of 3D models

### Symbols & Footprints

- **Symbol Libraries:** Using standard KiCAD libraries (no custom symbols)
- **Footprint Libraries:** Using standard KiCAD libraries (no custom footprints)
- Future custom components will be added here as needed

---

## Usage in Projects

### Referencing 3D Models

In PCB files (`.kicad_pcb`), reference models using the environment variable:

```scheme
(model "${TRAILCURRENT_3DMODEL_DIR}/modules/connector.step"
  (at (xyz 0 0 0))
)
```

### Adding New 3D Models

1. Place `.step` file in appropriate subfolder:
   - `connectors/` - Connector 3D models
   - `enclosures/` - Enclosure and case models
   - `modules/` - Component and subassembly models

2. Reference in PCB files:
   ```scheme
   (model "${TRAILCURRENT_3DMODEL_DIR}/[category]/[filename].step")
   ```

3. Commit to git and push to GitHub

---

## Contributing

### Adding Custom Symbols

1. Create `.kicad_sym` file in `symbols/[category]/`
2. Design symbol in KiCAD
3. Update `.gitignore` if needed
4. Commit and push to GitHub

### Adding Custom Footprints

1. Create `.pretty` directory in `footprints/[category]/`
2. Design footprint in KiCAD PCB Editor
3. Commit `.kicad_mod` files
4. Push to GitHub

### Adding 3D Models

1. Export STEP file from CAD software (FreeCAD, Fusion 360, etc.)
2. Place in `3d_models/[category]/`
3. Reference in PCB files with `${TRAILCURRENT_3DMODEL_DIR}` variable
4. Commit and push

---

## Security & Privacy

### No Personal Paths

✅ This repository contains **no absolute file paths**
✅ All references use environment variables
✅ Safe to share with contributors worldwide
✅ No personal information in files

### Automated Security Checks

A pre-commit hook automatically prevents commits containing:
- Personal file paths (/media/dave, /home/user, etc.)
- Credentials or secrets (passwords, API keys, tokens)
- Local development files (CLAUDE.md, .claude/)

To enable the hook:
```bash
./setup-hooks.sh
```

See [SECURITY.md](docs/SECURITY.md) for details and [KICAD_CHECKLIST.md](docs/KICAD_CHECKLIST.md) for security best practices.

### Automatic Verification on Commit

The pre-commit hook automatically checks all staged files before committing. No manual verification steps needed!

The hook catches:
- Personal file paths in any staged file
- Credentials or secrets
- Local development files

**Note:** If you need to manually verify (e.g., before the hook is installed):

```bash
# Check for personal paths in KiCAD files
grep -r "/home/\|/Users/\|C:\\\\" . --include="*.kicad_*" \
  && echo "Found personal paths - fix before committing!" || echo "No personal paths found"

# Check for personal names in KiCAD files
grep -ri "dave\|floyd\|@" . --include="*.kicad_*" | grep -v "@board" \
  && echo "Review matches above" || echo "No personal references found"
```

For more information, see [SECURITY.md](docs/SECURITY.md).

---

## Library Dependencies

### Standard KiCAD Libraries

All TrailCurrent projects use standard KiCAD libraries:

- `4xxx.kicad_sym` - Logic chips
- `Amplifier_Operational.kicad_sym` - Op-amps
- `Connector.kicad_sym` - Connectors
- `Device.kicad_sym` - Basic components
- `Interface_CAN_LIN.kicad_sym` - CAN interface
- `MCU_Espressif.kicad_sym` - ESP32 microcontrollers
- `Resistor_SMD.kicad_sym` - Surface mount resistors
- `Capacitor_SMD.kicad_sym` - Surface mount capacitors
- ...and many more standard libraries

These are automatically included with KiCAD installation.

### TrailCurrent Custom Libraries

- `symbols/core/` - Custom symbols (when needed)
- `symbols/connectors/` - Custom connector symbols
- `symbols/power/` - Custom power circuit symbols
- `footprints/*/` - Custom component footprints
- `3d_models/*/` - Custom 3D models

---

## Troubleshooting

### "Cannot find environment variable TRAILCURRENT_*"

**Solution:** See [KICAD_ENVIRONMENT_SETUP.md](docs/KICAD_ENVIRONMENT_SETUP.md)

- Set environment variables in shell or KiCAD GUI
- Restart KiCAD completely
- Check Preferences → Manage Paths

### "3D models not loading in projects"

**Solution:**
1. Open project in KiCAD
2. For each footprint:
   - Right-click → Footprint Properties
   - Check 3D Models tab
   - Verify path uses `${TRAILCURRENT_3DMODEL_DIR}`
3. Save project

---

## For Maintainers

### Adding New 3D Models

```bash
# Copy STEP file to appropriate category
cp /path/to/new_model.step 3d_models/modules/

# Verify it can be referenced
grep -r "new_model" . --include="*.kicad_pcb"

# Commit
git add 3d_models/modules/new_model.step
git commit -m "Add 3D model: new_model for [component]"
git push
```

### Updating Library Paths

If moving library location:

1. **Update environment variables** on all developer machines
2. **No project updates needed** - they use variables!
3. **That's it!** All projects automatically resolve to new location

### Validating Library Integrity

```bash
#!/bin/bash
# Check all 3D models can be referenced

for model in 3d_models/**/*.step; do
  basename=$(basename "$model")
  echo "Checking $basename..."

  # Verify file size is reasonable
  size=$(stat -f%z "$model" 2>/dev/null || stat -c%s "$model")
  if [ "$size" -lt 1000 ]; then
    echo "  ⚠️  Very small file size: $size bytes"
  fi
done

echo "✅ Library validation complete"
```

---

## License

TrailCurrent hardware designs use the appropriate open source hardware license.

See [LICENSE](LICENSE) in the main TrailCurrent repository.

---

## Related Repositories

- [TrailCurrent](https://codeberg.org/trailcurrent) - Main project organization
- [OtaUpdateLibraryWROOM32](https://codeberg.org/trailcurrent/OtaUpdateLibraryWROOM32) - Firmware library
- [TwaiTaskBasedLibraryWROOM32](https://codeberg.org/trailcurrent/TwaiTaskBasedLibraryWROOM32) - CAN library
- [ESP32ArduinoDebugLibrary](https://codeberg.org/trailcurrent/ESP32ArduinoDebugLibrary) - Debug library

---

## Documentation

- [KICAD_CHECKLIST.md](docs/KICAD_CHECKLIST.md) - Security best practices
- [KICAD_ENVIRONMENT_SETUP.md](docs/KICAD_ENVIRONMENT_SETUP.md) - Environment setup instructions
- [SECURITY.md](docs/SECURITY.md) - Pre-commit hook security system

---

## Optional Tools

The `tools/` directory contains optional workflow utilities for manufacturing and ordering:

- **add_supplier_fields.py** - Automation script to add supplier part numbers to schematics
- **jst_xh_connector_parts.csv** - Reference database of JST connector supplier codes
- **Manufacturing guides** - BOM generation, JLCPCB assembly integration, cost optimization

**Important:** These tools are **not required** to use the KiCAD library. They're provided for users who want to integrate supplier part numbers into their manufacturing workflow.

See [tools/README.md](tools/README.md) for details.

---

## Questions?

See the documentation files above or open an issue on GitHub.

Happy designing! 🎯
