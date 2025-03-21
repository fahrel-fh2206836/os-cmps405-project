#!/bin/bash

# Print green message
print_status() {
    echo -e "\e[1;32m[✔] $1\e[0m"
}

# Print red message
print_error() {
    echo -e "\e[1;31m[✘] $1\e[0m"
}

# Create groups
groups=("developers" "dev_leads" "operations" "ops_admin" "monitoring")

echo "Creating groups..."
for group in "${groups[@]}"; do
    if sudo groupadd "$group"; then
        print_status "Group '$group' created successfully."
    else
        print_error "Failed to create group '$group' (it may already exist)."
    fi
done

# Create users and assign them to groups
echo "Creating users and assigning group memberships..."
declare -A users
users=(
    ["dev_lead1"]="developers,dev_leads"
    ["ops_lead1"]="operations,ops_admin"
    ["ops_monitor1"]="operations,monitoring"
)

for user in "${!users[@]}"; do
    if id "$user" &>/dev/null; then
        print_error "User '$user' already exists, skipping..."
    else
        if sudo useradd -m -G "${users[$user]}" "$user"; then
            print_status "User '$user' created and assigned to groups: ${users[$user]}."
        else
            print_error "Failed to create user '$user'."
        fi
    fi
done

# Add specified users to the sudo group
echo "Granting sudo privileges..."
sudoers=("dev_lead1" "ops_lead1")

for sudo_user in "${sudoers[@]}"; do
    if sudo usermod -aG sudo "$sudo_user"; then
        print_status "User '$sudo_user' granted sudo privileges."
    else
        print_error "Failed to grant sudo privileges to '$sudo_user'."
    fi
done

# Successful run of the user setup script
echo -e "\n\e[1;34mUser and group setup completed successfully!\e[0m" 