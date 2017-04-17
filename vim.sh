# Configure vim.

install_vim_plug() {
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_plugins() {
  vim -c PlugInstall!
}

install_vim_plug
install_plugins
