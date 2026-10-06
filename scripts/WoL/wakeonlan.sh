#!/usr/bin/env bash

# Generic Functions ==========================================================#

version() { # Function to show version info
    echo ""
    echo "wolstart.sh Wake on Lan for Servers"
    echo "Part of the MyJourney project @ homelab.casaursus.net (based on a 20 year old script of mine)"
    echo ""
    echo "Created by Nalle Juslén 27.8.2020, version 1.1 1.12.2021"
    echo "  v.2.0 4.1.2022, v. 2.1 9.3.2022, v. 2.2 29.8.2022"
    echo "  v.3.0 1.9.2023, v. 3.1 6.9.2023"
    echo ""
    }

copyright(){ # Function to show Copyright info
    echo ""
    echo "Copyright (C) 2023 Free Software Foundation, Inc."
    echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
    echo ""
    echo "This is free software; you are free to change and redistribute it."
    echo "There is NO WARRANTY, to the extent permitted by law."
    echo ""
    }

helps(){ # Function to show help
    clear
    echo "Syntax: wolstart [-f <file name>] [-i <NIC>] [-n] [-h|--help] -c -v"
    echo "  - i the name of your NIC to use: eth0"
    echo "      use if NIC AutoDetect don't work (more than 1 NIC)"
    echo "  - f use a file for data <path>/file: wolstart -f ~/my.wol.nodes"
    echo "      use if you have no local data (nodeData)"
    echo "  - n use ping by name instead of IP"
    echo "  - h Show this help"
    echo "  - c Copyright statement"
    echo "  - v Version statement"
    echo "  To use internal data: wolstarts [-n]"
    echo ""
    }

# Sourced Functions: from the same directory as the script ===================#

source useColors
source spinner
source setRoot

# Data Section Arrays and variables ==========================================#

macArray=(); ipArray=(); nameArray=(); statusArray=();startArray=()
err=0; wolFile=""; nodes=0 # Tally on nodes

nodeData="NAS-1,192.0.2.40,00:11:22:33:44:55
Pve-1,192.0.2.41,00:11:22:33:44:55
Pve-2,192.0.2.42,00:11:22:33:44:55
Pve-3,192.0.2.43,00:11:22:33:44:55
Pve-4,192.0.2.44,00:11:22:33:44:55
Pve-5,192.0.2.45,00:11:22:33:44:55
Pve-6,192.0.2.46,00:11:22:33:44:55
Pve-7,192.0.2.47,00:11:22:33:44:55
Pve-8,192.0.2.48,00:11:22:33:44:55
Pve-9,192.0.2.49,00:11:22:33:44:55"

# Local Functions ============================================================#

initDataLocal() { # Function read local data and split the csv_data into the arrays
    i=1
    while IFS=',' read -r nameArray ipArray macArray; do
        nameArray+=("$nameArray"); ipArray+=("$ipArray"); macArray+=("$macArray")
        (( nodes++ ))
    done <<< "$nodeData" # Read local data
    }

initDataFile() { # Function read and split the file with csv_data into the arrays
    i=1
    while IFS=',' read -r nameArray ipArray macArray; do
        nameArray+=("$nameArray"); ipArray+=("$ipArray"); macArray+=("$macArray")
        (( nodes++ ))
    done < "${wolFile}" # Read from file /dir/file
    }

testPing() { # Function to test by ping if a Server is down -----------------#
    RETRY=1
        ping -c $RETRY $1 > /dev/null 2>&1 # ping with no output
        status=$?
    return $status
    }

downServers() { # Fuction checking for down servers --------------------------#
    i=1
    while [ $i -le $nodes ]
    do
        statusArray[$i]=''
        testPing ${ipArray[$i]}
        statusArray[$i]=$?
        if [[ ${statusArray[$i]} == 0 ]]; then # display status
            echo -e "\b  ${nameArray[$i]}\t ${grn}✔  running  ${end}"
          else
            echo -e "\b  ${nameArray[$i]}\t ${red}✘  off line ${end}"
        fi
        (( i++ ))
    done
    }

askStart() { # Function Ask to start down Servers ----------------------------#
    tput setaf 3
    echo -e "\n$yel  \e[4mStart Servers not running              \e[0m"
    i=1
    while [ $i -le $nodes ]
    do
      if [[ ${statusArray[$i]} -ne 0 ]]; then
         read -rp "  Start node: ${nameArray[$i]} ${ipArray[$i]} [y/N] : " o
         startArray[$i]=$o
      fi
      (( i++ ))
    done
    }

startServers() { # Function for starting servers chosen to run ---------------#
    i=1; err=0
    while [ $i -le $nodes ]
    do
        if [[ ${startArray[$i]} == [yY] ]]; then
            echo -e "$yel \b  Booting up: $end\b ${nameArray[$i]} @ ${ipArray[$i]} MAC ${macArray[$i]}";
            sudo etherwake -i $myNIC ${macArray[$i]} 2>/dev/null
            if [ $? == 0 ]; then tput cuu1; echo -e "$grn✔$end"; else tput cuu1; err=1; echo -e "$red✘$end"; fi
            sleep .5;
        fi
        (( i++ ))
    done
    echo -e "\n$grnb\bSelected Servers start to boot up, it will take several minutes.$end"
    if [ $err == 1 ]; then echo -e "$redb \bError$end$yel Servers with the $red✘$yel prefix faild the start command.$end"; fi
    exit
    }

# Code Section ===============================================================#

useColors        # Use color codes
clear            # Clear the screan
myNIC=$( ls /sys/class/net | grep ^e) #NIC AutoDetect

# Main Script ================================================================#

echo -e "\n$yelb \bStart Proxmox nodes$end"
initDataLocal

tput setaf 3   # Set text to yellow foreground
echo -e "\nInitialaizing with ping"
echo -e "\b  Servers now running"
tput sgr0 # set graphic rendition to default
echo -e "  \e[4mnode      status  \e[0m"

# Run function and/or coude with a spinner. Start spinner and save the PID ---#
    spinner &
    spinner_pid=$!
        # Run your commands with spinner running
            downServers
        # Terminate the Spinner Show the Cursor Again
    kill "$spinner_pid"; wait "$spinner_pid" 2>/dev/null; tput cnorm
#-----------------------------------------------------------------------------#

# Do you want to run the rest of the script
read -rp $'\n\e[1;36m  Do you like to continue [Yn]: \e[0m' continue
    if [[ $continue == [nN] ]]; then
        exit
      else
        askStart # Function asking to start nodes not running
        read -rp $'\n\e[1;36m  Start selected Servers [y/N] : \e[0m' ok # Ask for confirmation
            echo ""
            if [[ $ok == [yY] ]]; then
                setRoot; tput cuu1; startServers # Function Start the choosen ones
              else
                echo -e "\n${redb} No Servers Started. $end${yel}Operators choise ${end}"
            fi
    fi
# End of script ==============================================================#
