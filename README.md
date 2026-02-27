# TrailCurrent KiCAD Libraries
## Consolidated Symbol, Footprint, and 3D Model Repository

Part of the [TrailCurrent](https://trailcurrent.com) open-source vehicle platform.

---

## Overview

**TrailCurrentKiCADLibraries** is a KiCAD Plugin and Content Manager (PCM) compatible library package containing all reusable symbols, footprints, and 3D models for TrailCurrent hardware projects.

This repository is designed to:
- Install with a single script or via KiCAD's PCM
- Centralize all hardware design assets
- Make projects reproducible for contributors
- Remove personal system paths from project files
- Enable easy library updates with `git pull`

---

## Quick Start

### 1. Clone and Install

```bash
git clone git@github.com:trailcurrentoss/TrailCurrentKiCADLibraries.git
cd TrailCurrentKiCADLibraries
./install.sh
```

The install script automatically:
- Registers the symbol library in KiCAD's global sym-lib-table
- Registers the footprint library in KiCAD's global fp-lib-table
- Sets `TRAILCURRENT_3DMODEL_DIR` in KiCAD's path configuration
- Detects snap installs and fixes removable-media permissions if needed

### 2. Restart KiCAD and Verify

1. Restart KiCAD (close all windows, reopen)
2. Add Symbol -> search `AP63203` -> should find AP63203WU-7
3. Add Footprint -> search `MCP2515` -> should find MCP2515T-ISO

### Updating

```bash
cd TrailCurrentKiCADLibraries
git pull
```

No reinstall needed — KiCAD picks up changes automatically.

---

## Directory Structure

```
TrailCurrentKiCADLibraries/
├── metadata.json                              # PCM package metadata
├── install.sh                                 # Library installer script
├── symbols/
│   └── TrailCurrentSymbolLibrary.kicad_sym    # All custom symbols (1 file)
├── footprints/
│   └── TrailCurrentFootprints.pretty/         # All custom footprints (1 library)
│       ├── AP63203WU7.kicad_mod
│       ├── MCP2515T-ISO.kicad_mod
│       ├── SN65HVD230DR.kicad_mod
│       ├── HCM4912000000ABJT.kicad_mod
│       ├── INDM3225X240N.kicad_mod
│       ├── CAN_PLUS_POWER.kicad_mod
│       ├── JST_XH_B*_Vertical.kicad_mod      # JST XH vertical series
│       ├── JST_XH_S*_Horizontal.kicad_mod    # JST XH horizontal series
│       ├── JST_S*B-XH-SM4-TB.kicad_mod       # JST XH SMD series (2-12 pin)
│       ├── ESP32-C6-SuperMini_TH.kicad_mod   # ESP32-C6 SuperMini (through-hole)
│       ├── ESP32-C6-SuperMini_SMD.kicad_mod   # ESP32-C6 SuperMini (SMD)
│       ├── Mini560.kicad_mod                  # Mini560 buck converter module
│       ├── DS-04.kicad_mod                    # 4-position DIP slide switch
│       └── ...                                # 67 footprints total
├── 3dmodels/
│   └── TrailCurrent.3dshapes/                 # 3D models (categorized)
│       ├── connectors/                        # JST XH STEP+WRL, screw terminal
│       ├── ics/                               # SN65HVD230DR, MCP2515, IRF4905
│       ├── modules/                           # Enclosures, MCU modules, sensors
│       ├── passives/                          # Crystal, inductor
│       ├── power/                             # AP63203WU-7
│       └── switches/                          # DS-04 DIP slide switch
├── docs/
│   ├── ADDING_LIBRARIES.md                    # Guide to adding components
│   ├── KICAD_CHECKLIST.md                     # Security best practices
│   ├── KICAD_ENVIRONMENT_SETUP.md             # Environment setup details
│   └── SECURITY.md                            # Pre-commit hook system
├── tools/                                     # Optional workflow utilities
│   ├── README.md
│   ├── add_supplier_fields.py
│   ├── jst_xh_connector_parts.csv
│   ├── SUPPLIER_PART_NUMBERS.md
│   ├── BOM_ASSEMBLY_WORKFLOW.md
│   └── SUPPLIER_PARTS_README.md
├── resources/                                 # PCM package resources
└── LICENSE
```

---

## KiCAD Library Table Entries

After running `install.sh`, only **two** global library entries are needed (the script adds these automatically):

| Type | Nickname | Path |
|------|----------|------|
| Symbol | `TrailCurrentSymbolLibrary` | `<repo>/symbols/TrailCurrentSymbolLibrary.kicad_sym` |
| Footprint | `TrailCurrentFootprints` | `<repo>/footprints/TrailCurrentFootprints.pretty` |

New symbols and footprints are added to these existing libraries — no additional table entries needed.

---

## Contents Inventory

### Symbol Library

`symbols/TrailCurrentSymbolLibrary.kicad_sym` contains all custom symbols:

| Symbol | Description | Footprint |
|--------|-------------|-----------|
| AP63203WU-7 | 3.8-32V DC-DC buck converter (Diodes Inc) | TrailCurrentFootprints:AP63203WU7 |
| ESP32-C6-SuperMini | ESP32-C6 dev board, WiFi 6/BLE 5/Zigbee/Thread | TrailCurrentFootprints:ESP32-C6-SuperMini_TH |
| HCM4912000000ABJT | 12MHz crystal oscillator HC49S SMD (Citizen) | TrailCurrentFootprints:HCM4912000000ABJT |
| MCP2515T-I_SO | Stand-alone CAN controller with SPI (Microchip) | TrailCurrentFootprints:MCP2515T-ISO |
| Mini560 | 5A DC-DC buck converter module, 7-20V to 3.3/5/9/12V | TrailCurrentFootprints:Mini560 |
| S2B-XH-SM4-TB | JST XH 2-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S2B-XH-SM4-TB |
| S3B-XH-SM4-TB | JST XH 3-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S3B-XH-SM4-TB |
| S4B-XH-SM4-TB | JST XH 4-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S4B-XH-SM4-TB |
| S5B-XH-SM4-TB | JST XH 5-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S5B-XH-SM4-TB |
| S6B-XH-SM4-TB | JST XH 6-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S6B-XH-SM4-TB |
| S7B-XH-SM4-TB | JST XH 7-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S7B-XH-SM4-TB |
| S8B-XH-SM4-TB | JST XH 8-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S8B-XH-SM4-TB |
| S9B-XH-SM4-TB | JST XH 9-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S9B-XH-SM4-TB |
| S10B-XH-SM4-TB | JST XH 10-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S10B-XH-SM4-TB |
| S12B-XH-SM4-TB | JST XH 12-pin SMD connector, 2.50mm pitch | TrailCurrentFootprints:JST_S12B-XH-SM4-TB |
| DS-04 | 4-Position DIP slide switch, SPST, 2.54mm pitch | TrailCurrentFootprints:DS-04 |
| SN65HVD230DR | 3.3V CAN transceiver (Texas Instruments) | TrailCurrentFootprints:SN65HVD230DR |

### Footprint Library

`footprints/TrailCurrentFootprints.pretty/` contains 67 footprints:

| Component | Footprint(s) |
|-----------|-------------|
| JST XH Connectors | 46 footprints: 1-20 pin, vertical and horizontal variants |
| SMD JST XH | JST_S{2,3,4,5,6,7,8,9,10,12}B-XH-SM4-TB (10 variants) |
| ESP32-C6 SuperMini | ESP32-C6-SuperMini_TH, ESP32-C6-SuperMini_SMD |
| Mini560 Buck Converter | Mini560 (module footprint) |
| CAN Bus Controller | MCP2515T-ISO (18-SOIC) |
| CAN Transceiver | SN65HVD230DR (8-SOIC) |
| DC-DC Converter | AP63203WU7 (TSOT26) |
| Amazon Buck Converter | AmazonBuckConverter (module footprint) |
| Crystal Oscillator | HCM4912000000ABJT (HC49S SMD) |
| Inductor | INDM3225X240N (3225 SMD) |
| CAN+Power Connector | CAN_PLUS_POWER (4-pad custom) |
| DIP Switch | DS-04 (4-position, DIP-8 through-hole) |

### 3D Models

128 model files (STEP, STP, WRL) in `3dmodels/TrailCurrent.3dshapes/`:

| Directory | Contents |
|-----------|----------|
| `connectors/` | JST XH series (STEP + WRL pairs), JST XH SMD (S2B-S12B-SM4-TB, 10 variants), 4-pin screw terminal |
| `ics/` | SN65HVD230DR, MCP2515T-I_SO, IRF4905STRLPBF |
| `modules/` | Pi5CanAndBuckHat, AirQualityModule, DHT22, ESP32-C6 Super Mini, Mini560, AmazonBuckConverters, Automotive Fuse, trailer-shunt-can-bus |
| `passives/` | HCM4912000000ABJT (crystal), NLV32T-3R9J-EF (inductor) |
| `power/` | AP63203WU-7 |
| `switches/` | DS-04 (4-position DIP slide switch) |

---

## Alternative Install: KiCAD PCM (Install from File)

This repository is structured as a KiCAD PCM package. To install via PCM:

1. Download or clone this repository
2. Zip the repository contents (with `metadata.json` at the root)
3. In KiCAD: **Plugin and Content Manager -> Install from File**
4. Select the zip file

KiCAD will automatically register the symbol library, footprint library, and 3D model paths.

---

## Contributing

See [ADDING_LIBRARIES.md](docs/ADDING_LIBRARIES.md) for detailed step-by-step instructions on adding symbols, footprints, and 3D models.

Quick summary:

- **Symbols:** Import into `TrailCurrentSymbolLibrary.kicad_sym` via the Symbol Editor
- **Footprints:** Save `.kicad_mod` files into `footprints/TrailCurrentFootprints.pretty/`
- **3D Models:** Place `.step` files in `3dmodels/TrailCurrent.3dshapes/[category]/`
- **Always** use `${TRAILCURRENT_3DMODEL_DIR}` for 3D model paths — never absolute paths
- **Always** run the pre-commit hook check before committing

---

## Security & Privacy

### No Personal Paths

This repository contains **no absolute file paths**. All references use environment variables. Safe to share with contributors worldwide.

### Automated Security Checks

A pre-commit hook automatically prevents commits containing:
- Personal file paths (absolute paths to user home or mount directories)
- Credentials or secrets (passwords, API keys, tokens)
- Local development files (CLAUDE.md, .claude/)

To enable the hook:
```bash
./setup-hooks.sh
```

See [SECURITY.md](docs/SECURITY.md) for details and [KICAD_CHECKLIST.md](docs/KICAD_CHECKLIST.md) for security best practices.

---

## Troubleshooting

### "Cannot find environment variable TRAILCURRENT_3DMODEL_DIR"

**Solution:** Add the path variable in KiCAD:
- Preferences -> Configure Paths -> Add:
  - Name: `TRAILCURRENT_3DMODEL_DIR`
  - Path: `/path/to/TrailCurrentKiCADLibraries/3dmodels/TrailCurrent.3dshapes`
- Restart KiCAD

### "Footprint 'TrailCurrentFootprints:...' not found"

**Solution:** Run `./install.sh` to register the library, then restart KiCAD.

### "3D models not loading in projects"

**Solution:**
1. Check that `TRAILCURRENT_3DMODEL_DIR` is set in Preferences -> Configure Paths
2. Verify the path points to `3dmodels/TrailCurrent.3dshapes/`
3. Restart KiCAD

---

## Related Repositories

- [TrailCurrent](https://github.com/trailcurrentoss) - Main project organization
- [OtaUpdateLibraryWROOM32](https://github.com/trailcurrentoss/OtaUpdateLibraryWROOM32) - Firmware library
- [TwaiTaskBasedLibraryWROOM32](https://github.com/trailcurrentoss/TwaiTaskBasedLibraryWROOM32) - CAN library
- [ESP32ArduinoDebugLibrary](https://github.com/trailcurrentoss/ESP32ArduinoDebugLibrary) - Debug library

---

## Documentation

- [ADDING_LIBRARIES.md](docs/ADDING_LIBRARIES.md) - Adding symbols, footprints, and 3D models
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

## License

TrailCurrent hardware designs use the CERN Open Hardware License v2 - Permissive.

See [LICENSE](LICENSE) for details.

---

## Questions?

See the documentation files above or open an issue on GitHub.
