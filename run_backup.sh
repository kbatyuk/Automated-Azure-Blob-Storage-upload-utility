#!/bin/bash

# ==============================================================================
# Script Name:    run_backup.sh
# Description:    Automated archiving and Azure Blob Storage upload utility.
# ==============================================================================

# Locate the directory where the script itself lives to find the config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/backup.conf"

# --- Load Configurations ---
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default fallback placeholders for open-source safety
    BASE_DIR="/path/to/your/incoming_uploads"
    AZCOPY_PATH="/path/to/your/bin/azcopy"
    LOG_DIR="${SCRIPT_DIR}/log"
fi

echo "===================================================="
echo "Available storage packages in incoming directory:"
echo "----------------------------------------------------"
# List only directories inside the base path for quick reference
ls -1d ${BASE_DIR}/*/ 2>/dev/null | sed "s|${BASE_DIR}/||g" | tr -d '/'
echo "===================================================="
echo ""

# 1. Prompt for the specific folder name
read -p "Enter the storage folder name to archive: " storagePackage

if [ -z "$storagePackage" ]; then
    echo "Error: Folder name cannot be empty."
    exit 1
fi

# Construct the full target path
targetDirectory="${BASE_DIR}/${storagePackage}"

# --- Validation ---
if [ ! -d "$targetDirectory" ]; then
    echo "Error: Folder '$targetDirectory' does not exist."
    exit 1
fi

# 2. Prompt for Tar Name (with a smart uppercase default)
default_tar="${storagePackage^^}.tar"
read -p "Enter the desired tar filename [$default_tar]: " tarName
tarName=${tarName:-$default_tar}

# 3. Prompt for the Azure SAS URL token dynamically
echo ""
echo "Enter the full Azure Destination URL (including the SAS token details):"
read -r azURLToken

# Basic validation to ensure they didn't paste an empty string or bad URL
if [[ -z "$azURLToken" || ! "$azURLToken" =~ ^https:// ]]; then
    echo "Error: Invalid Azure URL provided. It must start with https://"
    exit 1
fi

echo "---------------------------------------"
echo "Ready to run backup locally in background:"
echo "Working Base Dir: $BASE_DIR"
echo "Target Package:   $storagePackage"
echo "Tar File Name:    $tarName"
echo "---------------------------------------"

mkdir -p "$LOG_DIR"

# Generate a timestamped log file name
log_file="$LOG_DIR/${storagePackage}_bk_$(date +%Y%m%d_%H%M%S).out"
echo "Process started! Tracking output in:"
echo "$log_file"

# Execute in background from the correct base directory mount point
nohup sh -c "
    cd '$BASE_DIR' || exit 1
    tar -cvf '$tarName' '$storagePackage'
    export AZCOPY_BUFFER_GB=10
    '$AZCOPY_PATH' cp '$tarName' '$azURLToken' --cap-mbps 1000
" > "$log_file" 2>&1 &
