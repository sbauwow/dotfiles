# Codebase Concerns

**Analysis Date:** 2026-02-26

## Tech Debt

**Hardcoded Ollama API URLs in zshrc:**
- Issue: Ollama model switching aliases use hardcoded `http://localhost:11434` endpoints
- Files: `zshrc` (lines 108-109)
- Impact: Non-functional if Ollama is running on different host/port; no error handling if service is down; aliases will fail silently and drop into wrong model
- Fix approach: Extract Ollama host/port to variables at top of zshrc, add connection check before alias execution or use wrapper function with fallback

**Hardcoded location in weather script:**
- Issue: Weather widget shows hardcoded location "Liberty+Hill,Texas"
- Files: `polybar/scripts/weather.sh` (line 14)
- Impact: Location is not user-configurable; script is non-portable across installations
- Fix approach: Read location from config file (`$XDG_CONFIG_HOME/polybar/weather.conf` or similar) with fallback to current location

**Hardcoded stream URL in chillsky-toggle:**
- Issue: Music stream URL is hardcoded directly in script
- Files: `i3/chillsky-toggle.sh` (line 5)
- Impact: If stream goes offline or URL changes, script silently fails; no error output; no fallback
- Fix approach: Move to config file, add stream availability check with user notification

**Multiple hardcoded radio URLs in herbstluftwm:**
- Issue: Three streaming URLs hardcoded in autostart keybinds
- Files: `herbstluftwm/autostart` (lines 34, 37-38)
- Impact: Similar to chillsky-toggle; fragile and non-maintainable
- Fix approach: Extract to separate music-streams.conf file, use consistent sourcing pattern

**Static polybar tray applet list:**
- Issue: Polybar launch script has hardcoded killall list for tray applets
- Files: `polybar/launch.sh` (line 28)
- Impact: If system doesn't have one of these apps (nm-applet, pamac-tray, etc.), killall still succeeds but is wasteful; if new tray apps are added, script must be edited manually
- Fix approach: Use `killall -q` with error suppression and optional config file to specify which apps to restart

**Android SDK path in bashrc:**
- Issue: ANDROID_HOME and PATH expansion with SDK tools present but commented alternatives exist
- Files: `bashrc` (lines 115-116)
- Impact: If SDK is moved or uninstalled, PATH includes invalid directories; no validation
- Fix approach: Add existence check for $ANDROID_HOME/platform-tools before adding to PATH

## Known Bugs

**Malformed bashrc line 116:**
- Bug: Long line with incomplete statement, PATH assignment split awkwardly
- Symptoms: bashrc line 116 appears to be two statements on one line with excessive whitespace
- Files: `bashrc` (line 116)
- Trigger: Sourcing bashrc; may cause parsing issues or unexpected PATH duplication
- Fix approach: Split into separate clear statements with proper formatting; verify shell syntax with `bash -n bashrc`

**S/Z swap toggle state tracking fragile:**
- Bug: State file uses simple existence check; no atomic operations
- Symptoms: If script is interrupted, state can become inconsistent with actual keyboard layout
- Files: `i3/toggle-sz-swap.sh` (lines 5-8)
- Trigger: Kill script between state file creation and setxkbmap execution
- Workaround: Manual `setxkbmap -option` to reset layout
- Fix approach: Query current layout state before making changes instead of relying on state file; use atomic operations

**Dock setup script debounce may still race:**
- Bug: Single sleep(1) before xrandr detection doesn't guarantee display settle time
- Symptoms: Occasional display configuration failures on rapid hotplug; wrong resolution chosen
- Files: `i3/dock-setup.sh` (lines 15, 60)
- Trigger: Quickly dock/undock multiple times
- Workaround: Manual re-run of dock-setup
- Fix approach: Query display state in loop with timeout, retry xrandr if output count doesn't stabilize

