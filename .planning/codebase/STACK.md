# Technology Stack

**Analysis Date:** 2026-02-26

## Languages

**Primary:**
- Bash - Shell scripting for system utilities and scripts
- INI/TOML - Configuration files for polybar, X11 resources

**Secondary:**
- Text/Config - X resources, keybindings, window manager configs

## Runtime

**Environment:**
- Linux (Manjaro distribution)
- X11 (windowing system)
- systemd/udev (system/device management)

**Shell:**
- Bash (primary scripting runtime)
- Zsh (interactive shell with oh-my-zsh framework)
- sh (POSIX shell compatibility)

## Frameworks & Window Managers

**Primary:**
- i3wm - Tiling window manager (default)
  - Location: `~/.i3/config`
  - Modifier: Alt (Mod1)
  - Features: Pixel borders, i3-gaps support, smart gaps, scratchpad

**Secondary:**
- herbstluftwm - Manual tiling window manager (alternative)
  - Location: `~/.config/herbstluftwm/autostart`
  - Modifier: Super (Mod4)

## Desktop Components

**Status Bar:**
- Polybar 3.x
  - Config: `~/.config/polybar/config.ini`
  - Launch script: `~/.config/polybar/launch.sh`
  - Modules: i3 workspaces, media, weather, CPU/temp, memory, disk, network speed, PulseAudio, battery, date/time, system tray
  - Features: Multi-monitor support, IPC enabled, auto-reload, lock-file based concurrency control

**Compositor:**
- picom (modern X11 compositor)
  - Config: `~/.config/picom.conf`
  - Backend: GLX
  - Features: Shadows, blur (dual_kawase), rounded corners (8px), opacity, vsync, XSync
  - Excludes: Dock windows, fullscreen, polybar

**Notification Daemon:**
- dunst
  - Config: `~/.config/dunst/dunstrc`
  - Integration: Managed by polybar launch script

**Shell Configuration:**
- oh-my-zsh framework
  - Theme: jonathan
  - Plugins: git
  - Location: `~/.zshrc`

## Display & Appearance

**Fonts:**
- Noto Sans (text, polybar default size 10)
- Terminess Nerd Font Mono (icons, polybar size 15)
- URWGothic-Book (i3wm window titles, size 11)
- Fixed (XTerm default)

**Color Scheme:**
- Neon Cyber theme (custom dark cyberpunk palette)
  - Colors defined in: `~/.Xresources`, `~/.config/polybar/config.ini`, `~/.config/picom.conf`, `~/.i3/config`
  - Palette: Dark background (#0a0e14), cyan accents (#00e5ff), neon highlights (lime, pink, orange, blue)

**X11 Configuration:**
- DPI: 96
- Font rendering: Antialiasing enabled, hinting slight, LCD filter default
- Resources: `~/.Xresources`, `~/.Xmodmap`

## System Integration

**Session Management:**
- X session startup: `~/.xinitrc`
- Session: dbus-launch with i3wm (default) or alternative WM
- Display initialization: Automatic resolution detection via xrandr
- Screen lock: blurlock (XSecureLock based)

**Power Management:**
- Battery monitoring via sysfs (`/sys/class/power_supply/BAT0`)
- Power manager applet: xfce4-power-manager (systemtray)
- Screen lock timeout: xautolock (10 minutes)

## Hardware Abstraction

**Display Management:**
- xrandr (monitor detection, resolution, rotation, positioning)
- Udev integration: Hotplug detection for dock/display changes (`~/.i3/dock-setup.sh`)
- Multi-monitor support: 4 docking configurations + undocked mode

**Audio:**
- PulseAudio (sound server)
- pactl (volume control via keybinds)
- alsamixer (direct ALSA access)

**Input:**
- Keyboard: X11 keybind mapping (Xmodmap)
- Mouse: X11 focus/scroll handling

## Configuration Files

**Display & X11:**
- `~/.xinitrc` - X session startup
- `~/.Xresources` - Terminal colors, fonts, keybindings
- `~/.Xmodmap` - Keyboard remapping

**Shell:**
- `~/.zshrc` - Zsh config with oh-my-zsh, aliases
- `~/.bashrc` - Bash config, colors, aliases
- `~/.bash_profile` - Bash startup (sources bashrc)
- `~/.profile` - POSIX shell env vars (QT theme, EDITOR, BROWSER, Android SDK paths)

**Window Manager & Desktop:**
- `~/.i3/config` - i3wm configuration
- `~/.config/herbstluftwm/autostart` - herbstluftwm alternative config
- `~/.config/polybar/config.ini` - Polybar bar configuration
- `~/.config/picom.conf` - Compositor effects
- `~/.config/dunst/dunstrc` - Notification daemon

## Scripts & Utilities

**Polybar Modules:**
- `~/.config/polybar/scripts/weather.sh` - Weather via wttr.in API (10min cache)
- `~/.config/polybar/scripts/updates.sh` - Arch Linux update count (30min cache)
- `~/.config/polybar/scripts/battery.sh` - Detailed battery metrics from sysfs
- `~/.config/polybar/scripts/media.sh` - Media player info

**Desktop Utilities:**
- `~/.config/polybar/launch.sh` - Multi-monitor polybar launcher with lock-file concurrency
- `~/.i3/dock-setup.sh` - Auto-detect dock configuration and apply xrandr settings
- `~/.i3/chillsky-toggle.sh` - Toggle chillsky theme
- `~/.i3/toggle-sz-swap.sh` - Swap workspace layout

## Platform Requirements

**Development:**
- Linux kernel (udev support for hotplug)
- X11 display server
- Standard POSIX utilities (xrandr, pactl, curl, grep, sed, awk)
- Systemd (for dbus-launch session management)

**Production/Deployment:**
- Manjaro Linux (or compatible Arch-based distro)
- X11 environment
- Package manager: pacman (Arch Linux packages)

**External Dependencies:**
- Network connectivity (weather API, update checks)
- dbus (session and system buses)
- udev rules (display hotplug detection)

---

*Stack analysis: 2026-02-26*
