#!/bin/bash

# Variables
VM1_IP="192.168.151.123"  # Place the current IP of VM 1
VM1_USER="server" 
LOG_FILE="/home/vm2dev/invalid_attempts.log" # The files should be under the current user profile of VM2
BLOCKED_IPS="/home/vm2dev/blocked_ips.txt"
VM1_PASSWORD="123" 


# Create the blocked_ips.txt file if it doesn't exist
if [[ ! -f "$BLOCKED_IPS" ]]; then
    touch "$BLOCKED_IPS"
    echo "Created $BLOCKED_IPS"
fi


# Function to block IP using iptables on VM1
block_ip() {
    local ip=$1
    echo "Blocking IP: $ip"
    ssh $VM1_USER@$VM1_IP "echo '$VM1_PASSWORD' | sudo -S iptables -A INPUT -s $ip -j DROP" # Command for blocking the ip using iptables
    echo "$ip" >> $BLOCKED_IPS
}

# Fetch SSH logs from VM1
echo "Fetching SSH logs from VM1..."
ssh $VM1_USER@$VM1_IP "echo $VM1_PASSWORD | sudo -S grep 'Failed password' /var/log/auth.log" > /tmp/ssh_failed_logs.txt

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
        if ! grep -q "$ip" $BLOCKED_IPS; then  #To check if it is already blocked
            block_ip "$ip"
        fi
    fi
done

echo "Login audit completed."

# Step 1: Run manually => ./login_audit.sh

# Step 2: Edit crontab to run periodically => crontab -e

# Step 3: To run script every 5 minutes => */5 * * * * /path/to/login_audit.sh
