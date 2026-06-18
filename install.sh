#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-installer"
NORDIC_THEME_REPO="https://github.com/EliverLara/Nordic.git"
NORDZY_ICON_REPO="https://github.com/alvatip/Nordzy-icon.git"
MODE="ask"
INSTALL_PACKAGES=1
ENABLE_BACKUP_TIMER=0
ASSUME_YES=0

log() { printf '\033[1;34m[info]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --terminal        Install terminal/server setup only
  --desktop         Install terminal setup plus desktop/Hyprland setup
  --no-packages     Only link/copy dotfiles; do not install OS packages
  --enable-backup   Enable the user restic backup timer if backup/env exists
  -y, --yes         Non-interactive yes for package installation prompts
  -h, --help        Show this help

Without --terminal or --desktop, the script asks which profile to install.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --terminal) MODE="terminal" ;;
    --desktop) MODE="desktop" ;;
    --no-packages) INSTALL_PACKAGES=0 ;;
    --enable-backup) ENABLE_BACKUP_TIMER=1 ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

ask_mode() {
  if [[ "$MODE" != "ask" ]]; then return; fi
  printf 'Install profile:\n'
  printf '  1) Terminal/server only (zsh, nvim, tmux, CLI tools)\n'
  printf '  2) Desktop as well (Hyprland, Waybar, Kitty, fonts, theme, icons)\n'
  while true; do
    read -r -p 'Choose 1 or 2 [1]: ' choice
    choice="${choice:-1}"
    case "$choice" in
      1) MODE="terminal"; break ;;
      2) MODE="desktop"; break ;;
      *) warn "Please enter 1 or 2." ;;
    esac
  done
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

install_packages() {
  [[ "$INSTALL_PACKAGES" -eq 1 ]] || { log "Skipping package installation (--no-packages)."; return; }

  local terminal_pkgs desktop_pkgs pkgs installer update_cmd install_cmd yesflag
  terminal_pkgs=(git curl zsh neovim tmux fzf ripgrep unzip tar less python3 nodejs npm restic)
  desktop_pkgs=(hyprland waybar kitty wofi wlogout hyprlock hypridle swaybg swaync grim slurp wl-clipboard brightnessctl playerctl dolphin bluez blueman)

  if has_cmd dnf; then
    installer="dnf"
    terminal_pkgs+=(fd-find util-linux-user)
    desktop_pkgs+=(network-manager-applet)
    if [[ "$MODE" == "desktop" ]]; then
      if ! dnf copr --help >/dev/null 2>&1; then
        log "Installing dnf COPR plugin..."
        sudo dnf install -y dnf-plugins-core
      fi
      log "Enabling lionheartp/Hyprland COPR repository for Hyprland packages..."
      sudo dnf copr enable lionheartp/Hyprland -y
    fi
    install_cmd="sudo dnf install"
    yesflag="-y"
  elif has_cmd apt-get; then
    installer="apt"
    terminal_pkgs+=(fd-find)
    desktop_pkgs+=(network-manager-gnome policykit-1-gnome)
    install_cmd="sudo apt-get install"
    yesflag="-y"
    log "Updating apt package lists..."
    sudo apt-get update
  elif has_cmd pacman; then
    installer="pacman"
    terminal_pkgs+=(fd)
    desktop_pkgs+=(network-manager-applet)
    install_cmd="sudo pacman -S --needed"
    yesflag="--noconfirm"
  else
    warn "No supported package manager found (dnf, apt-get, pacman). Install dependencies manually."
    return
  fi

  pkgs=("${terminal_pkgs[@]}")
  if [[ "$MODE" == "desktop" ]]; then
    pkgs+=("${desktop_pkgs[@]}")
  fi

  log "Detected package manager: $installer"
  log "Packages to install: ${pkgs[*]}"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    # shellcheck disable=SC2086
    $install_cmd $yesflag "${pkgs[@]}"
  else
    # shellcheck disable=SC2086
    $install_cmd "${pkgs[@]}"
  fi
}

backup_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local ts backup
    ts="$(date +%Y%m%d-%H%M%S)"
    backup="${path}.bak-${ts}"
    warn "Backing up existing $path to $backup"
    mv "$path" "$backup"
  fi
}

link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log "Already linked: $dest -> $src"
    return
  fi
  backup_path "$dest"
  ln -s "$src" "$dest"
  log "Linked: $dest -> $src"
}

link_dir() {
  link_file "$1" "$2"
}

clone_or_update() {
  local repo="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [[ -d "$dest/.git" ]]; then
    log "Updating $(basename "$dest")..."
    git -C "$dest" pull --ff-only
  elif [[ -e "$dest" ]]; then
    warn "$dest exists but is not a git repo; backing it up before cloning."
    backup_path "$dest"
    git clone --depth=1 "$repo" "$dest"
  else
    log "Downloading $repo..."
    git clone --depth=1 "$repo" "$dest"
  fi
}

