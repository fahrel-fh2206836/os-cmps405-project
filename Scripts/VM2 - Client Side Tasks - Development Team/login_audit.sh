#!/bin/bash

# Variables
VM1_IP="vm1_ip"  # Replace with VM1's IP address
VM1_USER="vm1_user"  # Replace with the username for VM1
LOG_FILE="/path/to/invalid_attempts.log"  # Path to store invalid attempts log
BLOCKED_IPS="/path/to/blocked_ips.txt"  # Path to store blocked IPs

# Function to block IP using iptables on VM1
block_ip() {
    local ip=$1
    echo "Blocking IP: $ip"
    ssh $VM1_USER@$VM1_IP "sudo iptables -A INPUT -s $ip -j DROP" # Command for blocking the ip using iptables
    echo "$ip" >> $BLOCKED_IPS
}

# Fetch SSH logs from VM1
echo "Fetching SSH logs from VM1..."
ssh $VM1_USER@$VM1_IP "sudo grep 'Failed password' /var/log/auth.log" > /tmp/ssh_failed_logs.txt

# Process logs
echo "Processing logs..."
declare -A ip_attempts  # Associative array to store IP attempts

while read -r line; do
    ip=$(echo "$line" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ -n "$ip" ]]; then
        ((ip_attempts["$ip"]++))
        echo "$line" >> $LOG_FILE
    fi
done < /tmp/ssh_failed_logs.txt

# Block IPs with more than 3 failed attempts
for ip in "${!ip_attempts[@]}"; do
    if [[ ${ip_attempts["$ip"]} -ge 3 ]]; then
        if ! grep -q "$ip" $BLOCKED_IPS; then  #To check if it is already blocked in iptables
            block_ip "$ip"
        fi
    fi
done

echo "Login audit completed."

# Step 1: Run manually => ./login_audit.sh

# Step 2: Edit crontab to run periodically => crontab -e

# Step 3: To run script every 5 minutes => */5 * * * * /path/to/login_audit.sh