# Cloud Archive & Backup Utility

A flexible, environment-decoupled Bash utility designed to automate the process of compressing local data directories into tarball archives and efficiently streaming them directly into Azure Blob Storage using Microsoft's `azcopy`. 

This script runs completely in the background via `nohup`, allowing you to safely disconnect or log out of your terminal session while large data payloads are processed and transmitted.

## Features
* **Environment Decoupling:** Uses a local config file (`backup.conf`) to store institutional paths, ensuring sensitive infrastructure paths are never exposed to source control.
* **Interactive Directory Auditing:** Scans and presents a clean list of available packages in your incoming directory before processing.
* **Background Resilience:** Forks processing and upload operations into a detached background sequence with dedicated log files.
* **Automatic Naming Sanitation:** Auto-generates smart, standardized uppercase `.tar` archive names based on the target folder name.

---

## Prerequisites & Installation

### 1. Download AzCopy
This utility relies directly on Microsoft's native `azcopy` command-line engine. For security and compatibility, **`azcopy` must be downloaded directly from Microsoft's official website**.

* **Linux (x86-64):** Download the latest release tarball directly from Microsoft:
  ```bash
  wget [https://aka.ms/downloadazcopy-v10-linux](https://aka.ms/downloadazcopy-v10-linux)
  tar -xvf downloadazcopy-v10-linux
### 2. Clone and Setup the Repository
*
  ```bash
  git clone https://github.com/Automated-Azure-Blob-Storage-upload-utility/Automated-Azure-Blob-Storage-upload-utility.git /var/az_script
  cd /var/az_script

### 3. Create the Local Configuration File
*
  ```bash
  nano backup.conf
*
  ```bash
  BASE_DIR="/path/to/your/incoming_storage_directory"
  AZCOPY_PATH="/path/to/your/installed/bin/azcopy"
  LOG_DIR="/var/cruise_script/log"
*
  ```bash
  chmod +x run_backup.sh

### How To Use
*
  ```bash
  ./run_backup.sh
