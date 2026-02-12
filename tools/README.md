# Optional Workflow Tools

This folder contains optional utilities for manufacturing and ordering workflows.

These tools are not required to use the KiCAD library. The core symbols, footprints, and 3D models in the main repository work independently for PCB design.

---

## What's Here

### 1. **add_supplier_fields.py**
Automation script to add supplier part numbers to KiCAD schematic files.

- Reads KiCAD `.kicad_sch` files
- Matches components by Value and Footprint
- Adds LCSC_PART, MOUSER_PART, and DIGIKEY_PART fields
- Integrates with the parts database below

**Usage:**
```bash
python3 add_supplier_fields.py my_design.kicad_sch jst_xh_connector_parts.csv
```

### 2. **jst_xh_connector_parts.csv**
Reference database of JST XH connector supplier part numbers across multiple distributors.

- 29+ entries covering JST XH 1-pin through 20-pin variants
- Includes part numbers for:
  - Mouser Electronics
  - DigiKey
  - LCSC (where available)
- Both vertical (B-series) and horizontal (S-series) orientations included
- Ready to use with `add_supplier_fields.py`

### 3. **Documentation**

- **[SUPPLIER_PART_NUMBERS.md](SUPPLIER_PART_NUMBERS.md)** - Complete guide to supplier part number integration
  - How to add fields in KiCAD manually
  - Using the automation script
  - Best practices and troubleshooting

- **[BOM_ASSEMBLY_WORKFLOW.md](BOM_ASSEMBLY_WORKFLOW.md)** - Assembly and BOM generation workflow
  - Quick start (4 simple steps)
  - JLCPCB assembly integration
  - Mouser/DigiKey sourcing alternatives
  - BOM generation methods with examples

- **[SUPPLIER_PARTS_README.md](SUPPLIER_PARTS_README.md)** - System overview
  - Standard field names and formats
  - Multiple sourcing strategies
  - Cost optimization workflows
  - Integration with TrailCurrent projects

---

## When to Use These Tools

Use these utilities if you need to:

**Manufacturing with BOM generation**
- Generate Bill of Materials with supplier part numbers
- Automate supplier field population in schematics

**JLCPCB Assembly Integration**
- Add part numbers for JLCPCB integrated assembly service
- Cost-optimize your BOM with LCSC sourcing

**Multi-supplier Sourcing**
- Track part numbers across Mouser, DigiKey, and LCSC
- Quickly find alternatives when suppliers have stock issues

---

## When You Don't Need These

**Basic PCB Design** - Use the core library without these tools
- Just want symbols and footprints? You're done.
- 3D models? Already included in the main library.

**Manual Part Number Lookup** - You can add supplier fields manually in KiCAD GUI
- Preferences → Manage Symbol Fields
- Add custom fields directly to components

---

## Quick Start: Adding Supplier Fields

### Option 1: Automated (Recommended for JST XH connectors)

```bash
python3 tools/add_supplier_fields.py my_schematic.kicad_sch tools/jst_xh_connector_parts.csv
```

Then open your project in KiCAD to verify fields are added and generate BOM with Tools → Generate BOM.

### Option 2: Manual (For any component)

1. In KiCAD Schematic Editor, select a component
2. Right-click → Properties
3. In the Custom Fields section, add:
   - `LCSC_PART` = part number from LCSC
   - `MOUSER_PART` = part number from Mouser
   - `DIGIKEY_PART` = part number from DigiKey

### Option 3: Parts Database

Use `jst_xh_connector_parts.csv` as a reference spreadsheet:
- Look up exact part numbers manually
- Copy/paste into your KiCAD projects
- Extend the CSV for your own part library

---

## File Structure

```
tools/
├── README.md                          # This file
├── add_supplier_fields.py             # Python automation tool
├── jst_xh_connector_parts.csv         # JST XH parts database
├── SUPPLIER_PART_NUMBERS.md           # Detailed integration guide
├── BOM_ASSEMBLY_WORKFLOW.md           # Manufacturing workflow
└── SUPPLIER_PARTS_README.md           # System overview
```

---

## Dependencies

### For add_supplier_fields.py
- Python 3.6+
- Standard library only (no external dependencies)

### For documentation
- Markdown reader
- KiCAD 6.0+ (recommended)

---

## Example Workflow

### Scenario: Manufacturing with JLCPCB

1. **Design your PCB** using the main library
2. **Use this script** to add LCSC part numbers
   ```bash
   python3 add_supplier_fields.py design.kicad_sch tools/jst_xh_connector_parts.csv
   ```
3. **Generate BOM** with LCSC part numbers
4. **Upload to JLCPCB** for integrated assembly

See [BOM_ASSEMBLY_WORKFLOW.md](BOM_ASSEMBLY_WORKFLOW.md) for complete example.

---

## Extension: Building Your Own Parts Database

The CSV format is simple - you can extend it:

```csv
Designator,Value,Footprint,LCSC_PART,MOUSER_PART,DIGIKEY_PART,Notes
Your_Part_ID,Part Value,Footprint_Name,LCSC_CODE,MOUSER_CODE,DIGIKEY_CODE,Your notes here
```

Then use it with the Python script:
```bash
python3 add_supplier_fields.py your_design.kicad_sch your_parts.csv
```

---

## Troubleshooting

**"No components matched"**
- Verify component Value and Footprint exactly match the CSV
- Component footprint must include library prefix (e.g., `Connector_JST:JST_XH_B4B...`)

**"Script can't find my file"**
- Use full path or ensure files are in the same directory
- Check file permissions

**"Fields not showing in KiCAD"**
- Restart KiCAD completely after running script
- Fields are hidden by default - right-click component to show

For more help, see:
- [SUPPLIER_PART_NUMBERS.md](SUPPLIER_PART_NUMBERS.md) - Complete guide
- [BOM_ASSEMBLY_WORKFLOW.md](BOM_ASSEMBLY_WORKFLOW.md) - Detailed workflow

---

## Summary

The core TrailCurrent KiCAD library (symbols, footprints, 3D models) works great on its own. These tools are optional helpers for users who want to extend their workflow with supplier integration and manufacturing automation.
