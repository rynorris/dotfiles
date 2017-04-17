set -e

###############################################################################
# Installs these dotfiles on a system.
###############################################################################
platform=$(uname)

# Install dependencies
case $platform
  Darwin)
    echo "Installing dependencies for MacOS (Darwin)"
    ./darwin.sh
    ;;
esac

# Readlink command is different on MacOS.  (needs coreutils installed)
if [[ $platform == Darwin ]]
then
  echo "System is running MacOS (Darwin).  Using greadlink to resolve filenames."
  READLINK=greadlink
else
  echo "System is running $platform.  Using readlink to resolve filenames."
  READLINK=readlink
fi

DOTFILE_DIR=$(dirname $($READLINK -f ${BASH_SOURCE}))

###############################################################################
# Installs a dotfile.
# If one already exists on the system, moves it to <name>_local.
# If <name>_local already exists, bails out.
#   $1 = dotfile
#   $2 = target location
#   $3 = if "noclobber", do nothing if target already exists.
###############################################################################
install() {
  local dotfile="${DOTFILE_DIR}/$1"
  local target="$2"
  local noclobber="$3"

  # If noclobber is set, bail if target exists in any form.
  if [[ -e $target && -n $noclobber ]]
  then
    echo "$target exists.  Leaving alone."
    return 0
  fi

  # If target is a symbolic link, just remove it.  Notify.
  if [[ -L $target ]]
  then
    echo "Removing symbolic link $target"
    rm "$target"
  fi

  # If target is a file, move it to ${target}_backup unless that exists.
  if [[ -f $target ]]
  then
    echo "Moving $target to ${target}_backup"
    if [[ -e ${target}_backup ]]
    then
      echo "${target}_backup exists.  Bailing."
      return 1
    fi

    mv "$target" "${target}_backup"
  fi

  # Now we're good to create the symbolic link to the dotfile here.
  echo "Creating symbolic link: $target => $dotfile"
  ln -s "$dotfile" "$target"
}

# Actually install the dotfiles.
install vimrc ~/.vimrc
install vimrc_local ~/.vimrc_local noclobber
install bashrc ~/.bashrc
install gitconfig ~/.gitconfig

# Vim setup.
./vim.sh
