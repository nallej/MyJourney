#!/bin/bash

# myTempBuilder.sh
# Part of the MyJourney project @ homelab.casaursus.net
#
# Created by Nalle Juslén version 1.0 29.11.2022, v. 1.1 1.12.2022
#   version 2.0 4.1.2023, v. 2.1 9.1.2023, v. 2.2 29.1.2023
#   version 3.0 30.5.2023, v. 3.1 31.5.2023, v. 3.2 1.6.2023, v. 3.3 12.10.2023
#   version 4.0 12.10.2023
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
#
# This is free software; you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
#

#-----------------------------------------------------------------------------#
# For more info see: https://pve.proxmox.com/pve-docs/qm.conf.5.html          #
# Date format and >>>> ---- <<<< **** for easy sorting                        #
#-----------------------------------------------------------------------------#

# Install this script by:
#  - open a terminal in the Proxmox node as root
#  - run wget://https://raw.githubusercontent.com/nallej/MyJourney/main/myTemplateBuilder.sh
#  - chmod +x myTemplateBuilder.sh
#

# Edit the script is very important:
#  - set memory size
#  - # of cores
#  - what apps do you need
#  - VM settings
#  or upload your puplic key to use for auto creation to:
#  - ~/.ssh/my_key

# This script generate a workin VM or a Template or a set of VMs 
# The functionallity is detemend by your Y/N answers 

# Global Functions ===========================================================#

useColors() # Function: define colors to be used
{
    # color code   color as bold
    red=$'\e[31m'; redb=$'\e[1;31m' # call red with $red and bold as $redb
    grn=$'\e[32m'; grnb=$'\e[1;32m' # call as green $grn as bold green $grnb
    yel=$'\e[33m'; yelb=$'\e[1;33m' # call as yellow $yel as bold yellow $yelb
    blu=$'\e[34m'; blub=$'\e[1;34m' # call as blue $blu as bold blue $blub
    mag=$'\e[35m'; magb=$'\e[1;35m' # call as magenta $mag as bold magenta $magb
    cyn=$'\e[36m'; cynb=$'\e[1;36m' # call as cyan $cyn as cyan bold $cynb
    end=$'\e[0m'

    #Use them to print with colours: printf "%s\n" "Text in white ${blu}blue${end}, white and ${mag}magenta${end}."
}

