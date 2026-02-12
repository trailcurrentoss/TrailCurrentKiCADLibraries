# Supplier Part Numbers - KiCAD Integration Guide

**Purpose:** Add LCSC, Mouser, and DigiKey part numbers to KiCAD schematics for automated assembly and flexible sourcing.

---

## Overview

TrailCurrent projects support multiple sourcing strategies by storing supplier part numbers as custom fields in the schematic. This enables:

- ✅ **JLCPCB Assembly:** Automated PCB assembly with LCSC parts
- ✅ **Flexible Sourcing:** Alternative parts from Mouser or DigiKey
- ✅ **BOM Generation:** Automated bill of materials with part links
- ✅ **Cost Comparison:** Easy switching between suppliers

---

## Standard Field Names

Use these field names consistently across all TrailCurrent projects:

| Field Name | Supplier | Example Value | Usage |
|------------|----------|----------------|-------|
| `LCSC_PART` | LCSC / JLC Electronics | `C0012345` | Automated JLCPCB assembly |
| `MOUSER_PART` | Mouser Electronics | `511-2N2222ATA` | Alternative sourcing |
| `DIGIKEY_PART` | Digi-Key | `2N2222-ND` | Alternative sourcing |
| `VALUE` | Component value (standard) | `10kΩ` | Component specification |
| `FOOTPRINT` | Footprint reference (standard) | `Resistor_SMD:R_0805_2012Metric` | PCB layout |
| `DATASHEET` | Optional: Datasheet link | `http://...` | Reference documentation |

---

## How to Add Fields in KiCAD

### Method 1: Schematic Editor (Manual per instance)

1. **Open schematic** in KiCAD
2. **Double-click a component** to open Properties
3. **Click "Edit Fields"** button
4. **Add custom field:**
   - Field Name: `LCSC_PART`
   - Value: `C0012345` (the actual LCSC part code)
   - Visible: ☑ (check if you want it visible on schematic)
   - Value editable in footprint properties: ☑
5. **Repeat** for MOUSER_PART and DIGIKEY_PART
6. **Click OK**

### Method 2: Symbol Editor (Once per symbol)

To add fields to ALL instances of a symbol:

1. **Open Manage Symbols** (Preferences → Manage Symbol Libraries)
2. **Edit the symbol** in Symbol Editor
3. **Double-click symbol** → Properties
4. **Click "Edit Fields"**
5. **Add custom field** with placeholder value
6. **Save symbol**

Now all new instances of this symbol will have these fields.

### Method 3: Via Schematic File (.kicad_sch)

Edit the `.kicad_sch` file directly (advanced):

```scheme
(symbol (lib_id "Device:R")
  (at 100 100 0)
  (property "Reference" "R1" (id 0) (at 102 99 0))
  (property "Value" "10k" (id 1) (at 102 101 0))
  (property "LCSC_PART" "C0012345" (id 2) (at 0 0 0) hide)
  (property "MOUSER_PART" "511-2N2222ATA" (id 3) (at 0 0 0) hide)
  (property "DIGIKEY_PART" "2N2222-ND" (id 4) (at 0 0 0) hide)
)
```

---

## LCSC Part Number Format

### What is LCSC_PART?

