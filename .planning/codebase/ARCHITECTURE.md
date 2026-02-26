# Architecture

**Analysis Date:** 2026-02-26

## Pattern Overview

**Overall:** Multi-layer desktop environment configuration with event-driven monitor/display management.

**Key Characteristics:**
- Configuration-as-code for desktop components (WM, compositor, status bar, terminal, notifications)
- Event-driven multi-monitor setup with hotplug detection
- Modular shell-based scripting for display, UI, and system integration
- Centralized color scheme (Neon Cyber theme) across all components
- Separation between primary (i3) and alternative (herbstluftwm) window manager configs

## Layers

**X11 Initialization Layer:**
- Purpose: Bootstrap X11 session and load user resources
- Location: `xinitrc`
- Contains: Session startup, default WM selection, resource loading
- Depends on: System xinit scripts, X11 binaries
- Used by: startx, display manager

**Window Manager Layer:**
- Purpose: Define key bindings, window behavior, workspaces, and layout rules
- Location: `i3/config` (primary), `herbstluftwm/autostart` (alternative)
- Contains: Keybindings, workspace definitions, floating rules, gaps config
- Depends on: i3/herbstluftwm daemons, notification system
- Used by: X11 session, polybar

**Display/Monitor Management Layer:**
- Purpose: Auto-detect docks and configure multi-monitor layouts
- Location: `i3/dock-setup.sh` (primary logic), `i3/95-dock-monitor.rules` (udev trigger)
- Contains: Hotplug detection, xrandr configuration, multi-monitor layout presets
- Depends on: xrandr, udev, wallpaper restoration
- Used by: User (manual via $mod+Shift+m) or udev on hotplug

**Status Bar / System Tray Layer:**
- Purpose: Display system information and application tray
- Location: `polybar/config.ini` (main config), `polybar/launch.sh` (lifecycle)
- Contains: Module definitions (i3 workspaces, CPU, memory, battery, network, weather, media)
- Depends on: polybar daemon, custom scripts, system info sources
- Used by: i3 (wm-restack), applications (tray)

**Compositor Layer:**
- Purpose: Apply visual effects (shadows, blur, transparency, rounded corners)
- Location: `picom.conf`
- Contains: GLX backend config, shadow/blur/fade settings, window exclusions
- Depends on: picom daemon, X11 extensions
- Used by: X11 session, all windows

**Notification Layer:**
- Purpose: Display system notifications with consistent styling
- Location: `dunst/dunstrc`
- Contains: Geometry, colors, markup, urgency handling
- Depends on: dunst daemon, notification protocol (D-Bus)
- Used by: Applications, shell scripts (notify-send)

**Shell Configuration Layer:**
- Purpose: Configure shell environment, aliases, themes, path
- Location: `bashrc` (Bash), `zshrc` (Zsh), `bash_profile`, `profile`
- Contains: Shell settings, completions, environment variables, custom aliases
- Depends on: oh-my-zsh (for zsh), bash completions
- Used by: Terminal sessions

**Application Launcher Layer:**
- Purpose: Provide fast application menu and window switcher
- Location: `rofi/config.rasi`
- Contains: Run modes (drun, run, window), theme, keybindings
- Depends on: rofi daemon
- Used by: i3 ($mod+d keybinding)

**Terminal & Input Layer:**
- Purpose: Configure terminal colors, fonts, keybindings, and keyboard layout
- Location: `Xresources`, `Xmodmap`
- Contains: URxvt/XTerm settings, color palette, terminal keybindings, key remapping
- Depends on: Xft, X11 resources
- Used by: Terminal emulators, keyboard input

