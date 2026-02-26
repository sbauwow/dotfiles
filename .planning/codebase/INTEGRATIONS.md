# External Integrations

**Analysis Date:** 2026-02-26

## APIs & External Services

**Weather API:**
- wttr.in - Weather data and forecasts
  - Used by: `~/.config/polybar/scripts/weather.sh`
  - Endpoint: `https://wttr.in/Liberty+Hill,Texas?format=%c+%t&u`
  - Cache: 10 minutes (local file: `/tmp/polybar-weather`)
  - Data: Current conditions and temperature
  - Fallback: Returns empty if unavailable

**System Updates API:**
- Arch Linux checkupdates command
  - Used by: `~/.config/polybar/scripts/updates.sh`
  - Method: Local pacman database queries (no external API)
  - Cache: 30 minutes (local file: `/tmp/polybar-updates`)

## Hardware & System Interfaces

**Power Supply Interface:**
- sysfs power supply nodes
  - Location: `/sys/class/power_supply/BAT0/`
  - Used by: `~/.config/polybar/scripts/battery.sh`
  - Metrics: status, capacity, energy_now, energy_full, energy_full_design, power_now
  - Read-only access, no authentication required

**Display/Monitor Hotplug:**
- udev rules (device hotplug detection)
  - Triggers: `~/.i3/dock-setup.sh` on display connection/disconnection
  - Method: DRM subsystem events
  - Debounce: 1-second delay + lockfile concurrency control

**X11 Display Server:**
- xrandr protocol (monitor configuration)
  - Used by: `~/.i3/dock-setup.sh`, `~/.config/polybar/launch.sh`
  - Operations: Query connected displays, set resolution/rotation/position
  - Protocol: X11 RandR extension

**Audio System:**
- PulseAudio daemon
  - Interface: `pactl` command-line client
  - Used by: i3 keybinds (`~/.i3/config`)
  - Operations: Set sink volume, mute/unmute, get device info
  - Socket: PulseAudio system socket (default location)

## System Daemons & Services

**Session Management:**
- D-Bus daemon (system and session buses)
  - Used by: X session startup via dbus-launch
  - Purpose: Inter-process communication for system services
  - Integration: Started with xinitrc session

**Window Manager Communication:**
- i3-ipc (Inter-Process Communication)
  - Used by: Polybar i3 module
  - Socket: `$XDG_RUNTIME_DIR/i3/ipc-socket` or `/tmp/i3-ipc-*`
  - Operations: Workspace queries, event subscriptions

**Polybar IPC:**
- Polybar hook/message system
  - Used by: Custom scripts for real-time updates
  - Method: `polybar-msg` command via named pipes
  - Feature: Enabled in `~/.config/polybar/config.ini` (enable-ipc = true)

## Application Integrations

**System Tray:**
- X11 system tray protocol
  - Managed by: Polybar tray module
  - Docked applications:
    - nm-applet (NetworkManager)
    - xfce4-power-manager (power management)
    - pamac-tray (Arch package manager)
    - clipit (clipboard manager)
  - Started by: `~/.config/polybar/launch.sh` after tray initialization

**Theme Integration:**
- pywal color scheme generator
  - Optional: Referenced in i3 config comment (`wal -i ~/family.jpg`)
  - Purpose: Dynamic theme generation from wallpaper
  - Not actively used in current config

**Notification System:**
- dunst daemon
  - Integration: Launched by polybar
  - Protocol: D-Bus notification protocol
  - Customization: `~/.config/dunst/dunstrc`

## Display & Wallpaper Management

**Wallpaper Management:**
- feh (fast image viewer with wallpaper support)
  - Used by: i3 autostart and dock-setup.sh
  - Command: `feh --bg-fill ~/nature.jpeg` (set background)
  - Command: `nitrogen --restore` (restore previous wallpaper after display change)

**Compositor Rendering:**
- picom (X11 compositor)
  - Backend: OpenGL (GLX)
  - Sync: XSync fence support
  - Advanced effects: Blur, shadows, rounded corners, opacity, vsync

