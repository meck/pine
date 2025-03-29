{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  nix = {
    gc.automatic = true;

    # Deduplicate and optimize nix store
    settings.auto-optimise-store = true;
  };

  boot = {
    # Systemd in initrd
    initrd.systemd.enable = true;

    # Clean /tmp on each boot
    tmp.cleanOnBoot = true;
  };

  # Use systemd networking
  networking.useNetworkd = true;
  systemd.network.enable = true;
  services.resolved.enable = true;

  services.openssh.enable = true;

  networking.hostName = lib.mkDefault "pine";

  environment.systemPackages = with pkgs; [
    file
    gitMinimal
    (htop.override {
      # pulls in lots of stuff
      sensorsSupport = false;
    })
    iperf3
    lsof
    nano
    nmap
    p7zip
    picocom
    psmisc
    rsync
    tree
    unrar
    unzip
    usbutils
    wget
    which
    whois
    zip
  ];

  # Time zone.
  time.timeZone = lib.mkDefault "Europe/Stockholm";

  programs = {
    # Editor
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };

}
