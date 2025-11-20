# dotfiles

## Installation

### Download and change the necessary packages:
Necessarry packages:
- terminal:
  - `kitty zsh tmux git lazygit`
  - `sudo chsh -s $(which zsh) $USER`
  - `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
  - `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"`
  - `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`

- neovim:
  - `nvim make gcc unzip ripgrep fd-find`
- nerdfont:
`sudo cp -r dotfiles/Hack-Nerd-Font /usr/share/fonts/ && fc-cache -f -v`
- hyprland

### Linking
Make symbolic links for the dotfiles:
- `ln -s ~/dotfiles/.zsh ~/`
- `ln -s ~/dotfiles/.p10k.zsh ~/`
- `ln -s ~/dotfiles/tmux ~/.config`
- `ln -s ~/dotfiles/kitty ~/.config`
- `ln -s ~/dotfiles/nvim ~/.config`
> [!NOTE]
> For tmux kill all sessions first so that tmux.conf gets loaded
