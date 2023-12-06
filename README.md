# MyJourney
To host the Docker Compose files for the blog on homelab.casaursus.net 

## Newest scripts 
My newest scripts will be found in the **SCRIPTS** section
- My new Template builder script can be or pulled by git or downloaded from <br>
https://github.com/nallej/MyJourney/raw/main/scripts/myTemplateBuilder.sh?ref=homelab.casaursus.net
- It automate template creation for VMs and K0s, K3s and K8s clusters
- New version 5.0 is in beta testing 
  https://github.com/nallej/MyJourney/raw/main/scripts/TemplateBuilder.sh


### Other scripts
New setup script myVMsetup is recommended over the 3 part scripts.
Get it to your VM pull: <br>`wget https://github.com/nallej/MyJourney/raw/main/myVMsetup.sh`

Make the script executable : `chmod +x myVMsetup.sh`

Obsolete version
Initial pull: `wget https://raw.githubusercontent.com/nallej/MyJourney/main/1-install.sh`

Make the script executable : `chmod +x 1-install.sh`

## Other

Updat Proxmox bash with my preferenses:<br>`wget https://github.com/nallej/MyJourney/raw/main/BashAddon.sh`<br> 

Add to or change the bash commands:<br>`wget https://github.com/nallej/MyJourney/raw/main/.bash_aliases`<br>
And also the personal bash prompt:<br>`wget https://github.com/nallej/MyJourney/raw/main/.bash_prompt`

## Firewall errors
Firewall errors can be really bad.
To fix do `pve-firewall stop`
If you like to disable it permanently
  - `nano /etc/pve/firewall/cluster.fw`
  - set `enable: 1` to `enable: 0`
# 
<sub><div align="center"> Proxmox® is a registered trademark of Proxmox Server Solutions GmbH. </div></sub>
