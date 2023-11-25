#!/bin/bash

#-----------------------------------------------------------------------------#
# For more info see: https://pve.proxmox.com/pve-docs/qm.conf.5.html          #
#-----------------------------------------------------------------------------#

# Install this script by:
#  - open a terminal in the Proxmox node as root
#  - run wget: wget -q --show-progress https://github.com/nallej/MyJourney/raw/main/scripts/myTemplateBuilder.sh
#  - chmod +x myTemplateBuilder.sh
#
# Edit the script is very important, set these to use for auto creation:
#  - set miniFILE -LOCATION = minimal Cloud Image
#  - set stdFILE -LOCATION  = server Cloud Image
#  - set passwdLENGHT       = Minimi lenght of passwords
#  - set admin              = admin user
#  - set initPASSWD         = admin user password
#  - showPASSWD             = Show Password in log true/false
#  - set initKEY            = name and address of your puplic key like   - ~/.ssh/my_key
#  - set testMODE           = Set to true for elevated privilidges in Testing / HomeLab mode
#  - set logFILE            = name and address to the logFILEile
#  - set ISO paths          = local or external path to ISO Storage

# This script generate a workin VM or a Template or a set of VMs

# The functionallity is detemend by your Y/N answers
# ⚠️ Select by [Space] and enter selection with [OK] or [Enter]

# In Case of Machin-ID errors (same IP on nodes)
#    - Erase the machine id: sudo truncate -s 0 /etc/machine-id
#    - Remove the linked: sudo rm /var/lib/dbus/machine-id
#    - Re-Create symbolic link: sudo ln -s /etc/machine-id /var/lib/dbus/machine-id


###############################################################################
 #                                                                           #
  #       👍    👍     E D I T  t h i s  S E C T I O N      👍    👍       #
 #                                                                           #
###############################################################################
#
#------------------------------------------------------------------------------
# 📂 Minimal Cloud Image - example Ubuntu 22.04. Just edit to use your favorite
#------------------------------------------------------------------------------
# File name
     mini=ubuntu-22.04-minimal-cloudimg-amd64.img
# Locaction of the file
     miniFile="https://cloud-images.ubuntu.com/minimal/releases/jammy/release/$mini"
#------------------------------------------------------------------------------
# 📂 Server Cloud Image - example Ubuntu 22.04. Just edit to use your favorite
#------------------------------------------------------------------------------
# File name
     #std=jammy-server-cloudimg-amd64-disk-kvm.img
     std=jammy-server-cloudimg-amd64.img
# Locaction of the file
     stdFile="https://cloud-images.ubuntu.com/jammy/current/$std"
#------------------------------------------------------------------------------
# 👤 Addmin user pre-fills
#------------------------------------------------------------------------------
     # 🔟 Create a long and complicated password
     #   6 is a joke,  8 is something,  12 is semi ok,  16 is ok,  20 is good.
     passl=16 #length of password
     admin=Administrator
     passwd=Pa$$w0rd
     showPASSWD=true     # Show Password in log true/false
     # 🔐 SSH Public Key or download it in the GUI into the cloud-init
     initKEY=~/.ssh/my_key
#------------------------------------------------------------------------------
     # 🔐 Add user to Docker Groupe - NOT recommended for production
     testMODE=true # Set to true for elevated privilidges in Testing / HomeLab mode
#------------------------------------------------------------------------------
# 📑 Name of your LOG file
     logFILE=~/TemplateBuilder.log
#------------------------------------------------------------------------------
# 📂 Local and External PATHs to your ISO files,
#------------------------------------------------------------------------------
#Default Local Storage
    path_iso_local="/var/lib/vz/template/iso/"
    name_iso_local=local
# Default NFS if any
    path_iso_NFS="/mnt/tank/PVE/ISO/"
    name_iso_NFS=ISO
# More defaults if needed
    #path_iso_1= < path >
    #name_iso_1= < name >
# More defaults if needed
    #path_iso_2= < path >
    #name_iso_2= < name >
# More defaults if needed
    #path_iso_3= < path >
    #name_iso_3= < name >
#------------------------------------------------------------------------------
# Other initialisation variables
#------------------------------------------------------------------------------
     initVMNO=8000                  # suggested VM numbre
     initVMNAME=k8s-ctrlr           # suggested VM name
     initTEMPLATENO=9000            # suggested Template number 
     initTEMPLATENAME=k8s-template  # suggested Template name
     initNOCLONES=3                 # suggested how many Clones to create
     initNO1STCLONE=5001            # suggested number for 1st Clone
     initCLONENAME=node-            # suggested Clone namebas for e.g. node-1
