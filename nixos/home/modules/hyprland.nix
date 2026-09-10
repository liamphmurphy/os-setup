{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # The other nix files my hyprland config relies on
  imports = [
    inputs.walker.homeManagerModules.default
    ./walker.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    # hyprland things
    pyprland
    hyprpicker
    hyprcursor
    phinger-cursors
    hyprlock
    hypridle
    hyprpaper
    hyprsunset
    hyprpolkitagent
  ];

  # Hyprland
  ## set cursor
  home.pointerCursor = {
    enable = true;
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 16;
  };
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "/home/liam/Pictures/wall.jpg" ];

      wallpaper = [
        ",/home/liam/Pictures/wall.jpg"
      ];
    };
  };

  services.hyprsunset = {
    enable = true;

    # Optional: pass CLI flags to the long-running hyprsunset daemon
    extraArgs = [ ]; # e.g., [ "--max-gamma" "150" ]

    # Timed transitions: OFF at 06:00, ON at 20:00.
    transitions = {
      morning = {
        calendar = "*-*-* 06:00:00";
        requests = [
          [ "identity" ] # no color shift
        ];
      };
      night = {
        calendar = "*-*-* 20:00:00";
        requests = [
          [
            "temperature"
            "3300"
          ] # tweak to taste
          # [ "gamma" "1.0" ]      # optional extra tweak
        ];
      };
    };
  };

  services.hypridle = {
    enable = true;
    # lock after 10 min, then suspend after 15 min
    settings = {
      listener = [
        {
          timeout = 600;
          on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      # pcloud is intentionally kept as a manually installed application.
      exec-once = pcloud
    '';

    settings = {
      general = {
        layout = "dwindle";
      };

      dwindle = {
        force_split = 2; # make windows split to the right
      };

      monitor = [
        "DP-1, 3440x1440@165, 0x0, 1, vrr, 2"
        "DP-2, disable"
      ];

      exec-once = [
        "walker --gapplication-service &"
      ];

      input = {
        kb_layout = "us";
      };

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
          "workIn, 0.72, -0.07, 0.41, 0.98"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
          "specialWorkspace, 1, 5, workIn, slidevert"
        ];
      };

      "$mod" = "SUPER";

      # Mouse bindings.
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        # Direct app shortcuts
        "$mod, B, exec, firefox"
        "$mod, O, exec, obsidian"

        # Custom made web app shortcuts, web apps defined in ./webapps.nix
        "$mod, Y, exec, launch-ytmusic"

        # Rofi
        "$mod, SPACE, exec, walker"

        # Window/Session actions.
        "$mod, Q, killactive,"
        "$mod, W, fullscreen, 1"
        "$mod SHIFT, W, fullscreen"
        "$mod, E, togglefloating,"
        "$mod, delete, exit,"

        # Dwindle
        "$mod, T, togglesplit,"
        "$mod, P, pseudo,"

        # Lock screen
        "$mod, Escape, exec, hyprlock"

        # Application shortcuts.
        "$mod, Return, exec, ghostty"
        "$mod SHIFT, Return, exec, ghostty --class floating"

        # Special workspace
        "$mod, S, togglespecialworkspace"
        "$mod SHIFT, S, movetoworkspacesilent, special"

        # Launcher
        # "$mod, A, exec, rofi -show drun -kb-cancel Super_L"
        "$mod SHIFT, A, exec, ags -t launcher"

        # Screenshot
        "$mod SHIFT, z, exec, wl-copy < $(grimshot --notify save area $XDG_PICTURES_DIR/Screenshots/$(TZ=utc date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png'))"

        # Move window focus with vim keys.
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Music control
        "$mod ALT, m, exec, pulsemixer --id $(pulsemixer --list-sources | cut -f3 | grep 'Default' | cut -d ',' -f 1 | cut -c 6-) --toggle-mute"
        ", XF86AudioMicMute, exec, pulsemixer --id $(pulsemixer --list-sources | cut -f3 | grep 'Default' | cut -d ',' -f 1 | cut -c 6-) --toggle-mute"
        ",XF86AudioMute, exec, pulsemixer --id $(pulsemixer --list-sinks | cut -f3 | grep 'Default' | cut -d ',' -f 1 | cut -c 6-) --toggle-mute"
        "$mod ALT, l, exec, hyprmusic next"
        ",XF86AudioNext, exec, hyprmusic next"
        "$mod ALT, h, exec, hyprmusic previous"
        ", XF86AudioPrev, exec, hyprmusic previous"
        "$mod ALT, p, exec, hyprmusic play-pause"
        ", XF86AudioPlay, exec, hyprmusic play-pause"

        # Swap windows with vim keys
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        "$mod SHIFT, c, centerwindow, 1"

        # Move monitor focus.
        "$mod, TAB, focusmonitor, +1"

        # Switch workspaces.
        # Switch workspaces (no exec)
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod CTRL, h, workspace, r-1"
        "$mod, Left, workspace, r-1"
        "$mod CTRL, l, workspace, r+1"
        "$mod, Right, workspace, r+1"

        # Scroll through monitor workspaces with mod + scroll
        "$mod, mouse_down, workspace, r-1"
        "$mod, mouse_up, workspace, r+1"
        "$mod, mouse:274, killactive,"

        # Move active window to a workspace.
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        "$mod CTRL SHIFT, l, movetoworkspace, r+1"
        "$mod SHIFT, Right, movetoworkspace, r+1"
        "$mod CTRL SHIFT, h, movetoworkspace, r-1"
        "$mod SHIFT, Left, movetoworkspace, r-1"
      ];
    };
  };
}
