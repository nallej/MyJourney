#!/bin/bash

#-----------------------------------------------------------------------------#
#  myTempBuilder.sh for Ubuntu 22.04 Servers                                  #
#  Part of the MyJourney project @ homelab.casaursus.net                      #
#                                                                             #
#  V.1 Created by Nalle Juslén 29.11.2022                                     #
#    -review 1.12.2022                                                        #
#                                                                             #
#  V.2 Created by Nalle Juslén 4.1.2023                                       #
#    - revison 9.1.2023, 29.1.2023                                            #
#                                                                             #
#  V.3 Created by Nalle Juslén 30.5.2023                                      #
#    - revison 31.5.2023, 1.6.2023, 12.10.2023                                #
#                                                                             #
# For more info see: https://pve.proxmox.com/pve-docs/qm.conf.5.html          #
# Date format and >>>> ---- <<<< **** for easy sorting                        #
#-----------------------------------------------------------------------------#

# Install this script by:
#  - open a terminal into the Proxmox node as root
#  - run wget://https://raw.githubusercontent.com/nallej/MyJourney/main/myTemplateBuilder.sh
#  - chmod +x myTemplateBuilder.sh
#

# Edit the script is very important:
#  - set memory size
#  - # of cores
#  - what apps do you need
#  - VM settings

# Upload your key to use for auto creation to:
#  - ~/.ssh/my_key


# Functions ==================================================================#

