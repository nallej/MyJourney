# Some more aliases use in .bash_aliases or .bashrc-personal 
# restart by source .bashrc or restart
# restart by . ~/.bash_aliases

### Functions go here. Use as any ALIAS ###
# make a directory and jump into it 
mkcd() { mkdir -p "$1" && cd "$1"; }
# make, chmod and nano a new script
newsh() { touch "$1".sh && chmod +x "$1".sh && echo "#!/bin/bash" > "$1.sh" && nano "$1".sh; }
# create, cmod and nano a file
newfile() { touch "$1" && chmod 700 "$1" && nano "$1"; }
new700() { touch "$1" && chmod 700 "$1" && nano "$1"; }
new750() { touch "$1" && chmod 750 "$1" && nano "$1"; }
new755() { touch "$1" && chmod 755 "$1" && nano "$1"; }
newxfile() { touch "$1" && chmod +x "$1" && nano "$1"; }

## Other ways of doing it ##
#alias mkcd='function _mkcd() { mkdir -p "$1" && cd "$1"; }; _mkcd'
#newsh() {
#    touch "$1" && chmod +x "$1" && echo "#!/bin/bash" > "$1" && nano "$1"
#}
#alias newfile='f() { touch "$1" && chmod 700 "$1" && nano "$1"; }; f'

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
alias docker-compose='docker compose'
alias dcn='nano docker-compose.yml'
alias dcup='docker-compose up -d'
alias dcupl='docker-compose up -d && docker-compose logs -f'
alias dcr='docker-compose restart'
alias dcd='docker-compose down'

## ssh keys
alias newkey='ssh-keygen -t ed25519 -C "user@example.com" -f ${1}'
alias remkey='ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R "${1}"'
alias addkey='ssh-copy-id -i ~/.ssh/id_ed25519.pub ${1} '

## system related on any deb based use batcat all other use bat
# Set the TZ
alias setz="timedatectl set-timezone $1"
alias fzfbat='fzf --preview "batcat --color=always --style=numbers --line-range=:500 {}"'
# usage: help <command>
#alias bathelp='bat --plain --language=help'
#help() { "$@" --help 2>&1 | bathelp }
# zsh only! ---------------------------------------------------------#
#alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'         #
#alias -g -- --help='--help 2>&1 | bat --language=help --style=plain' #
# -------------------------------------------------------------------#
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
alias f2b='fail2ban-regex systemd-journal /etc/fail2ban/filter.d/proxmox.conf'

## cd aliases
alias 'cd..'='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

## IP related
#### Use your subnet mask here /24 /64
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


