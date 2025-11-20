# dotfiles

## Installation
----------
### Download the necessary packages:
Necessarry packages:
- terminal:
`kitty zsh tmux git lazygit`
- neovim:
`nvim make gcc unzip ripgrep fd-find`
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
