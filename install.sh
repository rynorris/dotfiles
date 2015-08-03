###############################################################################
# Installs these dotfiles on a system.
###############################################################################
DOTFILE_DIR=$(dirname $(readlink -f ${BASH_SOURCE}))

###############################################################################
# Installs a dotfile.
# If one already exists on the system, moves it to <name>_local.
# If <name>_local already exists, bails out.
#   $1 = dotfile
#   $2 = target location
###############################################################################
install() {
  local dotfile="${DOTFILE_DIR}/$1"
  local target="$2"

  # If target is a symbolic link, just remove it.  Notify.
  if [[ -L $target ]]
  then
    echo "Removing symbolic link $target"
    rm "$target"
  fi

  # If target is a file, move it to ${target}_local unless that exists.
  if [[ -f $target ]]
  then
    echo "Moving $target to ${target}_local"
    if [[ -e ${target}_local ]]
    then
      echo "${target}_local exists.  Bailing."
      return 1
    fi

    mv "$target" "${target}_local"
  fi

  # Now we're good to create the symbolic link to the dotfile here.
  echo "Creating symbolic link: $target => $dotfile"
  ln -s "$dotfile" "$target"
}

# Actually install the dotfiles.
install vimrc ~/.vimrc
install bashrc ~/.bashrc
