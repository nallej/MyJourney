#!/bin/bash
# Create a VM running Docker & Dockge for our stacks
# Run as normal user in ~/

# Make the directory for oure stacks
mkdir -p /home/$USER/docker/
# refresh and upgrade
apt update && apt upgrade -y
# Prerequisits
apt install -y apt-transport-https ca-certificates curl software-properties-common
# GPG docker-archive-keyring
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
# Housekeeping
sudo apt update
# Install Docker-ce
# sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt install -y docker-ce
# Install Dockge
sudo docker run -d -p 5001:5001 --name Dockge --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v /home/$USER/docker/dockge/data:/app/data -v /home/$USER/docker/stacks:/home/$USER/docker/stacks -e DOCKGE_STACKS_DIR=/home/$USER/docker/stacks louislam/dockge:latest

# extra stuff
#systemctl start docker.service
#systemctl status docker.service
#sleep 5
#systemctl enable docker.service

# While you can run Docker as a root user, doing so is discouraged,
# because of potential security risks and accidental modifications to your Debian host system. 
# Instead, manage Docker operations under a non-root user account to enhance security.
#sudo useradd -m $USER -p userPASSWORD  #dockeruser, -m create home directory -p password
sudo usermod -aG docker $USER           #dockeruser
