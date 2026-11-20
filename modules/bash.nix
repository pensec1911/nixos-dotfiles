{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    historySize = 10000;
    historyControl = [ "ignoredups" "erasedups" ];
    shellAliases = {
      ll = "eza -la --group-directories-first";
      la = "eza -a";
      l = "eza";
      lt = "eza --tree --level=2";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      nrs = "nh os switch";   # rebuild + diff; flake path set in configuration.nix
    };
    initExtra = ''
      PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
    '';
  };
}
