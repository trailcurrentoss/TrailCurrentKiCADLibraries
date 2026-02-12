# Supplier Parts Integration - Complete System

**Overview:** TrailCurrent projects support multiple sourcing strategies through standardized supplier part number fields in KiCAD schematics.

---

## What's Included

### 📄 Documentation Files

1. **[SUPPLIER_PART_NUMBERS.md](SUPPLIER_PART_NUMBERS.md)** (Main Reference)
   - What supplier part numbers are and why they matter
   - How to add fields in KiCAD (3 methods)
   - LCSC/Mouser/DigiKey part number formats
   - Best practices for keeping numbers in sync
   - Troubleshooting guide

2. **[BOM_ASSEMBLY_WORKFLOW.md](BOM_ASSEMBLY_WORKFLOW.md)** (Practical Guide)
   - Step-by-step workflows for JLCPCB assembly
   - Mouser/DigiKey alternative sourcing
   - Bill of materials generation
   - Complete example project walkthrough
   - Helper scripts for automation

### 🔧 Helper Tools

3. **[add_supplier_fields.py](add_supplier_fields.py)**
   - Automated script to add supplier fields to schematics
   - Matches components by Value + Footprint to parts database
   - Creates backup before modifying
   - Reports matched and unmatched components

   **Usage:**
   ```bash
   python3 add_supplier_fields.py design.kicad_sch parts_database.csv
   ```

### 📊 Parts Databases

4. **[jst_xh_connector_parts.csv](jst_xh_connector_parts.csv)**
   - Pre-populated database of JST XH connector variants
   - Includes all 1-20 pin configurations
   - Both vertical (B-series) and horizontal (S-series)
   - Mouser and DigiKey part numbers for all variants
   - Ready to use with `add_supplier_fields.py`

---

## Standard Field Names

Use these exactly in all TrailCurrent projects:

| Field | Supplier | Example | Purpose |
|-------|----------|---------|---------|
| `LCSC_PART` | LCSC / JLC Electronics | `C0012345` | Automated JLCPCB assembly |
| `MOUSER_PART` | Mouser Electronics | `511-10KSMTR` | Alternative sourcing |
| `DIGIKEY_PART` | Digi-Key | `10KSMTR-ND` | Alternative sourcing |

---

## Quick Start (5 Minutes)

### For a New Project

1. **Create schematic normally in KiCAD**

2. **Add supplier fields to a few components:**
   ```bash
   # Option A: Use automation script
   python3 add_supplier_fields.py my-project.kicad_sch jst_xh_connector_parts.csv
   
   # Option B: Manual in KiCAD GUI
   # Double-click component → Edit Fields → Add LCSC_PART, MOUSER_PART, DIGIKEY_PART
   ```

3. **Generate BOM:**
   - KiCAD Schematic → Tools → Generate Bill of Materials
   - Include columns: Reference, Quantity, Value, LCSC_PART, MOUSER_PART, DIGIKEY_PART
   - Export as CSV

4. **For JLCPCB Assembly:**
   - Extract LCSC_PART column from BOM
   - Upload to JLCPCB with Gerber files and CPL
   - Automated assembly!

### For Existing Projects

1. **Back up your schematic**
2. **Run automation script to add fields**
3. **Review unmatched components**
4. **Manually add LCSC codes for unmatched parts**
5. **Generate and test BOM**

---

## Sourcing Strategies

### Strategy 1: JLCPCB Assembly (Cheapest for small runs)

✅ **Cost:** $2-10 per PCB including components and assembly  
✅ **Timeline:** 3-5 days  
✅ **Best for:** Prototypes, small production runs  
❌ **Limitation:** Limited to in-stock LCSC parts  

**Workflow:**
1. Fill `LCSC_PART` field for all components
2. Generate BOM with LCSC codes
3. Upload to JLCPCB
4. Done!

### Strategy 2: Mouser (Faster shipping, good availability)

✅ **Cost:** Usually 20-50% more than JLCPCB  
✅ **Timeline:** 1-2 days (US mainland)  
✅ **Best for:** When LCSC is out of stock  
❌ **Limitation:** Requires you to assemble PCB  

