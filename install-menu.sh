#!/bin/bash

# Exit if any command fails
set -e

# Set scripts directory
SCRIPT_DIR="$(dirname "$0")/scripts"

# Check if scripts directory exists
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "[ERROR] Scripts directory not found at $SCRIPT_DIR"
    exit 1
fi

# Get list of install scripts
scripts=("$SCRIPT_DIR"/*.sh)

# No scripts found
if [ ${#scripts[@]} -eq 0 ]; then
    echo "[INFO] No install scripts found in $SCRIPT_DIR"
    exit 0
fi

# Show menu
echo "==== INSTALL MENU ===="
for i in "${!scripts[@]}"; do
    script_name=$(basename "${scripts[$i]}")
    echo "$((i + 1)). $script_name"
done
echo "q. Quit"
echo "======================"

# Prompt for selection
read -rp "Enter number of the script to run: " choice

# Handle quit
if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    echo "[INFO] Aborted by user."
    exit 0
fi

# Check if valid number
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] Invalid input. Please enter a number."
    exit 1
fi

# Convert to array index
index=$((choice - 1))

# Check if index is in range
if [ "$index" -lt 0 ] || [ "$index" -ge "${#scripts[@]}" ]; then
    echo "[ERROR] Invalid selection. Number out of range."
    exit 1
fi

# Execute selected script
selected_script="${scripts[$index]}"
echo "[INFO] Executing: $selected_script"
bash "$selected_script"

