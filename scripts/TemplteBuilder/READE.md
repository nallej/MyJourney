# TemplateBuilder
How to create a VM or a Template from scratch
This script generates a single VM or a Template and VMs.                   
  - functionallity is determend by your choices and answers                  
This script will run as root or `sudo`.                                       
  - to make it executable: chmod +x Templatebuilder.sh or chmod 700 Templatebuilder.sh                      
 
## To edit the script is very important:                                      
  - location and name of public key to be used in auto creation           
     - your public key for this server/cluster                             
     - copy one into: `~/.ssh/my_key.pub` or use existing one                
  - what Cloud Images to use and where are they on the web                 
  - where are Cloud Images and VM disks to be stored                      
  - default user related things, name, password and key ...                
  
See the EDIT Section of the script  

## Sourced files
Most generic or semi-generic functions are called with thee **`source`** -command
- Example: `source version` 
