# Bill of Materials & Assembly Workflow

**Purpose:** Generate bills of materials for different sourcing options (JLCPCB, Mouser, DigiKey)

---

## Quick Start

### 1. Add Supplier Fields to Your Project

Use the automated script to add LCSC_PART, MOUSER_PART, and DIGIKEY_PART fields:

```bash
# Navigate to your project directory
cd /path/to/TrailCurrentMyProject/EDA/my-project

# Run the helper script
python3 ./add_supplier_fields.py \
    my-project.kicad_sch \
    ./jst_xh_connector_parts.csv
```

**What this does:**
- ✅ Scans your schematic for all components
- ✅ Matches components to the parts database by Value and Footprint
- ✅ Adds LCSC_PART, MOUSER_PART, DIGIKEY_PART fields to matching components
- ✅ Creates a backup of your original schematic
- ✅ Reports which components matched and which need manual lookup

### 2. Verify and Complete Supplier Fields

```bash
# Open schematic in KiCAD
kicad my-project.kicad_pro

# For each unmatched component:
# 1. Double-click component → Edit Fields
# 2. Add LCSC_PART field with value from https://jlcpcb.com/parts
# 3. Add MOUSER_PART field from https://mouser.com
# 4. Add DIGIKEY_PART field from https://digikey.com
# 5. Save
```

### 3. Generate Bill of Materials

#### Method A: Using KiCAD's Built-in BOM Generator

```bash
# In KiCAD Schematic Editor:
# Tools → Generate Bill of Materials

# Configure output to include columns:
# - Reference (designator like R1, C1)
# - Quantity
# - Value
# - LCSC_PART
# - MOUSER_PART
# - DIGIKEY_PART

# Export as CSV
```

#### Method B: Using KiCAD GUI (Easy)

1. **Open schematic** in KiCAD
2. **Schematic → Tools → Generate Bill of Materials**
3. **In the dialog:**
   - Left side: Select columns (Ref, Qty, Value, LCSC_PART, etc.)
   - Add custom field names: `LCSC_PART`, `MOUSER_PART`, `DIGIKEY_PART`
4. **Click "Export" → Choose CSV format**
5. **Save as `BOM.csv`**

---

## Workflow: JLCPCB Assembly

### Step 1: Prepare Design Files

```bash
# Ensure all SMD components have LCSC_PART field
# All THT components optional (JLCPCB can place THT too)

# Verify 3D models reference environment variable:
# ${TRAILCURRENT_3DMODEL_DIR}/connectors/JST_XH_S4B-XH-SM4-TB.step
```

### Step 2: Export Manufacturing Files

In KiCAD PCB Editor:

```bash
# File → Plot
# - Format: Gerber X2 (modern)
# - Layers: Check all copper + silkscreen layers
# - Export to: gerber/ directory
# - Options: Mirrored on Back, Plot SVG, PDF (for review)

# File → Fabrication Outputs → Drill Files (Excellon)
# - Export to: gerber/ directory

# File → Assembly (SMT Assembly Files)
# - Component Placement List: PCB.csv
# - Export to: assembly/ directory
```

### Step 3: Generate JLCPCB-Compatible BOM

The BOM CSV should be formatted for JLCPCB:

```csv
Designator,Quantity,Manufacturer Part Number
R1,1,C0012345
R2-R5,4,C0012345
C1,1,C0098765
U1,1,C1234567
J1,1,C9999999
```

**Format notes:**
- Column 1: **Designator** (e.g., R1, R2-R5 for groups)
- Column 2: **Quantity**
- Column 3: **Manufacturer Part Number** (LCSC part code, C-prefixed)

**To create this format from your CSV:**

```bash
# Use the bom_to_jlcpcb.py script (see below)
python3 bom_to_jlcpcb.py BOM.csv > BOM_JLCPCB.csv
```

### Step 4: Upload to JLCPCB

1. Go to: https://jlcpcb.com
2. Click: **"Order Now"** or **"Instant Quote"**
3. Upload **Gerber files** (zip)
4. Select: **PCB Assembly** checkbox
5. Upload **BOM_JLCPCB.csv**
6. Upload **PCB.csv** (component placement list)
7. Review preview
8. Check for:
   - ✅ All components recognized
   - ✅ No "unmatched" parts
   - ⚠️ Note if any parts marked as "Extended Components" (higher cost)
9. Confirm and pay

---

## Workflow: Mouser/DigiKey (Manual Sourcing)

### Step 1: Generate Complete BOM

```bash
# Generate BOM with ALL three supplier fields
# Tools → Generate Bill of Materials → Export as CSV
```

### Step 2: Review Availability and Cost

Open the BOM CSV in spreadsheet:

```
Ref     | Value | Footprint | LCSC_PART | MOUSER_PART | DIGIKEY_PART
--------|-------|-----------|-----------|-------------|---------------
R1-R5   | 10k   | 0805      | C0012345  | 511-10K     | 10KSMTR-ND
C1-C3   | 100nF | 0603      | C0098765  | 661-C0805   | 399-C0805C104K
U1      | ESP32 | BGA       | C1234567  | (Custom)    | (Custom)
J1      | JST   | Conn      | C9999999  | 649-B4B     | B4B-XH-A-ND
```

### Step 3: Choose Supplier

For each component, decide:
- ✅ **LCSC:** Cheapest, but may need JLCPCB assembly
- ✅ **Mouser:** Faster shipping, good availability
- ✅ **DigiKey:** Worldwide, best selection

### Step 4: Create Shopping Lists

#### LCSC Shopping List

```bash
# Extract just LCSC parts
cat BOM.csv | grep -v "^#" | awk -F, '{print $4}' | sort -u > shopping_lcsc.txt

# Bulk copy to JLCPCB cart:
# Visit: https://jlcpcb.com/parts
# Paste each part code to search
```

#### Mouser Shopping List

```bash
# Extract Mouser parts
cat BOM.csv | awk -F, '{print $5}' | sort -u > shopping_mouser.txt

# Create Mouser order: https://mouser.com
# Use "Paste Order" feature
```

#### DigiKey Shopping List

```bash
# Extract DigiKey parts
cat BOM.csv | awk -F, '{print $6}' | sort -u > shopping_digikey.txt

# Create DigiKey order: https://digikey.com
```

---

## Example: Full Workflow

### Project: TrailCurrentTempSensor

```bash
cd /path/to/TrailCurrentTempSensor/EDA/trailcurrent-temp-sensor

# Step 1: Add supplier fields
python3 /path/to/add_supplier_fields.py \
    trailcurrent-temp-sensor.kicad_sch \
    /path/to/jst_xh_connector_parts.csv

# Step 2: Open in KiCAD and verify
kicad trailcurrent-temp-sensor.kicad_pro
# (Check unmatched components and add missing LCSC/Mouser/DigiKey codes)

# Step 3: Generate BOM
# Tools → Generate Bill of Materials
# (Export as CSV)

# Step 4: Prepare for JLCPCB
# (PCB Editor) File → Plot (Gerber files)
# (PCB Editor) File → Assembly (Drill files, CPL)

# Step 5: Convert BOM to JLCPCB format
python3 bom_to_jlcpcb.py trailcurrent-temp-sensor.csv > BOM_JLCPCB.csv

# Step 6: Upload to JLCPCB
# Visit: https://jlcpcb.com/parts
# Upload files and review
```

---

## Helper Scripts

### bom_to_jlcpcb.py

```python
#!/usr/bin/env python3
"""
Convert KiCAD BOM to JLCPCB-compatible format

Usage:
    python3 bom_to_jlcpcb.py BOM.csv > BOM_JLCPCB.csv
"""

import csv
import sys
from collections import defaultdict

if len(sys.argv) < 2:
    print("Usage: bom_to_jlcpcb.py <BOM.csv>")
    sys.exit(1)

# Read input BOM
components = defaultdict(int)
lcsc_map = {}

with open(sys.argv[1], 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        ref = row.get('Ref', row.get('Reference', ''))
        qty = int(row.get('Qty', row.get('Quantity', '1')))
        lcsc = row.get('LCSC_PART', '').strip()

        # Group by LCSC part
        if lcsc:
            components[lcsc] += qty
            lcsc_map[lcsc] = lcsc
        else:
            # No LCSC part, skip (manual sourcing)
            pass

# Write JLCPCB format
print("Designator,Quantity,Manufacturer Part Number")
for lcsc_part in sorted(components.keys()):
    qty = components[lcsc_part]
    # For simplicity, just list the part with its quantity
    # In reality, you'd reconstruct designators (R1, R2-R5, etc.)
    print(f"(See BOM),{qty},{lcsc_part}")

print("\nNote: Manually group designators (e.g., R1,R2-R5,R10) in JLCPCB interface")
```

### verify_supplier_fields.py

