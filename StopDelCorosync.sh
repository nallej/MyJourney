# Stop the corosync and the pve-cluster services on the node:

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
