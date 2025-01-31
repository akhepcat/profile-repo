if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# Non-interactive login session
TS=$(date +"%Y%m%d%H%S")
HOST=$(uname -n)
USERNAME=$(whoami)

if [ -n "$PS1" ]; then
	test -n "${BASHPROFILE}" && return

	BASHPROFILE=loaded

        tset -I -Q

	bind '"\e[A"':history-search-backward
	bind '"\e[B"':history-search-forward

	ENV=$HOME/.bashrc
	TTY=$(tty | awk -F/ '{print $4}')

	# make sure this exists!
	test -d ${HOME}/.history && mkdir -p ${HOME}/.history
	HISTFILE=${HOME}/.history/.hist.${HOST}.${TS}.${TTY}
	HISTCONTROL=ignoreboth
	HISTSIZE=2000
	HISTFILESIZE=2000
	command_oriented_history=1
	ignoreeof=10

	[ -n "$(which less 2>/dev/null)" ] && PAGER="$(which less) -ri" || PAGER="$(which more)"
	# make less more friendly for non-text input files, see lesspipe(1)
	[ -n "$(which lesspipe 2>/dev/null)" ] && eval "$(lesspipe)"

	# Proper sorting! Woo!
	LC_COLLATE=C

	# if the \$FOO  bug bites, just uncomment this...
        if [ ${BASH_VERSINFO[0]} -ge 5 -o \( ${BASH_VERSINFO[0]} -eq 4 -a ${BASH_VERSINFO[1]} -ge 2 -a ${BASH_VERSINFO[2]} -ge 29 \) ]
                then shopt -s direxpand
        fi
	shopt -s checkwinsize

	if [ -n "${BASH}" -a -n "${BASH##*termux*}" ]
	then
		if [ -z "$(pgrep -u ${USER} gpg-agent)" -a -n "$(which gpg-agent 2>/dev/null)" -a ! -e ${HOME}/.gnupg/noagent ];
		then
			test -d ${HOME}/.gnupg && eval $(gpg-agent --daemon --enable-ssh-support )
		fi
	fi
	if [ "$TERM" = "network" ]; then
		TERM=vt102
	fi

	# set a fancy prompt (non-color, unless we know we "want" color)
	if [ -z "${STY}" ];  then TSSH=${SSH_CLIENT:+ssh(${SSH_CLIENT%% *}):}; else TSSH=""; fi
	case "$TERM" in
		xterm*|rxvt*|screen*|vt10*)
			eval "`dircolors -b`"
			if [ "${USERNAME:-$USER}" = "root" ]; then UC=31; else UC=32; fi
			PS1='${debian_chroot:+($debian_chroot):}${TSSH}${STY:+screen-${STY##*.}:}\[\033[01;${UC}m\]${SUDO_USER:+($SUDO_USER->)}\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
			#   for xwindow titles
			PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
		    ;;
		*)
			PS1='${debian_chroot:+($debian_chroot):}${TSSH}${STY:+screen-${STY##*.}:}\u@\h:\w\$ '
		    ;;
	esac

	# fixup these paths:
	CLASSPATH=${HOME}/.java/jar:$CLASSPATH

	MYMANPATH=/usr/man:/usr/share/man:/usr/local/man:$MANPATH
	MANPATH=$(for i in `echo $MYMANPATH | sed 's/:/ /g'`; do if [ -e $i ]; then echo $i; fi; done | sort -u | tr [\\n] [:])
	unset MYMANPATH MYPATH

	if [ -n "${BASH}" -a -n "${BASH##*termux*}" ]
	then
		MYPATH=/usr/local/bin:/usr/lib/openoffice:/share/bin:${PATH}:/bin:/sbin:/etc:/usr/etc:/usr/sbin:/usr/openwin/bin:/usr/ucb:/usr/ccs/bin:/apps/local/bin:/etc/sudocmd:/usr/sbin:/sbin:/usr/local/sbin:/opt/cxoffice/bin:${HOME}/.cargo/bin:${HOME}/go/bin/:${HOME}/.local/bin
		TPATH=$HOME/bin:$(for i in `echo $MYPATH | sed 's/:/ /g'`; do if [ -e $i ]; then echo $i; fi; done | sort -u | tr '\n' ':')
		PATH=${TPATH}

		MYLDLIBPATH=$LD_LIBRARY_PATH:/usr/local/lib:/share/lib:/opt/kde3/lib:/opt/qt3/lib
		TLD_LIBRARY_PATH=$(for i in `echo $MYLDLIBPATH | sed 's/:/ /g'`; do if [ -e $i ]; then echo $i; fi; done | sort -u | tr '\n' ':')
		LD_LIBRARY_PATH=${TLD_LIBRARY_PATH}
	
		unset MYLDLIBPATH TPATH TLD_LIBRARY_PATH
	else
		PATH=${HOME}/bin:${PATH}
	fi

	PATH=${PATH/%:/}

	SYSTEMD_PAGER="less"
	SYSTEMD_LESS="FRXMK"

	export USERNAME ENV PATH LD_LIBRARY_PATH PROMPT_COMMAND \
		PS1 EDITOR PAGER TERM ignoreeof MANPATH CLASSPATH \
		HISTFILE HISTCONTROL command_oriented_history LC_COLLATE \
		SYSTEMD_PAGER SYSTEMD_LESS

	##  cgroups  tty grouping for better CPU performance feel
	if [ -d /dev/cgroup/cpu/user ];
	then
	        mkdir -pm 0700 /dev/cgroup/cpu/user/$$ && \
	        	echo $$ > /dev/cgroup/cpu/user/$$/tasks
        fi


	if [ -z "${BASHALIASES}" ]
	then
		. ${HOME}/.bash_aliases
	fi

	# Client setup binaries
	if [ -n "${BASH}" -a -n "${BASH##*termux*}" ]
	then
		test -x ${HOME}/bin/fix-screens && ${HOME}/bin/fix-screens
		mesg n || true
	fi

	export BASHPROFILE

fi
# End of interactive

if [ -f ${HOME}/.profile_local ]; then
# Put local variable defines in here
	. ${HOME}/.profile_local
fi
