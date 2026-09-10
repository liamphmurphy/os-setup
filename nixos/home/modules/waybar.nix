{ config, pkgs, ... }:

{
  # Waybar things
  programs.waybar = {
    enable = true;

    settings = [
      # Bar on DP-1 (main)
      {
        layer = "top";
        position = "top";
        height = 32;
        output = [ "DP-1" ]; # <-- adjust to your monitor name
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "memory"
          "network"
          "pulseaudio"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          # Show workspaces only from this output, but keep mapping stable
          all-outputs = false;
          format = "{icon}"; # or "{name}"
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "default" = "";
          };
          on-click = "hyprctl dispatch workspace {id}";
          persistent-workspaces = {
            # map specific workspaces to this output
            "DP-1" = [
              1
              2
              3
              4
              5
            ];
          };
        };

        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        "clock" = {
          format = "{:%a %b %d  %H:%M}";
          tooltip = true;
        };

        "cpu" = {
          interval = 2;
          format = " {usage}%";
        };
        "memory" = {
          interval = 5;
          format = " {used:0.1f}G";
        };
        "network" = {
          format-wifi = "  {essid} {signalStrength}%";
          format-ethernet = "  {ifname}";
          format-disconnected = "󰖪";
          tooltip = true;
        };
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          tooltip = false;
        };
        "battery" = {
          format = "{icon} {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = true;
        };
        "tray" = {
          spacing = 8;
        };
      }
    ];

    # Minimal, readable styling (tweak as you like)
    style = ''
      * { font-family: JetBrainsMono Nerd Font, Iosevka, monospace; font-size: 12pt; }
      window#waybar { background: rgba(20,20,25,0.75); border-bottom: 1px solid rgba(255,255,255,0.06); }
      #clock, #cpu, #memory, #network, #pulseaudio, #battery, #tray, #window { padding: 0 10px; }
      #workspaces button { padding: 0 8px; margin: 4px 2px; border-radius: 8px; }
      #workspaces button.active { background: rgba(255,255,255,0.12); }
      #workspaces button.urgent { background: rgba(255,0,0,0.25); }
    '';
  };
}
