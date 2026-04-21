#!/usr/bin/env bash
# Theme switcher: work (Win11) vs home (Neon Cyber).
# Called by ~/.i3/dock-setup.sh.

set -u

theme="${1:-}"
case "$theme" in
  work|home) ;;
  *) echo "usage: $0 {work|home}" >&2; exit 1 ;;
esac

DOTFILES="$HOME/dotfiles/themes"
POLY_DIR="$HOME/.config/polybar"
ALA_DIR="$HOME/.config/alacritty"

mkdir -p "$POLY_DIR" "$ALA_DIR"

ln -sf "$DOTFILES/alacritty-base.toml" "$ALA_DIR/alacritty.toml"

if [[ "$theme" == "work" ]]; then
  ln -sf "$DOTFILES/polybar-win11.ini"  "$POLY_DIR/config.ini"
  ln -sf "$DOTFILES/alacritty-win11.toml" "$ALA_DIR/theme.toml"
  feh --no-fehbg --bg-fill "$DOTFILES/mint-solid.png" >/dev/null 2>&1 &
else
  ln -sf "$DOTFILES/polybar-neon.ini"   "$POLY_DIR/config.ini"
  ln -sf "$DOTFILES/alacritty-neon.toml" "$ALA_DIR/theme.toml"
  # Restore user's last wp selection (tracked by wpg's .current symlink)
  current=$(basename "$(readlink "$HOME/.config/wpg/.current" 2>/dev/null)" 2>/dev/null)
  [ -n "$current" ] && wpg -s "$current" >/dev/null 2>&1 &
fi

"$POLY_DIR/launch.sh" >/dev/null 2>&1 &disown