## Keyboard Input System

**X11 Keyboard:**
- XKB (X Keyboard Extension)
  - Keymap file: `~/.Xmodmap`
  - Used by: xinitrc on session startup
  - Operations: Custom key remapping

**Keybind Dispatch:**
- i3 event loop
  - Triggers: Bindsym keybinds in `~/.i3/config`
  - Actions: WM operations, application launches, script execution

## Hardware Monitoring

**Temperature Monitoring:**
- Thermal zone sysfs interface
  - Location: `/sys/class/thermal/thermal_zone5/` (configurable)
  - Used by: Polybar cpu-temp module
  - Metric: CPU temperature in degrees Celsius
  - Warning threshold: 80°C (hard-coded in config)

**CPU & Memory Monitoring:**
- procfs statistics
  - Sources: `/proc/stat`, `/proc/meminfo`
  - Used by: Polybar cpu and memory modules
  - Refresh rate: CPU 2s, Memory 2s (internal/cpu, internal/memory)

**Disk I/O:**
- procfs filesystem stats
  - Sources: `/proc/mounts`, disk usage query
  - Used by: Polybar disk module (internal/fs)
  - Mount point: / (root filesystem)
  - Refresh rate: 30 seconds

**Network Interface:**
- Linux kernel network interface statistics
  - Sources: `/sys/class/net/`
  - Used by: Polybar wlan and eth modules
  - Wireless interface: Auto-detected by interface-type = wireless
  - Wired interface: Auto-detected by interface-type = wired
  - Metrics: IP address (eth), SSID (wlan), up/down speed

## Locking & Security

**Screen Lock:**
- blurlock (XSecureLock wrapper)
  - Used by: i3 keybind ($mod+Shift+x) and xautolock
  - Backend: XSecureLock with blur effect
  - Triggers: Manual keybind, 10-minute idle timeout (xautolock)

**Authentication:**
- polkit-gnome (graphical authentication agent)
  - Used by: System operations requiring elevation
  - Started by: i3 autostart
  - Service: /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

## Caching Mechanisms

**Local Caches:**
- Polybar module caches (30min to 10min TTL):
  - `~/.config/polybar/scripts/weather.sh` → `/tmp/polybar-weather` (600s)
  - `~/.config/polybar/scripts/updates.sh` → `/tmp/polybar-updates` (1800s)
  - `~/.config/polybar/scripts/battery.sh` → no cache (sysfs reads are fast)

**Process Locking:**
- File-based mutexes:
  - `/tmp/polybar-launch.lock` - Prevents concurrent polybar instances
  - `/tmp/dock-setup.lock` - Prevents concurrent monitor reconfiguration
  - Purpose: Avoid race conditions during hotplug events

## Environment Configuration

**Required Environment Variables:**
- `MONITOR` - Set per-instance by polybar launcher (xrandr monitor name)
- `XDG_RUNTIME_DIR` - Standard Linux runtime directory (set by systemd)
- `ANDROID_HOME` - Optional, for Android development (set in `~/.profile`)
- `PATH` - Includes `~HOME/.npm-global/bin` (custom npm installation path)

**Configuration Sources:**
- `~/.profile` - POSIX shell env setup (sourced by login shell)
- `~/.bashrc` - Bash-specific config
- `~/.zshrc` - Zsh-specific config with oh-my-zsh
- `~/.xinitrc` - X session initialization
- `/etc/X11/xinit/xinitrc.d/` - System-wide X startup scripts

## No External Databases

**Storage:**
- All configuration is file-based (dotfiles)
- No SQL databases required
- No document stores or NoSQL
- No remote data syncing (configuration is local-only)

## Security Considerations

**API Keys & Credentials:**
- wttr.in weather API: No API key required (public endpoint)
- pacman updates: Local database only, no credentials
- All integrations use public endpoints or local system interfaces

**Network Access:**
- Only outbound: HTTP(S) to wttr.in for weather data
- Fallback-safe: Weather script gracefully handles API unavailability
- No inbound connections required

---

*Integration audit: 2026-02-26*
