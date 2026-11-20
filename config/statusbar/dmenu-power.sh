# dmenu-power: lock / suspend / reboot / shutdown / logout (dwm: Mod+Shift+e)
# Reboot, shutdown and logout ask for confirmation first.
dm() {
  dmenu -i -fn "JetBrainsMono Nerd Font:size=10" \
    -nb "#1a1b26" -nf "#a9b1d6" -sb "#7aa2f7" -sf "#1a1b26" "$@"
}
confirm() { [ "$(printf 'no\nyes\n' | dm -p "$1?")" = yes ]; }

choice=$(printf '%s\n' lock suspend reboot shutdown logout | dm -p power) || exit 0

case "$choice" in
  lock)     lock ;;
  suspend)  systemctl suspend ;;          # screen-locker locks before sleeping
  reboot)   confirm reboot && systemctl reboot ;;
  shutdown) confirm shutdown && systemctl poweroff ;;
  logout)   confirm logout && pkill -TERM -x dwm ;;   # dwm quits cleanly on SIGTERM
esac
