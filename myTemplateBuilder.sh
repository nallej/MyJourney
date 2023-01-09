#!/bin/bash

#-----------------------------------------------------------------------------#
#  myTempBuilder.sh for Ubuntu 22.04 Servers                                  #
#  Part of the MyJourney project @ homelab.casaursus.net                      #
#                                                                             #
#  V.1 Created by Nalle Juslén 29.11.2022                                     #
#    -review 1.12.2022                                                        #
#                                                                             #
#  V.2 Created by Nalle Juslén 4.1.2023                                       #
#    - revison 9.1.2023                                                       #
#                                                                             #
# For more info see: https://pve.proxmox.com/pve-docs/qm.conf.5.html          #
# Date format and >>>> ---- <<<< **** for easy sorting                        #
#-----------------------------------------------------------------------------#

# Functions ==================================================================#

hyrra() # Function hyrraPyorii. Show a activity spinner
{
        pid=$!   # PID of the previous running command
        x='-\|/' # hyrra in its elements
        i=0
            while kill -0 $pid 2>/dev/null
                do
                    i=$(( (i+1) %4 ))
                    printf "\r  ${x:$i:1}"
                    sleep .1
                done
        printf "\r  "
}


getUbuntu() # Function to get a cloud image, Ubuntu as example, it's a .qcow2 fil with the extension img - we turn it back to .qcow2
{
        if [[ $mini == [yY] ]]; then
                wget -O base.qcow2 https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
          else
                wget -O base.qcow2 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
        fi

        qemu-img resize base.qcow2 16G   # Resize the disk to your needs, 8 - 32G is normal
        # Add QEMU Guest Agent and any other packages you’d like in your base image.
        # libguestfs-tools has to be installed on the nodd. apt-get update && apt-get install libguestfs-tools
        virt-customize --install qemu-guest-agent -a base.qcow2
        virt-customize --install nano -a base.qcow2
        virt-customize --install git -a base.qcow2
}

createVM() # Funtion creating aVM or Template
{
        # Choose RAM, Disk size, # of cores, what bridge to use. virtio is mandatory
        if [[ $mini == [yY] ]]; then
                qm create $tno --memory 1024 --core 1 --name ubuntu-mini --net0 virtio,bridge=vmbr0
          else
                qm create $tno --memory 1024 --core 1 --name ubuntu-std --net0 virtio,bridge=vmbr0
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

        # Autostart vm at boot - default is 0
        #qm set $tno --onboot 1

        # Use Qemu Guest Agent - default is 0
        qm set $tno --agent 1

        # Set OS type Linux 5.x kernel 2.6 - default is other
        qm set $tno --ostype l26

        # Set dhcp on
        qm set $tno --ipconfig0 ip="dhcp"

    ## More automation can be added to cloud-init, examplesbelow -----------------#
        # 1. copy your key to the node or to the VM
                #ssh-copy-id -i ~/.ssh/id_ed25519  our_username@other_machine

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

createTemplate() # Create the template ex. 9000
{
        if [[ $tok == [yY] ]]; then
            qm template $tno
            sleep 5
        fi
}

createClones() #Cloning the template
{
        if [[ $ctno -gt 0 ]]; then
            x=0
            while [ $x -lt $ctno ]
            do
                xx=$(($fcno + $x))
                qm clone $tno $xx --name $cname$x --full
                x=$(( $x + 1 ))
            done
        fi
}


# Main =======================================================================#
clear
echo ">>>> Started the Install   @ $(date +"%F %T") ****  ****" > ~/installMTB.log
echo "This script will create templates and or VM's for your node."
echo ""
echo "NOTE libguestfs-tools is needed to be installed on Proxmox!"
echo ""
echo " Install this script by: "
echo "   - open a terminal into the Proxmox node as root"
echo "   - run wget://https://raw.githubusercontent.com/nallej/MyJourney/main/templatebuilder.sh"
echo "   - chmod +x templatebuilder.sh"
echo ""

read -rp "  Install the libguestfs-tools Now  [y/N] : " gfs
echo ""
echo "  Do you want to install Standard or a minimimal Ubuntu 22.04 image"
read -rp "  - Change to minimal Ubuntu    [y/N] : " mini
echo ""
read -rp "  - Set VM or Template ID     ex. 9000 : " tno
read -rp "  - Storage to use VM    ex. local-lvm : " storage
read -rp "  - Create with CI user      ex. admin : " ciu
read -rp "  - Create with CI user password       : " cip
read -rp "  - set key from ~/.ssh/my_key   [y/N] : " my_key
echo ""
read -rp "  - Create as a Template id $tno [y/N] : " tok
if [[ $tok == [yY] ]]; then
    read -rp "  - Create # clones of $tno 0=no clones: " ctno
    if [[ $ctno -gt 0 ]]; then
        read -rp "    - ID number for first clone        : " fcno
        xz=$(($fcno + $ctno))
        read -rp "    - name of clone's Pod1 to Pod$ctno     : " cname
        echo "  Creating Template with ID $tno"
        echo "    - creating cloned VM's $fcno - $xz"
        echo "    - named as  $cname$fcno - $cname$xz"
    fi
else
    echo ""
    echo "  Creating a VM with ID $tno"
fi
echo ""
read -rp "Start install [y/N] : " ok
# init log
if [[ $ok == [yY] ]]; then
# Execute the functions ------------------------------------------------------#
    if [[ $gfs == [yY] ]]; then
        (apt-get update && apt-get install libguestfs-tools)  &> /dev/null & hyrra
        echo "Installed libguestfs-tools"
        echo "---- * libguestfs-tools    @ $(date +"%F %T") ****  ****" > ~/installMTB.log
    fi
    sleep 2
    (getUbuntu >> ~/installMTB.log 2>&1) & hyrra #&> /dev/null & hyrra
    echo "  - Base.qcov2 image created"
    echo "---- * base.qcov2 image    @ $(date +"%F %T") ****  ****" > ~/installMTB.log
    (createVM >> ~/installMTB.log 2>&1) & hyrra #&> /dev/null & hyrra
    echo "  - VM created"
    echo "---- * VM Created      $(date +"%F %T") ****  ****" > ~/installMTB.log
    if [[ $tok == [yY] ]]; then
        createTemplate &> /dev/null & hyrra
        echo "  - Template created"
        echo "---- * Template created    @ $(date +"%F %T") ****  ****" > ~/installMTB.log

    fi
    if [[ $ctno -gt 0 ]]; then
        createClones &> /dev/null & hyrra
        echo "  - Clone(s) created"
        echo "---- * Clones created      @ $(date +"%F %T") ****  ****" > ~/installMTB.log
    fi
    # End message ----------------------------------------------------------------#
    echo ""
    echo "Remenmer do NOT start the VM before making it into a template !"
    echo ""
    echo "WARNING - Do  NOT  start the VM - WARNING"
    sleep 2
    echo ""
    echo "Log created: ~/install.log"
    echo ""
    echo "Edit the Cloud-Init NOW ... then clone your VM's"
    echo "<<<< Install ended OK     @ $(date +"%F %T") ****  ****" > ~/installMTB.log
    sleep 5
  else
        echo "<<<< Exited the Install   @ $(date +"%F %T") ****  ****" > ~/installMTB.log
fi

# End of script ======================================================#