**Theme/Style Layer:**
- Purpose: Centralized color scheme and aesthetic
- Location: Shared across config files (Neon Cyber palette)
- Contains: Color definitions (#0a0e14 bg, #d4dce6 fg, #00e5ff cyan accents, etc.)
- Used by: i3, polybar, picom, dunst, rofi, Xresources

## Data Flow

**Session Startup:**

1. `xinitrc` executes (via startx or display manager)
2. Load Xresources (`Xresources`, `Xmodmap`) into X11
3. Execute system xinit.d scripts
4. Launch WM via `get_session()` (defaults to i3)
5. i3 reads `i3/config`, executes autostart blocks
6. Autostart triggers: picom, polybar, dunst, polkit, wallpaper, xautolock
7. polybar's `launch.sh` starts bars on all monitors, then launches tray applets

**Monitor Hotplug Event:**

1. udev detects DRM subsystem change
2. `i3/95-dock-monitor.rules` triggers `i3/dock-setup.sh`
3. `dock-setup.sh` locks (debounce), detects connected outputs with xrandr
4. Matches against known dock configurations (Dock1 + HDMI, Dock1, Dock2, HDMI, undocked)
5. Applies xrandr commands to configure monitors and rotation
6. Calls `nitrogen --restore` to reapply wallpaper
7. Calls polybar's `launch.sh` to restart bars on new monitor layout
8. `polybar/launch.sh` kills old polybar instances, waits, relaunches
9. After 2s delay, restarts tray applets (nm-applet, xfce4-power-manager, pamac-tray, clipit)

**User Input:**

1. Key event triggers i3 binding
2. i3 executes associated command (application, shell script, i3 operation)
3. Examples: $mod+d runs rofi, $mod+Shift+m runs dock-setup.sh, $mod+t toggles picom
4. Shell scripts may trigger notifications via notify-send

**Polybar Module Updates:**

1. Polybar loads `polybar/config.ini` on startup
2. Defines modules with exec scripts, intervals, and format templates
3. Custom script modules (weather, updates, battery, media) run on schedule
4. Scripts output formatted text with color codes
5. Polybar renders output and displays on bar

**State Management:**

- Temporary state files: `/tmp/dock-setup.lock`, `/tmp/polybar-launch.lock` (debounce locks)
- Cache files: `/tmp/polybar-updates`, `/tmp/polybar-weather` (module output cache with TTL)
- Persistent state: `/tmp/sz-swap-enabled` (flag for key swap toggle)
- X11 resources: Loaded once at session start, accessed by apps via X11 API

## Key Abstractions

**Dock Configuration Presets:**
- Purpose: Simplify multi-monitor setup by detecting physical dock state
- Examples: `i3/dock-setup.sh` (lines 23-66)
- Pattern: Conditional xrandr commands based on detected outputs, with predefined geometry and rotation

**Polybar Script Modules:**
- Purpose: Generic exec-based modules that run scripts on intervals and display output
- Examples: `polybar/scripts/battery.sh`, `polybar/scripts/weather.sh`, `polybar/scripts/updates.sh`
- Pattern: Script outputs text, polybar renders with configurable colors/icons

**Keybinding Modes:**
- Purpose: Group related actions (system power, window resize, gap adjustment)
- Pattern: i3 mode blocks (`mode "$mode_system"`, `mode "$resize"`, `mode "$mode_gaps"`)
- Behavior: Enter mode with one key, use number/direction keys, exit with Enter/Escape

**Color Theme Variables:**
- Purpose: Ensure consistency across polybar, i3, rofi, Xresources, picom
- Pattern: Define palette once (e.g., `neon` section in polybar), reference variables throughout
- Palette: Neon Cyber (dark background #0a0e14, cyan #00e5ff accents, colors 0-15)

**Shell Script Utilities:**
- Purpose: Handle complex system tasks (multi-monitor detection, battery metrics, weather fetch)
- Patterns: Lock files for debounce, caching with TTL, error handling with redirects
- Reusable: Scripts are standalone, called from i3/polybar/systemd

## Entry Points

**X11 Session:**
- Location: `xinitrc`
- Triggers: User runs `startx` or display manager starts default session
- Responsibilities: Load X resources, merge keymaps, launch default WM (i3)

**Window Manager (i3):**
- Location: `i3/config`
- Triggers: xinitrc launches i3 via get_session()
- Responsibilities: Accept keybindings, manage window layout, trigger autostart blocks, interact with polybar

**Window Manager (herbstluftwm):**
- Location: `herbstluftwm/autostart`
- Triggers: xinitrc launches herbstluftwm via manual selection
- Responsibilities: Configure keybindings, tags, themes, launch panel

**Monitor Hotplug:**
- Location: `i3/dock-setup.sh`
- Triggers: udev rule on DRM subsystem change, or manual keybind ($mod+Shift+m)
- Responsibilities: Detect dock state, configure xrandr, restart polybar and tray

**Polybar Launcher:**
- Location: `polybar/launch.sh`
- Triggers: i3 autostart (`exec_always`), dock-setup.sh, manual calls
- Responsibilities: Kill old bars, wait for tray readiness, launch new bars, restart tray applets

**Shell Sessions:**
- Location: `bashrc`, `zshrc`
- Triggers: Terminal emulator opens (login/non-login shell)
- Responsibilities: Set PATH, aliases, completions, oh-my-zsh initialization

## Error Handling

**Strategy:** Minimal error handling in config files (declarative), defensive scripting in bash.

**Patterns:**

- **Bash scripts:** Use `||` and `&&` for conditional execution; redirect stderr to /dev/null for non-critical commands
  - Example: `nitrogen --restore 2>/dev/null &` (silently fail if nitrogen unavailable)
  - Example: `killall -q polybar` (suppress output if no processes found)

- **i3 config:** Uses `--no-startup-id` to prevent startup notification delays; command failures silently continue
  - Example: `exec --no-startup-id sleep 1; picom -b` (picom launch with 1s delay)

- **Polybar scripts:** Check for file/directory existence before reading; output empty on error
  - Example: `[[ ! -d "$BAT" ]] && exit 0` (skip battery module if sysfs unavailable)
  - Example: `curl -sf "wttr.in/..." 2>/dev/null` (silent fail, no output if curl unavailable)

- **Udev rules:** Wrapped in `su` command to run as user; DISPLAY set manually
  - Example: `RUN+="/bin/su stathis -c 'DISPLAY=:0 /home/stathis/.i3/dock-setup.sh &'"` (ensures proper context)

- **Lock files:** Prevent concurrent execution; flock with `-n` (non-blocking) to skip if locked
  - Example: `flock -n 9 || exit 0` (exit silently if another instance is running)

## Cross-Cutting Concerns

**Logging:**
- Approach: No centralized logging; scripts use notify-send for user feedback
- Examples: Display changes notify via `notify-send "Display" "Dock 1: ..."`, S/Z toggle notifies state
- Polybar modules output directly to bar (no logs)

**Validation:**
- File existence: Checked in conditional blocks (`[ -f "$file" ]`, `[ -d "$dir" ]`)
- Environment: xinitrc checks for Xresources/Xmodmap before loading
- Ranges: Battery script clamps capacity to icon/color logic; polybar modules validate input

**Authentication:**
- No auth layer; udev rule runs as user via `su stathis`
- Polkit agent launched in i3 autostart for system operations (e.g., power management)

**Concurrency:**
- Multi-instance prevention via lock files (dock-setup.sh, polybar-launch.sh)
- Debouncing: udev can fire multiple events; dock-setup.sh waits and locks
- Polybar child spawning: launch.sh waits for bar shutdown before relaunching

**Configuration Reload:**
- i3: $mod+Shift+c reloads config (keybindings, colors, autostart blocks)
- Polybar: `--reload` flag enables screenchange-reload for dynamic monitors
- Shell: source ~/.bashrc manually or open new terminal

---

*Architecture analysis: 2026-02-26*
