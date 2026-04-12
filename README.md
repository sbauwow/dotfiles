# dotfiles

Manjaro Linux (26.0.4) + X11 desktop config. i3wm, polybar, alacritty, fish shell.

## System

| Component | Detail |
|-----------|--------|
| OS | Manjaro Linux 26.0.4 "Anh-Linh" |
| Kernel | 6.12.x |
| WM | i3wm (primary), herbstluftwm (alt) |
| Bar | Polybar |
| Compositor | Picom |
| Terminal | Alacritty, URxvt |
| Shell | Fish + Starship prompt |
| Editor | Helix (`hx`) |
| Launcher | Rofi |
| Notifications | Dunst |
| File Manager | PCManFM, Yazi, Ranger |
| GTK Theme | Adapta-Nokto-Eta-Maia |
| Icon Theme | Papirus-Adapta-Nokto-Maia |
| Cursor | xcursor-breeze |
| System Font | Noto Sans 10 |
| Monospace Font | JetBrainsMono Nerd Font 12 |
| Multiplexer | tmux (Ctrl+a prefix) |
| Git Pager | delta (side-by-side, line numbers) |
| Micro Editor | Alt keybindings |

## Color Schemes

**Xresources / Polybar / i3** — "Neon Cyber"
```
bg         #0a0e14    fg         #d4dce6
black      #1c2433    bright-blk #4a5568
red        #ff3d3d    bright-red #ff6b6b
green      #00ff88    bright-grn #39ff14
yellow     #ffea00    bright-yel #ffd600
blue       #0088ff    bright-blu #00b4d8
magenta    #ff0080    bright-mag #bd00ff
cyan       #00e5ff    bright-cyn #67e8f9
white      #d4dce6    bright-wht #8b949e
```

**Alacritty / tmux** — Tokyo Night
```
bg         #1a1b26    fg         #c0caf5
black      #15161e    bright-blk #414868
red        #f7768e    green      #9ece6a
yellow     #e0af68    blue       #7aa2f7
magenta    #bb9af7    cyan       #7dcfff
white      #a9b1d6    bright-wht #c0caf5
```

## What's in here

```
dotfiles/
├── alacritty/
│   └── alacritty.toml          # Terminal (Tokyo Night, JetBrainsMono NF 12)
├── fish/
│   ├── config.fish             # Fish shell (starship, zoxide, eza/bat aliases)
│   └── functions/
│       ├── detach.fish         # Alt+& to background+disown current command
│       └── fish_user_key_bindings.fish
├── starship/
│   └── starship.toml           # Prompt (minimal: dir, git, lang, duration)
├── i3/
│   └── config                  # i3wm (Alt as mod, pixel borders)
├── polybar/
│   ├── config.ini              # Polybar (Neon Cyber colors, JetBrainsMono NF)
│   ├── launch.sh               # Multi-monitor launch script
│   └── scripts/                # Custom modules
├── rofi/
│   └── config.rasi             # App launcher
├── dunst/
│   └── dunstrc                 # Notification daemon
├── herbstluftwm/
│   └── autostart               # Alt WM (Super as mod, pywal colors)
├── tmux.conf                   # tmux (Ctrl+a, vim nav, Tokyo Night status)
├── gitconfig                   # Git (delta pager, side-by-side diffs)
├── micro/
│   └── bindings.json           # Micro editor keybindings
├── ranger/
│   ├── rc.conf                 # Ranger file manager config
│   └── scope.sh                # Preview script
├── picom.conf                  # Compositor (shadows, vsync, blur)
├── Xresources                  # Neon Cyber colors, URxvt config
├── xinitrc                     # X session startup (defaults to i3)
├── radio/                      # CLI streaming radio player
├── packages/
│   ├── pacman-explicit.txt     # All explicitly installed packages (314)
│   ├── aur.txt                 # AUR packages only
│   └── fonts.txt               # Installed font families
├── zshrc                       # Zsh config (oh-my-zsh, jonathan theme)
├── bashrc                      # Bash config, aliases
├── bash_profile                # Sources bashrc
├── profile                     # Env vars (QT theme, EDITOR, BROWSER)
└── systemd/
    └── logind.conf.d/
        └── power-button.conf   # Require long-press to poweroff
```

## Key Fonts

- **JetBrainsMono Nerd Font** — terminal, polybar, code
- **Noto Sans** — GTK/UI
- **Terminus / Terminess Nerd Font** — URxvt fallback
- **Inconsolata** — alt monospace
- **Noto Sans CJK** — CJK coverage

Full list in `packages/fonts.txt`.

## Install

```bash
# Shell
ln -sf ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
mkdir -p ~/.config/fish/functions
ln -sf ~/dotfiles/fish/functions/detach.fish ~/.config/fish/functions/detach.fish
ln -sf ~/dotfiles/fish/functions/fish_user_key_bindings.fish ~/.config/fish/functions/fish_user_key_bindings.fish
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/bashrc ~/.bashrc
ln -sf ~/dotfiles/bash_profile ~/.bash_profile
ln -sf ~/dotfiles/profile ~/.profile

# Terminal & tools
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
mkdir -p ~/.config/micro
ln -sf ~/dotfiles/micro/bindings.json ~/.config/micro/bindings.json
mkdir -p ~/.config/ranger
ln -sf ~/dotfiles/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf ~/dotfiles/ranger/scope.sh ~/.config/ranger/scope.sh

# X11
ln -sf ~/dotfiles/Xresources ~/.Xresources
ln -sf ~/dotfiles/xinitrc ~/.xinitrc

# Window managers
mkdir -p ~/.i3
ln -sf ~/dotfiles/i3/config ~/.i3/config
mkdir -p ~/.config/herbstluftwm
ln -sf ~/dotfiles/herbstluftwm/autostart ~/.config/herbstluftwm/autostart

# Polybar
mkdir -p ~/.config/polybar
ln -sf ~/dotfiles/polybar/config.ini ~/.config/polybar/config.ini
ln -sf ~/dotfiles/polybar/launch.sh ~/.config/polybar/launch.sh

# Rofi
mkdir -p ~/.config/rofi
ln -sf ~/dotfiles/rofi/config.rasi ~/.config/rofi/config.rasi

# Compositor & notifications
ln -sf ~/dotfiles/picom.conf ~/.config/picom.conf
mkdir -p ~/.config/dunst
ln -sf ~/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc

# Restore packages (native + AUR)
pacman -S --needed - < ~/dotfiles/packages/pacman-explicit.txt
yay -S --needed - < ~/dotfiles/packages/aur.txt
```

## Power button

`systemd/logind.conf.d/power-button.conf` swaps short-press / long-press: a tap does nothing, a ~5s hold powers off. Avoids accidental poweroffs from bumping the button.
