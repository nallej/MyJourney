# some more aliases
# restart by source .bashrc
# restart by . ~/.bash_aliases
## ls commands
alias ls='ls --color=auto'
alias ll='ls -alFh --color=auto'
alias la='ls -A'
alias l='ls -CF'
## confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
## Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
## docker related
alias dcn='nano docker-compose.yml'
alias dcup='docker-compose up -d'
alias dcr='docker-compose restart'
alias dcd='docker-compose down'
alias upd='docker-compose up -d'
alias mywanip='curl ipinfo.io/ip'
## system related
alias sr='sudo reboot'
alias bye='sudo poweroff'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias upall='sudo apt update && sudo apt upgrade'
alias nhost='sudo nano /etc/hosts'
## cd aliases
alias 'cd..'='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
## IP related
alias myip="echo My LAN-ip: $(ip a | grep 192 | awk '{print $2}')"
alias lanip="ip a | grep inet | awk '{print $2}' | cut -f2 -d:"
alias wanip="echo WanIp: $(curl ipinfo.io/ip)"
# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'