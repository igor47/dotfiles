# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# avoid infinite import loop
[ -n "$BASHRC_SOURCED" ] && return
export BASHRC_SOURCED=true

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

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
if [ -x /usr/bin/lesspipe ]
then
   export LESSOPEN='| /usr/bin/lesspipe %s'
   export LESSCLOSE='/usr/bin/lesspipe %s %s'
fi

#i got this stuff from https://gist.github.com/634750
# via http://nuts-and-bolts-of-cakephp.com/2010/11/27/show-git-branch-in-your-bash-prompt/

        RED="\[\033[0;31m\]"
      GREEN="\[\033[0;32m\]"
     YELLOW="\[\033[0;33m\]"
       BLUE="\[\033[0;34m\]"
     PURPLE="\[\033[0;35m\]"
       CYAN="\[\033[0;36m\]"
       GRAY="\[\033[0;37m\]"

   BOLD_RED="\[\033[1;31m\]"
 BOLD_GREEN="\[\033[1;32m\]"
BOLD_YELLOW="\[\033[1;33m\]"
  BOLD_BLUE="\[\033[1;34m\]"
BOLD_PURPLE="\[\033[1;35m\]"
  BOLD_CYAN="\[\033[1;36m\]"
  BOLD_GRAY="\[\033[1;37m\]"

 COLOR_NONE="\[\e[0m\]"

PROMPT_USER="${BOLD_GREEN}\u@\h${COLOR_NONE}"
PROMPT_PATH="${BLUE}\w${COLOR_NONE}"

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
   # if it's an xterm, set the window title
   case "$TERM" in
      xterm*|rxvt*)
         echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
         ;;
      *)
         ;;
   esac

   # discover git info
   git rev-parse --git-dir > /dev/null 2>&1
   if [ $? -eq 0 ]; then
     PROMPT_GIT=" ${GREEN}{$(parse_git_branch)}${COLOR_NONE}"
   else
     PROMPT_GIT=""
   fi

   # discover virtualenv info
   if [ ${VIRTUAL_ENV} ]; then
     envname=$(basename `echo ${VIRTUAL_ENV}`)
     PROMPT_VIRTUALENV=" ${CYAN}[${envname}]${COLOR_NONE}"
   else
     PROMPT_VIRTUALENV=""
   fi

   # assemble the prompt from pieces
   PS1="${PROMPT_USER}:${PROMPT_PATH}${PROMPT_VIRTUALENV}${PROMPT_GIT} \$ "
}

# install the prompt function
PROMPT_COMMAND=prompt_func

# If this is an xterm set the title to user@host:dir

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# rtssh command
# see: https://pempek.net/articles/2013/04/24/vpn-less-persistent-ssh-sessions/
function rtssh {
  case "$2" in
    "") autossh -M 0 $1 -t "if tmux -qu has; then tmux -qu attach; else EDITOR=vim tmux -qu new; fi";;
    *) autossh -M 0 $1 -t "if tmux -qu has -t $2; then tmux -qu attach -t $2; else EDITOR=vim tmux -qu new -s $2; fi";;
  esac
}

# Some aliases we want everywhere
alias pj='python -mjson.tool'
alias ll='ls -l'
alias lsd='ls -tr'
#alias la='ls -A'
#alias l='ls -CF'

alias ren='qmv --format=do'
alias grep='grep --color=auto'
alias totp='oathtool -b -w 2 --totp -'

# git aliases
# Determine if the main Git branch is "master" or "main". (Assumes it's one of those two.)
# https://stackoverflow.com/a/66622363/6962
function git_main_branch {
    [ -f "$(git rev-parse --show-toplevel)/.git/refs/heads/master" ] && echo "master" || echo "main"
}

alias gs='git status'
alias gdiff='git diff'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gpr='git pull --rebase'
alias gpo='git push origin'
alias gpom='git push origin `git_main_branch`'
alias gri='git rebase --interactive --autosquash'
alias grom='git checkout `git_main_branch` && gpr && git checkout - && git rebase `git_main_branch`'
alias gb="git checkout \$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ | fzf)"
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

# show last 5 downloads quickly
alias l5d='ls -t ~/Downloads | head -n 5'
alias l5s='ls -t ~/Sync | head -n 5'

export EDITOR='vim'
export LESS='--RAW-CONTROL-CHARS --tabs=8 -R'

# gopath
export GOPATH=~/.go

# asdf
# this is installed like so:
#   git clone https://github.com/asdf-vm/asdf.git ~/repos/asdf
#   cd ~/repos/asdf && git checkout v0.7.8 && cd -
# we require direnv:
#   asdf plugin add direnv
#   asdf install direnv 2.20.0
#   asdf global direnv 2.20.0
# if [ -d "$HOME/repos/asdf" ]
# then
#   #. ${HOME}/repos/asdf/asdf.sh
#   # In order to bypass asdf shims. We *only* add the `ASDF_DIR/bin`
#   # directory to PATH, since we still want to use `asdf` but not its shims.
#   export PATH="$HOME/repos/asdf/bin:$PATH"
# 
#   # A shortcut for asdf managed direnv.
#   direnv() { asdf exec direnv "$@"; }
# 
#   # Hook direnv into your shell.
#   eval "$(direnv hook bash)"
# 
#   # add asdf bash completions
#   . ${HOME}/repos/asdf/completions/asdf.bash
# 
#   # add asdf source (created by `asdf direnv setup`)
#   source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/bashrc"
# fi

# mise
# https://mise.jdx.dev/installing-mise.html#bash
if command -v mise > /dev/null; then
    eval "$(mise activate bash)"
fi

# fzf -- where does it come from?
# arch:
if [ -d "/usr/share/fzf" ]
then
    source /usr/share/fzf/key-bindings.bash
    source /usr/share/fzf/completion.bash
fi

# blesh (if installed)
#if [ -d "/usr/share/blesh" ]
#then
#  [[ $- == *i* ]] && source /usr/share/blesh/ble.sh
#fi

# zoxide for rapid directory navigation
if command -v zoxide > /dev/null; then
  eval "$(zoxide init bash)"
fi

# bash preexec (for atuin)
[[ -f /usr/share/bash-preexec/bash-preexec.sh ]] && source /usr/share/bash-preexec/bash-preexec.sh

# atuin for history management
if command -v atuin > /dev/null; then
  eval "$(atuin init bash)"
fi

# pipx should just use my `bin` directory
export PIPX_BIN_DIR=${HOME}/bin

# source .bash_profile for any machine-local settings
[ -f ${HOME}/.bash_profile ] && source ${HOME}/.bash_profile

# my bin always goes first (so this line always goes last)
export PATH=${HOME}/bin:$PATH

# allow resourcing bashrc
unset BASHRC_SOURCED
