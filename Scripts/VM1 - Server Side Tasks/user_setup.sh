#!/bin/bash

# ✅ Green status message
print_status() {
    echo -e "\e[1;32m[✔] $1\e[0m"
}

# ❌ Red error message
print_error() {
    echo -e "\e[1;31m[✘] $1\e[0m"
}

# Create Groups
echo "Creating groups..."
for group in developers dev_leads operations ops_admin monitoring; do
    if getent group "$group" > /dev/null; then
        print_error "Group '$group' already exists."
    else
        sudo groupadd "$group"
        print_status "Group '$group' created."
    fi
done

# Create Users and Add to Groups
echo "Creating users and assigning groups..."

# dev_lead1 → developers + dev_leads
if id dev_lead1 &>/dev/null; then
    print_error "User 'dev_lead1' already exists."
else
    sudo useradd -m -G developers,dev_leads dev_lead1
    print_status "User 'dev_lead1' created and added to groups."
fi

# ops_lead1 → operations + ops_admin
if id ops_lead1 &>/dev/null; then
    print_error "User 'ops_lead1' already exists."
else
    sudo useradd -m -G operations,ops_admin ops_lead1
    print_status "User 'ops_lead1' created and added to groups."
fi

# ops_monitor1 → operations + monitoring
if id ops_monitor1 &>/dev/null; then
    print_error "User 'ops_monitor1' already exists."
else
    sudo useradd -m -G operations,monitoring ops_monitor1
    print_status "User 'ops_monitor1' created and added to groups."
fi

# Set User Passwords
echo "Setting passwords..."
echo "dev_lead1:Dev@123" | sudo chpasswd && print_status "Password set for dev_lead1."
echo "ops_lead1:Ops@123" | sudo chpasswd && print_status "Password set for ops_lead1."
echo "ops_monitor1:Mon@123" | sudo chpasswd && print_status "Password set for ops_monitor1."

# Grant Sudo Access
echo "Adding sudo privileges..."
sudo usermod -aG sudo dev_lead1 && print_status "Sudo access given to dev_lead1."
sudo usermod -aG sudo ops_lead1 && print_status "Sudo access given to ops_lead1."

# 🎉 Done
echo -e "\n\e[1;34mAll users and groups set up successfully!\e[0m"
