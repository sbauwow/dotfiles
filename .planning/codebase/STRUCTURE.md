# Codebase Structure

**Analysis Date:** 2026-02-26

## Directory Layout

```
dotfiles/
├── i3/                          # i3wm window manager (primary)
│   ├── config                   # Main i3 configuration
│   ├── dock-setup.sh            # Multi-monitor auto-detect script
│   ├── 95-dock-monitor.rules    # udev rule to trigger hotplug
│   ├── chillsky-toggle.sh       # Radio streaming toggle
│   └── toggle-sz-swap.sh        # Dvorak S/Z key swap utility
├── polybar/                     # Status bar and system tray
│   ├── config.ini               # Polybar module definitions
│   ├── launch.sh                # Bar lifecycle manager
│   └── scripts/                 # Custom module scripts
│       ├── battery.sh           # Battery status with health metrics
│       ├── media.sh             # Currently playing media
│       ├── updates.sh           # Package update count
│       └── weather.sh           # Weather with icon conversion
├── herbstluftwm/                # herbstluftwm window manager (alternative)
│   └── autostart                # herbstluftwm config and keybindings
├── rofi/                        # Application launcher
│   └── config.rasi              # Rofi theme and modes
├── dunst/                       # Notification daemon
│   └── dunstrc                  # Dunst appearance and behavior
├── picom.conf                   # Compositor (shadows, blur, transparency)
├── xinitrc                      # X11 session startup script
├── zshrc                        # Zsh shell configuration
├── bashrc                       # Bash shell configuration
├── bash_profile                 # Bash login shell sourcer
├── profile                      # POSIX shell environment variables
├── Xresources                   # X11 terminal colors, fonts, keybindings
├── Xmodmap                      # Keyboard key remapping
├── README.md                    # Documentation
├── .git/                        # Git repository
└── .planning/                   # GSD planning output directory
    └── codebase/                # Codebase analysis documents
        ├── ARCHITECTURE.md
        ├── STRUCTURE.md
        ├── CONVENTIONS.md (future)
        └── TESTING.md (future)
```

## Directory Purposes

**i3/:**
- Purpose: i3 window manager configuration and utilities
- Contains: Keybindings, workspace layout, floating window rules, borders, gaps, color themes, hotplug handling
- Key files: `config` (408 lines, comprehensive), `dock-setup.sh` (73 lines, complex multi-dock logic)

**polybar/:**
- Purpose: Status bar rendering and system information display
- Contains: Polybar config with module definitions (i3, CPU, memory, battery, network, weather), launch script with locking and tray management
- Key files: `config.ini` (282 lines), `launch.sh` (38 lines, handles concurrency and tray applets)

**polybar/scripts/:**
- Purpose: Custom executable scripts called by polybar modules on intervals
- Contains: System info fetchers (battery, weather, updates) and media player integration
- Scripts: All bash, error-resistant, include caching and icon mapping

**herbstluftwm/:**
- Purpose: Alternative tiling window manager (not actively used)
- Contains: Complete keybinding and layout configuration, theme setup
- Note: Commented out in xinitrc; i3 is the default

**rofi/:**
- Purpose: Application launcher and window switcher
- Contains: Single config file with colors (Neon Cyber), modi (drun/run/window), display format
- Used by: i3 keybind $mod+d

**dunst/:**
- Purpose: Notification daemon appearance and behavior
- Contains: Global settings (geometry, transparency, colors), markup format, urgency levels
- Integrated with: Shell scripts (notify-send), i3 events

**picom.conf:**
- Purpose: Compositor configuration for visual effects
- Contains: GLX backend, rounded corners, shadows, blur, transparency, fading, window type exclusions
- Lifecycle: Started by i3 autostart; can be toggled with $mod+t, restarted with $mod+Ctrl+t

**xinitrc:**
- Purpose: X11 session initialization
- Contains: Xresources/Xmodmap loading, xinit.d script sourcing, WM selection logic
- Entry point: Called by startx or display manager
- Default: i3 (can switch to herbstluftwm via argument)

