# Vesper (github.com/liamphmurphy/Vesper) as a Docker Compose stack, reachable
# only from the tailnet through `tailscale serve`.
#
# The stack runs from a git checkout at `directory` with its own `.env`
# (SECRETS_KEY, PUBLIC_URL, ...). Neither lives in this repo: see
# docs/vesper-server.md for the one-time setup.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.vesper;
  docker = "${config.virtualisation.docker.package}/bin/docker";
  tailscale = "${config.services.tailscale.package}/bin/tailscale";
in
{
  options.services.vesper = {
    enable = lib.mkEnableOption "Vesper, served to the tailnet over HTTPS";

    directory = lib.mkOption {
      type = lib.types.str;
      default = "/srv/vesper";
      description = "Git checkout of Vesper, holding its .env.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "LAZYAGENTS_PORT: where Vesper's Caddy listens on 127.0.0.1.";
    };

    playgroundPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = lib.range 8090 8094;
      description = ''
        PLAYGROUND_PORTS. The web app opens a playground at Vesper's own host on
        one of these ports, so each is served over HTTPS on the tailnet too.
      '';
    };

    backup = {
      repository = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "sftp:backup@nas:/srv/restic/vesper";
        description = "Restic repository for nightly backups; null turns backups off.";
      };
      passwordFile = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/secrets/restic-vesper";
        description = "File holding the restic repository password (root-only, not in git).";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        virtualisation.docker = {
          enable = true;
          # Agent builds churn through images and build cache.
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };
        environment.systemPackages = [ pkgs.git ];

        # Compose publishes everything on 127.0.0.1 (LAZYAGENTS_BIND's default).
        # Docker's own iptables rules bypass this firewall, so never set
        # LAZYAGENTS_BIND=0.0.0.0 here: tailscale serve is the only way in.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 443 ] ++ cfg.playgroundPorts;

        systemd.services.vesper = {
          description = "Vesper (docker compose)";
          wantedBy = [ "multi-user.target" ];
          requires = [ "docker.service" ];
          after = [
            "docker.service"
            "network-online.target"
          ];
          wants = [ "network-online.target" ];
          # Waits for the one-time setup instead of failing every boot.
          unitConfig.ConditionPathExists = "${cfg.directory}/.env";
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            WorkingDirectory = cfg.directory;
            # Builds only what's missing; updates are `git pull` then
            # `docker compose up -d --build` by hand.
            ExecStart = "${docker} compose up -d --remove-orphans";
            ExecStop = "${docker} compose stop";
            TimeoutStartSec = "30min";
          };
        };

        # Declarative `tailscale serve`: HTTPS on the tailnet name with a
        # Tailscale-issued certificate, proxied to the loopback ports.
        # Never Funnel: that would publish Vesper to the internet.
        systemd.services.vesper-tailscale-serve = {
          description = "Serve Vesper to the tailnet";
          wantedBy = [ "multi-user.target" ];
          wants = [ "tailscaled.service" ];
          after = [
            "tailscaled.service"
            "vesper.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = 30;
          };
          script = ''
            # Fails (and retries) until the node is logged in to the tailnet.
            ${tailscale} status --peers=false >/dev/null
            ${tailscale} serve --bg --https=443 http://127.0.0.1:${toString cfg.port}
            ${lib.concatMapStrings (p: ''
              ${tailscale} serve --bg --https=${toString p} http://127.0.0.1:${toString p}
            '') cfg.playgroundPorts}
          '';
        };
      }

      (lib.mkIf (cfg.backup.repository != null) {
        services.restic.backups.vesper = {
          repository = cfg.backup.repository;
          passwordFile = cfg.backup.passwordFile;
          initialize = true;
          # A consistent dump instead of copying Postgres' live data files.
          backupPrepareCommand = ''
            install -d -m 700 /var/backup/vesper
            cd ${cfg.directory}
            ${docker} compose exec -T postgres pg_dump -U lazyagents -Fc lazyagents > /var/backup/vesper/postgres.dump
          '';
          paths = [
            "/var/backup/vesper"
            # Library files and artifacts.
            "/var/lib/docker/volumes/lazyagents_seaweed/_data"
            # Holds SECRETS_KEY: without it, stored secrets can't be decrypted.
            "${cfg.directory}/.env"
          ];
          timerConfig = {
            OnCalendar = "03:30";
            Persistent = true;
          };
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 6"
          ];
        };
      })
    ]
  );
}
