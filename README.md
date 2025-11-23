# dotfiles

## Installation

### Make symbolic links for the dotfiles
```
ln -s ~/dotfiles/.zshrc ~/
ln -s ~/dotfiles/.p10k.zsh ~/
ln -s ~/dotfiles/tmux ~/.config
ln -s ~/dotfiles/kitty ~/.config
ln -s ~/dotfiles/nvim ~/.config
ln -s ~/dotfiles/hypr ~/.config
ln -s ~/dotfiles/waybar ~/.config
```
> [!NOTE]
> For tmux kill all sessions first so that tmux.conf gets loaded

### Necessarry packages
```
kitty zsh tmux git lazygit nvim make gcc unzip ripgrep fd-find
```
### Extra config
- terminal:
```
sudo chsh -s $(which zsh) $USER
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
- nerdfont:
```
sudo cp -r dotfiles/Hack-Nerd-Font /usr/share/fonts/ && fc-cache -f -v
```
### Hyprland Packages
```
hyprland hyprpaper waybar power-profiles-daemon
```
> [~NOTE]
> In fedora do `sudo dnf copr enable solopasha/hyprland` before installing the packages
> Also fedora has Tuned instead of `power-profiles-daemon` so you won't need to install it

