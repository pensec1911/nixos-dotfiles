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

  # slock needs a setuid wrapper, otherwise it aborts immediately
  programs.slock.enable = true;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet # nm-applet + nm-connection-editor
    wireplumber          # wpctl for volume keys
    libnotify            # notify-send
    arandr               # monitor layout GUI
    seahorse             # GUI for the keyring
  ];
}
