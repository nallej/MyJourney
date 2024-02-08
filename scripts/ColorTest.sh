## Font attributes ##
# off
#off = '\x1b[0m' # off
default='\e[39m' # default foreground
DEFAULT='\e[49m' # default background
# 
#bd = '\x1b[1m' # bold
#ft = '\x1b[2m' # faint
#st = '\x1b[3m' # standout
#ul = '\x1b[4m' # underlined
#bk = '\x1b[5m' # blink
#rv = '\x1b[7m' # reverse
#hd = '\x1b[8m' # hidden
#nost = '\x1b[23m' # no standout
#noul = '\x1b[24m' # no underlined
#nobk = '\x1b[25m' # no blink
#norv = '\x1b[27m' # no reverse

## Background Colors
BLACK='\e[40m'
RED='\e[41m'
GREEN='\e[42m'
YELLOW='\e[43m'
BLUE='\e[44m'
MAGENTA='\e[45m'
CYAN='\e[46m'
WHITE='\e[47m'
### Dark/Light BG
DGRAY='\e[100m'
LRED='\e[101m'
LGREEN='\e[102m'
LYELLOW='\e[103m'
LBLUE='\e[104m'
LMAGENTA='\e[105m'
LCYAN='\e[106m'
LGRAY='\e[107m'


# Foreground Colors
black='\e[30m'
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
white='\e[37m'

# Dark/Light colors
dgray='\e[90m'
lred='\e[91m'
lgreen='\e[92m'
lyellow='\e[93m'
lblue='\e[94m'
lmagenta='\e[95m'
lcyan='\e[96m'
lgray='\e[97m'

## 256 colors ##
# \x1b[38;5;#m foreground, # = 0 - 255
# \x1b[48;5;#m background, # = 0 - 255
## True Color ##
# \x1b[38;2;r;g;bm r = red, g = green, b = blue foreground
# \x1b[48;2;r;g;bm r = red, g = green, b = blue background

echo -e "${red} Printing red"
echo -e "${green} Printing green"
echo -e "${yellow} Yellow"
echo -e "${blue} Blue"
echo -e "${magenta} Magenta"
echo -e "${cyan} Cyan" 
echo -e "${white} White"
echo -e "${dgray} Dark Grey"
echo -e "${lred} Light Red"
echo -e "${lgreen} Light Green"
echo -e "${lyellow} Light Yellow"
echo -e "${lblue} Light Blue"
echo -e "${lmagenta} Light Magenta"
echo -e "${lcyan} Light Cyan"
echo -e "${lgray} Light Grey"

# Other
ECS=$(echo "\e[m")         # End of Color Statement

bred=$(echo "\e[1;31m")
echo -e "${bred} Bold Red "
bgreen=$(echo "\e[1;92m")      # Bold Brite Light Green
echo -e "${bgreen} Bold Brite Light Gren"
Purple=$(echo "\e[1;95m")	  # Bold Purple
echo -e "${Purple} Purple"
WGN=$(echo "\e[1;37;1;42m")   # Bold White in Bold Green Box
WYW=$(echo "\e[1;37;1;43m")   # Bold White in Bold Yellow Box
WRD=$(echo "\e[1;37;1;41m")   # Bold White in Bold Red Box
echo -e "${WGN} Bold White in Bold Green Box${ECS}"
echo -e "${WYW} Bold White in Bold Yellow Box${ECS}"
echo -e "${WRD} Bold White in Bold Red Box${ECS}"
ugreen=$(echo "\e[4;92m")      # Underline Brite Light Green
echo -e "${ugreen} Underline Green ${ECS}"
echo -e "\e[1;95;1;46mTest text${ECS}"


#
## End and RESET
echo -e "⚠️ End of FG${default} and ${DEFAULT}end of BG ${endcs} end of Color Test"