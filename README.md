# dotfiles

My Linux desktop config files. Manjaro + X11 with tiling window managers.

## What's in here

```
dotfiles/
├── zshrc                       # Zsh config (oh-my-zsh, jonathan theme, aliases)
├── bashrc                      # Shell config, aliases, prompt, PATH
├── bash_profile                # Sources bashrc
├── profile                     # Env vars (QT theme, EDITOR, BROWSER)
├── Xresources                  # URxvt/XTerm colors, fonts, keybindings
├── xinitrc                     # X session startup (defaults to i3)
├── i3/
│   └── config                  # i3wm config (Alt as mod key)
├── herbstluftwm/
│   └── autostart               # herbstluftwm config (Super as mod key)
├── picom.conf                  # Compositor (shadows, vsync, blur)
└── dunst/
    └── dunstrc                 # Notification daemon
```

## Window Managers

**i3wm** - `Mod1` (Alt) as modifier. Pixel borders, dmenu launcher, workspaces 1-8.

**herbstluftwm** - `Mod4` (Super) as modifier. Manual tiling, pywal colors, 9 tags.

The xinitrc defaults to i3. Both WMs use picom for compositing and dunst for notifications.

## Install

Symlink the files to their expected locations:

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
```
