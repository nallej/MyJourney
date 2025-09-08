#!/usr/bin/env bash
### Extend the life of SSDs on a stand-alone Proxmox node
# Run as root 
# wget https://github.com/nallej/MyJourney/raw/main/scripts/MinSSDwear.sh
clear
echo Copyright (c) 2022-$(date +%Y) CasaUrsus
echo Author: nallej (CasaUrsus)
echo License: MIT see @ https://github.com/nallej/MyJourney/raw/main/LICENSE
echo

## No cluster stuff, see Proxmox docs and wiki
systemctl disable --now pve-ha-lrm
systemctl disable --now pve-ha-crm
systemctl disable --now corosync.service

## Swappines added and set to 10, see Proxmox docs and wiki
echo vm.swappines = 10 >> /etc/sysctl.conf

## Log2RAM from https://azlux.fr/ – via apt 
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bookworm main>
wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
apt update
apt install log2ram
systemctl restart log2ram

systemctl status log2ram

echo "See your logged data: journalctl -u log2ram -e"
