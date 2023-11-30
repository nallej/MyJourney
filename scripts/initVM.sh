#!/bin/bash
# Download: wget https://github.com/nallej/MyJourney/raw/main/scripts/initVM.sh
clear
# echo "This script will add my personal preferenses to Proxmox nodes"
# Add bat exa nala
# apt update && apt install -y bat exa nala >>install.log 2>&1
# Adding aliases to your bash and a new prompt"
wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases >>wget.log 2>&1
wget https://github.com/nallej/MyJourney/raw/main/.bash_prompt >>wget.log 2>&1
# Activate the changes
# - Adding bash_aliases to bashrc"
echo "[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases" >> .bashrc
# sleep .5
# echo "To start using the new bash, type: . .bash_aliases (note the periods)"
. .bash_aliases
