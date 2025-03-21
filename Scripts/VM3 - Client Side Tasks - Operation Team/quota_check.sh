#!/bin/bash

# ========== CONFIG ==========

VM1_USER="admin"                   # Remote user
VM1_IP="192.168.1.100"             # Remote VM1 IP
EMAIL="admin@qu.edu.qa"           # Alert email

# Quotas in KB
SOFT_dev=5000000   # 5GB
HARD_dev=6000000   # 6GB
SOFT_ops=3000000   # 3GB
HARD_ops=4000000   # 4GB

# ========== ENABLE & SET QUOTAS ON VM1 ==========

echo "🔧 Enabling quota system and applying limits on VM1 ($VM1_IP)..."

ssh "$VM1_USER@$VM1_IP" <<EOF
# Install quota tools if missing
sudo apt-get install quota quotatool

# Remount filesystem with quota options
sudo mount -o remount,usrquota /

# Initialize and enable quota
sudo quotacheck -cum /
sudo quotaon /

# Set user quotas
sudo setquota -u dev_lead1 $SOFT_dev $HARD_dev 0 0 /
sudo setquota -u ops_lead1 $SOFT_ops $HARD_ops 0 0 /
EOF

echo "✅ Quota system enabled and user limits applied."

# ========== CHECK USAGE & SEND ALERTS ==========

# Get usage remotely
ssh "$VM1_USER@$VM1_IP" << 'EOF'
quota -u dev_lead1 | awk 'NR==3 {print "dev_lead1", $2}'
quota -u ops_lead1 | awk 'NR==3 {print "ops_lead1", $2}'
EOF
> /tmp/remote_quotas.txt

# Compare and alert
while read user usage; do
    if [[ "$user" == "dev_lead1" ]]; then
        if [[ "$usage" -gt "$SOFT_dev" ]]; then
            echo "$user exceeded the 5GB soft limit. Usage: $usage KB" \
            | mail -s "Quota Warning: $user" $EMAIL
        fi
        if [[ "$usage" -gt "$HARD_dev" ]]; then
            echo "$user exceeded the 6GB hard limit. Usage: $usage KB" \
            | mail -s "Quota Critical: $user" $EMAIL
        fi
    elif [[ "$user" == "ops_lead1" ]]; then
        if [[ "$usage" -gt "$SOFT_ops" ]]; then
            echo "$user exceeded the 3GB soft limit. Usage: $usage KB" \
            | mail -s "Quota Warning: $user" $EMAIL
        fi
        if [[ "$usage" -gt "$HARD_ops" ]]; then
            echo "$user exceeded the 4GB hard limit. Usage: $usage KB" \
            | mail -s "Quota Critical: $user" $EMAIL
        fi
    fi
done < /tmp/remote_quotas.txt

rm /tmp/remote_quotas.txt