#------------------------------------------------------------------------------
#    E n d   o f   t h e   E d i t a b l e   S e c t i o n                    #
#------------------------------------------------------------------------------


###############################################################################
 #                                                                           #
  #   ✋   N O  n e e d  t o  E D I T  B e l o w  t h i s  P o i n t   🚫  #
 #                                                                           #
###############################################################################


# Version history ============================================================

version="myTempBuilder.sh is part of the My HomeLab Journey Project
- https://homelab.casaursus.net
- https://homelab.casaursus.net/proxmox-automation
- https://homelab.casaursus.net/setting-up-kubernetes-k8s

Version History:
- v1.0 29.11.2022  v1.1 01.12.2022
- v2.0 04.01.2023  v2.1 09.01.2023  v2.2 29.01.2023
- v3.0 30.05.2023  v3.1 31.05.2023  v3.2 01.06.2023  v3.3 12.10.2023
- v4.0 12.10.2023  v4.1 31.10.2023
- v5.0 25.11.2023"

function showRecommended() { # Basic recommendations for the user
whiptail --backtitle "$backTEXT" --title "Recommended Settings" --msgbox \
"\nRemember to edit the script before executing:
  - basic settings are 1 core/socket and 1 GiB RAM
  - normal disk size for a VM is 8 - 16 G, but sometimes 4 or even 32 G
    - K8s workers nodes : small 1-2 core and 1-2 GiB RAM, disk 8 - 16 G
    - K8s managers      : 2-4 core and 2 - 4 GiB RAM disk 16 - 32G.
    - K3s nodes minimum : min. 1 core and 512M RAM

  - OS type set to      = L26   Linux 2.6 - 6.X Kernel
  - IP address set to   = DHCP  Remember to set DHCP Reservations
  - Qemu-Guest-Agent    = on
  - Autostart set to    = on " 18 78
}

###############################################################################
 #                                                                           #
  #   🦺 🧰 🦺    G L O B A L  Variables and Functions   🤓   🚫   🤓      #
 #                                                                           #
###############################################################################

pgrm="TemplateBuilder"
ver="5.0"

stopNotRoot(){ # Function Check for root privilidges and exit if not
if [[ "$EUID" != 0 ]]; then
    echo -e "\e[0;31mYou need to be root! Pleas run as sudo.\033[0m" # Message in read
    exit
fi
}

setRoot() { # Function I am root 
if [[ "$EUID" = 0 ]]; then
    echo -e "\n${okcm} Initialaizing: $pgrm version $ver"          # I am root
else
    sudo -k                             # ask for sudo password
    if sudo true; then                  # Correct password
        clear
        echo -e "\n${yelb}Start $pgrm version $ver${end}"
        echo -e "\n${okcm}Initialaizing...${end}"
    else
        echo "${redb}wrong password!${end}"
        exit                            #exit if 3 times wrong
    fi
fi
}

function showGuide() {
whiptail --backtitle "$backTEXT" --title "Notice" --msgbox \
"This script generates a single VM or a Template and cloned VMs, \
\nfunctionallity is detemend by your Y/N answers
Run this script as root or sudo.
  - to make it executable: chmod +x myTemplateBuilder.sh.

 To edit the script is very important:
  - location and name of your public key
    or upload your puplic key to use for auto creation to: ~/.ssh/my_key
  - what Cloud Images to use
  - where are the Cloud Images stored
  - default user related things, name, password and key, logging 

  See the EDIT Section " 20 78
}

function c-info() { # print the Copyright
  clear
  cat <<"EOF"

  Copyright (c) 2021-2023 CasaUrsus
  Author: nallej (CasaUrsus)
  License: MIT
  https://github.com/nallej/MyJourney/raw/main/LICENSE

EOF
}

cstring="Template Builder is Free and Open Sourse Software.\n\
Copyright (c) 2021-2023 CasaUrsus\n\
- Author: nallej (CasaUrsus)\n\
- License: MIT  https://github.com/nallej/MyJourney/raw/main/LICENSE\n\
This is Free and Open Sourse Software; you are free to change and redistribute it.\n\
\nSee the LICENSE file or the link for details.\n \
 - There is NO WARRANTY, read the code befor using it.\n \
 - Part of the My Journey Project @ homelab.casaursus.net\n"

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

