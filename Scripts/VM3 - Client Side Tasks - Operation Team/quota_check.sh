#!/bin/bash

# Install the below and setup mail
# sudo apt install msmtp msmtp-mta mailutils

# Email alert recipient
email="jafm.projects@gmail.com"

# Remote server (VM1)
devVM1="dev_lead1"
opsVM1="ops_lead1"
ipVM1="192.168.10.128"

# Quota warning limits (in KB)
SOFT_dev=$((5 * 1024 * 1024))   
HARD_dev=$((6 * 1024 * 1024))   
SOFT_ops=$((3 * 1024 * 1024))   
HARD_ops=$((4 * 1024 * 1024))

# Fetch remote quota usage
ssh "$devVM1@$ipVM1" bash <<'EOF' > /tmp/remote_quotas.txt
quota -u dev_lead1 | awk 'NR==3 {print "dev_lead1", $2}'
EOF

ssh "$opsVM1@$ipVM1" bash <<'EOF' >> /tmp/remote_quotas.txt
quota -u ops_lead1 | awk 'NR==3 {print "ops_lead1", $2}'
EOF

#quota -u dev_lead1 | awk '/^\/.*shared/ {print "dev_lead1", $2}'
#quota -u ops_lead1 | awk '/^\/.*shared/ {print "ops_lead1", $2}'

# Compare usage and send alerts
while read -r user usage; do
    if [[ "$user" == "dev_lead1" ]]; then
        if (( usage > SOFT_dev )); then
            echo "$user exceeded the 5GB soft limit. Usage: $usage KB" \
            | mail -s "Quota Warning: $user" "$email"
        fi
        if (( usage > HARD_dev )); then
            echo "$user exceeded the 6GB hard limit. Usage: $usage KB" \
            | mail -s "Quota Critical: $user" "$email"
        fi
    elif [[ "$user" == "ops_lead1" ]]; then
        if (( usage > SOFT_ops )); then
            echo "$user exceeded the 3GB soft limit. Usage: $usage KB" \
            | mail -s "Quota Warning: $user" "$email"
        fi
        if (( usage > HARD_ops )); then
            echo "$user exceeded the 4GB hard limit. Usage: $usage KB" \
            | mail -s "Quota Critical: $user" "$email"
        fi
    fi
done < /tmp/remote_quotas.txt

rm -f /tmp/remote_quotas.txt

echo "Monitored Quota at $(date)" | mail -s "Quota Monitoring" $email
echo "✅ Quota monitoring completed."

