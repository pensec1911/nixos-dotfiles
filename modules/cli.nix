# Terminal quality-of-life tools.
{ pkgs, ... }:

{
  programs.bat = {
    enable = true;                         # cat with syntax highlighting
    config.theme = "TwoDark";
  };

  programs.eza = {
    enable = true;                         # ls replacement (aliases in bash.nix)
    git = true;
    icons = "auto";
    enableBashIntegration = false;         # keep our own ll/la/l aliases
  };

  programs.zoxide = {
    enable = true;                         # `z foo` jumps to the most used dir matching foo
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;                         # Ctrl+R history, Ctrl+T files, Alt+C cd
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
  };

  programs.tealdeer = {
    enable = true;                         # `tldr tar`: short examples instead of man pages
    settings.updates.auto_update = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    escapeTime = 0;
    historyLimit = 10000;
    terminal = "tmux-256color";
  };

  # nix-index with the prebuilt database from the nix-index-database flake:
  #   `, cowsay`        run a program without installing it (comma)
  #   `nix-locate foo`  find which package contains a file
  #   unknown commands suggest the package that provides them
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs; [
    gdu                                    # interactive disk usage (`gdu /`)
  ];
}