**Polybar restart race condition between launch and tray applets:**
- Bug: Hard sleep(2) assumption may not be enough for polybar tray initialization on slow systems
- Symptoms: Tray applets fail to dock into new tray, appear as floating windows
- Files: `polybar/launch.sh` (line 25)
- Trigger: On systems with high I/O contention or slow systemd-user
- Workaround: Manually `pkill -f "nm-applet|xfce4-power-manager"` and restart them
- Fix approach: Poll for polybar process and verify systemd XDG_RUNTIME_DIR socket exists before spawning applets

## Security Considerations

**External API calls without validation:**
- Risk: Weather script and stream URLs use curl without verifying SSL certificates or response format
- Files: `polybar/scripts/weather.sh` (line 14), `i3/chillsky-toggle.sh` (line 5)
- Current mitigation: Uses `-sf` flags (silent, show errors) but no cert validation
- Recommendations: Add explicit `--cacert` or validate response content-type; implement timeout with `--max-time 5`; sanitize output before display

**Unvalidated user-controlled hotplug events:**
- Risk: udev-triggered dock-setup script runs with user privileges; rapid hotplug events could spawn many processes
- Files: `i3/dock-setup.sh` (referenced via udev rule, lines 72)
- Current mitigation: Flock ensures single execution, but file descriptor cleanup is manual (exec 9>&-)
- Recommendations: Use `flock` cleanup trap instead of manual fd; add process count limits in udev rule

**Open HTTP streaming URLs:**
- Risk: chillsky and herbstluftwm streams use plain HTTP (not HTTPS)
- Files: `i3/chillsky-toggle.sh` (line 5), `herbstluftwm/autostart` (lines 34, 37-38)
- Current mitigation: None
- Recommendations: Use HTTPS where available; validate stream source before adding to config

**No input validation in shell scripts:**
- Risk: Scripts don't validate xrandr/xmodmap output or check for injection attacks
- Files: `i3/dock-setup.sh`, `i3/toggle-sz-swap.sh`, all polybar scripts
- Current mitigation: Scripts use built-in commands only (no user input passed to external tools)
- Recommendations: Quote all variable expansions (already done mostly); add explicit type checks where needed

## Performance Bottlenecks

**Synchronous xrandr queries block dock setup:**
- Problem: dock-setup.sh makes multiple sequential xrandr calls instead of batching
- Files: `i3/dock-setup.sh` (lines 25-29, 35-38, 44-47, 53-55, 60-64)
- Cause: Multiple independent xrandr invocations for each output; no pipelining
- Improvement path: Collect all output states in single xrandr query; build complete configuration; apply atomically with single xrandr invocation

**Weather caching uses global /tmp with no rotation:**
- Problem: Cache file persists indefinitely if system uptime is long; no cleanup
- Files: `polybar/scripts/weather.sh` (line 3)
- Cause: Relies on systemd tmpfiles.d cleanup (10 days by default); no explicit purge
- Improvement path: Add TTL-based cleanup or use systemd volatile storage; monitor cache growth

**Polybar uses hardcoded sleep delays:**
- Problem: Fixed 0.5s sleep between monitor launches and 2s before tray applets; arbitrary timing
- Files: `polybar/launch.sh` (lines 20, 25)
- Cause: No detection of polybar readiness; uses deterministic but fragile timing
- Improvement path: Query polybar socket/process to verify tray creation; use polling loop with timeout

**Multiple killall invocations in polybar launch:**
- Problem: Separate killall calls in launch sequence (lines 9, 28) plus tray applet restart loop
- Files: `polybar/launch.sh` (line 9, 28)
- Cause: No batching of process termination
- Improvement path: Single killall -q for all targets; verify termination with pgrep loop before proceeding

## Fragile Areas

