#------------------------------------------------------------------------------
# Shell unspecific configuration.
#------------------------------------------------------------------------------

# Find out our OS so we can use it later if necessary.
OS=$(uname)
echo "Current OS: $OS"

# Build config.
export MAKEFLAGS="-j 32"

# User specific aliases and functions
export UTIL_ROOT=$HOME/bin
export EDITOR=vim
export PATH=$UTIL_ROOT:$PATH:/usr/local/bin

# Rust config
export PATH=$HOME/.cargo/bin:$PATH

# On MacOS, JAVA_HOME is not automatically set correctly.  Do this here.
if [[ $OS = Darwin ]]
then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi
