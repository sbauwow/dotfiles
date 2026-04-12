# Starship prompt
if command -q starship
    starship init fish | source
end

# Zoxide (smart cd)
if command -q zoxide
    zoxide init fish | source
end

# Aliases
if command -q eza
    alias ls "eza --icons"
    alias ll "eza -la --icons --git"
    alias lt "eza -la --icons --tree --level=2"
end

if command -q bat
    alias cat "bat --style=auto"
end

alias sus "systemctl suspend"
alias recall "python3 ~/recall/recall.py"
alias codelearn "~/codelearn/.venv/bin/python ~/codelearn/codelearn.py"
alias m "mastery"
alias mq "mastery quick"

if command -q yazi
    # yazi wrapper: cd into directory on exit
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

# Environment
set -gx EDITOR hx
set -gx VISUAL hx
