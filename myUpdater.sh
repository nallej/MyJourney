#!/bin/bash

#------------------------------------------------------------------#
#  myUpdater.sh                                                    #
#  Part of the MyJourney project @ homelab.casaursus.net           #
#                                                                  #
#  V.1 Created by Nalle @ 29.11.2022                               #
#    -review 1.12.2022                                             #
#                                                                  #
#  V.2 Created by Nalle @ 4.1.2023                                 #
#    - revison                                                     #
#                                                                  #
# Date format and >>>> ---- <<<< **** for easy sorting             #
#   Updates for Debian (apt) and Redhat (dnf) based VM's           #
#                                                                  #
# NOTE  You NEED to run this script as SUDO !                      #
#------------------------------------------------------------------#

# Function hyrraPyorii. Show a activity spinner 
hyrraPyorii ()
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
#------------------------------------------------------------------#

# Function end_msg 
end_msg ()
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
#------------------------------------------------------------------#

# Function start_log 
start_log ()
{
    echo ">>>> Update started    @ $(date +"%F %T") ****  ****" >$ok_log
    echo ">>>> Update started    @ $(date +"%F %T") ****  ****" >$ei_log
}
#------------------------------------------------------------------#

# Function initUpdater
initUpdater()
{
os_rel=/etc/os-release
pvm=`date "+%Y-%m-%d"`
ok_log=/var/log/updater/"$pvm"_update_ok.log
ei_log=/var/log/updater/"$pvm"_update_error.log
if [ ! -d "/var/log/updater/" ]
then
  sudo mkdir /var/log/updater
  sudo chown :users /var/log/updater
  sudo chmod g+w /var/log/updater
fi
if [ ! -f $ok_log ]
then
  sudo touch $ok_log
  sudo chown :users $ok_log
fi
if [ ! -f $ei_log ]
then
  sudo touch $ei_log
  sudo chown :users $ei_log
fi
#------------------------------------------------------------------#
}

# Function startUpdater
startUpdater()
{
# Debian/Ubuntu/PopOS based ---------------------------------------#
if grep -q "debian" $os_rel
then
  echo -e "\b You are running a Debian based OS - Debian, Ubuntu, PopOS ..."
  sudo apt-get update 1>>$ok_log 2>>$ei_log
  sudo echo "---- Upgrade started   @ $(date +"%F %T") ****  ****" >>$ok_log
  sudo echo "---- Upgrade started   @ $(date +"%F %T") ****  ****" >>$ei_log
  sudo apt-get dist-upgrade -y 1>>$ok_log 2>>$ei_log
# Redhat/Fedora/CentOS --------------------------------------------#
elif grep -q "CentOs" $os_rel || grep -q "Fedora" $os_rel || grep -q "redhat"
then
  echo -e "\b You are running a Fedora or Redhat 8 based OS"
  sudo dnf upgrade -y 1>>$ok_log 2>>$ei_log
else
  echo ""
  echo "WARNING - Wrong OS for this version of myUpdater!"
  echo ""
fi
}

# Main =========================================================== #
clear
echo ""
echo "You are running:"
grep -E '^(VERSION|NAME)=' /etc/os-release
echo ""
echo "You need to run myUpdater as SUDO!"
echo ""
read -rp "Do you want to upgrade this VM [y/N]: " UPG
echo ""
if [[ "$UPG" = [yY] ]]; then
  initUpdater
  start_log
  startUpdater & hyrraPyorii
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
fi
# ================================================================ #
