#!/bin/bash
# TrailCurrent KiCAD Libraries — Install Script
#
# This script fully registers the TrailCurrent libraries in KiCAD 9.0:
#   1. Adds TRAILCURRENT_3DMODEL_DIR to KiCAD's path configuration
#   2. Adds TrailCurrentSymbolLibrary to the global sym-lib-table
#   3. Adds TrailCurrentFootprints to the global fp-lib-table
#   4. Checks snap permissions (if KiCAD is installed via snap)
#
# Usage:
#   ./install.sh
#
# Safe to run multiple times — skips entries that already exist.

set -euo pipefail

# Resolve the absolute path of this repository
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
THREED_PATH="$REPO_DIR/3dmodels/TrailCurrent.3dshapes"

# --- Detect KiCAD config directory ---
# Snap installs use ~/snap/kicad/<rev>/.config/ instead of ~/.config/
KICAD_CONFIG=""
IS_SNAP=false

if [[ "$OSTYPE" == "darwin"* ]]; then
    KICAD_CONFIG="${HOME}/Library/Preferences/kicad/9.0"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    KICAD_CONFIG="${APPDATA}/kicad/9.0"
else
    # Check for snap install first (snap uses its own config directory)
    if command -v snap &>/dev/null && snap list kicad &>/dev/null; then
        IS_SNAP=true
        # Find the current snap revision's config directory
        SNAP_REV=$(snap list kicad 2>/dev/null | tail -1 | awk '{print $3}')
        SNAP_CONFIG="${HOME}/snap/kicad/${SNAP_REV}/.config/kicad/9.0"
        if [[ -d "$SNAP_CONFIG" ]]; then
            KICAD_CONFIG="$SNAP_CONFIG"
        fi
    fi
    # Fall back to standard config location
    if [[ -z "$KICAD_CONFIG" || ! -d "$KICAD_CONFIG" ]]; then
        KICAD_CONFIG="${HOME}/.config/kicad/9.0"
    fi
fi

if [[ ! -d "$KICAD_CONFIG" ]]; then
    echo "Error: KiCAD 9.0 config directory not found."
    echo "Searched: $KICAD_CONFIG"
    echo "Make sure KiCAD 9.0 is installed and has been run at least once."
    exit 1
fi

SYM_TABLE="$KICAD_CONFIG/sym-lib-table"
FP_TABLE="$KICAD_CONFIG/fp-lib-table"
KICAD_COMMON="$KICAD_CONFIG/kicad_common.json"

echo "TrailCurrent KiCAD Libraries Installer"
echo "======================================="
echo ""
echo "Repository:   $REPO_DIR"
echo "KiCAD config: $KICAD_CONFIG"
if $IS_SNAP; then
    echo "Install type: snap"
fi
echo ""

# --- Check snap permissions ---
if $IS_SNAP; then
    echo "[*] Checking snap permissions..."
    MEDIA_CONNECTED=$(snap connections kicad 2>/dev/null | grep "removable-media" | awk '{print $3}')
    if [[ "$MEDIA_CONNECTED" == "-" || -z "$MEDIA_CONNECTED" ]]; then
        echo ""
        echo "  WARNING: KiCAD snap does not have removable-media access."
        echo "  Libraries on external drives (like /media/) will not be visible."
        echo ""
        echo "  Fix by running:"
        echo "    sudo snap connect kicad:removable-media :removable-media"
        echo ""
        read -p "  Run this command now? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo snap connect kicad:removable-media :removable-media
            echo "  Snap permissions updated."
        else
            echo "  Skipped. You can run the command manually later."
        fi
    else
        echo "  Removable-media access: OK"
    fi
    echo ""
fi

# --- Step 1: Add 3D model path to kicad_common.json ---
echo "[1/3] Configuring TRAILCURRENT_3DMODEL_DIR in KiCAD paths..."

if [[ -f "$KICAD_COMMON" ]]; then
    if grep -q "TRAILCURRENT_3DMODEL_DIR" "$KICAD_COMMON"; then
        echo "  Already configured — skipping."
    else
        python3 -c "