function header-2() { # print TemplateBuilder. figlet -f standard TemplateBuilder
  cat <<"EOF"
 _____                    _       _       ____        _ _     _
|_   _|__ _ __ ___  _ __ | | __ _| |_ ___| __ ) _   _(_) | __| | ___ _ __
  | |/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \  _ \| | | | | |/ _` |/ _ \ '__|
  | |  __/ | | | | | |_) | | (_| | ||  __/ |_) | |_| | | | (_| |  __/ |
  |_|\___|_| |_| |_| .__/|_|\__,_|\__\___|____/ \__,_|_|_|\__,_|\___|_|
                   |_|                    https://homelab.casaursus.net
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

function askLicens() {
  if (whiptail --backtitle "$backTEXT" --title "Copyrigt and License" --defaultno --yesno \
  "\n$cstring\n⚠️ Do You Accept the LICENSE agreement?" 20 78 \
    --no-button "No" --yes-button "Accept"); then
    echo "${grn}User Accepted the License. Yes, exit status was $?.${end}" >> $logFILE
    FILE=LICENSE
  if [ -f "$FILE" ]; then
      echo "${blu}LICENSE file exist in this directory.${end}" >> $logFILE
  else
      wget https://github.com/nallej/MyJourney/raw/main/LICENSE &> /dev/null
      echo "${blu}LICENSE file now in this directory.${end}" >> $logFILE
      echo -e "\nTemplate Builder is Free and Open Sourse Software.\n  - There is NO WARRANTY, to the extent permitted by law.\n  - Part of the My Journey Project @ homelab.casaursus.net" > /etc/motd
    fi
else
  echo "${red}⚠ User selected to Decline, exit status was $?. ⚠${end}" >> $logFILE
  exit
fi

whiptail --backtitle "$backTEXT" --title "Version History" --msgbox "$version" 18 78
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
        apt-get update && apt-get install -y libguestfs-tools >> $logFILE 2>&1
        echo -e "\b  ${okcm} Installed the libguestfs-tools"
        echo "${okcm}${cyn} libguestfs-tools installed  $(date +"%T") ${end}" >> $logFILE
    fi
}

# Function call my $1=minimal/server CHANGE server to STANDARD
function dlFile() { # Download the Cloud Image
    local TYPE=$1
    local FILE    # URL
    local NAME    # Short name O
    case $TYPE in
        minimal)
            fileISO=$miniFile
            nameISO=$mini
            ;;
        server)
            fileISO=$stdFile
            nameISO=$std
            ;;
    esac

    case $storageISO in
        local)
            pathISO="/var/lib/vz/template/iso/"
            ;;
        $name_iso_NFS)
            pathISO=path_iso_NFS
            ;;
        $name_iso_1)
            pathISO=path_iso_1
            ;;
        $name_iso_2)
            pathISO=path_iso_2
            ;;
        $name_iso_3)
            pathISO=path_iso_3
            ;;
    esac
    #dlNEW=(whiptail --backtitle "$backTEXT" --title "Re-DownLoad" --radiolist \
    #"Use existing image or load it as new" 20 58 2 \
    #"old" "Use the existing image" ON \
    #"new" "Replace image with new download" OFF 3>&1 1>&2 2>&3)

    if  [ -f $pathISO$nameISO ]; then #elif
        echo  "${okcm}${magb} $nameISO ${end}${cyn}exist in $storageISO" >> $logFILE
      else
        wget -P $pathISO $fileISO 2>&1 | \
        stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
        whiptail --title "Download" --gauge "Downloading $TYPE as:\n$nameISO" 8 78 0
        echo "${dlcm}${magb} $nameISO ${end}${cyn}downloaded to $storageISO  $(date +"%T") ${end}" >> $logFILE
    fi
}

function getPool() { # Show basic pool info and Select a Pool
    local ST=$1
    local LABEL
    local TYPE
    case $ST in
    VM)
      LABEL='VM/CT storage'
      TYPE=$zfs_st
      ;;
    ISO)
      LABEL='IMG/ISO storage'
      TYPE=$img_st
      ;;
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
          "\nStorage pool to use for the ${LABEL,,}?\nSelect [ Space ] and Accsept [ Enter ]\n" \
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
    10 48 vmbr2 3>&1 1>&2 2>&3)
    echo "${cyn}     -  Bridge: $vmbr" >> $logFILE
    # Use a Virtual LAN
    if whiptail --backtitle "$backTEXT"  --title "VLAN Dialog" --yesno \
       "\nDo you need to use a VLAN?" 10 48; then
       vlan=$(whiptail --backtitle "$backTEXT" --title "VLAN Dialog" --inputbox\
       "\nVLAN to use for the VM/Template" 10 48 10  3>&1 1>&2 2>&3)
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
      10 48 $admin 3>&1 1>&2 2>&3)
      echo "${cyn}     -  Cloud-init user: $ciu" >> $logFILE

    # Create a long and complicated password 6 is a joke 8 is something 12 is semi ok 16 is ok 20 is good
    while [[ "$cip" != "$cip_repeat" || ${#cip} -lt $passl ]]; do
      cip=$(whiptail --backtitle "$backTEXT" --title "Create CI User" --passwordbox \
        "\n${cip_invalid}Please enter a password (6 chars min.): " 10 48 $passwd 3>&1 1>&2 2>&3)
      cip_repeat=$(whiptail  --backtitle "$backTEXT" --title "Create CI User" --passwordbox \
        "\nPlease repeat the password: " 10 48 $passwd 3>&1 1>&2 2>&3)
      cip_invalid="WARNING Password too short, or not matching! "
    done
    # Shoud NOT be used for production
        if showPASSWD=true; then 
            echo "${cyn}     -  Cloud-init password: $cip" >> $logFILE
        else
            echo "${cyn}     -  Cloud-init password: /<hidden/>" >> $logFILE
        fi
      #PASSWORD="$(openssl rand -base64 16)"

    #read -rp "     - set key from ~/.ssh/my_key    [y/N] : " my_key
    # Set Key name and address
    my_key=$(whiptail --backtitle "$backTEXT" --title "Create CI User" --inputbox \
      "\nUsers SSH Public Key is: $my_key" \
      10 48 $initKEY 3>&1 1>&2 2>&3)
      echo "${cyn}     -  My key: $my_key" >> $logFILE

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

OPTION_MENU=()
LONGA=0
while read -r ONOFF TAG ITEM; do
  OFFSET=2
  ((${#ITEM} + OFFSET > LONGA)) && LONGA=${#ITEM}+OFFSET
  OPTION_MENU+=("$TAG" "$ITEM " "$ONOFF")
done < <(
  cat <<EOF
ON Qemu-Guest-Agent Qemu-Guest-Agent
ON nano editor and ncurses-term
ON git Git Hub/Lab use
on nala APT frontend
OFF unattended-upgrades set to On
ON Fail2Ban Security
OFF clamav antivirus and daemon
OFF mailutils needs FQDN
OFF Docker-CE Alpine
OFF Dockge Docker Management
OFF Portainer-CE Alpine
OFF Agent Portainer Agent
OFF Docker \$\$\$ license
OFF Portainer-BE \$\$\$ license
OFF K3s TBA a K3s HA-Cluster
OFF K8s make a K8s Cluster
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
    "Qemu-Guest-Agent")
      o1="y"
      echo "${cyn}     -  qemu-guest-agent${end}" >> $logFILE
      ;;
    "nano")
      o2="y"
      echo "${cyn}     -  nano editor, ncurses-term${end}" >> $logFILE
      ;;
    "git")
      o3="y"
      echo "${cyn}     -  git${end}" >> $logFILE
      ;;      
    "nala")
      o21="y"
      echo "${cyn}     -  nala${end}" >> $logFILE
      ;;
    "unattended-upgrades")
      o4="y"
      echo "${cyn}     -  unattended-upgrades${end}" >> $logFILE
      ;;
    "Fail2Ban")
      o5="y"
      echo "${cyn}     -  fail2ban${end}" >> $logFILE
      ;;
    "clamav")
      o6="y"
      echo "${cyn}     -  clamav-daemon${end}" >> $logFILE
      ;;
    "mailutils")
      o7="y"
      echo "${cyn}     -  mailutils${end}" >> $logFILE
      ;;
    "Docker-CE")
      o10="y"
      echo "${cyn}     -  Docker-CE${end}" >> $logFILE
      ;;
    "Dockge")
      o20="y"
      ;;
    "Portainer-CE")
      o11="y"
      echo "${cyn}     -  Portainer-CE${end}" >> $logFILE
      ;;
    "Agent")
      o12="y"
      echo "${cyn}     -  Portainer Agent${end}" >> $logFILE
      ;;
    "Docker")
      o13="y"
      echo "${cyn}     -  Docker-EE \$\$\$${end}" >> $logFILE
      ;;
    "Portainer-BE")
      o14="y"
      echo "${cyn}     -  Portainer \$\$\$${end}" >> $logFILE
      ;;
    "K3s")
      o8="y"
      echo "${cyn}     -  make a K3s cluster${end}" >> $logFILE
      ;;
    "K8s")
      o9="y"
      echo "${cyn}     -  make a K8s cluster${end}" >> $logFILE
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
        "\nName of clone(s) $initCLONENAME1 to $initCLONENAME$numberCLONES" 10 48 node- 3>&1 1>&2 2>&3)
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

function createBase() {
# Create base.qcow2 as a base for a VM using a CI
    #printf "\b"
    echo "${stcm}${cyn} $(date +"%T")  Copy $pathISO$nameISO -> base.qcow2" >> $logFILE
    if [ -f base.qcow2 ]; then
        cp --remove-destination $pathISO$nameISO base.qcow2  &> /dev/null
      else
        cp $pathISO$nameISO base.qcow2  &> /dev/null
    fi

    qemu-img resize base.qcow2 $sizeD
    # 16G is typical - Resize the disk to your needs, 8 - 32 GiB is normal
    # Add Qemu-Guest-Agent and any other packages you’d like in your base image.
    # libguestfs-tools has to be installed on the node.
    # Add or delete add-ons according to your needs
    echo "${stcm}${cyn} $(date +"%T")  Create base $sizeD image" >> $logFILE

    echo "# Firstboot commands created from myTemplateBuilder" > firstboot.sh
    vc=""
    if [[ $o1 == 'y' ]]; then vc="$vc --install qemu-guest-agent"; fi
    if [[ $o2 == 'y' ]]; then
        vc="$vc --install nano"
        vc="$vc --install ncurses-term"; fi
    if [[ $o3 == 'y' ]]; then vc="$vc --install git"; fi
    if [[ $o21 == 'y' ]]; then vc="$vc --install nala"; fi    
    if [[ $o4 == 'y' ]]; then vc="$vc --install unattended-upgrades"; fi
    if [[ $o5 == 'y' ]]; then vc="$vc --install fail2ban"; fi
    if [[ $o6 == 'y' ]]; then
        vc="$vc --install clamav"
        vc="$vc --install clamav-daemon"; fi
    if [[ $o7 == 'y' ]]; then vc="$vc --install mailutils"; fi

    # if [[ $o8 == 'y' ]]; then
    # --firstboot-command 'sudo apt-get update'
    # --install containerd,curl \
    # --firstboot-command 'sudo apt-get install software-properties-common'\
    # --firstboot-command 'sudo apt-get update' \
    # --firstboot-command 'curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | sudo dd status=none of=/usr/share/keyrings/kubernetes-archive-keyring.gpg' \
    # --firstboot-command 'echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list' \
    # #virt-customize -a base.qcow2 --firstboot-command 'sudo apt-get update && sudo apt-get upgrade'
    # --firstboot-command 'sudo swapoff -a' \
    # --mkdir /etc/containerd \
    # --firstboot-command 'containerd config default | sudo tee /etc/containerd/config.toml' \
    # --firstboot-command 'echo "br_netfilter" > /etc/modules-load.d/k8s.conf' \
    # --firstboot-command 'sed -i "s/^\( *SystemdCgroup = \)false/\1true/" /etc/containerd/config.toml' \
    # --firstboot-command 'sed -i -e "/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1" etc/sysctl.conf' \
    # --firstboot-command 'sudo apt-get update && sudo apt install -y kubeadm kubectl kubelet' \
    # --firstboot-command 'sudo truncate -s 0 /etc/machine-id' \
    # --firstboot-command 'sudo rm /var/lib/dbus/machine-id' \
    # --firstboot-command 'sudo ln -s /etc/machine-id /var/lib' \"
    # fi
    # #if [[ $o9 == 'y' ]]; then ; fi
    if [[ $o10 == 'y' ]]; then # || $o13 == 'y' ]]; then
        # vc="$vc --install software-properties-common"
        # vc="$vc --install apt-transport-https"
        # vc="$vc --install ca-certificates"
        # vc="$vc --install apt-utils"
        # vc="$vc --install gnupg"
        # vc="$vc --install curl"
        echo "apt-get install -y software-properties-common apt-transport-https ca-certificates apt-utils gnupg curl"  >> firstboot.sh
        echo "mkdir -p /etc/apt/keyrings" >> firstboot.sh
        echo "mkdir -p /home/$ciu/docker/" >> firstboot.sh
        echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" >> firstboot.sh
        echo "chmod a+r /etc/apt/keyrings/docker.gpg" >> firstboot.sh
        echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null" >> firstboot.sh
        echo "apt-get update" >> firstboot.sh
        if [[ testMODE = true ]]; then echo "usermod -aG docker $ciu" >> firstboot.sh; fi
        echo "apt-get install -y docker-ce containerd.io docker-ce-cli docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin" >> firstboot.sh
    fi  
    if [[ $o20 == 'y' ]]; then
        echo "/home/$ciu/docker/dockge/" >> firstboot.sh
        # Dockge management app is a great tool and replaces Portainer-CE in my lab. Storage strategy /home/<user>/docker/ dockge (for its data) and stacks (for the <app>/compose.yaml)
        echo "docker run -d -p 5001:5001 --name Dockge --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v /home/$ciu/docker/dockge/data:/app/data -v /home/$ciu/docker/stacks:/home/$ciUSER/docker/stacks -e DOCKGE_STACKS_DIR=/home/$ciUSER/docker/stacks louislam/dockge:latest" >> firstboot.sh
      fi  
    if [[ $o11 == 'y' ]]; then
        echo "mkdir -p /home/$ciu/docker/portainer/portainer-data" >> firstboot.sh
        echo "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:alpine" >> firstboot.sh
    fi
    if [[ $o12 == 'y' ]]; then
        echo "docker run -d -p 9001:9001 --name portainer-agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:alpine" >> firstboot.sh
    fi
    if [[ $o13 == 'y' ]]; then
        vc="$vc --install apt-utils"
        #vc="$vc --install curl"
        vc="$vc --install software-properties-common"
        vc="$vc --install apt-transport-https"
        #vc="$vc --install ca-certificates"
        vc="$vc --install gnupg"
        echo "mkdir -p /etc/apt/keyrings" > firstboot.sh
        echo "mkdir -p /home/$ciu/docker/" >> firstboot.sh
        echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" >> firstboot.sh
        echo "chmod a+r /etc/apt/keyrings/docker.gpg" >> firstboot.sh
        echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null" >> firstboot.sh
        echo "apt-get update" >> firstboot.sh
        echo "apt-get install -y docker containerd.io docker-cli docker-compose-plugin docker-rootless-extras docker-buildx-plugin" >> firstboot.sh
    fi     
    if [[ $o14 == 'y' ]]; then 
        echo "mkdir -p /home/$ciu/docker/portainer/portainer-data" >> firstboot.sh
        echo "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:alpine" >> firstboot.sh
    fi
    echo "cp /root/virt-sysprep-firstboot.log /home/$ciu/firstboot.log" >> firstboot.sh
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

function createVM() {
# Creat a VM or a Template based on the base.qcow2 file
    local note
    echo "${stcm}${cyn} $(date +"%T")  VM creation started" >> $logFILE
    # Creare the base image ----------------------------------------------#
    ibase="$vmNO --memory $sizeM --core $sizeC --name $vmNAME --net0 virtio,bridge=$vmbr"
    if [[ tag > 0 ]]; then ibase="${ibase},tag=$vlan"; fi
    qm create $ibase
    echo "${okcm}${cyn} $(date +"%T")    - $ibase $storageVM" >> $logFILE
    # Set options --------------------------------------------------------#
    qm disk import $vmNO base.qcow2 $storageVM > /dev/null 2>&1                 # Import the disc to the base of the VM. Where to put the VM local-lvm
    qm set $vmNO --scsihw virtio-scsi-pci --scsi0 $storageVM:vm-$vmNO-disk-0    # Attache the disk to the base of the VM
    qm set $vmNO --ide2 $storageVM:cloudinit                                    # Attach the cloudinit file - you might need to EDIT it later !
    qm set $vmNO --boot c --bootdisk scsi0                                      # Make the cloud init drive bootable and only boot from this disk
    qm set $vmNO --serial0 socket --vga serial0                                 # Add serial console, to be able to see console output!
    qm set $vmNO --onboot 1                                                     # Autostart vm at boot - default is 0 - Ususlly most VM's are allway running
    qm set $vmNO --agent 1                                                      # Use Qemu Guest Agent - default is 0
    qm set $vmNO --ostype l26                                                   # Set OS type Linux 5.x kernel 2.6 - default is other
    qm set $vmNO --ipconfig0 ip="dhcp"                                          # Set dhcp on
    qm set $vmNO --ciuser $ciu                                                  # "admin"        use your imagination
    qm set $vmNO --cipassword $cip                                              # "Pa$$w0rd"     use a super complicated one
    qm set $vmNO --sshkey ~/.ssh/my_key                                         # sets the users key to the vm
    #if [[ $my_key > " " ]]; then qm set $vmNO --sshkey $my_key; fi     # sets the users key to the vm
    # Create the Notes window
    echo "# # VM $vmNO $vmNAME" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- RAM    : $sizeM" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- Core   : $sizeC" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- User   : $ciu, $cip" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- Bridge : $vmbr" >>  /etc/pve/qemu-server/$vmNO.conf
    if [[ $vlan > 0 ]]; then echo "#  vLAN: $vlan" >> /etc/pve/qemu-server/$vmNO.conf; fi
    if [[ $my_key > " " ]]; then echo "# - SSH Key: $my_key" >> /etc/pve/qemu-server/$vmNO.conf; fi
    echo "#- Storage: $storageVM" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#- Base   : $nameISO" >> /etc/pve/qemu-server/$vmNO.conf
    echo "#  from: $pathISO" >> /etc/pve/qemu-server/$vmNO.conf
    #echo -e '#foo-bar\n' >> /etc/pve/lxc/VMID.conf
    echo "${okcm}${cyn} $(date +"%T")  VM $vmNO $vmNAME Created" >> $logFILE
}

function createTemplate() {
# Create the template ex. 90000000
    local note
    echo "${stcm}${cyn} $(date +"%T")  Template creation started" >> $logFILE
    ibase="$templateNO --memory $sizeM --core $sizeC --name $templateNAME --net0 virtio,bridge=$vmbr"
    if [[ tag > 0 ]]; then ibase="${ibase},tag=$vlan"; fi
    qm create $ibase
    echo "${okcm}${cyn} $(date +"%T")    - $ibase"  >> $logFILE
    # Set options --------------------------------------------------------#
    qm disk import $templateNO base.qcow2 $storageVM > /dev/null 2>&1                       # Import the disc to the base of the template. Where to put the VM local-lvm
    qm set $templateNO --scsihw virtio-scsi-pci --scsi0 $storageVM:vm-$templateNO-disk-0    # Attache the disk to the base of the template
    qm set $templateNO --ide2 $storageVM:cloudinit                                          # Attach the cloudinit file - you might need to EDIT it later !
    qm set $templateNO --boot c --bootdisk scsi0                                            # Make the cloud init drive bootable and only boot from this disk
    qm set $templateNO --serial0 socket --vga serial0                                       # Add serial console, to be able to see console output!
    qm set $templateNO --onboot 1                                                           # Autostart vm at boot - default is 0 - Ususlly most VM's are allway running
    qm set $templateNO --agent 1                                                            # Use Qemu Guest Agent - default is 0
    qm set $templateNO --ostype l26                                                         # Set OS type Linux 5.x kernel 2.6 - default is other
    qm set $templateNO --ipconfig0 ip="dhcp"                                                # Set dhcp on
    qm set $templateNO --ciuser $ciu                                                        # "admin"        use your imagination
    qm set $templateNO --cipassword $cip                                                    # "Pa$$w0rd"     use a super complicated one
    if [[ $my_key > " " ]]; then qm set $templateNO --sshkey $my_key; fi            # sets the users key to the vm

    echo "# # Template $templateNO $templateNAME" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- RAM    : $sizeM" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- Core   : $sizeC" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- User   : $ciu, $cip" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- Bridge : $vmbr" >>  /etc/pve/qemu-server/$templateNO.conf
    if [[ $vlan > 0 ]]; then echo "#  vLAN: $vlan" >> /etc/pve/qemu-server/$templateNO.conf; fi
    if [[ $my_key > " " ]]; then echo " - SSH Key: $my_key" >> /etc/pve/qemu-server/$templateNO.conf; fi
    echo "#- Storage: $storageVM" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#- Base   : $nameISO" >> /etc/pve/qemu-server/$templateNO.conf
    echo "#  from : $pathISO" >> /etc/pve/qemu-server/$templateNO.conf
    #echo -e '#foo-bar\n' >> /etc/pve/lxc/VMID.conf

    qm template $templateNO
    echo "${okcm}${cyn} $(date +"%T")  Template $templateNO $templateNAME created" >> $logFILE
}

function createClones() { # Cloning the template
    local note
    echo "${stcm}${cyn} $(date +"%T")  Clone creation started" >> $logFILE
    x=0
    while [ $x -lt $numberCLONES ]
    do
        xx=$(($firstCLONE + $x))
        x=$(( $x + 1 ))
        qm clone $templateNO $xx --name $cname$x --full
        echo "# # VM $xx $cname$x" >> /etc/pve/qemu-server/$xx.conf
        #echo " ${okcm}${cyn} $(date +"%T")  Clone $xx created"
        echo "${okcm}${cyn} $(date +"%T")  Cloned VM $xx $cname$x created" >> $logFILE
    done
}

function init() {
    clear; printf ${yelb}; header-2; printf ${end} # Show header-2
    #Spinner
    runSpinner run
    # Read the storage pools ---------------------------------------------------#
    zfs_st=$(pvesm status -content rootdir)
    img_st=$(pvesm status -content vztmpl)
    runSpinner off
}

###############################################################################
 #                                                                           #
  #   🧱🧱🧱🧱🧱🧱   E X E C U T I O N A B L E   C O D E   🧱🧱🧱🧱🧱🧱   #
 #                                                                           #
###############################################################################

# Code Section ===============================================================#
backt="myTempBuilder.sh is part of the My HomeLab Journey Project"  #Background text
# Initialization menu --------------------------------------------------------#

useColors                   # Use color codes
init                        # Init function
setRoot                     # Check for root privilidges
stopNotRoot                 # Exit if not root
clear                       # Clear the screan
setLOG                      # New or Append
showGuide                   # Quick Guide
askLicens                   # Accept Licens
showRecommended             # Recommendations
guestfs                     # Install the needed libguestfs-tools if it's missing

storageISO=$(getPool ISO)   # Set ISO storage e.g. local /var/lib/vz/template/iso/

# Use Server or Minimal Cloud Image
CI=$(whiptail  --backtitle "$backTEXT" --title "Choose the Base Image" --radiolist \
"\nChoose the Cloud Image to use as a Base " 12 78 2 \
"minimal" "$mini" ON \
"server" "$std" OFF \
3>&1 1>&2 2>&3)
dlFile $CI                  # Download Cloud Image if missing from storageISO
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
  "\nCreate a VM, a Template and Clones" --yesno --defaultno \
  "\n  ⚠️  Do you like to proceed  -  Install  or  Exit " \
  10 68 --no-button "Exit" --yes-button "Install"); then
  echo "${okcm}${magb} User selected Installation to start  $(date +"%F %T")${end}" >> $logFILE

###############################################################################
 #                                                                           #
  #   ✋   N O  n e e d  t o  E D I T  B e l o w  t h i s  P o i n t   🚫  #
 #                                                                           #
###############################################################################

# Headers --------------------------------------------------------------------#
    printf ${yelb}; header; header-2; printf ${end}
    echo -e "\n\n${magb}# ========== **** S T A R T  o f  I N S T A L L A T I O N **** ========== #\n${end}"
    echo "${cyn}-  $(date +"%T")  Cloud Image creation started" >> $logFILE
    echo "-- Installation started"
    runSpinner run    # Run the Spinner
# Create the VM --------------------------------------------------------------#
    (createBase >> $logFILE 2>&1)
    printf "\b"
    echo "${okcm} base.qcow2 image created"

    (createVM >> $logFILE 2>&1)
    printf "\b"
    echo "${okcm} VM $vmNO created as $vmNAME"
# Create the Template --------------------------------------------------------#
    if [[ $tok = true ]]; then
        createTemplate &> /dev/null
        printf "\b"
        echo "${okcm} Template created: $templateNO $templateNAME"

        # Create the Clones --------------------------------------------------#
        if [[ $numberCLONES -gt 0 ]]; then
            (createClones &> /dev/null)
            printf "\b"
            first="${cname}1"
            if [ $numberCLONES = 1 ]; then
               echo "${okcm} Clone created: $firstCLONE $first $numberCLONES"
            elif [[ $numberCLONES > 1 ]]; then
               last=$(($firstCLONE + $numberCLONES - 1))
               echo "${okcm} Clone(s) created: $firstCLONE $first - $last $cname$numberCLONES"
            fi
        fi
    fi

    echo -e "\n${grnb}== Installation is completed. See log for details."
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
# End of Script ###############################################################