LCSC (JLC Electronics' component database) uses standardized part codes:

**Format:** `C` + numbers (e.g., `C0012345`)

**Finding LCSC parts:**
1. Visit: https://jlcpcb.com/parts
2. Search by part value (e.g., "10kΩ resistor 0805")
3. Filter by:
   - Category (Resistors, Capacitors, etc.)
   - Package (0805, 1206, etc.)
   - Stock availability (usually select "In Stock")
4. Copy the part code (starts with `C`)

**Examples:**
```
Resistor 10kΩ 0805:     C0012345 (generic)
Capacitor 100nF 0603:   C0098765 (ceramic)
IC ESP32-S3:            C0987654 (microcontroller)
Connector JST XH 4-pin: C1234567 (JST connector)
```

### LCSC Stock Status

- **In Stock:** Reliable supply, use for production designs
- **Limited Stock:** May run out, check regularly
- **Not Available:** Cannot be used, find alternative

**Best Practice:** Always verify LCSC_PART is in stock before ordering!

---

## Mouser Part Numbers

### Format

Mouser uses hierarchical part numbers: `Manufacturer-SKU`

**Examples:**
```
Resistor 10kΩ 0805:      VISHAY-CRCW0805 10.0K FHMS
Capacitor 100nF 0805:    KEMET-C0805X104M5RACAUTO
Connector JST XH 4-pin:  JST-B4B-XH-A
```

**Finding Mouser parts:**
1. Visit: https://mouser.com
2. Search by part value + package
3. Compare prices and availability
4. Copy Mouser part number from product page
5. Often shown as **Mouser #** or **Part #**

### Advantages
- ✅ Often faster shipping than LCSC
- ✅ Often has stock when LCSC is out
- ✅ No SMT assembly fee (if sourcing parts yourself)
- ❌ Usually more expensive per unit

---

## DigiKey Part Numbers

### Format

DigiKey uses manufacturer SKUs with DigiKey suffix:

**Examples:**
```
Resistor 10kΩ 0805:      10KSMTR-ND (generic)
Capacitor 100nF 0805:    C0805C104K5RACAUTO-ND
Connector JST XH 4-pin:  B4B-XH-A(LF)(SN)-ND
```

**Finding DigiKey parts:**
1. Visit: https://digikey.com
2. Search by part value + package
3. Compare prices and lead times
4. Copy DigiKey part number
5. Often shown as **Part #** or **Digi-Key #**

### Advantages
- ✅ Worldwide shipping
- ✅ Often has exotic/hard-to-find parts
- ✅ Good API for automated orders
- ❌ Typically most expensive
- ❌ Longer lead times

---

## Using Fields in BOM Export

### Method 1: KiCAD's Built-in BOM Export

1. **Schematic → Tools → Generate Bill of Materials**
2. **Configure** columns to include custom fields:
   - Component Reference (R1, C1, etc.)
   - Value (10k, 100n, etc.)
   - Footprint
   - LCSC_PART
   - MOUSER_PART
   - DIGIKEY_PART
3. **Export** as CSV

### Example BOM Output

```
Ref      | Value    | Footprint          | LCSC_PART | MOUSER_PART      | DIGIKEY_PART
---------|----------|--------------------|-----------|--------------------|------------------
R1-R5    | 10k      | R_0805             | C0012345  | 511-10KSMTR        | 10KSMTR-ND
C1-C3    | 100nF    | C_0805             | C0098765  | 661-C0805X104M     | 399-C0805C104K5RA
U1       | ESP32-S3 | BGA-48             | C1234567  | (custom IC)        | (custom IC)
J1       | JST XH   | Connector_JST:B4B  | C9999999  | 649-B4B-XH-A       | B4B-XH-A(LF)(SN)-ND
```

### Method 2: Automated JLCPCB Assembly

JLCPCB uses a specific CSV format:

```
Designator,Quantity,Manufacturer Part Number
R1,1,
R2,1,C0012345
C1,3,C0098765
U1,1,C1234567
J1,1,C9999999
```

(First column is reference, JLCPCB uses 3rd column for LCSC parts)

---

## Best Practices

### 1. Keep Values Synchronized

If you update a component value, update all supplier fields:

```
BAD:  Value="10k" but LCSC_PART="C0012345" (for 4.7k)
GOOD: Value="10k" and LCSC_PART="C0045678" (verified match)
```

### 2. Verify Stock Before Finalizing BOM

```bash
# Create script to check LCSC availability
for part in C0012345 C0098765 C1234567; do
  # Query JLCPCB API for part info
  curl "https://jlcpcb.com/api/get/parts?part_code=$part"
done
```

### 3. Document Substitutions

If a preferred part is unavailable, document the substitution:

```scheme
; Original: C0012345 (unavailable)
; Substitute: C0045678 (mechanically identical)
(property "LCSC_PART" "C0045678" (id 2))
```

### 4. Create Template Symbols

For commonly used parts, create pre-populated symbols:

```
symbols/core/
├── Resistor_10k_0805.kicad_sym     (includes LCSC, Mouser, DigiKey)
├── Capacitor_100nF_0603.kicad_sym
├── Connector_JST_XH_4pin.kicad_sym
└── IC_ESP32-S3.kicad_sym
```

### 5. Maintain Part Library

Create a spreadsheet mapping component values to suppliers:

| Component | Value | Package | LCSC | Mouser | DigiKey | Notes |
|-----------|-------|---------|------|--------|---------|-------|
| Resistor | 10k | 0805 | C0012345 | 511-10KSMTR | 10KSMTR-ND | Common |
| Capacitor | 100nF | 0603 | C0098765 | 661-C0805X104M | 399-C0805C104K5RA | Ceramic |
| IC | ESP32-S3 | BGA48 | C1234567 | – | – | Custom |

---

## JLCPCB Assembly Workflow

### Step 1: Add LCSC_PART to All Components

In your schematic, ensure all SMD components have `LCSC_PART` field with valid LCSC part code.

### Step 2: Generate BOM

```bash
# In KiCAD Schematic
Tools → Generate Bill of Materials → Configure
- Include columns: Designator, Quantity, LCSC_PART
- Export as CSV
```

### Step 3: Upload to JLCPCB

1. Go to https://jlcpcb.com
2. Select "SMT Assembly"
3. Upload Gerber files (PCB design)
4. Upload BOM (CSV with LCSC_PART column)
5. Upload CPL file (component placement list)
6. Review assembly preview
7. Pay and manufacture

### Step 4: JLCPCB Verification

JLCPCB will:
- ✅ Verify each LCSC_PART code
- ✅ Check stock availability
- ✅ Identify any unavailable parts (needs substitution)
- ✅ Estimate assembly cost and timeline
- ⚠️ Flag if parts are "Extended Parts" (higher cost)

---

## Troubleshooting

### "LCSC_PART not recognized"

**Cause:** Field name doesn't match exactly (case-sensitive)  
**Solution:** Use exactly `LCSC_PART` (capital letters)

### "Part not found in LCSC database"

**Cause:** Invalid or incorrect part code  
**Solution:**
1. Verify part code on jlcpcb.com/parts
2. Check for typos (C + numbers only)
3. Search for similar part if original unavailable

### "Part is Extended Part (higher cost)"

**Cause:** Part is not standard stock  
**Solution:**
1. Find LCSC equivalent if available
2. Use Mouser/DigiKey alternative instead
3. Contact JLCPCB sales for bulk discounts

### "Fields not showing in BOM export"

**Cause:** Custom fields not configured in export template  
**Solution:**
1. Regenerate BOM
2. In BOM plugin, add custom field names
3. Verify field names match exactly

---

## Example: Adding Parts to JST XH Connector

For the newly consolidated JST XH connectors:

### JST_XH_S4B-XH-SM4-TB (4-pin SMD)

```
Component: JST XH 4-pin Connector
Footprint: Connector_JST:JST_XH_S4B-XH-SM4-TB_1x04-1MP_P2.50mm_Horizontal
VALUE:     JST XH S4B-XH-SM4-TB

LCSC_PART:   C9999999    # Need to look up actual LCSC code
MOUSER_PART: 649-B4B-XH-A-TH
DIGIKEY_PART: B4B-XH-A(LF)(SN)-ND
DATASHEET:   https://www.jst.com/products/...
```

**To find the LCSC part:**
1. Visit https://jlcpcb.com/parts
2. Search: "JST XH 4 pin connector 2.5mm"
3. Filter: In Stock, Package: SMD
4. Find exact match (S4B-XH-SM4-TB variant)
5. Copy LCSC part code

---

## Integration with TrailCurrent Workflow

### For New Projects

1. **Use template symbols** with pre-filled supplier fields
2. **Add LCSC_PART** when finalizing BOM
3. **Generate BOM** before manufacturing
4. **Verify availability** on jlcpcb.com

### For Existing Projects

1. **Audit schematic** for all components
2. **Add LCSC_PART fields** for each component
3. **Verify each part** exists in LCSC database
4. **Document substitutions** in component notes
5. **Test BOM export** before sending to JLCPCB

### Automated Approach

Create a script to:

```python
# pseudo-code
for each_component in schematic:
    value = get_value(component)
    footprint = get_footprint(component)
    
    # Look up suppliers
    lcsc = query_lcsc_api(value, footprint)
    mouser = query_mouser_api(value, footprint)
    digikey = query_digikey_api(value, footprint)
    
    # Add to component
    add_field(component, "LCSC_PART", lcsc)
    add_field(component, "MOUSER_PART", mouser)
    add_field(component, "DIGIKEY_PART", digikey)
```

---

## Next Steps

1. ✅ **Understand the system** (read this guide)
2. ⏳ **Create template symbols** with common parts
3. ⏳ **Update existing projects** with supplier fields
4. ⏳ **Build supplier lookup database**
5. ⏳ **Automate BOM generation** for JLCPCB

---

## References

- **JLCPCB SMT Assembly:** https://jlcpcb.com/capabilities/smtAssembly
- **LCSC Parts Database:** https://jlcpcb.com/parts
- **Mouser:** https://mouser.com
- **DigiKey:** https://digikey.com
- **KiCAD Custom Fields:** https://docs.kicad.org/stable/en/schematic/schematic.html#custom_fields

