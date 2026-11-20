# Battery details from sysfs (handles energy_* and charge_* batteries)
trap 'tput cnorm' EXIT
tput civis
rd() { cat "$1" 2>/dev/null || echo 0; }
while :; do
  {
    printf '\033[H\n'
    now_sum=0; full_sum=0; rate_sum=0; state=""
    for b in /sys/class/power_supply/BAT*; do
      [ -e "$b/status" ] || continue
      if [ -e "$b/energy_now" ]; then
        now=$(rd "$b/energy_now"); full=$(rd "$b/energy_full"); design=$(rd "$b/energy_full_design")
        rate=$(rd "$b/power_now")
      else
        now=$(rd "$b/charge_now"); full=$(rd "$b/charge_full"); design=$(rd "$b/charge_full_design")
        rate=$(rd "$b/current_now")
      fi
      st=$(rd "$b/status")
      [ "$st" = Discharging ] || [ "$st" = Charging ] && state=$st
      now_sum=$((now_sum + now)); full_sum=$((full_sum + full)); rate_sum=$((rate_sum + rate))
      health=0; [ "$design" -gt 0 ] && health=$((100 * full / design))
      printf '  \033[1m%s\033[0m  %3s%%  %-13s\033[K\n' "${b##*/}" "$(rd "$b/capacity")" "$st"
      printf '        Zustand %s%% · %s Zyklen\033[K\n\n' "$health" "$(rd "$b/cycle_count")"
    done
    total=0; [ "$full_sum" -gt 0 ] && total=$((100 * now_sum / full_sum))
    printf '  \033[1mGesamt\033[0m %s%%\033[K\n' "$total"
    if [ "$rate_sum" -gt 0 ] && [ -n "$state" ]; then
      if [ "$state" = Discharging ]; then left=$((now_sum * 60 / rate_sum)); label="Restlaufzeit"
      else left=$(((full_sum - now_sum) * 60 / rate_sum)); label="Voll in"; fi
      printf '  %s: %dh %02dmin\033[K\n' "$label" $((left / 60)) $((left % 60))
    else
      printf '  am Netzteil\033[K\n'
    fi
    printf '\n  \033[2mq schließen\033[0m\033[J'
  }
  read -rsn1 -t 2 key && [ "$key" = q ] && exit 0
done
