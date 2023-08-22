#!/bin/bash

#-----------------------------------------------------------------------------#
#  WOL.sh for Proxmox Servers                                                 #
#  Part of the MyJourney project @ homelab.casaursus.net                      #
#                                                                             #
#  V.1 Created by Nalle Juslén 29.8.2022                                      #
#    -review 1.12.2022                                                        #
#                                                                             #
#  V.2 Created by Nalle Juslén 4.1.2023                                       #
#    - revison 9.3.2023, 29.8.2023                                            #
#                                                                             #
#   How to use this tool: Enter myNIC and Servers MAC abd URL below and run.  #                                                                   #
#                                                                             #
#-----------------------------------------------------------------------------#


# Please enter the Servers MAC and URL here ==================================#
# Function to set URL and MAc for the Servers --------------------------------#
setMACurl () {
# Node-1
    MAC1=00:11:22:33:44:55
    URL1=192.0.2.41
# Node-2
    MAC2=00:11:22:33:44:55
    URL2=192.0.2.42
# Node-3
    MAC3=00:11:22:33:44:55
    URL3=192.0.2.43
# Node-4
    MAC4=00:11:22:33:44:55
    URL4=192.0.2.44
# Node-5
    MAC5=00:11:22:33:44:55
    URL5=192.0.2.45
# Node-6
    MAC6=00:11:22:33:44:55
    URL6=192.0.2.6
# Node-7
    MAC7=00:11:22:33:44:55
    URL7=192.0.2.47
# Node-8
    MAC8=00:11:22:33:44:55
    URL8=192.0.2.48
# Node-9
    MAC9=00:11:22:33:44:55
	  URL9=10.10.10.49
}
# ============================================================================#

# My myNIC used by etherwake =================================================#
myNIC=enp2s0
#=============================================================================#

# Function to display an animated spinner ------------------------------------#
spinner() {
#The different Spinner Arrays to choose from
    local array1=("◐" "◓" "◑" "◒")
    local array2=("░" "▒" "▓" "█")
    local array3=("╔" "╗" "╝" "╚")
    local array4=("┌" "┐" "┘" "└")
    local array5=("▄" "█" "▀" "█")
    local array6=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
# Delay between each character
    local delays=0.1 

    while :; do
        for character in "${array6[@]}"; do #Which Array to Use
            printf "%s" "$character"
            sleep "$delays"
            printf "\b"  # Move the cursor back
        done
    done
}

# Function to test if a Server is down, using ping ----------------------------#
testPing () {
RETRYCOUNT=1;
#echo Checking server: $1
  ping -c $RETRYCOUNT $1 > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    status=1
    #echo $1 down
  else
    status=2
    #echo $1 live
  fi
return $status
}

# Function check running servers ---------------------------------------------#
runningServers() {


testPing $URL1; st1=$?; if [[ $st1 == 2 ]]; then
	echo -e "\b  Node-1 is ${G}running${No}"; else echo -e "\b  Node-1 is ${R}off line${No}"; fi
testPing $URL2; st2=$?; if [[ $st2 == 2 ]]; then
	echo -e "\b  Node-2 is ${G}running${No}"; else echo -e "\b  Node-2 is ${R}off line${No}"; fi
testPing $URL3; st3=$?; if [[ $st3 == 2 ]]; then
	echo -e "\b  Node-3 is ${G}running${No}"; else echo -e "\b  Node-3 is ${R}off line${No}"; fi
testPing $URL4; st4=$?; if [[ $st4 == 2 ]]; then
	echo -e "\b  Node-4 is ${G}running${No}"; else echo -e "\b  Node-4 is ${R}off line${No}"; fi
testPing $URL5; st5=$?; if [[ $st5 == 2 ]]; then
	echo -e "\b  Node-5 is ${G}running${No}"; else echo -e "\b  Node-5 is ${R}off line${No}"; fi
testPing $URL6; st6=$?; if [[ $st6 == 2 ]]; then
	echo -e "\b  Node-6 is ${G}running${No}"; else echo -e "\b  Node-6 is ${R}off line${No}"; fi
testPing $URL7; st7=$?; if [[ $st7 == 2 ]]; then
	echo -e "\b  Node-7 is ${G}running${No}"; else echo -e "\b  Node-7 is ${R}off line${No}"; fi
testPing $URL8; st8=$?; if [[ $st8 == 2 ]]; then
	echo -e "\b  Node-8 is ${G}running${No}"; else echo -e "\b  Node-8 is ${R}off line${No}"; fi
testPing $URL9; st9=$?; if [[ $st9 == 2 ]]; then
	echo -e "\b  Node-9 is ${G}running${No}"; else echo -e "\b  Node-9 is ${R}off line${No}"; fi
echo ""
}

# Colors and Controls to use -------------------------------------------------#
R='\e[0;31m'
G='\e[0;32m'
Y='\e[1;33m'
No='\033[0m' # No Color

