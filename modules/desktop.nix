# System-side desktop services that a full DE (e.g. KDE) would bring along,
# so the dwm session has keyring, polkit, Thunar mounting etc.
{ pkgs, ... }:

{
  # Secret Service (stores logins for Proton VPN/Pass, browsers, ...)
  services.gnome.gnome-keyring.enable = true;
  # unlock the keyring automatically with the login password in ly
  security.pam.services.ly.enableGnomeKeyring = true;

  # privilege prompts for GUI apps (agent itself runs per user, see desktop-home.nix)
  security.polkit.enable = true;

  # Thunar: mounting, trash, network shares, thumbnails
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # needed for GTK settings / dark mode written via home-manager dconf
  programs.dconf.enable = true;

  # screen locker: i3lock-color (also sets up the PAM service "i3lock")
  programs.i3lock = {
    enable = true;
    package = pkgs.i3lock-color;
  };

  # icon font for dwm bar, dmenu and slstatus; Noto as fallback so websites
  # and notifications have glyphs for every script and emoji
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  # desktop portal: proper GTK file dialogs for Firefox, Electron apps, ...
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # OpenSnitch: per-application outbound firewall. The UI (started in
  # desktop-home.nix) pops up for each new connection; rules are kept in
  # /var/lib/opensnitch/rules.
  services.opensnitch = {
    enable = true;
    # the eBPF monitor is a kernel module that does not build against
    # linuxPackages_latest (7.x) yet; "proc" works on any kernel
    settings.ProcMonitorMethod = "proc";
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet # nm-applet + nm-connection-editor
    wireplumber          # wpctl for volume keys
    libnotify            # notify-send
    arandr               # monitor layout GUI
    seahorse             # GUI for the keyring

    # `lock`: blurred screenshot + clock, colors match dwm (Mod+Shift+x)
    (writeShellScriptBin "lock" ''
      exec ${i3lock-color}/bin/i3lock-color \
        --blur 8 \
        --clock --indicator \
        --time-str "%H:%M" --date-str "%A, %d.%m.%Y" \
        --time-size 64 --date-size 20 \
        --time-color eeeeeeff --date-color eeeeeeff \
        --inside-color 22222299 --ring-color 005577ff \
        --insidever-color 22222299 --ringver-color 3399ccff \
        --insidewrong-color 22222299 --ringwrong-color cc3333ff \
        --keyhl-color 3399ccff --bshl-color cc3333ff \
        --line-uses-inside --separator-color 00000000 \
        --verif-color eeeeeeff --wrong-color eeeeeeff \
        --verif-text "..." --wrong-text "falsch" --noinput-text "leer" \
        --radius 120 --ring-width 8 \
        --ignore-empty-password --show-failed-attempts \
        "$@"
    '')
  ];
}
