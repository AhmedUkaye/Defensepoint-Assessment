#!/bin/bash

set -e  # Exit immediately on errors

echo "[*] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# --- Install dependencies ---
echo "[*] Installing dependencies..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg-agent \
    git

# --- Install Docker ---
echo "[*] Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# --- Install Docker Compose ---
echo "[*] Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# --- Enable basic system logging ---
echo "[*] Setting up rsyslog..."
sudo apt-get install -y rsyslog
sudo systemctl enable rsyslog
sudo systemctl start rsyslog

# --- Deploy Wazuh (Single-node) ---
echo "[*] Cloning Wazuh Docker repo..."
cd /home/ubuntu
if [ ! -d wazuh-docker ]; then
    git clone https://github.com/wazuh/wazuh-docker.git
fi
cd wazuh-docker/single-node

# Optional: Copy custom docker-compose if uploaded via Terraform
if [ -f /home/ubuntu/docker-compose.yml ]; then
  cp /home/ubuntu/docker-compose.yml ./docker-compose.yml
fi

echo "[*] Starting Wazuh containers..."
sudo docker-compose -f docker-compose.yml up -d

echo "[✔] Wazuh deployment complete on Ubuntu EC2."
