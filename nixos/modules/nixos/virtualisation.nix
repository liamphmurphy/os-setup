{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        runAsRoot = false;
      };
    };
    containers.enable = true;
    docker = {
      enable = true;
    };
  };
  environment.systemPackages = [ pkgs.docker-compose ];
  programs.virt-manager.enable = true;
}
