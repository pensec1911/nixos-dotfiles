# bar-popup <name> <cols>x<rows> <command...>
# Opens a small floating st in the top right corner. Clicking the same
# block again closes it (toggle). dwm floats it via the "statuspopup" rule.
name=$1
geom=$2
shift 2
inst="statuspopup-$name"

if pkill -f -- "-n $inst " ; then
  exit 0
fi
exec st -n "$inst" -t "$name" -g "$geom-12+34" -e "$@"
