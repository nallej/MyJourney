#!/bin/bash

#------------------------------------------------------------------#
#  myVMsetup.sh                                                    #
#  Part of the MyJourney project @ homelab.casaursus.net           #
#                                                                  #
#  V.1 Created by Nalle @ 5.1.2023                                 #
#    -review 9.1.2023                                              #
#                                                                  #
#------------------------------------------------------------------#

hyrra() # Function - Shows the activity spinner
    {
       pid=$!   # PID of the previous running command
       x='-\|/' # hyrra in its elements
       i=0
       while kill -0 $pid 2>/dev/null
       do
         i=$(( (i+1) %4 ))
         printf "\r  ${x:$i:1}"
         sleep .1
        done
        printf "\r  "
    }


askOS() #Function to get the OS
    {
      os_rel=/etc/os-release
      if grep -q "debian" $os_rel
        then
          myOS=1
      elif grep -q "CentOs" $os_rel || grep -q "Fedora" $os_rel || grep -q "redhat"
        then
          myOS=2
      else
        echo ""
        echo "WARNING - Wrong OS for myVMsetop!"
        echo ""
        exit
      fi
    }


askTZ() #Function - get the TimeZone variable
    {
        echo ""
        echo "What Time zone (TZ) do you use"
        read -rp "  Your area (Europe):   " YA
        read -rp "  Your City (Helsinki): " YC
        myTZ=$YA/$YC
        echo ""
        PS3="TZ = $myTZ - is this correct? [1=No 2=Yes] "
        select _ in \
          " No  - incorrect location" \
          " Yes - this is my place" \
          " Exit"
        do
          case $REPLY in
            1) askTZ ;;
            2) nextPart ;;
            *) echo "  Invalid selection, please try again " ;;
          esac
        done
    }


nextPart() #Function to install needed parts
    {
      askAPPS
      installBaseApps
      if [[ $myOS = 1 ]]
         then
           doAppInstall
      elif [[ $myOS = 2 ]]
         then
           installDNF
      else
          echo "  Error - Invalid OS "
          exit
      fi
    }



end_msg() # Function - final messages into log-files
    {
      if [ $? -ne 0 ]
      then
        echo ""
        echo "<<<< Ended with errors @ $(date +"%F %T") ****   ****" >>$ei_log
        echo "ERROR! ERROR! ERROR!"
        echo "Error occurred while upgrading - check the log: $ei_log"
        echo ""
      else
        echo ""
        echo "<<<< Upgrade ended OK  @ $(date +"%F %T") ****   ****" >>$ok_log
        echo "<<<< No errors found   @ $(date +"%F %T") ****   ****" >>$ei_log
        echo "Update completed - please read the log: $ok_log"
      fi
    }


start_log() # Function - initialize the log-files
    {
      echo ">>>> Update started    @ $(date +"%F %T") ****  ****" >$ok_log
      echo ">>>> Update started    @ $(date +"%F %T") ****  ****" >$ei_log
    }


initUpdater() # Function initUpdater - initialize variables and log-files
    {
      #os_rel=/etc/os-release
      pvm=`date "+%Y-%m-%d"`
      ok_log=/var/log/updater/"$pvm"_update_ok.log
      ei_log=/var/log/updater/"$pvm"_update_error.log
      if [[ ! -d "/var/log/updater/" ]]; then
          sudo mkdir /var/log/updater
          sudo chown $me:users /var/log/updater
          sudo chmod g+w /var/log/updater
      fi
      if [[ ! -f $ok_log ]]; then
          sudo touch $ok_log
          sudo chown $me:users $ok_log
      fi
      if [[ ! -f $ei_log ]]; then
          sudo touch $ei_log
          sudo chown $me:users $ei_log
      fi
    }


