#!/bin/bash
# Download: wget https://github.com/nallej/MyJourney/raw/main/scripts/PveInit.sh
clear
# This script will add my personal preferenses to Proxmox nodes"
# Adding apps 
# - bat, cat on steroids"
# - exa, ls as a modern app"
# - nala, apt frontend with a modern look"
#apt update && apt install -y bat exa nala
# Adding aliases to your bash and a new prompt"
# Add to or change the bash commands  1>>$ok_log 2>>$ei_log
wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases
# And also the personal bash prompt 
#wget https://github.com/nallej/MyJourney/raw/main/.bash_prompt
# Activate the changes
# Adding bash_aliases to bashrc. Usually not needed
#echo "[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases" >> .bashrc 
#  Edit your new bash by nano .bash_aliases and make it yours"
#  - change the IP mask if not /24 in [alias myip]"
#  - add any other alias you like
#  - comment out what you do not like"
#  - exit from bat type q"
#To start using the new bash, type: . .bash_aliases (note the periods)"
. .bash_aliases
