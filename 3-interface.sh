#!/bin/bash

#--------------------------------------------------------#
#  3-interface.sh 1.0                                    #
#  MyJourney project | Web facing apps NPM, Authelia     #
#                                                        #
#  V.1 created by Nalle Juslen 01.03.2022                #
#    - revison 00.00.2022                                #
#                                                        #
#  V.2 created 15.02.2022                                #
#    - revision 00.00.2022                               #
#--------------------------------------------------------#
# Declare function hyrraPyorii Show a activity spinner   #
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
echo "This script will install: "
echo "  Interface module: "
echo "    - Nginx Proxy Manager "
echo "    - Authelia "
echo "    - Dozzle "
echo ""
echo "  WARNING - DON'T run scripts without editing - WARNING "
echo ""
echo "  Warning . This script will pull parts from my GitHub "
echo ""
echo ""
# What to install -------------------------------------------------------------
echo "Chose apps to install:"
read -rp "  Nginx Proxy Manager  [y/n] " NPM
read -rp "  Authelia             [y/n] " AUTH
echo ""
echo "Recommended apps: "
read -rp "  Dozzle               [y/n] " DOZ
echo ""
echo "Updating and Upgrading "
  sudo ls &> /dev/null # dummy to get sudo psw
  (sudo apt-get update && sudo apt-get upgrade &&
    sleep 2s
   ) > ~/interface.log 2>&1 &
    hyrraPyorii
# Start installing NPM --------------------------------------------------------
if [[ "$NPM" == [yY] ]]; then
    sudo ls &> /dev/null # dummy to get sudo psw
    echo ""
    echo "Installing Nginx Reverse Proxy "
    (mkdir -p npm npm/data npm/advanced-cfgs npm/letsencrypt npm/secrets &&
       wget https://raw.githubusercontent.com/nallej/MyJourney/main/interface/npm.yml -O ./npm/docker-compose.yml &&
       wget https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-cfg-site -O ./npm/advanced-cfgs/site.cfg &&
       wget https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-cfg-auth -O ./npm/advanced-cfgs/auth.cfg
    ) >> ~/interface.log 2>&1 &
    echo ""
    echo "  - NPM installed. "
    echo "    - Start after edits: goto npm/ and dcup (docker-compose up -d) "
fi
# Start installing Authelia ---------------------------------------------------
if [[ "$AUTH" == [yY] ]]; then
    echo ""
    echo "Installing Authelia "
    (mkdir -p authelia authelia/config authelia/mysql authelia/redis &&
       wget https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia.yml -O ./authelia/docker-compose.yml &&
       wget https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-config.yml -O ./authelia/config/configuration.yml &&
       wget https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-users -O ./authelia/config/users.yml
    ) >> ~/interface.log 2>&1 &
    echo ""
    echo "  - Authelia installed "
    echo "    - edit and test NPM before continuing! "
    echo "    - add users passwords - use generator site "
    echo "    - Start after edits: goto authelia/ and dcup (docker-compose up -d) "
fi
# Start installing Dozzle, log reader -----------------------------------------
if [[ "$DOZ" == [yY] ]]; then
    echo ""
    echo "Installing Dozzle "
    mkdir dozzle
    wget https://raw.githubusercontent.com/nallej/MyJourney/main/Dozzle/docker-compose.yml -O ./dozzle/docker-compose.yml  &> /dev/null
    echo ""
    echo "  - Dozzle installed "
    echo "    - Not started, EDIT befor using "
    echo "    - port: 9999 "
    echo "    - Start after edits: goto dozzle/ and dcup (docker-compose up -d) "
    echo ""
fi
echo ""
echo "Interface installation done!"
echo "  - add your services: whoogle, wp, ghost ..."
echo "  - reboot befor starting up containers"
echo ""
echo "Rememper to have fun! Learn new things and love the CLI."
sleep 2s
read -rp "Do you want to reboot? [y/n] " RB
  if [[ "$RB" = [yY] ]]; then
     sudo reboot
  else
    echo "Exit - automated process"
    echo "  - Edit the scripts! "
    echo "  - Set re-directs in router"
    echo "  - Read the code, change to your needs, add your stuff and passwords ! "
    echo "  - REBOOT befor running containers"
  fi
