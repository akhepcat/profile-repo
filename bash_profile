# First, just return if we're not interactive
[[ $- != *i* ]] && return

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# Validate and append directories to a PATH
path_add() {
	local myvar=$1
	local paths=$2
	local IFS=':'
	local temp_path=""

	for dir in $paths
	do
		if [[ -d "$dir" ]]
		then
			if [[ -z "$temp_path" ]]
			then
				temp_path="$dir"
			elif [[ ":$temp_path:" != *":$dir:"* ]]
			then
				temp_path="$temp_path:$dir"
			fi
		fi
	done
	printf -v "$myvar" "%s" "$temp_path"
}


# Non-interactive login session
TS=$(date +"%Y%m%d%H%S")
HOST=$(uname -n)
USERNAME=$(whoami)
USER=${USER:-$USERNAME}

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

	EDITOR="$(command -v joe || command -v vi)"

	if [ -n "$(command -v less)" ]
	then
		LESS="-EFXRfi"
		PAGER="$(command -v less) ${LESS}"
		# make less more friendly for non-text input files, see pygmentize(1) and  lesspipe(1)
		if [ -n "$(command -v pygmentize)" ]
		then
			LESSOPEN="|pygmentize -g %s"
			export LESSOPEN
		elif [ -n "$(command -v lesspipe)" ]
		then
			eval "$(lesspipe)"
		fi
		SYSTEMD_PAGER="$(command -v less)"
		SYSTEMD_LESS="${LESS}"
		export SYSTEMD_PAGER SYSTEMD_LESS
	else
		MORE="-e"
		PAGER="$(command -v more) ${MORE}"
	fi

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

	if [ -n "${BASH}" -a -n "${BASH##*termux*}" ]
	then
		MYPATH=/usr/local/bin:/usr/lib/openoffice:/share/bin:${PATH}:/bin:/sbin:/etc:/usr/etc:/usr/sbin:/usr/openwin/bin:/usr/ucb:/usr/ccs/bin:/apps/local/bin:/etc/sudocmd:/usr/sbin:/sbin:/usr/local/sbin:/opt/cxoffice/bin:${HOME}/.cargo/bin:${HOME}/go/bin/:${HOME}/.local/bin
		path_add PATH "${MYPATH}"

		MYLDLIBPATH=$LD_LIBRARY_PATH:/usr/local/lib:/share/lib:/opt/kde3/lib:/opt/qt3/lib
		path_add LD_LIBRARY_PATH "${MYLDLIBPATH}"
	
		TCLASSPATH=${HOME}/.java/jar:$CLASSPATH
		path_add CLASSPATH "${TCLASSPATH}"

		MYMANPATH=/usr/man:/usr/share/man:/usr/local/man:$MANPATH
		path_add MANPATH "${MYMANPATH}"

	else
		PATH=${HOME}/bin:${PATH}
	fi

	unset MYPATH
	unset MYLDLIBPATH
	unset TCLASSPATH
	unset MYMANPATH

	# remove any trailing ':'
	PATH=${PATH/%:/}
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH/%:/}
	CLASSPATH=${CLASSPATH/%:/}
	MANPATH=${MANPATH/%:/}


	export USERNAME ENV PATH LD_LIBRARY_PATH PROMPT_COMMAND \
		PS1 EDITOR MORE LESS PAGER TERM ignoreeof MANPATH CLASSPATH \
		HISTFILE HISTCONTROL command_oriented_history LC_COLLATE

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
		test -n "$(command -v mesg)" && mesg n
	fi

	export BASHPROFILE

fi
# End of interactive

if [ -f ${HOME}/.profile_local ]; then
# Put local variable defines in here
	. ${HOME}/.profile_local
fi

# support RUST
if [ -f "$HOME/.cargo/env" ] 
then
	. "$HOME/.cargo/env"
fi
