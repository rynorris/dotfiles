#------------------------------------------------------------------------------
# Global .bashrc.
#------------------------------------------------------------------------------

# Find out our OS so we can use it later if necessary.
OS=$(uname)
echo "Current OS: $OS"

# Find out which shell we are running.
if [ -n "$ZSH_VERSION" ]; then
    # assume Zsh
    SHELL=zsh
    autoload -U add-zsh-hook
    exists_on_path() {
        whence $1
    }
else
    # assume bash
    SHELL=bash
    exists_on_path() {
        type -P $1
    }
fi
echo "Current Shell: $SHELL"

# .bashrc
export TERM=xterm-256color
ssh-add &>/dev/null

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# This command is a bash-builtin and there is no equivalent in zsh.
# It attempts to fix line-wrapping when the window is resized.
if [[ $SHELL = bash ]]
then
    shopt -s checkwinsize
fi

# Support unicode by default.
export LANG=en_US.UTF-8

# Build config.
export MAKEFLAGS="-j 32"

# User specific aliases and functions
export UTIL_ROOT=$HOME/bin
export DIFFCMD=meld
export EDITOR=vim
export PATH=$UTIL_ROOT:$PATH:/usr/local/bin

#------------------------------------------------------------------------------
# Go config.
#------------------------------------------------------------------------------
[[ -s "/home/ryan/.gvm/scripts/gvm" ]] && source "/home/ryan/.gvm/scripts/gvm"
if [[ $(exists_on_path gvm) ]]
then
  latest_go_version=$(gvm list | grep "go.*" | tail -n1)
  gvm use $latest_go_version
fi
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

#------------------------------------------------------------------------------
# Rust config
#------------------------------------------------------------------------------
export PATH=$HOME/.cargo/bin:$PATH

#------------------------------------------------------------------------------
# Neovim
#------------------------------------------------------------------------------
export PATH=$HOME/neovim/bin:$PATH

#------------------------------------------------------------------------------
# Aliases
#------------------------------------------------------------------------------
alias cdv='cd ~/.vim'

alias evimrc='vim ~/.vimrc'
alias ebash='vim ~/.bashrc'

alias cleanlist="svn st | egrep '(^\?)' | sed 's/^... *//' | grep -v .git"
alias grep='grep -n --color'

alias hist='eval $(history | sed "s/ *[0-9]* *//" | sort -u | fzf)'
alias dbg='gdb -q -ex "python gdb.events.exited.connect(lambda x: gdb.execute(\"quit\"))" -ex run --args'

#------------------------------------------------------------------------------
# Function for removing a host from the ssh known_hosts file.
#------------------------------------------------------------------------------
rhost() {
  sed -i "/$1/d" ~/.ssh/known_hosts
}

#------------------------------------------------------------------------------
# Function for sshing into a box ignoring the fact that it's changed.
# Also automatically sets up passwordless access.
#------------------------------------------------------------------------------
connect()
{
  rhost $1
  echo "Attempting login without password."
  \ssh -q -oBatchMode=yes $1 echo
  if [[ $? -ne 0 ]]
  then
    echo "Server asked for password. Setting up passwordless access..."
    ssh-copy-id $1 2>/dev/null
  fi
  \ssh $1
}

#------------------------------------------------------------------------------
# Function for unpacking a .tar.gz archive into a directory.
#------------------------------------------------------------------------------
unpack()
{
  local archive=$1
  local directory=$2
  if [[ -z $directory ]]
  then
    directory=${archive%%.*}
  fi

  echo "Unpacking $archive --> $directory"
  mkdir -p "$directory"
  tar -xzf "$archive" -C "$directory" && rm $archive
}

#------------------------------------------------------------------------------
# Functions to mark and easily goto marked directories by name.
# ------------------------------------------------------------------------------
MARKED_DIR_FILE=~/.marked_dirs
touch $MARKED_DIR_FILE

mark()
{
  sed -i "/^$1/d" $MARKED_DIR_FILE
  echo $1 $PWD >> $MARKED_DIR_FILE
}

goto()
{
  local line=$(grep "^$1" $MARKED_DIR_FILE)
  local dir=${line##* }
  cd $dir
}

#------------------------------------------------------------------------------
# Pretty Prompt
#------------------------------------------------------------------------------
sep() {
  COLS=$(tput cols)

  x=0
  while (( $x < COLS ))
  do
    echo -ne '\xE2\x95\x90'
    x=$(( $x + 1 ))
  done
  echo
}

# Git status
parse_git_dirty() {
if [[ -n $(git status --porcelain 2> /dev/null) ]]; then echo "*"; fi
}

parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)] /"
}

# Get a random color which is good on a dark background.
get_rand_color() {
    local random=$1
    declare -a valid_colors=($(seq 13 15) $(seq 46 51) $(seq 82 87) $(seq 118 123) $(seq 154 159) $(seq 190 195) $(seq 226 231))
    local num_colors=${#valid_colors[@]}
    local choice_index=$((RANDOM % num_colors))
    echo ${valid_colors[choice_index]}
}

set_rand_color() {
    local COL=$(get_rand_color $RANDOM)
    tput setaf ${COL}
    #echo "($COL)"
}

# Set prompt.
# The way we do this has to differ between bash and zsh.
if [[ $SHELL = bash ]]
then
    export PROMPT_COMMAND='sep'
    export PS1='$(parse_git_branch)'
    if [[ $TERM == "putty-256color" || $TERM == "xterm-256color" ]]
    then
      export PS1='\[$(set_rand_color)\]\t '$PS1'[\W] ~> '
    else
      export PS1='\t '$PS1'[\W] {$?} ~> '
    fi
else
    configure_prompt() {
        local seed=$RANDOM
        local colour="$(get_rand_color $seed)"
        local current_time="$(date +%H:%M:%S)"
        local git_branch="$(parse_git_branch)"
        PS1="%F{$colour}${current_time} ${git_branch}[%~]~> "
    }

    add-zsh-hook precmd configure_prompt
    add-zsh-hook precmd sep
fi

# Use fzf if available.
if [[ -f ~/.fzf.bash ]]
then
  . ~/.fzf.bash

  # C-g to insert a modified file in a git repo.
  bind '"\C-g": " \C-u \C-a\C-k$(git diff master --name-only | fzf)\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er"'
fi

# Use bash completion if available.
if [[ $OS = Darwin ]]
then
  BASH_COMPLETION_FILE=$(brew --prefix)/etc/bash_completion
else
  BASH_COMPLETION_FILE=/etc/bash_completion
fi

if [[ -f $BASH_COMPLETION_FILE ]]
then
  . $BASH_COMPLETION_FILE
fi

# On MacOS, JAVA_HOME is not automatically set correctly.  Do this here.
if [[ $OS = Darwin ]]
then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Source machine-local definitions if available.
if [ -f ~/.bashrc_local ]; then
  . ~/.bashrc_local
fi
