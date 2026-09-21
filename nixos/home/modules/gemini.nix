{ ... }:

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
}
