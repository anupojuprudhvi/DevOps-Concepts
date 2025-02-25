#!/bin/bash
# ==============================
# Constants and Variables
# ==============================
LOG_FILE="/var/log/install.log"
K3S_KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
K3S_GROUP="k3s"
DEFAULT_K3S_USERS=("raj") # Default users to create
INSTALL_DOCKER=${1:-"n"}                   # Accept Docker installation as a parameter (default: no)
# ==============================
# Logging Setup
# ==============================
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[$(date)] INFO: Starting installation..."
# ==============================
# Helper Functions
# ==============================
log() {
  local level=$1
  local message=$2
  echo "[$(date)] $level: $message"
}
# Check if a package is installed
package_installed() {
  rpm -q "$1" &>/dev/null
}
# Function to install dependencies using --allowerasing
install_dependencies() {
  log "INFO" "Installing dependencies (curl, jq)..."
  if package_installed "curl-minimal"; then
    log "INFO" "Attempting to replace curl-minimal with curl using --allowerasing..."
    sudo yum install -y curl jq --allowerasing || { 
      log "ERROR" "Dependency installation failed."; exit 1; 
    }
  else
    sudo yum install -y curl jq || { 
      log "ERROR" "Dependency installation failed."; exit 1; 
    }
  fi
}
# Function to update the system
update_system() {
  log "INFO" "Updating the system..."
  yum update -y || { log "ERROR" "System update failed."; exit 1; }
}
# Function to create the k3s group
create_k3s_group() {
  if ! getent group "$K3S_GROUP" &>/dev/null; then
    log "INFO" "Creating '$K3S_GROUP' group..."
    groupadd "$K3S_GROUP" || { log "ERROR" "Failed to create '$K3S_GROUP' group."; exit 1; }
  fi
}

# Function to create users and add them to the k3s group
create_users_and_add_to_group() {
  local users=("$@")
  for USER in "${users[@]}"; do
    if ! id "$USER" &>/dev/null; then
      log "INFO" "Creating user '$USER'..."
      useradd -m -s /bin/bash "$USER" || { log "ERROR" "Failed to create user '$USER'."; continue; }
      
      # Optionally set a password (comment out if not needed)
      echo "$USER:yourpassword" | chpasswd
      
      # Alternatively, unlock the account without a password
      usermod -p '*' "$USER"
    fi

    if ! groups "$USER" | grep -q "\b$K3S_GROUP\b"; then
      log "INFO" "Adding user '$USER' to the '$K3S_GROUP' group..."
      usermod -aG "$K3S_GROUP" "$USER" || { log "ERROR" "Failed to add user '$USER' to the '$K3S_GROUP' group."; continue; }
    fi

    if [[ -f "$K3S_KUBECONFIG" ]]; then
      log "INFO" "Copying kubeconfig file for user '$USER'..."
      mkdir -p "/home/$USER/.kube"
      cp "$K3S_KUBECONFIG" "/home/$USER/.kube/config"
      chown -R "$USER:$USER" "/home/$USER/.kube"
      chmod 600 "/home/$USER/.kube/config"
    fi
  done
}
# Function to install K3s
install_k3s() {
  if ! systemctl is-active --quiet k3s; then
    log "INFO" "Installing K3s..."
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 640 || { 
      log "ERROR" "K3s installation failed."; exit 1; 
    }
  fi
}
# Function to configure kubectl
configure_kubectl() {
  if ! grep -q "export PATH=\$PATH:/usr/local/bin" ~/.bashrc; then
    log "INFO" "Adding kubectl to PATH..."
    export PATH=$PATH:/usr/local/bin
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
  fi
}
# Function to create a dev namespace
create_dev_namespace() {
  if ! kubectl get namespace dev &>/dev/null; then
    log "INFO" "Creating dev namespace..."
    kubectl create namespace dev || { log "ERROR" "Failed to create 'dev' namespace."; exit 1; }
  fi
}
# Function to fix kubeconfig permissions
fix_kubeconfig_permissions() {
  if [[ -f "$K3S_KUBECONFIG" ]]; then
    log "INFO" "Fixing kubeconfig permissions for '$K3S_KUBECONFIG'..."
    chmod 640 "$K3S_KUBECONFIG"
    chown root:k3s "$K3S_KUBECONFIG"
  else
    log "WARN" "Kubeconfig file '$K3S_KUBECONFIG' not found. Skipping permission fix."
  fi
}
# Function to install Docker (optional)
install_docker() {
  if [[ "$INSTALL_DOCKER" == "y" || "$INSTALL_DOCKER" == "Y" ]]; then
    if ! command -v docker &>/dev/null; then
      log "INFO" "Installing Docker..."
      yum install -y docker || { log "ERROR" "Docker installation failed."; exit 1; }
      systemctl start docker
      systemctl enable docker
    fi
  fi
}
# ==============================
# Main Script Execution
# ==============================
# Step 1: Update the system
update_system
# Step 2: Install dependencies
install_dependencies
# Step 3: Create the k3s group
create_k3s_group
# Step 4: Create users and add them to the k3s group
create_users_and_add_to_group "${DEFAULT_K3S_USERS[@]}"
# Step 5: Install K3s
install_k3s
# Step 6: Fix kubeconfig permissions
fix_kubeconfig_permissions
# Step 7: Configure kubectl
configure_kubectl
# Step 8: Create dev namespace
create_dev_namespace
# Step 9: Install Docker (optional)
install_docker
# Final Message
log "INFO" "Setup complete! K3s is running, and the 'dev' namespace has been created."
log "INFO" "Use 'kubectl get nodes' to verify the cluster."
