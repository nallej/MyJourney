#!/bin/bash
# Download: wget https://github.com/nallej/MyJourney/raw/main/scripts/initVM.sh
clear
# echo "This script will add my personal preferenses to Proxmox nodes"
# Add bat, exa and nala
# apt update && apt install -y bat exa nala
# Adding aliases to your bash and a new prompt"
wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases
#wget https://github.com/nallej/MyJourney/raw/main/.bash_prompt
# Activate the changes
# - Adding bash_aliases to bashrc"
#echo "[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases" >> .bashrc
# echo "To start using the new bash, type: . .bash_aliases (note the periods)"
. .bash_aliases
