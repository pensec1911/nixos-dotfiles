# Clickable dwm status bar: dwm runs `dwm-statusclick <block> <button>` when
# a block of the slstatus text is clicked (patch in config/dwm/dwm.c,
# block markers in config/slstatus/config.h). Scripts live in config/statusbar.
{ pkgs, ... }:

let
  script = name: runtimeInputs: pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = builtins.readFile ../config/statusbar/${name}.sh;
  };
in
{
  environment.systemPackages = with pkgs; [
    (script "dwm-statusclick" [ networkmanager networkmanagerapplet libnotify wireplumber pavucontrol ])
    (script "bar-popup" [ procps ])
    (script "bar-topmem" [ procps gawk coreutils ncurses ])
    (script "bar-battery" [ coreutils ncurses ])
    (script "bar-calendar" [ util-linux coreutils gnused ncurses ])
    (script "dmenu-power" [ procps ])   # uses the user's patched dmenu from PATH
  ];
}
