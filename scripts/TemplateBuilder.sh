#!/bin/bash

#-----------------------------------------------------------------------------#
# For more info see: https://pve.proxmox.com/pve-docs/qm.conf.5.html          #
#-----------------------------------------------------------------------------#

###############################################################################
 #                                                                           #
  #       👍    👍     E D I T  t h i s  S E C T I O N      👍    👍       #
 #                                                                           #
###############################################################################

#------------------------------------------------------------------------------
# 👤 Admin user pre-fills
#------------------------------------------------------------------------------
     # 🔟 Create a long and complicated password
     #   6 is a joke,  8 is something,  12 is semi ok,  16 is ok,  20 is good.
     # 🔐 SSH Public Key or download it later in the GUI into the cloud-init
     initUSER=Administrator        # admin user name
     passLENGHT=16                 # length of password
     initPASSWD=Passw0rd           # a long and complicated password
     showPASSWD=false              # Show Password in log true/false
     initKEY=~/.ssh/my_key.pub     # typically ~/.ssh/id_ed25519.pub
#------------------------------------------------------------------------------
     # 🔐 Add user to Docker Groupe - NOT recommended for production
     testMODE=true                  # Set to true/false for elevated privilidges in Testing / HomeLab mode
#------------------------------------------------------------------------------
# 📂 Server Cloud Image - add and/or edit to use your favorite OS
#------------------------------------------------------------------------------
# OS-1 ------------------------------------------
    osFILE1="ubuntu-22.04-minimal-cloudimg-amd64.img"
    osFAMILY1="ubuntu"
    osLOCATION1="https://cloud-images.ubuntu.com/minimal/releases/jammy/release/"
    # Special version ment for no user login
# OS-2 ------------------------------------------
    osFILE2="jammy-server-cloudimg-amd64.img"
    osFAMILY2="ubuntu"
    osLOCATION2="https://cloud-images.ubuntu.com/jammy/current/"
    # Standard server image
# OS-3 ------------------------------------------
    osFILE3="jammy-server-cloudimg-amd64-disk-kvm.img"
    osFAMILY3="ubuntu"
    osLOCATION3="https://cloud-images.ubuntu.com/jammy/current/"
    # A KVM optimized server for KVM based hypervisors
# OS-4 ------------------------------------------
    osFILE4="debian-12-genericcloud-amd64.qcow2"
    osFAMILY4="debian"
    osLOCATION4="https://cloud.debian.org/images/cloud/bookworm/latest/"
    # For virtual use, smaller by excluding drivers for physical hardware
# OS-5 ------------------------------------------
    osFILE5="debian-12-generic-amd64.qcow2"
    osFAMILY5="debian"
    osLOCATION5="https://cloud.debian.org/images/cloud/bookworm/latest/"
    # HW and virtual,  for e.g. OpenStack, DigitalOcean and also on real rust
# OS-6 ------------------------------------------
    osFILE6="alpine-virt-3.19.0-x86_64.iso"
    osFAMILY6="alpine"
    osLOCATION6="$https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/"
    ## Alpine will not use any other options ONLY Docker
# OS-7 ------------------------------------------
    osFILE7=""
    osFAMILY7=""
    osLOCATION7=""
# OS-8 ------------------------------------------
    osFILE8=""
    osFAMILY8=""
    osLOCATION8=""
# OS-9 ------------------------------------------
    osFILE9=""
    osFAMILY9=""
    osLOCATION9=""
#------------------------------------------------------------------------------
# 📂 Local and External PATHs to your ISO files. See  /etc/pve/storage.cfg
#    Using manual settings makes complicated storage setups easier to use.
#------------------------------------------------------------------------------
# Default Local Storage.
    nameISO1=local
    pathISO1="/var/lib/vz/template/iso/"
# Local ISO storage
    nameISO2=localISO
    pathISO2="/storage/ISO/template/iso/"
# Default NFS if any, use the NFS-storage name you have
    nameISO3=nfsISO
    pathISO3="/mnt/pve/nfsISO/template/iso/"
# Default USB if any, use the USB-storage name you have
    nameISO4=ISO
    pathISO4="/upool/ISO/template/iso/"
# More defaults if needed
    #nameISO5= < name >
    #pathISO5= < path >

## Can be replase with /etc/pve/storage.cfg lookup
    ## Only for small standard setups
    ## On Large setups it's usless
##

#------------------------------------------------------------------------------
# 📑 Other initialisation variables
#------------------------------------------------------------------------------
     initVMNO=3000                  # suggested VM numbre
     initVMNAME=k0s-ctrlr           # suggested VM name
     initTEMPLATENO=30000           # suggested Template number
     initTEMPLATENAME=k0s-template  # suggested Template name
     initNOCLONES=2                 # suggested how many Clones to create
     initNO1STCLONE=3001            # suggested number for 1st Clone
     initCLONENAME=node-            # suggested Clone namebas for e.g. node-1
     initVMBR=vmbr0                 # the prefered virtual bridge
     initVLAN=30                    # the prefered VLAN
     logFILE=~/TemplateBuilder.log  # Name of your LOG file
#------------------------------------------------------------------------------
#    E n d   o f   t h e   E d i t a b l e   S e c t i o n                    #
#------------------------------------------------------------------------------


###############################################################################
 #                                                                           #
  #   ✋   N O  n e e d  t o  E D I T  B e l o w  t h i s  P o i n t   🚫  #
 #                                                                           #
###############################################################################
pgrm="TemplateBuilder"
pver="5.2-15"

# Version history ============================================================

versionHISTORY="TemplateBuilder.sh is part of the My HomeLab Journey Project
- https://homelab.casaursus.net
- https://homelab.casaursus.net/proxmox-automation
- https://homelab.casaursus.net/setting-up-kubernetes-k8s

Version History:
- v1.0 29.11.2022  v1.1 01.12.2022
- v2.0 04.01.2023  v2.1 09.01.2023  v2.2 29.01.2023
- v3.0 30.05.2023  v3.1 31.05.2023  v3.2 01.06.2023  v3.3 12.10.2023
- v4.0 12.10.2023  v4.1 31.10.2023
- v5.0 25.11.2023  v5.1 18.12.2023  v5.2 31.12.2023"

newTEXT="
TemplateBuilder is Free and Open Sourse Software.
  - There is NO WARRANTY, to the extent permitted by law.
  - Part of the My Journey Project @ homelab.casaursus.net
"

cSTRING="TemplateBuilder is Free and Open Sourse Software.\n\n\
Copyright (c) 2021-$(date +%Y) CasaUrsus\n\
- Author: nallej (CasaUrsus)\n\
- License: MIT  https://github.com/nallej/MyJourney/raw/main/LICENSE\n\
This is Free and Open Sourse Software; you are free to change and redistribute it.\n\
\nSee the LICENSE file or the link for details.\n \
 - There is NO WARRANTY, read the code befor using it.\n \
 - Part of the My Journey Project @ homelab.casaursus.net\n"

# Functions section ===========================================================

function cINFO() { # print a Copyright statement
  clear
  cat <<"EOF"

  Copyright (c) 2021-$(date +%Y) CasaUrsus
  Author: nallej (CasaUrsus)
  License: MIT
  https://github.com/nallej/MyJourney/raw/main/LICENSE

EOF
}

