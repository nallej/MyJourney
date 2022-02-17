# some more ls aliases
# restart by . ~/.bash_aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias dcn='nano docker-compose.yml'
alias dcup='docker-compose up -d'
alias dcr='docker-compose restart'
alias dcd='docker-compose down'
alias upd='docker-compose up -d'
alias mywanip='curl ipinfo.io/ip'
alias sr='sudo reboot'
alias bye='sudo poweroff'
alias 'cd..'='cd ..'
alias myip="echo My LAN-ip: $(ip a | grep 192 | awk '{print $2}')"
alias lanip="ip a | grep inet | awk '{print $2}' | cut -f2 -d:"
alias wanip="echo WanIp: $(curl ipinfo.io/ip)"
