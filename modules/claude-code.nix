{ pkgs-unstable, ... }:

# Claude Code via Home-Manager-Modul.
# Paket kommt aus nixos-unstable, weil Claude Code sehr oft released wird und
# der stable-Channel deutlich hinterherhinkt. Der Auto-Updater ist im
# nixpkgs-Paket deaktiviert -> Updates per `nix flake update nixpkgs-unstable`.
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;

    # Hinweis: Sobald `settings` gesetzt ist, wird ~/.claude/settings.json ein
    # read-only Symlink in den Nix-Store. Claude Code kann dann z. B. über
    # /config keine globalen Einstellungen mehr selbst speichern.
    # Projektbezogene Einstellungen (.claude/settings.local.json im Repo)
    # bleiben davon unberührt.
    #
    # settings = {
    #   includeCoAuthoredBy = false;
    #   permissions = {
    #     deny = [ "Read(./.env)" "Read(./secrets/**)" ];
    #   };
    # };

    # Globale Anweisungen (~/.claude/CLAUDE.md)
    # memory.text = ''
    #   - Antworte auf Deutsch.
    # '';

    # MCP-Server (werden per --mcp-config in den Wrapper eingebaut)
    # mcpServers = { };
  };
}
