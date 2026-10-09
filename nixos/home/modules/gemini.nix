{ lib, ... }:

{
  # Keep Gemini / Antigravity agent personas and custom skills in the Nix
  # configuration so Home Manager installs them consistently across profiles.
  home.file.".gemini/config/agents" = {
    source = ../files/gemini/agents;
    recursive = true;
    # Replace manually installed copies on activation.
    force = true;
  };

  home.file.".gemini/config/skills" = {
    source = ../files/gemini/skills;
    recursive = true;
    force = true;
  };

  # Antigravity does not reliably recognize agent personas when they are
  # symlinks into the Nix store. Keep the source declarative, then materialize
  # all agent files as regular files after Home Manager links them.
  home.activation.geminiAgentFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    agents_src="${../files/gemini/agents}"
    agents_dest="$HOME/.gemini/config/agents"
    if [ -d "$agents_src" ]; then
      find "$agents_src" -type f | while read -r src_file; do
        rel_path="''${src_file#$agents_src/}"
        dest_file="$agents_dest/$rel_path"
        mkdir -p "$(dirname "$dest_file")"
        rm -f "$dest_file"
        cp "$src_file" "$dest_file"
        chmod 644 "$dest_file"
      done
    fi
  '';
}
