# User-session desktop services for dwm: tray applets, notifications,
# compositor, polkit agent, screenshots and a consistent dark theme.
{ pkgs, lib, config, ... }:

let
  torrentDir = "${config.home.homeDirectory}/Downloads/torrents";
  torrentTmp = "${torrentDir}/.incomplete";
in
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

  # auto-lock: after 10 min idle (xautolock) and before suspend / lid close
  # (xss-lock reacts to logind's lock signal); `lock` is defined in desktop.nix
  services.screen-locker = {
    enable = true;
    lockCmd = "/run/current-system/sw/bin/lock";
    inactiveInterval = 10;
  };

  # OpenSnitch popup/tray UI (the daemon is enabled in desktop.nix)
  services.opensnitch-ui.enable = true;

  # warm screen colours all day (same temperature day and night = always on)
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 52.5;   # Berlin; only used for the (identical) day/night switch
    longitude = 13.4;
    temperature = {
      day = 4500;
      night = 4500;
    };
  };

  # clipboard history, pick an older entry with Mod+v (dmenu)
  services.clipmenu.enable = true;

  # remembers the last active media player, so the media keys (playerctl)
  # control whatever played last
  services.playerctld.enable = true;

  home.packages = with pkgs; [
    thunderbird
    playerctl
    qbittorrent
  ];

  # qBittorrent: finished downloads in ~/Downloads/torrents, unfinished ones
  # in ~/Downloads/torrents/.incomplete. qBittorrent rewrites its config
  # itself, so instead of a read-only file from the store only these keys are
  # set on every switch (other settings from the GUI stay untouched).
  # Close qBittorrent before switching, otherwise it overwrites them on exit.
  home.activation.qbittorrentPaths = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    conf="${config.xdg.configHome}/qBittorrent/qBittorrent.conf"
    $DRY_RUN_CMD mkdir -p "${torrentTmp}" "$(dirname "$conf")"
    set_qbt() {
      $DRY_RUN_CMD ${pkgs.crudini}/bin/crudini --ini-options=nospace \
        --set "$conf" BitTorrent "$1" "$2"
    }
    set_qbt 'Session\DefaultSavePath' "${torrentDir}"
    set_qbt 'Session\TempPath' "${torrentTmp}"
    set_qbt 'Session\TempPathEnabled' true
  '';

  # default applications (xdg-open, Thunar, Firefox downloads, ...)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "okularApplication_pdf.desktop";
      "inode/directory" = "thunar.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "message/rfc822" = "thunderbird.desktop";
      "image/png" = "okularApplication_kimgio.desktop";
      "image/jpeg" = "okularApplication_kimgio.desktop";
      "image/gif" = "okularApplication_kimgio.desktop";
      "image/webp" = "okularApplication_kimgio.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "onlyoffice-desktopeditors.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-desktopeditors.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "onlyoffice-desktopeditors.desktop";
      "application/msword" = "onlyoffice-desktopeditors.desktop";
      "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
      "application/vnd.oasis.opendocument.text" = "onlyoffice-desktopeditors.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "onlyoffice-desktopeditors.desktop";
    };
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
    gtk4.theme = config.gtk.theme;
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
