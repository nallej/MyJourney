#!/bin/bash
## templatebuilder.sh for Ubuntu 22.04 Servers
## A basic set of command, for more see: https://pve.proxmox.com/pve-docs/qm.conf.5.html

# Get the cloud image of choise
wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
#wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create the base for the template 
# Choose RAM, Disg size and # of core, what bridge to use. NOTE virtio is mandatory
qm create 9000 --memory 1024 --core 1 --name ubuntu-2204-mini-server --net0 virtio,bridge=vmbr0
#qm create 9100 --memory 1024 --core 1 --name ubuntu-2204-server --net0 virtio,bridge=vmbr0

# Convert the file to cow2
mv ubuntu-22.04-minimal-cloudimg-amd64.img ubuntu-22.04.mini.qcow2
#mv jammy-server-cloudimg-amd64.img ubuntu-22-04.qcow2

# Resize to your needs, 8 - 32G is normal
qemu-img resize ubuntu-22.04.mini.qcow2 16G
#qemu-img resize ubuntu-22.04.qcow2 16G

# Import the disc to the base of the template. Where to put the VM local-lvm
qm importdisk 9000 ubuntu-22.04.mini.qcow2 local-lvm
#qm importdisk 9100 ubuntu-22.04.qcow2 local-lvm

# Attache the disk to the base of the template
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
#qm set 9100 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9100-disk-0

# Attach the cloudinit file - you NEED to EDIT it later!
qm set 9000 --ide2 local-lvm:cloudinit
#qm set 9100 --ide2 local-lvm:cloudinit

# Make the cloud init drive bootable and only boot from this disk
qm set 9000 --boot c --bootdisk scsi0
#qm set 9100 --boot c --bootdisk scsi0

# Add serial console, to be able to see console output!
qm set 9000 --serial0 socket --vga serial0
#qm set 9100 --serial0 socket --vga serial0

# Autostart vm at boot - default is 0
qm set 9000 --autostart 1
#qm set 9100 --autostart 1

# Use Qemu Guest Agent - default is 0
qm set 9000 --agent 1
#qm set 9100 --agent 1

# End of code

echo ""
echo "Thats it. Remenmer do NOT start the VM"
echo ""
echo "WARNING - Do  NOT  start the VM - WARNING"
sleep 5
echo "Edit the Cloud-Init NOW" 
sleep 5
