#!/bin/bash
# Create a VM running Docker & Dockge for our stacks
# Run as normal user in ~/
# wget https://github.com/nallej/MyJourney/raw/main/scripts/DoDoU.sh

# Make the directory for oure stacks
mkdir -p /home/$USER/docker/
# refresh and upgrade
sudo apt update && sudo apt upgrade -y
# Prerequisits
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
# GPG docker-archive-keyring
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
# Houskeeping
sudo apt update
apt-cache policy docker-ce
# Install Docker-ce, community edition and not the licenced one
sudo apt install -y docker-ce

# Add Dockge container
sudo docker run -d -p 5001:5001 --name Dockge --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v /home/$USER/docker/dockge/data:/app/data -v /home/$USER/docker/stacks:/home/$USER/docker/stacks -e DOCKGE_STACKS_DIR=/home/$USER/docker/stacks louislam/dockge:latest

# extra stuff
#systemctl start docker.service
#systemctl status docker.service
#sleep 5
#systemctl enable docker.service

# While you can run Docker as a root user, doing so is discouraged,
# because of potential security risks and accidental modifications to your host system. 
# Instead, manage Docker operations under a non-root user account to enhance security.
#
# sudo useradd -m $USER -p userPASSWORD  #dockeruser, -m create home directory -p password
# sudo adduser $USER sudo                 # Superuser
sudo usermod -aG docker $USER           #dockeruser
