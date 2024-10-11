#!/usr/bin/env bash
# Copyright (c) 2019-2024 CasaUrsus
# Author: nalle (CasaUrsus)
# License: MIT
# https://github.com/nallej/MyJourne/raw/main/LICENSE


sudo apt update && sudo apt install apt-transport-https gnupg2 -y
# Download the key, 4 options
#sudo wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add -
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 013baa07180c50a7101097ef9de922f1c2fde6c4
curl -fsSL https://packages.cisofy.com/keys/cisofy-software-public.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/cisofy-software-public.gpg
#echo "deb [arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/cisofy-software-public.gpg] https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list

sudo echo 'Acquire::Languages "none";' | sudo tee /etc/apt/apt.conf.d/99disable-translations

echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-ly>

sudo apt update && sudo apt install lynis -y
echo "..."
sleep 1
sudo apt-cache policy lynis
echo "..."
sudo lynis audit system --auditor $USER --logfile ~/LYNIS-initial-install.log
