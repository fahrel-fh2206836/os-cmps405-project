# If not installed
sudo apt-get install quota quotatool

# Create /shared directory
mkdir -p /shared
chmod 777 /shared

# Quota limits (in KB)
ONE_GB=$((1024 * 1024))
SOFT_dev=$((5 * ONE_GB))  
HARD_dev=$((6 * ONE_GB))   
SOFT_ops=$((3 * ONE_GB))   
HARD_ops=$((4 * ONE_GB))  


echo "Enabling quota support..."

# Ensure / is mounted with usrquota
mount | grep / | grep -q usrquota
if [ $? -ne 0 ]; then
    sed -i 's/errors=remount-ro/&,usrquota/' /etc/fstab
    mount -o remount,usrquota /
else
    echo "✅ usrquota already enabled on /"
fi

# Initialize quota files
echo "Running quotacheck..."
quotacheck -cum /

# Turn on quota
echo "Turning quota on..."
quotaon /
# Apply quotas to users
echo "Setting quota limits on dev_lead1 & ops_lead1..."

setquota -u dev_lead1 $SOFT_dev $HARD_dev 0 0 /
setquota -u ops_lead1 $SOFT_ops $HARD_ops 0 0 /

echo "✅ Quotas applied"
