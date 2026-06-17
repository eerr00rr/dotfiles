# Hyprland configs

This directory keeps both the legacy Hyprland config and the Hyprland 0.55+ Lua config.

## Files

- `hyprland.conf` — legacy Hyprland / hyprlang config. Kept unchanged for older Hyprland versions.
- `hyprland.lua` — Hyprland 0.55+ Lua config. This mirrors the old config using the new Lua API.
- `hypridle.conf` — hypridle config. Still uses hyprlang-style syntax in current Hypr ecosystem tools.
- `hyprlock.conf` — hyprlock config. Still uses hyprlang-style syntax in current Hypr ecosystem tools.

## Hyprland 0.55+

Hyprland 0.55 deprecated `hyprland.conf` in favor of:

```text
~/.config/hypr/hyprland.lua
```

The installer links this whole directory to `~/.config/hypr`, so Hyprland 0.55+ should pick up `hyprland.lua` automatically.

If you need to start it manually with the new file:

```bash
Hyprland --config ~/.config/hypr/hyprland.lua
```

## Notes

- The old `hyprland.conf` is intentionally not deleted.
- The new Lua file uses `hyprpolkitagent` first, with fallbacks for older polkit agents.
- The wallpaper command prefers `swww` and falls back to `swaybg` if available.