startUpdater() # Function startUpdater
    {
      if [[ $myOS -eq 1 ]] #grep -q "debian" $os_rel # Debian/Ubuntu/PopOS based
        then
          echo -e "\b You are running a Debian based OS - Debian, Ubuntu, PopOS ..."
          sudo apt-get update 1>>$ok_log 2>>$ei_log
          sudo echo "---- Upgrade started   @ $(date +"%F %T") ****  ****" >>$ok_log
          sudo echo "---- Upgrade started   @ $(date +"%F %T") ****  ****" >>$ei_log
          sudo apt-get dist-upgrade -y 1>>$ok_log 2>>$ei_log
      elif [[ $myOS -eq 2 ]] #grep -q "CentOs" $os_rel || grep -q "Fedora" $os_rel || grep -q "redhat" # Redhat/Fedora/CentOS
        then
          echo -e "\b You are running a Fedora or Redhat 8 based OS"
          sudo dnf upgrade -y 1>>$ok_log 2>>$ei_log
      else
        echo ""
        echo "WARNING - Wrong OS for myVMsetop!"
        echo ""
        exit
      fi
    }


installBaseApps() # Function installs basic apps and features
    {
      echo ""
      echo "Starting upgrade/install of apps for the Docker-stack"
      echo ""
      #lsb_release -a #print lsb-release info
      echo ""
      echo "  Starting the Install "
      sleep 3
      read -rp "  - Do you want to do the Install  [y/n] " DPI
        if [[ "$DPI" = [yY] ]]; then
           echo "  - Running VM updates and installs ..."
           echo "  - The logfile is opend in your home directory - install.log"
          # Add bash_aliases and prompt--------------------------------------------------
          wget https://raw.githubusercontent.com/nallej/MyJourney/main/.bash_aliases &> /dev/null
          wget https://raw.githubusercontent.com/nallej/MyJourney/main/.bash_prompt &> /dev/null
          (. ~/.bash_aliases) >> ~/install.log 2>&1
          echo "  - added .bash_aliases"
          # Add bash_aliases ------------------------------------------------------------
          sudo timedatectl set-timezone "$myTZ"
          echo "  - Setting up unattenden updates = yes "
          (sudo systemctl enable unattended-upgrades --now) >> ~/install.log 2>&1
          echo ""
          echo "  WARNING - Do you want to clear old updates?"
          read -rp "  - Clear old updates  [y/n] " COU
          if [[ "$COU" = [yY] ]]; then
             echo "  - Deliting old installs ..."
             sudo apt-get clean >> ~/install.log 2>&1
             sudo apt-get autoremove >> ~/install.log 2>&1
          fi
          if [[ ! -d "~/docker/" ]]; then
             mkdir ~/docker
             echo "  + Added the dir [~/docker] for the Docker-stack "
          fi
        else
          exit
      fi
    }

askAPPS() #Function - What to install
  {
    isDOCE=$( (sudo systemctl is-active docker ) 2>&1 )
    isDOCO=$( (docker-compose -v ) 2>&1 )
    echo ""
    echo "NOTE: Without Docker you cannot use Docker-Compose, NGinx Proxy Manager, or Portainer-CE."
    echo "      You also must have Docker-Compose for NGinX Proxy Manager to be installed."
    echo "NOTE: - Portainer-ce    - Web GUI for Docker, Swarm and Kubernetes"
    echo "      - Portainer Agent - Remote Agent for other Portainer-ce to Connect to"
    echo ""
    if [[ "$isDOCE" != "active" ]]
        then
          echo "Please install  Docker-ce"
          #echo ""
      else
          echo "Note -> Docker appears to be installed and running."
          #echo ""
    fi
    if [[ "$isDOCO" == *"command not found"* ]]
        then
          echo "Please install Docker-Compose"
          echo ""
      else
          echo "Note -> Docker-compose appears to be installed."
          echo ""
    fi
    echo "You need to install these apps:"
    read -rp "  Docker-ce              [y/n] " DOCE
    read -rp "  Docker-Compose         [y/n] " DOCO
    echo "Good to have: Portainer or it's Agent "
    read -rp "  - Portainer-ce         [y/n] " POT
    read -rp "  - Portainer Agent      [y/n] " POTA
    echo ""
    echo "Apps you can set up via Portainer or Docker-Compose."
    echo "Recommended apps:"
    read -rp "  WatchTower, updater    [y/n] " WT
    read -rp "  Dozzle, reading logs   [y/n] " DOZ
    echo ""
    echo "Optional apps "
    read -rp "  -  NGinX Proxy Manager [y/n] " NPM
    read -rp "  -  Heimdall            [y/n] " HEIM
    read -rp "  -  Authelia            [y/n] " AUTH
    read -rp "  -  Bind9 DNS, ICS-DHCP [y/N] " DNS
  }


doAppInstall() # Function to install the Apps
    {
      if [[ "$DOCE" == [yY] ]]; then
        installDOCE
      fi
      if [[ "$DOCO" == [yY] ]]; then
        installDOCO
      fi
      if [[ "$POT" == [yY] ]]; then
        installPOT
      fi
      if [[ "$POTA" == [yY] ]]; then
        installPOTA
      fi
      if [[ "$WT" == [yY] ]]; then
        installWT
      fi
      if [[ "$DOZ" == [yY] ]]; then
        installDOZ
      fi
      if [[ "$HEIM" == [yY] ]]; then
        installHEIM
      fi
      if [[ "$NPM" == [yY] ]]; then
        installNPM
      fi
      if [[ "$AUTH" == [yY] ]]; then
        installAUTH
      fi
      if [[ "$DNS" == [yY] ]]; then
        installDNS
      fi

      echo ""
      echo "Basic installation done!"
      echo "  - add services: prometheus, node-reporter, backup ..."
      echo "  - add your apps wp, ghost, pfSense, Zabbix ...."
      echo "  - logout and login again to activate permissions"
      echo "  - please reboot node befor starting apps"
      echo ""
      echo "Rememper to have fun! Learn new things and love the CLI."
      echo ""
    exit
    }

installDOCE() # Funtion installing Docker-ce on this VM
    {
      #sudo ls &> /dev/null # dummy to get sudo psw if user not part of SUDO groupe
      echo "Installing Docker-ce"
      sudo curl -fsSL https://get.docker.com | sh >> ~/install.log 2>&1 & hyrra
      echo ""
      echo "  - Docker-ce installed. "
      echo "    - Starting docker."
      echo ""
      (sleep 10s
      sudo systemctl enable docker
      sudo systemctl enable containerd.service
      sudo systemctl start docker
      sleep 5s
      docker -v
      sleep 2s
      sudo usermod -aG docker "$me" # you do not need to sudo to run docker commands after re-login
      sleep 1s) >> ~/install.log 2>&1 & hyrra
      sudo docker network create -d bridge kadulla  &> /dev/null #frontend
      sudo docker network create -d bridge pihalla  &> /dev/null #backbone
      echo "    - $me added to the docker group (active after next login)."
      echo ""
      echo "    - Internal networks created:"
      echo "      - kadulla = frontend "
      echo "      - pihalla = backbone "
      echo ""
    }


installDOCO() # Funtion installing Docker-Compose on this VM
    {
      ( sudo apt install -q docker-compose -y ) >> ~/install.log 2>&1 #& hyrra
      echo "  - Docker-Compose installed."
      echo ""
      sleep 2
      verDOCO=$(docker-compose --version)
      echo "    - Version is: $verDOCO"
      echo ""
      sleep 1
    }


installPOT() #Function installing Portainer-ce on this VM
    {
      ( sudo docker volume create portainer_data
        sudo docker run -d \
         -p 8000:8000 \
         -p 9000:9000 \
         --name=portainer \
         --restart=always \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -v portainer_data:/data \
         portainer/portainer-ce ) >> ~/install.log 2>&1 & hyrra
      echo "  - Portainer can now be found @ ip x.x.x.x:9000"
      echo ""
    }


installPOTA() # Function installing Portainer Agent on this VM
    {
      ( sudo docker volume create portainer_data
        sudo docker run -d \
         -p 9001:9001 \
         --name portainer_agent \
         --restart=always \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -v /var/lib/docker/volumes:/var/lib/docker/volumes \
         portainer/agent) >> ~/install.log 2>&1 & hyrra
      echo "  - Portainer finds this agent @ ip x.x.x.x:9001"
      echo ""
    }

