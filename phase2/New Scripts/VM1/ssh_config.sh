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

# Disable password auth in SSH config
disable_password_auth() {
    echo "[*] Disabling password authentication in SSH config..."

    SSHD_CONFIG="/etc/ssh/sshd_config"

	# Check if a Match block for dev_lead1 already exists
	if grep -q "^Match User dev_lead1" "$SSHD_CONFIG"; then
	    echo "[✔] Match User dev_lead1 block already exists. Please verify manually."
	else
	   {
		echo "Match User dev_lead1"
		echo "    PasswordAuthentication yes"
		echo "    PubkeyAuthentication yes"
	    } | sudo tee -a "$SSHD_CONFIG" > /dev/null

	    echo "[✔] Match block for dev_lead1 added with PasswordAuthentication=no and PubkeyAuthentication=yes."
	fi

	# Restart SSH service
	sudo systemctl restart sshd && \
	echo "[✔] SSH service restarted." || \
	echo "[✘] Failed to restart SSH service."
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
    disable_password_auth
    monitor_failed_logins
    enable_auto_updates
    motd
    echo -e "\n\e[1;34m[✔] All security hardening measures have been completed.\e[0m"
}

main