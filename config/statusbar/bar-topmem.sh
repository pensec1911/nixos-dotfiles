# Memory usage grouped by program (RSS summed over all processes of an app)
trap 'tput cnorm' EXIT
tput civis
while :; do
  {
    printf '\033[H'
    free -h | awk 'NR==2 {printf "  \033[1mRAM\033[0m  %s / %s benutzt, %s verfügbar\033[K\n", $3, $2, $7}
                   NR==3 {printf "  \033[1mSwap\033[0m %s / %s\033[K\n\n", $3, $2}'
    total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    ps -eo rss=,comm= | awk -v total="$total" '
      { rss=$1; $1=""; name=substr($0,2); sub(/^\./, "", name); sub(/-wrap(ped)?$/, "", name)
        a[name]+=rss; n[name]++ }
      END { for (k in a) printf "%d\t%d\t%s\n", a[k], n[k], k }' |
      sort -rn | awk -F'\t' -v total="$total" '
      NR <= 15 { mib=$1/1024; pct=100*$1/total; w=int(pct/4+0.5); bar=""
        for (i=0;i<w;i++) bar=bar "█"
        name=$3; if ($2>1) name=name " (" $2 ")"
        printf "  %-22.22s %7.0f MiB %5.1f%% \033[34m%s\033[0m\033[K\n", name, mib, pct, bar }'
    printf '\n  \033[2mq schließen · Rechtsklick auf RAM: btop\033[0m\033[J'
  }
  read -rsn1 -t 2 key && [ "$key" = q ] && exit 0
done
