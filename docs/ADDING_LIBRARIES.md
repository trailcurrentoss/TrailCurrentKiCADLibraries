# Adding Libraries to TrailCurrentKiCADLibraries
## Symbols, Footprints, and 3D Models

---

## Before You Start

1. **Run the install script** if you haven't already:
   ```bash
   ./install.sh
   ```
   This registers all libraries and sets the 3D model path automatically.

2. **Install the pre-commit hook** to prevent accidental commits containing personal paths:
   ```bash
   ./setup-hooks.sh
   ```

---

## Directory Layout

```
TrailCurrentKiCADLibraries/
├── symbols/
│   └── TrailCurrentSymbolLibrary.kicad_sym    # All custom symbols (one file)
├── footprints/
│   └── TrailCurrentFootprints.pretty/         # All custom footprints (one directory)
│       ├── AP63203WU7.kicad_mod
│       ├── MCP2515T-ISO.kicad_mod
│       └── ...
└── 3dmodels/
    └── TrailCurrent.3dshapes/                 # 3D models (categorized)
        ├── connectors/
        ├── ics/
        ├── modules/
        ├── passives/
        └── power/
```

**Key points:**
- **One** symbol library file contains all symbols
- **One** footprint library directory contains all footprints
- 3D models are organized by category but referenced via a single environment variable
- Adding new components never requires updating KiCAD library table entries

---

## Adding Symbols

### How Symbol Libraries Work

A `.kicad_sym` file **is** a library — it's a single file that can contain multiple symbol definitions. This project uses one consolidated library: `TrailCurrentSymbolLibrary.kicad_sym`.

**About downloaded symbols:** Sites like EasyEDA, SnapEDA, and Ultra Librarian export individual `.kicad_sym` files (one per component). You **import** the symbol from the downloaded file into the TrailCurrent library rather than using it as a separate library.

### Step 1: Open the Symbol Library

1. Open the **Symbol Editor**
2. If `TrailCurrentSymbolLibrary` isn't in the left panel, add it:
   File -> Add Library -> navigate to `symbols/TrailCurrentSymbolLibrary.kicad_sym`
3. Select the library

### Step 2: Add a Symbol

#### Option A: Import a Downloaded Symbol

1. Select `TrailCurrentSymbolLibrary` in the left panel
2. File -> Import Symbol
3. Navigate to the downloaded `.kicad_sym` file and open it
4. The symbol is copied into the library — you can delete the downloaded file
5. Review and update the symbol's properties (see checklist below)
6. Save (Ctrl+S)

#### Option B: Draw a New Symbol

1. Select `TrailCurrentSymbolLibrary` in the left panel
2. Click **New Symbol** (or File -> New Symbol)
3. Name it to match the component part number (e.g., `AP63203WU-7`)
4. Draw the symbol:
   - Add pins with correct electrical types (input, output, power, passive, etc.)
   - Set pin numbers to match the component datasheet
   - Add the component outline
5. Save (Ctrl+S)

#### Symbol Property Checklist

Verify these properties are set correctly:

- **Reference:** prefix letter (U for ICs, J for connectors, Y for crystals, L for inductors)
- **Value:** component part number
- **Footprint:** `TrailCurrentFootprints:<footprint_name>` (e.g., `TrailCurrentFootprints:MCP2515T-ISO`)
- **Datasheet:** URL to the manufacturer's datasheet

Imported symbols often have the footprint field pre-filled with a path from the download site. Update it to reference `TrailCurrentFootprints:<name>`.

### Step 3: Verify

1. Run **Inspect -> Electrical Rules Check**
2. Confirm the footprint field resolves correctly

### Step 4: Check for Personal Paths

```bash
grep -n "/home/\|/Users/\|/media/" symbols/*.kicad_sym
```

---

## Adding Footprints

Footprints are PCB land patterns (`.kicad_mod` files). All footprints go into the single `TrailCurrentFootprints.pretty/` directory.

### Naming Convention

```
JST_XH_B10B-XH-A_1x10_P2.50mm_Vertical.kicad_mod
│      │          │     │        └── Mounting orientation
│      │          │     └── Pin pitch
│      │          └── Pin configuration
│      └── Manufacturer part number
└── Series/family prefix
```

### Step 1: Create the Footprint

