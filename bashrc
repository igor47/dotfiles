# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# always use the 256-color version of xterm if xterm is the termtype
if [ "x$TERM" = "xxterm" ]
then
   export TERM="xterm-256color"
fi

# source the color list
if [ -f ~/.bash_colors ]; then
    . ~/.bash_colors
fi

# don't put duplicate lines in the history. See bash(1) for more options
#export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# we're ignoring:
# - duplicates
# - any command starting with a space
# - simple invocations of ls
# - fg or bg
# - exit
export HISTIGNORE="&:[ 	]*:ls:[bf]g:exit"

#use autoresume job control -- just type a substring of a previous job
export auto_resume=substring

#save history from multiple shells
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
if [ -x /usr/bin/lesspipe ]
then
   export LESSOPEN='| /usr/bin/lesspipe %s'
   export LESSCLOSE='/usr/bin/lesspipe %s %s'
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#xterm-color)
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#    ;;
#*)
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#    ;;
#esac

# Comment in the above and uncomment this below for a color prompt
#PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ "

#i got this stuff from https://gist.github.com/634750
# via http://nuts-and-bolts-of-cakephp.com/2010/11/27/show-git-branch-in-your-bash-prompt/

        RED="\[\033[0;31m\]"
     YELLOW="\[\033[0;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[0;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"

#PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ "
PROMPT_CHROOT="${debian_chroot:+($debian_chroot)}"
PROMPT_USER="${LIGHT_GREEN}\u@\h${COLOR_NONE}"
PROMPT_PATH="${BLUE}\w${COLOR_NONE}"
PS1="${PROMPT_CHROOT}${PROMPT_USER}:${PROMPT_PATH} \$ "

function parse_git_branch {
   git rev-parse --git-dir &> /dev/null
   git_status="$(git status 2> /dev/null)"
   branch_pattern="^# On branch ([^${IFS}]*)"
   detached_branch_pattern="# Not currently on any branch"
   remote_pattern="# Your branch is (.*) of"
   diverge_pattern="# Your branch and (.*) have diverged"
   if [[ ${git_status}} =~ "Changed but not updated" ]]; then
      state="${RED}⚡"
   fi
 
   # add an else if or two here if you want to get more specific
   if [[ ${git_status} =~ ${remote_pattern} ]]; then
      if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
         remote="${YELLOW}↑"
      else
         remote="${YELLOW}↓"
      fi
   fi
 
   if [[ ${git_status} =~ ${diverge_pattern} ]]; then
      remote="${YELLOW}↕"
   fi
   if [[ ${git_status} =~ ${branch_pattern} ]]; then
      branch=${BASH_REMATCH[1]}
   elif [[ ${git_status} =~ ${detached_branch_pattern} ]]; then
      branch="${YELLOW}NO BRANCH"
   fi
 
   if [[ ${#state} -gt "0" || ${#remote} -gt "0" ]]; then
      s=" "
   fi
 
   echo "${branch}${s}${remote}${state}"
}

function prompt_func() {
   # if it's an xterm, set the window title
   case "$TERM" in
      xterm*|rxvt*)
         echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
         ;;
      *)
         ;;
   esac

   git rev-parse --git-dir > /dev/null 2>&1
   if [ $? -eq 0 ]; then
      prompt="${PROMPT_USER}:${PROMPT_PATH} ${GREEN}{$(parse_git_branch)}${COLOR_NONE}"
      PS1="${prompt} \$ "
   else
      PS1=$PSAVE
   fi
}

# install the prompt function
export PSAVE=$PS1
PROMPT_COMMAND=prompt_func

# If this is an xterm set the title to user@host:dir

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Some aliases we want everywhere
alias pj='python -mjson.tool'
alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# git aliases
alias gs='git status'
alias gdiff='git diff'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gpr='git pull --rebase'
alias gpo='git push origin'
alias gpom='git push origin master'

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    # if dircolors exists, assume we're on GNU
    if [ `which dircolors` ]; then
        eval "`dircolors -b`"
        alias ls='ls --color=auto'
        #alias dir='ls --color=auto --format=vertical'
        #alias vdir='ls --color=auto --format=long'

    #otherwise, assume we're on osx or bsd or something
    else
        alias ls='ls -G'
    fi
fi

export EDITOR='vim'
export LESS='--RAW-CONTROL-CHARS --tabs=8 -r'
export GREP_OPTIONS='--color=auto'

# custom path vars
export PATH=~/bin:$PATH

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#fi
