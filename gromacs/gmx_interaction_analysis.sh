#!/bin/bash

# Embedded Python script for prep_pdbq.py functionality
create_prep_script() {
    cat > /tmp/prep_pdbq_temp.py << 'PYTHON_SCRIPT_EOF'
def parse_gro_file(filename):
    atoms = []
    with open(filename, 'r') as f:
        lines = f.readlines()[2:-1]
        for line in lines:
            atomname = line[10:15].strip()
            x = float(line[20:28])
            y = float(line[28:36])
            z = float(line[36:44])
            atoms.append((atomname, x, y, z))
    return atoms

def parse_pdb_file(filename):
    atoms = []
    with open(filename, 'r') as f:
        for line in f:
            if line.startswith("ATOM") or line.startswith("HETATM"):
                atomname = line[76:78].strip() or line[12:16].strip()
                x = float(line[30:38])
                y = float(line[38:46])
                z = float(line[46:54])
                atoms.append((atomname, x, y, z))
    return atoms

def parse_topology_file(filename):
    charges = []
    with open(filename, 'r') as f:
        lines = f.readlines()
        in_atoms_section = False
        for line in lines:
            line = line.strip()
            if line.startswith("[ atoms ]"):
                in_atoms_section = True
                continue
            if in_atoms_section:
                if line == "" or line.startswith("["):
                    break
                if line.startswith(";"):
                    continue
                parts = line.split()
                if len(parts) >= 7:
                    try:
                        charge = float(parts[6])
                        charges.append(charge)
                    except ValueError:
                        continue
    return charges

def main():
    coord_file = input("Enter the name of the coordinate file (.gro or .pdb): ").strip()
    topo_file = input("Enter the name of the topology file (.top or .itp): ").strip()
    term = input("Enter the term for the output file [xyzq_<term>.txt]: ").strip()
    
    output_file = f"xyzq_{term}.txt"

    if coord_file.endswith(".gro"):
        atoms = parse_gro_file(coord_file)
    elif coord_file.endswith(".pdb"):
        atoms = parse_pdb_file(coord_file)
    else:
        print("Unsupported coordinate file format. Use .gro or .pdb")
        return

    charges = parse_topology_file(topo_file)

    if len(atoms) != len(charges):
        print(f"Mismatch between number of atoms ({len(atoms)}) and charges ({len(charges)}).")
        return

    with open(output_file, 'w') as f:
        f.write(f"{'Atom':<6} {'X':>10} {'Y':>10} {'Z':>10} {'Charge':>10}\n")
        f.write("-" * 50 + "\n")
        for (atom, x, y, z), q in zip(atoms, charges):
            f.write(f"{atom:<6} {x:10.3f} {y:10.3f} {z:10.3f} {q:10.4f}\n")

    print(f"✅ Output written to {output_file}")

if __name__ == "__main__":
    main()
PYTHON_SCRIPT_EOF
}

# Main script starts here
ls -ltr
echo

# Ask for input PDB file first
read -p "Enter the input PDB file name: " input_pdb
# Ensure .pdb extension
[[ "$input_pdb" != *.pdb ]] && input_pdb="${input_pdb}.pdb"

# Prepare a separate ligand file from the input PDB
read -p "Enter the ligand name (e.g., lig_1a): " LIGAND_NAME
# Ensure .pdb extension
[[ "$LIGAND_NAME" != *.pdb ]] && LIGAND_NAME="${LIGAND_NAME}.pdb"
LIGAND_FILE="$LIGAND_NAME"

# Copy the input PDB file to ligand file
cp "$input_pdb" "$LIGAND_FILE" || { echo "Error: Could not copy $input_pdb"; exit 1; }

sed -i '/HETATM/!d' "$LIGAND_FILE"
echo "Ligand file created: $LIGAND_FILE"
echo

# Ask for output PDB name
read -p "Enter the output PDB file name: " output_pdb
# Ensure .pdb extension
[[ "$output_pdb" != *.pdb ]] && output_pdb="${output_pdb}.pdb"

# Copy the input PDB to the output name
cp "$input_pdb" "$output_pdb"
sed -i '/HETATM/d' "$output_pdb"

echo
echo "=========================================="
echo "Running pdb2gmx in INTERACTIVE mode"
echo "=========================================="
echo "You will be asked to:"
echo "  1. Select force field (recommend: 5 for Amber99sb)"
echo "  2. Select water model (recommend: 7 for None)"
echo "  3. Answer protonation questions for specific residues"
echo "     - For LYSINE: 0=neutral (LYN), 1=protonated/charged (LYS)"
echo "     - For HISTIDINE: 0=H on ND1, 1=H on NE2, 2=H on both"
echo "     - For other residues: follow on-screen prompts"
echo "=========================================="
echo

# Run pdb2gmx in fully interactive mode
gmx pdb2gmx -f "$output_pdb" -o "${output_pdb%.pdb}.gro" -ignh -missing -inter

# Check if pdb2gmx succeeded
if [ $? -ne 0 ]; then
    echo
    echo "ERROR: pdb2gmx failed. Please check the output above."
    exit 1
fi

echo
echo "pdb2gmx completed successfully!"
echo

# Convert .gro to new .pdb using editconf
gmx editconf -f "${output_pdb%.pdb}.gro" -o "${output_pdb%.pdb}_H.pdb"

# Check if editconf succeeded
if [ $? -ne 0 ]; then
    echo
    echo "ERROR: editconf failed. Please check if .gro file was created."
    exit 1
fi

echo
echo "Conversion to PDB completed successfully!"
echo

# Give a list of all the files
ls -ltr
echo

# Create and run the embedded Python script
echo "=========================================="
echo "Running prep_pdbq.py to generate xyzq file"
echo "=========================================="
create_prep_script
python3 /tmp/prep_pdbq_temp.py

# Clean up temporary Python script
rm -f /tmp/prep_pdbq_temp.py

echo
echo "=========================================="
echo "All steps completed!"
echo "=========================================="