function showRecommended() { # Basic recommendations for the user
whiptail --backtitle "$backTEXT" --title "Recommended Settings" --msgbox \
"Remember to edit the script before executing:
  - basic settings are 1 core/socket and 1 GiB RAM, Shell: xterm.js

  - normal disk size for a VM is 8 - 16 G, but sometimes 4 or even 32 G
    - K8s workers nodes : small 1-2 core and 1-2 GiB RAM, disk 8 - 16 G
    - K8s managers      : 2-4 core and 2 - 4 GiB RAM disk 16 - 32G.
    - K0s and K3s nodes : min. 1 core and 512M RAM

  - OS type set to      = L26   Linux 2.6 - 6.X Kernel
  - IP address set to   = DHCP  Remember to set DHCP Reservations
  - Qemu-Guest-Agent    = on
  - Autostart set to    = on
  - Use a Public KEY" 18 78
}

function showGuide() {
whiptail --backtitle "$backTEXT" --title "Notice" --msgbox \
"This script generates a single VM or a Template and VMs.
  - functionallity is detemend by your choices and answers
This script will run as root or sudo.
  - to make it executable: chmod +x TemplateBuilder.sh

 To edit the script is very important:
  - location and name of public key to be useed in auto creation
    - your public key for this server/cluster
    - copy one into: ~/.ssh/my_key.pub or use existing one
  - what Cloud Images to use and wher are they on the web
  - where are Cloud Images and VM disks to be stored
  - default user related things, name, password and key ...

  See the EDIT Section of the script" 20 78
}