installWT() # Function installing WatchTower on this VM
    {
      if [[ ! -d "~/docker/watchtower/" ]]; then
         mkdir ~/docker/watchtower
      fi
      #cd ~/docker/watchtower
      wget -P ~/docker/watchtower https://raw.githubusercontent.com/nallej/MyJourney/main/watchtower/docker-compose.yml &> /dev/null
      # uncomment the next line if you want to start it now
      # docker-compose up -d
      echo "Watchtower installed"
      echo "  - Updating images daily 04.00 "
      echo "  - NOT started, edit befor starting"
      echo ""
    }


installDOZ() # Function installing Dozzle log reader on this VM
    {
      if [[ ! -d "~/docker/dozzle/" ]]; then
         mkdir ~/docker/dozzle
      fi
      wget -P ~/docker/dozzle https://raw.githubusercontent.com/nallej/MyJourney/main/dozzle/docker-compose.yml &> /dev/null
      # uncomment the next line if you want to start it now
      # sudo docker-compose up -d
    ## Uncomment the next line if you want to ask
      #read -rp "Start Dozzle now [yN] startDOZ
      #if [[ "$startDOZ" == [yY] ]]; then
      #   docker-compose up -d
      #   sleep 2
      #fi
      echo "Dozzle config installed"
      echo "  - Not started, EDIT befor using"
      echo "  - ports: 9999"
      echo ""
    }


installHEIM() # Function installing Heimdall Dashboard app on this VM
    {
      if [[ ! -d "~/docker/heimdall/" ]]; then
         mkdir ~/docker/heimdall
      fi
      wget -P ~/docker/heimdall https://raw.githubusercontent.com/nallej/MyJourney/main/heimdall/docker-compose.yml &>/dev/null
    # Uncomment the next line if you want to start it now
      #docker-compose up -d
    ## Uncomment the next line if you want to ask
      #read -rp "Start the Heimdall now [yN] startHEIM
      #if [[ "$startHEIM" == [yY] ]]; then
      #   docker-compose up -d
      #   sleep 2
      #fi
      echo "Heimdal config installed"
      echo "  - Not started, EDIT befor using"
      echo "  - default user/group: 1000/1000"
      echo "  - ports: 9080 or 9088 "
      echo ""
      sleep 2
    }


installNPM() # Funtion for installing NGinX Proxy Manager on this VM
    {
      if [[ ! -d "~/docker/npm/" ]]; then
            mkdir ~/docker/npm
      fi
      curl -o ~/docker/npm/docker-compose.yml https://raw.githubusercontent.com/nallej/MyJourney/main/interface/npm.yml &>/dev/null
    # Uncomment the next line if you want to start it now
      #docker-compose up -d
    ## Uncomment the next line if you want to ask
      #read -rp "Start NPM now [yN] startNPM
      #if [[ "$startNPM" == [yY] ]]; then
      #   docker-compose up -d
      #   sleep 2
      #fi
      echo "NGinX Proxy Manager is installed"
      echo "  - Start and go to your server on port 81 to setup NPM admin account."
      echo "  - default login credentials for NPM are:"
      echo "      username: admin@example.com"
      echo "      password: changeme"
      echo ""
      sleep 3
    }


installAUTH() # Function to install Authelia on this VM
    {
    if [[ ! -d "~/docker/authelia/" ]]; then
            mkdir ~/docker/authelia
            mkdir ~/docker/authelia/config
            mkdir ~/docker/authelia/config/assets/
            mkdir ~/docker/authelia/npm-advanced-cfgs
      fi
      curl -o ~/docker/authelia/config/docker-compose.yml https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-config.yml &>/dev/null
      curl -o ~/docker/authelia/config/users.yml https://raw.githubusercontent.com/nallej/MyJourney/main/interface/users &>/dev/null
      curl -o ~/docker/authelia/npm-advanced-cfgs/npm.site.advanced.cfg https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-cfg-site &>/dev/null     
      curl -o ~/docker/authelia/npm-advanced-cfgs/npm.auth.advanced.cfg https://raw.githubusercontent.com/nallej/MyJourney/main/interface/authelia-cfg-auth &>/dev/null
      echo "Authelia config and other files are is installed"
      echo "  - Start and go to your server for setting up the autentication services"
      echo ""
      sleep 3
    }