# Main =======================================================================#

clear
tput setaf 3

echo "Start Proxmox nodes"

# Check for root privilidges
#if [[ "$EUID" != 0 ]]; then
#    echo "${R}You need to be root. Pleas run as sudo.${No}"
#    exit
#fi

if [[ "$EUID" = 0 ]]; then
    echo "" #Start Proxmox nodes"
    echo "Initialaizing:" #"already root"
else
    sudo -k
    if sudo true; then
        clear
        echo "Start Proxmox nodes"
        echo ""
        echo "Initialaizing:" #correct password
    else
        echo "wrong password"
        exit #exit 1 #re-try the password
    fi
fi

sleep 1
#echo "Initialaizing..."
setMACurl
    tput setaf 3
    echo -e "\b  Server Status"
    #echo ""
    tput sgr0
    echo -e "  \e[4mnode     status  \e[0m"

# Run the spinner in the background and Save the PID
spinner &
spinner_pid=$!

runningServers

# Terminate the Spinner
kill "$spinner_pid"
wait "$spinner_pid" 2>/dev/null
# Show the Cursor Again
tput cnorm

read -rp "Do you like to continue [Yn]: " cont
if [[ $cont == [nN] ]]; then exit; fi

tput setaf 3
echo -e "\e[4m${Y}Start Servers not running\e[0m"
#echo ""
#tput sgr0

# Ask to start if not running
if [[ $st1 == 2 ]]; then
    	echo -e "  Node-1 is ${G}running${No} $URL1 $MAC1 $st"
	else
    	read -rp "  Node-1 [y/N] : $st" p1
	fi

if [[ $st2 == 2 ]]; then
    	echo -e "  Node-2 is ${G}running${No} $URL2 $MAC2"
	else
    	read -rp "  Node-2 [y/N] : " p2
	fi

if [[ $st3 == 2 ]]; then
    	echo -e "  Node-3 is ${G}running${No} $URL3 $MAC3"
	else
    	read -rp "  Node-3 [y/N] : " p3
	fi

if [[ $st4 == 2 ]]; then
    	echo -e "  Node-4 is ${G}running${No} $URL4 $MAC4"
	else
    	read -rp "  Node-4 [y/N] : " p4
	fi

if [[ $st5 == 2 ]]; then
        echo -e "  Node-5 is ${G}running${No} $URL5 $MAC5"
    else
        read -rp "  Node-5 [y/N] : " p5
    fi

if [[ $st6 == 2 ]]; then
        echo -e "  Node-6 is ${G}running${No} $URL6 $MAC6"
    else
        read -rp "  Node-6 [y/N] : " p6
    fi

if [[ $st7 == 2 ]]; then
        echo -e "  Node-7 is ${G}running${No} $URL7 $MAC7"
    else
        read -rp "  Node-7 [y/N] : " p7
    fi

if [[ $st8 == 2 ]]; then
        echo -e "  Node-8 is ${G}running${No} $URL8 $MAC8"
    else
        read -rp "  Node-8 [y/N] : " p8
    fi

if [[ $st9 == 2 ]]; then
        echo -e "  Node-9 is ${G}running${No} $URL9 $MAC9"
    else
        read -rp "  Node-9 [y/N] : " p9
    fi
echo ""
read -rp $'\e[1;31mStart the Servers [y/N] : \e[0m' ok
echo ""

 # Start the choosen nodes ----------------------------------------------------#
if [[ $ok == [yY] ]]; then
    # Start the nodes (need to run as sudo)
    if [[ $p1 == [yY] ]]; then echo "Starting Node-1"; etherwake $MAC1 -i $myNIC; sleep .5; fi
    if [[ $p2 == [yY] ]]; then echo "Starting Node-2"; etherwake $MAC2 -i $myNIC; sleep .5; fi
    if [[ $p3 == [yY] ]]; then echo "Starting Node-3"; etherwake $MAC3 -i $myNIC; sleep .5; fi
    if [[ $p4 == [yY] ]]; then echo "Starting Node-4"; etherwake $MAC4 -i $myNIC; sleep .5; fi
    if [[ $p5 == [yY] ]]; then echo "Starting Node-5"; etherwake $MAC5 -i $myNIC; sleep .5; fi
    if [[ $p6 == [yY] ]]; then echo "Starting Node-6"; etherwake $MAC6 -i $myNIC; sleep .5; fi
    if [[ $p7 == [yY] ]]; then echo "Starting Node-7"; etherwake $MAC7 -i $myNIC; sleep .5; fi
    if [[ $p8 == [yY] ]]; then echo "Starting Node-8"; etherwake $MAC8 -i $myNIC; sleep .5; fi
    if [[ $p9 == [yY] ]]; then echo "Starting Node-9"; etherwake $MAC9 -i $myNIC; sleep .5; fi
    echo ""
fi

# End of script ==============================================================#
