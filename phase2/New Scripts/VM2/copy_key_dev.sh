#!/bin/bash

# === CONFIG ===
DEV_LEAD="dev_lead1"
VM1_IP="192.168.18.4"
SSH_KEY="$HOME/.ssh/id_rsa"

# === Generate SSH Key (if not exists) ===
if [ ! -f "$SSH_KEY" ]; then
    echo "[+] Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
else
    echo "[✔] SSH key already exists at $SSH_KEY"
fi

# === Copy Public Key to VM1 ===
echo "[+] Copying public key to $DEV_LEAD@$VM1_IP..."
ssh-copy-id -i "${SSH_KEY}.pub" "$DEV_LEAD@$VM1_IP"

echo "[✔] Key copied. You can now SSH without password:"
echo "    ssh $DEV_LEAD@$VM1_IP"