installDNS() #Function  to install Bind9 DNS server
{
    if [[ ! -d "~/docker/dns/" ]]; then
            mkdir ~/docker/dns
            mkdir ~/docker/dns/cache
            mkdir ~/docker/dns/config
            mkdir ~/docker/dns/records
            mkdir ~/docker/dns/dhcp 
            mkdir ~/docker/dns/dhcp/data
      fi
      wget -P ~/docker/dns/ https://raw.githubusercontent.com/nallej/MyJourney/main/dns/docker-compose.yml &>/dev/null
      wget -P ~/docker/dns/config/ https://raw.githubusercontent.com/nallej/MyJourney/main/dns/config/db.lab-example-com.zones &>/dev/null
      wget -P ~/docker/dns/config/ https://raw.githubusercontent.com/nallej/MyJourney/main/dns/config/db.182.168.1 &>/dev/null
      wget -P ~/docker/dns/config/ https://raw.githubusercontent.com/nallej/MyJourney/main/dns/config/named.conf &>/dev/null
      wget -P ~/docker/dns/dhcp/ https://raw.githubusercontent.com/nallej/MyJourney/main/dns/dhcp/docker-compose.yml &>/dev/null
      wget -P ~/docker/dns/dhcp/data/ https://raw.githubusercontent.com/nallej/MyJourney/main/dns/dhcp/data/dhcp.conf &>/dev/null
      echo "Bind 9 files are installed"
      echo "  - Edit the files in ~/docker/dns/config before starting"
      echo "    - db.lab-example-com.zones db.192.168.1 & named.conf"
      echo "  - Edit resolved.conf"
      echo "    - sudo nano /etc/systemd/resolved.conf"
      echo "    - sudo systemctl restart systemd-resolved"
      echo "    - sudo systemctl status systemd-resolved"
      echo "  - Start your Bind9 DNS"
      echo ""
      echo "  Optional ICS-DHCP"
      echo "  - Edit ~/dns/docker-compose.yml"
      echo "    - Edit the ~/docker/dnd/dhcp/data/dhcpd.conf"
      echo "  - Start ICS-DHCP"
      echo ""
      sleep 3
}


# Main =======================================================

clear
askOS
me="${SUDO_USER:-${USER}}"
echo ""
echo "You, $me are running:"
grep -E '^(VERSION|NAME)=' /etc/os-release
echo ""
echo ""
echo "Create a Docker based VM"
echo "---------------------------------------------------------------------------------"
echo ""
echo "  WARNING - DON'T run scripts you download from the net without checking it first"
echo "  WARNING - Read the code - edit it and then run it!"
echo ""
echo "  Warning, this script will pull additional parts from my GitHub"
echo ""
sleep 3
read -rp "Do you want to SetUp this VM   [y/N]: " SUP
if [[ "$SUP" != [yY] ]]
  then
    exit
fi
echo ""
read -rp "Do you want to upgrade this VM [y/N]: " UPG
echo ""
if [[ "$UPG" = [yY] ]]
  then
    initUpdater
    start_log
    startUpdater & hyrra
    end_msg
    # Post upgrade messsge
    echo ""
    echo ""
    read -rp "  Do you want to see the error-log [y/N]: " SEL
      if [[ "$SEL" = [yY] ]]; then
         cat $ei_log
      fi
    echo ""
    read -rp "  Do you like to see the ok-log [y/N]: " SOK
      if [[ "$SOK" = [yY] ]]; then
         cat $ok_log
      fi
  else
    if [[ $myOS = 1 ]]; then
        echo "  - Performing apt-update "
        (sudo apt-get update &> /dev/null) &  hyrra
    else
        sudo dnf upgrade
        echo "  Please reboot the VM"
        echo "    - and then test for errors: "
        echo "      dmesg | egrep -i 'error|critical|warn|failed'"
    fi
fi

# Starting installation of apps
echo ""
echo "Current system Time zone (TZ) is: $(cat /etc/timezone)" 
read -rp "  - Do you want to change [y/N] " CTZ
if [[ "$CTZ" = [yY] ]]; then
    askTZ
  else
    nextPart
fi    