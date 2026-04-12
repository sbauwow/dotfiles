function detach --description 'Append " &; disown" to the current command line and execute'
    set -l cmd (commandline)
    if test -z "$cmd"
        return
    end
    commandline -r "$cmd &; disown"
    commandline -f execute
end
