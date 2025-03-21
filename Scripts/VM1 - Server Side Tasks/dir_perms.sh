#!/bin/bash

# Print green message
print_status() {
    echo -e "\e[1;32m[✔] $1\e[0m"
}

# Print red message
print_error() {
    echo -e "\e[1;31m[✘] $1\e[0m"
}

# Ensure ACL is installed, if it's not install then make sure that it is
if ! dpkg -l | grep -q acl; then
    echo "Installing ACL package..."
    sudo apt update && sudo apt install -y acl
    print_status "ACL package installed."
fi

# Create directory structure
echo "Creating directory structure..."
sudo mkdir -p /projects/development/source
sudo mkdir -p /projects/development/builds
sudo mkdir -p /var/operations/monitoring
sudo mkdir -p /var/operations/reports
print_status "Directory structure created."

# Set permissions for developers group
echo "Applying ACL permissions..."
sudo setfacl -m g:developers:rwx /projects/development/source
print_status "Full access granted to 'developers' for /projects/development/source."

sudo setfacl -m g:developers:r /projects/development/builds
print_status "Read-only access granted to 'developers' for /projects/development/builds."

# Set permissions for monitoring group
sudo setfacl -m g:monitoring:r /var/operations/reports
print_status "Read-only access granted to 'monitoring' for /var/operations/reports."

# Verify ACL settings
echo -e "\nVerifying ACL settings..."
getfacl /projects/development/source
getfacl /projects/development/builds
getfacl /var/operations/reports

# Successful run of the dir_perms script
print_status "ACL permissions have been successfully applied!"