import json

with open('$KICAD_COMMON', 'r') as f:
    config = json.load(f)

if 'environment' not in config:
    config['environment'] = {}
if 'vars' not in config['environment']:
    config['environment']['vars'] = {}

config['environment']['vars']['TRAILCURRENT_3DMODEL_DIR'] = '$THREED_PATH'

with open('$KICAD_COMMON', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print('  Added TRAILCURRENT_3DMODEL_DIR to kicad_common.json.')
"
    fi
else
    echo "  kicad_common.json not found — skipping."
    echo "  Set manually: KiCAD -> Preferences -> Configure Paths"
fi
echo ""

# --- Step 2: Add symbol library ---
echo "[2/3] Adding TrailCurrentSymbolLibrary to sym-lib-table..."

SYM_ENTRY='  (lib (name "TrailCurrentSymbolLibrary")(type "KiCad")(uri "'"$REPO_DIR"'/symbols/TrailCurrentSymbolLibrary.kicad_sym")(options "")(descr "TrailCurrent custom symbols"))'

if [[ ! -f "$SYM_TABLE" ]]; then
    echo "(sym_lib_table" > "$SYM_TABLE"
    echo "$SYM_ENTRY" >> "$SYM_TABLE"
    echo ")" >> "$SYM_TABLE"
    echo "  Created sym-lib-table with TrailCurrentSymbolLibrary."
elif grep -q 'name "TrailCurrentSymbolLibrary"' "$SYM_TABLE"; then
    echo "  Already present — skipping."
else
    sed -i '$ s/)$//' "$SYM_TABLE"
    echo "$SYM_ENTRY" >> "$SYM_TABLE"
    echo ")" >> "$SYM_TABLE"
    echo "  Added TrailCurrentSymbolLibrary."
fi
echo ""

# --- Step 3: Add footprint library ---
echo "[3/3] Adding TrailCurrentFootprints to fp-lib-table..."

# Clean up stale entries from old directory structure FIRST
# (old category-based entries like TrailCurrentFootprints_Connectors would
# cause the "already present" check below to false-match)
for OLD_NAME in TrailCurrentFootprints_Connectors TrailCurrentFootprints_DCDC TrailCurrentFootprints_ICs TrailCurrentFootprints_Passives; do
    if grep -q "$OLD_NAME" "$FP_TABLE" 2>/dev/null; then
        sed -i "/$OLD_NAME/d" "$FP_TABLE"
        echo "  Removed stale entry: $OLD_NAME"
    fi
done

FP_ENTRY='  (lib (name "TrailCurrentFootprints")(type "KiCad")(uri "'"$REPO_DIR"'/footprints/TrailCurrentFootprints.pretty")(options "")(descr "TrailCurrent custom footprints"))'

if [[ ! -f "$FP_TABLE" ]]; then
    echo "(fp_lib_table" > "$FP_TABLE"
    echo "$FP_ENTRY" >> "$FP_TABLE"
    echo ")" >> "$FP_TABLE"
    echo "  Created fp-lib-table with TrailCurrentFootprints."
elif grep -q 'name "TrailCurrentFootprints"' "$FP_TABLE"; then
    echo "  Already present — skipping."
else
    sed -i '$ s/)$//' "$FP_TABLE"
    echo "$FP_ENTRY" >> "$FP_TABLE"
    echo ")" >> "$FP_TABLE"
    echo "  Added TrailCurrentFootprints."
fi
echo ""

# --- Summary ---
echo ""
echo "======================================="
echo "Installation complete!"
echo ""
echo "Restart KiCAD, then verify:"
echo "  - Add Symbol -> search 'AP63203' -> should find AP63203WU-7"
echo "  - Add Footprint -> search 'MCP2515' -> should find MCP2515T-ISO"
echo "  - Preferences -> Configure Paths -> TRAILCURRENT_3DMODEL_DIR should appear"
echo ""
echo "To update libraries later: git pull (no reinstall needed)."