1. Open the **Footprint Editor**
2. File -> New Footprint
3. Name it following the convention above
4. Build the footprint:
   - Add pads matching the component datasheet land pattern
   - Set pad numbers to match the symbol pin numbers
   - Draw the component outline on the `F.Fab` layer
   - Draw the courtyard on the `F.CrtYd` layer
   - Draw the silkscreen on the `F.SilkS` layer
   - Add reference designator (`REF**`) on `F.SilkS`

### Step 2: Assign a 3D Model (if available)

1. Open Footprint Properties (Edit -> Footprint Properties)
2. Go to the **3D Models** tab
3. Click **Add 3D Model**
4. Set the path using the environment variable:
   ```
   ${TRAILCURRENT_3DMODEL_DIR}/ics/MyModel.step
   ```
5. Adjust offset, rotation, and scale to align with the pads

**Never use absolute paths.** Always use `${TRAILCURRENT_3DMODEL_DIR}`.

### Step 3: Save to the Library

Save the `.kicad_mod` file into `footprints/TrailCurrentFootprints.pretty/`.

That's it — since KiCAD already knows about this directory, the footprint is immediately available in all projects.

### Step 4: Run DRC

Run **Inspect -> Design Rules Check** to catch pad spacing, missing courtyard, or silkscreen overlap issues.

### Step 5: Verify No Personal Paths

```bash
grep -rn "/home/\|/Users/\|/media/" footprints/TrailCurrentFootprints.pretty/*.kicad_mod
```

The 3D model path inside the `.kicad_mod` file should look like:

```
(model "${TRAILCURRENT_3DMODEL_DIR}/connectors/MyModel.step"
  (offset (xyz 0 0 0))
  (scale (xyz 1 1 1))
  (rotate (xyz 0 0 0))
)
```

---

## Adding 3D Models

3D models are STEP files used for mechanical visualization. Place them in categorized subdirectories under `3dmodels/TrailCurrent.3dshapes/`.

### Supported Formats

| Format | Extension | Purpose |
|--------|-----------|---------|
| STEP   | `.step`, `.stp` | Precision CAD interchange (required) |
| VRML   | `.wrl`    | Lightweight visualization with colors (optional) |

### Step 1: Obtain the Model

- **Manufacturer websites** often provide 3D models for download
- **CAD software** (FreeCAD, Fusion 360, SolidWorks): export as STEP AP214
- **Community libraries:** GrabCAD, 3DContentCentral

When exporting:
- Set origin to where the component sits on the PCB
- Use millimeters
- Orient +Z pointing up from the board surface

### Step 2: Place the File

Copy into the appropriate category:

```
3dmodels/TrailCurrent.3dshapes/
├── connectors/    # Connector models
├── ics/           # IC and semiconductor models
├── modules/       # Multi-component modules and assemblies
├── passives/      # Crystals, inductors, capacitors
└── power/         # Power supply and converter models
```

Create a new subdirectory if no existing category fits.

### Step 3: Link to a Footprint

Open the footprint in the Footprint Editor and add the model path:

```
${TRAILCURRENT_3DMODEL_DIR}/ics/MyModel.step
```

### Step 4: Verify Alignment

1. Open a PCB that uses the footprint (or create a test PCB)
2. View -> 3D Viewer (Alt+3)
3. Check that the model sits flush on the board and aligns with pads

---

## Checklist Before Staging

- [ ] No absolute paths in any `.kicad_sym` or `.kicad_mod` file
- [ ] All 3D model references use `${TRAILCURRENT_3DMODEL_DIR}`
- [ ] Symbol footprint references use `TrailCurrentFootprints:<name>` format
- [ ] Footprint passes DRC
- [ ] Symbol passes ERC
- [ ] 3D model aligns correctly in 3D Viewer
- [ ] No backup files staged (`.bak`, `.kicad_pcb-bak`, etc.)

---

## Troubleshooting

### "Footprint library not showing in library browser"

**Fix:** Run `./install.sh` to register the library, then restart KiCAD.

### "3D model path not resolving"

**Fix:** Verify `TRAILCURRENT_3DMODEL_DIR` is set in KiCAD: Preferences -> Configure Paths. It should point to `3dmodels/TrailCurrent.3dshapes/`.

### "Symbol library not loading"

**Fix:** Run `./install.sh` to register the library, then restart KiCAD.

### "3D model is floating above/below the board"

**Fix:** Adjust the Z offset in the footprint's 3D Models tab.

### "3D model is rotated wrong"

**Fix:** Adjust rotation values in the footprint's 3D Models tab. Common fix: rotate 180 degrees around Z.
