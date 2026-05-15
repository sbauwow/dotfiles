function runclip --description 'Run multi-line command(s) straight from the X clipboard'
    set -l cmd (xsel -b)
    if test -z "$cmd"
        echo "runclip: clipboard empty" >&2
        return 1
    end
    printf '%s\n' "$cmd" | bash
end
