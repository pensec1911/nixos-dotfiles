# User-session desktop services for dwm: tray applets, notifications,
# compositor, polkit agent, screenshots and a consistent dark theme.
{ pkgs, ... }:

{
  # notifications (notify-send, app popups)
  services.dunst = {
    enable = true;
    settings.global = {
      font = "monospace 10";
      frame_color = "#005577";
      background = "#222222";
      foreground = "#eeeeee";
      offset = "(15, 40)";
      corner_radius = 4;
    };
  };

  # compositor: mainly against tearing, no eye candy
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;
  services.flameshot.enable = true;

  # Java apps render blank/grey in non-reparenting WMs like dwm without this
  home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

  # dark theme for GTK (Thunar, Firefox dialogs, ...)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };

  # dark theme for Qt (Okular, KeePassXC, ...)
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}
