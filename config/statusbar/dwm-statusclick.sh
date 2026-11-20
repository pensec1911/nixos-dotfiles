# Called by dwm when the status text is clicked: dwm-statusclick <block> <button>
# Blocks are marked in config/slstatus/config.h with \x01, \x02, ...
# Buttons: 1 = left, 2 = middle, 3 = right, 4/5 = wheel up/down
block=$1
button=$2

case "$block:$button" in
  # 1: network
  1:1) bar-popup net 80x26 nmtui ;;
  1:2) if [ "$(nmcli radio wifi)" = enabled ]; then nmcli radio wifi off; notify-send "WLAN" "aus"
       else nmcli radio wifi on; notify-send "WLAN" "an"; fi ;;
  1:3) nm-connection-editor & ;;
  # 2: cpu
  2:*) bar-popup cpu 110x32 btop ;;
  # 3: ram
  3:1) bar-popup ram 56x22 bar-topmem ;;
  3:*) bar-popup cpu 110x32 btop ;;
  # 4: battery
  4:*) bar-popup bat 52x18 bar-battery ;;
  # 6: volume (left: mixer, middle: mute, wheel: +/-)
  6:1) pavucontrol & ;;
  6:2) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  6:4) wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
  6:5) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  # 5: clock
  5:*) bar-popup cal 66x14 bar-calendar ;;
esac
