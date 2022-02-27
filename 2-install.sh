#!/bin/bash

#--------------------------------------------------------#
#  2-install.sh 2.0                                      #
#  MyJourney project                                     #
#                                                        #
#  V.1 created by Nalle Juslen 20.11.2021 as 2 scripts   #
#    - revison 26.1.2022                                 #
#                                                        #
#  V.2 created 15.02.2022 Install basic Docker-Stack     #
#    - revision                                          #
#--------------------------------------------------------#

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
echo "This script will install:"
echo " - Docker-ce and Docker-Compose,"
echo "  - Portainer/Portainer agent, "
echo "  - Dozzle and Watchtower, "
echo "  - if you need it Heimdall. "
echo ""
echo "  WARNING - DON'T run scripts without editing - WARNING"
echo ""
echo "  Warning . This script will pull parts from my GitHub"
echo ""
echo ""
# What to install -------------------------------------------------------------
echo "Chose apps to install:"
read -rp " Docker-ce            [y/n] " DOCE
read -rp " Docker-Compose       [y/n] " DOCO
echo "Use Portainer or the Agent "
read -rp "  - Portainer-ce      [y/n] " POT
read -rp "  - Portainer Agent   [y/n] " POTA
echo ""
echo "Recommended apps:"
read -rp " WatchTower           [y/n] " WT
read -rp " Dozzle               [y/n] " DOZ
echo ""
echo "Optional apps "
read -rp "  -  Heimdall         [y/n] " HEIM


# Start installing Docker-ce --------------------------------------------------
if [[ "$DOCE" == [yY] ]]; then
    #sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    #apt-cache policy docker-ce
    sudo ls &> /dev/null # dummy to get sudo psw
    echo ""
    echo "installing Docker-ce"
    (sudo apt install -q docker-ce -y ) >> ~/install.log 2>&1 &
    hyrraPyorii
    echo ""
    echo "  - Docker-ce installed. "
    echo "  - Starting docker."
    echo ""
    sleep 10s
    sudo systemctl enable docker
    sudo systemctl enable containerd.service
    sudo systemctl start docker
    sleep 5s
    docker -v 
    sleep 2s
    sudo usermod -aG docker "${USER}" # you do not need to sudo to run docker commands after re-login
    sleep 1s
    sudo docker network create -d bridge kadulla  &> /dev/null #frontend  
    sudo docker network create -d bridge pihalla  &> /dev/null #backbone
    echo "  $USER added to docker group"
    echo ""
    echo "  Internal networks created:"
    echo "    - kadulla = frontend "
    echo "    - pihalla = backbone "
    echo ""
fi
echo ""

# Start installing Docker-Copmpose --------------------------------------------
if [[ "$DOCO" == [yY] ]]; then
    (sudo apt install -q docker-compose -y) >> ~/install.log 2>&1 &
    hyrraPyorii
    echo ""
    echo "  - Docker-Compose installed."
    echo ""
fi
echo ""
# Start installing Portainer/Portainer agent ----------------------------------
echo ""
#---------------------------------------------#
# I use 9000 http, you can use 9443 for https #
#---------------------------------------------#
if [[ "$POT" == [yY] ]]; then
    (sudo docker volume create portainer_data
    sudo docker run -d \
     -p 8000:8000 \
     -p 9000:9000 \
     --name=portainer \
     --restart=always \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v portainer_data:/data \
     portainer/portainer-ce) >> ~/install.log 2>&1 &
    hyrraPyorii
    echo "    - Portainer @ x.x.x.x:9000"
    echo ""
fi
    if [[ "$POTA" == [yY] ]]; then
        echo ""
        echo ""
        (sudo docker volume create portainer_data
        sudo docker run -d \
         -p 9001:9001 \
         --name portainer_agent \
         --restart=always \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -v /var/lib/docker/volumes:/var/lib/docker/volumes \
         portainer/agent) >> ~/install.log 2>&1 &
        hyrraPyorii
        sleep 2s
        echo ""
        echo "    - Portainer finds this agent @ x.x.x.x:9001"
        echo ""
    fi
sleep 2s
echo ""
# Start installing WatchTower, auto update ------------------------------------
if [[ "$WT" == [yY] ]]; then
    mkdir ~/docker-stack/watchtower
    cd ~/docker-stack/watchtower
    wget https://raw.githubusercontent.com/nallej/MyJourney/main/watchtower/docker-compose.yml &> /dev/null
#    docker-compose up -d # uncomment if you want to start now
    echo ""
    echo "Watchtower installed"
    echo "  - Updating images daily 04.00 "
    echo "  - NOT started, edit befor starting"
    echo ""
fi

echo ""
# Start installing Dozzle, log reader -----------------------------------------
if [[ "$DOZ" == [yY] ]]; then
    mkdir ~/docker-stack/dozzle
    cd ~/docker-stack/dozzle
    wget https://raw.githubusercontent.com/nallej/MyJourney/main/dozzle/docker-compose.yml &> /dev/null
#    sudo docker-compose up -d # uncomment if you want to start now
    echo ""
    echo "Dozzle installed"
    echo "  - Not started, EDIT befor using"
    echo "  - ports: 9999"
    echo ""
fi
echo ""
# Start installing Heimdall, internal portal ----------------------------------
if [[ "$HEIM" == [yY] ]]; then
    mkdir ~/docker-stack/heimdall
    cd ~/docker-stack/heimdall
    wget https://raw.githubusercontent.com/nallej/MyJourney/main/heimdall/docker-compose.yml &>/dev/null
#    docker-compose up -d # uncomment if you want to start now
    echo ""
    echo "Heimdal installed"
    echo "  - Not started, EDIT befor using"
    echo "  - default user/group: 1000/1000"
    echo "  - ports: 9080 or 9088 "
    echo ""
fi
echo ""
echo "Basic installation done!"
echo "  - add services: prometheus, node-reporter, backup ..."
echo "  - add your apps wp, ghost ...."
echo "  - logout and login again to activate permissions"
echo "  - reboot befor starting apps"
echo ""
echo "Rememper to have fun! Learn new things and love the CLI."
