#!/bin/bash

# Green error message
print_status() {
    echo -e "\e[1;32m[✔] $1\e[0m"
}

# Red error message
print_error() {
    echo -e "\e[1;31m[✘] $1\e[0m"
}

# Check and install openssh-server
if dpkg -s openssh-server &>/dev/null; then
    print_status "OpenSSH Server is already installed."
else
    sudo apt update && print_status "Package list updated." || print_error "Failed to update package list."
    sudo apt install -y openssh-server && print_status "OpenSSH Server installed." || print_error "Failed to install OpenSSH Server."
fi

# Allow SSH through UFW if not yet allowed
if sudo ufw status | grep -qw "OpenSSH"; then
    print_status "SSH is already allowed through UFW."
else
    sudo ufw allow ssh && print_status "SSH allowed through UFW." || print_error "Failed to allow SSH through UFW."
fi

# SSH Key-Based Authentication for dev_lead1
setup_ssh_key_auth() {
    local USER="dev_lead1"
    local SSH_DIR="/home/$USER/.ssh"

    echo "[*] Configuring SSH Key Authentication for $USER..."

    # create user if it doesn't exist
    if id "$USER" &>/dev/null; then
        print_status "User $USER already exists."
    else
        sudo useradd -m -s /bin/bash "$USER" && print_status "User $USER created." || print_error "Failed to create user $USER."
        sudo passwd -d "$USER" && print_status "Password removed for $USER."
    fi

    # create .ssh directory
    sudo -u "$USER" mkdir -p "$SSH_DIR"
    sudo chmod 700 "$SSH_DIR"
    sudo chown "$USER:$USER" "$SSH_DIR"

    # Generate SSH key if it still doesn't exist
    if [ ! -f "$SSH_DIR/id_rsa.pub" ]; then
        sudo -u "$USER" ssh-keygen -t rsa -b 2048 -f "$SSH_DIR/id_rsa" -N "" && \
        print_status "SSH key generated for $USER." || print_error "Failed to generate SSH key."
    else
        print_status "SSH key already exists for $USER."
    fi

    # Deploy key
    sudo cp "$SSH_DIR/id_rsa.pub" "$SSH_DIR/authorized_keys"
    sudo chmod 600 "$SSH_DIR/authorized_keys"
    sudo chown "$USER:$USER" "$SSH_DIR/authorized_keys"
    print_status "SSH public key deployed for $USER."

    # Lock password login
    sudo passwd -l "$USER" && print_status "Password login disabled for $USER."
}

# Disable password auth in SSH config
disable_password_auth() {
    echo "[*] Disabling password authentication in SSH config..."

    SSHD_CONFIG="/etc/ssh/sshd_config"

    if grep -q "^PasswordAuthentication no" "$SSHD_CONFIG"; then
        print_status "PasswordAuthentication already disabled."
    else
        sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG" || \
        echo "PasswordAuthentication no" | sudo tee -a "$SSHD_CONFIG" > /dev/null
        print_status "PasswordAuthentication set to no."
    fi

    sudo systemctl restart sshd && print_status "SSH service restarted." || print_error "Failed to restart SSH."
}

# Auto-detect password-based login attempts
monitor_failed_logins() {
    echo "[*] Detecting failed SSH password login attempts for dev_lead1..."
    local LOG_FILE="/var/log/dev_lead1_blocked.log"

    sudo grep "sshd.*dev_lead1.*Failed password" /var/log/auth.log | sudo tee "$LOG_FILE" > /dev/null && \
        print_status "Failed login attempts saved to $LOG_FILE." || \
        print_error "No failed login attempts found or unable to write to log."
}

# Enable unattended security updates
enable_auto_updates() {
    local LOG_PATH="/var/log/security_updates.log"

    echo "[*] Enabling automatic security updates..."

    sudo apt update && sudo apt install -y unattended-upgrades && \
        print_status "Unattended-upgrades installed." || print_error "Failed to install unattended-upgrades."

    sudo dpkg-reconfigure -f noninteractive unattended-upgrades && \
        print_status "Unattended-upgrades configured."

    sudo touch "$LOG_PATH" && sudo chmod 644 "$LOG_PATH" && \
        print_status "Created log file at $LOG_PATH."
}

# Configure the Message of the Day
motd() {
    echo "[*] Setting Message of the Day (MOTD)..."
    echo "Welcome to the Ubuntu Administration Lab." | sudo tee /etc/motd > /dev/null && \
        print_status "MOTD set successfully."
}

# Main
main() {
    setup_ssh_key_auth
    disable_password_auth
    monitor_failed_logins
    enable_auto_updates
    motd
    echo -e "\n\e[1;34m[✔] All security hardening measures have been completed.\e[0m"
}

main
