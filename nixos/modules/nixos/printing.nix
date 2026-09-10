{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.gutenprint
      pkgs.hplip
    ];
  };

  # Avahi enables discovery of printers advertised on the local network.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Plasma's printer manager provides the GUI for adding and configuring
  # printers through CUPS.
  environment.systemPackages = [ pkgs.kdePackages.print-manager ];
}