usecolors() # Function: define colors
{
    red=$'\e[1;31m'
    grn=$'\e[1;32m'
    yel=$'\e[1;33m'
    blu=$'\e[1;34m'
    mag=$'\e[1;35m'
    cyn=$'\e[1;36m'
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

guestfs() # Function: install the libguestfs-tools
{
    apt-get update
    apt-get install libguestfs-tools -y
}

getUbuntu() # Function: get a cloud image, Ubuntu as example, it's a .qcow2 fil with the extension img - we turn it back to .qcow2
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
{
    qemu-img resize base.qcow2 $ds #16G is typical - Resize the disk to your needs, 8 - 32G is normal
    # Add QEMU Guest Agent and any other packages you’d like in your base image.
    # libguestfs-tools has to be installed on the node.
    # Add or delete according to your needs
    virt-customize --install qemu-guest-agent -a base.qcow2     # Highly recommended
    virt-customize --install nano -a base.qcow2                 # I like it
    virt-customize --install ncurses-term -a base.qcow2         # needed for terminals
    virt-customize --install git -a base.qcow2                  # moustly needed 
    virt-customize --install unattended-upgrades -a base.qcow2  # good feature
    virt-customize --install fail2ban -a base.qcow2             # highly recommended
    virt-customize --install clamav -a base.qcow2               # highly recommended
    virt-customize --install clamav-demon -a base.qcow2         # linked to above
    virt-customize --install mailutils -a base.qcow2            # might be needed
}

createVM() # Funtion: creat a VM or a Template
{
        # Choose RAM, Disk size, # of cores, what bridge to use. virtio is mandatory
        if [[ $mini == [yY] ]]; then
                qm create $tno --memory $ms --core $cc --name ubuntu-mini --net0 virtio,bridge=$vmbr,tag=$vlan
          else
                qm create $tno --memory $ms --core $cc --name ubuntu-std --net0 virtio,bridge=$vmbr,tag=$vlan
        fi

        # Import the disc to the base of the template. Where to put the VM local-lvm
        qm importdisk $tno base.qcow2 $storage

        # Attache the disk to the base of the template
        qm set $tno --scsihw virtio-scsi-pci --scsi0 $storage:vm-$tno-disk-0

        # Attach the cloudinit file - you NEED to EDIT it later !
        qm set $tno --ide2 $storage:cloudinit

        # Make the cloud init drive bootable and only boot from this disk
        qm set $tno --boot c --bootdisk scsi0

        # Add serial console, to be able to see console output!
        qm set $tno --serial0 socket --vga serial0

        # Autostart vm at boot - default is 0 - Ususlly most VM's are allway running
        qm set $tno --onboot 1

        # Use Qemu Guest Agent - default is 0
        qm set $tno --agent 1

        # Set OS type Linux 5.x kernel 2.6 - default is other
        qm set $tno --ostype l26

        # Set dhcp on
        qm set $tno --ipconfig0 ip="dhcp"

    ## More automation can be added to cloud-init, examplesbelow -----------------#
        # 1. copy your public key to the node or copy it later to the VM
                #ssh-copy-id -i ~/.ssh/id_ed25519 username@pve.lab.example.com

        # 2. set up credentials
        qm set $tno --ciuser $ciu     #"admin"       # use your imagination
        qm set $tno --cipassword $cip # "Pa$$w0rd"   # use a super complicated one
        if [[ $my_key == [yY] ]]; then
                qm set $tno --sshkey ~/.ssh/my_key     # sets the users key to the vm
        fi

        # 3. use a bootstrap file at the initial boot <directory> that can have snippets.
        # You need to check the status of the Storage Manager and set according to yours
        #pvesm status
        #pvesm set local --content backup,iso,snippets,vztmpl
        #qm set $tno --cicustom "vendor=<local>:snippets/vendor.yaml"

}

createTemplate() # Functin: Create the template ex. 9000
{
    if [[ $tok == [yY] ]]; then
        qm template $tno
        sleep 2
    fi
}

createClones() # Functin: Cloning the template
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

# Main =======================================================================#
clear
echo ">>>> Started the Install   @ $(date +"%F %T") ****  ****" > ~/installMTB.log
echo -e "\e[1;35mThis script will create Templates and or VM's for your node.\e[0m"
echo ""
echo -e "\e[1;31mNOTE\e[1;35m - libguestfs-tools is needed. Installe it ones on Proxmox."
echo ""
echo " Remember to edit the script before executing: "
echo "   - base settings are 1 core and 1024M RAM"
echo "   - normal disk size for a VM is 8-16G or sometimes 32G"
echo "   - Enter Disk size as 8G NOT 8 !"
echo -e "   - OS = L26, IP = DHCP, QGA = on, Autostart = off\e[0m"
echo ""
echo -e "\e[1;33mStart the configuration\e[0m"
read -rp "  Install the libguestfs-tools Now  [y/N] : " gfs
echo ""
echo -e "\e[1;35m Creating the Base Image from a Cloud image\e[0m"
read -rp "  - Change to minimal Ubuntu      [y/N] : " mini
read -rp "    - Use existing ISO-image      [y/N] : " upd
read -rp "    - Disk size (8, 16 or 32G) e.g   8G : " ds
read -rp "    - Memory (1024 is plenty)  e.g.1024 : " ms
read -rp "    - Core count (1 is plenty)   e.g. 1 : " cc
read -rp "    - Set vmbr to be used    e.g. vmbr2 : " vmbr
read -rp "      - Set vlan tag         e.g.     1 : " vlan
echo -e "\e[1;35m  Settings for the VM or Template and VMs\e[0m"
read -rp "  - Set VM or Template ID    e.g. 9000 : " tno
read -rp "  - Storage to use VM   e.g. local-lvm : " storage
read -rp "  - Create with CI user     e.g. admin : " ciu
#echo -n "    - create with CI user password     : "
read -sp "    - create with CI user password     : " cip
echo
read -rp "    - set key from ~/.ssh/my_key [y/N] : " my_key
echo -e "\e[1;35m  Settings for Template and VMs\e[0m"
read -rp "  - Create as a Template id $tno [y/N] : " tok
if [[ $vlan < 1 ]]; then vlan=1; fi
if [[ $tok == [yY] ]]; then
    read -rp "  - Create # clones of $tno 0=no clones: " ctno
    if [[ $ctno -gt 0 ]]; then
        read -rp "    - ID number for first clone   5000 : " fcno
        if [ $ctno = 1 ]; then
           xz=$fcno
        else
           xz=$(($fcno + $ctno))
        fi
        read -rp "    - name of clone's pod1 to pod$ctno     : " cname
        echo -e "\e[1;33m  Creating Template with ID $tno, $ds"
        echo "    - creating cloned VM's $fcno - $xz"
        y=1
        echo -e "    - named as  $cname$y - $cname$ctno\e[0m"
    fi
else
    echo ""
    echo -e "\e[1;33m  - Creating a VM with ID $tno Disk $ds\e[0m"
fi
echo ""
read -rp $'\e[1;31mStart the Install [y/N] : \e[0m' ok
echo ""

# init log
if [[ $ok == [yY] ]]; then
    # Run the spinner in the background and Save the PID
    spinner &
    spinner_pid=$!

    # Execute the functions --------------------------------------------------#
    if [[ $gfs == [yY] ]]; then
        (guestfs >> ~/installMTB.log 2>&1) #& hyrra
        printf "\b \n"
        echo "Installed libguestfs-tools"
        echo "---- * libguestfs-tools    @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    fi
    sleep .5
    (getUbuntu >> ~/installMTB.log 2>&1) #& hyrra
    printf "\b" #\n"
    echo "  - Cloud Image downloaded"
    echo "---- * CloudImage    @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    (createBase >> ~installMTB.log 2>&1)
    printf "\b" #\n"
    echo "  - Base.qcow2 image created"
    echo "---- * base.qcov2 $ds image     @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    (createVM >> ~/installMTB.log 2>&1) #& hyrra
    printf "\b" # \n"
    echo "  - VM created, $ds"
    echo "---- * VM Created      $(date +"%F %T") ****  ****" >> ~/installMTB.log
    if [[ $tok == [yY] ]]; then
        createTemplate &> /dev/null #& hyrra
        printf "\b" # \n"
        echo "  - Template created, $ds"
        echo "---- * Template created    @ $(date +"%F %T") ****  ****" >> ~/installMTB.log

    fi
    if [[ $ctno -gt 0 ]]; then
        createClones &> /dev/null #& hyrra
        printf "\b" # \n"
        echo "  - Clone(s) created"
        echo "---- * Clones created      @ $(date +"%F %T") ****  ****" >> ~/installMTB.log
    fi
    # End of Execute Functions------------------------------------------------#
    echo "<<<< Install ended OK     @ $(date +"%F %T") ****  ****" >> ~/installMTB.log

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
       tput setaf 3
       echo "Remenmer do NOT start the VM before making it into a template !"
       tput sgr0
       echo "Edit the Cloud-Init NOW ... then clone your VM's"
       tput setaf 1
       echo ""
       echo "WARNING - Do  NOT  start the VM - WARNING"
       tput sgr0
       # Alt way of output
       #useColors
       #printf "%s\n" "Remenmer do ${red}NOT4{end} start the VM before making it into a template !"
       #printf "%s\n" "Edit the Cloud-Init ${red}NOW${end} ... then clone your VM's"
       #printf "%s\n" "${red}WARNING${end} - Do  ${red}NOT${end}  start the VM - ${red}WARNING${end}."
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
if [[ $pl -eq '' || $pl = [yY] ]]; then
   cat ~/installMTB.log
fi
