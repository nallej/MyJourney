#!/bin/bash
#
clear
echo "This script will add my personal preferenses to Proxmox nodes"
echo ""
echo "  Adding bat (cat on steroids) to your system"
# Add bat 
apt update && apt install -y bat >>install.log 2>&1
echo "  Adding aliases to your bash and a new prompt"
# Add to or change the bash commands  1>>$ok_log 2>>$ei_log
wget https://raw.githubusercontent.com/nallej/MyJourney/main/.bash_aliases >>wget.log 2>&1
# And also the personal bash prompt 
wget https://raw.githubusercontent.com/nallej/MyJourney/main/.bash_prompt >>wget.log 2>&1
# Activate the changes
echo ""
echo ""
echo "  Adding bash_aliases to bashrc"
echo "[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases" >> .bashrc
echo ""
echo "  Edit your new bash by nano .bash_aliases and make it yours"
echo "    - change the IP mask if not /24 in [alias myip]"
echo "    - add any alias you like"
echo "    - comment out what you do not like"
echo "    - exit from bat type q"
sleep 1
echo ""
echo "To start using the new bash, type: . .bash_aliases (note the periods)"
