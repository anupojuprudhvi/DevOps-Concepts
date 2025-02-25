
---

# Workflow Documentation for Ansible Setup Script

This document describes the workflow and usage of the Bash script designed to automate the setup of an Ansible environment. The script creates the necessary directory structure, configuration files (`ansible.cfg` and `hosts`), and inventory groups dynamically based on user input.

---

## Table of Contents

1. [Purpose](#purpose)
2. [Script Overview](#script-overview)
3. [Workflow Steps](#workflow-steps)
4. [Usage Instructions](#usage-instructions)
5. [Example Scenarios](#example-scenarios)
6. [Output Files](#output-files)
7. [Troubleshooting](#troubleshooting)

---

## Purpose

The script automates the initial setup of an Ansible environment by:
- Creating a directory for Ansible files.
- Generating the `ansible.cfg` configuration file.
- Creating the `hosts` inventory file with dynamic groups.
- Backing up existing files before making changes.

This ensures a consistent and reusable Ansible setup process.

---

## Script Overview

### Key Features
- **Customizable Inputs**: Users can specify the directory name, configuration file path, inventory file path, and inventory groups via command-line arguments.
- **Dynamic Inventory Groups**: Supports comma-separated group names for the inventory file.
- **Backup Mechanism**: Automatically backs up existing files before overwriting them.
- **Validation**: Ensures valid inputs for group names and handles errors gracefully.

### Default Values
If no arguments are provided, the script uses the following defaults:
- Directory: `/home/ec2-user/ansible`
- Configuration File: `/home/ec2-user/ansible/ansible.cfg`
- Inventory File: `/home/ec2-user/ansible/hosts`
- Inventory Groups: `appserver,dmz`

---

## Workflow Steps

1. **Parse Command-Line Arguments**:
   - The script accepts optional arguments for customizing the directory, configuration file, inventory file, and inventory groups.
   - If no arguments are provided, default values are used.

2. **Validate Inputs**:
   - Ensures that group names are alphanumeric and properly formatted.
   - Exits with an error message if validation fails.

3. **Create Directory**:
   - Creates the specified directory (or uses the default `/home/ec2-user/ansible`) if it doesn't already exist.

4. **Backup Existing Files**:
   - Checks if `ansible.cfg` or `hosts` files already exist.
   - Backs up existing files with a timestamp suffix (e.g., `ansible.cfg.bak.20231010120000`).

5. **Generate Configuration Files**:
   - Creates the `ansible.cfg` file with the specified inventory path.
   - Generates the `hosts` file with the specified inventory groups.

6. **Final Confirmation**:
   - Prints a success message with details about the created files and directory.

---

## Usage Instructions

### Syntax
```bash
./setup_ansible.sh [-d DIR_NAME] [-c CFG_PATH] [-i INV_PATH] [-g GROUPS]
```

### Flags
- `-d DIR_NAME`: Directory name for Ansible setup (default: `ansible`).
- `-c CFG_PATH`: Path to `ansible.cfg` file (default: `/home/ec2-user/ansible/ansible.cfg`).
- `-i INV_PATH`: Path to inventory file (default: `/home/ec2-user/ansible/hosts`).
- `-g GROUPS`: Comma-separated list of inventory groups (default: `appserver,dmz`).

### Example Commands
1. **Default Setup**:
   ```bash
   ./setup_ansible.sh
   ```
   - Uses default values for all parameters.

2. **Custom Directory and Groups**:
   ```bash
   ./setup_ansible.sh -d my_ansible -g webserver,database
   ```
   - Creates `/home/ec2-user/my_ansible` with `ansible.cfg` and `hosts` files containing `[webserver]` and `[database]`.

3. **Custom Paths**:
   ```bash
   ./setup_ansible.sh -d ansible_dev -c /etc/ansible/ansible.cfg -i /etc/ansible/hosts -g devserver,testserver
   ```
   - Uses custom paths for configuration and inventory files.

---

## Example Scenarios

### Scenario 1: Default Setup
Run the script without arguments:
```bash
./setup_ansible.sh
```

**Output**:
```
Backed up existing /home/ec2-user/ansible/ansible.cfg to /home/ec2-user/ansible/ansible.cfg.bak.20231010120000
Created /home/ec2-user/ansible/ansible.cfg
Backed up existing /home/ec2-user/ansible/hosts to /home/ec2-user/ansible/hosts.bak.20231010120000
Created /home/ec2-user/ansible/hosts with groups: appserver,dmz
Ansible setup completed successfully.
Directory: /home/ec2-user/ansible
Configuration file: /home/ec2-user/ansible/ansible.cfg
Inventory file: /home/ec2-user/ansible/hosts
```

### Scenario 2: Custom Groups
Run the script with custom groups:
```bash
./setup_ansible.sh -g webserver,database,loadbalancer
```

**Output**:
```
Created /home/ec2-user/ansible/ansible.cfg
Created /home/ec2-user/ansible/hosts with groups: webserver,database,loadbalancer
Ansible setup completed successfully.
Directory: /home/ec2-user/ansible
Configuration file: /home/ec2-user/ansible/ansible.cfg
Inventory file: /home/ec2-user/ansible/hosts
```

---

## Output Files

### Directory Structure
After running the script, the following files and directory will be created:
```
/home/ec2-user/
└── ansible/
    ├── ansible.cfg       # Ansible configuration file
    └── hosts             # Inventory file
```

### `ansible.cfg`
```ini
[defaults]
inventory = /home/ec2-user/ansible/hosts
```

### `hosts`
```ini
# Ansible Inventory File
[appserver]

[dmz]
```

---

## Troubleshooting

### 1. Invalid Group Names
If you provide invalid group names (e.g., containing special characters), the script will exit with an error:
```
Error: Invalid group names. Use a comma-separated list of alphanumeric group names.
```

### 2. Permission Issues
Ensure you have sufficient permissions to create directories and files in `/home/ec2-user`. Use `sudo` if necessary.

### 3. Backup Conflicts
If backups fail, ensure there is enough disk space and that no other processes are locking the files.

---

## Conclusion

This script simplifies the process of setting up an Ansible environment by automating repetitive tasks. It is flexible, reusable, and suitable for various scenarios. For further customization or enhancements, refer to the script's source code.

For more information about Ansible, visit the official documentation: [https://docs.ansible.com](https://docs.ansible.com).

---
