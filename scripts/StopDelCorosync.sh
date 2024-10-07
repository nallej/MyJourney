# Stop the corosync and the pve-cluster services on the node:
# wget https://github.com/nallej/MyJourney/raw/main/StopDelCorosync.sh

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
echo "Remove ghost of old node can be removed from /etc/pve/corosync.conf" 
echo ""
#
# Browser errors
# You can maybe fix it by:
# rm remove /etc/pve/priv/pve-root-ca.key /etc/pve/pve-root-ca.pem
# rm /etc/pve/local/pve-ssl.pem /etc/pve/local/pve-ssl.key /etc/pve/local/pveproxy-ssl.pem /etc/pve/local/pveproxy-ssl.key (on each node!)
# run pvecm updatecerts
# run systemctl restart pveproxy
#
# Now the GUI should work again, with the default self-signed certificates. 
# In the GUI or 'pvenode' upload your certificate + key 
# (it will be stored in '/etc/pve/local/pveproxy-ssl.pem' / '/etc/pve/local/pveproxy-ssl.key'