**Dock configuration detection logic:**
- Files: `i3/dock-setup.sh` (lines 23-66)
- Why fragile: Complex nested conditional logic based on output presence; if new dock configuration is added (e.g., Dock 3 with different port combination), entire script must be rewritten
- Safe modification: Extract dock profiles to separate config file as JSON/TOML with connector names and xrandr parameters; rewrite main script to iterate over profiles
- Test coverage: No tests; relies on manual verification after dock changes; missing coverage for: edge cases with USB-C hubs providing multiple DP streams, race between docking and sleep, rapid undock/redock

**Polybar multi-monitor launching:**
- Files: `polybar/launch.sh` (lines 18-21)
- Why fragile: Loop depends on xrandr formatting remaining stable; if xrandr output format changes across updates, script silently fails
- Safe modification: Use more robust parsing like `xrandr --query --parseable` or check for /sys/class/drm entries instead
- Test coverage: Not tested on systems with hotplug events or 5+ monitors; untested on tiling WMs other than i3

**Shell alias expansion in zshrc:**
- Files: `zshrc` (lines 108-109)
- Why fragile: Aliases with complex command substitution and shell operators; if ollama changes API format or model names, aliases silently fail with no helpful error message
- Safe modification: Convert to functions with error checking and user feedback
- Test coverage: No validation that models are installed; no health check before launching ollama run

**Temperature/status file reads in battery script:**
- Files: `polybar/scripts/battery.sh` (lines 8-12)
- Why fragile: Reads from /sys/class/power_supply/BAT0 hardcoded; fails silently on systems with different battery naming (BAT1, AC0, etc.); no fallback
- Safe modification: Auto-detect battery directory via `ls /sys/class/power_supply/*` and select first BAT* entry; add error output
- Test coverage: Only tested on systems with BAT0; untested on: multi-battery laptops, systems with only AC power, ACPI driver changes

**Xmodmap state depends on file existence:**
- Files: `i3/toggle-sz-swap.sh` (lines 5-8)
- Why fragile: Toggle state determined only by file presence; if state file is deleted externally, script behavior becomes unpredictable
- Safe modification: Query actual xkb state with `setxkbmap -query` or check if Xmodmap rules are active
- Test coverage: No tests for: file system issues (permission denied on /tmp), concurrent toggle attempts, X server restart

**Notification-based user feedback:**
- Files: `i3/dock-setup.sh` (lines 30, 39, 48, 56, 65), `i3/toggle-sz-swap.sh` (lines 10, 14), `i3/chillsky-toggle.sh` (line 5)
- Why fragile: Scripts rely on dunst notifications without checking if dunst is running; failures are silent
- Safe modification: Test notification daemon availability before sending; provide fallback to stderr/syslog
- Test coverage: Untested on systems without dunst or with disabled notifications

## Scaling Limits

**Monitor configuration hardcoded for specific setup:**
- Current capacity: 4 distinct dock configurations (Dock 1 + HDMI, Dock 1 only, Dock 2, HDMI only, Laptop only)
- Limit: Adding new dock or monitor combination requires script modification; no abstraction
- Scaling path: Move dock profiles to external config file; implement profile selection logic independent of specific port names

**Weather refresh cadence not tunable:**
- Current capacity: Fixed 10-minute cache (600s)
- Limit: No way to adjust cache time without editing script
- Scaling path: Read cache TTL from config file; allow per-user override via environment variable

**Tray applet list fixed in polybar launch:**
- Current capacity: 4 hardcoded applets (nm-applet, xfce4-power-manager, pamac-tray, clipit)
- Limit: Custom or additional tray apps must be added manually to script
- Scaling path: Configuration-driven app list; allow enabling/disabling applets via config without script editing

## Dependencies at Risk

**oh-my-zsh dependency in zshrc:**
- Risk: Sources `/home/stathis/.oh-my-zsh/oh-my-zsh.sh` (line 75); if oh-my-zsh is uninstalled, shell fails to initialize
- Impact: zsh becomes unusable; login issues
- Migration plan: Add existence check before sourcing; provide fallback to minimal zsh config; document oh-my-zsh as optional dependency

