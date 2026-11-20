{ pkgs, pkgs-unstable }:

pkgs.mkShell {
  packages = with pkgs; [
    pkg-config
    libx11
    libxft
    libxinerama
    libxcb       # dwm swallow patch (xcb-res)
    fontconfig
    freetype
    harfbuzz
    gcc
    gnumake
  ];
}