spinner() # Function: display a animated spinner
{
# The different Spinner Arrays to choose from
local array1=("◐" "◓" "◑" "◒")
local array2=("░" "▒" "▓" "█")
local array3=("╔" "╗" "╝" "╚")
local array4=("┌" "┐" "┘" "└")
local array5=("▄" "█" "▀" "█")
local array6=('-' '\' '|' '/') # L to R
local array7=('-' '/' '|' '\') # R to L
local array9=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

local delays=0.1 # Delay between each characte

tput civis # Hide cursor and spinn

  while :; do
    for character in "${array9[@]}"; do # Use this Array
        printf "%s" "$character"
        sleep "$delays"
        printf "\b"  # Move cursor back
    done
  done
}

# Local Functions ========================================#

guestfs() # Function: install the libguestfs-tools
{
    apt-get update
    apt-get install -y libguestfs-tools
}

getUbuntu() # Function: get a Cloud Image, Ubuntu as example, CIs are allway up to date 
# It's a .qcow2 fil with the extension .img - we turn it back to .qcow2
{
    if [[ $mini == [yY] ]]; then
       if [[ -f "mini.qcow2" && $upd == [yY] ]]; then
              cp mini.qcow2 base.qcow2
           else
          wget -O mini.qcow2 https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
          cp mini.qcow2 base.qcow2
           fi
    else
          if [[ -f std.qcow2 && $upd == [yY] ]]; then
             cp std.qcow2 base.qcow2
          else
         wget -O std.qcow2 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
         cp std.qcow2 base.qcow2
          fi
    fi
}

createBase() # Function: create a fully loaded base ISO ### Set the Disk size ### set the apps needed ####
             # Add QEMU Guest Agent and any other packages you’d like in your base image.
             # libguestfs-tools has to be installed on the node!
             # Add or delete functionallity according to your needs
             # virt-customize -a /path/to/your/vm-image.qcow2 --firstboot /path/to/your/firstboot-script.sh
             # virt-customize -a base.qcow2 --firstboot.sh
{
    qemu-img resize base.qcow2 $ds #16G is typical - Resize the disk to your needs, 8 - 32G is normal

    if [[ $o1 == [yY] ]]; then virt-customize -a base.qcow2 --install qemu-guest-agent ; fi      # o1 Highly recommended    
    if [[ $o2 == [yY] ]]; then virt-customize -a base.qcow2 --install nano, ncurses-term ; fi    # o2 I like it
    if [[ $o4 == [yY] ]]; then virt-customize -a base.qcow2 --install git ; fi                   # o3 moustly needed 
    if [[ $o5 == [yY] ]]; then virt-customize -a base.qcow2 --install unattended-upgrades ; fi   # o4 good feature
    if [[ $o6 == [yY] ]]; then virt-customize -a base.qcow2 --install fail2ban ; fi              # o5 highly recommended
    if [[ $o7 == [yY] ]]; then virt-customize -a base.qcow2 --install clamav, clamav-daemon ; fi # o6 highly recommended
    if [[ $o9 == [yY] ]]; then virt-customize -a base.qcow2 --install mailutils ; fi             # o7 might be needed
    if [[ $o8 == [yY] ]]; then
       virt-customize -a base.qcow2 --firstboot-command 'sudo apt-get update' 
       virt-customize -a base.qcow2 --firstboot-command 'sudo apt-get install -y wget curl containerd software-properties-common'
       virt-customize -a base.qcow2 --firstboot-command 'sudo apt-get update'
       virt-customize -a base.qcow2 --firstboot-command 'curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | sudo dd status=none of=/usr/share/keyrings/kubernetes-archive-keyring.gpg'
       virt-customize -a base.qcow2 --firstboot-command 'echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list'
       #virt-customize -a base.qcow2 --firstboot-command 'sudo apt-get update && sudo apt-get upgrade'
       virt-customize -a base.qcow2 --firstboot-command 'sudo swapoff -a'
       virt-customize -a base.qcow2 --mkdir /etc/containerd
       virt-customize -a base.qcow2 --firstboot-command 'containerd config default | sudo tee /etc/containerd/config.toml'
       virt-customize -a base.qcow2 --firstboot-command 'echo "br_netfilter" > /etc/modules-load.d/k8s.conf'
       virt-customize -a base.qcow2 --firstboot-command 'sed -i "s/^\( *SystemdCgroup = \)false/\1true/" /etc/containerd/config.toml'
       virt-customize -a base.qcow2 --firstboot-command 'sed -i -e "/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1" etc/sysctl.conf'
       virt-customize -a base.qcow2 --firstboot-command 'sudo apt-get update && sudo apt install -y kubeadm kubectl kubelet'
       virt-customize -a base.qcow2 --firstboot-command 'sudo truncate -s 0 /etc/machine-id'
       virt-customize -a base.qcow2 --firstboot-command 'sudo rm /var/lib/dbus/machine-id'
       virt-customize -a base.qcow2 --firstboot-command 'sudo ln -s /etc/machine-id /var/lib'
    fi
}    

createVM() # Funtion: creat a VM or a Template using a CI #### EDIT THE DEFAULTS ####
{
        # Choose RAM, Disk size, # of cores, what bridge to use. virtio is mandatory
        if [[ $mini == [yY] ]] ; then
                if [[ $tname < ' ' ]]; then tname='ubuntu-mini' ; fi
          else
                if [[ $tname < ' ' ]]; then tname='ubuntu-std' ; fi
        fi
        # if [[ $tno <  1 ]]; then tno=8000 ; fi
        # if [[ $ms < 1 ]]; then ms=1024 ; fi
        # if [[ $cc < 1 ]]; then cc=1 ; fi
        # if [[ $vmbr  ]]; then vmbr=vmbr2 ; fi
        # if [[ $storage < ' ' ]]; then storage=tank; fi

        # Creare the base image ----------------------------------------------#
        ibase=$tno --memory $ms --core $cc --name $tname --net0 virtio,bridge=$vmbr
        if [[ tag > 0 ]]; then ibase="{$ibase},tag=$vlan"; fi
        qm create $ibase

        # Set options --------------------------------------------------------#

        qm importdisk $tno base.qcow2 $storage                                # Import the disc to the base of the template. Where to put the VM local-lvm
        qm set $tno --scsihw virtio-scsi-pci --scsi0 $storage:vm-$tno-disk-0  # Attache the disk to the base of the template
        qm set $tno --ide2 $storage:cloudinit                                 # Attach the cloudinit file - you might need to EDIT it later !
        qm set $tno --boot c --bootdisk scsi0                                 # Make the cloud init drive bootable and only boot from this disk
        qm set $tno --serial0 socket --vga serial0                            # Add serial console, to be able to see console output!
        qm set $tno --onboot 1                                                # Autostart vm at boot - default is 0 - Ususlly most VM's are allway running
        qm set $tno --agent 1                                                 # Use Qemu Guest Agent - default is 0
        qm set $tno --ostype l26                                              # Set OS type Linux 5.x kernel 2.6 - default is other
        qm set $tno --ipconfig0 ip="dhcp"                                     # Set dhcp on
        qm set $tno --ciuser $ciu                                             # "admin"        use your imagination
        qm set $tno --cipassword $cip                                         # "Pa$$w0rd"     use a super complicated one
        if [[ $my_key == [yY] ]]; then qm set $tno --sshkey ~/.ssh/my_key; fi # sets the users key to the vm

        ## More automation can be added to cloud-init, examples below ------------#
        # 1. copy your public key to the node or copy it later to the VM
                #ssh-copy-id -i ~/.ssh/id_ed25519 username@pve.lab.example.com

        # 2. use a bootstrap file at the initial boot <directory> that can have snippets.
        # You need to check the status of the Storage Manager and set according to yours
        # pvesm status
        # pvesm set local --content backup,iso,snippets,vztmpl
        # qm set $tno --cicustom "vendor=<local>:snippets/vendor.yaml"
}

createTemplate() # Function: Create the template ex. 9000
{
    if [[ $tok == [yY] ]]; then qm template $tno; fi
    sleep .5
}

createClones() # Function: Cloning the template
{
    if [[ $ctno -gt 0 ]]; then
        x=0
        while [ $x -lt $ctno ]
        do
            xx=$(($fcno + $x))
            x=$(( $x + 1 ))
            qm clone $tno $xx --name $cname$x --full
        done
    fi
}

# Code Section ===============================================================#

useColors        # Use color codes
clear            # Clear the screan
#Init the log
echo ">>>> Started the Install  @ $(date +"%F %T") ****  ****" > ~/installMTB.log

# Main Script ================================================================#

# Main menu ------------------------------------------------------------------#
printf ${mag}" This script will create Templates and or VM's for your node."${end}
echo " "
echo -e " ${redb}NOTE${end} - libguestfs-tools is needed. Pls installe it on the this node"
echo -e "${cyn}"
echo "  Remember to edit the script before executing: "
echo "    - base settings are 1 core and 1024M RAM"
echo "    - normal disk size for a VM is 8-16G or sometimes 32G"
echo "    - Enter Disk size as ${redb}8G${end}${cyn} NOT 8 !"
echo -e "    - OS = L26, IP = DHCP, QGA = on, Autostart = off ${end}"
echo ""
echo -e " ${yelb}Start the configuration${end}"
read -rp "    Install the libguestfs-tools Now  [y/N] : " gfs
echo -e " ${magb}  Creating the Base Image from a Cloud image${end}"
read -rp "    Use existing ISO-image        [y/N] : " upd
read -rp "     - Use a minimal Ubuntu image     [y/N] : " mini
read -rp "     - Disk size (8, 16 or 32G) e.g     8G : " ds
read -rp "     - Memory (1024 is plenty)  e.g.  1024 : " ms
read -rp "     - Core count (1 is plenty) e.g.     1 : " cc
read -rp "     - Set vmbr to be used      e.g. vmbr2 : " vmbr
read -rp "       - Set vlan tag           e.g.  0=no : " vlan
echo -e " ${yelb}  Options:${end}"
read -rp "     +  qemu-guest-agent             [y/N] : " o1
read -rp "     +  nano editor, ncurses-term    [y/N] : " o2
read -rp "     +  git                          [y/N] : " o3
read -rp "     +  unattended-upgrades          [y/N] : " o4
read -rp "     +  fail2ban                     [y/N] : " o5
read -rp "     +  clamav, clamav-daemon        [y/N] : " o6
read -rp "     +  mailutils                    [y/N] : " o7
read -rp "     +  make K8s settings            [y/N] : " o8
#read -rp "     +  containerd                   [y/N] : " o9
#read -rp "     +  Docker-ce                    [y/N] : " o10
#read -rp "     +  Portainer ce                 [y/N] : " o11
echo -e " ${magb}  Settings for the VM or Template + VMs${end}"
read -rp "   - Set VM / Template ID       e.g.  9000 : " tno
read -rp "     - Set VM / Template name   e.g.  mini : " tname
read -rp "     - Storage to use       e.g. local-zfs : " storage
read -rp "   - Create with CI user    e.g.     admin : " ciu
#echo -n "     - create with CI user password     : "
#ead -sp "     - create with CI user password ****** : " cip
echo -n "    - "
cip="$(systemd-ask-password "Enter the password:")"
read -rp "     - set key from ~/.ssh/my_key    [y/N] : " my_key
echo -e " ${magb}  Settings for Templates and VMs${end}"
read -rp "   - Create as a Template id $tno    [y/N] : " tok

if [[ $tok == [yY] ]]; then
    read -rp "   - Create # clones of $tno    0=no clones: " ctno
    if [[ $ctno -gt 0 ]]; then
        read -rp "     - ID number for first clone e.g. 5000 : " fcno
        if [ $ctno = 1 ]; then
           xz=$fcno
        else
           xz=$(($fcno + $ctno))
        fi
        read -rp "     - name of clone's node1 to node$ctno       : " cname
        echo -e " ${yelb}  Creating Template with ID $tno, $ds"
        echo "     - creating cloned VM's $fcno - $xz"
        y=1
        echo -e "     - named as  $cname$y - $cname$ctno${end}"
    fi
else
    echo ""
    echo -e "${yelb}   - Creating a VM${end} $tname ${yelb}with ID${end} $tno ${yelb}Disk ${end}$ds"
fi
echo ""
read -rp " ${redb}Start the Install [y/N] : ${end}" ok
echo ""
# end of menu ----------------------------------------------------------------#

# init log
if [[ $ok == [yY] ]]; then
    # Run the spinner in the background and Save the PID
    spinner &
    spinner_pid=$!

    # Execute the functions --------------------------------------------------#
    if [[ $gfs == [yY] ]]; then
        (guestfs >> ~/installMTB.log 2>&1)
        printf "\b \n"
        echo "${grn} ✔${end}Installed libguestfs-tools"
        echo "---- * libguestfs-tools loaded @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    fi
    sleep .5

    echo "---->> Cloud Image creation    @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    (getUbuntu >> ~/installMTB.log 2>&1)
    printf "\b"
    echo "${grn} ✔${end}  Cloud Image downloaded"
    echo "---- * Cloud Image downloaded  @ $(date +"%F %T") ****  ****" >> ~/installMTB.log

    echo "---->> create base $ds image   @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    (createBase >> ~/installMTB.log 2>&1)
    printf "\b"
    echo "${grn} ✔${end}  base.qcow2 image created"
    echo "---- * base.qcov2 $ds done     @ $(date +"%F %T") ****  ****" >> ~/installMTB.log

    echo "---->> VM start create $(date +"%F %T") ****  ****" >> ~/installMTB.log
    (createVM >> ~/installMTB.log 2>&1)
    printf "\b"
    echo "${grn} ✔${end}  VM created, $tno-$tname"
    echo "---- * VM Created      $(date +"%F %T") ****  ****" >> ~/installMTB.log

    if [[ $tok == [yY] ]]; then
        echo "---->> Template creation       @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
        createTemplate &> /dev/null
        printf "\b"
        echo "${grn} ✔${end}  Template created, $tno-$tname"
        echo "---- * Template created        @ $(date +"%F %T") ****  ****" >> ~/installMTB.log

    fi
    if [[ $ctno -gt 0 ]]; then
        echo "---->> Clones creation start   @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
        createClones &> /dev/null
        printf "\b"
        echo "${grn} ✔${end}  Clone(s) created"
        echo "---- * Clones created          @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    fi
    # End of Execute Functions------------------------------------------------#
    echo "<<<< Installation ended OK     @ $(date +"%F %T") ****  ****" >> ~/installMTB.log

    # Terminate the Spinner
    kill "$spinner_pid"
    wait "$spinner_pid" 2>/dev/null

    # End messages
    if [[ $ctno -gt 0 ]]; then
       echo ""
       echo "Log created: ~/installMTB.log - check for errors"
       echo ""
    else
       echo ""
       #tput setaf 3
       #echo "Remember do NOT start the VM before making it into a template !"
       #tput sgr0
       #echo "Edit the Cloud-Init NOW ... then clone your VM's"
       #tput setaf 1
       #echo ""
       #echo "WARNING - Do  NOT  start the VM - WARNING"
       #tput sgr0
       # Alt way of output
       #useColors
       printf "%s\n" "Remember do ${red}NOT${end} to start the VM before making it into a template !"
       printf "%s\n" "Edit the Cloud-Init ${red}NOW${end} ... then clone your VM's"
       echo
       printf "%s\n" "${red}WARNING${end} - Do  ${red}NOT${end}  start the VM - ${red}WARNING${end}"
       sleep 1
       echo ""
       echo "Log created: ~/installMTB.log - Check for errors"
       echo ""
    fi
    sleep 2
else
    echo "<<<< Exited the Install   @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
fi
# Show the Cursor Again
tput cnorm

read -rp "Print the log [Y/n] : " pl
if [[ $pl == [yY] ]]; then cat ~/installMTB.log; fi

