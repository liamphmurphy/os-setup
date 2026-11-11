# Runbook: Vesper server over Tailscale

## Problem

Reach Vesper from anywhere (MacBooks, iPhone) without putting it on the
public internet, with agent builds running on a dedicated PC.

## Environment

- Host `vesper`: bare-metal NixOS, `nixos/hosts/vesper`, modules
  `nixos/modules/nixos/server.nix` and `nixos/modules/nixos/vesper.nix`.
- Vesper's Docker Compose stack from a checkout at `/srv/vesper`, publishing
  only on `127.0.0.1` (8080 for the app, 8090–8094 for playgrounds).
- `tailscale serve` (never Funnel) gives
  `https://vesper.<tailnet>.ts.net` with a Tailscale certificate, plus the
  playground ports on the same name.

## Fix (one-time setup)

1. **Tailnet admin console**
   - DNS: enable MagicDNS and HTTPS Certificates.
   - Access controls: tag the server and stop it starting connections to your
     other devices (agent containers route out through the host). Replace the
     default allow-all rule:

     ```jsonc
     "tagOwners": { "tag:vesper": ["autogroup:admin"] },
     "grants": [
       // Your own devices reach everything; tagged devices start nothing.
       { "src": ["autogroup:member"], "dst": ["*"], "ip": ["*"] }
     ]
     ```

2. **Install NixOS** from the minimal ISO, labelling the root partition
   `nixos` and the EFI partition `boot`, then:

   ```sh
   nixos-generate-config --root /mnt --show-hardware-config \
     > nixos/hosts/vesper/hardware-configuration.nix   # commit this
   nixos-install --flake .#vesper
   ```

   After the first boot, set your password with `passwd`, and add your SSH
   public key to `users.users.liam.openssh.authorizedKeys.keys`.

3. **Join the tailnet**:
   `sudo tailscale up --advertise-tags=tag:vesper`, then in the admin console
   open the machine and **Disable key expiry**.

4. **Vesper checkout and `.env`** (the `.env` holds secrets and never goes in git):

   ```sh
   sudo git clone https://github.com/liamphmurphy/Vesper /srv/vesper
   cd /srv/vesper && sudo cp .env.example .env
   ```

   In `.env` set at least:
   - `SECRETS_KEY`: a new random key (`openssl rand -base64 32`).
   - `PUBLIC_URL=https://vesper.<tailnet>.ts.net`.
   - `POSTGRES_PASSWORD`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`: replace the
     defaults with random values.
   - Keep `LAZYAGENTS_BIND=127.0.0.1`. Docker's port rules bypass
     the NixOS firewall, so binding 0.0.0.0 would expose the sign-in page on
     the LAN.

   Build once: `sudo docker compose up -d --build`, or restart the
   `vesper` unit, which waits for `.env` to exist.

5. **Claim the install before serving it.** The first browser to reach
   Vesper sets the owner's password. From the box itself:
   `ssh -L 8080:127.0.0.1:8080 vesper`, then open `http://localhost:8080`
   on your Mac and create the account.

6. **Serve it**: `sudo systemctl restart vesper-tailscale-serve`
   (it also runs on every boot).

7. **Backups (optional)**: put the restic password in
   `/var/lib/secrets/restic-vesper` (mode 600, root), and set
   `services.vesper.backup.repository` in `hosts/vesper/default.nix`.
   Nightly at 03:30 it backs up a `pg_dump` of Postgres, the SeaweedFS
   volume, and `.env` (which holds `SECRETS_KEY`).

## Verify

- `tailscale status` on the box shows it logged in as `tag:vesper`.
- `tailscale serve status` lists 443 and 8090–8094 → `127.0.0.1`.
- From the iPhone on cellular (Wi-Fi off, Tailscale on):
  `https://vesper.<tailnet>.ts.net` loads, chats stream live, and a
  playground opens.
- From the LAN with Tailscale off: `curl http://<lan-ip>:8080` is refused.
- Isolation: `sudo docker run --rm alpine wget -T 5 -qO- http://<another-tailnet-ip>`
  times out.
- Backups: `sudo systemctl start restic-backups-vesper`, then
  `sudo restic -r <repo> --password-file /var/lib/secrets/restic-vesper snapshots`.
  Test a restore once.

## Notes

- Updating Vesper: `cd /srv/vesper && sudo git pull && sudo docker compose up -d --build`.
- Updating the OS: `sudo nixos-rebuild switch --flake ~/os-setup/nixos#vesper`.
  Roll back from the boot menu or with `nixos-rebuild switch --rollback`.
- The playground ports must match `PLAYGROUND_PORTS` in `.env` and
  `services.vesper.playgroundPorts`.
- Not verified yet on hardware: whether `tailscale serve` traffic passes the
  host firewall. The module opens 443 and the playground ports on
  `tailscale0` either way.
- If Tailscale's control plane becomes a concern, Headscale works with the
  same clients.