**zshrc:**
- Purpose: Zsh interactive shell configuration
- Contains: oh-my-zsh setup (jonathan theme, git plugin), completion settings, aliases
- Loaded: On every zsh session start
- Custom additions: OpenClaw completions, Ollama model aliases

**bashrc:**
- Purpose: Bash interactive shell configuration
- Contains: Color setup, terminal title, PS1 prompt, aliases, PATH extensions (npm, Android SDK)
- Loaded: On every bash session start
- Fallback: Sourced by bash_profile

**bash_profile:**
- Purpose: Bash login shell initialization
- Contains: Single line sourcing bashrc for consistency
- Loaded: On login (e.g., tty, SSH)

**profile:**
- Purpose: POSIX shell environment variables (shared across shells)
- Contains: Qt theme, editor (nano), GTK theme, browser (palemoon)
- Loaded: On login via shell rc files

**Xresources:**
- Purpose: X11 resource definitions for terminal emulators
- Contains: Font configuration (Terminess Nerd Font), color palette (Neon Cyber 16-color), URxvt/XTerm settings, keybindings
- Loaded: xinitrc merges via `xrdb -merge`
- Used by: Terminal emulators, X applications

**Xmodmap:**
- Purpose: Keyboard key remapping
- Contains: Dvorak S/Z swap (keycode 47 <-> 61)
- Loaded: xinitrc via `xmodmap`, can be reloaded via toggle-sz-swap.sh
- State: Tracked in /tmp/sz-swap-enabled

**README.md:**
- Purpose: Installation and overview documentation
- Contains: Directory layout, WM descriptions, symlink installation instructions

## Key File Locations

**Entry Points:**
- `xinitrc`: X11 session bootstrap (defines default WM, loads resources)
- `i3/config`: i3 window manager (primary WM, contains keybindings, autostart)
- `polybar/launch.sh`: Status bar and tray lifecycle (triggered by i3 autostart and dock-setup)
- `herbstluftwm/autostart`: Alternative WM (unused by default)

**Configuration:**
- `i3/config`: Keybindings, workspaces (1-9), floating rules, gaps, borders, colors, autostart blocks
- `polybar/config.ini`: Bar modules (i3, CPU, memory, battery, network, weather, date, tray)
- `rofi/config.rasi`: Launcher theme, display modes (drun/run/window)
- `picom.conf`: Compositor backend (GLX), effects (blur, shadow, rounded corners, fade)
- `dunst/dunstrc`: Notification geometry, colors, markup, urgency
- `Xresources`: Terminal colors (16-color palette), fonts, URxvt/XTerm settings
- `zshrc`: Shell prompt (jonathan theme), plugins (git)

**Core Logic:**
- `i3/dock-setup.sh`: Multi-monitor hotplug detection and xrandr configuration (73 lines, complex)
- `polybar/launch.sh`: Polybar lifecycle and tray applet management (38 lines)
- `polybar/scripts/battery.sh`: Battery metrics with health and time calculation (102 lines)
- `polybar/scripts/weather.sh`: Weather fetch with emoji-to-icon mapping (50 lines)
- `i3/toggle-sz-swap.sh`: Dvorak key swap with state tracking (16 lines)
- `i3/chillsky-toggle.sh`: Radio streaming MPV toggle (6 lines)

**Testing:**
- Not applicable (configuration files, no automated tests)

**Utilities & Helpers:**
- `i3/95-dock-monitor.rules`: udev rule (1 line, triggers dock-setup.sh on DRM events)
- `polybar/scripts/updates.sh`: Arch Linux update count with caching (21 lines)
- `polybar/scripts/media.sh`: playerctl integration for now-playing display (18 lines)
- `bashrc`, `zshrc`: Shell initialization with completions and aliases

## Naming Conventions

**Files:**

- **Configuration files:** Dot-prefixed for hidden files (`.bashrc`, `.zshrc`, `.Xmodmap`, `.Xresources`)
- **Shell scripts:** `.sh` extension, kebab-case names (`dock-setup.sh`, `chillsky-toggle.sh`)
- **Config formats:** INI for polybar (`config.ini`), RASI for rofi (`config.rasi`), conf for picom/dunst (`picom.conf`, `dunstrc`)
- **Rules/Daemons:** Descriptive with version (e.g., `95-dock-monitor.rules` = priority 95, udev rule)

