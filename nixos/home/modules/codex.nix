{ lib, ... }:

{
  # Keep the project harness in the Nix configuration so Home Manager installs
  # it consistently on every machine/profile.
  home.file.".codex/skills/project-harness" = {
    source = ../files/codex/project-harness;
    recursive = true;
    # Replace the equivalent manually installed copy on first activation.
    force = true;
  };

  # Codex's skill discovery does not reliably recognize SKILL.md when it is a
  # symlink into the Nix store. Keep the source declarative, then materialize
  # this entry as a regular file after Home Manager links the skill directory.
  home.activation.codexProjectHarnessSkill = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    skill_file="$HOME/.codex/skills/project-harness/SKILL.md"
    rm -f "$skill_file"
    cp ${../files/codex/project-harness/SKILL.md} "$skill_file"
    chmod 644 "$skill_file"
  '';
}
