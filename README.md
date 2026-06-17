# Dotfiles

Personal Linux dotfiles for a terminal/server setup and an optional Hyprland desktop setup.

## What is included

### Terminal/server profile

The terminal profile is safe for CLI-only machines and installs/links:

- `zsh/` → `~/.zshrc` and `~/.p10k.zsh`
- Oh My Zsh
- Powerlevel10k
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `nvim/` → `~/.config/nvim`
- `tmux/` → `~/.config/tmux`
- TPM (`tmux` plugin manager)
- Common CLI dependencies such as `git`, `curl`, `neovim`, `tmux`, `fzf`, `ripgrep`, `nodejs`, `npm`, and `restic`

### Desktop profile

The desktop profile includes everything from the terminal profile, plus:

- `hypr/` → `~/.config/hypr`
- `waybar/` → `~/.config/waybar`
- `kitty/` → `~/.config/kitty`
- `wlogout/` → `~/.config/wlogout`
- Hack Nerd Font copied to `~/.local/share/fonts/Hack-Nerd-Font` when the local font folder exists
- Nordic GTK theme downloaded from `https://github.com/EliverLara/Nordic.git`
- Nordzy icon theme downloaded from `https://github.com/alvatip/Nordzy-icon.git`
- Restic systemd user units linked to `~/.config/systemd/user/`
- Desktop dependencies such as `hyprland`, `waybar`, `kitty`, `wofi`, `wlogout`, `hyprlock`, `hypridle`, `swww`, `swaync`, `grim`, `slurp`, `wl-clipboard`, `brightnessctl`, and `playerctl`

Downloaded desktop assets are stored in:

```text
~/.cache/dotfiles-installer/Nordic
~/.cache/dotfiles-installer/Nordzy-icon
```

The installer then links it to both common GTK theme locations:

```text
~/.local/share/themes/Nordic
~/.themes/Nordic
```

The icons are linked to:

```text
~/.local/share/icons/Nordzy
```

This keeps the dotfiles repository small while still installing the full theme and icon set on desktop machines. If `nwg-look` does not show Nordic, rerun `./install.sh --desktop --no-packages` and restart `nwg-look`; it usually scans `~/.local/share/themes`.

## Quick start

Clone the repository, then run:

```bash
chmod +x install.sh
./install.sh
```

The installer asks whether to install:

1. **Terminal/server only** — best for servers or CLI-only machines.
2. **Desktop as well** — best for a full Hyprland workstation/laptop.

You can also skip the prompt:

```bash
./install.sh --terminal
./install.sh --desktop
```

If you already installed packages yourself and only want to link/copy config files and download assets:

```bash
./install.sh --terminal --no-packages
./install.sh --desktop --no-packages
```

For a mostly non-interactive package install:

```bash
./install.sh --desktop -y
```

## Backup/restic setup

The desktop profile links the systemd user units from `backup/`, but it does **not** enable the timer unless requested.

Create `backup/env` first:

```bash
RESTIC_REPOSITORY='your-repository'
RESTIC_PASSWORD='your-password'
```

Then run:

```bash
./install.sh --desktop --enable-backup
```

`backup/env` is intentionally ignored by git because it contains secrets.

## Notes after installation

- Restart your shell after running the installer.
- The installer automatically changes your login shell to zsh with `chsh` when zsh is installed; log out and back in for it to take effect.
- Open `tmux` and press `prefix + I` to install tmux plugins through TPM.
- For Hyprland changes, log out and back in.
- Re-running `./install.sh --desktop` updates the cached Nordic and Nordzy git repositories with `git pull --ff-only`.

## Supported package managers

`install.sh` currently knows how to install packages with:

- Fedora/RHEL: `dnf`
- Debian/Ubuntu: `apt-get`
- Arch Linux: `pacman`

Package names vary by distribution, especially for Hyprland-related packages. If a package is unavailable, install that dependency manually and rerun with `--no-packages`.

Fedora note: when using `dnf` for a desktop install, the installer enables the `lionheartp/Hyprland` COPR repository before package installation so Hyprland packages are available. The Fedora desktop package list uses `network-manager-applet` and intentionally does not install `power-profiles-daemon`, `polkit-gnome`, or `pulsemixer`.

## Making the repository smaller for GitHub

After removing the vendored `icons/` and `theme/` directories, the local dotfiles folder is about **42 MB**. The largest folders before this cleanup were:

- `icons/` — about **185 MB**
- `icons/.git/` alone — about **92 MB**
- `theme/` — about **29 MB**
- `Hack-Nerd-Font/` — about **31 MB**
- `backgrounds/` — about **5.8 MB**
- `tmux/plugins/` — about **4.4 MB**

`install.sh` now downloads `icons/` and `theme/` equivalents from upstream instead of requiring them in this repo. `.gitignore` also ignores `icons/` and `theme/` so they do not get committed again by accident.

The vendored copies have already been removed from this working tree, so this cleanup is already done here. If they come back later, remove them before pushing:

```bash
rm -rf icons theme
```

That removes roughly **214 MB** from the folder.

Other size recommendations:

1. **Do not commit downloaded plugin repositories.**
   - `tmux/plugins/` is ignored in `.gitignore`.
   - TPM can download plugins again after install.

2. **Avoid committing large binary assets unless you really need them.**
   - Fonts and wallpapers are now the main remaining size contributors.
   - Consider downloading the font in `install.sh` too, or keeping only the exact font variants you use.

3. **Use shallow clones for dependencies.**
   - The installer uses `git clone --depth=1` for Oh My Zsh plugins, TPM, Nordic, and Nordzy.

4. **Use Git LFS only if you intentionally want large binary assets in GitHub.**
   - This is useful for wallpapers/fonts, but it adds setup overhead and bandwidth limits.

## Repository layout

```text
.
├── backup/          # restic systemd user service/timer and env template location
├── backgrounds/     # wallpapers
├── Hack-Nerd-Font/  # local Nerd Font files, optional for desktop font install
├── hypr/            # Hyprland legacy .conf, Hyprland 0.55+ Lua, hypridle, hyprlock config
├── kitty/           # Kitty terminal config
├── nvim/            # Neovim config
├── tmux/            # tmux config and sessionizer
├── waybar/          # Waybar config/style/scripts
├── wlogout/         # logout menu config/style
└── zsh/             # zshrc and Powerlevel10k config
```

`icons/` and `theme/` are intentionally not part of the expected repository layout anymore. They are downloaded during desktop installation.
