#!/bin/bash

# Variables
SSH_USER="ssh-user"
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsptjW30R0+NX0eU8jggplU3VfJ9rGZM7zXYjSyLyvYnZdILaSTe9kmF6d3VK9mgPo8o6cz1Me1G77oMDqoKk4xV0CWEqE7Hpl8sWsL/Em6D4/fZSBAX3MzuNW1s7cZd7shWMffNDZNiAv+x/cVkhTDh7zqNR88h9E1EkqHRa+8r2Wu4xNCfeHo1q/9bMjUxxRdUTOt3QKjSE8Hyb3Gaa8Lny0UymABx9Zg1XC3X1GOazly++iFLDeKV4IW54DBqjzhqLgMC3rGBTODPC66mG+O4FwNWUJFAdwili0BRClB5c7b4AJVEtYzOG9sBh9cMcos7JB9CeAj+1vPFz+XraT"

# Ensure SSH is installed
if ! command -v sshd &>/dev/null; then
  echo "OpenSSH is not installed. Installing OpenSSH..."
  apt update && apt install -y openssh-server
fi

# Start and enable SSH service
systemctl start ssh
systemctl enable ssh

# Ensure SSH key authentication is allowed
SSHD_CONF="/etc/ssh/sshd_config"
if [ ! -f "$SSHD_CONF.bak" ]; then
  echo "Backing up original SSH configuration..."
  cp "$SSHD_CONF" "$SSHD_CONF.bak"
fi

# Update SSH configuration to ensure key authentication is allowed
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD_CONF
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' $SSHD_CONF

# Restart SSH service to apply changes
systemctl restart ssh

# Create the user and set up the SSH key
echo "Creating user $SSH_USER and setting up SSH key..."
if ! id "$SSH_USER" &>/dev/null; then
  useradd -m -s /bin/bash "$SSH_USER"
fi

USER_SSH_DIR="/home/$SSH_USER/.ssh"
mkdir -p "$USER_SSH_DIR"
echo "$SSH_KEY" > "$USER_SSH_DIR/authorized_keys"
chmod 700 "$USER_SSH_DIR"
chmod 600 "$USER_SSH_DIR/authorized_keys"
chown -R "$SSH_USER:$SSH_USER" "$USER_SSH_DIR"

# Verify the setup
if ssh-keygen -F localhost | grep -q localhost; then
  echo "SSH setup successfully! The Scoring Engine should be able to authenticate using the provided key."
else
  echo "SSH setup failed. Please check the configuration."
fi