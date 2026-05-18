function glitchwp --description 'Set a ~/glitch-art output as wallpaper via wp; or glitch an image then set it'
    set -l dir "$HOME/glitch-art"
    set -l wpgdir "$HOME/.config/wpg/wallpapers"

    # No args -> list available glitch outputs
    if test (count $argv) -eq 0
        echo "glitch outputs in $dir:"
        for f in $dir/*.png
            test -f "$f"; and echo "  "(basename "$f")
        end
        echo
        echo "usage:"
        echo "  glitchwp <name>              set an existing output as wallpaper"
        echo "  glitchwp gen <img> [flags]   run glitch.py on <img>, then set result"
        return 0
    end

    # gen mode: glitch a source image, then set the result as wallpaper
    if test "$argv[1]" = gen
        if test (count $argv) -lt 2
            echo "glitchwp gen: need a source image" >&2
            return 1
        end
        set -l src "$argv[2]"
        set -l rest $argv[3..-1]
        if not test -f "$src"
            echo "glitchwp gen: no such file: $src" >&2
            return 1
        end
        set -l stem (string replace -r '\.[^./]+$' '' (basename "$src"))
        set -l out "$dir/$stem"_glitch.png
        "$dir/glitch.py" "$src" "$out" $rest; or return 1
        set argv $out
    end

    # Resolve the target image (path, or bare name under ~/glitch-art)
    set -l arg "$argv[1]"
    set -l target
    if test -f "$arg"
        set target (realpath "$arg")
    else if test -f "$dir/$arg"
        set target "$dir/$arg"
    else if test -f "$dir/$arg.png"
        set target "$dir/$arg.png"
    else
        echo "no glitch output matching '$arg' in $dir" >&2
        return 1
    end

    # If wpg already tracks this basename, switch by name (avoids `wp`'s
    # unconditional `wpg -a`, which aborts under set -e on a re-add).
    set -l base (basename "$target")
    if test -e "$wpgdir/$base"
        wp "$base"
    else
        wp "$target"
    end
end
