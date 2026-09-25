{ pkgs, ... }:

let
  clipWrapper = pkgs.writeShellApplication {
    name = "clip";
    runtimeInputs = with pkgs; [
      cliphist
      wl-clipboard
      fzf
    ];
    text = ''
      usage() {
        cat <<'EOF'
clip - Interactive CLI clipboard manager for WSL (cliphist + fzf)

Usage:
  clip [options]

Options:
  -c, --copy       Select an entry and copy it to clipboard (default)
  -p, --print      Select an entry and print it to stdout (useful for pipes)
  -d, --delete     Select an entry and delete it from history
  -w, --wipe       Wipe all clipboard history
  -l, --list       List clipboard history
  -h, --help       Show this help message

Keybindings inside fzf:
  Enter            Confirm selection (copy or print)
  Ctrl+X           Delete highlighted item from history and refresh
  Ctrl+D / Ctrl+U  Scroll preview down / up
  Esc / Ctrl+C     Cancel
EOF
      }

      MODE="copy"

      case "''${1:-}" in
        -h|--help)
          usage
          exit 0
          ;;
        -p|--print)
          MODE="print"
          ;;
        -d|--delete)
          MODE="delete"
          ;;
        -w|--wipe)
          read -r -p "Wipe all clipboard history? [y/N] " confirm
          if [[ "$confirm" =~ ^[Yy]$ ]]; then
            cliphist wipe
            echo "Clipboard history wiped." >&2
          fi
          exit 0
          ;;
        -l|--list)
          cliphist list
          exit 0
          ;;
        -c|--copy|"")
          MODE="copy"
          ;;
        *)
          echo "Unknown option: $1" >&2
          usage >&2
          exit 1
          ;;
      esac

      if [[ -z "$(cliphist list)" ]]; then
        echo "Clipboard history is empty." >&2
        exit 0
      fi

      selected=$(cliphist list | fzf \
        --prompt="Clipboard > " \
        --header="Enter: select | Ctrl+X: delete item | Esc: quit" \
        --preview="echo {} | grep -q '\[\[ binary data .* \]\]' && echo '[binary data]' || echo {} | cliphist decode" \
        --preview-window="down:50%:wrap" \
        --bind="ctrl-d:preview-page-down,ctrl-u:preview-page-up" \
        --bind="ctrl-x:execute-silent(echo {} | cliphist delete)+reload(cliphist list)")

      if [[ -z "$selected" ]]; then
        exit 0
      fi

      case "$MODE" in
        copy)
          echo "$selected" | cliphist decode | wl-copy
          echo "Copied to clipboard." >&2
          ;;
        print)
          echo "$selected" | cliphist decode
          ;;
        delete)
          echo "$selected" | cliphist delete
          echo "Deleted item." >&2
          ;;
      esac
    '';
  };
in
{
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
    clipnotify
    clipWrapper
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.shellAliases = {
    clip-wipe = "cliphist wipe";
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard management daemon (cliphist)";
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };
    Service = {
      Environment = [
        "DISPLAY=:0"
        "WAYLAND_DISPLAY=wayland-0"
      ];
      ExecStart = "${pkgs.writeShellScript "cliphist-watcher" ''
        set -eu
        ${pkgs.wl-clipboard}/bin/wl-paste --no-newline 2>/dev/null | ${pkgs.cliphist}/bin/cliphist store 2>/dev/null || true
        while ${pkgs.clipnotify}/bin/clipnotify; do
          ${pkgs.wl-clipboard}/bin/wl-paste --no-newline 2>/dev/null | ${pkgs.cliphist}/bin/cliphist store 2>/dev/null || true
          ${pkgs.wl-clipboard}/bin/wl-paste --type image 2>/dev/null | ${pkgs.cliphist}/bin/cliphist store 2>/dev/null || true
        done
      ''}";
      Restart = "always";
      RestartSec = "2s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
