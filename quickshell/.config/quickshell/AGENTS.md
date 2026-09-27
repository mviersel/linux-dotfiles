# Quickshell configuration guide

This directory is the active Quickshell configuration; `~/.config/quickshell/shell.qml` resolves here.

## Layout

- `shell.qml` owns global theme colors, polling, screen panels, and the media overlay.
- `bar/TopBar.qml` defines the top bar and composes its controls.
- Reusable bar controls live in `bar/` as separate QML files.

## UI conventions

- Use the theme properties from the passed `shell`/`rootShell` object instead of hard-coded colors.
- Match the existing compact styling: 6–8px radii, one-pixel `tooltipBorder` borders, and `bgHover` for hover states.
- Anchor popup menus below their triggering chip (use the chip's bottom edge and downward gravity); they must not overlap the chip. Provide a click-outside dismissal surface when a popup should behave as a menu.
- Keep `TopBar.qml` focused on composition; put non-trivial popups in their own file.

## Audio mixer

- The master chip uses `wpctl` and controls `@DEFAULT_AUDIO_SINK@`.
- `bar/MixerMenu.qml` gets active application streams from `pactl -f json list sink-inputs` and controls them through `pactl`.
- App stream IDs are ephemeral. Never persist them; rediscover them when refreshing the popup.
- Mixer groups are intentionally defined by application metadata:
  - Spotify: names containing `spotify`
  - Browsers: names containing `helium`, `zen`, `floorp`, or `brave`
  - Discord: names containing `discord`
- Applying a group volume or mute change must apply to every active stream in that group.

## Validation

After QML edits, verify syntax/loading without disturbing the running configuration:

```sh
timeout 5 quickshell -n -p /home/mrtn/linux-dotfiles/quickshell/.config/quickshell --no-color
```

The expected result contains `Configuration Loaded` and exits due to the timeout.
