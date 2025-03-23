{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww15160\viewh10940\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
\
# Create and Setup SSH for dev_lead1\
setup_ssh_key_auth() \{\
  local USER="dev_lead1"\
  local SSH_DIR="/home/$USER/.ssh"\
  echo "[*] Creating SSH Key Authentication for $USER..."\
\
  # Create the user if not exists\
  if ! id "$USER" &>/dev/null; then\
    echo "  [+] Creating user $USER..."\
    sudo useradd -m -s /bin/bash "$USER"\
    sudo passwd -d "$USER"\
  fi\
\
  # Create SSH directory and set permissions\
  sudo -u "$USER" mkdir -p "$SSH_DIR"\
  sudo chown "$USER:$USER" "$SSH_DIR"\
  sudo chmod 700 "$SSH_DIR"\
\
  # Generate SSH key pair if it does not exist\
  if [ ! -f "$SSH_DIR/id_rsa.pub" ]; then\
    echo "  [+] Generating SSH key..."\
    sudo -u "$USER" ssh-keygen -t rsa -b 2048 -f "$SSH_DIR/id_rsa" -N ""\
  fi\
\
  # Deploy key\
  echo "  [+] Deploying SSH public key..."\
  sudo cp "$SSH_DIR/id_rsa.pub" "$SSH_DIR/authorized_keys"\
  sudo chown -R "$USER:$USER" "$SSH_DIR"\
  sudo chmod 600 "$SSH_DIR/authorized_keys"\
\
  # Lock password and allow only sudo access\
  echo "  [+] Locking password and allowing sudo access..."\
  sudo passwd -l "$USER"\
  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER" > /dev/null\
\}\
\
# Disable global password authentication\
disable_password_auth_globally() \{\
  echo "[*] Disabling SSH password authentication..."\
\
  if [ ! -f /etc/ssh/sshd_config ]; then\
    echo "[!] sshd_config not found. Creating a new one..."\
    sudo touch /etc/ssh/sshd_config\
  fi\
\
  sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config || echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config\
  sudo systemctl restart sshd 2>/dev/null || echo "[!] SSH service not found or could not be restarted."\
\}\
\
# Monitor all failed SSH login attempts\
monitor_login_attempts() \{\
  local USER="dev_lead1"\
  local LOG_FILE="/var/log/dev_lead1_blocked.log"\
  echo "[*] Monitoring failed login attempts for $USER..."\
  sudo grep "sshd.*$USER.*Failed password" /var/log/auth.log | sudo tee "$LOG_FILE" > /dev/null || echo "[!] Could not write to $LOG_FILE"\
\}\
\
# Enable automatic security updates\
enable_auto_updates() \{\
  echo "[*] Enabling automatic security updates..."\
\
  # Wait if apt is locked\
  while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do\
    echo "[*] Waiting for apt lock to be released..."\
    sleep 5\
  done\
\
  sudo apt update && sudo apt install -y unattended-upgrades\
  sudo dpkg-reconfigure -f noninteractive unattended-upgrades\
\
  # Create log file for updates\
  local UPDATE_LOG="/var/log/security_updates.log"\
  sudo touch "$UPDATE_LOG"\
  sudo chmod 644 "$UPDATE_LOG"\
\
  # Cron job to log update results daily at 3 AM\
  echo "[*] Setting up cron job for update logging..."\
  local CRON_JOB='0 3 * * * /usr/bin/unattended-upgrade >> /var/log/security_updates.log 2>&1'\
  (sudo crontab -l 2>/dev/null; echo "$CRON_JOB") | sudo crontab -\
\}\
\
# Set MOTD\
set_motd() \{\
  echo "[*] Setting login message..."\
  echo "Welcome to the Ubuntu Administration Lab." | sudo tee /etc/motd > /dev/null\
\}\
\
# Run all functions\
main() \{\
  setup_ssh_key_auth\
  disable_password_auth_globally\
  monitor_login_attempts\
  enable_auto_updates\
  set_motd\
  echo " All security hardening steps completed!"\
\}\
\
# Run the main function\
main\
}