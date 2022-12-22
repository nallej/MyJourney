#!/bin/bash
## templatebuilder.sh ver. 1.2 for Ubuntu 22.04 Servers
## A basic set of commands, for more see: https://pve.proxmox.com/pve-docs/qm.conf.5.html

#=============================================================================#
# Get the cloud image of choise, Ubuntu as example
wget -O base.qcow2 https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
#wget -O base.qcow2 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
#-----------------------------------------------------------------------------#
# Resize the disk to your needs, 8 - 32G is normal
qemu-img resize base.qcow2 16G
#=============================================================================#
#                                                                             #
# Create the template ========================================================#
#
# Choose RAM, Disk size, # of cores, what bridge to use. virtio is mandatory  
qm create 9000 --memory 1024 --core 1 --name ubuntu-mini --net0 virtio,bridge=vmbr0
# Import the disc to the base of the template. Where to put the VM local-lvm
qm importdisk 9000 base.qcow2 local-lvm
#-----------------------------------------------------------------------------#
# Attache the disk to the base of the template
qm set 9000 --scsihw virtio-scsi-pci --scsi0 locl-lvm:vm-9000-disk-0
#-----------------------------------------------------------------------------#
# Attach the cloudinit file - you NEED to EDIT it later !
qm set 9000 --ide2 local-lvm:cloudinit
# Make the cloud init drive bootable and only boot from this disk
qm set 9000 --boot c --bootdisk scsi0
#-----------------------------------------------------------------------------#
# Add serial console, to be able to see console output!
qm set 9000 --serial0 socket --vga serial0
#-----------------------------------------------------------------------------#
# Autostart vm at boot - default is 0 
#qm set 9000 --onboot 1
#-----------------------------------------------------------------------------#
# Use Qemu Guest Agent - default is 0
qm set 9000 --agent 1
#-----------------------------------------------------------------------------#
# Set OS type Linux 5.x kernel 2.6 - default is other
qm set 9000 --ostype l26
#-----------------------------------------------------------------------------#
# Set dhcp on
qm set 9000 --ipconfig0 ip="dhcp"
#-----------------------------------------------------------------------------#
#                                                                             #
## More automation can be added to cloud-init, examplesbelow -----------------#
# 1. copy your key to the node or to the VM 
#ssh-copy-id our_username@other_machine
# 2. set up credentials
#qm set 9000 --ciuser "admin"           # use your imagination
#qm set 9000 --cipassword  "Pa$$w0rd"   # use a super complicated one
#qm set 9000 --sshkey ~/.ssh/my_key     # sets the users key to the vm
#-----------------------------------------------------------------------------#
# Create the template 9000 
#qm template 9000
#sleep 15
# Cloning the template
#qm clone 9000 5001 --name Pod1 --full
#qm clone 9000 5002 --name Pod2 --full
#qm clone 9000 5003 --name Pod3 --full
#-----------------------------------------------------------------------------#
#                                                                             #
# End of code ================================================================#

echo ""
echo "Remenmer do NOT start the VM before making it into a template !"
echo ""
echo "WARNING - Do  NOT  start the VM - WARNING"
sleep 2
echo ""
echo "Edit the Cloud-Init NOW ... then clone your VM's"
sleep 5
