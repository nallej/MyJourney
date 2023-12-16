#!/bin/bash
# Download: wget https://github.com/nallej/MyJourney/raw/main/scripts/initVM.sh
clear
echo "This script will add my personal preferenses to Proxmox nodes"
echo "Switch keyboard sudo nano /etc/default/keyboard"
sudo nano /etc/default/keyboard
#echo "Add bat, exa and nala"
# apt update && apt install -y bat exa nala
echo "Adding aliases to your bash and a new prompt"
#wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases
wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases -O .bash-personal
wget https://github.com/nallej/MyJourney/raw/main/.bash_prompt
echo "Activating the changes"
#  - Adding bash_aliases to bashrc and activate"
# echo "[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases" >> .bashrc
# echo "To start using the new bash, type: . .bash_aliases (note the periods)"
#. .bash_aliases
echo "  - Adding bash-personal to bashrc and activate"
echo "[[ -f ~/.bash-personal ]] && . ~/.bash-personal" >> .bashrc
# echo "To start using the new bash, type: . .bash-personal (note the periods)"
. .bash-personal