install_downloaded_desktop_assets() {
  local theme_cache="$CACHE_DIR/Nordic"
  local icons_cache="$CACHE_DIR/Nordzy-icon"

  clone_or_update "$NORDIC_THEME_REPO" "$theme_cache"
  clone_or_update "$NORDZY_ICON_REPO" "$icons_cache"

  # nwg-look and GTK tools commonly scan ~/.local/share/themes; some older
  # GTK tooling also scans ~/.themes. Link both so the theme is visible broadly.
  link_dir "$theme_cache" "$HOME/.local/share/themes/Nordic"
  link_dir "$theme_cache" "$HOME/.themes/Nordic"

  if [[ -d "$icons_cache/src" ]]; then
    link_dir "$icons_cache/src" "$HOME/.local/share/icons/Nordzy"
  else
    warn "Downloaded Nordzy icon repo did not contain src/; linking repo root instead."
    link_dir "$icons_cache" "$HOME/.local/share/icons/Nordzy"
  fi

  has_cmd gtk-update-icon-cache && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/Nordzy" >/dev/null 2>&1 || true
  log "Desktop theme/icon assets are managed in $CACHE_DIR, not in this dotfiles repo."
}

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    log "Oh My Zsh already exists."
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$custom/themes" "$custom/plugins"

  if [[ ! -d "$custom/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
  else
    log "powerlevel10k already exists."
  fi

  if [[ ! -d "$custom/plugins/zsh-autosuggestions" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
  else
    log "zsh-autosuggestions already exists."
  fi

  if [[ ! -d "$custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting"
  else
    log "zsh-syntax-highlighting already exists."
  fi
}

install_tpm() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    mkdir -p "$(dirname "$tpm_dir")"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    log "TPM already exists."
  fi

  if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
    log "Installing tmux plugins automatically through TPM..."
    "$tpm_dir/bin/install_plugins"
  else
    warn "TPM install script not found at $tpm_dir/bin/install_plugins"
    warn "Open tmux and press prefix + I to install plugins manually."
  fi
}

link_terminal_configs() {
  link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/p10k.zsh" "$HOME/.p10k.zsh"
  link_dir "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_dir "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
}

link_desktop_configs() {
  link_dir "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
  link_dir "$DOTFILES_DIR/hypr" "$HOME/.config/hypr"
  link_dir "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"
  link_dir "$DOTFILES_DIR/wlogout" "$HOME/.config/wlogout"

  if [[ -d "$DOTFILES_DIR/Hack-Nerd-Font" ]]; then
    mkdir -p "$HOME/.local/share/fonts/Hack-Nerd-Font"
    cp -a "$DOTFILES_DIR/Hack-Nerd-Font"/*.ttf "$HOME/.local/share/fonts/Hack-Nerd-Font/" 2>/dev/null || true
    has_cmd fc-cache && fc-cache -f "$HOME/.local/share/fonts" || true
    log "Installed Hack Nerd Font to ~/.local/share/fonts/Hack-Nerd-Font"
  fi

  install_downloaded_desktop_assets
}

install_backup_units() {
  local systemd_user="$HOME/.config/systemd/user"
  mkdir -p "$systemd_user"
  link_file "$DOTFILES_DIR/backup/restic-backup.service" "$systemd_user/restic-backup.service"
  link_file "$DOTFILES_DIR/backup/restic-backup.timer" "$systemd_user/restic-backup.timer"
  systemctl --user daemon-reload || warn "Could not reload user systemd. Is systemd --user running?"

  if [[ "$ENABLE_BACKUP_TIMER" -eq 1 ]]; then
    if [[ -f "$DOTFILES_DIR/backup/env" ]]; then
      systemctl --user enable --now restic-backup.timer
      log "Enabled restic-backup.timer"
    else
      warn "Not enabling backup timer because backup/env is missing. Create it first with RESTIC_REPOSITORY and RESTIC_PASSWORD."
    fi
  else
    warn "Backup systemd units installed but timer not enabled. Use --enable-backup after configuring backup/env."
  fi
}

set_zsh_as_login_shell() {
  if ! has_cmd zsh; then
    warn "zsh is not installed or not in PATH; cannot change login shell."
    return
  fi

  local zsh_path current_shell target_user
  zsh_path="$(command -v zsh)"
  target_user="${SUDO_USER:-${USER:-$(id -un)}}"
  current_shell="$(getent passwd "$target_user" | cut -d: -f7 || true)"

  if [[ "$current_shell" == "$zsh_path" ]]; then
    log "Login shell for $target_user is already zsh ($zsh_path)."
    return
  fi

  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    log "Adding $zsh_path to /etc/shells."
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  log "Changing login shell for $target_user to zsh ($zsh_path)."
  if has_cmd chsh; then
    sudo chsh -s "$zsh_path" "$target_user" || warn "Could not change shell with chsh. Try manually: chsh -s $zsh_path"
  else
    sudo usermod -s "$zsh_path" "$target_user" || warn "Could not change shell with usermod. Try manually: sudo usermod -s $zsh_path $target_user"
  fi
}

main() {
  ask_mode
  log "Dotfiles directory: $DOTFILES_DIR"
  log "Selected profile: $MODE"

  install_packages
  install_oh_my_zsh
  link_terminal_configs
  install_tpm

  if [[ "$MODE" == "desktop" ]]; then
    link_desktop_configs
    install_backup_units
  fi

  set_zsh_as_login_shell

  log "Install complete. Restart your shell, or log out/in for the new zsh login shell and desktop changes to take effect."
}

main "$@"
