function editclip --description 'Load clipboard into the command line for review, then Enter once'
    commandline -r (xsel -b | string collect)
    commandline -f repaint
end