**Directories:**

- **Lowercase, short:** `i3`, `polybar`, `rofi`, `dunst`, `herbstluftwm` (WM/app names)
- **Scripts subdirectory:** `scripts/` within polybar for modular, reusable modules
- **Dotted prefix:** `.git` (git repo), `.planning` (GSD planning output)

## Where to Add New Code

**New Feature:**

- **Display-related logic:** Add to `i3/dock-setup.sh` (condition blocks, xrandr commands) or create new script in `i3/`
- **System info module:** Create new script in `polybar/scripts/` and reference in `polybar/config.ini` with `exec` directive
- **Keybinding:** Add to `i3/config` or `herbstluftwm/autostart` depending on WM
- **Terminal configuration:** Add to `Xresources` (colors, keybindings) or `bashrc`/`zshrc` (aliases, functions)

**New Component/Module:**

- **Status bar module:** Create `.sh` script in `polybar/scripts/`, define module section in `polybar/config.ini`, add to `modules-right` (or other position)
- **Alternative WM config:** Add new WM dir (e.g., `bspwm/`) with autostart script, referenced in xinitrc's `get_session()`
- **New application config:** Create directory (e.g., `alacritty/`, `sway/`) with config file(s), install via symlink in README.md

**Utilities:**

- **Shell helper functions:** Add to `bashrc` or `zshrc` depending on shell
- **System script:** Place in appropriate component dir (`i3/`, `polybar/scripts/`) or create utility dir (e.g., `scripts/`)
- **Keybind script:** Place in `i3/` (if i3-specific) or top-level if general-purpose

## Special Directories

**.git/:**
- Purpose: Git version control
- Generated: Yes (automatic via git init)
- Committed: No (metadata only)

**.planning/:**
- Purpose: GSD (Get Stuff Done) planning and analysis documents
- Generated: Yes (by GSD orchestrator)
- Committed: Yes (included in dotfiles repo)
- Contents: Codebase analysis (ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, etc.)

**polybar/scripts/:**
- Purpose: Modular, reusable script modules for polybar
- Generated: No (manually maintained)
- Committed: Yes
- Convention: Bash scripts with shebang, error handling, caching, color output

## Symlink Installation

All configs must be symlinked to their expected locations (not committed in repo):

```bash
# Shell
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/bashrc ~/.bashrc
ln -sf ~/dotfiles/bash_profile ~/.bash_profile
ln -sf ~/dotfiles/profile ~/.profile

# X11
ln -sf ~/dotfiles/Xresources ~/.Xresources
ln -sf ~/dotfiles/xinitrc ~/.xinitrc

# Window managers
mkdir -p ~/.i3
ln -sf ~/dotfiles/i3/config ~/.i3/config
mkdir -p ~/.config/herbstluftwm
ln -sf ~/dotfiles/herbstluftwm/autostart ~/.config/herbstluftwm/autostart

# Compositor & notifications
ln -sf ~/dotfiles/picom.conf ~/.config/picom.conf
mkdir -p ~/.config/dunst
ln -sf ~/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc

# Launcher & polybar
mkdir -p ~/.config/rofi
ln -sf ~/dotfiles/rofi/config.rasi ~/.config/rofi/config.rasi
mkdir -p ~/.config/polybar
ln -sf ~/dotfiles/polybar/config.ini ~/.config/polybar/config.ini
ln -sf ~/dotfiles/polybar/launch.sh ~/.config/polybar/launch.sh
ln -sf ~/dotfiles/polybar/scripts ~/.config/polybar/scripts

# Keyboard
ln -sf ~/dotfiles/Xmodmap ~/.Xmodmap

# Udev rule (optional, for automatic dock hotplug)
sudo ln -sf ~/dotfiles/i3/95-dock-monitor.rules /etc/udev/rules.d/95-dock-monitor.rules
# Then: sudo udevadm control --reload
```

---

*Structure analysis: 2026-02-26*
