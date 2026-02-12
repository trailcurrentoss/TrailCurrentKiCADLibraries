#!/usr/bin/env python3
"""
add_supplier_fields.py

Helper script to add LCSC_PART, MOUSER_PART, and DIGIKEY_PART fields
to KiCAD schematic components.

Usage:
    python3 add_supplier_fields.py <schematic_file.kicad_sch> <parts_database.csv>

Example:
    python3 add_supplier_fields.py my_design.kicad_sch jst_xh_connector_parts.csv

This script:
1. Reads a KiCAD schematic file
2. Matches components by Value/Footprint to a parts database CSV
3. Adds LCSC_PART, MOUSER_PART, DIGIKEY_PART fields to matching components
4. Creates a backup of original file
5. Writes updated schematic with supplier fields
"""

import sys
import re
import csv
from pathlib import Path
from datetime import datetime


class KiCADSchematicEditor:
    """Edit KiCAD schematic files to add supplier part fields"""

    def __init__(self, schematic_path):
        self.path = Path(schematic_path)
        if not self.path.exists():
            raise FileNotFoundError(f"Schematic not found: {schematic_path}")

        with open(self.path, 'r') as f:
            self.content = f.read()

        print(f"✓ Loaded schematic: {self.path.name}")

    def backup(self):
        """Create backup of original file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = self.path.parent / f"{self.path.stem}_backup_{timestamp}{self.path.suffix}"
        backup_path.write_text(self.content)
        print(f"✓ Backup created: {backup_path.name}")
        return backup_path

    def extract_components(self):
        """Extract all components from schematic"""
        # Pattern to match (symbol ...) blocks
        pattern = r'\(symbol\s+\(lib_id\s+"([^"]+)"\)([^)]*(?:\(property[^)]*\))*[^)]*)\)'
        matches = re.finditer(pattern, self.content, re.MULTILINE | re.DOTALL)

        components = []
        for match in matches:
            comp_id = match.group(1)
            comp_block = match.group(0)

            # Extract reference (e.g., R1, C1, U1)
            ref_match = re.search(r'\(property\s+"Reference"\s+"([^"]+)"', comp_block)
            reference = ref_match.group(1) if ref_match else "?"

            # Extract value (e.g., 10k, 100nF)
            val_match = re.search(r'\(property\s+"Value"\s+"([^"]+)"', comp_block)
            value = val_match.group(1) if val_match else "?"

            # Extract footprint
            fp_match = re.search(r'\(property\s+"Footprint"\s+"([^"]+)"', comp_block)
            footprint = fp_match.group(1) if fp_match else ""

            components.append({
                'ref': reference,
                'value': value,
                'footprint': footprint,
                'lib_id': comp_id,
                'full_block': comp_block,
                'has_lcsc': 'LCSC_PART' in comp_block,
                'has_mouser': 'MOUSER_PART' in comp_block,
                'has_digikey': 'DIGIKEY_PART' in comp_block,
            })

        return components

    def load_parts_database(self, csv_path):
        """Load supplier parts from CSV"""
        db = {}

        with open(csv_path, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                # Key by value and footprint for matching
                key = (row['Value'].strip(), row['Footprint'].strip())
                db[key] = {
                    'lcsc': row.get('LCSC_PART', '').strip(),
                    'mouser': row.get('MOUSER_PART', '').strip(),
                    'digikey': row.get('DIGIKEY_PART', '').strip(),
                    'notes': row.get('Notes', '').strip(),
                }

        print(f"✓ Loaded {len(db)} parts from database")
        return db

    def add_fields_to_component(self, comp_block, lcsc='', mouser='', digikey=''):
        """Add supplier fields to a component block"""

        # Find the last property before the closing paren
        lines = comp_block.split('\n')

        # Build field lines
        new_fields = []
        if lcsc:
            new_fields.append(f'    (property "LCSC_PART" "{lcsc}" (at 0 0 0) hide)')
        if mouser:
            new_fields.append(f'    (property "MOUSER_PART" "{mouser}" (at 0 0 0) hide)')
        if digikey:
            new_fields.append(f'    (property "DIGIKEY_PART" "{digikey}" (at 0 0 0) hide)')

        if not new_fields:
            return comp_block

        # Insert fields before the closing paren
        insert_line = '\n'.join(new_fields) + '\n'

        # Find last ) in block
        last_close = comp_block.rfind(')')
        if last_close > 0:
            updated = comp_block[:last_close] + '\n' + insert_line + comp_block[last_close:]
            return updated

        return comp_block

    def match_and_update(self, parts_db):
        """Match components to parts database and update"""
        components = self.extract_components()

        print(f"\n✓ Found {len(components)} components in schematic\n")
        print("Component Matching Results:")
        print("-" * 80)

        updated = self.content
        matched = 0
        unmatched = []

        for comp in components:
            key = (comp['value'], comp['footprint'])

            if key in parts_db:
                part = parts_db[key]
                print(f"✓ {comp['ref']:8} {comp['value']:15} → LCSC: {part['lcsc']}, "
                      f"Mouser: {part['mouser']}, DigiKey: {part['digikey']}")

                # Add fields to component
                updated_block = self.add_fields_to_component(
                    comp['full_block'],
                    lcsc=part['lcsc'],
                    mouser=part['mouser'],
                    digikey=part['digikey']
                )
                updated = updated.replace(comp['full_block'], updated_block)
                matched += 1
            else:
                status = "SKIP" if comp['has_lcsc'] else "NO MATCH"
                print(f"✗ {comp['ref']:8} {comp['value']:15} (footprint: {comp['footprint']}) - {status}")
                unmatched.append((comp['ref'], comp['value'], comp['footprint']))

        print("-" * 80)
        print(f"\n✓ Matched: {matched} components")
        print(f"✗ Unmatched: {len(unmatched)} components")

        if unmatched:
            print("\nUnmatched components (may need manual lookup):")
            for ref, value, fp in unmatched:
                print(f"  {ref}: {value} ({fp})")

        self.content = updated
        return matched, unmatched

    def save(self):
        """Save updated schematic"""
        self.path.write_text(self.content)
        print(f"\n✓ Updated schematic saved: {self.path}")


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 add_supplier_fields.py <schematic.kicad_sch> <parts.csv>")
        print("\nExample:")
        print("  python3 add_supplier_fields.py my_design.kicad_sch jst_xh_connector_parts.csv")
        sys.exit(1)

    schematic_file = sys.argv[1]
    parts_file = sys.argv[2]

    if not Path(parts_file).exists():
        print(f"Error: Parts database not found: {parts_file}")
        sys.exit(1)

    try:
        # Load and edit schematic
        editor = KiCADSchematicEditor(schematic_file)
        editor.backup()

        # Load parts database
        parts_db = editor.load_parts_database(parts_file)

        # Match and update
        matched, unmatched = editor.match_and_update(parts_db)

        # Save
        editor.save()

        print("\n" + "=" * 80)
        print("✓ Operation completed successfully!")
        print(f"  Matched: {matched} components with supplier part numbers")
        print(f"  Unmatched: {len(unmatched)} components (manual lookup required)")
        print("=" * 80)

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
