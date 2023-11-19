# Stop the corosync and the pve-cluster services on the node:
# wget https://github.com/nallej/MyJourney/blob/main/StopDelCorosync.sh

systemctl stop pve-cluster
systemctl stop corosync

# Start the cluster filesystem again in local mode:
pmxcfs -l

# Delete the corosync configuration files:
rm /etc/pve/corosync.conf
rm -r /etc/corosync/*

# Start the filesystem again as normal service:

killall pmxcfs
systemctl start pve-cluster

# Remove any left over .conf files
echo ""
echo ""
echo "Remove any *.conf left in /etc/pve/qemu-server"
echo "Remove any *.conf left in /etc/pve/lxc"
echo "Remove any *.conf left in /etc/pve/nodes/<OLD NODE>/qemu-server"
echo "Remove any *.conf left in /etc/pve/nodes/<OLD NODE>/lxc"
echo ""
