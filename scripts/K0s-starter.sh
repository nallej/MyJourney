# Start setup os K0s Controller/Worker
clear
echo ""
echo "Initialize the K0s Cluster"
echo ""
read -rp "Init the Controller [y/N] " x
if [ "$x" = "y" ]; then
    #yes a Controller
    #sudo k0s install controller --enable-worker # or standalone
    sudo systemctl start k0scontroller.service
    sudo k0s token create --role worker --expiry 1h > k0s.token
    read -rp "IP worker 1: " IPworker1
    read -rp "IP worker 2: " IPworker2
    # ssh-keyscan -H $IPworker1 >> ~/.ssh/known_hosts
    # ssh-keyscan -H $IPworker2 >> ~/.ssh/known_hosts
    sudo scp k0s.token $USER@$IPworker1:/home/$USER
    sudo scp k0s.token $USER@$IPworker2:/home/$USER
    sudo k0s start
    sudo k0s status
    sudo k0s kubectl get nodes
else
    # no on of the Workers
    sudo k0s install worker --token-file k0s.token
    sudo k0s start
    sudo k0s status
fi
echo ""
echo "After starting the Controller and all worker check status "
echo "  - sudo k0s kubectl get nodes"
