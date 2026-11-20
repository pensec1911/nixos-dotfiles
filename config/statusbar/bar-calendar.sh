# Live clock + 3-month calendar (today highlighted)
# h/l or arrows: month back/forward, t: today, q: close
trap 'tput cnorm' EXIT
tput civis
off=0
while :; do
  ref=$(date -d "$(date +%Y-%m-15) $off month" +'%m %Y')
  {
    printf '\033[H\n  \033[1;34m%s\033[0m   %s\033[K\n\n' "$(date +%H:%M:%S)" "$(date '+%A, %d. %B %Y · KW %V')"
    # shellcheck disable=SC2086
    cal --color=always -m -3 $ref | sed 's/^/  /; s/$/\x1b[K/'
    printf '\n  \033[2mh/l Monat · t heute · q schließen\033[0m\033[J'
  }
  if read -rsn1 -t 1 key; then
    [ "$key" = $'\e' ] && read -rsn2 -t 0.01 key
    case $key in
      q) exit 0 ;;
      h|'[D') off=$((off - 1)) ;;
      l|'[C') off=$((off + 1)) ;;
      t) off=0 ;;
    esac
  fi
done