**Workflow:**
1. Fill `MOUSER_PART` field
2. Export BOM
3. Create Mouser shopping list
4. Order and assemble yourself

### Strategy 3: DigiKey (Best availability worldwide)

✅ **Cost:** Usually most expensive  
✅ **Timeline:** 2-7 days worldwide  
✅ **Best for:** Hard-to-find components  
❌ **Limitation:** Highest per-unit cost  

**Workflow:**
1. Fill `DIGIKEY_PART` field
2. Export BOM with DigiKey codes
3. Create shopping list
4. Order from DigiKey

### Strategy 4: Hybrid (Use all three)

✅ **Cost:** Compare and choose best for each component  
✅ **Timeline:** Varies by component  
✅ **Best for:** Cost optimization  

**Workflow:**
1. Fill ALL three fields for each component
2. Generate BOM with all suppliers
3. Create cost comparison spreadsheet
4. Choose best supplier per component
5. Create three separate shopping lists

---

## Integration with TrailCurrent

### In Hardware Projects

```
TrailCurrentMyProject/
├── EDA/
│   └── my-project/
│       ├── my-project.kicad_sch          ← Add LCSC/Mouser/DigiKey fields
│       ├── BOM.csv                       ← Generated from schematic
│       └── BOM_JLCPCB.csv                ← JLCPCB-formatted for assembly
└── firmware/
    └── ...
```

### In Firmware Projects (Optional)

If your firmware project needs to document hardware it runs on:

```
FirmwareProject/
├── firmware/
├── hardware_bom/                         ← Reference BOMs
│   ├── TrailCurrentGpsModule_BOM.csv
│   └── TrailCurrentTempSensor_BOM.csv
└── README.md                             ← Links to hardware projects
```

---

## Workflow Examples

### Example 1: New TrailCurrent Module

```bash
# 1. Design new hardware module in KiCAD
# 2. Add components to schematic (use generic symbols)
# 3. Run automation to add supplier fields:

python3 add_supplier_fields.py \
    my-new-module.kicad_sch \
    jst_xh_connector_parts.csv

# 4. Manually add LCSC codes for remaining components:
#    - Open https://jlcpcb.com/parts
#    - Search each unmatched component
#    - Copy LCSC code into schematic
#    - Repeat for Mouser and DigiKey

# 5. Generate BOM and upload to JLCPCB
```

### Example 2: Sourcing from Multiple Suppliers

```bash
# 1. Generate complete BOM with all three supplier columns

# 2. Open in spreadsheet (LibreOffice Calc, Excel)

# 3. Create comparison columns:
#    | Component | LCSC_Price | Mouser_Price | DigiKey_Price | Chosen |
#    
# 4. Use VLOOKUP or manual lookups to fill prices

# 5. Color-code best option per component

# 6. Export as separate shopping lists:
cat BOM.csv | awk -F, '$4 == "best"' > shopping_lcsc.csv
cat BOM.csv | awk -F, '$5 == "best"' > shopping_mouser.csv
cat BOM.csv | awk -F, '$6 == "best"' > shopping_digikey.csv
```

### Example 3: Updating Parts for Availability

```bash
# SCENARIO: LCSC part goes out of stock

# 1. Verify:
#    https://jlcpcb.com/parts search for C0012345
#    Status: Out of Stock

# 2. Find alternative:
#    https://jlcpcb.com/parts search "10k 0805"
#    Find in-stock variant: C9999999

# 3. Update in schematic:
#    Open my-project.kicad_sch
#    Find R1-R5 (all 10k resistors)
#    Double-click → Edit Fields
#    Change LCSC_PART from C0012345 to C9999999

# 4. Document in schematic:
#    Add note: "Substituted C0012345→C9999999 due to stock"

# 5. Regenerate BOM and test on JLCPCB
```

---

## File Organization

After implementing supplier parts system:

```
/path/to/TrailCurrentKiCADLibraries/
├── README.md                           ← User guide
├── KICAD_CHECKLIST.md                  ← Security best practices
├── KICAD_ENVIRONMENT_SETUP.md          ← Environment variables
├── PROJECT_MIGRATION_GUIDE.md          ← How to copy projects
├── CONNECTOR_CONSOLIDATION_SUMMARY.md  ← JST XH connectors
│
├── SUPPLIER_PART_NUMBERS.md            ← ⭐ NEW: Main reference
├── BOM_ASSEMBLY_WORKFLOW.md            ← ⭐ NEW: Practical guide
├── SUPPLIER_PARTS_README.md            ← ⭐ NEW: This file
│
├── add_supplier_fields.py              ← ⭐ NEW: Automation script
├── jst_xh_connector_parts.csv          ← ⭐ NEW: JST parts database
│
├── symbols/                            ← Symbol libraries
├── footprints/                         ← Footprint libraries
│   └── connectors/                     ← JST XH footprints
└── 3d_models/                          ← 3D models
    └── connectors/                     ← JST XH 3D models
```

---

## Next Steps

### Phase 1: Setup (Optional but Recommended)

- [ ] Read [SUPPLIER_PART_NUMBERS.md](SUPPLIER_PART_NUMBERS.md)
- [ ] Read [BOM_ASSEMBLY_WORKFLOW.md](BOM_ASSEMBLY_WORKFLOW.md)
- [ ] Understand the three sourcing strategies
- [ ] Test `add_supplier_fields.py` on a sample project

### Phase 2: Implementation

- [ ] Create parts databases for commonly used components
  - Resistors (common values, 0603/0805 SMD)
  - Capacitors (100nF, 1µF, 10µF ceramic/electrolytic)
  - ICs (ESP32-S3, common sensors, etc.)
- [ ] Add automation script to each TrailCurrent project folder
- [ ] Update existing projects with supplier fields

### Phase 3: Production

- [ ] Use JLCPCB for high-volume assembly
- [ ] Use Mouser/DigiKey for prototypes
- [ ] Track which suppliers work best for each part type
- [ ] Build corporate history of preferred parts

---

## Benefits

### For You (Designer)

✅ **Single source of truth** - All supplier options in schematic  
✅ **Easy substitutions** - Change one field when parts unavailable  
✅ **Cost optimization** - Compare suppliers in spreadsheet  
✅ **Automation** - Scripts handle field addition  
✅ **Documentation** - Non-technical people can order from BOM  

### For Contributors

✅ **Clear sourcing** - No guessing which connectors to use  
✅ **Fast ordering** - Just copy LCSC code to JLCPCB  
✅ **Flexibility** - Can source from preferred supplier  
✅ **Professional** - Shows thoughtful design process  

### For JLCPCB

✅ **Faster assembly** - Pre-populated with LCSC codes  
✅ **Fewer delays** - Already verified parts are in stock  
✅ **Fewer errors** - Automated BOM parsing  

---

## Support

### Common Questions

**Q: Do I have to use all three suppliers?**  
A: No! Use just LCSC_PART for JLCPCB-only projects. Add others for flexibility.

**Q: What if a part isn't in LCSC?**  
A: Use MOUSER_PART and DIGIKEY_PART, or find LCSC equivalent.

**Q: Can I use this for non-TrailCurrent projects?**  
A: Absolutely! The system works for any KiCAD project.

**Q: How do I keep part numbers updated?**  
A: Mark fields as "editable in footprint properties" so they appear in PCB Editor.

### Troubleshooting

See [SUPPLIER_PART_NUMBERS.md - Troubleshooting](SUPPLIER_PART_NUMBERS.md#troubleshooting)

---

## Version History

- **v1.0** (Feb 12, 2026) - Initial release
  - LCSC, Mouser, DigiKey field standardization
  - JST XH connector parts database
  - add_supplier_fields.py automation script
  - BOM/assembly workflow documentation

---

## License

These documents and scripts are provided as-is for TrailCurrent projects.  
Feel free to adapt for your own projects!

---

**Ready to use supplier part numbers in your TrailCurrent projects!** 🚀

Start with [SUPPLIER_PART_NUMBERS.md](SUPPLIER_PART_NUMBERS.md) for concepts, then [BOM_ASSEMBLY_WORKFLOW.md](BOM_ASSEMBLY_WORKFLOW.md) for practical steps.

