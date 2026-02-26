# Coding Conventions

**Analysis Date:** 2026-02-26

## Naming Patterns

**Files:**
- Lowercase with hyphens for separators: `dock-setup.sh`, `chillsky-toggle.sh`
- Scripts execute system commands or manage system state
- No specific file naming prefix convention (e.g., no `run-` or `lib-` prefixes)

**Functions:**
- Not heavily used; codebase favors inline procedural scripts
- When defined, use snake_case: `has_output()` in `/home/stathis/dotfiles/i3/dock-setup.sh`
- Short, descriptive function names for helper logic

**Variables:**
- All caps for configuration constants: `LOCKFILE`, `CACHE`, `CACHE_AGE`, `BAT`, `STATE_FILE`
- Lowercase for runtime variables: `connected`, `status`, `capacity`, `watts`, `health`, `time_str`
- All caps with prefix for color codes: `C_LIME`, `C_ORANGE`, `C_RED`, `C_FG`, `C_CYAN`, `C_COMMENT`
- All caps for icon/symbol variables: `NF_SUNNY`, `NF_PARTCLOUD`, `NF_CLOUDHI`, `NF_CLOUDY` in `/home/stathis/dotfiles/polybar/scripts/weather.sh`

**Types:**
- Not applicable; shell scripting has no static type system

## Code Style

**Formatting:**
- 4-space indentation for control structures and function bodies (observed in `dock-setup.sh`, `battery.sh`)
- Tab indentation used inconsistently in `bashrc` (mixed usage)
- Each script maintains consistent internal style but no unified formatter across repo

**Linting:**
- No linting tools detected (no `.shellcheckrc`, `eslintrc`, or similar)
- No automatic formatting tools configured

**Shebang:**
- Preferred: `#!/usr/bin/env bash` (used in `launch.sh`, `battery.sh`)
- Alternative: `#!/bin/bash` (used in `dock-setup.sh`, `toggle-sz-swap.sh`)

## Comment Style

**When to Comment:**
- Inline comments explain non-obvious logic
- Header comments describe script purpose and global state
- Comments precede complex sections (e.g., weather emoji mapping in `weather.sh`)

**Examples:**
```bash
# Debounce: udev fires multiple DRM events per hotplug
LOCKFILE="/tmp/dock-setup.lock"

# Pick color based on state and capacity
case "$status" in
```

**Doc Comments:**
- Rarely used; scripts are small and single-purpose
- Header docstring pattern observed: script purpose + key functions on lines 1-10

## Error Handling

**Patterns:**
- Silencing errors with `2>/dev/null`: `playerctl status 2>/dev/null`, `notify-send ... 2>/dev/null`
- Checking existence before operations: `[[ ! -d "$BAT" ]] && exit 0` in `battery.sh`
- Conditional exits: `flock -n 9 || exit 0` for lock acquisition in `dock-setup.sh`, `launch.sh`
- No error propagation or logging; failures are silent or result in empty output
- No try-catch equivalent; scripts use early returns or conditional exits

**Exit Codes:**
- Exit 0 on success or handled exit
- Exit via `exit 0` for early termination when preconditions not met
- No explicit non-zero exit codes observed

## Variable Scope & Path Usage

**Paths:**
- Absolute paths preferred: `/tmp/dock-setup.lock`, `/tmp/polybar-updates`, `/sys/class/power_supply/BAT0`
- Home directory expansion: `~/.i3/dock-setup.sh`, `~/.Xmodmap`, `~/.config/polybar/launch.sh`
- No path canonicalization; relative paths appear in config references only

**Quoting:**
- Variables quoted in double quotes: `"$LOCKFILE"`, `"$status"`, `"$BAT"`
- Command substitution quoted: `"$(xrandr | grep ...)"`, `"$(date +%s)"`
- String concatenation without explicit operator: `"${capacity}%  ${watts}W"`

## Conditional & Control Flow

**Conditionals:**
- Bash `[[ ]]` syntax preferred over `[ ]`: `[[ ! -d "$BAT" ]]`, `[[ -f "$CACHE" ]]`
- Case statements for multi-branch logic: dock configurations in `dock-setup.sh`, battery status in `battery.sh`
- `if/then/elif/else/fi` for simple branches

**Loops:**
- `for` loop over command substitution: `for m in $(xrandr --query | grep ...)` in `launch.sh`
- `while` for polling: `while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done` in `launch.sh`

## Command Pipeline & Text Processing

**Patterns:**
- `grep -q` for silent boolean checks: `echo "$connected" | grep -q "^$1$"` in `dock-setup.sh`
- `awk` for arithmetic and formatting: `awk "BEGIN {printf \"%.1f\", $power_now / 1000000}"` in `battery.sh`
- `sed` for emoji/text substitution: extensive Unicode mapping in `weather.sh`
- `cut`, `tr`, `head`, `tail` for filtering and slicing
- Pipeline chaining for composition: `curl ... | sed ... | tr ...`

## Arithmetic & Numeric Handling

**Integer Operations:**
- Bash arithmetic expansion: `$((secs / 3600))`, `$((secs % 3600) / 60)` in `battery.sh`
- Comparisons: `-lt`, `-le`, `-gt`, `-eq` for numeric tests

**Floating Point:**
- `awk` with `printf` for decimal formatting: `awk "BEGIN {printf \"%.1f\", ...}"` in `battery.sh`
- All UI-facing numbers use 2 decimal places or integer display

## Installation & Distribution

**Pattern:**
- Scripts are standalone executables in their respective directories
- Configuration files are source-controlled as dotfiles
- Installation via symlinks to home directories (documented in `README.md`)
- No package.json, requirements.txt, or build system

## Module Organization

**No module system:** Each script is self-contained and executes independently. Scripts in polybar/scripts/ are spawned by polybar daemon.

**Script Responsibilities:**
- `dock-setup.sh`: Monitor configuration via xrandr, polybar restart
- `launch.sh`: Polybar daemon lifecycle and tray applet management
- `battery.sh`: Read sysfs battery metrics, format for polybar output
- `weather.sh`: Fetch weather, cache, translate emojis for display
- `updates.sh`: Count available package updates, cache results
- `media.sh`: Display current media player status via playerctl
- `chillsky-toggle.sh`: Toggle lo-fi stream playback
- `toggle-sz-swap.sh`: Toggle keyboard layout swap state

## Concurrency & Locking

**Pattern:**
- File-based locking for race condition prevention: `flock` command
- Lock files placed in `/tmp/`: `/tmp/dock-setup.lock`, `/tmp/polybar-launch.lock`
- Non-blocking lock acquisition: `flock -n 9 || exit 0` (exit if locked)
- Lock held for script duration or explicitly released: `exec 9>&-` in `launch.sh`

## Subprocess & Background Execution

**Patterns:**
- `&disown` to spawn background processes that survive script exit: `nm-applet &disown 2>/dev/null`
- `&` to spawn without disown in subprocess context: `nitrogen --restore 2>/dev/null &`
- Process management: `pkill`, `killall`, `pgrep` for querying and terminating

---

*Convention analysis: 2026-02-26*
