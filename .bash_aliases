# some more aliases
# restart by source .bashrc or restart
# restart by . ~/.bash_aliases
## ls commands
alias ls='ls --color=auto'
alias ll='ls -alFh --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias lsd='lsblk -o +MODEL,SERIAL'
alias lsdid='ls -l /dev/disk/by-id'
#alias ls='exa'
#alias ls='exa -T'
#alias ll='exa -a'
#### Remvove the --icons if or install a Nerdfont
#alias exa='exa --long --icons'
#alias exat='exa --long --icons --tree '
alias exa='exa --long'
alias exat='exa --long --tree '
## confirm before overwriting something
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
## Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
## docker related
alias dcn='nano docker-compose.yml'
alias dcup='docker-compose up -d'
alias dcupl='docker-compose up -d && docker-compose logs -f'
alias dcr='docker-compose restart'
alias dcd='docker-compose down'
## system related
alias bat='batcat'
#alias cat='bat'
#alias cat='batcat'
#alias catt='cat'
alias sr='sudo reboot'
alias bye='sudo poweroff'
alias update='sudo apt-get update'
alias install='sudo apt-get update && sudo apt-get install -y '
#alias install='sudo nala install -y '
#alias update='sudo nala update'
#alias upgrade='sudo nala upgrade --no-autoremove'
#alias upall='sudo nala update && sudo nala upgrade'
alias upgrade='sudo apt-get upgrade'
alias upall='sudo apt-get update && sudo apt-get dist-upgrade -y'
alias nhost='sudo nano /etc/hosts'
alias df='df -h'
alias free='free -m'
## cd aliases
alias 'cd..'='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
## IP related
#### Use your subnet mask here /24 
alias myip="echo My LAN-ip: $(ip address | grep /24 | awk '{print $2}')"
#alias lanip="ip a | grep inet | awk '{print $2}' | cut -f2 -d:"
#alias wanip='echo WanIp: $(curl ipinfo.io/ip)'
#alias netspeed='sudo curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
#alias sää='curl wttr.in'
#alias mikä='curl cheat.sh/'
# Extracting archive files
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Use Personal Prompt
[[ -f ~/.bash_prompt ]] && source ~/.bash_prompt