**Hardcoded OpenClaw completion path in zshrc:**
- Risk: Sources `/home/stathis/.openclaw/completions/openclaw.zsh` (line 105); assumes openclaw is installed
- Impact: zsh startup fails if file missing; no fallback; breaks on fresh system setup
- Migration plan: Add existence check with `[[ -f ... ]] &&` pattern; document openclaw as optional

**NotifyD daemon dependency:**
- Risk: All scripts rely on `notify-send` without checking if daemon is running
- Impact: Notifications fail silently; user has no feedback from dock-setup, toggle-sz-swap, etc.
- Migration plan: Implement notification fallback (journal, stderr); check dunst status before sending

**curl and network dependencies:**
- Risk: Weather and stream scripts require internet connectivity; no offline mode
- Impact: Polybar weather widget fails on network loss; music streams hang if unreachable
- Migration plan: Implement graceful degradation (show "offline" instead of blank); add connection check before curl; cache results longer

## Missing Critical Features

**No error reporting in shell scripts:**
- Problem: Most scripts suppress stderr and use silent failures; user has no way to debug issues
- Blocks: Troubleshooting dock setup failures, understanding why streams don't work, debugging polybar crashes
- Impact: Hours spent investigating silent failures; users blame system rather than dotfiles

**No configuration file support:**
- Problem: All settings (location, streams, cache times, tray apps) hardcoded in scripts
- Blocks: Portability across machines; per-user customization without editing code; version control issues if user modifies dotfiles locally
- Impact: Each new environment requires script modifications; upgrades risk clobbering user changes

**No health checks or diagnostics:**
- Problem: No way to verify that dependencies are installed (ollama, nm-applet, dunst, etc.)
- Blocks: First-run setup is error-prone; users don't know what's missing
- Impact: Broken features appear without explanation; users resort to manual debugging

**No rollback or undo mechanism:**
- Problem: dock-setup and xmodmap changes are applied directly without saving previous state
- Blocks: Recovery from bad configurations; ability to revert to last known good setup
- Impact: Users stuck with bad monitor setup; manual xrandr commands needed to recover

## Test Coverage Gaps

**No testing of multi-monitor hotplug scenarios:**
- What's not tested: Rapid dock/undock, partial display connections, USB-C hub variations
- Files: `i3/dock-setup.sh`
- Risk: Monitor configuration fails silently; users stuck with wrong resolution/arrangement
- Priority: High

**No test coverage for polybar multi-monitor launch:**
- What's not tested: 3+ monitors, monitors added/removed during polybar restart, tray applet startup failures
- Files: `polybar/launch.sh`
- Risk: Tray icons disappear after dock change; applets fail to respawn; users unaware of failures
- Priority: High

**No validation of shell syntax before deploy:**
- What's not tested: Syntax errors, undefined variables, quoting issues
- Files: All `.sh` files in i3/, polybar/scripts/
- Risk: Silent failures on systems with different bash/sh versions; bashisms in POSIX scripts
- Priority: Medium

**No integration testing for X11 session:**
- What's not tested: i3 startup, polybar initialization, xmodmap loading, compositor startup order
- Files: `xinitrc`, i3 config, all autostart scripts
- Risk: Display fails to start; users unable to log in; race conditions in startup sequence
- Priority: High

**No testing of ollama service health before alias execution:**
- What's not tested: Ollama not running, port 11434 unreachable, model missing
- Files: `zshrc` lines 108-109
- Risk: vis/txt aliases hang waiting for connection; user experience is poor; no error feedback
- Priority: Medium

**No cache invalidation testing:**
- What's not tested: Behavior when cache files are stale, corrupted, or permission-denied
- Files: `polybar/scripts/weather.sh`, `polybar/scripts/updates.sh`
- Risk: Polybar hangs reading stale cache; updates widget shows wrong count indefinitely
- Priority: Low

---

*Concerns audit: 2026-02-26*
