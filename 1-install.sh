#!/bin/bash

#---------------------------------------------------------#
#  1-install.sh 2.0                                       #
#  HomeStack project                                      #
#                                                         #
#  V.1 Created by Nalle Jusleon 10.1.2022 as 2 scripts    #
#    -review 9.2.2022                                     #
#                                                         #
#  V.2 created 10.02.2022 Prepare VM for Docker-Stack     #
#                                                         #
#---------------------------------------------------------#

# Declare function hyrraPyorii Show a activity spinner --#
hyrraPyorii (){                                          #
   pid=$! # Process Id of the previous running command   #
   x='-\|/' # hyrra in its elements                      #
   i=0                                                   #
   while kill -0 $pid 2>/dev/null                        #
   do                                                    #
     i=$(( (i+1) %4 ))                                   #
     printf "\r  ${x:$i:1}"                              #
     sleep .1                                            #
    done                                                 #
    printf "\r  "                                        #
}                                                        #
hyrraPyorii                                              #
# -------------------------------------------------------#

clear
echo ""
echo "Starting upgrade/install of apps for the Docker-stack"
echo ""
echo "  WARNING - DON'T run scripts without editing - WARNING"
echo ""
echo "  Warning . This script will pull parts from my GitHub"
echo ""
lsb_release -a #print lsb-release info
echo ""
echo "Preparing the VM"
# Add bash_aliases ------------------------------------------------------------
wget https://raw.githubusercontent.com/nallej/HomeStack/main/.bash_aliases &> /dev/null
. ~/.bashrc
echo "  - added .bash_aliases"
# running install -------------------------------------------------------------
echo ""
echo "  - starting Install"
echo "  WARNING Rread the code - edit and the run!"
read -rp "  - Do you want to do the Install  [y/n] " DPI
if [[ "$DPI" = [yY] ]]; then
  echo "  - Running VM updates and installs ..."
  # This is the main part update-install-upgrade ------------------------------
  echo "**** Initial install/upgrade stage ****   ****   ****" > ~/install.log
  sudo ls &> /dev/null # dummy to get sudo psw
  (sudo apt-get update &&
   sudo apt-get install curl apt-transport-https ca-certificates software-properties-common fail2ban -y &&
   sudo apt-get upgrade -y
  ) >> ~/install.log 2>&1 &
    hyrraPyorii
  echo "  - starting Docker Pre-Install ..."
  echo "**** Docker Pre Install stage ****   ****   ****" >> ~/install.log
  wget https://github.com/nallej/HomeStack/raw/main/LICENSE &> /dev/null
  # set your timezone ---------------------------------------------------------
  echo "  - TZ = Helsinki" # change to your timezone
  sudo timedatectl set-timezone Europe/Helsinki
  # ---------------------------------------------------------------------------
  read -rp "  - Are you ruinning 1-Focal 2-Hirsute  0=Quit : " OS # <<< add deb
    echo "    -  LTS is recomended use Focal Stable"
    if [[ "$OS" != [1] ]]; then
      echo "You need to edit the script"
    exit
    else
      echo "  ... upgrading sw ..."
      echo "**** second install/upgrade stage ****   ****   ****" >> ~/install.log
      (  # Add keys -----------------------------------------------------------
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
        # LTS is recomendded focal stable  (hirsute, impish) ------------------
        sudo apt-cache policy docker-ce &&
        sudo apt-get update &&
        sudo apt-get upgrade -y
      ) >> ~/install.log 2>&1 &
        hyrraPyorii
    fi
    echo ""
    echo "  - Setting up unattenden updates = yes "
    echo "**** Docker Pre Install stage ****   ****   ****" >> ~/install.log
    (sudo systemctl enable unattended-upgrades --now) >> ~/install.log 2>&1 &
    echo ""
    echo "  WARNING - Do you want to clear old updates?"
    read -rp "  - Clear old updates  [y/n] " COU
      if [[ "$COU" = [yY] ]]; then
        echo "  - Deliting old installs ..."
        (sudo apt-get clean &&
        sudo apt-get autoremove) >> ~/install.log 2>&1 &
      fi

    # This is only needed for Proxmox VM's ------------------------#
    echo ""                                                        #
    read -rp "  - Install QGA for Proxmox VM  [y/n] "  QGA         #
      if [[ "$QGA" = [yY] ]]; then                                 #
        sudo apt-get install -q -y qemu-guest-agent &> /dev/null   #
      fi                                                           #
    # qemu-quest-agent --------------------------------------------#

# Giv your stack a name or use default: docker-stack --------------------------
    mkdir docker-stack
    cd docker-stack
    wget https://raw.githubusercontent.com/nallej/HomeStack/main/docker-install.sh &> /dev/null
    chmod +x docker-install.sh
# =============================================================================
    echo ""
    echo ""
    echo ""
    echo "All done ! "
    echo "  - Licens copied to current folder "
    echo "  - Next script is in ~/docker-stack/ - 2-install.sh "
    echo "  - install.log written, check for errors "
    echo ""
    echo ""
    echo "Ready for the next script ? "
    echo "  - Read the code, change to your needs, add your stuff and passwords ! "
    echo "  - reboot is mandatory"
    echo ""
    echo "You should now: "
    echo "  - Power off and change VM settings "
    echo "  - Edit the script:  ~/docker-stack/2-install.sh "
    echo ""
    sleep 2s
    read -rp "Do you want to reboot? [y/n] " RB
      if [[ "$RB" = [yY] ]]; then
        sudo reboot
      fi
  # end of install y/n
  else
    echo "Exit - automated process"
    echo "  - Edit the script:  ~/docker-stack/2-install.sh "
    echo "  - Read the code, change to your needs, add your stuff and passwords ! "
    echo "  - REBOOT befor running ./2-install.sh"
  fi