function header2() { # print name of script. figlet -f standard TemplateBuilder
  cat <<"EOF"
 _____                    _       _       ____        _ _     _
|_   _|__ _ __ ___  _ __ | | __ _| |_ ___| __ ) _   _(_) | __| | ___ _ __
  | |/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \  _ \| | | | | |/ _` |/ _ \ '__|
  | |  __/ | | | | | |_) | | (_| | ||  __/ |_) | |_| | | | (_| |  __/ |
  |_|\___|_| |_| |_| .__/|_|\__,_|\__\___|____/ \__,_|_|_|\__,_|\___|_|
                   |_|                    https://homelab.casaursus.net
EOF
}

###############################################################################
 #                                                                           #
  #   🦺 🧰 🦺    G L O B A L  Variables and Functions   🤓   🚫   🤓      #
 #                                                                           #
###############################################################################

function stopNotRoot(){ # Function Check for root privilidges and exit if not
if [[ "$EUID" != 0 ]]; then
    echo -e "\e[0;31mYou need to be root! Pleas run as sudo.\033[0m" # Message in read
    exit
fi
}

function setRoot() { # Function I am root
if [[ "$EUID" = 0 ]]; then
    echo -e "\n${okcm} Initialaizing: $pgrm version $pver"          # I am root
else
    sudo -k                             # ask for sudo password
    if sudo true; then                  # Correct password
        clear
        echo -e "\n${yelb}Start $pgrm version $pver${end}"
        echo -e "\n${okcm}Initialaizing...${end}"
    else
        echo "${redb}wrong password!${end}"
        exit                            #exit if 3 times wrong
    fi
fi
}

function header() { # print CasaUrsus. figlet -f standard CasaUrsus
  clear
  cat <<"EOF"

              ____                _   _
             / ___|__ _ ___  __ _| | | |_ __ ___ _   _ ___
            | |   / _` / __|/ _` | | | | '__/ __| | | / __|
            | |__| (_| \__ \ (_| | |_| | |  \__ \ |_| \__ \
             \____\__,_|___/\__,_|\___/|_|  |___/\__,_|___/
EOF
}

function useColors() { # define colors to be used
    # color code   color as bold
    red=$'\e[31m'; redb=$'\e[1;31m'     # call red with $red and bold as $redb
    grn=$'\e[32m'; grnb=$'\e[1;32m'     # call as green $grn as bold green $grnb
    yel=$'\e[33m'; yelb=$'\e[1;33m'     # call as yellow $yel as bold yellow $yelb
    blu=$'\e[34m'; blub=$'\e[1;34m'     # call as blue $blu as bold blue $blub
    mag=$'\e[35m'; magb=$'\e[1;35m'     # call as magenta $mag as bold magenta $magb
    cyn=$'\e[36m'; cynb=$'\e[1;36m'     # call as cyan $cyn as cyan bold $cynb
    end=$'\e[0m'                        # End that color
    okcm="${grnb}✔ ${end}"              # Green OK
    nocm="${redb}✘ ${end}"              # Red NO
    dlcm="${grnb}➟ ${end}"              # Indikate DownLoad
    stcm="${cynb}➲ ${end}"              # Start of somthing
    ccl="\\r\\033[K"                    # Clear Current Line (carriage return + clear from cursor to EOL)
    time=${cynb}$(date +"%T")${end}     # Show time of somthing
    #Use them to print with colours: printf "%s\n" "Text in white ${blu}blue${end}, white and ${mag}magenta${end}.
}

function spinner() { # display a animated spinner
    # The different Spinner Arrays to choose from
    local array1=("◐" "◓" "◑" "◒")
    local array2=("░" "▒" "▓" "█")
    local array3=("╔" "╗" "╝" "╚")
    local array4=("┌" "┐" "┘" "└")
    local array5=("▄" "█" "▀" "█")
    local array6=('-' '\' '|' '/') # L to R
    local array7=('-' '/' '|' '\') # R to L
    local array9=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local array10=("▏" "▎" "▍" "▌" "▋" "▊" "▉" "█")
    local array11=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

    local delays=0.1 # Delay between each characte

    tput civis # Hide cursor and spinn
    #echo -e "${yelb} "
    while :; do
        for character in "${array9[@]}"; do # Use this Array
            printf "%s" "$character"
            sleep "$delays"
            printf "\b"  # Move cursor back
        done
    done
}

function runSpinner() {
    local ONOFF=$1
    if [ $ONOFF == 'run' ]; then
        # Run the spinner in the background and Save the PID
        spinner &
        spinner_pid=$!
    else
       # Terminate the Spinner
       kill "$spinner_pid"; wait "$spinner_pid" 2>/dev/null
       tput cnorm # Show the Cursor Again
       echo -e "${end} "
    fi
}

function askLicens() {
  if (whiptail --backtitle "$backTEXT" --title "Copyrigt © and License" --defaultno --yesno \
  "$cSTRING\n⚠️ Do You Accept the LICENSE agreement?" 20 78 \
    --no-button "No" --yes-button "Accept"); then
    echo "${grn}User Accepted the License. Yes, exit status was $?.${end}" >> $logFILE
    FILE=LICENSE
    if [ -f "$FILE" ]; then
        echo "${blu}LICENSE file exist in this directory.${end}" >> $logFILE
    else
        wget https://github.com/nallej/MyJourney/raw/main/LICENSE &> /dev/null
        install -D $HOME/LICENSE /usr/share/doc/templatebuilder/copyright
        echo "${blu}LICENSE file now in this directory.${end}" >> $logFILE

        if [ -e "$motd_file" ]; then                # Check if the motd file exists
            if [ ! -e "$backup_file" ]; then        # Check if the backup file doesn't exist
                cp "$motd_file" "$backup_file"      # Create a backup of the original motd file
                echo "$newTEXT" >> "$motd_file"    # Append your new text to the motd file
            fi
        fi

        #echo -e "${/etc/otd}\nTemplateBuilder is Free and Open Sourse Software.\n  - There is NO WARRANTY, to the extent permitted by law.\n  - Part of the My Journey Project @ homelab.casaursus.net" >> /etc/motd
    fi
  else
    echo "${red}⚠ User selected to Decline, exit status was $?. ⚠${end}" >> $logFILE
    exit
  fi
  timeSTART=
  whiptail --backtitle "$backTEXT" --title "Version History" --msgbox "$versionHISTORY" 18 78
}

function setLOG(){
    if [ -f "$logFILE" ]; then
       if (whiptail --backtitle "$backTEXT"  --title "Log File Dialog" --defaultno --yesno \
            "\n⚠️   You have a log file: $logFILE \
            \n- Do you like to proceed by Overwright it or Append to it" \
            8 78 --no-button "Append" --yes-button "Overwright"); then
            echo "${blub}>>>> Started the Install  $(date +"%F %T") ${end}" > $logFILE
        else
            echo "${blub}>>>> Started the Install  $(date +"%F %T") ${end}" >> $logFILE
        fi
    else
        echo "${blub}>>>> Started the Install  $(date +"%F %T") ${end}" > $logFILE
    fi
}


###############################################################################
 #                                                                           #
  #   🦺  🧰  🦺    L O C A L  Variables and Functions   🤓   🚫   🤓      #
 #                                                                           #
###############################################################################

function guestfs() {
    # Install the needed libguestfs-tools if it'smissing -------------------------#
    if dpkg -s libguestfs-tools &>/dev/null; then
        echo -e "${okcm}${magb} The libguestfs-tools was found"  >> $logFILE
      else
        echo -e "\b  ${nocm} Missing libguestfs-tools"
        echo -e "\b  ${dlcm}${cyn} downloading and installing libguestfs-tools ...${end}"
        apt-get update && apt-get install -y libguestfs-tools  &> /dev/null
        echo -e "\b  ${okcm} Installed the libguestfs-tools"
        echo "${okcm}${cyn} libguestfs-tools installed  $(date +"%T") ${end}" >> $logFILE
    fi
}

#-----------------------------------------------------------------------------#
#    B A S I C   S E T T I N G S   F O R   V M's   A N D   T E M P L A T E    #
#-----------------------------------------------------------------------------#

# Function call my $1=minimal/server CHANGE server to STANDARD
function dlFile() { # Download the Cloud Image
    echo "${okcm}${cyn} selected OS: $1 in $storageISO ${end}" >> $logFILE
    local TYPE=$1
    local FILE    # URL
    local NAME    # Short name O
    fileISO=$1
    case $TYPE in
        $osFILE1) familyISO=$osFAMILY1 ; locationOS=$osLOCATION1 ;;
        $osFILE2) familyISO=$osFAMILY2 ; locationOS=$osLOCATION2 ;;
        $osFILE3) familyISO=$osFAMILY3 ; locationOS=$osLOCATION3 ;;
        $osFILE4) familyISO=$osFAMILY4 ; locationOS=$osLOCATION4 ;;
        $osFILE5) familyISO=$osFAMILY5 ; locationOS=$osLOCATION5 ;;
        $osFILE6) familyISO=$osFAMILY6 ; locationOS=$osLOCATION6 ;;
        $osFILE7) familyISO=$osFAMILY7 ; locationOS=$osLOCATION7 ;;
        $osFILE8) familyISO=$osFAMILY8 ; locationOS=$osLOCATION8 ;;
        $osFILE9) familyISO=$osFAMILY9 ; locationOS=$osLOCATION9 ;;
    esac

    case $storageISO in
        $nameISO1) pathISO=$pathISO1 ;; #"/var/lib/vz/template/iso/"
        $nameISO2) pathISO=$pathISO2 ;;
        $nameISO3) pathISO=$pathISO3 ;;
        $nameISO4) pathISO=$pathISO4 ;;
        $nameISO5) pathISO=$pathISO5 ;;
    esac
    if [[ "$newBASE" == true || ! -f base.qcow2 ]]; then
        if  [ -f $pathISO$fileISO ]; then #elif
            echo  "${okcm}${magb} $fileISO ${end}${cyn}exist in $storageISO" >> $logFILE
          else
            wget -P $pathISO  $locationOS$fileISO 2>&1 | \
            stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
            whiptail --title "Download" --gauge "Downloading $TYPE as:\n$fileISO" 8 78 0
            echo "${dlcm}${magb} $locationOS$fileISO ${end}${cyn} downloaded to $storageISO path: $pathISO  $(date +"%T") ${end}" >> $logFILE
        fi
    fi
}

function getPool() { # Show basic pool info and Select a Pool
    local ST=$1
    local LABEL
    local TYPE
    case $ST in
        VM) LABEL='VM/CT storage' ; TYPE=$zfs_st ;;
        ISO) LABEL='IMG/ISO storage' ; TYPE=$img_st ;;
        *) exit ;;
    esac
    local -a LIST
    while read -r line; do
      local TAG=$(echo $line | awk '{print $1}')
      local TYPE=$(echo $line | awk '{printf "%-10s", $2}')
      local FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
      local ITEM="  Type: $TYPE Free: $FREE "
      local OFFSET=2
      if [[ $((${#ITEM} + $OFFSET)) -gt ${LONGA:-} ]]; then
        local LONGA=$((${#ITEM} + $OFFSET))
      fi
      LIST+=("$TAG" "$ITEM" "OFF")
    done < <(echo "$TYPE" | awk 'NR>1')
    # Select storage location
    if [ $((${#LIST[@]} / 3)) -eq 0 ]; then
        echo "${nocm}${red}Unable to detect valid storage location for ISO storage.${end}" >> $logFILE
      elif [ $((${#LIST[@]} / 3)) -eq 1 ]; then
        printf ${LIST[0]}
      else
        local POOL
        while [ -z "${POOL:+x}" ]; do
        POOL=$(whiptail --backtitle "$backTEXT" --title "Select Storage Pool" --radiolist \
          "\nStorage pool to use for the ${LABEL,,}\nSelect with [Space] and Accept with [Enter]\n" \
          18 $(($LONGA + 23)) 6 \
          "${LIST[@]}" 3>&1 1>&2 2>&3) || echo "getPool RadioList aborted."  >> $logFILE
      done
      printf $POOL
    fi
}

function setLAN(){
    # Set the Virtual Bridge
    vmbr=$(whiptail --backtitle "$backTEXT" --title "VLAN Dialog" --inputbox \
    "\nVirtual Bridge to be useed" \
    10 48 $initVMBR 3>&1 1>&2 2>&3)
    echo "${cyn}     -  Bridge: $vmbr" >> $logFILE
    # Use a Virtual LAN
    if whiptail --backtitle "$backTEXT"  --title "VLAN Dialog" --yesno \
       "\nDo you need to use a VLAN?" 10 48; then
       vlan=$(whiptail --backtitle "$backTEXT" --title "VLAN Dialog" --inputbox\
       "\nVLAN to use for the VM/Template" 10 48 $initVLAN  3>&1 1>&2 2>&3)
       echo "${cyn}     -  VLAN: $vlan" >> $logFILE
      else
        vlan=0
        echo "${cyn}     -  User selected NOT to use a VLAN" >> $logFILE
    fi
}

function setUSER() {
    # Set Cloid-init user
    ciu=$(whiptail --backtitle "$backTEXT" --title "Create CI User" --inputbox \
      "\nCreate with CI user" \
      10 48 $initUSER 3>&1 1>&2 2>&3)
      echo "${cyn}     -  Cloud-init user: $ciu" >> $logFILE

    # Create a long and complicated password 6 is a joke 8 is something 12 is semi ok 16 is ok 20 is good
    while [[ "$cip" != "$cip_repeat" || ${#cip} -lt $passLENGHT ]]; do
      cip=$(whiptail --backtitle "$backTEXT" --title "Create CI User" --passwordbox \
        "\n${cip_invalid}Please enter a password ($passLENGHT chars min.): " 10 48 $initPASSWD 3>&1 1>&2 2>&3)
      cip_repeat=$(whiptail  --backtitle "$backTEXT" --title "Create CI User" --passwordbox \
        "\nPlease repeat the password: " 10 48 $initPASSWD 3>&1 1>&2 2>&3)
      cip_invalid="WARNING Password too short, or not matching! "
    done
    # Shoud NOT be used for production
        if [[ "$showPASSWD"=true ]]; then
            echo "${cyn}     -  Cloud-init password: $cip" >> $logFILE
        else
            echo "${cyn}     -  Cloud-init password: /<hidden/>" >> $logFILE
        fi
      #PASSWORD="$(openssl rand -base64 16)"

    # Set Key name and address
    myKEY=$(whiptail --backtitle "$backTEXT" --title "Create CI User" --inputbox \
      "\nSet users SSH Public Key:" \
      10 48 $initKEY 3>&1 1>&2 2>&3)
      echo "${cyn}     -  My key: $myKEY" >> $logFILE

}

function setBASE() {
    # Disk size selector
    sizeD=$(whiptail --backtitle "$backTEXT" --title "Base Settings" --radiolist \
    "\n Expand the Disk Size to" 14 48 5 \
    "4G" " 4 GiB" OFF \
    "8G" " 8 GiB for basic VMs" ON \
    "16G" "16 GiB for basic VMs" OFF \
    "32G" "32 GiB for large VMs" OFF \
    "64G" "32 GiB for extra large VMs" OFF \
    3>&1 1>&2 2>&3)
    echo "${cyn}     -  Disk size: $sizeD${end}" >> $logFILE

    # RAM size selector
    sizeM=$(whiptail  --backtitle "$backTEXT" --title "Base Settings" --radiolist \
    "\nChoose the Size of RAM" 14 48 5 \
    "512" ".5 GiB for small nodes" OFF \
    "1024" "1  GiB for basic VMs" ON \
    "2048" "2  GiB for basic VMs" OFF \
    "4096" "4  GiB for hevy load VMs" OFF \
    "8192" "8  GiB for extra heavy load VMs" OFF \
    3>&1 1>&2 2>&3)
    echo "${cyn}     -  RAM size: $sizeM${end}" >> $logFILE

    # Core count selector
    sizeC=$(whiptail  --backtitle "$backTEXT" --title "Base Settings" --radiolist \
    "\nChoose the number of Cores/Socket" 14 48 6 \
    "1" "for normal VMs and Workers " ON \
    "2" "for basic VMs and Managers " OFF \
    "3" "large VMs" OFF \
    "4" "large VMs" OFF \
    "6" "extra large VMs" OFF \
    "8" "XXL VMs" OFF \
    3>&1 1>&2 2>&3)
    echo "${cyn}     -  Cores: $sizeC" >> $logFILE
}

function setOPTIONS() {
    #add init vc and firstboot.sh

OPTION_MENU=()
LONGA=0

echo "# Firstboot commands created from TemplateBuilder" > firstboot.sh
vcapt="apt-get install -y "
vc=" --install "

while read -r ONOFF TAG ITEM; do
  OFFSET=2
  ((${#ITEM} + OFFSET > LONGA)) && LONGA=${#ITEM}+OFFSET
  OPTION_MENU+=("$TAG" "$ITEM " "$ONOFF")
done < <(
  cat <<EOF
ON Qemu-Guest-Agent Qemu-Guest-Agent
ON spice-vdagent clipboard for xterm
ON nano editor and ncurses-term
ON git Git Hub/Lab use
on nala APT frontend
ON unattended-upgrades set to On
ON Fail2Ban Security
ON clamav antivirus and daemon
OFF 2FA OATHtool, Google Authenticator
OFF mailutils needs FQDN
OFF bat better cat
OFF exa better ls
OFF fzf fuzzy find
OFF myBash add personal settings
OFF Docker-CE Alpine
OFF Dockge Docker Management
OFF Portainer-CE Alpine
OFF Agent Portainer Agent
OFF Docker \$\$\$ license
OFF Portainer-BE \$\$\$ license
OFF K0s a K0s Cluster
OFF K3s a K3s ClusterTBA
OFF K3s-HAa TBA K3s HA-Cluster TBA
OFF K8s make a K8s Cluster
OFF AlpineDocker Docker on Apline
EOF
)
OPTIONS=$(whiptail --backtitle "$backTEXT" --title "Options List" --checklist --separate-output \
"\nSelect Options for the VM:\n" 20 $((LONGA + 33)) 12 "${OPTION_MENU[@]}" 3>&1 1>&2 2>&3 | tr -d '"') || exit
[ -z "$OPTIONS" ] && {
  whiptail --backtitle "$backTEXT" --title "No Options Selected" --msgbox "It appears that no Options was selected" 10 68
}

if [ -z "$OPTIONS" ]; then
  echo "${red}⚠ No option was selected (user hit Cancel or unselected all options)${end}" >> $logFILE
else
  echo "${cynb}   - User selected options:${end}" >> $logFILE
  for CHOICE in $OPTIONS; do
    case "$CHOICE" in
    "Qemu-Guest-Agent") vc="$vc,qemu-guest-agent" ;        echo "${cyn}     -  qemu-guest-agent${end}" >> $logFILE ;;
    "spice-vdagent") vc="$vc,spice-vdagent" ;              echo "${cyn}     -  spice-vdagent${end}" >> $logFILE ;;
    "nano") vc="$vc,nano,ncurses-term" ;                   echo "${cyn}     -  nano editor, ncurses-term${end}" >> $logFILE ;;
    "git") vc="$vc,git" ;                                  echo "${cyn}     -  git${end}" >> $logFILE ;;
    "nala") vc="$vc,nala" ;                                echo "${cyn}     -  nala${end}" >> $logFILE ;;
    "unattended-upgrades") vc="$vc,unattended-upgrades" ;  echo "${cyn}     -  unattended-upgrades${end}" >> $logFILE ;;
    "Fail2Ban") vc="$vc,fail2ban" ;                        echo "${cyn}     -  fail2ban${end}" >> $logFILE ;;
    "clamav") vc="$vc,clamav,clamav-daemon" ;              echo "${cyn}     -  clamav-daemon${end}" >> $logFILE ;;
    "2FA") vc="$vc,oathtool,libpam-google-authenticator" ; echo "${cyn}     -  OATH Toolkit, Google Authenticator${end}" >> $logFILE ;;
    "mailutils")  vc="$vc,mailutils" ;                     echo "${cyn}     -  mailutils${end}" >> $logFILE ;;
    "bat") vc="$vc,bat" ;                                  echo "${cyn}     -  bat${end}" >> $logFILE ;;
    "exa") vc="$vc,exa" ;                                  echo "${cyn}     -  exa${end}" >> $logFILE ;;
    "fzf") vc="$vc,fzf" ;                                  echo "${cyn}     -  fzf${end}" >> $logFILE  ;;
    "Docker-CE")
      echo "apt-get update && apt-get install -y containerd software-properties-common apt-transport-https ca-certificates apt-utils gnupg curl" >> firstboot.sh
      echo "mkdir -p /etc/apt/keyrings" >> firstboot.sh
      echo "mkdir -p /home/$ciu/docker/" >> firstboot.sh
      if [[ "$familyISO" == 'ubuntu' ]]; then
            echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" >> firstboot.sh
            echo "chmod a+r /etc/apt/keyrings/docker.gpg" >> firstboot.sh
            echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null" >> firstboot.sh
        elif [[ "$familyISO" == 'debian' ]]; then
            echo "curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" >> firstboot.sh
            echo "chmod a+r /etc/apt/keyrings/docker.gpg" >> firstboot.sh
            echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null" >> firstboot.sh
        else
            echo " EXIT Wrong OS Family!" >> $logFILE
            exit
      fi
      echo "apt-get update && apt-get install -y docker-ce containerd.io docker-ce-cli docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin" >> firstboot.sh
      if [ "$testMODE" = true ]; then echo "usermod -aG docker $ciu" >> firstboot.sh; fi
      echo "${cyn}     -  Docker-CE${end}" >> $logFILE
      ;;
    "Dockge")
      echo "/home/$ciu/docker/dockge/" >> firstboot.sh
      # Dockge management app is a great tool and replaces Portainer-CE in my lab. Storage strategy /home/<user>/docker/ dockge (for its data) and stacks (for the <app>/compose.yaml)
      echo "docker run -d -p 5001:5001 --name Dockge --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v /home/$ciu/docker/dockge/data:/app/data -v /home/$ciu/docker/stacks:/home/$ciUSER/docker/stacks -e DOCKGE_STACKS_DIR=/home/$ciUSER/docker/stacks louislam/dockge:latest" >> firstboot.sh
      echo "${cyn}     -  Dockge${end}" >> $logFILE
      ;;
    "Portainer-CE")
      echo "mkdir -p /home/$ciu/docker/portainer/portainer-data" >> firstboot.sh
      echo "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:alpine" >> firstboot.sh
      echo "${cyn}     -  Portainer-CE${end}" >> $logFILE
      ;;
    "Agent")
      echo "docker run -d -p 9001:9001 --name portainer-agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:alpine" >> firstboot.sh
      echo "${cyn}     -  Portainer Agent${end}" >> $logFILE
      ;;
    "Docker")
      echo "apt-get update && apt-get install -y containerd software-properties-common apt-transport-https ca-certificates apt-utils gnupg curl" >> firstboot.sh
      #vc="$vc,apt-utils"
      #vc="$vc,curl"
      #vc="$vc,software-properties-common"
      #vc="$vc,apt-transport-https"
      #vc="$vc,ca-certificates"
      #vc="$vc,gnupg"
      echo "mkdir -p /etc/apt/keyrings" >> firstboot.sh
      echo "mkdir -p /home/$ciu/docker/" >> firstboot.sh
      echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" >> firstboot.sh
      echo "chmod a+r /etc/apt/keyrings/docker.gpg" >> firstboot.sh
      echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null" >> firstboot.sh
      echo "apt-get update" >> firstboot.sh
      echo "apt-get install -y docker containerd.io docker-cli docker-compose-plugin docker-rootless-extras docker-buildx-plugin" >> firstboot.sh
      echo "${cyn}     -  Docker-EE \$\$\$${end}" >> $logFILE
      ;;
    "Portainer-BE")
      echo -e "mkdir -p /home/$ciu/docker/portainer/portainer-data" >> firstboot.sh
      echo -e "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:alpine" >> firstboot.sh
      echo "${cyn}     -  Portainer \$\$\$${end}" >> $logFILE
      ;;
    "K0s")
      echo "apt-get update && apt-get install -y containerd curl" >> firstboot.sh
      echo "su - $ciu"  >> firstboot.sh
      echo "curl -sSLf https://get.k0s.sh | sh" >> firstboot.sh
      echo "wget https://github.com/nallej/MyJourney/raw/main/scripts/K0s-starter.sh -O /home/$ciu/K0s-starter.sh" >> firstboot.sh
      echo "chmod a+x /home/$ciu/K0s-starter.sh" >> firstboot.sh
      echo "${cyn}     -  make a K0s cluster${end}" >> $logFILE
      ;;
    "K3s")
      # Create 1 server (VM) and 2 agents (clones)
      echo "apt-get update && apt-get install -y containerd curl" >> firstboot.sh
      echo "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.27.8+k3s2 sh -" >> firstboot.sh
      echo "wget https://github.com/nallej/MyJourney/raw/main/scripts/K0s-starter.sh -O /home/$ciu/K3s-starter.sh" >> firstboot.sh
      echo "chmod a+x /home/$ciu/K3s-starter.sh" >> firstboot.sh
      echo "${cyn}     -  make a K3s cluster${end}" >> $logFILE
      ;;
    "K3s-HA")
      echo "${cyn}     -  make a K3s HA-cluster${end}" >> $logFILE
      ;;
    "K8s")
      echo "${cyn}     -  make K8s HA-settings${end}" >> $logFILE
      echo "apt-get update && apt-get install -y containerd software-properties-common apt-transport-https ca-certificates apt-utils gnupg curl" >> firstboot.sh
      echo "apt-get update" >> firstboot.sh
      echo "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | dd status=none of=/usr/share/keyrings/kubernetes-archive-keyring.gpg" >> firstboot.sh
      echo "echo \"deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main\" | tee /etc/apt/sources.list.d/kubernetes.list" >> firstboot.sh
      echo "swapoff -a" >> firstboot.sh
      echo "mkdir /etc/containerd" >> firstboot.sh
      echo "containerd config default | tee /etc/containerd/config.toml" >> firstboot.sh
      echo "echo \"br_netfilter\" > /etc/modules-load.d/k8s.conf" >> firstboot.sh
      echo "sed -i \"s/^\( *SystemdCgroup = \\)false/\\1true/\" /etc/containerd/config.toml" >> firstboot.sh
      echo "sed -i -e \"/#net.ipv4.ip_forward=1/c\\net.ipv4.ip_forward=1\" etc/sysctl.conf" >> firstboot.sh
      echo "apt-get update && sudo apt-get install -y kubeadm kubectl kubelet" >> firstboot.sh
      # echo "truncate -s 0 /etc/machine-id" >> firstboot.sh
      # echo "rm /var/lib/dbus/machine-id" >> firstboot.sh
      # echo "ln -s /etc/machine-id /var/lib" >> firstboot.sh
      # echo "systemd-machine-id-setup" >> firstboot.sh
      echo "${cyn}     -  make a K8s cluster${end}" >> $logFILE
      ;;
    "myBash")
      echo "lsb_release" >> firstboot.sh
      echo "chmod a+x /home/$ciu/initVM.sh" >> firstboot.sh
      echo "${cyn}     -  myBashAddOns${end}" >> $logFILE
      ;;
    "AlpineDocker")
      echo "# Firstboot commands created from TemplateBuilder" > firstboot.sh
      echo "apk update" >> firstboot.sh
      echo "apk add docker docker-compose" >> firstboot.sh
      echo "rc-update add docker" >> firstboot.sh
      echo "service docker start" >> firstboot.sh
      echo "addgroup $ciu docker" >> firstboot.sh
      echo "${cyn}     -  Docker in Alpine Linux${end}" >> $logFILE
      ;;
    *)
      echo "${red}⚠ Unsupported item $CHOICE! ${end}" >> $logFILE
      exit 1
      ;;
    esac
  done
fi
}

function toCREATE() {
# What are we to create only a VM, only a Template or both
if (whiptail --backtitle "$backTEXT" --title "What to Create" --yesno \
  "\n Create a VM or a Template Stack?" \
  10 48 --no-button "One VM" --yes-button "Stack"); then
  tok=true # do the yes, a Template
  templateNO=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nTemplate ID" 10 48 $initTEMPLATENO 3>&1 1>&2 2>&3)
  templateNAME=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nTemplate Name" 10 48 $initTEMPLATENAME 3>&1 1>&2 2>&3)
  echo "${cyn}     -  Template $templateNO $templateNAME" >> $logFILE
  #Create also some Clones of the Template
  if (whiptail --backtitle "$backTEXT" --title "What to Create" --yesno \
       "\n  Create Clones of the Template?" 10 48 ); then
        # do the yes, a Template
        firstCLONE=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nID of first clone" 10 48 $initNO1STCLONE 3>&1 1>&2 2>&3)
        numberCLONES=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nNumber of clones" 10 48 $initNOCLONES 3>&1 1>&2 2>&3)
        cname=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nName of clones ${initCLONENAME}1 to $initCLONENAME$numberCLONES" 10 48 node- 3>&1 1>&2 2>&3)
        first="${cname}1"
        if [ $numberCLONES = 1 ]; then
            createMSG="     - $numberCLONES Clone: $firstCLONE $first $numberCLONES "
        else
            last=$(($firstCLONE + $numberCLONES))
            createMSG="     -  $numberCLONES Clones: $firstCLONE $first - $last $cname$numberCLONES"
        fi
        echo "$createMSG" >> $logFILE
  fi
else
    tok=false # No, a Single VM
fi
    vmNO=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nVM ID" 10 48 $initVMNO 3>&1 1>&2 2>&3)
    vmNAME=$(whiptail --backtitle "$backTEXT" --title "What to Create" --inputbox \
        "\nName of the VM" 10 48 $initVMNAME 3>&1 1>&2 2>&3)
    echo "${cyn}     -  VM $vmNO $vmNAME" >> $logFILE
}



###############################################################################
 #                                                                           #
  #    🧱🧱🧱🧱🧱🧱   C R E A T E  t h e  N O D E S   🧱🧱🧱🧱🧱🧱        #
 #                                                                           #
###############################################################################

# Funtions Creating VM/Temlate [Clones] ======================================#
# Create a fully loaded base ISO
#   - set the Expand to disk size
#   - add all needed the apps
#   - add Qemu-Guest-Agent
#   - add and any other packages you’d chosen into your Base Image
#   - libguestfs-tools has to be installed on the node
#     - will be installed if missing
#   - add parts to install at First Boot
# Add or delete functionallity according to your needs
# virt-customize -a /path/to/your/vm-image.qcow2 --firstboot /path/to/your/firstboot-script.sh
# virt-customize -a base.qcow2 --firstboot.sh

function copyBASE(){
# Create base.qcow2 as a base for a VM using a CI
    echo "${stcm}${cyn} $(date +"%T")  Copy $pathISO$fileISO -> base.qcow2" >> $logFILE
    if [ -f base.qcow2 ]; then
        cp --remove-destination $pathISO$fileISO base.qcow2  &> /dev/null
      else
        cp $pathISO$fileISO base.qcow2  &> /dev/null
    fi
    echo "${stcm}${cyn} $(date +"%T")  Created raw image base.qcow2" >> $logFILE

    qemu-img resize base.qcow2 $sizeD
    # NOTE The bigger a disk should be, the longer it takes to resize and copy it!
    # 16G is typical - Resize the disk to your needs, 8 - 32 GiB is normal
    echo "${stcm}${cyn} $(date +"%T")  Resized the base.qcow2 to $sizeD" >> $logFILE
}

function createBase() {
# Initialize base.qcow2 as a base for a VM using a CI
    # Add Qemu-Guest-Agent and any other packages you’d like in your base image.
    # libguestfs-tools has to be installed on the node.
    # Add or delete add-ons according to your needs
    echo "${stcm}${cyn} $(date +"%T")  Initialized base image" >> $logFILE
# ======================== Delete ->
    echo "# Firstboot commands created from TemplateBuilder" > firstboot.sh
    vcapt="apt-get install -y "
    vc=" --install "
    #echo "reboot" >> firstboot.sh
# =================== Delete -|
    echo "truncate -s 0 /etc/machine-id" >> firstboot.sh
    echo "systemd-machine-id-setup" >> firstboot.sh
    echo "cp /root/virt-sysprep-firstboot.log /home/$ciu/firstboot.log" >> firstboot.sh
    echo "systemctl reboot --no-wall" >> firstboot.sh
    vc="$vc --firstboot firstboot.sh --add base.qcow2"
    virt-customize $vc
    echo -e "\n>>>> virt-customize --------------------------------------------------------" >> $logFILE
    echo "$vc" >> $logFILE
    echo -e "<<<< virt-customize ---------------------------------------------------------\n" >> $logFILE
    echo -e ">>>> firstboot --------------------------------------------------------------" >> $logFILE
    cat firstboot.sh >> $logFILE
    echo -e "<<< firstboot --------------------------------------------------------------\n" >> $logFILE
    echo "${okcm} ${time}  base.qcow2 $sizeD created" >> $logFILE
}

#------------------------------------------------------------------------------
#  C R E A T E   t h e   V M / T e m p l a t e / C l o n e s   S e c t i o n  #
#------------------------------------------------------------------------------

# --scsihw virtio-scsi-pci --scsi0 ...  # Attache the disk to the base of the VM
# --ide2 $storageVM:cloudinit           # Attach the cloudinit file - you might need to EDIT it later !
# --boot c --bootdisk scsi0             # Make the cloud init drive bootable and only boot from this disk
# --serial0 socket --vga serial0        # Add serial console, to be able to see console output!
# --onboot 1                            # Autostart vm at boot - default is 0 - Ususlly most VM's are allway running
# --agent 1                             # Use Qemu Guest Agent - default is 0
# --ostype l26                          # Set OS type Linux 5.x kernel 2.6 - default is other
# --ipconfig0 ip="dhcp"                 # Set dhcp on
# --ciuser $ciu                         # "admin"        use your imagination
# --cipassword $cip                     # "Pa$$w0rd"     use a super complicated one
# --sshkey ~/.ssh/my_key.pub            # sets the users public key for the vm typically ~/.ssh/id_ed25519.pub

function createVM() {
    # Creat a VM or a Template based on the base.qcow2 file
    # Later versions will have different setting for Template+clones and the VM
    local note
    echo "${stcm}${cyn} $(date +"%T")  VM creation started" >> $logFILE
    # Creare the base image ----------------------------------------------#
    ibase="$vmNO --memory $sizeM --core $sizeC --name $vmNAME --net0 virtio,bridge=$vmbr"
    if [[ $vlan > 0 ]]; then ibase="${ibase},tag=$vlan"; fi
    qm create $ibase
    echo "${okcm}${cyn} $(date +"%T")    - $ibase $storageVM" >> $logFILE
    #cp base.qcow2 vm-base.qcow2
    # Set options --------------------------------------------------------#
    qm disk import $vmNO base.qcow2 $storageVM > /dev/null 2>&1                 # Import the disc to the base of the VM. Where to put the VM local-lvm

    if [[ ${#myKEY} > 0 ]]; then
        qm set $vmNO --scsihw virtio-scsi-pci --scsi0 $storageVM:vm-$vmNO-disk-0 --ide2 $storageVM:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga std --onboot 1 --agent 1 --ostype l26 --ipconfig0 ip="dhcp" --ciuser $ciu --cipassword $cip --sshkey $myKEY
    else
        qm set $vmNO --scsihw virtio-scsi-pci --scsi0 $storageVM:vm-$vmNO-disk-0 --ide2 $storageVM:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga std --onboot 1 --agent 1 --ostype l26 --ipconfig0 ip="dhcp" --ciuser $ciu --cipassword $cip
    fi

    #if [ ${#myKEY} > 0 ]; then qm set $vmNO --sshkey $myKEY; fi     # sets the users key to the vm
    #qm disk resize $vmNO scsi0 $sizeD

    # Create the Notes window
    echo "# # VM $vmNO $vmNAME" >> /etc/pve/qemu-server/$vmNO.conf
    echo "# Created $(date +"%F %T")" >> /etc/pve/qemu-server/$vmNO.conf
    #echo "#- RAM    : $sizeM" >> /etc/pve/qemu-server/$vmNO.conf
    #echo "#- Core   : $sizeC" >> /etc/pve/qemu-server/$vmNO.conf
    if [ "$showPASSWD" = true ]; then
         echo "#- User   : $ciu, $cip" >> /etc/pve/qemu-server/$vmNO.conf
    else
         echo "#- User   : $ciu" >> /etc/pve/qemu-server/$vmNO.conf
    fi

    # Create the Notes window
    echo "#- Bridge : $vmbr" >>  /etc/pve/qemu-server/$vmNO.conf
    if [[ $vlan > 0 ]]; then echo "#  vLAN: $vlan" >> /etc/pve/qemu-server/$vmNO.conf; fi
    if [ ${#myKEY} > 0 ];  then echo "# - SSH Key: $myKEY" >> /etc/pve/qemu-server/$vmNO.conf; fi
    echo "#- Storage: $storageVM" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- Base   : $fileISO" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- from   : $pathISO" >> /etc/pve/qemu-server/$vmNO.conf

    #echo -e '#foo-bar\n' >> /etc/pve/lxc/VMID.conf
    echo "${okcm}${cyn} $(date +"%T")  VM $vmNO $vmNAME Created" >> $logFILE
}

function createTemplate() {
    # Create the template ex. 90000000
    local note
    echo "${stcm}${cyn} $(date +"%T")  Template creation started" >> $logFILE
    ibase="$templateNO --memory $sizeM --core $sizeC --name $templateNAME --net0 virtio,bridge=$vmbr"
    if [[ $vlan > 0 ]]; then ibase="${ibase},tag=$vlan"; fi
    qm create $ibase
    echo "${okcm}${cyn} $(date +"%T")    - $ibase"  >> $logFILE
    #cp base.qcow2 template-base.qcow2
    # Set options --------------------------------------------------------#
    qm disk import $templateNO base.qcow2 $storageVM > /dev/null 2>&1                       # Import the disc to the base of the template. Where to put the VM local-lvm
    if [[ ${#myKEY} > 0 ]]; then
        qm set $templateNO --scsihw virtio-scsi-pci --scsi0 $storageVM:vm-$templateNO-disk-0 --ide2 $storageVM:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga std --onboot 1 --agent 1 --ostype l26 --ipconfig0 ip="dhcp" --ciuser $ciu --cipassword $cip --sshkey $myKEY
    else
        qm set $templateNO --scsihw virtio-scsi-pci --scsi0 $storageVM:vm-$templateNO-disk-0 --ide2 $storageVM:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga std --onboot 1 --agent 1 --ostype l26 --ipconfig0 ip="dhcp" --ciuser $ciu --cipassword $cip
    fi
    #qm disk resize $templateNO scsi0 $sizeD

    # Create the Notes window
    echo "# # Template $templateNO $templateNAME" >> /etc/pve/qemu-server/$templateNO.conf
    echo "# Created $(date +"%F %T")" >> /etc/pve/qemu-server/$templateNO.conf
    #echo "#- RAM    : $sizeM" >> /etc/pve/qemu-server/$templateNO.conf
    #echo "#- Core   : $sizeC" >> /etc/pve/qemu-server/$templateNO.conf
    if [ "$showPASSWD" = true ]; then
        echo "#- User   : $ciu, $cip" >> /etc/pve/qemu-server/$templateNO.conf
    else
        echo "#- User   : $ciu" >> /etc/pve/qemu-server/$templateNO.conf
    fi
    echo "#- Bridge : $vmbr" >>  /etc/pve/qemu-server/$templateNO.conf
    if [[ $vlan > 0 ]]; then echo "#  vLAN: $vlan" >> /etc/pve/qemu-server/$templateNO.conf; fi
    if [[ ${#myKEY} > 0 ]]; then echo "# - SSH Key: $myKEY" >> /etc/pve/qemu-server/$templateNO.conf; fi
    echo "#- Storage: $storageVM" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- Base   : $fileISO" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- from   : $pathISO" >> /etc/pve/qemu-server/$templateNO.conf
    #echo -e '#foo-bar\n' >> /etc/pve/lxc/VMID.conf

    qm template $templateNO
    echo "${okcm}${cyn} $(date +"%F %T")  Template $templateNO $templateNAME created" >> $logFILE
}

function createClones() { # Cloning the template
    local note
    #echo "${stcm}${cyn} $(date +"%T")  Clone creation started" >> $logFILE
    #x=0
    #while [ $x -lt $numberCLONES ]
    #do
    #    xx=$(($firstCLONE + $x))
    #    x=$(( $x + 1 ))
        qm clone $templateNO $xx --name $cname$x --full
        echo "# # VM $xx $cname$x" >> /etc/pve/qemu-server/$xx.conf
        echo "# Created $(date +"%F %T")" >> /etc/pve/qemu-server/$xx.conf
        echo "${okcm}${cyn} $(date +"%T")  Cloned VM $xx $cname$x created" >> $logFILE
    #done
}
# Init Section ===============================================================#

function init() {
    clear; printf ${yelb}; header2; printf ${end} # Show name of script header
    # Start the Spinner
    runSpinner run
    # Read the storage pools -------------------------------------------------#
    zfs_st=$(pvesm status -content rootdir)
    img_st=$(pvesm status -content iso)
    #ctt_st=$(pvesm status -content vztmpl)
    motd_file="/etc/motd"
    backup_file="/etc/motd.old"
    runSpinner off
}

###############################################################################
 #                                                                           #
  #    🧱🧱🧱🧱🧱🧱   E X E C U T I O N A B L E   C O D E   🧱🧱🧱🧱🧱🧱    #
   #                                                                       #
  #    ✋  N O  n e e d  t o  E D I T  B e l o w  t h i s  P o i n t  🚫    #
 #                                                                           #
###############################################################################

# Code Section ===============================================================#
backTEXT="$pgrm $pver; part of the My HomeLab Journey Project"   #Background text
# Initialization menu --------------------------------------------------------#

useColors                   # Use color codes
init                        # Init function
setRoot                     # Check for root privilidges
stopNotRoot                 # Exit if not root
clear                       # Clear the screan
showGuide                   # Quick Guide
askLicens                   # Accept Licens
showRecommended             # Recommendations
setLOG                      # New or Append
guestfs                     # Install the needed libguestfs-tools if it's missing

storageISO=$(getPool ISO)   # Set ISO storage e.g. local /var/lib/vz/template/iso/
    echo -e "\n${okcm}${magb} User selected ISO's from $storageISO  $(date +"%F %T")${end}" >> $logFILE

# Use Server or Minimal Cloud Image
## Change to setup with Ubuntu or Debian versions
CI=$(whiptail  --backtitle "$backTEXT" --title "Choose the Image to use as Base Image" --radiolist \
 "\nChoose OS for VM's, Clones and Template" 14 68 5 \
  "$osFILE1" "$osFAMILY1 " OFF \
  "$osFILE2" "$osFAMILY2 " OFF \
  "$osFILE3" "$osFAMILY3 " OFF \
  "$osFILE4" "$osFAMILY4 " OFF \
  "$osFILE5" "$osFAMILY5 " OFF \
  "$osFILE6" "$osFAMILY6 " OFF \
  "$osFILE7" "$osFAMILY7 " OFF \
  "$osFILE8" "$osFAMILY8 " OFF \
  "$osFILE9" "$osFAMILY9 " OFF \
 3>&1 1>&2 2>&3)
    echo -e "\n${okcm}${magb} User selected OS-img $CI for base.qcow2  $(date +"%F %T")${end}" >> $logFILE

if (whiptail --backtitle "$backTEXT" --title \
  "Copy a new QCow2-file or us the current one" --yesno --defaultno \
  "\n    ⚠️ Do you like to use Current  -  or Copy a NEW one " \
  10 68 --no-button "Copy New" --yes-button "Current"); then
  echo -e "\n${okcm}${magb} User selected to use the current base.qcoq2  $(date +"%F %T")${end}" >> $logFILE
  newBASE=false
else
  echo -e "\n${okcm}${magb} User selected to use a new copy of base.qco2  $(date +"%F %T")${end}" >> $logFILE
  newBASE=true
  dlFile $CI
fi

#dlFile $CI                  # Download Cloud Image if missing from storageISO
echo "${cynb}   - User selected the ${magb}$CI${end}${cyn} image and:${end}" >> $logFILE
# Set basic parameters for VM/Template
setBASE                     # Set Disk Size, RAM size and # of Cores
setLAN                      # Set Bridge and VLAN
setOPTIONS                  # Set more Options
storageVM=$(getPool VM)     # Set Storage fo the VM e.g. local-zfs
setUSER                     # Create the user, Passwork and Private Key to use
toCREATE                    # What shall we Create Today, a VM or a Template+Clones

# End of Code Section and Initialization Menu ================================#

# Install or not to Install ==================================================#
if (whiptail --backtitle "$backTEXT" --title \
  "Create a single VM or a Template + Clones" --yesno --defaultno \
  "\n    ⚠️ Do you like to proceed  -  Install  or  Exit " \
  10 68 --no-button "Exit" --yes-button "Install"); then
  echo -e "\n${okcm}${magb} User selected Installation to start  $(date +"%F %T")${end}" >> $logFILE


# Headers --------------------------------------------------------------------#
    printf ${yelb}; header; header2; printf ${end}
    echo -e "\n\n${magb}# ========== **** S T A R T  o f  I N S T A L L A T I O N **** ========== #\n${end}"
    echo "${cyn}-  $(date +"%T")  Cloud Image creation started" >> $logFILE
    echo "-- Installation started"
    runSpinner run    # Run the Spinner
# Base Image
    (copyBASE >> $logFILE 2>&1)
    printf "\b"
    echo "${okcm} base.qcow2 image created"
    (createBase >> $logFILE 2>&1)
    printf "\b"
    echo "${okcm} base.qcow2 image initialized"

# Create the VM --------------------------------------------------------------#


    (createVM >> $logFILE 2>&1)
    printf "\b"
    echo "${okcm} VM $vmNO created as $vmNAME"
# Create the Template --------------------------------------------------------#
    if [ "$tok" = true ]; then
        createTemplate &> /dev/null
        printf "\b"
        echo "${okcm} Template $templateNO created as $templateNAME"

        # Create the Clones --------------------------------------------------#
    #     if [[ $numberCLONES -gt 0 ]]; then
    #         (createClones &> /dev/null)
    #         printf "\b"
    #         first="${cname}1"
    #         if [ $numberCLONES = 1 ]; then
    #            echo "${okcm} Clone $firstCLONE created as $first"
    #         elif [[ $numberCLONES > 1 ]]; then
    #            last=$(($firstCLONE + $numberCLONES - 1))
    #            echo "${okcm} Clones $firstCLONE - $last created as $first - $cname$numberCLONES"
    #         fi
    #     fi
    # fi
        echo "${stcm}${cyn} $(date +"%T")  Clone creation started" >> $logFILE
        x=0
        while [ $x -lt $numberCLONES ]
        do
            xx=$(($firstCLONE + $x))
            x=$(( $x + 1 ))
            (createClones &> /dev/null)
            printf "\b"
            echo "${okcm} Clone $xx $cname$x created"
            #echo "${okcm}${cyn} $(date +"%T") Cloned VM $xx $cname$x created" >> $logFILE
        done
        # first="${cname}1"
        # printf "\b"
        # if [ $numberCLONES = 1 ]; then
        #    echo "${okcm} Clone $firstCLONE created as $first"
        # elif [[ $numberCLONES > 1 ]]; then
        #    last=$(($firstCLONE + $numberCLONES - 1))
        #    echo "${okcm} Clones $firstCLONE - $last created as $first - $cname$numberCLONES"
        # fi
    fi

    echo -e "\n${grnb}== Installation is completed. See log for details."
    echo -e "\n${yelb}   Startup the VM's to finalize install"
# End of Execute Functions----------------------------------------------------#

# End of Install -------------------------------------------------------------#
runSpinner off  # Terminate the Spinner
echo "${blub}>>>> End of the Install   $(date +"%F %T") ${end}" >> $logFILE
read -rp "Show the log [y/N] : " pl; if [[ $pl == [yY] ]]; then cat $logFILE; fi
# End of Install =============================================================#

# ⚠️ Setup Aborted ⚠️ ========================================================#
else
    echo -e "${red}== Installation was aborted!${end}"
    echo -e "${yelb}⚠ User canceld the install ⚠${end}" >> $logFILE
fi
