#------------------------------------------------------------------------------
# Global .bashrc.
#------------------------------------------------------------------------------

source ~/.common.sh

# assume bash
SHELL=bash

# .bashrc
export TERM=xterm-256color
ssh-add &>/dev/null

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

shopt -s checkwinsize

# Support unicode by default.
export LANG=en_US.UTF-8

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
export PROMPT_COMMAND='sep'
export PS1='$(parse_git_branch)'
if [[ $TERM == "putty-256color" || $TERM == "xterm-256color" ]]
then
  export PS1='\[$(set_rand_color)\]\t '$PS1'[\W] ~> '
else
  export PS1='\t '$PS1'[\W] {$?} ~> '
fi

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


# Source machine-local definitions if available.
if [ -f ~/.bashrc_local ]; then
  . ~/.bashrc_local
fi
