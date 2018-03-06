# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# source global stuff if it's available on the system
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

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
export HISTSIZE=1000
export HISTNAME="default"

# we're ignoring:
# - duplicates
# - any command starting with a space
# - simple invocations of ls
# - fg or bg
# - exit
export HISTIGNORE="&:[ 	]*:ls:[bf]g:exit"

#use autoresume job control -- just type a substring of a previous job
#export auto_resume=substring

#append to the history file, dont overwrite
shopt -s histappend

# prepare to save multiple histories depending on an environment variable
function save_history() {
   # if we've just exported a new HISTNAME, start using that history file
   if [ "$HISTNAME" != "$CUR_HISTNAME" ]; then
      echo "Updating history file..."
      if [ "$HISTNAME" == 'default' ]; then
         export HISTFILE=~/.bash_history
         history -c
         history -r
      else
         if [ ! -e ~/.bash_history_files ]; then
            mkdir ~/.bash_history_files
         fi

         history -a  # append current lines to the previous history list
         history -c  # clear the current history
         export HISTFILE=~/.bash_history_files/"$HISTNAME"
         [ ! -e "$HISTFILE" ] && touch "$HISTFILE"
         history -r  # read the new history file into the current history
         echo "Switched to new history file $HISTFILE"
      fi

      export CUR_HISTNAME="$HISTNAME"

   # for non-default histories, keep histories in sync
   elif [ "$CUR_HISTNAME" != 'default' ]; then
      # put SOMETHING into the history file if there's nothing there
      # i couldn't find any other way to get this to work. frustrating!
      if [ $(stat -f '%z' "$HISTFILE") -eq 0 ]; then
         echo "Doing initial save of new history file $HISTFILE"
         history -w
      fi

      history -a
      history -n
   fi
}

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
   branch_pattern="On branch ([^${IFS}]*)"
   detached_branch_pattern="HEAD detached at ([^${IFS}]*)"
   mid_rebase_pattern="You are currently rebasing branch '([^${IFS}]*)' on"
   remote_pattern="Your branch is (.*) of"
   diverge_pattern="Your branch and (.*) have diverged"
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
      branch="${YELLOW}${BASH_REMATCH[1]} DETACHED"
   elif [[ ${git_status} =~ ${mid_rebase_pattern} ]]; then
      branch="${YELLOW}${BASH_REMATCH[1]} REBASE"
   fi

   if [[ ${#state} -gt "0" || ${#remote} -gt "0" ]]; then
      s=" "
   fi
 
   echo "${branch}${s}${remote}${state}"
}

function prompt_func() {
   # save the history after every command
   save_history

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
alias lsd='ls -tr'
#alias la='ls -A'
#alias l='ls -CF'

alias ren='qmv --format=do'
alias grep='grep --color=auto'

# git aliases
alias gs='git status'
alias gdiff='git diff'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gpr='git pull --rebase'
alias gpo='git push origin'
alias gpom='git push origin master'
alias gri='git rebase --interactive --autosquash'
alias cclean='cbranch=`git rev-parse --abbrev-ref HEAD`; git checkout production && git pull --rebase && git branch -d $cbranch'

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

# gopath
export GOPATH=~/.go

# pyenv
export PYENV_ROOT="$HOME/repos/pyenv"
export PATH=$PYENV_ROOT/bin:$PATH
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if command -v pyenv 1>/dev/null 2>&1
then
  echo 'pyenv init'
  eval "$(pyenv init -)"
fi

# my bin always goes first
export PATH=~/bin:$PATH
