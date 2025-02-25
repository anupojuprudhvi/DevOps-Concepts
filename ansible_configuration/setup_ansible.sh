#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 [-d DIR_NAME] [-c CFG_PATH] [-i INV_PATH] [-g GROUPS]"
    echo "  -d DIR_NAME   : Directory name for Ansible setup (default: ansible)"
    echo "  -c CFG_PATH   : Path to ansible.cfg file (default: /home/ec2-user/ansible/ansible.cfg)"
    echo "  -i INV_PATH   : Path to inventory file (default: /home/ec2-user/ansible/hosts)"
    echo "  -g GROUPS     : Comma-separated list of inventory groups (default: appserver,dmz)"
    exit 1
}

# Default values
DIR_NAME="ansible"
CFG_PATH="/home/ec2-user/ansible/ansible.cfg"
INV_PATH="/home/ec2-user/ansible/hosts"
GROUPS="appserver,dmz"

# Parse command-line arguments
while getopts ":d:c:i:g:" opt; do
    case ${opt} in
        d) DIR_NAME="$OPTARG" ;;
        c) CFG_PATH="$OPTARG" ;;
        i) INV_PATH="$OPTARG" ;;
        g) GROUPS="$OPTARG" ;;
        *) usage ;;
    esac
done

# Validate inputs
if [[ ! "$GROUPS" =~ ^[a-zA-Z0-9]+(,[a-zA-Z0-9]+)*$ ]]; then
    echo "Error: Invalid group names. Use a comma-separated list of alphanumeric group names."
    exit 1
fi

# Create the Ansible directory
sudo mkdir -p "/home/ec2-user/$DIR_NAME" || { echo "Failed to create directory"; exit 1; }
cd "/home/ec2-user/$DIR_NAME" || { echo "Failed to navigate to directory"; exit 1; }

# Backup existing files if they exist
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        sudo mv "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)" || { echo "Failed to backup $file"; exit 1; }
        echo "Backed up existing $file to ${file}.bak"
    fi
}

backup_file "$CFG_PATH"
backup_file "$INV_PATH"

# Create ansible.cfg
cat <<EOL | sudo tee "$CFG_PATH" > /dev/null
[defaults]
inventory = $INV_PATH
EOL
echo "Created $CFG_PATH"

# Create inventory file with dynamic groups
{
    echo "# Ansible Inventory File"
    IFS=',' read -ra GROUP_ARRAY <<< "$GROUPS"
    for group in "${GROUP_ARRAY[@]}"; do
        echo "[$group]"
        echo
    done
} | sudo tee "$INV_PATH" > /dev/null
echo "Created $INV_PATH with groups: $GROUPS"

# Final confirmation
echo "Ansible setup completed successfully."
echo "Directory: /home/ec2-user/$DIR_NAME"
echo "Configuration file: $CFG_PATH"
echo "Inventory file: $INV_PATH"