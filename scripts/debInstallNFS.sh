#!/usr/bin/env bash
# Setup a NFS Server

clear

# Init Variables
initSUB=10.10.40.0
initSRV=10.10.40.40
dirNAME=139 # Last Octet of SRV IP

# No EDIT beyound thtis point =============================================== #

# Functions ------------------------------------------------------------------#

function setroot() { # Function I am root or not
if [[ "$EUID" = 0 ]]; then
    echo -e "\nInitialaizing:"          # I am root
else
    sudo -k
    if sudo true; then                  # Correct password
        clear
        echo -e "\nStart My Code what ever it's"
        echo -e "\nInitialaizing..."
    else
        echo "wrong password!"
        exit                            #exit if 3 times wrong
    fi
fi
}

function serverNFS() { # setting up the NFS-Server 
sudo mkdir -p /exports/{backup,documents,films,music,photos}
sudo apt-get update && sudo apt-get -y install nfs-kernel-server
sudo cp /etc/exports /etc/exports.orig
sudo sh -c "echo '/exports/backup $srvIP/255.255.255.0(rw,no_subtree_check) # subnets allowed' >> /etc/exports"
sudo sh -c "echo '/exports/documents $srvIP/255.255.255.0(rw,no_subtree_check) # subnets allowed' >> /etc/exports"
sudo sh -c "echo '/exports/films $srvIP/255.255.255.0(rw,no_subtree_check) # subnets allowed' >> /etc/exports"
sudo sh -c "echo '/exports/music $srvIP/255.255.255.0(rw,no_subtree_check) # subnets allowed' >> /etc/exports"
sudo sh -c "echo '/exports/photos $srvIP/255.255.255.0(rw,no_subtree_check) # subnets allowed' >> /etc/exports"
sudo systemctl restart nfs-kernel-server
sudo systemctl status nfs-kernel-server
echo "You might need to reboot for the NFS Server for it to work"
}

function clientNFS() {
# Setting up a NFS-Server Client --- EDIT befor running script ---
sudo apt-get update && sudo apt-get -y install nfs-common autofs
sudo apt-get -y install autofs
# EDIT 139 should be the last octet of the server
mkdir /srv/nfs/$dirNAME/
echo "/srv/nfs/$dirNAME/ /etc/auto.nfs --ghost --timeout=60" >> /etc/auto.master
echo "backup -fstype=nfs4,rw $cliIP:/exports/backup" >> /etc/auto.nfs
echo "documents -fstype=nfs4,rw $cliIP:/exports/documents" >> /etc/auto.nfs
echo "films -fstype=nfs4,rw $cliIP:/exports/films" >> /etc/auto.nfs
echo "music -fstype=nfs4,rw $cliIP:/exports/music" >> /etc/auto.nfs
echo "photos -fstype=nfs4,rw $cliIP:/exports/photos" >> /etc/auto.nfs
sudo systemctl restart autofs
}


setroot
# M A I N  C O D E section ==================================================#
backt="setupNFS.sh is part of the My HomeLab Journey Project"  # Background text

if whiptail --backtitle "$backTEXT" --title "Create a NFS Server or a NFS Client" --yesno "Install a Server or a Client " 10 68 --no-button "Server" --yes-button "Client"; then
    srvIP=$(whiptail --backtitle "$backTEXT"  --title "Create NFS Client" --inputbox "Server IP" 10 58 $initSRV 3>&1 1>&2 2>&3)
    clientNFS
  else
    subIP=$(whiptail --backtitle "$backTEXT" --title "Create NFS Server" --inputbox "Subnet" 10 58 $initSUB 3>&1 1>&2 2>&3)
    serverNFS
fi