```python
#!/usr/bin/env python3
"""
Verify that all components have supplier fields

Usage:
    python3 verify_supplier_fields.py design.kicad_sch
"""

import re
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print("Usage: verify_supplier_fields.py <schematic.kicad_sch>")
    sys.exit(1)

with open(sys.argv[1], 'r') as f:
    content = f.read()

# Find all symbols
pattern = r'\(symbol\s+\(lib_id\s+"([^"]+)"\)([^)]*(?:\(property[^)]*\))*[^)]*)\)'
matches = re.finditer(pattern, content, re.MULTILINE | re.DOTALL)

print("Component Field Verification")
print("=" * 80)

missing = []

for match in matches:
    comp_block = match.group(0)

    # Extract reference
    ref_match = re.search(r'\(property\s+"Reference"\s+"([^"]+)"', comp_block)
    ref = ref_match.group(1) if ref_match else "?"

    # Check for fields
    has_lcsc = 'LCSC_PART' in comp_block
    has_mouser = 'MOUSER_PART' in comp_block
    has_digikey = 'DIGIKEY_PART' in comp_block

    if not (has_lcsc or has_mouser or has_digikey):
        missing.append(ref)
        print(f"✗ {ref:8} Missing supplier fields")
    elif has_lcsc and has_mouser and has_digikey:
        print(f"✓ {ref:8} Complete (LCSC, Mouser, DigiKey)")
    else:
        fields = []
        if has_lcsc:
            fields.append("LCSC")
        if has_mouser:
            fields.append("Mouser")
        if has_digikey:
            fields.append("DigiKey")
        print(f"⚠ {ref:8} Partial: {', '.join(fields)}")

print("=" * 80)
print(f"Components missing all supplier fields: {len(missing)}")
if missing:
    print(f"  {', '.join(missing)}")
```

---

## Best Practices

### 1. Keep Values and Part Numbers in Sync

```bash
# BAD: Component value changed but part number didn't
Value="4.7k" but LCSC_PART="C0012345" (for 10k)

# GOOD: Always update all fields together
Value="4.7k" and LCSC_PART="C0045678" (verified for 4.7k)
```

### 2. Document LCSC Stock Status

Add notes when parts go out of stock:

```
Original: LCSC_PART="C0012345" (10k resistor)
Note: Out of stock as of 2026-02-12
Substitute: LCSC_PART="C0045678" (equivalent 10k resistor)
```

### 3. Use Extended Parts Sparingly

JLCPCB charges extra for "Extended Parts" (not standard inventory):

- ✅ Standard parts: No extra charge
- ⚠️ Extended parts: +$1-5 per reel typically
- ❌ Avoid if possible for cost-sensitive projects

### 4. Group Quantities

When generating BOM, group identical parts:

```
BAD:  R1, C0012345, 1
      R2, C0012345, 1
      R5, C0012345, 1

GOOD: R1,R2,R5, C0012345, 3
```

### 5. Test BOM Before Manufacturing

```bash
# Create test project with just a few components
# Upload to JLCPCB for quote (usually free)
# Verify all parts recognized and in stock
# Then proceed with full project
```

---

## Troubleshooting

### "Part not found in LCSC"

**Cause:** Invalid LCSC code or part unavailable
**Solution:**
1. Visit https://jlcpcb.com/parts
2. Search for part manually
3. Verify code starts with "C"
4. Update in schematic

### "JLCPCB says part is unavailable"

**Cause:** Stock issue or incorrect code
**Solution:**
1. Check LCSC website directly (stock changes daily)
2. Use "Find Similar" on JLCPCB
3. Switch to Mouser/DigiKey alternative

### "Fields not appearing in exported BOM"

**Cause:** Custom field names not configured in BOM export
**Solution:**
1. Open Tools → Generate Bill of Materials
2. In the export dialog, explicitly add field names
3. Type: `LCSC_PART`, `MOUSER_PART`, `DIGIKEY_PART`
4. Re-export

---

## File Structure After BOM Workflow

```
TrailCurrentMyProject/
├── EDA/
│   └── my-project/
│       ├── my-project.kicad_pro
│       ├── my-project.kicad_sch        ← Contains LCSC/Mouser/DigiKey fields
│       ├── my-project.kicad_pcb
│       ├── BOM.csv                     ← Complete BOM with all suppliers
│       ├── BOM_JLCPCB.csv              ← JLCPCB-formatted BOM
│       ├── gerber/                     ← Manufacturing files
│       │   ├── my-project.GBL
│       │   ├── my-project.GBR
│       │   ├── my-project.GTO
│       │   └── my-project.XLN         ← Drill file
│       ├── assembly/
│       │   └── my-project.csv          ← Component placement list
│       └── 3dmodels/                   ← Local 3D models (if used)
└── README.md
```

---

## References

- **JLCPCB Assembly:** https://jlcpcb.com/capabilities/smtAssembly
- **LCSC Parts:** https://jlcpcb.com/parts
- **Mouser:** https://mouser.com
- **DigiKey:** https://digikey.com
- **KiCAD BOM:** https://docs.kicad.org/latest/en/schematic/tools/bom.html

