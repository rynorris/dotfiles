# Installs dependencies for MacOS systems.

has_executable() {
  hash $1
}

ensure() {
  local name=$1
  local executable=$2
  shift 2
  if has_executable $executable
  then
    echo "$name already installed"
  else
    echo "Installing $name..."
    $*
  fi
}

ensure "Homebrew" "brew" /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
ensure "Coreutils" "greadlink" brew install coreutils
ensure "CMake" "cmake" brew install cmake
