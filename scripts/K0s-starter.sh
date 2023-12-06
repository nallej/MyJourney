# Start setup os K0s Controller/Worker
clear
echo -e "\nStart the K0s cluster\n"
read -rp "IP worker 1" IPworker1
read -rp "IP worker 2" IPworker2
echo -e "\nAfter starting Controller and worker check status "
echo "  - sudo k0s kubectl get nodes"


if (whiptail --backtitle "$backTEXT"  --title "Start K0S" --defaultno --yesno \
    "\nStart the K0s cluster." \
    8 58 --no-button "worker" --yes-button "ctrlr"); then
    #yes Controller
    sudo k0s token create --role=worker > k0s.token
    sudo scp k0s.token $user@$IPworker1
    sudo scp k0s.token $user$@IPworker2
    sudo k0s install controller --enable-worker
    sudo k0s start
    sudo k0s status
    sudo k0s kubectl get nodes
else
    # Worker
    sudo k0s install worker --token-file k0s.token
    sudo k0s start
fi
