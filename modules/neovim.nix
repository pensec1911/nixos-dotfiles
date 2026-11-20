{ config, pkgs, lib, ...}:

{

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf

    lua-language-server
    nil
    nixpkgs-fmt

    nodejs
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # nvim config dir is an out-of-store symlink -> don't write init.lua into it
    sideloadInitLua = true;
    withRuby = false;
    withPython3 = false;
  };
}
