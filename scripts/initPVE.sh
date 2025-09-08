#!/usr/bin/env bash
# Download: wget https://github.com/nallej/MyJourney/raw/main/scripts/PveInit.sh
clear
echo "This script will add my personal preferenses to Proxmox nodes"
echo " Adding apps"
echo " - bat, cat on steroids"
echo " - exa, ls as a modern app"
echo " - nala, apt frontend with a modern look"
read -rp "Install the set [y/N]: " ben
[[ "$ben" == 'yY ]] && apt update && apt install -y bat exa nala

# Adding aliases to your bash and a new prompt
echo "Add aliases or change the bash commands with aliases"
read -rp "Install bash_aliases [y/N]: " ali
[[ "$ali" == 'yY' ]] && wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases
# And also the personal bash prompt 
echo " Implove the bash prompl [y/N]: " pro
[[ "$pro" == 'yY' ]] && wget https://github.com/nallej/MyJourney/raw/main/.bash_prompt

# Activate the changes
# Adding bash_aliases to bashrc. Usually not needed
echo "[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases" >> .bashrc
echo "Edit your new bash: nano .bash_aliases - and make it yours"
echo "  - change the IP mask if yours not [ /24 ] in [ alias myip ]"
echo "  - add any other alias you like"
echo "  - remove what you do not like"
#echo "  - exit from bat type q"

echo "To start using the new bash, type: . .bash_aliases (note the periods)"
echo #chmod 700 .initPVE.sh#
echo ". .initPVE.sh"
echo ". .bash_aliases"
read -rp "Start using new settings [y/Y] " sta
[[ "$sta" == 'yY' ]] && source .bash_aliases
