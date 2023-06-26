#!/bin/bash
test -n "${BASHALIASES}" && return

BASHALIASES=loaded
LOAD_SYSTEM_ALIASES=TRUE

# Source global aliases
if [ -f /etc/profile.d/aliases.sh ]; then
	. /etc/profile.d/aliases.sh
fi
# Source local aliases
if [ -f ${HOME}/.local_aliases ]; then
	if [ ! -r ${HOME}/.aliases_local ]
	then
		mv ${HOME}/.local_aliases ${HOME}/.aliases_local
        else
		echo "Can't migrate .local_aliases to .aliases_local, manual intervention required"
	fi
fi
# Source local aliases
if [ -f ${HOME}/.aliases_local ]; then
	. ${HOME}/.aliases_local
fi

alias psx="ps -ef | grep -v '\[.*\]'"
alias ipgrep='egrep -o '\''[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'\'''
alias ip6r='ip -6 route | grep -v "^f"'
alias fixterm=' echo -e "\017" '
alias nulcat="sed 's/\x00/\n/g'"
alias wt='which biff >/dev/null 2>&1 && biff y; while true; do echo -n "."; sleep 1s; done'
alias cls=clear

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

test -n "$(which ncftp 2>/dev/null)" && alias ftp=ncftp
test -n "$(which rsync 2>/dev/null)" && alias cpv="rsync -avh --progress"
test -n "$(which lsof 2>/dev/null)" && alias lsofl='lsof -i -n -P -stcp:LISTEN|grep -v COMMAND|sort'

alias date2epoch='perl -le "
      use Date::Manip;
      print &UnixDate(@ARGV[0], \"%s\");"'
alias epoch2date='perl -le "
      use Date::Manip;
      \$DATE=&ParseDate(\"epoch @ARGV[0]\");
      print &UnixDate(\$DATE, \"%a %b %d %H:%M:%S AKDT %Y\");"'

# aliases for /bin/ls
if [ -n "$(ls --help 2>&1 | grep group-dir)" ]; then LSGROUP="--group-directories-first"; else LSGROUP=""; fi
alias ls="LC_COLLATE='C.UTF-8' /bin/ls -F --color=auto ${LSGROUP}"
alias lsf='ls -a'
alias dir='ls -l'
alias sdir='ls -lSr'
alias tdir='ls -lFr --sort=time'

# aliases for ssh, for temp connections without host-key validation
alias tscp='scp -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null'
alias tsftp='sftp -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null'
alias tssh='ssh -o StrictHostKeyChecking=false -o UserKnownHostsFile=/dev/null -E /dev/null -k -x'
# force password authentication
alias pssh='ssh -o PreferredAuthentications=keyboard-interactive,password'
# for old ssh connections
alias ossh='ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -ociphers=+aes256-cbc,aes192-cbc,aes128-cbc'

export BASHALIASES
