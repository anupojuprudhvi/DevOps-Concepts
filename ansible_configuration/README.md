

---

# Ansible Setup Guide

This repository provides a step-by-step guide to set up an Ansible environment on an EC2 instance. The setup includes creating the necessary directory structure, configuration files, and inventory files. Additionally, it explains how to test connectivity using the `ansible ping` module.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Directory Structure](#directory-structure)
3. [Configuration Files](#configuration-files)
   - [ansible.cfg](#ansiblecfg)
   - [hosts](#hosts)
4. [Testing Connectivity](#testing-connectivity)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before proceeding with the setup, ensure the following:

- **EC2 Instance**: You have access to an EC2 instance (e.g., Amazon Linux or Ubuntu).
- **SSH Access**: You can SSH into the EC2 instance.
- **Ansible Installed**: Install Ansible if it is not already installed:
  ```bash
  sudo yum install ansible -y  # For Amazon Linux
  sudo apt install ansible -y  # For Ubuntu
  ```
- **Python**: Ensure Python is installed on both the control node and managed nodes.

---

## Directory Structure

The Ansible setup will be located in the `/home/ec2-user/ansible` directory. Below is the directory structure:

```
/home/ec2-user/
└── ansible/
    ├── ansible.cfg       # Ansible configuration file
    └── hosts             # Inventory file
```

---

## Configuration Files

### `ansible.cfg`

The `ansible.cfg` file specifies the default settings for Ansible. Create this file in the `/home/ec2-user/ansible` directory with the following content:

```ini
[defaults]
inventory = /home/ec2-user/ansible/hosts
```

This configuration tells Ansible to use the `hosts` file as the inventory.

---

### `hosts`

The `hosts` file defines the inventory of managed nodes. Create this file in the `/home/ec2-user/ansible` directory with the following content:

```ini
[appserver]

[dmz]
```

You can add hostnames or IP addresses under each group. For example:

```ini
[appserver]
192.168.1.10
192.168.1.11

[dmz]
192.168.1.20
192.168.1.21
```

---

## Testing Connectivity

Once the setup is complete, you can test connectivity to the managed nodes using the `ansible ping` module.

### 1. Navigate to the Ansible Directory
Ensure you are in the `/home/ec2-user/ansible` directory:
```bash
cd /home/ec2-user/ansible
```

### 2. Run the Ping Command
Use the following commands to test connectivity:

#### Ping All Hosts
```bash
ansible all -m ping
```

#### Ping Specific Groups
- For the `appserver` group:
  ```bash
  ansible appserver -m ping
  ```

- For the `dmz` group:
  ```bash
  ansible dmz -m ping
  ```

---

### Expected Output
If the `ping` module succeeds, you'll see output similar to this for each host:
```bash
<hostname> | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

If there are issues (e.g., SSH connectivity problems or Python not installed on the remote host), you'll see error messages like:
```bash
<hostname> | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh.",
    "unreachable": true
}
```

---

## Troubleshooting

### 1. Check SSH Connectivity
Manually test SSH access to the managed nodes:
```bash
ssh user@<hostname_or_ip>
```

### 2. Enable Verbose Output
Use the `-vvv` flag for detailed debugging:
```bash
ansible all -m ping -vvv
```

### 3. Specify Python Interpreter
If Python is installed in a non-default location on the managed nodes, specify the interpreter in the inventory file:
```ini
[appserver]
192.168.1.10 ansible_python_interpreter=/usr/bin/python3
```

---

## Conclusion

This guide provides a basic setup for managing hosts with Ansible. Once the setup is complete, you can expand it by adding more groups, roles, and playbooks to automate tasks across your infrastructure.

For more information, refer to the official Ansible documentation: [https://docs.ansible.com](https://docs.ansible.com).

---
