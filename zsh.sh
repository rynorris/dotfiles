#!/bin/zsh

# Installs dependencies specific to zsh
set -e

exists() {
    # Check PATH first.
    if (whence $1 2>&1 > /dev/null)
    then
        echo "$1 exists on PATH"
        return 0
    fi

    # Then check if it's a file.
    if [[ -f $1 ]]
    then
        echo "$1 exists in filesystem"
        return 0
    fi

    # Otherwise doesn't exist.
    return 1
}

ensure() {
    local name=$1
    local file=$2
    shift 2
    if exists $file
    then
        echo "$name already installed"
    else
        echo "Installing $name..."
        $*
    fi
}

ensure "Oh-my-zsh" "$ZSH/oh-my-zsh.sh" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
