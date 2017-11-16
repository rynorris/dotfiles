#------------------------------------------------------------------------------
# Global .bashrc.
#------------------------------------------------------------------------------

# Find out our OS so we can use it later if necessary.
OS=$(uname)

# .bashrc
export TERM=xterm-256color
ssh-add &>/dev/null

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

shopt -s checkwinsize

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
if [[ $(type -P gvm) ]]
then
  latest_go_version=$(gvm list | grep "go.*" | tail -n1)
  gvm use $latest_go_version
fi
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

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
export PROMPT_COMMAND='sep'

# Git status
parse_git_dirty() {
if [[ -n $(git status --porcelain 2> /dev/null) ]]; then echo "*"; fi
}

parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)] /"
}

export PS1='$(parse_git_branch)'

# Get a random color which is good on a dark background.
get_rand_color() {
  num='0'
  invalid_nums='0 4 16 17 18 19 20 21 22 25 52 53 54 55 56 57 91 92 232 233 234 235 236 237 238 239 240'
  while [[ $invalid_nums =~ $num ]]
  do
    num=$((RANDOM%255+1))
  done
  echo $num
}

set_rand_color() {
  COL=$(get_rand_color)
  tput setaf ${COL}
  #echo "($COL)"
}

# Pretty colours
if [[ $TERM == "putty-256color" || $TERM == "xterm-256color" ]]
then
  export PS1='\[$(set_rand_color)\]\t '$PS1'[\W] ~> '
else
  export PS1='\t '$PS1'[\W] {$?} ~> '
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
